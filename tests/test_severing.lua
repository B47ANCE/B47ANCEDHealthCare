local anatomyState={speciesId="Mortis.Humanoid",speciesVersion=1,regions={leftArm={attached=true}}}
local provenance={schemaVersion=1,regionId="leftArm",classifications={}}
local emitted=false
local Mortis={
    Authority={canWriteCanonicalState=function() return true end},
    Anatomy={
        getRegion=function() return anatomyState.regions.leftArm,{severable=true},"leftArm" end,
        sever=function() anatomyState.regions.leftArm.attached=false return {regionId="leftArm"} end,
    },
    DetachedParts={
        capture=function() return provenance end,
        write=function(item,value) item.provenance=value return true end,
        read=function(item) return item.provenance end,
    },
    Events={emit=function(_,name) emitted=name=="AnatomySevered" end},
}
local realRequire=require
require=function(name) if name=="Mortis/init" then return Mortis end return realRequire(name) end
local created={}
instanceItem=function(fullType) return {fullType=fullType} end
local destination={
    AddItem=function(_,item) created[#created+1]=item; return item end,
    contains=function(_,item) for _,value in ipairs(created) do if value==item then return true end end return false end,
    Remove=function(_,item) for i,value in ipairs(created) do if value==item then table.remove(created,i) break end end end,
}
local api=dofile(arg[1])
local authority=Mortis.Authority
Mortis.Authority=nil
assert(not api.sever({},"leftArm",destination,{}))
assert(#created==0 and anatomyState.regions.leftArm.attached)
Mortis.Authority={canWriteCanonicalState=function() error("authority unavailable") end}
assert(not api.sever({},"leftArm",destination,{}))
assert(#created==0)
Mortis.Authority=authority
local item,record,result=api.sever({},"leftArm",destination,{})
assert(item and item.fullType=="medWorks.DetachedArm")
assert(record==provenance and result.regionId=="leftArm" and emitted)
assert(api.getDetachedPartProvenance(item)==provenance)
local patient={data={},getModData=function(s)return s.data end}
api.registerProcedure({id="test.clean",validate=function(context)return context.knowledge==true,"knowledge required" end,
    execute=function(context) context.executed=true return true end})
assert(api.validateProcedure("test.clean",{patient=patient,knowledge=false})==false)
local context={patient=patient,knowledge=true,replayId="action-1"}
assert(api.performProcedure("test.clean",context)==true and context.executed==true)
assert(api.performProcedure("test.clean",context)==false,"replayed procedure must be rejected")
local count=0
api.registerProcedure{id="test.reentrant",validate=function() return true end,execute=function(ctx)
    count=count+1
    assert(api.performProcedure("test.reentrant",ctx)==false)
    return true
end}
Mortis.Events.emit=function() error("listener failed") end
assert(api.performProcedure("test.reentrant",{patient=patient,replayId="reentrant"}))
assert(count==1)
api.registerProcedure{id="test.throw",validate=function() return true end,execute=function() count=count+1; error("partial mutation") end}
local failed={patient=patient,replayId="failed"}
assert(not api.performProcedure("test.throw",failed))
assert(not api.performProcedure("test.throw",failed) and count==2)
assert(patient.data.medWorks.completedProcedures.failed.status=="uncertain")
local recovery=assert(api.inspectProcedureRecovery(patient))
assert(recovery.requiresInspection==true and #recovery.active==1)
assert(api.resolveProcedureRecovery(patient,"failed","failed"))
assert(patient.data.medWorks.completedProcedures.failed.status=="failed")
patient.data.medWorks={schemaVersion=99,completedProcedures={}}
assert(not api.performProcedure("test.clean",{patient=patient,knowledge=true,replayId="future"}))
assert(patient.data.medWorks.schemaVersion==99)
print("medWorks authoritative severing/provenance checks passed")
