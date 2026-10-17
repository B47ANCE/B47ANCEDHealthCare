local clock=1000;getTimestampMs=function()return clock end;package.loaded["medWorks/init"]={}
local Results=dofile("src/B47ANCEDHealthCare/42/media/lua/client/medWorks/CompletedExaminations.lua")
local examiner,other,patient={},{},{};local report={patient=patient,sections={{providerId="fixture",data={health=80,bad=0/0,callback=function()end}}},diagnostics={}}
assert(Results.publish(examiner,patient,report));local view=assert(Results.inspect(examiner,patient))
assert(view.patient==nil and view.sections[1].data.health==80 and view.sections[1].data.bad==nil and view.sections[1].data.callback==nil)
view.sections[1].data.health=1;assert(Results.inspect(examiner,patient).sections[1].data.health==80,"inspection must return a detached report")
assert(select(2,Results.inspect(other,patient))=="EXAMINATION_REQUIRED","another examiner must not read the result")
clock=301001;assert(select(2,Results.inspect(examiner,patient))=="EXAMINATION_REQUIRED","expired observations must fail closed")
assert(not Results.publish(examiner,patient,{}));print("test_completed_examinations.lua: PASS")
clock=0;assert(Results.publish(examiner,patient,report))
clock=300001;assert(not Results.inspect(examiner,patient),"zero timestamps must still expire")
clock=5000;assert(Results.publish(examiner,patient,report));clock=4000
assert(not Results.inspect(examiner,patient),"clock rollback must invalidate observations")
clock=0/0;assert(not Results.publish(examiner,patient,report),"invalid clocks cannot create immortal cache entries")
clock=1000;assert(Results.publish(examiner,patient,report));getTimestampMs=nil
assert(not Results.inspect(examiner,patient),"loss of clock invalidates cached observations")
getTimestampMs=function()return 5000 end
local large={sections={{data={text="<IMAGE:unsafe>"..string.rep("x",100000)}}}}
assert(Results.publish(examiner,patient,large))
local text=Results.inspect(examiner,patient).sections[1].data.text
assert(#text<=180 and not text:find("[<>]"),"cached provider strings must be bounded plain text")
local wide={}
for i=1,10000 do wide[string.rep("invalid-key",10)..i]=i end
assert(Results.publish(examiner,patient,{sections={{data=wide}}}))
local bounded=assert(Results.inspect(examiner,patient))
assert(bounded.presentationLimited==true,"copy traversal limits must remain visible to report viewers")
