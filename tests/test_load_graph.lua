local clientModules={
    "medWorks/init","medWorks/Knowledge","medWorks/Examination",
    "medWorks/ExaminationReport","medWorks/ExaminationAction","medWorks/ExaminationMenu",
    "medWorks/ProcedureDiagnostics","medWorks/ProcedureDiagnosticViewer",
    "medWorks/SunburnTreatment","medWorks/CorpseRecoveryClient","medWorks/CorpseMenu",
}
local serverModules={
    "medWorks/init","medWorks/Knowledge","medWorks/Examination",
    "medWorks/ProcedureDiagnostics","medWorks/SunburnTreatment","medWorks/CorpseRecoveryServer",
}

local function exercise(path,modules)
    local loaded={}
    for _,name in ipairs(modules) do
        package.loaded[name]=nil
        package.preload[name]=function() loaded[name]=(loaded[name] or 0)+1; return {} end
    end
    dofile(path)
    for _,name in ipairs(modules) do
        assert(loaded[name]==1,"production loader omitted or duplicated "..name)
        package.preload[name]=nil
        package.loaded[name]=nil
    end
end

exercise(arg[1],clientModules)
exercise(arg[2],serverModules)

print("medWorks client/server production load-graph checks passed")
