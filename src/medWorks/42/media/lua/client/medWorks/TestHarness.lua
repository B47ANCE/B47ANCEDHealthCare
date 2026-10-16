-- Development-only in-game harness; host tests omit the engine predicate.
if type(isDebugEnabled)=="function" and isDebugEnabled()~=true then return {} end

local medWorks=require "medWorks/init"
local Knowledge=require "medWorks/Knowledge"
local ProcedureDiagnostics=require "medWorks/ProcedureDiagnostics"

local Harness={}
local RESULT_FILE="theWorks Test Results - medWorks.txt"
local DATA_KEY="medWorks.TestSession.V1"
local RUNTIME_TOKEN=tostring({})
local steps={
    {id="startup",feature="Canonical load, dependencies, APIs, and result export",
        instruction="Run medWorksTestAuto()."},
    {id="examination",feature="Read-only self examination",instruction="Run medWorksTestExamine(), then confirm the detailed console report and no treatment mutation."},
    {id="examination_action",feature="Health-panel examination action",instruction="Use Perform examination; verify duration plus movement/range cancellation and concise overhead output."},
    {id="research",feature="experienceWorks medical prerequisites",instruction="Read Field Safety, verify Anatomy Recovery is initially blocked, then read it and run medWorksTestKnowledge()."},
    {id="corpse_access",feature="Corpse menu, clothing access, and tools",instruction="With a nested working saw, verify clothing and range denials, then expose one valid region."},
    {id="corpse_recovery",feature="Authoritative one-part recovery",instruction="Recover one region; verify one provenance-bearing part and that replay plus descendant recovery reject."},
    {id="persistence",feature="Recovered anatomy save/reload persistence",instruction="Save/quit/reload and verify the recovered region stays unavailable, then run medWorksTestReload()."},
    {id="sandbox",feature="Recovery and examination sandbox controls",instruction="Verify enable switches and durations affect menus and already-queued completion."},
    {id="multiplayer",feature="Hosted and dedicated authority",instruction="Verify one request/one output, stale identity rejection, reconnect, and replication; BLOCKED until available."},
}

local function safe(value) return tostring(value or ""):gsub("[\r\n]+"," "):sub(1,500) end
local function now()
    local library=rawget(_G,"os")
    if type(library)=="table" and type(library.date)=="function" then
        local ok,value=pcall(library.date,"!%Y-%m-%dT%H:%M:%SZ")
        if ok and value then return tostring(value) end
    end
    return "timestamp unavailable"
end
local function worldAge()
    local getter=rawget(_G,"getGameTime"); if type(getter)~="function" then return 0 end
    local ok,time=pcall(getter); if not ok or not time then return 0 end
    local read,value=pcall(function() return time:getWorldAgeHours() end)
    return read and tonumber(value) or 0
end
local function pzVersion()
    local getter=rawget(_G,"getCore"); if type(getter)~="function" then return "unavailable" end
    local ok,core=pcall(getter); if not ok or not core then return "unavailable" end
    for _,name in ipairs({"getVersionNumber","getVersion"}) do
        if type(core[name])=="function" then local read,value=pcall(core[name],core); if read and value~=nil then return tostring(value) end end
    end
    return "unavailable"
end
local function player()
    local getter=rawget(_G,"getSpecificPlayer")
    if type(getter)=="function" then local ok,value=pcall(getter,0); if ok and value then return value end end
    getter=rawget(_G,"getPlayer"); if type(getter)=="function" then local ok,value=pcall(getter); if ok then return value end end
end
local function modData(character)
    if not character or type(character.getModData)~="function" then return nil end
    local ok,value=pcall(character.getModData,character); return ok and type(value)=="table" and value or nil
end
local function session(create)
    local character=player(); local data=modData(character)
    if not data then return nil,nil,"local player ModData unavailable" end
    if create and type(data[DATA_KEY])~="table" then
        data[DATA_KEY]={schemaVersion=1,sessionId=string.format("MED-%s-%.3f",safe(now()),worldAge()),startedAt=now(),
            pzVersion=pzVersion(),modId="medWorks",modVersion=medWorks.VERSION,runtimeToken=RUNTIME_TOKEN,results={},commands={}}
    end
    return data[DATA_KEY],character
end
local function counts(current)
    local result={PASS=0,FAIL=0,BLOCKED=0,PENDING=0}
    for _,step in ipairs(steps) do local status=current.results[step.id] and current.results[step.id].status or "PENDING"; result[status]=(result[status] or 0)+1 end
    return result
end
local function overall(current)
    local result=counts(current); if result.FAIL>0 then return "FAIL" end; if result.PENDING>0 then return "IN_PROGRESS" end
    if result.BLOCKED>0 then return "BLOCKED" end; return "PASS"
end
local function reportLines(current)
    local output={"theWorks in-game test results","Mod: medWorks","Mod ID: medWorks","Mod version: "..safe(current.modVersion),
        "Project Zomboid version: "..safe(current.pzVersion),"Session: "..safe(current.sessionId),"Started: "..safe(current.startedAt),
        "Generated: "..now(),"Dependencies enabled for this stage: experienceWorks, ProjectMORTIS","Overall session status: "..overall(current),"","FEATURE RESULTS"}
    for index,step in ipairs(steps) do local result=current.results[step.id] or {status="PENDING",note=""}; output[#output+1]=string.format("%02d. [%s] %s | %s | %s",index,result.status,step.id,step.feature,safe(result.note)) end
    output[#output+1]=""; output[#output+1]="COMMAND LOG"
    for index,entry in ipairs(current.commands) do output[#output+1]=string.format("%03d. %s | %s | %s | %s | %s",index,safe(entry.at),safe(entry.command),safe(entry.feature),safe(entry.outcome),safe(entry.detail)) end
    output[#output+1]=""; output[#output+1]="Send this file plus console.txt and screenshots for failed visual checks to development."
    return output
end
local function writeReport(current)
    local factory=rawget(_G,"getFileWriter"); if type(factory)~="function" then return false,"getFileWriter unavailable" end
    local ok,err=pcall(function()
        local writer=factory(RESULT_FILE,true,false); if not writer then error("writer unavailable") end
        for _,line in ipairs(reportLines(current)) do if type(writer.writeln)=="function" then writer:writeln(line) elseif type(writer.write)=="function" then writer:write(line.."\n") else error("writer has no write method") end end
        if type(writer.close)=="function" then writer:close() end
    end)
    return ok,ok and nil or safe(err)
end
local function say(message) print("[medWorks][Test] "..message) end
local function record(current,id,status,note) current.results[id]={status=status,note=safe(note),recordedAt=now()} end
local function finish(current,command,feature,status,detail)
    current.commands[#current.commands+1]={at=now(),command=command,feature=feature,outcome=status,detail=safe(detail)}
    while #current.commands>128 do table.remove(current.commands,1) end
    local saved,errorText=writeReport(current); say(command..": "..status.." "..safe(detail))
    say(saved and ("Results saved to Zomboid/Lua/"..RESULT_FILE) or ("Result export failed: "..safe(errorText)))
    return status=="PASS",detail
end
local function pending(current) for _,step in ipairs(steps) do if not current.results[step.id] then return step end end end

function Harness.auto()
    local current,_,err=session(true); if not current then say(err); return false,err end
    local archive=rawget(_G,"experienceWorks"); local mortis=rawget(_G,"Mortis")
    local dependencies=type(archive)=="table" and type(archive.hasDocument)=="function" and archive.hasDocument("MW-FIELD-001")==true
        and type(mortis)=="table" and type(mortis.Anatomy)=="table" and type(mortis.DetachedParts)=="table"
    local canonical=rawget(_G,"medWorks")==medWorks and medWorks.VERSION==current.modVersion
    local surfaces=type(medWorks.examine)=="function" and type(medWorks.sever)=="function" and type(medWorks.inspectProcedureRecovery)=="function"
    local diagnosticsOk,diagnostics=pcall(ProcedureDiagnostics.snapshot,player())
    local writerOk,writerError=writeReport(current)
    local pass=dependencies and canonical and surfaces and diagnosticsOk and type(diagnostics)=="table" and writerOk
    local detail=string.format("canonical=%s dependencies=%s surfaces=%s diagnostics=%s writer=%s",tostring(canonical),tostring(dependencies),tostring(surfaces),tostring(diagnosticsOk),tostring(writerOk))
    if not pass and writerError then detail=detail.." error="..safe(writerError) end
    record(current,"startup",pass and "PASS" or "FAIL",detail); return finish(current,"medWorksTestAuto()","startup",pass and "PASS" or "FAIL",detail)
end
function Harness.start(reset)
    local current,character,err=session(true); if not current then say(err); return false,err end
    if reset==true then modData(character)[DATA_KEY]=nil; current=session(true) end
    Harness.auto(); local step=pending(current); say("Session started. Enable experienceWorks, ProjectMORTIS, and medWorks only.")
    if step then say("NEXT ["..step.id.."] "..step.instruction) end; return true,current.sessionId
end
function Harness.examine()
    local current,character=session(false); if not current then say("No session; run medWorksTestStart(true)"); return false end
    local ok,report,reason=pcall(medWorks.examine,character,character,{testSession=current.sessionId})
    local pass=ok and type(report)=="table" and type(report.sections)=="table" and #report.sections>0
    local detail=pass and string.format("sections=%d diagnostics=%d",#report.sections,type(report.diagnostics)=="table" and #report.diagnostics or 0) or safe(ok and reason or report)
    if pass then record(current,"examination","PASS",detail.."; confirm displayed/console formatting manually") end
    return finish(current,"medWorksTestExamine()","examination",pass and "PASS" or "FAIL",detail)
end
function Harness.knowledge()
    local current,character=session(false); if not current then say("No session"); return false end
    local archive=rawget(_G,"experienceWorks"); local learned=archive and archive.hasKnowledge and archive.hasKnowledge(character,Knowledge.RECOVERY)==true
    local detail="recoveryKnowledge="..tostring(learned)
    if learned then record(current,"research","PASS",detail) end
    return finish(current,"medWorksTestKnowledge()","research",learned and "PASS" or "BLOCKED",detail)
end
function Harness.reloadStatus()
    local current=session(false); if not current then say("No session"); return false end
    local reloaded=current.runtimeToken~=RUNTIME_TOKEN
    if reloaded then record(current,"persistence","PASS","test session survived a new Lua runtime; confirm recovered region remains absent") end
    return finish(current,"medWorksTestReload()","persistence",reloaded and "PASS" or "BLOCKED",reloaded and "runtime reload observed" or "save/quit/reload still required")
end
function Harness.recordCurrent(status,note)
    local current=session(false); if not current then say("No session"); return false end
    local step=pending(current); if not step then say("All steps already recorded"); return false end
    record(current,step.id,status,note); finish(current,"medWorksTest"..status:sub(1,1)..status:sub(2):lower().."()",step.id,status,note)
    local nextStep=pending(current); if nextStep then say("NEXT ["..nextStep.id.."] "..nextStep.instruction) else say("All steps recorded. Run medWorksTestReport().") end
    return true
end
function Harness.report()
    local current=session(false); if not current then say("No session"); return false end
    say("REPORT BEGIN"); for _,line in ipairs(reportLines(current)) do say(line) end; say("REPORT END")
    local saved,err=writeReport(current); say(saved and ("Results saved to Zomboid/Lua/"..RESULT_FILE) or ("Result export failed: "..safe(err))); return saved,err
end
function Harness.where() say("Windows result file: %USERPROFILE%\\Zomboid\\Lua\\"..RESULT_FILE); return RESULT_FILE end

medWorksTestStart=function(reset) return Harness.start(reset) end
medWorksTestAuto=function() return Harness.auto() end
medWorksTestExamine=function() return Harness.examine() end
medWorksTestKnowledge=function() return Harness.knowledge() end
medWorksTestReload=function() return Harness.reloadStatus() end
medWorksTestPass=function(note) return Harness.recordCurrent("PASS",note) end
medWorksTestFail=function(note) return Harness.recordCurrent("FAIL",note) end
medWorksTestBlocked=function(note) return Harness.recordCurrent("BLOCKED",note) end
medWorksTestReport=function() return Harness.report() end
medWorksTestWhere=function() return Harness.where() end
medWorks.TestHarness=Harness
say("Ready: medWorksTestStart(true); results export to Zomboid/Lua/"..RESULT_FILE)
return Harness
