package.loaded["medWorks/TestHarness"]=nil
local reportLines={}
getFileWriter=function(name,create,append)
    assert(name=="B47ANCED Health Care Test Results.txt" and create==true and append==false)
    reportLines={}; return {writeln=function(_,line) reportLines[#reportLines+1]=line end,close=function() end}
end
getGameTime=function() return {getWorldAgeHours=function() return 24 end} end
getCore=function() return {getVersionNumber=function() return "42.20.3-test" end} end
local player={modData={}}
function player:getModData() return self.modData end
getSpecificPlayer=function(index) assert(index==0); return player end

local learned=false
B47ANCEDKnowledgeAndWisdom={
    hasDocument=function(id) return id=="MW-FIELD-001" end,
    hasKnowledge=function(character,id) return character==player and id=="medWorks.CorpseRecovery" and learned end,
}
Mortis={Anatomy={},DetachedParts={}}
local medWorks={VERSION="0.8.2",sever=function() end,inspectProcedureRecovery=function() end}
medWorks.examine=function(examiner,patient)
    assert(examiner==player and patient==player)
    return {sections={{id="vanilla-human"}},diagnostics={}}
end
package.loaded["medWorks/init"]=medWorks; _G.medWorks=medWorks
package.loaded["medWorks/Knowledge"]={RECOVERY="medWorks.CorpseRecovery"}
package.loaded["medWorks/ProcedureDiagnostics"]={snapshot=function(patient) assert(patient==player); return {active={},completed={}} end}

local Harness=require "medWorks/TestHarness"
assert(Harness.start(true)==true)
local session=player.modData["medWorks.TestSession.V1"]
assert(session and session.results.startup.status=="PASS")
assert(Harness.examine()==true and session.results.examination.status=="PASS")
assert(Harness.knowledge()==false and session.results.research==nil)
learned=true
assert(Harness.knowledge()==true and session.results.research.status=="PASS")
assert(Harness.reloadStatus()==false and session.results.persistence==nil,"same runtime cannot certify reload")
package.loaded["medWorks/TestHarness"]=nil
Harness=require "medWorks/TestHarness"
assert(Harness.reloadStatus()==true and session.results.persistence.status=="PASS")
for _=1,140 do Harness.auto() end
assert(#session.commands==128,"command history must remain bounded")
assert(Harness.report()==true)
local joined=table.concat(reportLines,"\n")
assert(joined:find("Mod ID: B47ANCEDHealthCare",1,true))
assert(joined:find("Dependencies enabled for this stage: B47ANCEDKnowledgeAndWisdom, ProjectMORTIS",1,true))
print("medWorks in-game test harness/result-export checks passed")
