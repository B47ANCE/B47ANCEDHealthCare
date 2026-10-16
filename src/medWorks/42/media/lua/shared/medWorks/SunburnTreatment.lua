local medWorks=require "medWorks/init"
local loaded,Sunburn=pcall(require,"lightWorks/lightWorks_Sunburn")
if not loaded or type(Sunburn)~="table" or type(Sunburn.applyTreatment)~="function" then
    medWorks.SunburnTreatment={ID="medWorks.treatSunburn",available=false}
    return medWorks.SunburnTreatment
end

local ID="medWorks.treatSunburn"
local function finite(value)
    value=tonumber(value);return value and value==value and value~=math.huge and value~=-math.huge and value or nil
end
local function validate(context)
    if type(context)~="table"or not context.patient then return false,"patient required"end
    local source=context.treatmentSource
    if type(source)~="string"or source==""or #source>128 then return false,"bounded treatment source required"end
    local amount=finite(context.amount)
    if not amount or amount<.01 or amount>.5 then return false,"treatment amount must be 0.01-0.5"end
    local state,err=Sunburn.getState(context.patient)
    if not state then return false,err or"sunburn state unavailable"end
    if (tonumber(state.dose)or 0)<=0 then return false,"patient has no documented sunburn dose"end
    return true
end
local function execute(context)
    local ok,result=Sunburn.applyTreatment(context.patient,context.amount,context.operationId)
    if not ok then return false,result end
    return true,result
end

if not medWorks.Procedures[ID]then
    medWorks.registerProcedure{id=ID,validate=validate,execute=execute,
        lockKeys=function()return{"skin:uv-exposure"}end}
end
medWorks.SunburnTreatment={ID=ID,validate=validate,available=true}
return medWorks.SunburnTreatment
