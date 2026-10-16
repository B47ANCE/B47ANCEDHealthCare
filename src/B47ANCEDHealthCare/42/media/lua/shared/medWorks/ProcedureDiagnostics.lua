local medWorks=require "medWorks/init"
local Diagnostics={MAX_COMPLETED=32,MAX_TEXT=160}

local function text(value)
    local result=tostring(value or ""):gsub("[%c]"," ")
    return #result>Diagnostics.MAX_TEXT and result:sub(1,Diagnostics.MAX_TEXT).."…" or result
end
local function copyKeys(values)
    local result={}
    for index,value in ipairs(type(values)=="table" and values or{})do
        if index>16 then break end
        result[index]=text(value)
    end
    return result
end
local function modData(patient)
    if not patient or not patient.getModData then return nil end
    local ok,data=pcall(function()return patient:getModData()end)
    return ok and type(data)=="table" and data or nil
end

function Diagnostics.snapshot(patient)
    local report={schemaVersion=1,requiresInspection=false,active={},completed={},severRecovery=nil}
    local recovery,recoveryError=medWorks.inspectProcedureRecovery(patient)
    if recovery then
        report.requiresInspection=recovery.requiresInspection==true
        for _,entry in ipairs(recovery.active or{})do
            if #report.active>=32 then break end
            report.active[#report.active+1]={operationId=text(entry.operationId),procedureId=text(entry.procedureId),
                status=text(entry.status),lockKeys=copyKeys(entry.lockKeys)}
        end
    else report.error=text(recoveryError or"procedure state unavailable")end

    local data=modData(patient)
    local root=data and data.medWorks
    local ids={}
    for operationId in pairs(type(root)=="table"and type(root.completedProcedures)=="table"and root.completedProcedures or{})do
        if type(operationId)=="string"then ids[#ids+1]=operationId end
    end
    table.sort(ids)
    local first=math.max(1,#ids-Diagnostics.MAX_COMPLETED+1)
    for index=first,#ids do
        local operationId=ids[index];local record=root.completedProcedures[operationId]
        if type(record)=="table"then report.completed[#report.completed+1]={operationId=text(operationId),
            procedureId=text(record.procedureId),status=text(record.status),reason=text(record.reason),
            lockKeys=copyKeys(record.lockKeys)}end
    end
    local sever=data and data.medWorksSeverRecovery
    if type(sever)=="table"and sever.requiresInspection==true then
        report.requiresInspection=true
        report.severRecovery={regionId=text(sever.regionId),reason=text(sever.reason)}
    end
    return report
end

function Diagnostics.format(report)
    if type(report)~="table"then return"medWorks diagnostics unavailable"end
    local lines={"medWorks procedure diagnostics",
        "Inspection required: "..(report.requiresInspection and"YES"or"no"),
        "Active reservations: "..tostring(#(report.active or{}))}
    for _,entry in ipairs(report.active or{})do
        lines[#lines+1]=entry.operationId.." | "..entry.procedureId.." | "..entry.status
        if #entry.lockKeys>0 then lines[#lines+1]="Locks: "..table.concat(entry.lockKeys,", ")end
    end
    if report.severRecovery then lines[#lines+1]="Sever recovery: "..report.severRecovery.regionId.." | "..report.severRecovery.reason end
    lines[#lines+1]="Recent completed/terminal records: "..tostring(#(report.completed or{}))
    for _,entry in ipairs(report.completed or{})do
        local line=entry.operationId.." | "..entry.procedureId.." | "..entry.status
        if entry.reason~=""then line=line.." | "..entry.reason end
        lines[#lines+1]=line
    end
    if report.error then lines[#lines+1]="Error: "..report.error end
    lines[#lines+1]="Read-only report. Recovery resolution requires authoritative operator action."
    return table.concat(lines," <LINE> ")
end

medWorks.ProcedureDiagnostics=Diagnostics
return Diagnostics
