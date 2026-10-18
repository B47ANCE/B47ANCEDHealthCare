local Mortis=require "Mortis/init"

local medWorks=rawget(_G,"medWorks") or {}
medWorks.VERSION="0.12.1"
medWorks.Procedures=medWorks.Procedures or {}

local PART_TYPES={
    neck="medWorks.DetachedHead",
    leftArm="medWorks.DetachedArm", rightArm="medWorks.DetachedArm",
    leftHand="medWorks.DetachedHand", rightHand="medWorks.DetachedHand",
    leftLeg="medWorks.DetachedLeg", rightLeg="medWorks.DetachedLeg",
    leftFoot="medWorks.DetachedFoot", rightFoot="medWorks.DetachedFoot",
}

local severing=setmetatable({},{__mode="k"})
local function recoveryData(source)
    local ok,data=pcall(function() return source:getModData() end)
    if ok and type(data)=="table" then return data end
end
local function quarantine(source,details)
    local data=recoveryData(source)
    if data and data.medWorksSeverRecovery==nil then
        details=type(details)=="table" and details or {}
        data.medWorksSeverRecovery={
            schemaVersion=1,requiresInspection=true,
            regionId=type(details.regionId)=="string" and details.regionId or nil,
            reason=tostring(details.reason or "uncertain sever transaction"),
        }
        pcall(function() source:transmitModData() end)
    end
end
local function contains(destination,item)
    local ok,present=pcall(function() return destination:contains(item) end)
    if not ok then return nil end
    if present==true then return true end
    if present==false then return false end
    return nil
end

local function removeCreated(destination,item,reason)
    reason=tostring(reason or "anatomy transition rejected")
    if contains(destination,item)==true then pcall(function() destination:Remove(item) end) end
    local ok,present=pcall(function() return destination:contains(item) end)
    if not ok or present~=false then
        -- Keep this source locked pending inspection: retrying while an
        -- unremoved output remains could manufacture duplicate parts.
        return nil,reason.."; output rollback unverified; source quarantined",true
    end
    return nil,reason
end

local function canWrite(patient)
    if not Mortis.Authority or type(Mortis.Authority.canWriteCanonicalState)~="function" then return false end
    local ok,allowed=pcall(Mortis.Authority.canWriteCanonicalState,patient)
    return ok and allowed==true
end

local function emit(name,...)
    if Mortis.Events and type(Mortis.Events.emit)=="function" then
        local ok=pcall(Mortis.Events.emit,Mortis.Events,name,...)
        if not ok then pcall(print,"[medWorks] notification failed after committed operation: "..name) end
    end
end

local completing=setmetatable({},{__mode="k"})
local function patientData(patient,create)
    if not patient or not patient.getModData then return nil,"patient state unavailable" end
    local ok,data=pcall(function() return patient:getModData() end)
    if not ok or type(data)~="table" then return nil,"patient state unavailable" end
    if data.medWorks==nil then
        if not create then return nil,"patient state absent" end
        data.medWorks={schemaVersion=1,completedProcedures={}}
    end
    if type(data.medWorks)~="table" or data.medWorks.schemaVersion~=1
        or type(data.medWorks.completedProcedures)~="table" then return nil,"malformed patient state" end
    for _,key in ipairs({"activeProcedures","procedureLocks"}) do
        if data.medWorks[key]~=nil and type(data.medWorks[key])~="table" then return nil,"malformed patient state" end
    end
    if create then
        data.medWorks.activeProcedures=data.medWorks.activeProcedures or {}
        data.medWorks.procedureLocks=data.medWorks.procedureLocks or {}
    end
    return data.medWorks
end

local function copyKeys(keys)local copy={};for index,key in ipairs(keys)do copy[index]=key end;return copy end
local function sameKeys(a,b)
    if type(a)~="table"or type(b)~="table"or #a~=#b then return false end
    for index,key in ipairs(a)do if b[index]~=key then return false end end
    return true
end
local function reservationMatches(token,active,record)
    return type(active)=="table"and type(record)=="table"
        and active.procedureId==token.procedureId and record.procedureId==token.procedureId
        and record.operationId==token.operationId and sameKeys(active.lockKeys,record.lockKeys)
end

local function transmit(patient)
    if patient and patient.transmitModData then pcall(function() patient:transmitModData() end) end
end

local function procedureKeys(definition,context)
    local supplied=context.lockKeys
    if type(definition.lockKeys)=="function" then
        local ok,value=pcall(definition.lockKeys,context)
        if not ok then return nil,"procedure lock-key error" end
        supplied=value
    end
    if supplied==nil then supplied={"patient"} end
    if type(supplied)=="string" then supplied={supplied} end
    if type(supplied)~="table" then return nil,"procedure lock keys must be a table" end
    local result,seen={},{}
    for _,value in ipairs(supplied) do
        if type(value)~="string" or value=="" then return nil,"invalid procedure lock key" end
        if not seen[value] then seen[value]=true; result[#result+1]=value end
    end
    if #result==0 then result[1]="patient" end
    table.sort(result)
    return result
end

local function releaseProcedure(data,operationId)
    local active=data.activeProcedures[operationId]
    for _,key in ipairs(type(active)=="table" and active.lockKeys or {}) do
        if data.procedureLocks[key]==operationId then data.procedureLocks[key]=nil end
    end
    data.activeProcedures[operationId]=nil
end

function medWorks.registerProcedure(definition)
    assert(type(definition)=="table" and type(definition.id)=="string","procedure id required")
    assert(type(definition.validate)=="function" and type(definition.execute)=="function","procedure callbacks required")
    assert(not medWorks.Procedures[definition.id],"duplicate medWorks procedure: "..definition.id)
    medWorks.Procedures[definition.id]=definition
    return definition
end

function medWorks.getRegionAccess(patient,region)
    local ok,result,err=pcall(function()
        local Anatomy=require "Mortis/Runtime/AnatomyRuntime"
        local Coverage=require "Mortis/Runtime/ClothingCoverage"
        local anatomy,reason=Anatomy.get(patient)
        if not anatomy then return nil,reason end
        local body,bodyErr,canonical=Anatomy.getRegion(patient,region)
        if not body then return nil,bodyErr end
        local coverage,coverageErr=Coverage.region(patient,anatomy.speciesId,canonical)
        if not coverage then return nil,coverageErr end
        return {region=canonical,attached=body.attached~=false,destroyed=body.destroyed==true,
            accessible=body.attached~=false and not coverage.covered,coverage=coverage}
    end)
    if not ok then return nil,"anatomical clothing query failed" end
    return result,err
end

function medWorks.validateProcedure(id,context)
    local definition=medWorks.Procedures[id]
    if not definition then return false,"unknown procedure" end
    context=type(context)=="table" and context or {}
    if not context.patient then return false,"patient required" end
    if definition.requiresExposedRegion==true then
        if type(context.region)~="string" or context.region=="" then return false,"procedure region required" end
        local access,accessErr=medWorks.getRegionAccess(context.patient,context.region)
        if not access then return false,accessErr end
        if not access.accessible then return false,"anatomical region is detached or obstructed by clothing" end
    end
    local ok,allowed,reason=pcall(definition.validate,context)
    if not ok then return false,"procedure validation error" end
    if allowed~=true then return false,reason or "procedure rejected" end
    return true,definition
end

function medWorks.beginProcedure(id,context)
    local valid,definitionOrError=medWorks.validateProcedure(id,context)
    if not valid then return false,definitionOrError end
    if not canWrite(context.patient) then return false,"non-authority" end
    local data=patientData(context.patient,true)
    if not data then return false,"patient state unavailable" end
    local operationId=context.operationId or context.replayId
    if type(operationId)~="string" or operationId=="" then return false,"replay id required" end
    if data.completedProcedures[operationId] or data.activeProcedures[operationId] then
        return false,"procedure already attempted"
    end
    local keys,keyError=procedureKeys(definitionOrError,context)
    if not keys then return false,keyError end
    if data.completedProcedures[operationId]or data.activeProcedures[operationId]then return false,"procedure already attempted"end
    for _,key in ipairs(keys) do
        local owner=data.procedureLocks[key]
        if owner and owner~=operationId then return false,"patient resource busy: "..key end
    end
    local record={procedureId=id,status="reserved",operationId=operationId,lockKeys=keys}
    data.completedProcedures[operationId]=record
    data.activeProcedures[operationId]={procedureId=id,status="reserved",lockKeys=keys}
    for _,key in ipairs(keys) do data.procedureLocks[key]=operationId end
    transmit(context.patient)
    return true,{patient=context.patient,procedureId=id,operationId=operationId,lockKeys=copyKeys(keys)}
end

function medWorks.cancelProcedure(token,reason)
    if type(token)~="table" or not canWrite(token.patient) then return false,"non-authority" end
    if completing[token.patient] and completing[token.patient][token.operationId] then return false,"procedure is being validated" end
    local data=patientData(token.patient,true)
    local active=data and data.activeProcedures[token.operationId]
    local record=data and data.completedProcedures[token.operationId]
    if not reservationMatches(token,active,record) or active.status~="reserved" or record.status~="reserved" then return false,"procedure is not cancellable" end
    record.status="cancelled"
    record.reason=tostring(reason or "cancelled before execution")
    releaseProcedure(data,token.operationId)
    transmit(token.patient)
    return true
end

function medWorks.completeProcedure(token,context)
    context=type(context)=="table" and context or {}
    if type(token)~="table" or token.patient~=context.patient then return false,"procedure token mismatch" end
    token={patient=token.patient,procedureId=token.procedureId,operationId=token.operationId}
    if not canWrite(token.patient) then return false,"non-authority" end
    local definition=medWorks.Procedures[token.procedureId]
    if completing[token.patient] and completing[token.patient][token.operationId] then return false,"procedure is being validated" end
    local data=patientData(token.patient,true)
    local active=data and data.activeProcedures[token.operationId]
    local record=data and data.completedProcedures[token.operationId]
    if not definition or not reservationMatches(token,active,record) or active.status~="reserved" or record.status~="reserved" then
        return false,"procedure reservation unavailable"
    end
    if (context.operationId~=nil and context.operationId~=token.operationId)
        or (context.replayId~=nil and context.replayId~=token.operationId)then return false,"procedure replay identity mismatch"end
    local supplied={};for key,value in pairs(context)do supplied[key]=value end
    supplied.operationId=token.operationId;supplied.replayId=token.operationId
    local pending=completing[token.patient]or{};completing[token.patient]=pending;pending[token.operationId]=true
    local valid,validationReason=medWorks.validateProcedure(token.procedureId,supplied)
    local keys,keyReason
    if valid then keys,keyReason=procedureKeys(definition,supplied)end
    pending[token.operationId]=nil
    if supplied.patient~=token.patient or supplied.operationId~=token.operationId or supplied.replayId~=token.operationId then return false,"procedure completion identity changed"end
    -- Callback code cannot reenter completion/cancellation while validation runs.
    if data.activeProcedures[token.operationId]~=active or data.completedProcedures[token.operationId]~=record
        or active.status~="reserved"or record.status~="reserved"then return false,"procedure reservation changed"end
    if not valid then
        record.status="cancelled"
        record.reason=validationReason
        releaseProcedure(data,token.operationId)
        transmit(token.patient)
        return false,validationReason
    end
    if not keys or not sameKeys(keys,active.lockKeys)then return false,keyReason or "procedure reserved resources changed"end
    for _,key in ipairs(keys)do if data.procedureLocks[key]~=token.operationId then return false,"procedure lock ownership changed"end end
    if not canWrite(token.patient)then return false,"non-authority"end
    active.status="executing"
    record.status="executing"
    transmit(token.patient)
    local ok,result,reason=pcall(definition.execute,supplied)
    -- Preserve provider annotations without changing the caller's identity fields.
    for key in pairs(context)do
        if key~="patient"and key~="operationId"and key~="replayId"and supplied[key]==nil then context[key]=nil end
    end
    for key,value in pairs(supplied)do
        if key~="patient"and key~="operationId"and key~="replayId"then context[key]=value end
    end
    if not ok then
        -- Provider code may have changed the patient before throwing. Preserve
        -- the lock and explicit uncertain state until an operator resolves it.
        active.status="uncertain"
        record.status="uncertain"
        record.reason="procedure execution error"
        transmit(token.patient)
        return false,"procedure execution error; recovery inspection required"
    end
    record.status=result==true and "completed" or "failed"
    record.reason=result==true and nil or tostring(reason or "procedure failed")
    releaseProcedure(data,token.operationId)
    transmit(token.patient)
    if result~=true then return false,reason or "procedure failed; operation must not be replayed" end
    emit("MedicalProcedureCompleted",token.procedureId,supplied,result)
    return true,result
end

function medWorks.performProcedure(id,context)
    local begun,tokenOrError=medWorks.beginProcedure(id,context)
    if not begun then return false,tokenOrError end
    return medWorks.completeProcedure(tokenOrError,context)
end

function medWorks.inspectProcedureRecovery(patient)
    local data,reason=patientData(patient,false)
    if not data then
        if reason=="patient state absent"then return{requiresInspection=false,active={}}end
        return nil,reason
    end
    local result={requiresInspection=false,active={}}
    for operationId,active in pairs(data.activeProcedures or{}) do
        if type(operationId)~="string"or type(active)~="table"or type(active.lockKeys)~="table"then return nil,"malformed procedure reservation"end
        local entry={operationId=operationId,procedureId=active.procedureId,
            status=active.status,lockKeys={}}
        for i,key in ipairs(active.lockKeys or {}) do entry.lockKeys[i]=key end
        result.active[#result.active+1]=entry
        if active.status=="uncertain" then result.requiresInspection=true end
    end
    table.sort(result.active,function(a,b) return a.operationId<b.operationId end)
    return result
end

function medWorks.resolveProcedureRecovery(patient,operationId,outcome)
    if not canWrite(patient) then return false,"non-authority" end
    if completing[patient] and completing[patient][operationId]then return false,"procedure is being validated"end
    if outcome~="failed" and outcome~="completed" and outcome~="cancelled" then
        return false,"resolution outcome must be failed, completed, or cancelled"
    end
    local data=patientData(patient,true)
    local active=data and data.activeProcedures[operationId]
    local record=data and data.completedProcedures[operationId]
    if type(active)~="table"or type(active.procedureId)~="string"
        or not reservationMatches({procedureId=active.procedureId,operationId=operationId},active,record)then return false,"procedure recovery not found or malformed" end
    if active.status=="executing" then return false,"procedure is still executing" end
    if active.status=="uncertain" and outcome=="cancelled" then
        return false,"uncertain execution requires completed or failed resolution"
    end
    record.status=outcome
    record.reason="operator recovery resolution"
    releaseProcedure(data,operationId)
    transmit(patient)
    return true,record
end

local function sever(source,region,destination,options)
    options=type(options)=="table" and options or {}
    if not source then return nil,"source required" end
    if not canWrite(source) then return nil,"non-authority" end
    local regionState,definition,regionId=Mortis.Anatomy.getRegion(source,region)
    if not regionState then return nil,definition end
    if definition.severable~=true then return nil,"region is not severable" end
    if regionState.attached==false then return nil,"region already detached" end
    local fullType=options.itemType or PART_TYPES[regionId]
    if not fullType then return nil,"no detached item for region" end
    if not destination or not destination.AddItem or not destination.Remove or not destination.contains then
        return nil,"recoverable destination inventory required"
    end

    local provenance,provenanceErr=Mortis.DetachedParts.capture(source,regionId,{
        procedureId=options.procedureId or "medWorks.sever",
        practitionerStableId=options.practitionerStableId,
    })
    if not provenance then return nil,provenanceErr end
    -- Allocate off-inventory so even an insertion that throws leaves us with
    -- the exact output object to remove. Never create by AddItem(string).
    local ok,item=pcall(function() return instanceItem(fullType) end)
    if not ok or not item then return nil,"could not create detached part" end
    local writeOk,wrote,writeErr=pcall(Mortis.DetachedParts.write,item,provenance)
    if not writeOk or not wrote then return nil,writeOk and writeErr or "provenance write failed" end
    local inserted=pcall(function() destination:AddItem(item) end)
    if not inserted or contains(destination,item)~=true then
        return removeCreated(destination,item,"could not insert detached part")
    end
    local severOk,result,severErr=pcall(Mortis.Anatomy.sever,source,regionId,{transmit=options.transmit==true})
    if not severOk or not result then
        local _,reason,quarantined=removeCreated(destination,item,severOk and severErr or "anatomy transition threw; inspect source before retry")
        return nil,reason,quarantined or not severOk
    end
    if type(sendAddItemToContainer)=="function" then pcall(sendAddItemToContainer,destination,item) end
    emit("AnatomySevered",source,item,provenance,result,options)
    return item,provenance,result
end

function medWorks.sever(source,region,destination,options)
    if not source then return nil,"source required" end
    if not canWrite(source) then return nil,"non-authority" end
    local data=recoveryData(source)
    if severing[source] or (data and data.medWorksSeverRecovery~=nil) then
        return nil,"source is busy or requires recovery inspection"
    end
    -- Whole-source lock also excludes overlapping parent/child regions.
    severing[source]=true
    local ok,item,record,result=pcall(sever,source,region,destination,options)
    if ok and (item or result~=true) then severing[source]=nil end
    if not ok or (not item and result==true) then
        quarantine(source,{regionId=region,reason=record})
    end
    if not ok then return nil,"sever transaction failed; source requires recovery inspection" end
    return item,record,item and result or nil
end

local function matchingOutputs(destination,expected)
    if not destination or not expected then return nil,"destination and provenance required" end
    local ok,items=pcall(function() return destination:getItems() end)
    if not ok or not items then return nil,"destination items unavailable" end
    local okSize,size=pcall(function() return items:size() end)
    if not okSize or type(size)~="number" or size<0 then return nil,"destination size unavailable" end
    local matches={}
    for index=0,math.floor(size)-1 do
        local got,item=pcall(function() return items:get(index) end)
        if got and item then
            local read,record=pcall(Mortis.DetachedParts.read,item)
            if read and type(record)=="table" and record.regionId==expected.regionId
                and record.sourceStableId==expected.sourceStableId then matches[#matches+1]=item end
        end
    end
    return matches
end

function medWorks.inspectSeverRecovery(source,destination)
    local data=recoveryData(source)
    local quarantineRecord=data and data.medWorksSeverRecovery or nil
    if type(quarantineRecord)~="table" or quarantineRecord.requiresInspection~=true then
        return {status="clear",requiresInspection=false}
    end
    local region=quarantineRecord.regionId
    if not PART_TYPES[region] then
        return {status="manual-inspection",requiresInspection=true,reason="missing recovery region"}
    end
    local regionOk,state=pcall(Mortis.Anatomy.getRegion,source,region)
    if not regionOk or type(state)~="table" then
        return {status="manual-inspection",requiresInspection=true,regionId=region,reason="anatomy unavailable"}
    end
    local captureOk,expected=pcall(Mortis.DetachedParts.capture,source,region,{procedureId="medWorks.RecoveryInspection"})
    if not captureOk or type(expected)~="table" then
        return {status="manual-inspection",requiresInspection=true,regionId=region,attached=state.attached==true,
            reason="provenance unavailable"}
    end
    local matches,reason=matchingOutputs(destination,expected)
    if not matches then
        return {status="destination-required",requiresInspection=true,regionId=region,
            attached=state.attached==true,reason=reason}
    end
    local status
    if state.attached==true then status=#matches>0 and "rollback-output-found" or "safe-to-retry"
    elseif #matches<=1 then status="committed"
    else status="duplicate-output" end
    return {status=status,requiresInspection=true,regionId=region,attached=state.attached==true,
        matchingOutputs=#matches,items=matches}
end

function medWorks.resolveSeverRecovery(source,destination)
    if not canWrite(source) then return false,"non-authority" end
    local report=medWorks.inspectSeverRecovery(source,destination)
    if report.requiresInspection~=true then severing[source]=nil; return true,report end
    if report.status=="manual-inspection" or report.status=="destination-required"
        or report.status=="duplicate-output" then return false,report.status,report end
    if report.attached==true then
        for _,item in ipairs(report.items or {}) do
            local removed=pcall(function() destination:Remove(item) end)
            if not removed or contains(destination,item)~=false then
                return false,"output-removal-unverified",report
            end
        end
    end
    local data=recoveryData(source)
    if not data or data.medWorksSeverRecovery==nil then return false,"recovery state unavailable",report end
    data.medWorksSeverRecovery=nil
    severing[source]=nil
    pcall(function() source:transmitModData() end)
    report.requiresInspection=false
    report.resolved=true
    return true,report
end

function medWorks.getDetachedPartProvenance(item)
    return Mortis.DetachedParts.read(item)
end

medWorks.PART_TYPES=PART_TYPES
_G.medWorks=medWorks
return medWorks
