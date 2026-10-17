# Health Care sunburn self-care validation

Current version: 0.11.0.

2026-10-16. Base 0c7fd8defe24d859db69d585c7a3f0b5f9649c76 (0.10.0), isolated feature/spectrum-sunburn-treatment checkout. MINOR adds optional native timed self-care; retained medWorks imports/items/save/protocol identifiers remain compatible. Original artwork checkout and its work are unchanged. Prior docs/VALIDATION_0_10_0.md remains exact historical evidence.

Implemented: Base.Coldpack from main inventory, living non-driving self only, no client commit RPC, native shared-action completion and server-owned sandbox timing/dose, existing patient procedure lock and authority gate, fresh server UUID and consumed input before canonical Spectrum mutation. The public SunburnCare API is trusted server code, not permission for clients to bypass native timing. Each action completion is terminal; a later action can retry a proven untouched pack after recovery.

Recovery persists medWorksSunburnCareRecovery before native removal. Exceptions preserve the Medical uncertain lock and block more care. inspect(actor) returns copied scalar diagnostics. resolve(actor,item) clears only a positive canonical Spectrum receipt (completed) or exact retained pack plus unchanged recorded dose (failed). Missing pack with no retained receipt cannot be refunded/unlocked automatically; use a disposable-save backup/operator inspection. Spectrum retains only 32 treatment receipts; absence is not proof that an old treatment never happened. Existing Medical operator recovery alone does not clear the supply marker.

SandboxVars.medWorks: EnableSunburnCare true; SunburnCareSeconds 30, integer 5-600; SunburnCareReduction 0.10, double 0.01-0.50. Server reads/validates settings; malformed values use defaults, numeric values clamp. All 29 locale folders have matching labels/tooltips/menu keys with explicit English fallback where untranslated. No recipe/art asset is introduced; the consumed vanilla Coldpack is an intentional gameplay approximation, not a clinical simulation.

[TESTED, offline Windows / Python / Lua 5.1] 20 host regression files PASS, including actual Spectrum commit interruption and receipt recovery; optional absence, client refusal, callback replay, removed/nested supply, sandbox disable/bounds, after-removal failure/quarantine and proven pre-removal failure resolution. Source syntax, internal require case, canonical version, localization, artwork and Workshop identity/text checks PASS. Test fixture explicitly supplies SP realm predicates to the changing Knowledge dependency; it does not bypass production authority. Native objects are stubs.

Commands:

```text
python scripts/check_versions.py
python scripts/validate_source.py
python scripts/run_host_tests.py --dependencies ../..
python scripts/check_public_tree.py
git diff --check
git diff --cached --check
```

Dependencies are selected from the verified sibling root two levels above this worktree; Spectrum source is now B47ANCEDSPXTRM/src/B47ANCEDSPXTRM, with lightWorks Lua imports preserved. Exact full current source probes are retained by SPXTRM's validation records. Knowledge's current dedicated storage path is explicitly blocked upstream; host SP checks do not establish that dependency's multiplayer readiness.

[RUNTIME GATE] Actual native-action dispatch/serialization/timing, remote inventory synchronization, save/reload and crash interruptions, observer reentry and dedicated authority/late join/restart remain NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No package, deploy, game/server launch or upload.
