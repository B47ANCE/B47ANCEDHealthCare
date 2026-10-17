local Med=require "medWorks/init"
local Treatment=require "medWorks/SunburnTreatment"
local Care={ID="medWorks.coolSunburn",ITEM="Base.Coldpack"}
local busy=setmetatable({},{__mode="k"})
local function call(o,m,...)
    if not o then return false end
    local ok,f=pcall(function()return o[m]end)
    if not ok or type(f)~="function" then return false end
    return pcall(f,o,...)
end
local function finite(v) return type(v)=="number" and v==v and math.abs(v)<math.huge end
function Care.settings()
    local vars=rawget(_G,"SandboxVars")
    local v=type(vars)=="table" and type(vars.medWorks)=="table" and vars.medWorks or {}
    local function number(key,default,min,max)
        local n=v[key];if not finite(n) then return default end
        return math.max(min,math.min(max,n))
    end
    return {enabled=v.EnableSunburnCare~=false,seconds=math.floor(number("SunburnCareSeconds",30,5,600)),
        amount=number("SunburnCareReduction",.1,.01,.5)}
end
function Care.validate(actor,item)
    if not Care.settings().enabled or Treatment.available~=true then return false,"sunburn care unavailable" end
    local alive,dead=call(actor,"isDead");local driving,atWheel=call(actor,"isDriving")
    if not alive or dead~=false or not driving or atWheel~=false then return false,"living stationary patient required" end
    local mdOk,data=call(actor,"getModData")
    if not mdOk or type(data)~="table" or data.medWorksSunburnCareRecovery~=nil then return false,"care recovery inspection required" end
    local invOk,inv=call(actor,"getInventory");local contained,present=call(inv,"contains",item)
    local typeOk,kind=call(item,"getFullType");local ownOk,container=call(item,"getContainer")
    local idOk,id=call(item,"getID")
    if not invOk or not contained or present~=true or not ownOk or container~=inv or not typeOk or kind~=Care.ITEM
        or not idOk or not finite(id) or id~=math.floor(id) or math.abs(id)>9007199254740991 then return false,"cold pack in main inventory required" end
    local loaded,Sunburn=pcall(require,"lightWorks/lightWorks_Sunburn")
    if not loaded or type(Sunburn.hasProcessedTreatment)~="function" then return false,"Spectrum treatment-receipt API unavailable" end
    local state=Sunburn.getState(actor)
    if not state or not finite(state.dose) or state.dose<=0 then return false,"documented sunburn required" end
    return true,{inventory=inv,data=data,itemId=id,state=state,Sunburn=Sunburn}
end
local function execute(context)
    local actor,item=context.patient,context.item
    local valid,view=Care.validate(actor,item);if not valid then return false,view end
    -- The existing procedure lock owns the patient. Persist intent BEFORE native
    -- removal: interruption may consume a pack, but cannot grant free/replayed care.
    local record={schemaVersion=1,operationId=context.operationId,itemId=view.itemId,
        doseBefore=view.state.dose,amount=Care.settings().amount,stage="removing"}
    view.data.medWorksSunburnCareRecovery=record
    call(actor,"transmitModData")
    local removed=call(view.inventory,"Remove",item)
    local checked,present=call(view.inventory,"contains",item)
    if not removed or not checked or present~=false then
        error("cold-pack removal uncertain; inspect care recovery",0)
    end
    record.stage="consumed";call(actor,"transmitModData")
    if type(isServer)=="function" and isServer()==true then
        if type(sendRemoveItemFromContainer)~="function" then error("inventory synchronization unavailable",0) end
        sendRemoveItemFromContainer(view.inventory,item)
    end
    local ok,result=view.Sunburn.applyTreatment(actor,record.amount,context.operationId)
    if not ok then error("sunburn commit uncertain; inspect care recovery",0) end
    record.stage="committed"
    view.data.medWorksSunburnCareRecovery=nil
    call(actor,"transmitModData")
    return true,result
end
if Treatment.available and not Med.Procedures[Care.ID] then
    Med.registerProcedure{id=Care.ID,validate=function(c)
        if type(c)~="table" or c.actor~=c.patient then return false,"self-care only" end
        return Care.validate(c.patient,c.item)
    end,execute=execute,lockKeys=function()return {"skin:uv-exposure"}end}
end
function Care.complete(actor,item)
    if type(isClient)=="function" and isClient()==true then return false,"non-authority" end
    if busy[actor] then return false,"care busy" end
    local valid,view=Care.validate(actor,item);if not valid then return false,view end
    local id=require("lightWorks/lightWorks_Operations").new("CARE")
    if not id then return false,"authority operation identity unavailable" end
    busy[actor]=true
    local called,ok,detail=pcall(Med.performProcedure,Care.ID,{patient=actor,actor=actor,item=item,operationId=id})
    busy[actor]=nil
    if not called then return false,"care transaction interrupted; inspect recovery" end
    return ok,detail
end
function Care.inspect(actor)
    local ok,data=call(actor,"getModData");if not ok or type(data)~="table" then return nil,"patient state unavailable" end
    local r=data.medWorksSunburnCareRecovery
    if r==nil then return {requiresInspection=false} end
    if type(r)~="table" or r.schemaVersion~=1 then return nil,"unsupported recovery record" end
    return {requiresInspection=true,operationId=r.operationId,itemId=r.itemId,stage=r.stage,doseBefore=r.doseBefore,amount=r.amount}
end
function Care.resolve(actor,item)
    if type(isClient)=="function" and isClient()==true then return false,"non-authority" end
    if busy[actor] then return false,"care busy" end
    local ok,data=call(actor,"getModData");local r=ok and data and data.medWorksSunburnCareRecovery
    if type(r)~="table" or r.schemaVersion~=1 or type(r.operationId)~="string"
        or not finite(r.doseBefore) or not finite(r.amount) then return false,"valid recovery record required" end
    local loaded,sunburn=pcall(require,"lightWorks/lightWorks_Sunburn")
    local state=loaded and sunburn.getState(actor)
    if not state then return false,"sunburn state unavailable" end
    local outcome
    if type(sunburn.hasProcessedTreatment)=="function" and sunburn.hasProcessedTreatment(actor,r.operationId)==true then outcome="completed" end
    if not outcome then
        local invOk,inv=call(actor,"getInventory");local idOk,id=call(item,"getID")
        local has,present=call(inv,"contains",item);local typeOk,kind=call(item,"getFullType")
        if invOk and has and present==true and idOk and id==r.itemId and typeOk and kind==Care.ITEM
            and state.dose==r.doseBefore then outcome="failed" end
    end
    if not outcome then return false,"outcome unproven; restore disposable save or inspect manually" end
    local resolved,reason=Med.resolveProcedureRecovery(actor,r.operationId,outcome)
    if not resolved then return false,reason end
    data.medWorksSunburnCareRecovery=nil;call(actor,"transmitModData")
    return true,outcome
end
Med.SunburnCare=Care
return Care
