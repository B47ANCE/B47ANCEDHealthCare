local clock=1000;getTimestampMs=function()return clock end;package.loaded["medWorks/init"]={}
local Results=dofile("src/B47ANCEDHealthCare/42/media/lua/client/medWorks/CompletedExaminations.lua")
local examiner,other,patient={},{},{};local report={patient=patient,sections={{providerId="fixture",data={health=80,bad=0/0,callback=function()end}}},diagnostics={}}
assert(Results.publish(examiner,patient,report));local view=assert(Results.inspect(examiner,patient))
assert(view.patient==nil and view.sections[1].data.health==80 and view.sections[1].data.bad==nil and view.sections[1].data.callback==nil)
view.sections[1].data.health=1;assert(Results.inspect(examiner,patient).sections[1].data.health==80,"inspection must return a detached report")
assert(select(2,Results.inspect(other,patient))=="EXAMINATION_REQUIRED","another examiner must not read the result")
clock=301001;assert(select(2,Results.inspect(examiner,patient))=="EXAMINATION_REQUIRED","expired observations must fail closed")
assert(not Results.publish(examiner,patient,{}));print("test_completed_examinations.lua: PASS")
