# Health Care development validation

Current version: 0.10.0.

Recorded 2026-10-16. Source base: 0.9.3 e129d7fb1e96e8c1626ce45021b4bce62fe5cb7a. Development branch: feat/authoritative-recovery-0.10.0, stacked on feat/health-care-0.9.3. MINOR: native action/completion and procedure integration contracts tightened; legacy direct recovery commits reject. No persistent schema or public item/Mod ID rename.

[TESTED — offline, Windows / bundled Python / lupa.lua51]

```text
python scripts/check_versions.py
PASS: 0.10.0, 12 current mirrors and identities

python scripts/validate_source.py
PASS: Lua-only source, 115 authoring files, 18 modules, exact internal requires,
29 matching English-fallback locale key sets, artwork and current Workshop drafts

python scripts/run_host_tests.py
PASS: 18/18 isolated Lua 5.1 regressions

python -m py_compile scripts/check_versions.py scripts/validate_source.py scripts/package_project.py
PASS
```

Baseline 0.9.3's original 15 cases passed. New reproductions initially failed for save writes during inspection and instant legacy recovery commands. A separate isolated probe of the old procedure source executed a substituted provider once; the current source executes it zero times. These are host reproductions, not observed PZ incidents. New cases cover procedure/resource/replay/patient binding, detached token lock arrays, validation and lock-key reentry, read-only/malformed persistence, native callback selection and unit conversion, and disabled legacy commit paths. Existing authority, canonical sever/rollback/quarantine, knowledge, optional integration, observation, sandbox and load-graph tests pass.

[VERIFIED — source] Installed Steam build 25485521; full engine patch UNKNOWN. Current Lua/class fingerprints and control-flow findings are in API_EVIDENCE_0_10_0.json. Native action metadata/bytecode was read without loading the JVM or game. Vanilla shared bandaging and local medical-check presentation anchor the callback-side design. No raw native bodies or private logs are committed. A reusable finding was recorded in the unmanaged local PZ API draft catalog, not the managed shared catalog.

Settings migration: the retired ExaminationMaxBodyParts option is ignored; old saved values are not deleted. Internal 32/64 traversal budgets and bounded provider override remain. Existing duration bounds/defaults are retained; seconds convert to 50 native action units. Native moodle/speed/pause and live settings-change behavior remain runtime gates.

Persistence: schema 1 remains. Diagnostic inspection creates no data. Absent optional maps initialize only on authoritative writes; malformed maps/records are preserved and rejected. No real saves were read or modified. Crash-interrupted executing reservations stay safely blocked pending a future explicit recovery contract; no automatic unlock/rollback/retry claim.

[VERIFIED — retention] No new package/staging was generated. Retained 0.9.3 ZIP SHA-256 remains 057f52568dab18a2e6c64d151856ecc498e75464fbf1ac882564f2e177ab25ed. The named 0.9.3 validation/upload/provenance records are byte-equivalent to their recorded Git versions. Current inventory explicitly declares no 0.10.0 package or release manifest; older artifact evidence is historical.

Public push checks: git diff --cached --check PASS; python scripts/check_public_tree.py PASS (204 indexed files, zero findings) after targeted staging. The staged/tracked source and docs were inspected for credentials, raw diagnostics, generated outputs and private settings. Fresh fetch confirmed HEAD matched the parent feature branch e129d7f, with main ancestry ahead 3 / behind 0 and no unfinished operations. No reset/stash/merge/rebase. CI is not configured and is not claimed.

[RUNTIME GATE] Native SP/hosted/dedicated NOT TESTED for 0.10.0. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No game/server launch, local deployment, package build, Workshop update or Steam restart. Prior publish/restart authorization is not reused for this development request. Next human tests: native corpse/tool argument reconstruction, real action duration/cancellation, exact output/replication, save/reload/restart, join/rejoin, remote snapshot/observer isolation and two practitioners on disposable fixtures.
