-- Explicit offline SP realm. The dependency fails closed without an execution
-- side and blocks its own dedicated storage until that contract is verified.
isClient=function()return false end
isServer=function()return false end
local Knowledge=require "medWorks/Knowledge"
local Archive=require "B47ANCEDKnowledgeAndWisdom/API"
local data={}
local player={getModData=function() return data end}
assert(not Knowledge.canRecover(player))
assert(next(data)==nil,"eligibility checks must not create knowledge")
assert(not Archive.completeRead(player,"medWorks.AnatomicalRecoveryManual"))
assert(Archive.completeRead(player,"medWorks.FieldSafetyMagazine"))
assert(not Knowledge.canRecover(player))
assert(Archive.completeRead(player,"medWorks.AnatomicalRecoveryManual"))
assert(Knowledge.canRecover(player))
local inventoryBook=Archive.getDocumentForItem("medWorks.AnatomicalRecoveryManual")
assert(inventoryBook.grantsKnowledge[1]=="medWorks.CorpseRecovery")
local distributions={list={BookstoreBooks={items={}},LibraryBooks={items={}},ArmyStorageMedical={items={}}}}
assert(Archive.applyDistributions(distributions)==6)
assert(Archive.applyDistributions(distributions)==0,"loot registration must be idempotent")
data[Archive.ROOT_KEY]={schemaVersion=999}
assert(not Knowledge.canRecover(player))
SandboxVars={medWorks={RequireRecoveryKnowledge=false}}
assert(Knowledge.canRecover(player))
SandboxVars.medWorks.RequireRecoveryKnowledge=true
assert(not Knowledge.canRecover(player))
print("medWorks physical literature progression, gating and loot checks passed")
