local mode,api,activeSource
local items={}
local detached=false
local calls=0
local destination={}
function destination:contains(item) return items[item]==true end
function destination:Remove(item) if mode~="remove-noop" then items[item]=nil end end
function destination:AddItem(item)
    if mode=="add-noop" then return end
    items[item]=true
    if mode=="add-throw" then error("inserted then threw") end
    if mode=="reenter" then
        assert(not api.sever(activeSource,"hand",self),"overlapping source must be locked")
    end
end
function destination:getItems()
    local list={}
    for item,present in pairs(items) do if present then list[#list+1]=item end end
    return {size=function() return #list end,get=function(_,index) return list[index+1] end}
end
instanceItem=function(fullType) return {fullType=fullType} end
local mortis={Authority={canWriteCanonicalState=function() return true end},
    Anatomy={getRegion=function(_,region) return {attached=not detached},{severable=true},region end,
        sever=function()
            calls=calls+1
            if mode=="reject" or mode=="remove-noop" then return nil,"rejected" end
            if mode=="sever-throw" then detached=true; error("uncertain commit") end
            detached=true
            return {regionId="leftArm"}
        end},
    DetachedParts={capture=function(_,region) return {schemaVersion=1,sourceStableId="source-1",regionId=region} end,
        write=function(item,record) if mode=="write-throw" then error("write failed") end item.record=record return true end,
        read=function(item) return item.record end},
    Events={emit=function() error("listener") end}}
package.loaded["Mortis/init"]=mortis
api=require "medWorks/init"
for _,scenario in ipairs({"write-throw","add-noop","add-throw","reject"}) do
    mode=scenario; activeSource={}; detached=false; calls=0
    assert(not api.sever(activeSource,"leftArm",destination))
    assert(not next(items) and not detached,"failure must not leave output or mutate anatomy")
    if scenario~="reject" then assert(calls==0) end
    mode="ok"
    assert(api.sever(activeSource,"leftArm",destination),"recovered source must unlock")
    items={}
end
mode="reenter"; activeSource={}; detached=false; calls=0
assert(api.sever(activeSource,"leftArm",destination))
assert(calls==1)
items={}
for _,scenario in ipairs({"remove-noop","sever-throw"}) do
    local data={}
    mode=scenario; activeSource={getModData=function() return data end}; detached=false
    local item,reason=api.sever(activeSource,"leftArm",destination)
    assert(not item and reason)
    mode="ok"
    assert(not api.sever(activeSource,"leftArm",destination),"uncertain output/commit must quarantine source")
    assert(data.medWorksSeverRecovery.requiresInspection)
    local restoredSource={getModData=function() return data end}
    assert(not api.sever(restoredSource,"leftArm",destination),"persisted quarantine must survive a new object")
    local report=api.inspectSeverRecovery(activeSource,destination)
    assert(report.requiresInspection and report.regionId=="leftArm")
    mode="ok"
    local resolved,resolveReport=api.resolveSeverRecovery(activeSource,destination)
    assert(resolved and resolveReport.resolved and data.medWorksSeverRecovery==nil,
        "recovery resolution failed: "..tostring(resolveReport and resolveReport.status or resolveReport))
    if scenario=="remove-noop" then
        assert(not next(items),"verified recovery must remove the rolled-back staged output")
        detached=false
        assert(api.sever(activeSource,"leftArm",destination),"resolved attached source may retry")
    else
        assert(not api.sever(activeSource,"leftArm",destination),"committed detached region must remain non-repeatable")
    end
    items={}
end
print("medWorks staged sever output, rollback, overlap and uncertain-commit checks passed")
