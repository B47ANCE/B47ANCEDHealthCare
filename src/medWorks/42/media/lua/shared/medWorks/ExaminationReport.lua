local medWorks=require "medWorks/init"
local Report={MAX_LINES=80,MAX_LINE_LENGTH=180}
local function bounded(value)value=tostring(value or ""):gsub("[%c]"," ");return #value>Report.MAX_LINE_LENGTH and value:sub(1,Report.MAX_LINE_LENGTH).."…"or value end
local function add(lines,value)if #lines<Report.MAX_LINES then lines[#lines+1]=bounded(value)end end
local function partLine(part)
    local findings={}
    for _,entry in ipairs({{"bandaged","bandaged"},{"bandageDirty","dirty bandage"},{"bitten","bite"},{"scratched","scratch"},{"cut","laceration"},{"bleeding","bleeding"},{"deepWounded","deep wound"},{"glass","glass"},{"bullet","bullet"},{"stitched","stitched"},{"splinted","splinted"},{"burnt","burn"},{"needsBurnWash","burn needs washing"},{"localWoundInfection","local wound infection"}})do if part[entry[1]]==true then findings[#findings+1]=entry[2]end end
    if #findings==0 and part.injured then findings[1]="injury observed"end
    if #findings==0 then return nil end
    return tostring(part.type or "Body part")..": "..table.concat(findings,", ")
end
function Report.format(report)
    local lines={};if type(report)~="table"then return{"Examination unavailable"}end
    for _,section in ipairs(type(report.sections)=="table"and report.sections or{})do
        local data=type(section.data)=="table"and section.data or{};add(lines,"["..tostring(section.providerId or section.owner or "provider").."]")
        if data.overallHealth then add(lines,"Overall health: "..string.format("%.1f",data.overallHealth))end
        if data.injuredPartCount~=nil then add(lines,"Injured areas observed: "..tostring(data.injuredPartCount))end
        for _,part in ipairs(type(data.parts)=="table"and data.parts or{})do local line=partLine(part);if line then add(lines,line)end end
        if data.truncated then add(lines,"Observation limited by configured body-part ceiling.")end
    end
    for _,diagnostic in ipairs(type(report.diagnostics)=="table"and report.diagnostics or{})do add(lines,"Provider "..tostring(diagnostic.providerId or "unknown")..": "..tostring(diagnostic.error or "unavailable"))end
    if #lines==0 then lines[1]="No observable findings."end;return lines
end
function Report.summary(report)
    local injured,infections=0,0
    for _,section in ipairs(type(report)=="table"and type(report.sections)=="table"and report.sections or{})do local data=type(section.data)=="table"and section.data or{};injured=injured+(tonumber(data.injuredPartCount)or 0);infections=infections+(tonumber(data.localWoundInfectionCount)or 0)end
    if injured==0 then return"Examination complete: no observable injuries."end
    local text="Examination complete: "..tostring(injured).." injured area"..(injured==1 and""or"s").." observed."
    if infections>0 then text=text.." "..tostring(infections).." local wound infection"..(infections==1 and""or"s").." observed."end
    return text
end
medWorks.ExaminationReport=Report
return Report
