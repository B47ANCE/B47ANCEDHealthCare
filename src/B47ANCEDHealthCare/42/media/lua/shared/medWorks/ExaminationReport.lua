local medWorks=require "medWorks/init"
local Report={MAX_LINES=80,MAX_LINE_LENGTH=180,MAX_SECTIONS=16,MAX_PARTS=64,MAX_DIAGNOSTICS=16}
local function finite(value)
    return type(value)=="number" and value==value and value~=math.huge and value~=-math.huge
end
local function prefix(value,limit)
    local cut=value:sub(1,limit);local start=#cut
    while start>0 and cut:byte(start)>=128 and cut:byte(start)<192 do start=start-1 end
    local lead=cut:byte(start)or 0
    local width=lead>=240 and 4 or lead>=224 and 3 or lead>=192 and 2 or 1
    if start+width-1>#cut then cut=cut:sub(1,start-1)end
    return cut
end
function Report.safeText(value)
    if type(value)~="string"then value=finite(value)and tostring(value)or ""end
    local truncated=#value>Report.MAX_LINE_LENGTH
    value=prefix(value,truncated and Report.MAX_LINE_LENGTH-3 or Report.MAX_LINE_LENGTH)
    -- Provider content is plain text. Only the viewer supplies rich-text tags.
    value=value:gsub("[%c]"," "):gsub("<","["):gsub(">","]")
    return value..(truncated and "..."or "")
end
function Report.text(key,fallback,...)
    local args={...}
    if type(getText)=="function"then
        local ok,value=pcall(getText,key,unpack(args))
        if ok and type(value)=="string"and value~=""and value~=key then return Report.safeText(value)end
    end
    return Report.safeText((fallback:gsub("%%(%d)",function(index)return Report.safeText(args[tonumber(index)])end)))
end
local function tr(name,fallback,...)return Report.text("UI_medWorks_Report_"..name,fallback,...)end
local function count(value)
    if not finite(value)or value<0 then return nil end
    return math.min(Report.MAX_PARTS,math.floor(value))
end
local findings={
    {"bandaged","Bandaged","bandaged"},{"bandageDirty","DirtyBandage","dirty bandage"},
    {"bitten","Bite","bite"},{"scratched","Scratch","scratch"},{"cut","Cut","laceration"},
    {"bleeding","Bleeding","bleeding"},{"deepWounded","DeepWound","deep wound"},
    {"glass","Glass","glass"},{"bullet","Bullet","bullet"},{"stitched","Stitched","stitched"},
    {"splinted","Splinted","splinted"},{"burnt","Burn","burn"},
    {"needsBurnWash","BurnWash","burn needs washing"},
    {"localWoundInfection","WoundInfection","local wound infection"},
}
local bodyNames={Hand_L="Left hand",Hand_R="Right hand",ForeArm_L="Left forearm",ForeArm_R="Right forearm",
    UpperArm_L="Left upper arm",UpperArm_R="Right upper arm",Torso_Upper="Upper torso",Torso_Lower="Lower torso",
    Head="Head",Neck="Neck",Groin="Groin",UpperLeg_L="Left thigh",UpperLeg_R="Right thigh",
    LowerLeg_L="Left shin",LowerLeg_R="Right shin",Foot_L="Left foot",Foot_R="Right foot"}
local function partLine(part)
    if type(part)~="table"then return nil end
    local observed={}
    for _,entry in ipairs(findings)do
        if rawget(part,entry[1])==true then observed[#observed+1]=tr(entry[2],entry[3])end
    end
    if #observed==0 and rawget(part,"injured")==true then observed[1]=tr("Injury","injury observed")end
    if #observed==0 then return nil end
    local kind=rawget(part,"type")
    local label=type(kind)=="string"and bodyNames[kind]or nil
    label=label and tr("Part_"..kind,label)or Report.safeText(kind)
    if label==""then label=tr("BodyPart","Body part")end
    return label..": "..table.concat(observed,", ")
end
local onlyCureStates = {
    ["not-ready"] = {"OnlyCureNotReady", "Only Cure+ observations unavailable: local data is not ready."},
    ["unsupported-version"] = {"OnlyCureUnsupported", "Only Cure+ observations unavailable: unsupported version."},
    ["conflicting-mod"] = {"OnlyCureConflict", "Only Cure+ observations unavailable: conflicting original mod is active."},
}
local onlyCureParts = {Hand_L=true, ForeArm_L=true, UpperArm_L=true, Hand_R=true, ForeArm_R=true,
    UpperArm_R=true, Foot_L=true, LowerLeg_L=true, UpperLeg_L=true, Foot_R=true, LowerLeg_R=true, UpperLeg_R=true}
local function onlyCureLines(data, add)
    local status = rawget(data, "status")
    if status ~= "ready" or rawget(data, "scope") ~= "local-self" or rawget(data, "schemaVersion") ~= 1 then
        local text = onlyCureStates[status]
        add(text and tr(text[1], text[2]) or tr("OnlyCureUnavailable", "Only Cure+ observations unavailable; no limb status inferred."))
        return
    end
    local parts, seen = rawget(data, "parts"), {}
    local valid = type(parts) == "table" and rawget(parts, 13) == nil
    for index = 1, 12 do
        local part = valid and rawget(parts, index)
        local name = type(part) == "table" and rawget(part, "type")
        local loss = type(part) == "table" and rawget(part, "lossReported")
        local support = type(part) == "table" and rawget(part, "supportReported")
        if not onlyCureParts[name] or seen[name] or type(loss) ~= "boolean" or type(support) ~= "boolean"
            or (not loss and support) then valid = false; break end
        seen[name] = true
    end
    if not valid then add(tr("OnlyCureUnavailable", "Only Cure+ observations unavailable; no limb status inferred.")); return end
    add(tr("OnlyCureTitle", "Only Cure+ local self-observation"))
    add(tr("OnlyCureSeparate", "Vanilla health and reported limb loss describe separate systems."))
    for index = 1, 12 do
        local part = rawget(parts, index)
        local name = rawget(part, "type")
        local state = not rawget(part, "lossReported") and tr("OnlyCureNoLoss", "no loss reported")
            or rawget(part, "supportReported") and tr("OnlyCureSupportedLoss", "loss and prosthetic support reported")
            or tr("OnlyCureUnsupportedLoss", "loss reported; no prosthetic support reported")
        if not add(tr("Part_"..name, bodyNames[name])..": "..state) then break end
    end
end
function Report.format(report)
    if type(report)~="table"then return{tr("Unavailable","Examination unavailable")}end
    local lines={};local truncated=rawget(report,"presentationLimited")==true
    local function add(value)
        if #lines>=Report.MAX_LINES-1 then truncated=true;return false end
        lines[#lines+1]=Report.safeText(value);return true
    end
    local sections=rawget(report,"sections")
    if type(sections)=="table"then
        for index=1,Report.MAX_SECTIONS do
            local section=rawget(sections,index);if section==nil then break end
            if type(section)=="table"then
                local data=rawget(section,"data")
                if type(data)=="table"then
                    local id=Report.safeText(rawget(section,"providerId")or rawget(section,"owner"))
                    if not add("["..(id~=""and id or tr("Provider","provider")).."]")then break end
                    if rawget(data,"kind")=="only-cure-self" then
                        onlyCureLines(data,add)
                    else
                    local health=rawget(data,"overallHealth")
                    if finite(health)and health>=0 and health<=100 then add(tr("Health","Overall health: %1",string.format("%.1f",health)))end
                    local injured=count(rawget(data,"injuredPartCount"))
                    if injured then add(tr("Areas","Injured areas observed: %1",injured))end
                    local parts=rawget(data,"parts")
                    if type(parts)=="table"then
                        for partIndex=1,Report.MAX_PARTS do
                            local part=rawget(parts,partIndex);if part==nil then break end
                            local line=partLine(part);if line and not add(line)then break end
                        end
                        if rawget(parts,Report.MAX_PARTS+1)~=nil then truncated=true end
                    end
                    if rawget(data,"truncated")==true then add(tr("PartLimit","Observation limited by the body-part safety ceiling."))end
                    end
                end
            end
            if #lines>=Report.MAX_LINES-1 then truncated=true;break end
        end
        if rawget(sections,Report.MAX_SECTIONS+1)~=nil then truncated=true end
    end
    local diagnostics=rawget(report,"diagnostics")
    if type(diagnostics)=="table"then
        for index=1,Report.MAX_DIAGNOSTICS do
            local diagnostic=rawget(diagnostics,index);if diagnostic==nil then break end
            if type(diagnostic)=="table"then
                local id=Report.safeText(rawget(diagnostic,"providerId"))
                local reason=Report.safeText(rawget(diagnostic,"error"))
                if not add(tr("Diagnostic","Provider %1: %2",id~=""and id or tr("Unknown","unknown"),reason~=""and reason or tr("UnavailableReason","unavailable")))then break end
            end
        end
        if rawget(diagnostics,Report.MAX_DIAGNOSTICS+1)~=nil then truncated=true end
    end
    if truncated then lines[#lines+1]=tr("Limited","Report limited; additional observations are omitted.")end
    if #lines==0 then lines[1]=tr("NoFindings","No observable findings.")end
    return lines
end
function Report.summary(report)
    local sections=type(report)=="table"and rawget(report,"sections")or nil
    local injured,infections,known=0,0,false
    if type(sections)=="table"then
        for index=1,Report.MAX_SECTIONS do
            local section=rawget(sections,index);if section==nil then break end
            local data=type(section)=="table"and rawget(section,"data")or nil
            if type(data)=="table"then
                if rawget(data,"kind")=="only-cure-self" then
                    return tr("OnlyCureSummary","Examination complete: review the detailed report for Only Cure+ observations.")
                end
                local value=count(rawget(data,"injuredPartCount"))
                if value then injured=injured+value;known=true end
                infections=infections+(count(rawget(data,"localWoundInfectionCount"))or 0)
            end
        end
    end
    if not known then return tr("SummaryUnknown","Examination complete: findings unavailable.")end
    if injured==0 and infections==0 then return tr("SummaryClear","Examination complete: no observable injuries.")end
    local text=injured==1 and tr("SummaryOne","Examination complete: 1 injured area observed.")or tr("SummaryMany","Examination complete: %1 injured areas observed.",injured)
    if infections>0 then text=text.." "..(infections==1 and tr("InfectionOne","1 local wound infection observed.")or tr("InfectionMany","%1 local wound infections observed.",infections))end
    return Report.safeText(text)
end
medWorks.ExaminationReport=Report
return Report
