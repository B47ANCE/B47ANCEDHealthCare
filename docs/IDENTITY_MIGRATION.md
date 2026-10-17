# B47ANCE'd Health Care identity migration

Version 0.9.3, approved 2026-10-16. Display name: B47ANCE'd Health Care. Activation Mod ID and package folder: `B47ANCEDHealthCare`. Existing Workshop item: `3788592396`. No new item or visibility change.

## Configuration and consumers

Replace `medWorks` with `B47ANCEDHealthCare` in server/client mod lists and dependency `require=` metadata. Keep the existing Workshop subscription ID. Health Care now requires `ProjectMORTIS` and `B47ANCEDKnowledgeAndWisdom`; the removed `experienceWorks/*` imports are updated to that dependency's current public API. Optional Spectrum retains its lightWorks Mod ID and API.

Nightfall currently declares medWorks in its mod.info. It needs a separate source/version/publication update before it can resolve this renamed activation ID. This task does not edit or publish that separate project. No old-ID activation shim is shipped.

## Persisted and provider contracts

The `medWorks/*` Lua module paths, `_G.medWorks`, `medWorks.*` items/procedure/knowledge IDs, ownership tags, `medWorks` transport module, ModData keys and `SandboxVars.medWorks` identifiers intentionally remain stable. They are not activation IDs. The package folder changed, but the Lua module subdirectories did not. No duplicate runtime or dual API is introduced. The sandbox page's translated display name changes in all 29 fallback locales.

The test report identifies the new Mod ID and writes `B47ANCED Health Care Test Results.txt`; debug command names and the existing test-session ModData key remain stable. Existing-session reset is required for a new-version test.

## Recovery and proof

Use a disposable copy after backing up saves. Native reload, corpse inventory/provenance, new-client activation, remote consent, join/rejoin and dedicated restarts require human testing. Offline tests cannot prove the Mod ID migration in game. The verified pre-edit snapshot and prior 0.9.2 package are retained locally; historical release hashes are unchanged. Rollback means restoring the old subscription content and activation configuration together; no automatic save downgrade is claimed. G7 and stable G8 remain BLOCKED.
