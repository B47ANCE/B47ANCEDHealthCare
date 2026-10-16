local sent
sendClientCommand=function(player,module,command,args)sent={player,module,command,args}end
local event;Events={OnServerCommand={Add=function(fn)event=fn end}}
local square={getX=function()return 5 end,getY=function()return 6 end,getZ=function()return 0 end}
local corpse={getSquare=function()return square end,getStaticMovingObjectIndex=function()return 2 end}
local tool={getID=function()return 42 end,getFullType=function()return"Base.Saw"end}
local player={getOnlineID=function()return 7 end}
local Client=require"medWorks/CorpseRecoveryClient"
local ok,id=Client.request(player,corpse,"leftArm",tool)
assert(ok and id==sent[4].requestId and sent[2]=="medWorks"and sent[3]=="recoverCorpsePart")
assert(sent[4].x==5 and sent[4].corpseIndex==2 and sent[4].toolId=="42"and sent[4].region=="leftArm")
corpse.getStaticMovingObjectIndex=function()return nil end
assert(not Client.request(player,corpse,"leftArm",tool))
event("medWorks","recoverCorpsePartResult",{ok=false,reason="test"})
print("medWorks corpse-recovery client identity checks passed")
