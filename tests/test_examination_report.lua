package.loaded["medWorks/init"]={}
local Report=require "medWorks/ExaminationReport"
local malformed={sections={{data={overallHealth={},injuredPartCount=0/0,parts={false,42,{type={},bleeding=true}}}},false},diagnostics={false,{providerId={},error=function()error("must not stringify callbacks")end}}}
local ok,lines=pcall(Report.format,malformed)
assert(ok and type(lines)=="table","one malformed provider must not abort examination presentation")
local healthy={sections={{providerId="human",data={overallHealth=99.5,injuredPartCount=0,parts={}}}}}
assert(Report.summary(healthy):find("no observable injuries",1,true))
assert(not Report.summary(malformed):find("no observable injuries",1,true),"missing/invalid counts are not healthy evidence")
local poisoned={sections={},diagnostics={}}
for i=1,40 do
    local parts={}
    for j=1,100 do parts[j]={type="<IMAGE:private>\n"..string.rep("x",10000),bleeding=true}end
    poisoned.sections[i]={providerId="<LINE>\tprovider",data={overallHealth=math.huge,injuredPartCount=math.huge,localWoundInfectionCount=-1,parts=parts}}
end
local rendered=Report.format(poisoned)
assert(#rendered<=Report.MAX_LINES and rendered[#rendered]:find("limited",1,true),"large reports need a visible truncation marker")
for _,line in ipairs(rendered)do assert(#line<=Report.MAX_LINE_LENGTH and not line:find("[<>%c]"),"provider markup/controls must remain inert and bounded")end
assert(not Report.summary(poisoned):find("inf",1,true))
local huge={sections={{data={injuredPartCount=999999,localWoundInfectionCount=999999}}}}
assert(Report.summary(huge):find("64 injured areas",1,true),"per-provider counts are capped to observation budget")
local utf8=string.rep(string.char(230,181,139),200)
local clipped=Report.safeText(utf8)
assert(#clipped<=Report.MAX_LINE_LENGTH and clipped:sub(-3)=="..." and (#clipped-3)%3==0,"UTF-8 truncation must preserve character boundaries")
getText=function(key,...)
    if key=="UI_medWorks_Report_Health"then return "Translated health: "..select(1,...)end
    return key
end
assert(table.concat(Report.format(healthy)," "):find("Translated health: 99.5",1,true),"report must consume localized text")
getText=function()error("unavailable translator")end
assert(Report.summary(healthy):find("no observable injuries",1,true),"English fallback must work offline/when lookup fails")
print("Examination malformed-provider isolation, bounds, markup, UTF-8, counts and localization checks passed")
