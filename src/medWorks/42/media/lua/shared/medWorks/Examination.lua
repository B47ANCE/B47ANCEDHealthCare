local medWorks=require "medWorks/init"

medWorks.ExaminationProviders=medWorks.ExaminationProviders or {}

local MAX_PROVIDERS=16
local HARD_PART_LIMIT=64

local function call(object,method,...)
    if not object or type(object[method])~="function" then return nil end
    local ok,value=pcall(object[method],object,...)
    if not ok then return nil end
    return value
end

local function finite(value)
    value=tonumber(value)
    if not value or value~=value or value==math.huge or value==-math.huge then return nil end
    return value
end

local function bool(object,method)
    return call(object,method)==true
end

local function configuredPartLimit(context)
    local requested=type(context)=="table" and finite(context.maxBodyParts) or nil
    local sandbox=rawget(_G,"SandboxVars")
    local configured=type(sandbox)=="table" and type(sandbox.medWorks)=="table"
        and finite(sandbox.medWorks.ExaminationMaxBodyParts) or nil
    local value=math.floor(requested or configured or 32)
    return math.max(1,math.min(HARD_PART_LIMIT,value))
end

local function partName(part,index)
    local partType=call(part,"getType")
    local enum=rawget(_G,"BodyPartType")
    if partType~=nil and type(enum)=="table" and type(enum.ToString)=="function" then
        local ok,value=pcall(enum.ToString,partType)
        if ok and type(value)=="string" and value~="" then return value end
    end
    if partType~=nil then
        local ok,value=pcall(tostring,partType)
        if ok and value and value~="" then return value end
    end
    return "BodyPart"..tostring(index)
end

local function observePart(part,fallbackIndex)
    if not part then return nil end
    local index=finite(call(part,"getIndex")) or fallbackIndex
    local result={
        index=math.floor(index),
        type=partName(part,index),
        health=finite(call(part,"getHealth")),
        pain=finite(call(part,"getPain")),
        bandaged=bool(part,"bandaged"),
        bandageDirty=bool(part,"isBandageDirty"),
        bitten=bool(part,"bitten"),
        scratched=bool(part,"scratched"),
        cut=bool(part,"isCut"),
        bleeding=bool(part,"bleeding"),
        bleedingTime=finite(call(part,"getBleedingTime")),
        deepWounded=bool(part,"deepWounded") or bool(part,"isDeepWounded"),
        deepWoundTime=finite(call(part,"getDeepWoundTime")),
        glass=bool(part,"haveGlass"),
        bullet=bool(part,"haveBullet"),
        stitched=bool(part,"stitched"),
        stitchTime=finite(call(part,"getStitchTime")),
        splinted=bool(part,"isSplint"),
        splintFactor=finite(call(part,"getSplintFactor")),
        fractureTime=finite(call(part,"getFractureTime")),
        burnt=bool(part,"isBurnt"),
        burnTime=finite(call(part,"getBurnTime")),
        needsBurnWash=bool(part,"isNeedBurnWash"),
        localWoundInfection=bool(part,"isInfectedWound"),
        localWoundInfectionLevel=finite(call(part,"getWoundInfectionLevel")),
    }
    -- Knox infection is deliberately absent. This adapter reports only the
    -- native per-wound infection fields owned by BodyPart.
    result.injured=(result.health and result.health<100) or result.pain and result.pain>0
        or result.bitten or result.scratched or result.cut or result.bleeding
        or result.deepWounded or result.glass or result.bullet or result.fractureTime and result.fractureTime>0
        or result.burnt or result.localWoundInfection
    return result
end

local function vanillaSupports(_,patient,context)
    return patient and (type(patient.getBodyDamage)=="function"
        or type(context)=="table" and context.bodyDamageSnapshot~=nil)
end

local function vanillaExamine(_,patient,context)
    -- A remote client's vanilla health panel observes BodyDamageRemote. It is
    -- disposable presentation state, but it is the correct read-only source;
    -- never silently substitute the remote object's non-subscribed BodyDamage.
    local bodyDamage=type(context)=="table" and context.bodyDamageSnapshot or nil
    if bodyDamage==nil then bodyDamage=call(patient,"getBodyDamage") end
    if not bodyDamage then return nil,"body damage unavailable" end
    local bodyParts=call(bodyDamage,"getBodyParts")
    if not bodyParts then return nil,"body parts unavailable" end
    local size=finite(call(bodyParts,"size"))
    if not size or size<0 then return nil,"body part count unavailable" end
    size=math.floor(size)
    local limit=configuredPartLimit(context)
    local result={
        kind="vanilla-human",
        overallHealth=finite(call(bodyDamage,"getHealth")),
        parts={},
        observedPartCount=0,
        availablePartCount=size,
        truncated=size>limit,
        injuredPartCount=0,
        localWoundInfectionCount=0,
    }
    for zeroIndex=0,math.min(size,limit)-1 do
        local part=call(bodyParts,"get",zeroIndex)
        local observation=observePart(part,zeroIndex)
        if observation then
            result.parts[#result.parts+1]=observation
            result.observedPartCount=result.observedPartCount+1
            if observation.injured then result.injuredPartCount=result.injuredPartCount+1 end
            if observation.localWoundInfection then
                result.localWoundInfectionCount=result.localWoundInfectionCount+1
            end
        end
    end
    return result
end

function medWorks.registerExaminationProvider(definition)
    assert(type(definition)=="table","examination provider definition required")
    assert(type(definition.id)=="string" and definition.id~="","examination provider id required")
    assert(type(definition.owner)=="string" and definition.owner~="","examination provider owner required")
    assert(type(definition.supports)=="function" and type(definition.examine)=="function",
        "examination provider callbacks required")
    assert(#medWorks.ExaminationProviders<MAX_PROVIDERS,"medWorks examination provider limit reached")
    for _,existing in ipairs(medWorks.ExaminationProviders) do
        assert(existing.id~=definition.id,"duplicate examination provider: "..definition.id)
    end
    definition.priority=finite(definition.priority) or 0
    medWorks.ExaminationProviders[#medWorks.ExaminationProviders+1]=definition
    table.sort(medWorks.ExaminationProviders,function(a,b)
        if a.priority==b.priority then return a.id<b.id end
        return a.priority>b.priority
    end)
    return definition
end

function medWorks.examine(examiner,patient,context)
    if not patient then return nil,"patient required" end
    context=type(context)=="table" and context or {}
    local report={schemaVersion=1,patient=patient,sections={},diagnostics={}}
    for _,provider in ipairs(medWorks.ExaminationProviders) do
        local supportedOk,supported=pcall(provider.supports,examiner,patient,context)
        if not supportedOk then
            report.diagnostics[#report.diagnostics+1]={providerId=provider.id,error="support check failed"}
        elseif supported==true then
            local ok,section,reason=pcall(provider.examine,examiner,patient,context)
            if ok and type(section)=="table" then
                report.sections[#report.sections+1]={providerId=provider.id,owner=provider.owner,data=section}
            else
                report.diagnostics[#report.diagnostics+1]={providerId=provider.id,
                    error=ok and tostring(reason or "invalid examination result") or "examination failed"}
            end
        end
    end
    if #report.sections==0 then return nil,"no examination provider",report end
    return report
end

medWorks.registerExaminationProvider{
    id="medWorks.VanillaHuman",
    owner="medWorks",
    priority=-100,
    supports=vanillaSupports,
    examine=vanillaExamine,
}

medWorks.EXAMINATION_MAX_PROVIDERS=MAX_PROVIDERS
medWorks.EXAMINATION_HARD_PART_LIMIT=HARD_PART_LIMIT
return medWorks
