require "TimedActions/ISBaseTimedAction"
local Care=require "medWorks/SunburnCare"
MWSunburnCareAction=ISBaseTimedAction:derive("MWSunburnCareAction")
function MWSunburnCareAction:isValid() return Care.validate(self.character,self.item)==true end
function MWSunburnCareAction:getDuration() return Care.settings().seconds*50 end
function MWSunburnCareAction:start() self:setActionAnim("Loot");self:setAnimVariable("LootPosition","Mid") end
function MWSunburnCareAction:complete()
    if self.completed or (type(isClient)=="function" and isClient()==true) then return false end
    -- Terminal even on failure: a possibly consumed pack is never retried by an
    -- action callback. Existing procedure/recovery records retain ambiguity.
    self.completed=true
    return Care.complete(self.character,self.item)==true
end
function MWSunburnCareAction:perform() ISBaseTimedAction.perform(self) end
function MWSunburnCareAction:new(character,item)
    local o=ISBaseTimedAction.new(self,character);o.item=item;o.completed=false
    o.stopOnWalk=true;o.stopOnRun=true;o.maxTime=o:getDuration();return o
end
return MWSunburnCareAction
