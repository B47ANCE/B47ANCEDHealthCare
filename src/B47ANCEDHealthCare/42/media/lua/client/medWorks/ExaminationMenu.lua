require "XpSystem/ISUI/ISHealthPanel"
require "TimedActions/ISTimedActionQueue"
local Action=require "medWorks/ExaminationAction"
local DiagnosticsViewer=require "medWorks/ProcedureDiagnosticViewer"
local ExaminationViewer=require "medWorks/ExaminationViewer"
local original=ISHealthPanel.doBodyPartContextMenu
if not ISHealthPanel.medWorksExaminationWrapped then
    ISHealthPanel.medWorksExaminationWrapped=true
    function ISHealthPanel:doBodyPartContextMenu(bodyPart,x,y)
        original(self,bodyPart,x,y)
        local patient=self:getPatient();local examiner=self:getDoctor();if not patient or not examiner then return end
        local playerNum=self.otherPlayer and self.otherPlayer:getPlayerNum()or self.character:getPlayerNum();local context=ISContextMenu.get(playerNum,x+self:getAbsoluteX(),y+self:getAbsoluteY())
        if not context then return end
        local vars=rawget(_G,"SandboxVars")
        if not(vars and vars.medWorks and vars.medWorks.EnableExaminations==false)then
            local label=type(getText)=="function"and getText("ContextMenu_medWorks_PerformExamination")or"Perform examination"
            context:addOption(label,examiner,function(character,target)local ok=pcall(function()ISTimedActionQueue.add(Action:new(character,target))end);if not ok and print then print("[medWorks] Examination action unavailable")end end,patient)
        end
        ExaminationViewer.addHealthPanelOption(context,playerNum,examiner,patient)
        DiagnosticsViewer.addHealthPanelOption(context,playerNum,examiner,patient)
        context:setVisible(true)
    end
end
return true
