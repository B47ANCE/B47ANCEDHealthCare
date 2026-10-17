package.loaded["medWorks/init"]={}
local Report=require "medWorks/ExaminationReport"
local Cache=require "medWorks/CompletedExaminations"
local names={"Hand_L","ForeArm_L","UpperArm_L","Hand_R","ForeArm_R","UpperArm_R",
    "Foot_L","LowerLeg_L","UpperLeg_L","Foot_R","LowerLeg_R","UpperLeg_R"}
local data={kind="only-cure-self",schemaVersion=1,scope="local-self",status="ready",parts={}}
for _,name in ipairs(names)do data.parts[#data.parts+1]={type=name,lossReported=false,supportReported=false}end
data.parts[1].lossReported=true;data.parts[1].supportReported=true
local report={schemaVersion=1,sections={{providerId="medWorks.OnlyCureSelf",data=data},
    {data={overallHealth=100,injuredPartCount=0,parts={}}}}}
local text=table.concat(Report.format(report),"\n")
assert(text:find("Left hand: loss and prosthetic support reported",1,true))
assert(text:find("describe separate systems",1,true))
assert(not Report.summary(report):find("no observable injuries",1,true),"clean native fields cannot imply healthy anatomy")
local examiner,patient={},{}
getTimestampMs=function() return 1000 end
assert(Cache.publish(examiner,patient,report))
data.parts[1].lossReported=false
local cached=assert(Cache.inspect(examiner,patient))
assert(cached.sections[1].data.parts[1].lossReported,"historical structural observation survives bounded cache copy")
assert(table.concat(Report.format(cached)," "):find("prosthetic support reported",1,true))
data.parts[1].supportReported=false
data.parts[2].type="<IMAGE:bad>"
local invalid=table.concat(Report.format(report)," ")
assert(invalid:find("no limb status inferred",1,true)and not invalid:find("<",1,true))
data.status="not-ready"
assert(table.concat(Report.format(report)," "):find("not ready",1,true))
data.status={};assert(pcall(Report.format,report))
getText=function(key) if key=="UI_medWorks_Report_OnlyCureNotReady"then return "Localized not-ready state"end;return key end
data.status="not-ready"
assert(table.concat(Report.format(report)," "):find("Localized not-ready state",1,true))
print("Only Cure+ bounded/localized report, unknown semantics and historical cache checks passed")
