local Report=require "medWorks/ExaminationReport"
local Completed=require "medWorks/CompletedExaminations"
local Viewer={};local windows={}
local function owns(playerNum,examiner)
    return type(playerNum)=="number"and playerNum>=0 and playerNum==math.floor(playerNum)
        and type(getSpecificPlayer)=="function"and getSpecificPlayer(playerNum)==examiner
end
local function bounds(playerNum)
    local width=getPlayerScreenWidth(playerNum);local height=getPlayerScreenHeight(playerNum)
    if width<260 or height<180 then return nil end
    local w=math.min(720,width-40);local h=math.min(520,height-40)
    return getPlayerScreenLeft(playerNum)+(width-w)/2,getPlayerScreenTop(playerNum)+(height-h)/2,w,h
end
function Viewer.open(playerNum,examiner,patient)
    if not owns(playerNum,examiner)then return false,"EXAMINATION_REQUIRED"end
    -- Recheck the exact observer/patient cache when a possibly old menu is clicked.
    local report,reason,age=Completed.inspect(examiner,patient)
    if not report then return false,reason end
    local x,y,width,height=bounds(playerNum)
    if not x then return false,"VIEWPORT_UNAVAILABLE"end
    require "ISUI/ISModalRichText"
    local lines={Report.text("UI_medWorks_Report_Title","Examination report"),
        Report.text("UI_medWorks_Report_Recorded","Recorded %1 seconds ago.",math.floor(age/1000)),
        Report.text("UI_medWorks_Report_ReadOnly","Read-only observations from a completed examination; not a diagnosis or live health reading.")}
    for _,line in ipairs(Report.format(report))do lines[#lines+1]=line end
    if windows[playerNum]then windows[playerNum]:destroy()end
    local modal=ISModalRichText:new(x,y,width,height,table.concat(lines," <LINE> "),false,nil,nil,playerNum)
    -- This report must never change game speed/paused-message state on close.
    function modal:destroy()
        if windows[playerNum]~=self then return end
        windows[playerNum]=nil
        self:setVisible(false);self:removeFromUIManager()
        if type(getJoypadFocus)=="function"and getJoypadFocus(playerNum)==self then setJoypadFocus(playerNum,self.prevFocus)end
    end
    -- Vanilla modal auto-height uses the whole screen. Keep this instance in its
    -- player's viewport, with fixed scrolling height and live viewport resize.
    function modal:update()
        ISPanelJoypad.update(self)
        if not owns(playerNum,examiner)then self:destroy();return end
        local left,top,w,h=bounds(playerNum)
        if not left then self:destroy();return end
        if self:getWidth()~=w or self:getHeight()~=h then
            self:setWidth(w);self:setHeight(h);self:ignoreHeightChange();self:updateButtons()
            self.ok:setX((w-self.ok:getWidth())/2)
            self.chatText:setWidth(w-4);self.chatText:paginate()
        end
        self:setX(left);self:setY(top)
        self.chatText:setHeight(math.max(1,self.ok:getY()-2));self.chatText:updateScrollbars()
    end
    modal:initialise();modal:addToUIManager();windows[playerNum]=modal
    if type(getJoypadFocus)=="function"and type(setJoypadFocus)=="function"then
        modal.prevFocus=getJoypadFocus(playerNum);setJoypadFocus(playerNum,modal)
    end
    return true
end
function Viewer.addHealthPanelOption(context,playerNum,examiner,patient)
    if not context or not owns(playerNum,examiner)or not Completed.inspect(examiner,patient)then return false end
    if not bounds(playerNum)then return false end
    local label=Report.text("ContextMenu_medWorks_ViewExamination","View last examination")
    context:addOption(label,playerNum,Viewer.open,examiner,patient)
    return true
end
return Viewer
