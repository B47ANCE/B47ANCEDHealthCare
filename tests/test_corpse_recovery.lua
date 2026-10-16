unpack=unpack or table.unpack
package.loaded["medWorks/Knowledge"]={canRecover=function() return true end}
local semanticDefinition
local semanticReports={}
package.loaded["B47ANCEDKnowledgeAndWisdom/Progression"]={
    hasSemanticAction=function() return semanticDefinition~=nil end,
    registerSemanticAction=function(definition) semanticDefinition=definition end,
    processSemanticAction=function(character,id,report,context)
        semanticReports[#semanticReports+1]={character=character,id=id,report=report,context=context}; return true,{}
    end,
}
local severed=0
local attached=true
local provenance=true
local authority=true
local covered=false
local api={PART_TYPES={leftArm="medWorks.DetachedArm"},sever=function()
    if not authority then return nil,"non-authority" end
    severed=severed+1; attached=false; return {}
end}
api.getRegionAccess=function() return {accessible=not covered} end
package.loaded["medWorks/init"]=api
package.loaded["Mortis/init"]={Anatomy={getRegion=function() return {attached=attached},{severable=true} end},
    DetachedParts={captureCorpse=function() return provenance and {} or nil end}}
local Recovery=require "medWorks/CorpseRecovery"
local inventory={}
local carried=true
local bag={contains=function() return carried end}
local kind="Base.Saw"
local condition=10
local tool={getOutermostContainer=function() return inventory end,getContainer=function() return bag end,
    getFullType=function() return kind end,getCondition=function() return condition end}
local dead=false
local reachable=true
local square={canReachTo=function() return reachable end}
local character={isDead=function() return dead end,getSquare=function() return square end,
    getInventory=function() return inventory end,faceThisObject=function() end,shouldBeTurning=function() return false end}
local distance=1
local index=0
local corpse={getObjectName=function() return "DeadBody" end,getSquare=function() return square end,
    getStaticMovingObjectIndex=function() return index end,DistToSquared=function() return distance end}
local function valid() return Recovery.validate(character,corpse,"leftArm",tool) end
assert(valid()==inventory,"nested carried tool should work")
covered=true;assert(not valid(),"covered region must reject recovery");covered=false
dead=true; assert(not valid()); dead=false
reachable=false; assert(not valid()); reachable=true
distance=5; assert(not valid()); distance=1
index=-1; assert(not valid()); index=0
carried=false; assert(not valid()); carried=true
condition=0; assert(not valid()); condition=10
kind="Base.KitchenKnife"; assert(not valid()); kind="Base.Saw"
provenance=false; assert(not valid()); provenance=true
attached=false; assert(not valid()); attached=true
SandboxVars={medWorks={EnableCorpseRecovery=false}}; assert(not valid())
SandboxVars.medWorks.EnableCorpseRecovery=true
SandboxVars.medWorks.CorpseRecoverySeconds=1; assert(Recovery.duration()==10)
SandboxVars.medWorks.CorpseRecoverySeconds=9999; assert(Recovery.duration()==3600)
SandboxVars.medWorks.CorpseRecoverySeconds=120

package.loaded["TimedActions/ISBaseTimedAction"]=true
ISBaseTimedAction={derive=function(_,name)
    local class={}; class.__index=class; return setmetatable(class,{__index=ISBaseTimedAction})
end,new=function(class,player) return setmetatable({character=player},class) end,perform=function() end}
local Action=require "medWorks/RecoverPartAction"
local action=Action:new(character,corpse,"leftArm",tool)
assert(action.maxTime==120 and action.stopOnWalk and action.stopOnRun and action:isValid())
covered=true;assert(not action:complete() and severed==0,
    "clothing added during the timed action must block completion");covered=false
carried=false; assert(not action:complete() and severed==0); carried=true
authority=false; assert(not action:complete() and severed==0); authority=true
assert(action:complete() and severed==1)
assert(semanticDefinition.id=="medWorks.CorpseRecovery" and semanticDefinition.skills.Doctor==1)
assert(#semanticReports==1 and semanticReports[1].report.committed and semanticReports[1].report.sourceCategory=="corpse-anatomy")
assert(not action:complete() and severed==1,"completed/overlapping recovery cannot repeat")
assert(#semanticReports==1,"failed repeat must not award semantic XP")
-- Native network resolution can lose any constructor argument between queue
-- submission and server reconstruction. These must fail without a mutation.
attached=true
assert(Action:new(character,corpse,"leftArm",tool):isValid())
for _,missing in ipairs({"character","corpse","tool"}) do
    local args={character=character,corpse=corpse,tool=tool}
    args[missing]=nil
    local reconstructed=Action:new(args.character,args.corpse,"leftArm",args.tool)
    assert(not reconstructed:isValid() and not reconstructed:complete())
end
assert(severed==1)

local callback
Events={OnFillWorldObjectContextMenu={Add=function(fn) callback=fn end}}
package.loaded["TimedActions/ISTimedActionQueue"]=true
local queued=0
ISTimedActionQueue={add=function() queued=queued+1 end}
getSpecificPlayer=function() return character end
ISWorldObjectContextMenu={fetchVars={body=corpse}}
inventory.getFirstEvalRecurse=function(_,predicate) return predicate(tool) and tool end
local options={}
local context={addOption=function(_,label,target,fn,...)
    local option={label=label,target=target,fn=fn,args={...}}; options[#options+1]=option; return option
end,addSubMenu=function() end}
ISContextMenu={getNew=function() return context end}
getText=function(key)
    local values={ContextMenu_medWorks_RecoverBodyPart="Localized Recovery",
        ContextMenu_medWorks_RegionLeftArm="Localized Left Arm"}
    return values[key] or key
end
require "medWorks/CorpseMenu"
attached=true
callback(0,context,{},false)
assert(#options==2 and options[1].label=="Localized Recovery" and options[2].label=="Localized Left Arm")
options[2].fn(options[2].target,unpack(options[2].args)); assert(queued==1)
carried=false
options[2].fn(options[2].target,unpack(options[2].args)); assert(queued==1)
options={}; callback(0,context,{},false); assert(#options==0)
ISWorldObjectContextMenu.fetchVars.body={}; callback(0,context,{},false)
print("medWorks corpse recovery validation, action completion and safe menu checks passed")
