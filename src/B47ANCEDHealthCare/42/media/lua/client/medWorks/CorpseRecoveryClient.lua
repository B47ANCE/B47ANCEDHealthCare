local Commands=require "medWorks/Commands"
local Client={}
local counter=0
local function call(object,name)
    local ok,value=pcall(function()return object and object[name](object)end)
    return ok and value or nil
end
local function integer(value)return type(value)=="number"and value==math.floor(value)and value==value end
function Client.request(player,corpse,region,tool)
    if type(sendClientCommand)~="function"then return false,"network command unavailable"end
    local square=call(corpse,"getSquare")
    local x,y,z=call(square,"getX"),call(square,"getY"),call(square,"getZ")
    local index=call(corpse,"getStaticMovingObjectIndex")
    local itemId,itemType=call(tool,"getID"),call(tool,"getFullType")
    if not integer(x)or not integer(y)or not integer(z)or not integer(index)
        or itemId==nil or type(itemType)~="string"then return false,"recovery identity unavailable"end
    counter=(counter%1000000)+1
    local playerId=call(player,"getOnlineID")or call(player,"getPlayerNum")or 0
    local requestId="medWorks.recover:"..tostring(playerId)..":"..tostring(counter)
    local payload={schemaVersion=1,requestId=requestId,x=x,y=y,z=z,corpseIndex=index,
        region=region,toolId=tostring(itemId),toolType=itemType}
    local ok,err=pcall(sendClientCommand,player,Commands.MODULE,Commands.RECOVER_PART,payload)
    return ok,ok and requestId or err
end
function Client.receive(module,command,args)
    if module~=Commands.MODULE or command~=Commands.RECOVER_RESULT or type(args)~="table"then return end
    local message=args.ok and("Recovered "..tostring(args.itemType or"body part"))
        or("Recovery failed: "..tostring(args.reason or"unknown error"))
    pcall(print,"[medWorks] "..message)
end
if Events and Events.OnServerCommand then Events.OnServerCommand.Add(Client.receive)end
return Client
