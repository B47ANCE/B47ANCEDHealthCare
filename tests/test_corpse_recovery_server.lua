local completed=0
package.loaded["medWorks/CorpseRecovery"]={complete=function(player,corpse,region,tool)
    completed=completed+1;assert(region=="leftArm");return{getFullType=function()return"medWorks.DetachedArm"end}
end}
local function list(values)return{size=function()return#values end,get=function(_,i)return values[i+1]end}end
local root
local tool={getID=function()return 91 end,getFullType=function()return"Base.Saw"end,
    getOutermostContainer=function()return root end}
local bagItems=list({tool});local bag={contains=function(_,item)return item==tool end,getItems=function()return bagItems end}
local bagItem={getInventory=function()return bag end,getID=function()return 10 end,getFullType=function()return"Base.Bag"end}
root={contains=function()return false end,getItems=function()return list({bagItem})end}
local square
local corpse={getObjectName=function()return"DeadBody"end,getSquare=function()return square end,
    getStaticMovingObjectIndex=function()return 0 end}
square={getStaticMovingObjects=function()return list({corpse})end}
local cell={getGridSquare=function(_,x,y,z)if x==100 and y==200 and z==0 then return square end end}
getCell=function()return cell end
local player={getX=function()return 100 end,getY=function()return 200 end,getZ=function()return 0 end,getInventory=function()return root end}
local replies={};sendServerCommand=function(target,module,command,args)replies[#replies+1]={target,module,command,args}end
Events={OnClientCommand={Add=function()end},OnTick={Add=function()end}}
local Server=require"medWorks/CorpseRecoveryServer"
local args={schemaVersion=1,requestId="r1",x=100,y=200,z=0,corpseIndex=0,region="leftArm",toolId="91",toolType="Base.Saw"}
local ok,result=Server.handle("medWorks","recoverCorpsePart",player,args)
assert(ok and result.itemType=="medWorks.DetachedArm"and completed==1 and#replies==1)
ok=Server.handle("medWorks","recoverCorpsePart",player,args)
assert(ok and completed==1 and#replies==2,"replay must return cached result without a second mutation")
local stale={schemaVersion=1,requestId="r2",x=100,y=200,z=0,corpseIndex=1,region="leftArm",toolId="91",toolType="Base.Saw"}
assert(not Server.handle("medWorks","recoverCorpsePart",player,stale)and completed==1)
local remote={schemaVersion=1,requestId="r3",x=110,y=200,z=0,corpseIndex=0,region="leftArm",toolId="91",toolType="Base.Saw"}
assert(not Server.handle("medWorks","recoverCorpsePart",player,remote)and completed==1)
Server.refill();tool.getOutermostContainer=function()return{}end
local stolen={schemaVersion=1,requestId="r4",x=100,y=200,z=0,corpseIndex=0,region="leftArm",toolId="91",toolType="Base.Saw"}
assert(not Server.handle("medWorks","recoverCorpsePart",player,stolen)and completed==1)
print("medWorks authoritative corpse-recovery transport checks passed")
