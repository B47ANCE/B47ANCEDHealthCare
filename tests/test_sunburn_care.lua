package.loaded["Mortis/init"]={Authority={canWriteCanonicalState=function()return true end},Events={emit=function()end}}
package.preload["TimedActions/ISBaseTimedAction"]=function()
    ISBaseTimedAction={derive=function(self)local c={};c.__index=c;setmetatable(c,{__index=self});return c end,
        new=function(self,actor)return setmetatable({character=actor},{__index=self})end,perform=function()end}
    return true
end
local dose,history=1,{}
local Sunburn={getState=function()return {dose=dose,processedOperations=history}end,
    hasProcessedTreatment=function(_,op)for _,id in ipairs(history)do if id==op then return true end end;return false end,
    applyTreatment=function(_,amount,op)dose=math.max(0,dose-amount);history[#history+1]=op;return true,{}end}
package.loaded["lightWorks/lightWorks_Sunburn"]=Sunburn
local Med=require "medWorks/init"
local Care=require "medWorks/SunburnCare"
local uuid=0
getRandomUUID=function()uuid=uuid+1;return "12345678-1234-1234-1234-"..string.format("%012d",uuid)end
local Action=require "medWorks/SunburnCareAction"
local data,present,mode={},true,"ok"
local inv={contains=function()return present end,Remove=function()if mode=="before"then error("before")end;present=false;if mode=="after"then error("after")end end}
local actor={getInventory=function()return inv end,getModData=function()return data end,
    isDead=function()return false end,isDriving=function()return false end,transmitModData=function()end}
local currentId=123
local pack={getContainer=function()return inv end,getFullType=function()return "Base.Coldpack"end,getID=function()return currentId end}
assert(Care.validate(actor,pack))
local a=Action:new(actor,pack);assert(a:getDuration()==1500)
isClient=function()return true end;assert(not a:complete() and dose==1 and present and not a.completed)
isClient=function()return false end
assert(a:complete() and math.abs(dose-.9)<1e-8 and not present and not data.medWorksSunburnCareRecovery)
assert(not a:complete() and math.abs(dose-.9)<1e-8)
assert(not Care.complete(actor,pack) and dose==.9,"a removed pack cannot replay")
present=true;currentId=124;mode="after"
assert(not Care.complete(actor,pack) and dose==.9 and not present)
assert(Care.inspect(actor).requiresInspection and not Care.validate(actor,pack))
assert(not Care.resolve(actor,pack),"consumed without proven dose cannot refund or silently unlock")
-- Disposable pre-removal failure: exact supply and unchanged dose permit failure
-- resolution; the existing Med reservation is also cleared, without replay.
data={};currentId=125;present=true;mode="before"
assert(not Care.complete(actor,pack) and Care.inspect(actor).requiresInspection)
assert(Care.resolve(actor,pack) and not Care.inspect(actor).requiresInspection and present and dose==.9)
currentId=126;mode="ok";SandboxVars={medWorks={EnableSunburnCare=false}}
assert(not Care.complete(actor,pack) and present)
SandboxVars.medWorks={SunburnCareReduction=99,SunburnCareSeconds=-10}
assert(Care.settings().amount==.5 and Care.settings().seconds==5)
SandboxVars.medWorks.SunburnCareReduction=0/0;assert(Care.settings().amount==.1)
pack.getContainer=function()return {}end;assert(not Care.complete(actor,pack),"nested or remote supplies require transfer to main inventory")
print("cold-pack care: native callbacks, exact supply, replay, settings, uncertain removal and conservative recovery pass")
