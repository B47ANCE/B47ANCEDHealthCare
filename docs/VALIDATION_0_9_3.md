# Health Care validation

Current version: 0.9.3.

Recorded 2026-10-16. The requested 0.9.3 PATCH version includes an explicit activation-ID break; see IDENTITY_MIGRATION.md.

[VERIFIED] Public repository B47ANCE/B47ANCEDHealthCare; authorized legacy 0.9.2 baseline commit 2e2aa07f377fb5d13268356e59a249e56abc9cf0. Authoritative source src/B47ANCEDHealthCare. Existing Workshop item 3788592396; no new item or visibility change. Source/stale staging and the prior package were backed up and verified before edits. Historical dist files remain unchanged.

[TESTED — offline, Python 3 / lupa.lua51 on Windows] Exact commands from the repository root:

```text
python scripts/check_versions.py
python scripts/validate_source.py
python scripts/run_host_tests.py
```

All 11 declared current version mirrors/identities PASS. Source checks PASS: 115 Lua-only authoring files, 18 Lua modules parsed, internal requires have exact case, 29 translation locales have complete matching fallback keys, current sandbox display labels match, declared icon/poster PNGs exist, and Workshop text carries the correct item/status with actual paragraphs. The runtime payload excludes the empty authoring .keep file.

All 15 existing Lua host regressions PASS: completed examination isolation, corpse recovery, client/server transport, examination providers/action, production load graph, diagnostics, procedure locks/replay/recovery, physical knowledge progression, sandbox ownership, sever transaction/authority, optional Spectrum sunburn integration, and debug harness export. Current Knowledge & Wisdom production API/Progression imports are exercised. Dependencies are sibling checkouts; these tests do not run native engine inventories, timing, serialization or networking.

The first runner attempt produced 14/15 because the newly written runner forced isDebugEnabled=true, enabling a second admin diagnostics option in the examination-menu test. Removing that runner-only override restored the original host environment; 15/15 then passed. Production examination/authority code was not changed to satisfy the test.

[VERIFIED — source diff] Runtime changes are activation metadata, two current dependency import paths, version, presentation strings/test export and byte-for-byte reuse of the supplied thumbnail as the missing version-local poster. Lua module/API, item, knowledge/procedure owner, network, ModData and server sandbox identifiers stay medWorks. No custom Java/native payload. Nightfall's separate require=medWorks metadata still needs updating before consuming this activation ID.

Public staging audit command: python scripts/check_public_tree.py after targeted git add. No authentication, local configuration, generated package/staging, diagnostics or linked global tools may enter the public index.

Current packaging commands: python scripts/package_project.py; python scripts/package_project.py --verify; python scripts/prepare_workshop.py. Run after the reviewed source commit and verified push. Their output binds package/staging hashes to the exact release-source commit, validates CRC, paths, duplicates, case and actual contents, and produces a separate VDF for existing App 108600/item 3788592396. Historical Contents is never an input. Package creation/publication results are recorded separately after execution; this paragraph is not a pre-claimed package or upload PASS.

Installed appmanifest evidence: app 108600 buildid 25485521, public branch. Runtime minimum remains 42.20.3. The current native game version string has not been verified by launch; historical API audits remain tied to their original fingerprints.

[RUNTIME GATE] PZ native/SP/hosted/dedicated NOT TESTED for 0.9.3. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. `python scripts/check_versions.py --release` intentionally rejects stable G8. A labelled MP test upload proves distribution only. No local deployment, game/server launch or server mutation is part of this work.
