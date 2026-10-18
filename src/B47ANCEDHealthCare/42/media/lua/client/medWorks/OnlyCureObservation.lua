-- Independent, read-only interoperability adapter. See ONLY_CURE_PLUS_OBSERVATION.md.
local medWorks = require "medWorks/Examination"
if medWorks.OnlyCureObservation then return medWorks.OnlyCureObservation end

local Observation = {}
local SUPPORTED_VERSION = "3.2.0"
-- Vanilla human part identifiers; no topology conversion or clinical data export.
local PARTS = {"Hand_L", "ForeArm_L", "UpperArm_L", "Hand_R", "ForeArm_R", "UpperArm_R",
    "Foot_L", "LowerLeg_L", "UpperLeg_L", "Foot_R", "LowerLeg_R", "UpperLeg_R"}
local GROUPS = {"Top_L", "Top_R", "Bottom_L", "Bottom_R"}

local function call(object, name, ...)
    if not object then return nil end
    local ok, method = pcall(function() return object[name] end)
    if not ok or type(method) ~= "function" then return nil end
    local success, value = pcall(method, object, ...)
    if success then return value end
end

local function localSelf(examiner, patient)
    if type(isServer) ~= "function" or type(isClient) ~= "function" then return false end
    local serverOK, server = pcall(isServer)
    local clientOK, client = pcall(isClient)
    if not serverOK or server ~= false or not clientOK or type(client) ~= "boolean" then return false end
    if not patient or examiner ~= patient or type(getSpecificPlayer) ~= "function" then return false end
    local index = call(patient, "getPlayerNum")
    if type(index) ~= "number" or index ~= math.floor(index) or index < 0 or index > 3 then return false end
    local ok, current = pcall(getSpecificPlayer, index)
    return ok and current == patient and call(patient, "isDead") == false
end

local function activation()
    if type(getActivatedMods) ~= "function" then return "detection-unavailable" end
    local ok, mods = pcall(getActivatedMods)
    if not ok then return "detection-unavailable" end
    local plus, original = call(mods, "contains", "TheOnlyCurePlus"), call(mods, "contains", "TheOnlyCure")
    if type(plus) ~= "boolean" or type(original) ~= "boolean" then return "detection-unavailable" end
    if not plus then return "inactive" end
    return original and "conflicting-mod" or "active"
end

local function capabilities(status, version)
    return {status = status, version = version, canObserve = status == "ready", scope = "local-self"}
end

local function shape(dc)
    if type(dc) ~= "table" or rawget(dc, "isDataReady") ~= true then return nil end
    local data = rawget(dc, "tocData")
    local limbs = type(data) == "table" and rawget(data, "limbs")
    local prostheses = type(data) == "table" and rawget(data, "prostheses")
    if type(limbs) ~= "table" or type(prostheses) ~= "table" then return nil end
    -- Validate only the consumed structural booleans. Never initialize missing records.
    for _, name in ipairs(PARTS) do
        local limb = rawget(limbs, name)
        if type(limb) ~= "table" or type(rawget(limb, "isCut")) ~= "boolean" then return nil end
    end
    for _, name in ipairs(GROUPS) do
        local group = rawget(prostheses, name)
        if type(group) ~= "table" or type(rawget(group, "isProstEquipped")) ~= "boolean" then return nil end
    end
    return data, limbs, prostheses
end

local function probe(examiner, patient)
    if not localSelf(examiner, patient) then return capabilities("not-local-self") end
    local active = activation()
    if active ~= "active" then return capabilities(active) end
    local ok, api = pcall(require, "TOC/API")
    if not ok or type(api) ~= "table" then return capabilities("interface-unavailable") end
    local version = rawget(api, "version")
    if version ~= SUPPORTED_VERSION then return capabilities("unsupported-version") end
    if type(rawget(api, "isCut")) ~= "function" or type(rawget(api, "hasPart")) ~= "function" then
        return capabilities("interface-unavailable", version)
    end
    local loaded, controller = pcall(require, "TOC/Controllers/DataController")
    if not loaded or type(controller) ~= "table" or type(rawget(controller, "GetReady")) ~= "function" then
        return capabilities("interface-unavailable", version)
    end
    local username = call(patient, "getUsername")
    if type(username) ~= "string" or #username == 0 or #username > 128 then return capabilities("invalid-data", version) end
    local ready, dc = pcall(rawget(controller, "GetReady"), username)
    if not ready then return capabilities("query-failed", version) end
    if dc == nil then return capabilities("not-ready", version) end
    if type(dc) ~= "table" or rawget(dc, "username") ~= username or not shape(dc) then
        return capabilities("invalid-data", version)
    end
    return capabilities("ready", version), api, controller, dc, username
end

function Observation.getCapabilities(examiner, patient)
    local result = probe(examiner, patient)
    return result
end

function Observation.capture(examiner, patient)
    local state, api, controller, dc, username = probe(examiner, patient)
    local result = {kind = "only-cure-self", schemaVersion = 1, scope = "local-self",
        status = state.status, version = state.version, parts = {}}
    if not state.canObserve then return result end
    local data, limbs, prostheses = shape(dc)
    local cutBefore, prostBefore = {}, {}
    for _, name in ipairs(PARTS) do cutBefore[name] = rawget(rawget(limbs, name), "isCut") end
    for _, name in ipairs(GROUPS) do prostBefore[name] = rawget(rawget(prostheses, name), "isProstEquipped") end
    for _, name in ipairs(PARTS) do
        local cutOK, cut = pcall(rawget(api, "isCut"), patient, name)
        local availableOK, available = pcall(rawget(api, "hasPart"), patient, name)
        if not cutOK or not availableOK then result.status = "query-failed"; break end
        if type(cut) ~= "boolean" or type(available) ~= "boolean" or cut ~= cutBefore[name]
            or (not cut and not available) then result.status = "invalid-data"; break end
        result.parts[#result.parts + 1] = {type = name, lossReported = cut, supportReported = cut and available}
    end
    local ready, current = pcall(rawget(controller, "GetReady"), username)
    local currentData, currentLimbs, currentProstheses = shape(dc)
    if not ready or current ~= dc or currentData ~= data or rawget(api, "version") ~= SUPPORTED_VERSION
        or rawget(dc, "username") ~= username or call(patient, "getUsername") ~= username
        or not localSelf(examiner, patient) or activation() ~= "active" then result.status = "not-ready" end
    if result.status == "ready" then
        for _, name in ipairs(PARTS) do
            if rawget(rawget(currentLimbs, name), "isCut") ~= cutBefore[name] then result.status = "not-ready" end
        end
        for _, name in ipairs(GROUPS) do
            if rawget(rawget(currentProstheses, name), "isProstEquipped") ~= prostBefore[name] then result.status = "not-ready" end
        end
    end
    if result.status ~= "ready" then result.parts = {} end
    return result
end

medWorks.OnlyCureObservation = Observation
medWorks.registerExaminationProvider {
    id = "medWorks.OnlyCureSelf", owner = "medWorks", priority = 10,
    supports = function(examiner, patient, context)
        return not (context and context.remoteObservation == true) and localSelf(examiner, patient)
            and activation() ~= "inactive"
    end,
    examine = function(examiner, patient) return Observation.capture(examiner, patient) end,
}
return Observation
