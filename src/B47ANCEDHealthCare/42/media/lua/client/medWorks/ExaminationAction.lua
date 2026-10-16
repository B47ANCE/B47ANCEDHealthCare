require "TimedActions/ISBaseTimedAction"
local medWorks=require "medWorks/Examination"
local Report=require "medWorks/ExaminationReport"
local Completed=require "medWorks/CompletedExaminations"
MWExaminationAction=ISBaseTimedAction:derive("MWExaminationAction")
local function alive(character)return character and not(type(character.isDead)=="function"and character:isDead())end
local function driving(character)return type(character.isDriving)=="function"and character:isDriving()end
local function sameVehicle(a,b)return not driving(a)and type(a.getVehicle)=="function"and a:getVehicle()~=nil and a:getVehicle()==b:getVehicle()end
local function clientRuntime()return type(isClient)=="function"and isClient()==true end
local function onlineId(character)
    if not character or type(character.getOnlineID)~="function"then return nil end
    local ok,value=pcall(character.getOnlineID,character);return ok and value or nil
end
local function remoteSnapshot(patient)
    if not clientRuntime()then return nil,false end
    if type(patient.isLocalPlayer)=="function"and patient:isLocalPlayer()then return nil,false end
    if type(patient.getBodyDamageRemote)~="function"then return nil,true end
    local ok,value=pcall(patient.getBodyDamageRemote,patient);return ok and value or nil,true
end
function MWExaminationAction:isValid()
    if not alive(self.character)or not alive(self.patient)then return false end
    if self.patientOnlineId~=nil and clientRuntime()and type(getPlayerByOnlineID)=="function"
        and getPlayerByOnlineID(self.patientOnlineId)~=self.patient then return false end
    if self.character==self.patient then return not driving(self.character)end
    if sameVehicle(self.character,self.patient)then return true end
    local dx=math.abs(self.character:getX()-self.patient:getX());local dy=math.abs(self.character:getY()-self.patient:getY())
    return dx<=2 and dy<=2 and self.patient:getX()==self.patientX and self.patient:getY()==self.patientY
end
function MWExaminationAction:waitToStart()if self.character==self.patient then return false end;self.character:faceThisObject(self.patient);return self.character:shouldBeTurning()end
function MWExaminationAction:start()self:setActionAnim("Loot");self:setAnimVariable("LootPosition","Mid")end
function MWExaminationAction:update()if self.character~=self.patient then self.character:faceThisObject(self.patient)end end
function MWExaminationAction:getDuration()local vars=rawget(_G,"SandboxVars");local value=vars and vars.medWorks and tonumber(vars.medWorks.ExaminationSeconds)or 30;return math.max(5,math.min(600,value))*50 end
-- Local read-only observation: defining complete would request server execution.
function MWExaminationAction:finishObservation()
    if self.completed then return false end;self.completed=true;if not self:isValid()then return false end
    local snapshot,isRemote=remoteSnapshot(self.patient)
    if isRemote and not snapshot then if print then print("[medWorks] Examination failed: remote body-damage snapshot unavailable")end;return false end
    local report,reason=medWorks.examine(self.character,self.patient,{bodyDamageSnapshot=snapshot,remoteObservation=isRemote})
    if not report then if print then print("[medWorks] Examination failed: "..tostring(reason))end;return false end
    for _,line in ipairs(Report.format(report))do if print then print("[medWorks] "..line)end end
    local summary=Report.summary(report);if HaloTextHelper and HaloTextHelper.addText then pcall(HaloTextHelper.addText,self.character,summary,HaloTextHelper.getColorGreen and HaloTextHelper.getColorGreen()or nil)end
    Completed.publish(self.character,self.patient,report)
    self.result=report;self.summary=summary;return true
end
function MWExaminationAction:perform()
    self:finishObservation()
    ISBaseTimedAction.perform(self)
end
function MWExaminationAction:new(character,patient)local o=ISBaseTimedAction.new(self,character);o.patient=patient;o.patientX=patient:getX();o.patientY=patient:getY();o.patientOnlineId=onlineId(patient);o.stopOnWalk=true;o.stopOnRun=true;o.maxTime=o:getDuration();o.completed=false;return o end
return MWExaminationAction
