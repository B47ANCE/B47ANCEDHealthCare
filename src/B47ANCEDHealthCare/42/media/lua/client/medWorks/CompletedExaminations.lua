local medWorks=require "medWorks/init"
local Report=require "medWorks/ExaminationReport"
local Results={MAX_PER_EXAMINER=16,MAX_AGE_MILLISECONDS=300000};local stores=setmetatable({},{__mode="k"})
local function now()
    if type(getTimestampMs)~="function"then return nil end
    local ok,value=pcall(getTimestampMs)
    if ok and type(value)=="number"and value==value and value>=0 and value<math.huge then return value end
end
local function copy(value,depth,state)
    local kind=type(value);if kind=="string"then return Report.safeText(value)end
    if kind=="nil"or kind=="boolean"then return value end
    if kind=="number"then return value==value and value~=math.huge and value~=-math.huge and value or nil end
    if kind~="table"then return nil end;depth=(depth or 0)+1;state=state or{nodes=0,seen={}}
    state.nodes=state.nodes+1
    if depth>6 or state.nodes>1024 then state.limited=true;return nil end
    if state.seen[value]then return nil end;state.seen[value]=true
    state.visits=state.visits or 0
    local result={};local count=0;for key,entry in next,value do
        if count>=256 or state.visits>=4096 then state.limited=true;break end
        count=count+1;state.visits=state.visits+1
        if(type(key)=="string"and#key<=64)or(type(key)=="number"and key==math.floor(key)and key>=1 and key<=256)then
            local copied=copy(entry,depth,state);if copied~=nil then result[key]=copied end
        end
    end;state.seen[value]=nil;return result
end
function Results.publish(examiner,patient,report)
    if not examiner or not patient or type(report)~="table"or type(report.sections)~="table"then return false,"INVALID_RESULT"end
    local timestamp=now();if timestamp==nil then return false,"CLOCK_UNAVAILABLE"end
    local budget={nodes=0,seen={},visits=0}
    local value=copy({schemaVersion=rawget(report,"schemaVersion"),sections=rawget(report,"sections"),diagnostics=rawget(report,"diagnostics")},0,budget)
    if not value or type(value.sections)~="table"then return false,"UNSAFE_RESULT"end
    value.presentationLimited=budget.limited or nil
    value.patient=nil;local store=stores[examiner]or{};stores[examiner]=store
    for index=#store,1,-1 do if store[index].patient==patient then table.remove(store,index)end end
    store[#store+1]={patient=patient,completedAt=timestamp,report=value}
    while#store>Results.MAX_PER_EXAMINER do table.remove(store,1)end
    return true
end
function Results.inspect(examiner,patient)
    local store=stores[examiner];if not store or not patient then return nil,"EXAMINATION_REQUIRED"end
    local current=now()
    if current==nil then stores[examiner]=nil;return nil,"EXAMINATION_REQUIRED"end
    for index=#store,1,-1 do local entry=store[index]
        if current<entry.completedAt or current-entry.completedAt>Results.MAX_AGE_MILLISECONDS then table.remove(store,index)
        elseif entry.patient==patient then return copy(entry.report),nil,math.max(0,current-entry.completedAt)end
    end
    return nil,"EXAMINATION_REQUIRED"
end
medWorks.CompletedExaminations=Results;medWorks.getCompletedExamination=Results.inspect
return Results
