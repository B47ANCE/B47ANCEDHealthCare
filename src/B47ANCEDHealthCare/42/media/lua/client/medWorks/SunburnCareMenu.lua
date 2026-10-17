require "TimedActions/ISTimedActionQueue"
local Care=require "medWorks/SunburnCare"
local Action=require "medWorks/SunburnCareAction"
local Menu={}
function Menu.add(playerNum,context,items)
    local player=type(getSpecificPlayer)=="function" and getSpecificPlayer(playerNum)
    if not player or type(items)~="table" or not context then return end
    for index,entry in ipairs(items) do
        if index>64 then break end
        local item=type(entry)=="table" and entry.items and entry.items[1] or entry
        if Care.validate(player,item)==true then
            context:addOption(getText("ContextMenu_medWorks_CoolSunburn"),player,function(actor,pack)
                if Care.validate(actor,pack) then ISTimedActionQueue.add(Action:new(actor,pack)) end
            end,item)
            return
        end
    end
end
if Events and Events.OnFillInventoryObjectContextMenu then Events.OnFillInventoryObjectContextMenu.Add(Menu.add) end
return Menu
