local medWorks=require "medWorks/init"
local Mortis=require "Mortis/init"
local Knowledge=require "medWorks/Knowledge"
local Progression=require "B47ANCEDKnowledgeAndWisdom/Progression"
local Recovery={}
local unpackArguments=unpack or table.unpack
Recovery.regions={"neck","leftArm","rightArm","leftHand","rightHand","leftLeg","rightLeg","leftFoot","rightFoot"}
-- Exact verified vanilla saw types; providers may register equivalent tools.
local tools={['Base.Saw']=true,['Base.GardenSaw']=true}
local ACTION_ID="medWorks.CorpseRecovery"
if not Progression.hasSemanticAction(ACTION_ID) then
    Progression.registerSemanticAction{id=ACTION_ID,owner="medWorks",title="Anatomical Recovery",
        baseXP=2,skills={Doctor=1},outcomes={success=1},repeatWindowHours=168,
        repeatDecay=.2,repeatFloor=.25}
end
local function call(object,method,...)
    if not object then return nil end
    local args={...}
    local ok,value=pcall(function() return object[method](object,unpackArguments(args)) end)
    if ok then return value end
end
function Recovery.registerTool(fullType)
    assert(type(fullType)=="string" and fullType:find(".",1,true),"tool full type required")
    tools[fullType]=true
end
function Recovery.duration()
    local options=SandboxVars and SandboxVars.medWorks or {}
    local value=tonumber(options.CorpseRecoverySeconds) or 120
    if value~=value then value=120 end
    return math.max(10,math.min(3600,value))
end
function Recovery.isTool(item)
    return tools[call(item,"getFullType")]==true and (tonumber(call(item,"getCondition")) or 0)>0
end
function Recovery.validate(character,corpse,region,tool)
    if SandboxVars and SandboxVars.medWorks and SandboxVars.medWorks.EnableCorpseRecovery==false then
        return nil,"Corpse recovery is disabled."
    end
    if call(character,"isDead")~=false then return nil,"Living practitioner required." end
    local learned,reason=Knowledge.canRecover(character)
    if not learned then return nil,reason end
    if call(corpse,"getObjectName")~="DeadBody" then return nil,"World corpse required." end
    local index=call(corpse,"getStaticMovingObjectIndex")
    if type(index)~="number" or index<0 then return nil,"Corpse is no longer available." end
    local square=call(character,"getSquare")
    local targetSquare=call(corpse,"getSquare")
    if not square or not targetSquare or call(square,"canReachTo",targetSquare)~=true then
        return nil,"Cannot reach corpse."
    end
    local distance=call(corpse,"DistToSquared",character)
    if type(distance)~="number" or distance~=distance or distance>4 then return nil,"Move within two tiles of the corpse." end
    local inventory=call(character,"getInventory")
    if not inventory or call(tool,"getOutermostContainer")~=inventory
        or call(call(tool,"getContainer"),"contains",tool)~=true
        or not Recovery.isTool(tool) then return nil,"A carried saw is required." end
    local condition=call(tool,"getCondition")
    if type(condition)~="number" or condition<=0 then return nil,"Saw is broken." end
    if not medWorks.PART_TYPES[region] then return nil,"Unsupported region." end
    local ok,state,definition=pcall(Mortis.Anatomy.getRegion,corpse,region)
    if not ok or not state or not definition or definition.severable~=true or state.attached~=true
        or state.destroyed==true then return nil,"Region is missing or unavailable." end
    local accessOk,access,accessError=pcall(medWorks.getRegionAccess,corpse,region)
    if not accessOk or not access then return nil,accessError or "Anatomical clothing access unavailable." end
    if access.accessible~=true then return nil,"Remove clothing covering this region before anatomical recovery." end
    local captured,record=pcall(Mortis.DetachedParts.captureCorpse,corpse,region)
    if not captured or not record then return nil,"Corpse provenance unavailable." end
    return inventory
end
function Recovery.complete(character,corpse,region,tool)
    local inventory,reason=Recovery.validate(character,corpse,region,tool)
    if not inventory then return nil,reason end
    local item,provenance,result=medWorks.sever(corpse,region,inventory,{procedureId=ACTION_ID,transmit=true})
    if not item then return nil,provenance,result end
    local conditionValue=call(tool,"getCondition")
    local maximumValue=call(tool,"getConditionMax")
    local condition=tonumber(conditionValue) or 1
    local maximum=tonumber(maximumValue) or math.max(1,condition)
    local quality=math.max(0,math.min(1,condition/math.max(1,maximum)))
    local difficulty=(region=="neck" and 1.5) or ((region=="leftHand" or region=="rightHand" or region=="leftFoot" or region=="rightFoot") and .75) or 1
    local gameTime
    if type(rawget(_G,"getGameTime"))=="function" then local got,value=pcall(getGameTime); if got then gameTime=value end end
    local worldAgeHours=call(gameTime,"getWorldAgeHours")
    local sourceId=type(provenance)=="table" and provenance.sourceStableId or tostring(corpse)
    local ok,awarded,awardReason=pcall(Progression.processSemanticAction,character,ACTION_ID,
        {committed=true,meaningful=true,outcome="success",difficulty=difficulty,quality=quality,
            sourceCategory="corpse-anatomy",sourceId=tostring(sourceId)},
        {worldAgeHours=worldAgeHours})
    if not ok or awarded~=true then
        pcall(print,"[medWorks] Corpse recovery committed; semantic XP was not applied: "..tostring(ok and awardReason or awarded))
    end
    return item,provenance,result
end
medWorks.CorpseRecovery=Recovery
return Recovery
