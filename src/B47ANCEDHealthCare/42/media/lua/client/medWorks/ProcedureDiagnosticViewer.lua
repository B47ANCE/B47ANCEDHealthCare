local Diagnostics=require "medWorks/ProcedureDiagnostics"
local Viewer={};local windows={}
local function authorized(character)
    if type(isDebugEnabled)=="function"then local ok,value=pcall(isDebugEnabled);if ok and value==true then return true end end
    if character and character.getAccessLevel then
        local ok,value=pcall(function()return character:getAccessLevel()end)
        return ok and type(value)=="string"and value~=""and value~="None"
    end
    return false
end
function Viewer.open(playerNum,patient)
    local character=type(getSpecificPlayer)=="function"and getSpecificPlayer(playerNum)or nil
    if not authorized(character)then return false,"operator access required"end
    local ok,result=pcall(function()
        require "ISUI/ISModalRichText"
        if windows[playerNum]then windows[playerNum]:destroy()end
        local width=math.min(720,getPlayerScreenWidth(playerNum)-40);local height=math.min(520,getPlayerScreenHeight(playerNum)-40)
        local x=getPlayerScreenLeft(playerNum)+(getPlayerScreenWidth(playerNum)-width)/2
        local y=getPlayerScreenTop(playerNum)+(getPlayerScreenHeight(playerNum)-height)/2
        local modal;modal=ISModalRichText:new(x,y,width,height,Diagnostics.format(Diagnostics.snapshot(patient)),false,nil,function()if windows[playerNum]==modal then windows[playerNum]=nil end end,playerNum)
        modal:initialise();modal:addToUIManager();windows[playerNum]=modal;return true
    end)
    return ok and result==true
end
function Viewer.addHealthPanelOption(context,playerNum,examiner,patient)
    if not context or not authorized(examiner)then return end
    local label=type(getText)=="function"and getText("ContextMenu_medWorks_ProcedureDiagnostics")or"Procedure diagnostics"
    context:addOption(label,playerNum,Viewer.open,patient)
end
return Viewer
