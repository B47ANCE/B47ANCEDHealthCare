local calls=0
package.loaded["medWorks/CorpseRecovery"]={duration=function()return 120 end,validate=function()return{}end,
    complete=function()calls=calls+1;return{getFullType=function()return"medWorks.DetachedArm"end}end}
local function list(values)return{size=function()return#values end,get=function(_,i)return values[i+1]end}end
local root;local tool={getID=function()return 42 end,getFullType=function()return"Base.Saw"end,getOutermostContainer=function()return root end}
root={getItems=function()return list({tool})end,contains=function()return true end}
local square;local corpse={getObjectName=function()return"DeadBody"end,getSquare=function()return square end,getStaticMovingObjectIndex=function()return 0 end}
square={getStaticMovingObjects=function()return list({corpse})end}
getCell=function()return{getGridSquare=function()return square end}end
local player={getX=function()return 1 end,getY=function()return 1 end,getZ=function()return 0 end,getInventory=function()return root end}
local Server=require "medWorks/CorpseRecoveryServer"
local accepted=Server.handle("medWorks","recoverCorpsePart",player,{schemaVersion=1,requestId="no-start",x=1,y=1,z=0,corpseIndex=0,region="leftArm",toolId="42",toolType="Base.Saw"})
assert(not accepted and calls==0,"client completion without a server-owned timed start must never recover a part")
print("Legacy/instant completion without an authoritative timed reservation rejected")
