local medWorks={}
function medWorks.inspectProcedureRecovery()
    return{requiresInspection=true,active={{operationId="op-active",procedureId="test.surgery",status="uncertain",lockKeys={"patient","limb:left"}}}}
end
package.loaded["medWorks/init"]=medWorks
package.loaded["medWorks/ProcedureDiagnostics"]=nil
local patient={data={medWorks={completedProcedures={}}}}
function patient:getModData()return self.data end
for index=1,40 do
    patient.data.medWorks.completedProcedures[string.format("op-%02d",index)]={procedureId="test.exam",status="completed",reason=index==40 and"done\ncleanly"or nil}
end
patient.data.medWorksSeverRecovery={requiresInspection=true,regionId="leftArm",reason="uncertain output"}
local Diagnostics=dofile(arg[1])
local report=Diagnostics.snapshot(patient)
assert(report.requiresInspection and #report.active==1,"uncertain procedure must be visible")
assert(#report.completed==32 and report.completed[1].operationId=="op-09","history must be deterministically bounded")
assert(report.completed[32].reason=="done cleanly","control characters must be sanitized")
assert(report.severRecovery.regionId=="leftArm","sever quarantine must share the operator report")
local formatted=Diagnostics.format(report)
assert(formatted:find("Inspection required: YES",1,true)and formatted:find("Read%-only report"),"formatted report must state status and authority boundary")
local copy=Diagnostics.snapshot(patient);copy.completed[1].status="mutated"
assert(Diagnostics.snapshot(patient).completed[1].status=="completed","snapshots must not expose persistent state")
print("medWorks bounded operator procedure diagnostics checks passed")
