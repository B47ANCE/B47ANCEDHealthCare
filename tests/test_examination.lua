local Mortis={Authority={},Events={},Anatomy={},DetachedParts={}}
package.loaded["Mortis/init"]=Mortis
package.loaded["medWorks/init"]=nil
package.loaded["medWorks/Examination"]=nil
local api=require "medWorks/Examination"

BodyPartType={ToString=function(value) return "Part-"..tostring(value) end}

local function part(index,values)
    values=values or {}
    local result={}
    function result:getIndex() return index end
    function result:getType() return values.type or index end
    function result:getHealth() return values.health or 100 end
    function result:getPain() return values.pain or 0 end
    function result:bandaged() return values.bandaged==true end
    function result:isBandageDirty() return values.bandageDirty==true end
    function result:bitten() return values.bitten==true end
    function result:scratched() return values.scratched==true end
    function result:isCut() return values.cut==true end
    function result:bleeding() return values.bleeding==true end
    function result:getBleedingTime() return values.bleedingTime or 0 end
    function result:deepWounded() return values.deepWounded==true end
    function result:getDeepWoundTime() return values.deepWoundTime or 0 end
    function result:haveGlass() return values.glass==true end
    function result:haveBullet() return values.bullet==true end
    function result:stitched() return values.stitched==true end
    function result:getStitchTime() return values.stitchTime or 0 end
    function result:isSplint() return values.splinted==true end
    function result:getSplintFactor() return values.splintFactor or 0 end
    function result:getFractureTime() return values.fractureTime or 0 end
    function result:isBurnt() return values.burnt==true end
    function result:getBurnTime() return values.burnTime or 0 end
    function result:isNeedBurnWash() return values.needsBurnWash==true end
    function result:isInfectedWound() return values.localInfection==true end
    function result:getWoundInfectionLevel() return values.localInfectionLevel or 0 end
    -- If the adapter probes this, the test must fail: Knox infection is outside
    -- this observation contract.
    function result:IsInfected() error("Knox infection must not be queried") end
    return result
end

local values={
    part(0),
    part(1,{health=72,pain=8,cut=true,bleeding=true,localInfection=true,localInfectionLevel=12}),
    part(2),part(3),part(4),
}
local list={}
function list:size() return #values end
function list:get(index) return values[index+1] end
local damage={}
function damage:getHealth() return 88 end
function damage:getBodyParts() return list end
local patient={}
function patient:getBodyDamage() return damage end

local report=assert(api.examine(nil,patient,{maxBodyParts=3}))
assert(report.schemaVersion==1 and #report.sections==1)
local human=report.sections[1].data
assert(human.kind=="vanilla-human" and human.overallHealth==88)
assert(human.availablePartCount==5 and human.observedPartCount==3 and human.truncated==true)
assert(human.injuredPartCount==1 and human.localWoundInfectionCount==1)
assert(human.parts[2].type=="Part-1" and human.parts[2].localWoundInfectionLevel==12)
assert(human.parts[2].knoxInfection==nil and human.parts[2].infected==nil)
local remoteDamage={getHealth=function()return 55 end,getBodyParts=function()return list end}
local remote=assert(api.examine(nil,patient,{maxBodyParts=1,bodyDamageSnapshot=remoteDamage}))
assert(remote.sections[1].data.overallHealth==55 and remote.sections[1].data.observedPartCount==1,
    "explicit remote observation snapshot must replace canonical patient BodyDamage")

api.registerExaminationProvider{
    id="test.Throws",owner="test",priority=50,
    supports=function() error("bad modded patient probe") end,
    examine=function() error("must not run") end,
}
api.registerExaminationProvider{
    id="test.Augment",owner="test",priority=25,
    supports=function(_,candidate) return candidate==patient end,
    examine=function() return {kind="test-observation",value=7} end,
}
local augmented=assert(api.examine({},patient,{maxBodyParts=9999}))
assert(#augmented.sections==2 and augmented.sections[1].providerId=="test.Augment")
assert(#augmented.diagnostics==1 and augmented.diagnostics[1].providerId=="test.Throws")
assert(augmented.sections[2].data.observedPartCount==5,
    "hard cap permits this five-part fixture but rejects unbounded caller limits")

local unsupported,reason,diagnostics=api.examine(nil,{})
assert(unsupported==nil and reason=="no examination provider" and #diagnostics.sections==0
    and #diagnostics.diagnostics==1,"unsupported patients fail closed while preserving diagnostics")

print("medWorks bounded examination and infection-separation checks passed")
