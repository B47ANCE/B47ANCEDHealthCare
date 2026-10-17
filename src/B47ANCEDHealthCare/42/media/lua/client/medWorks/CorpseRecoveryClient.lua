local Client={}
-- Retained module/function identity for callers; never supplies an alternate
-- gameplay commit path around the native shared timed action.
function Client.request(player,corpse,region,tool)
    return false,"queue MWRecoverPartAction through ISTimedActionQueue"
end
return Client
