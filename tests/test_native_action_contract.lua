local mutations=0;local client=true;local localCompletions=0
isClient=function()return client end
package.loaded["medWorks/CorpseRecovery"]={duration=function()return 120 end,validate=function()return{}end,
    complete=function()mutations=mutations+1;return{}end}
package.loaded["TimedActions/ISBaseTimedAction"]=true
ISBaseTimedAction={derive=function(_,name)local c={};c.__index=c;return setmetatable(c,{__index=ISBaseTimedAction})end,
    new=function(class,character)return setmetatable({character=character},class)end,perform=function()localCompletions=localCompletions+1 end}
local RecoveryAction=require "medWorks/RecoverPartAction"
assert(type(rawget(RecoveryAction,"complete"))=="function","shared native server action must have a completion callback")
local action=RecoveryAction:new({}, {}, "leftArm", {})
assert(action.maxTime==120*50,"seconds must convert to native 20ms units")
assert(not action:complete()and mutations==0,"a client callback cannot mutate or send a commit command")
client=false;assert(action:complete()and mutations==1);assert(not action:complete()and mutations==1)
package.loaded["medWorks/Examination"]={examine=function()return{sections={{data={}}}}end}
package.loaded["medWorks/ExaminationReport"]={format=function()return{}end,summary=function()return"observed"end}
local published=0;package.loaded["medWorks/CompletedExaminations"]={publish=function()published=published+1 end}
local Examination=require "medWorks/ExaminationAction"
assert(rawget(Examination,"complete")==nil,"client-only examination must not select native server dispatch")
local character={isDead=function()return false end,getX=function()return 0 end,getY=function()return 0 end}
local observation=Examination:new(character,character)
assert(observation.maxTime==30*50)
observation:perform();observation:perform()
assert(published==1 and localCompletions==2,"local perform publishes the read-only observation once")
print("Native server action selection, seconds conversion, server-only commit and local examination dispatch checks passed")
