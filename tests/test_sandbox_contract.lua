local function read(path)
    local file=assert(io.open(path,"rb"));local value=file:read("*a");file:close();return value
end
local options=read(arg[1]);local translations=read(arg[2])
local recovery=read(arg[3]);local knowledge=read(arg[4]);local examination=read(arg[5]);local action=read(arg[6])
local expected={
    RequireRecoveryKnowledge="boolean",EnableCorpseRecovery="boolean",CorpseRecoverySeconds="integer",
    EnableExaminations="boolean",ExaminationSeconds="integer",
    EnableSunburnCare="boolean",SunburnCareSeconds="integer",SunburnCareReduction="double",
}
for id,kind in pairs(expected)do
    local block=options:match("option%s+medWorks%."..id.."%s*(%b{})")
    assert(block,"missing medWorks sandbox option "..id)
    assert(block:match("type%s*=%s*"..kind),"wrong type for medWorks sandbox option "..id)
    assert(block:match("translation%s*=%s*medWorks_"..id),"missing translation binding for "..id)
    assert(translations:find('"Sandbox_medWorks_'..id..'"',1,true),"missing label translation for "..id)
    assert(translations:find('"Sandbox_medWorks_'..id..'_tooltip"',1,true),"missing tooltip translation for "..id)
end
assert(recovery:find("EnableCorpseRecovery==false",1,true),"authority completion must recheck recovery enable switch")
assert(recovery:find("CorpseRecoverySeconds",1,true),"recovery duration must consume sandbox value")
assert(knowledge:find("RequireRecoveryKnowledge==false",1,true),"knowledge bypass must consume owning sandbox value")
assert(not options:find("option medWorks.ExaminationMaxBodyParts",1,true),"technical traversal ceilings are not player settings")
assert(examination:find("HARD_PART_LIMIT=64",1,true),"internal examination safety ceiling must remain bounded")
assert(action:find("ExaminationSeconds",1,true),"examination action must consume duration setting")
print("medWorks implemented-feature sandbox ownership contract passed")
