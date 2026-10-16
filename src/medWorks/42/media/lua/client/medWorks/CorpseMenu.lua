require "TimedActions/ISTimedActionQueue"
local Action=require "medWorks/RecoverPartAction"
local Recovery=require "medWorks/CorpseRecovery"
local Knowledge=require "medWorks/Knowledge"
local function tr(key,fallback)
    local get=rawget(_G,"getText")
    if type(get)~="function" then return fallback end
    local ok,value=pcall(get,key)
    if ok and type(value)=="string" and value~="" and value~=key then return value end
    return fallback
end
local labels={neck={"ContextMenu_medWorks_RegionHead","Head"},leftArm={"ContextMenu_medWorks_RegionLeftArm","Left arm"},
    rightArm={"ContextMenu_medWorks_RegionRightArm","Right arm"},leftHand={"ContextMenu_medWorks_RegionLeftHand","Left hand"},
    rightHand={"ContextMenu_medWorks_RegionRightHand","Right hand"},leftLeg={"ContextMenu_medWorks_RegionLeftLeg","Left leg"},
    rightLeg={"ContextMenu_medWorks_RegionRightLeg","Right leg"},leftFoot={"ContextMenu_medWorks_RegionLeftFoot","Left foot"},
    rightFoot={"ContextMenu_medWorks_RegionRightFoot","Right foot"}}
local function queue(character,corpse,region,tool)
    if Recovery.validate(character,corpse,region,tool) then
        ISTimedActionQueue.add(Action:new(character,corpse,region,tool))
    end
end
local function fill(player,context,worldobjects,test)
    if test then return end
    local character=getSpecificPlayer(player)
    local fetch=ISWorldObjectContextMenu and ISWorldObjectContextMenu.fetchVars
    local corpse=fetch and fetch.body
    if not character or not corpse then return end
    -- Vanilla recursive inventory predicate includes nested bags; no world scan.
    local tool=character:getInventory():getFirstEvalRecurse(function(item)
        return Recovery.isTool(item)
    end)
    if not tool then return end
    local learned=Knowledge.canRecover(character)
    if not learned then
        local option=context:addOption(tr("ContextMenu_medWorks_RecoveryKnowledgeRequired","Recover body part (medical reading required)"),nil,nil)
        option.notAvailable=true
        return
    end
    local available={}
    for _,region in ipairs(Recovery.regions) do
        if Recovery.validate(character,corpse,region,tool) then available[#available+1]=region end
    end
    if #available==0 then return end
    local root=context:addOption(tr("ContextMenu_medWorks_RecoverBodyPart","Recover body part"),nil,nil)
    local submenu=ISContextMenu:getNew(context)
    context:addSubMenu(root,submenu)
    for _,region in ipairs(available) do
        local label=labels[region]
        submenu:addOption(label and tr(label[1],label[2]) or tostring(region),character,queue,corpse,region,tool)
    end
end
Events.OnFillWorldObjectContextMenu.Add(function(...)
    -- Unknown/modded objects cannot break the rest of the world context menu.
    local ok=pcall(fill,...)
    if not ok then pcall(print,"[medWorks] Corpse recovery menu unavailable") end
end)
