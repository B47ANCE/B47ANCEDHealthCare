require "TimedActions/ISBaseTimedAction"
local Recovery=require "medWorks/CorpseRecovery"
MWRecoverPartAction=ISBaseTimedAction:derive("MWRecoverPartAction")
function MWRecoverPartAction:isValid()
    return Recovery.validate(self.character,self.corpse,self.region,self.tool)~=nil
end
function MWRecoverPartAction:waitToStart()
    self.character:faceThisObject(self.corpse)
    return self.character:shouldBeTurning()
end
function MWRecoverPartAction:start()
    self:setActionAnim("Loot")
    self:setAnimVariable("LootPosition","Low")
end
function MWRecoverPartAction:update() self.character:faceThisObject(self.corpse) end
-- Native action units are 20 ms; server sandbox values are seconds.
function MWRecoverPartAction:getDuration() return Recovery.duration()*50 end
function MWRecoverPartAction:complete()
    if self.completed then return false end
    local client=false
    if type(rawget(_G,"isClient"))=="function"then local ok,value=pcall(isClient);client=ok and value==true end
    if client then
        -- Build 42 dispatches complete on the server for this shared action.
        -- A client callback must never submit a second mutation path.
        return false
    end
    local item=Recovery.complete(self.character,self.corpse,self.region,self.tool)
    if item~=nil then self.completed=true end
    return item~=nil
end
function MWRecoverPartAction:perform() ISBaseTimedAction.perform(self) end
function MWRecoverPartAction:new(character,corpse,region,tool)
    local object=ISBaseTimedAction.new(self,character)
    object.corpse=corpse; object.region=region; object.tool=tool
    object.stopOnWalk=true; object.stopOnRun=true
    object.maxTime=object:getDuration()
    object.completed=false
    return object
end
return MWRecoverPartAction
