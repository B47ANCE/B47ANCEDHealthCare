local Commands=require "medWorks/Commands"
local Recovery=require "medWorks/CorpseRecovery"
local Server={MAX_OBJECTS=128,MAX_ITEMS=512,MAX_CACHE=64,MAX_REQUESTS_PER_TICK=2}
local caches=setmetatable({},{__mode="k"})
local allowances=setmetatable({},{__mode="k"})
local function call(object,name,...)
    local ok,fn=pcall(function()return object and object[name]end)
    if not ok or type(fn)~="function"then return nil,false end
    local called,value=pcall(fn,object,...);return called and value or nil,called
end
local function validString(value,maximum)
    return type(value)=="string"and value~=""and#value<=maximum and not value:find("[%c]")
end
local function integer(value)return type(value)=="number"and value==math.floor(value)and value==value end
local function closeEnough(player,x,y,z)
    local px,py,pz=tonumber((call(player,"getX"))),tonumber((call(player,"getY"))),tonumber((call(player,"getZ")))
    return px and py and pz and math.abs(pz-z)<.01 and(px-x)^2+(py-y)^2<=4
end
local function resolveCorpse(player,args)
    if not integer(args.x)or not integer(args.y)or not integer(args.z)or math.abs(args.x)>10000000
        or math.abs(args.y)>10000000 or args.z<0 or args.z>64 or not integer(args.corpseIndex)
        or args.corpseIndex<0 or args.corpseIndex>=Server.MAX_OBJECTS then return nil,"invalid corpse identity"end
    if not closeEnough(player,args.x,args.y,args.z)then return nil,"corpse is out of reach"end
    local cell=type(getCell)=="function"and getCell()or nil
    local square=call(cell,"getGridSquare",args.x,args.y,args.z);if not square then return nil,"corpse square is not loaded"end
    local list=call(square,"getStaticMovingObjects");local size=tonumber((call(list,"size")))or 0
    if args.corpseIndex>=math.min(size,Server.MAX_OBJECTS)then return nil,"corpse is no longer available"end
    local corpse=call(list,"get",args.corpseIndex)
    if call(corpse,"getObjectName")~="DeadBody"or call(corpse,"getSquare")~=square
        or call(corpse,"getStaticMovingObjectIndex")~=args.corpseIndex then return nil,"corpse identity changed"end
    return corpse
end
local function resolveTool(player,args)
    if not validString(args.toolId,Commands.MAX_ITEM_ID)or not validString(args.toolType,128)then return nil,"invalid tool identity"end
    local root=call(player,"getInventory");if not root then return nil,"player inventory unavailable"end
    local queue={root};local cursor,seen=1,0
    while cursor<=#queue and seen<Server.MAX_ITEMS do
        local container=queue[cursor];cursor=cursor+1;local items=call(container,"getItems")
        local size=math.min(tonumber((call(items,"size")))or 0,Server.MAX_ITEMS-seen)
        for index=0,size-1 do
            local item=call(items,"get",index);seen=seen+1
            if item and tostring(call(item,"getID"))==args.toolId and call(item,"getFullType")==args.toolType
                and call(item,"getOutermostContainer")==root and call(container,"contains",item)==true then return item end
            local nested=call(item,"getInventory");if nested then queue[#queue+1]=nested end
        end
    end
    return nil,"owned recovery tool not found"
end
local function cacheFor(player)local c=caches[player];if not c then c={map={},order={}};caches[player]=c end;return c end
local function reply(player,payload)if type(sendServerCommand)=="function"then pcall(sendServerCommand,player,Commands.MODULE,Commands.RECOVER_RESULT,payload)end end
local function remember(player,id,payload)local c=cacheFor(player);c.map[id]=payload;c.order[#c.order+1]=id;while#c.order>Server.MAX_CACHE do c.map[table.remove(c.order,1)]=nil end end
local function outcome(id,ok,value)return{schemaVersion=1,requestId=id,ok=ok==true,
    reason=ok and nil or tostring(value or"recovery failed"):sub(1,160),itemType=ok and tostring(call(value,"getFullType")or""):sub(1,128)or nil}end
function Server.handle(module,command,player,args)
    if module~=Commands.MODULE or command~=Commands.RECOVER_PART then return nil,"unhandled command"end
    if not player or type(args)~="table"or args.schemaVersion~=1 or not validString(args.requestId,Commands.MAX_REQUEST_ID)
        or type(args.region)~="string"or#args.region>32 then return false,"invalid recovery request"end
    local cache=cacheFor(player);if cache.map[args.requestId]then local prior=cache.map[args.requestId];reply(player,prior);return prior.ok,prior end
    local left=allowances[player];if left==nil then left=Server.MAX_REQUESTS_PER_TICK end
    if left<=0 then local result=outcome(args.requestId,false,"rate limited");remember(player,args.requestId,result);reply(player,result);return false,result end
    allowances[player]=left-1
    local corpse,err=resolveCorpse(player,args);local tool
    if corpse then tool,err=resolveTool(player,args)end
    local item;if tool then item,err=Recovery.complete(player,corpse,args.region,tool)end
    local result=outcome(args.requestId,item~=nil,item or err);remember(player,args.requestId,result);reply(player,result)
    return result.ok,result
end
function Server.refill()allowances=setmetatable({},{__mode="k"})end
local function onCommand(...)local ok,err=pcall(Server.handle,...);if not ok then pcall(print,"[medWorks] Corpse recovery command failed safely: "..tostring(err))end end
if Events and Events.OnClientCommand then Events.OnClientCommand.Add(onCommand)end
if Events and Events.OnTick then Events.OnTick.Add(Server.refill)end
return Server
