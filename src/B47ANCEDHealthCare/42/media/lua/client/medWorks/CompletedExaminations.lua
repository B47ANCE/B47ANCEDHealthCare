local medWorks=require "medWorks/init"
local Results={MAX_PER_EXAMINER=16,MAX_AGE_MILLISECONDS=300000};local stores=setmetatable({},{__mode="k"})
local function now()local ok,value=pcall(type(getTimestampMs)=="function"and getTimestampMs or function()return 0 end);return ok and tonumber(value)or 0 end
local function copy(value,depth,state)
    local kind=type(value);if kind=="nil"or kind=="boolean"or kind=="string"then return value end
    if kind=="number"then return value==value and value~=math.huge and value~=-math.huge and value or nil end
    if kind~="table"then return nil end;depth=(depth or 0)+1;state=state or{nodes=0,seen={}}
    state.nodes=state.nodes+1;if depth>6 or state.nodes>1024 or state.seen[value]then return nil end;state.seen[value]=true
    local result={};local count=0;for key,entry in pairs(value)do
        if count>=256 then break end
        if(type(key)=="string"and#key<=64)or(type(key)=="number"and key==math.floor(key)and key>=1 and key<=256)then
            local copied=copy(entry,depth,state);if copied~=nil then result[key]=copied;count=count+1 end
        end
    end;state.seen[value]=nil;return result
end
function Results.publish(examiner,patient,report)
    if not examiner or not patient or type(report)~="table"or type(report.sections)~="table"then return false,"INVALID_RESULT"end
    local value=copy(report);if not value then return false,"UNSAFE_RESULT"end
    value.patient=nil;local store=stores[examiner]or{};stores[examiner]=store
    for index=#store,1,-1 do if store[index].patient==patient then table.remove(store,index)end end
    store[#store+1]={patient=patient,completedAt=now(),report=value}
    while#store>Results.MAX_PER_EXAMINER do table.remove(store,1)end
    return true
end
function Results.inspect(examiner,patient)
    local store=stores[examiner];if not store or not patient then return nil,"EXAMINATION_REQUIRED"end
    local current=now()
    for index=#store,1,-1 do local entry=store[index]
        if current>0 and entry.completedAt>0 and current-entry.completedAt>Results.MAX_AGE_MILLISECONDS then table.remove(store,index)
        elseif entry.patient==patient then return copy(entry.report),nil,math.max(0,current-entry.completedAt)end
    end
    return nil,"EXAMINATION_REQUIRED"
end
medWorks.CompletedExaminations=Results;medWorks.getCompletedExamination=Results.inspect
return Results
