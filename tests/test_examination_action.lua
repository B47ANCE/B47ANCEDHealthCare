unpack=unpack or table.unpack
local api={};package.loaded["medWorks/init"]=api
local examined=0;local lastContext
package.loaded["medWorks/Examination"]={examine=function(examiner,patient,context)examined=examined+1;lastContext=context;return{sections={{providerId="test",data={overallHealth=70,injuredPartCount=1,localWoundInfectionCount=1,parts={{type="LeftHand",injured=true,bleeding=true,localWoundInfection=true}}}}},diagnostics={}}end}
package.loaded["TimedActions/ISBaseTimedAction"]=true
ISBaseTimedAction={derive=function(_,name)local c={};c.__index=c;return setmetatable(c,{__index=ISBaseTimedAction})end,new=function(class,character)return setmetatable({character=character},class)end,perform=function()end}
local Report=require "medWorks/ExaminationReport"
local lines=Report.format(package.loaded["medWorks/Examination"].examine())
assert(#lines==4 and lines[4]:find("local wound infection",1,true));assert(Report.summary({sections={{data={injuredPartCount=2,localWoundInfectionCount=1}}}}):find("2 injured areas",1,true))
local Action=require "medWorks/ExaminationAction"
local dead=false;local x,y=0,0
local character={isDead=function()return dead end,getX=function()return 0 end,getY=function()return 0 end,getPlayerNum=function()return 0 end,getVehicle=function()return nil end,isDriving=function()return false end,faceThisObject=function()end,shouldBeTurning=function()return false end}
local patient={isDead=function()return false end,getX=function()return x end,getY=function()return y end,getVehicle=function()return nil end,getOnlineID=function()return 7 end}
SandboxVars={medWorks={ExaminationSeconds=1}}
local action=Action:new(character,patient);assert(action.maxTime==5 and action:isValid());assert(action:complete()and examined==2);assert(not action:complete()and examined==2)
assert(lastContext.remoteObservation==false and lastContext.bodyDamageSnapshot==nil)
x=3;assert(not Action:new(character,patient):isValid());x=0;local moved=Action:new(character,patient);x=1;assert(not moved:isValid());x=0;dead=true;assert(not Action:new(character,patient):isValid());dead=false
isClient=function()return true end;local snapshot={};patient.isLocalPlayer=function()return false end;patient.getBodyDamageRemote=function()return snapshot end
getPlayerByOnlineID=function()return patient end
local remote=Action:new(character,patient);assert(remote:isValid()and remote:complete());assert(lastContext.remoteObservation and lastContext.bodyDamageSnapshot==snapshot)
local replaced=Action:new(character,patient);getPlayerByOnlineID=function()return{}end;assert(not replaced:isValid(),"recreated remote patient must invalidate retained action")
getPlayerByOnlineID=function()return patient end;patient.getBodyDamageRemote=function()return nil end;assert(not Action:new(character,patient):complete(),"missing remote snapshot must fail closed")
isClient=function()return false end

local originalCalls,queued=0,0
ISHealthPanel={doBodyPartContextMenu=function()originalCalls=originalCalls+1 end}
package.loaded["XpSystem/ISUI/ISHealthPanel"]=true;package.loaded["TimedActions/ISTimedActionQueue"]=true
ISTimedActionQueue={add=function()queued=queued+1 end}
local option;local context={addOption=function(_,label,target,fn,... )option={label=label,target=target,fn=fn,args={...}}end,setVisible=function()end}
ISContextMenu={get=function()return context end}
local panel={character=character,otherPlayer=nil,getPatient=function()return patient end,getDoctor=function()return character end,getAbsoluteX=function()return 0 end,getAbsoluteY=function()return 0 end}
setmetatable(panel,{__index=ISHealthPanel});require "medWorks/ExaminationMenu";panel:doBodyPartContextMenu({},1,1)
assert(originalCalls==1 and option.label=="Perform examination");option.fn(option.target,unpack(option.args));assert(queued==1)
SandboxVars.medWorks.EnableExaminations=false;option=nil;panel:doBodyPartContextMenu({},1,1);assert(originalCalls==2 and option==nil)
print("medWorks timed examination and health-panel presentation checks passed")
