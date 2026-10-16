local patientData={lightWorksSunburn={schemaVersion=1,dose=.8,severity=.7,processedOperations={}}}
local patient={getModData=function()return patientData end,transmitModData=function(self)self.sent=(self.sent or 0)+1 end}
local Mortis={Authority={canWriteCanonicalState=function()return true end},Events={emit=function()end}}
package.loaded["Mortis/init"]=Mortis
local lightWorks={Config={SunburnFirstDegreeDoseHours=.75,SunburnMaximumDoseHours=4}}
package.loaded["lightWorks/lightWorks_API"]=lightWorks
package.loaded["lightWorks/lightWorks_UV"]={getSunlightExposure=function()return{uv={uvb=0}}end}
package.loaded["medWorks/init"]=nil;medWorks=nil
local med=dofile(arg[1]);package.loaded["medWorks/init"]=med
local Sunburn=dofile(arg[2]);package.loaded["lightWorks/lightWorks_Sunburn"]=Sunburn
local integration=dofile(arg[3]);assert(integration.ID=="medWorks.treatSunburn" and integration.available)
assert(not med.performProcedure(integration.ID,{patient=patient,amount=.2,operationId="bad-source"}))
local ok,result=med.performProcedure(integration.ID,{patient=patient,amount=.2,operationId="treat-1",treatmentSource="medWorks.test.topical"})
local treated=Sunburn.getState(patient)
assert(ok and result==true and treated.severity<.7 and math.abs(patientData.lightWorksSunburn.dose-.6)<.0001)
assert(not med.performProcedure(integration.ID,{patient=patient,amount=.2,operationId="treat-1",treatmentSource="medWorks.test.topical"}),"replay must fail")
assert(not med.performProcedure(integration.ID,{patient=patient,amount=.9,operationId="treat-2",treatmentSource="medWorks.test.topical"}),"unbounded dose must fail")
isClient=function()return true end;isServer=function()return false end
assert(not med.performProcedure(integration.ID,{patient=patient,amount=.1,operationId="client",treatmentSource="medWorks.test.topical"}))
print("medWorks authoritative lightWorks sunburn-treatment integration checks passed")
