local mortalityEvents={emit=function() end}
local Mortis={
    Authority={canWriteCanonicalState=function() return true end},
    Events=mortalityEvents,
    Anatomy={}, DetachedParts={},
}
package.loaded["Mortis/init"]=Mortis
package.loaded["medWorks/init"]=nil
local api=require "medWorks/init"

local patient={data={}}
function patient:getModData() return self.data end
function patient:transmitModData() self.transmits=(self.transmits or 0)+1 end

local executions=0
local covered=true
local mappingAvailable=true
package.loaded["Mortis/Runtime/AnatomyRuntime"]={get=function() return {speciesId="test"} end,
    getRegion=function(_,region) return {attached=true}, {},region end}
package.loaded["Mortis/Runtime/ClothingCoverage"]={region=function(_,_,region)
    if not mappingAvailable then return nil,"anatomical region has no native clothing mapping" end
    return {region=region,covered=covered,layers=covered and {{itemType="Test.Jacket"}} or {}}
end}
api.registerProcedure{id="test.exposed",requiresExposedRegion=true,
    validate=function() return true end,execute=function() executions=executions+1;return true end}
local accessContext={patient=patient,region="leftArm",replayId="access-test"}
assert(not api.beginProcedure("test.exposed",accessContext))
covered=false
local accessOk,accessToken=api.beginProcedure("test.exposed",accessContext)
assert(accessOk)
covered=true
assert(not api.completeProcedure(accessToken,accessContext),"clothing must be rechecked after timed action")
assert(executions==0)
covered=false;mappingAvailable=false
assert(not api.beginProcedure("test.exposed",{patient=patient,region="unmapped",replayId="missing-mapping"}),
    "unknown coverage must not authorize an exposed-region procedure")
mappingAvailable=true
api.registerProcedure{
    id="test.arm",
    validate=function(context) return context.ready==true,"not ready" end,
    lockKeys=function(context) return {"limb:"..context.side,"sterile-field"} end,
    execute=function(context) executions=executions+1; return context.succeed~=false,"provider rejected" end,
}

local left={patient=patient,replayId="left-1",ready=true,side="left",succeed=true}
local ok,leftToken=api.beginProcedure("test.arm",left)
assert(ok and leftToken.operationId=="left-1")
local blocked,reason=api.beginProcedure("test.arm",{
    patient=patient,replayId="right-1",ready=true,side="right",succeed=true,
})
assert(not blocked and reason=="patient resource busy: sterile-field")
assert(api.cancelProcedure(leftToken,"player moved"))

local ok2,rightToken=api.beginProcedure("test.arm",{
    patient=patient,replayId="right-2",ready=true,side="right",succeed=true,
})
assert(ok2)
-- Completion must revalidate the provider after elapsed timed-action work.
local completed,validationReason=api.completeProcedure(rightToken,{
    patient=patient,ready=false,side="right",succeed=true,
})
assert(not completed and validationReason=="not ready" and executions==0)

local successContext={patient=patient,replayId="left-2",ready=true,side="left",succeed=true}
assert(api.performProcedure("test.arm",successContext))
assert(executions==1)
assert(patient.data.medWorks.completedProcedures["left-2"].status=="completed")

local failureContext={patient=patient,replayId="left-3",ready=true,side="left",succeed=false}
assert(not api.performProcedure("test.arm",failureContext))
assert(patient.data.medWorks.completedProcedures["left-3"].status=="failed")
assert(#api.inspectProcedureRecovery(patient).active==0)

api.registerProcedure{
    id="test.uncertain",validate=function() return true end,
    execute=function() error("mutation boundary unknown") end,
}
assert(not api.performProcedure("test.uncertain",{patient=patient,replayId="uncertain-1"}))
local report=api.inspectProcedureRecovery(patient)
assert(report.requiresInspection and report.active[1].operationId=="uncertain-1")
assert(not api.resolveProcedureRecovery(patient,"uncertain-1","cancelled"))
assert(api.resolveProcedureRecovery(patient,"uncertain-1","failed"))
assert(#api.inspectProcedureRecovery(patient).active==0)
assert(not api.performProcedure("test.uncertain",{patient=patient,replayId="uncertain-1"}),
    "resolved operation remains non-replayable")

print("medWorks procedure reservation, locking, revalidation and recovery checks passed")
