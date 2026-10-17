-- Independently authored interface fixtures; never load the external mod.
package.loaded["medWorks/init"] = {}
local medWorks = require "medWorks/Examination"
local active, server, client = {}, false, false
local players, counters = {}, {imports=0,queries=0}
local names = {"Hand_L","ForeArm_L","UpperArm_L","Hand_R","ForeArm_R","UpperArm_R",
    "Foot_L","LowerLeg_L","UpperLeg_L","Foot_R","LowerLeg_R","UpperLeg_R"}
local function person(index, username)
    return {getPlayerNum=function() return index end, getUsername=function() return username end,
        isLocalPlayer=function(self) return players[index]==self end,
        isDead=function() return false end, getX=function() return 5 end, getY=function() return 5 end,
        isDriving=function() return false end}
end
local patient = person(0,"local-user")
players[0] = patient
isServer=function() return server end
isClient=function() return client end
getSpecificPlayer=function(index) return players[index] end
getActivatedMods=function() return {contains=function(_,id) return active[id]==true end} end
ModData=setmetatable({}, {__index=function() error("no ModData access") end})
sendClientCommand=function() error("no outgoing RPC") end
sendServerCommand=sendClientCommand
local flags, dc = {}, nil
local external = {version="3.2.0"}
external.isCut=function(_, name) counters.queries=counters.queries+1; return flags[name].loss end
external.hasPart=function(_, name) counters.queries=counters.queries+1; return flags[name].available end
external.getMobility=function() error("mobility query prohibited") end
local controller={GetReady=function(username) assert(username==patient:getUsername()); return dc end}
local realRequire=require
require=function(name)
    if name=="TOC/API" then counters.imports=counters.imports+1; return external end
    if name=="TOC/Controllers/DataController" then counters.imports=counters.imports+1; return controller end
    if name:sub(1,4)=="TOC/" then error("unexpected external import") end
    return realRequire(name)
end
local Observation=require "medWorks/OnlyCureObservation"
assert(#medWorks.ExaminationProviders==2)
dofile("src/B47ANCEDHealthCare/42/media/lua/client/medWorks/OnlyCureObservation.lua")
assert(#medWorks.ExaminationProviders==2,"repeat load must not register twice")
local function status(expected)
    local value=Observation.capture(patient,patient)
    assert(value.status==expected, tostring(value.status).." ~= "..expected)
    assert(#value.parts==0 or expected=="ready","no partial facts after failure")
    return value
end
status("inactive"); assert(counters.imports==0)
active.TheOnlyCurePlus=true
server=true; status("not-local-self"); assert(counters.imports==0)
server=false
assert(Observation.capture(patient,person(0,"remote-user")).status=="not-local-self")
local impostor=person(0,"local-user")
assert(Observation.capture(impostor,impostor).status=="not-local-self")
assert(counters.imports==0,"remote/impostor identities must not import upstream modules")
active.TheOnlyCure=true;status("conflicting-mod");assert(counters.imports==0);active.TheOnlyCure=nil
external.version="3.3.0";status("unsupported-version");assert(counters.queries==0)
external.version="3.2.0";status("not-ready");assert(counters.queries==0)
local oldActivation=getActivatedMods
getActivatedMods=function() error("metadata failure") end
status("detection-unavailable");getActivatedMods=oldActivation
local oldCut=external.isCut
external.isCut=nil;status("interface-unavailable");external.isCut=oldCut
local function reset()
    dc={username=patient:getUsername(),isDataReady=true,tocData={limbs={},prostheses={}}}
    for _,name in ipairs(names)do dc.tocData.limbs[name]={isCut=false};flags[name]={loss=false,available=true}end
    for _,name in ipairs({"Top_L","Top_R","Bottom_L","Bottom_R"})do dc.tocData.prostheses[name]={isProstEquipped=false}end
end
reset()
assert(Observation.getCapabilities(patient,patient).canObserve)
flags.Hand_L={loss=true,available=true};dc.tocData.limbs.Hand_L.isCut=true
dc.tocData.prostheses.Top_L.isProstEquipped=true
flags.Foot_R={loss=true,available=false};dc.tocData.limbs.Foot_R.isCut=true
local observed=status("ready")
assert(#observed.parts==12 and observed.parts[1].lossReported and observed.parts[1].supportReported)
assert(observed.parts[10].lossReported and not observed.parts[10].supportReported)
observed.parts[1].lossReported=false
assert(dc.tocData.limbs.Hand_L.isCut==true,"returned report must not alias upstream data")
local report=assert(medWorks.examine(patient,patient))
assert(#report.sections==1 and report.sections[1].data.kind=="only-cure-self")
local _,_,remote=medWorks.examine(patient,person(1,"other"))
assert(remote and #remote.sections==0,"remote provider must not participate")
local _,_,context=medWorks.examine(patient,patient,{remoteObservation=true})
assert(context and #context.sections==0)
dc.tocData.limbs.Hand_L=nil;status("invalid-data")
reset();dc.tocData.prostheses.Top_R=nil;status("invalid-data")
reset();dc.tocData.limbs.Hand_L.isCut="false";status("invalid-data")
reset();dc.username="other-user";status("invalid-data")
reset();flags.Hand_L.loss=nil;status("invalid-data")
reset();flags.Hand_L.available=false;status("invalid-data")
reset()
local originalCut=external.isCut
external.isCut=function() error("foreign failure detail must not leak") end
status("query-failed");external.isCut=originalCut
local originalPart=external.hasPart
external.hasPart=function(p,name) dc.isDataReady=false;return originalPart(p,name) end
status("not-ready");external.hasPart=originalPart
reset()
external.hasPart=function(p,name) players[0]=nil;return originalPart(p,name) end
status("not-ready");external.hasPart=originalPart;players[0]=patient
reset()
external.hasPart=function(p,name) active.TheOnlyCurePlus=nil;return originalPart(p,name) end
status("not-ready");external.hasPart=originalPart;active.TheOnlyCurePlus=true
reset()
local beforeGetReady=controller.GetReady
controller.GetReady=function() error("readiness failure") end
status("query-failed");controller.GetReady=beforeGetReady
-- A second local player uses its exact player slot, not getPlayer()/slot zero.
patient=person(1,"split-user");players[1]=patient;reset();client=true
assert(status("ready").scope=="local-self")
local capability=Observation.getCapabilities(patient,patient)
capability.status="corrupted"
assert(Observation.getCapabilities(patient,patient).status=="ready")
-- Exercise the actual timed completion -> provider -> formatter -> cache path.
local base={}
function base:derive()
    local class={};class.__index=class;return setmetatable(class,{__index=self})
end
function base:new(character) return setmetatable({character=character},{__index=self}) end
function base:perform() counters.completed=(counters.completed or 0)+1 end
ISBaseTimedAction=base
package.preload["TimedActions/ISBaseTimedAction"]=function() return base end
getTimestampMs=function() return 1234 end
local Action=require "medWorks/ExaminationAction"
local Cache=require "medWorks/CompletedExaminations"
local Report=require "medWorks/ExaminationReport"
flags.Hand_L={loss=true,available=false};dc.tocData.limbs.Hand_L.isCut=true
local action=Action:new(patient,patient)
local oldPrint=print;print=function()end
action:perform()
print=oldPrint
assert(counters.completed==1)
local saved=assert(Cache.inspect(patient,patient))
assert(table.concat(Report.format(saved)," "):find("loss reported; no prosthetic support",1,true))
local queries=counters.queries
assert(action:finishObservation()==false and counters.queries==queries,"repeated finish cannot re-observe")
-- Rendering historical results never touches external getters.
external.isCut=function() error("historical report must not query upstream") end
assert(pcall(Report.format,saved))
print("Only Cure+ independent capability, self-only, readiness, purity and failure fixtures passed")
