isClient=function()return false end
isServer=function()return false end
getRandomUUID=function()return "12345678-1234-1234-1234-123456789abc" end
package.loaded["Mortis/init"]={Authority={canWriteCanonicalState=function()return true end},Events={emit=function()end}}
local S=require "lightWorks/lightWorks_Sunburn"
local Med=require "medWorks/init"
local Care=require "medWorks/SunburnCare"
local data={lightWorksSunburn={schemaVersion=1,dose=.8,severity=.3,processedOperations={}}}
local present=true
local inv={contains=function()return present end,Remove=function()present=false end}
local actor={getModData=function()return data end,getInventory=function()return inv end,
    isDead=function()return false end,isDriving=function()return false end,transmitModData=function()end}
local item={getFullType=function()return "Base.Coldpack"end,getID=function()return 12 end,getContainer=function()return inv end}
local original=S.applyTreatment
S.applyTreatment=function(...)
    local ok,value=original(...);assert(ok);error("interrupted after canonical dose commit")
end
assert(not Care.complete(actor,item) and not present and math.abs(S.getState(actor).dose-.7)<1e-8)
assert(Care.inspect(actor).requiresInspection)
assert(S.getState(actor).processedOperations==nil,"real Spectrum query intentionally hides history")
assert(Care.resolve(actor,item),"real canonical receipt proves completed outcome")
assert(not Care.inspect(actor).requiresInspection)
assert(not Med.inspectProcedureRecovery(actor).requiresInspection)
assert(not Care.complete(actor,item),"recovery must never create or refund a cold pack")
print("actual Spectrum/Medical commit interruption resolves from canonical receipt without dose replay or item refund")
