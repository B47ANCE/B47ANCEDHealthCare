local Archive=require "B47ANCEDKnowledgeAndWisdom/API"
local Knowledge={RECOVERY="medWorks.CorpseRecovery"}
local knowledgeDefinitions={
    {id="medWorks.FieldSafety",owner="medWorks",title="Field Care Safety"},
    {id=Knowledge.RECOVERY,owner="medWorks",title="Anatomical Recovery"},
}
for _,definition in ipairs(knowledgeDefinitions) do
    if not Archive.hasKnowledgeDefinition(definition.id) then Archive.registerKnowledge(definition) end
end
local definitions={
    {id="MW-FIELD-001",itemType="medWorks.FieldSafetyMagazine",project="medWorks",
        category="MEDICAL",classification="PUBLIC",title="Field Care: Safe Handling",tier=1,
        distribution={BookstoreBooks=0.3,LibraryBooks=0.2,ArmyStorageMedical=0.1},
        grantsKnowledge={"medWorks.FieldSafety"},
        content={"A field-care magazine covering protective equipment, clean work areas, and the risks of handling contaminated remains. This issue prepares the reader for the anatomical recovery manual; it does not unlock surgery on living patients."}},
    {id="MW-ANATOMY-001",itemType="medWorks.AnatomicalRecoveryManual",project="medWorks",
        category="MEDICAL",classification="PUBLIC",title="Anatomical Recovery Manual",tier=2,
        distribution={BookstoreBooks=0.1,LibraryBooks=0.08,ArmyStorageMedical=0.05},
        prerequisiteKnowledge={"medWorks.FieldSafety"},grantsKnowledge={Knowledge.RECOVERY},
        content={"A technical reference for identifying anatomical regions and preserving the identity of recovered specimens. Study the field-safety issue first. Completion unlocks B47ANCE'd Health Care corpse recovery, not clinical amputation, treatment, or rendered limb removal."}},
}
for _,definition in ipairs(definitions) do
    if not Archive.hasDocument(definition.id) then Archive.registerDocument(definition) end
end
function Knowledge.canRecover(character)
    if SandboxVars and SandboxVars.medWorks and SandboxVars.medWorks.RequireRecoveryKnowledge==false then return true end
    local ok,learned=pcall(Archive.hasKnowledge,character,Knowledge.RECOVERY)
    if ok and learned==true then return true end
    return false,"Read Field Care: Safe Handling, then the Anatomical Recovery Manual."
end
return Knowledge
