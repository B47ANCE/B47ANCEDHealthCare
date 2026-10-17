local allowed=true
package.loaded["Mortis/init"]={Authority={canWriteCanonicalState=function()return allowed end},Events={emit=function()end}}
local api=require "medWorks/init"
local function patient(data)return{getModData=function()return data end,transmitModData=function()end}end
local fresh={};local observer=patient(fresh)
assert(api.inspectProcedureRecovery(observer))
assert(next(fresh)==nil,"read-only recovery inspection must not create patient state")
local malformed={medWorks={schemaVersion=1,completedProcedures={},activeProcedures="preserve",procedureLocks={}}}
assert(not api.inspectProcedureRecovery(patient(malformed)))
assert(malformed.medWorks.activeProcedures=="preserve","malformed saved state must not be reset")
local data={};local target=patient(data);local executions=0
api.registerProcedure{id="integrity.arm",validate=function()return true end,
    lockKeys=function(c)return{"limb:"..c.side}end,execute=function(c)
        executions=executions+1;assert(c.operationId=="reserved" and c.replayId=="reserved");return true end}
api.registerProcedure{id="integrity.other",validate=function()return true end,execute=function()executions=executions+100;return true end}
local context={patient=target,side="left",replayId="reserved"}
local ok,token=api.beginProcedure("integrity.arm",context);assert(ok)
token.lockKeys[1]="changed"
assert(data.medWorks.activeProcedures.reserved.lockKeys[1]=="limb:left","token must not alias saved lock keys")
local wrong={patient=target,procedureId="integrity.other",operationId="reserved"}
assert(not api.completeProcedure(wrong,context) and executions==0,"cross-procedure token must fail")
assert(not api.cancelProcedure(wrong) and data.medWorks.activeProcedures.reserved,"mismatched cancel must preserve reservation")
assert(not api.completeProcedure(token,{patient=target,side="right"}) and executions==0,"completion cannot switch reserved resources")
assert(not api.completeProcedure(token,{patient=target,side="left",operationId="other-id"}) and executions==0)
assert(api.completeProcedure(token,context) and executions==1)
assert(context.operationId==nil,"normalization must not mutate the caller's context")
local nested=false;local reentered;local count=0;local reToken
api.registerProcedure{id="integrity.reentry",validate=function(c)
    if reToken and not nested then nested=true;reentered=api.completeProcedure(reToken,c)end
    return true end,execute=function()count=count+1;return true end}
local c={patient=target,replayId="reentry"}
local begun;begun,reToken=api.beginProcedure("integrity.reentry",c);assert(begun)
assert(api.completeProcedure(reToken,c) and reentered==false and count==1,"validation reentry must execute once")
local switchPatient=false
api.registerProcedure{id="integrity.patient",validate=function(c)if switchPatient then c.patient=observer end;return true end,
    execute=function()error("changed patient must not execute")end}
local okPatient,patientToken=api.beginProcedure("integrity.patient",{patient=target,replayId="bound-patient"});assert(okPatient)
switchPatient=true
assert(not api.completeProcedure(patientToken,{patient=target})and fresh.medWorks==nil)
assert(api.cancelProcedure(patientToken),"invalid completion leaves an explicitly cancellable reservation")
local callbackToken;local reenterKeys=false;local inner
api.registerProcedure{id="integrity.keys",validate=function()return true end,lockKeys=function(c)
    if not reenterKeys then reenterKeys=true;inner=api.beginProcedure("integrity.keys",c)end
    return{"key-slot"}end,execute=function()return true end}
local outer=api.beginProcedure("integrity.keys",{patient=target,replayId="key-reentry"})
assert(inner and not outer,"lock-key callback reentry cannot overwrite an existing reservation")
allowed=false
assert(not api.beginProcedure("integrity.other",{patient=observer,replayId="client"}))
assert(next(fresh)==nil,"non-authority must not create saved state")
print("Procedure identity, lock detachment, replay binding, reentry and read-only persistence checks passed")
