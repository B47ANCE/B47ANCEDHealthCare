local Commands=require "medWorks/Commands"
local Server={}
-- Deprecated v1 intent cannot prove elapsed work. Shared MWRecoverPartAction
-- now commits exclusively through Build 42's server-owned native action timer.
function Server.handle(module,command,player,args)
    if module~=Commands.MODULE or command~=Commands.RECOVER_PART then return nil,"unhandled command"end
    return false,"native timed recovery action required"
end
if Events and Events.OnClientCommand then Events.OnClientCommand.Add(Server.handle)end
return Server
