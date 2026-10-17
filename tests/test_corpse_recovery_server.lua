local mutations=0
package.loaded["medWorks/CorpseRecovery"]={complete=function()mutations=mutations+1 end}
local hooked;Events={OnClientCommand={Add=function(fn)hooked=fn end}}
local Server=require "medWorks/CorpseRecoveryServer"
for _,payload in ipairs({{}, {schemaVersion=1,requestId="instant",region="leftArm"}, {schemaVersion=2,requestId="other"}})do
    assert(not Server.handle("medWorks","recoverCorpsePart",{},payload))
end
assert(not hooked("medWorks","recoverCorpsePart",{},nil)and mutations==0)
assert(Server.handle("other","other",{},nil)==nil)
print("Legacy corpse-recovery commands reject all mutation attempts; native shared action is the only recovery commit path")
