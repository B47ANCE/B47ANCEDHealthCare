# Health Care examination report validation

Current version: 0.11.0.

Recorded 2026-10-16. Base source: 0.10.1 commit 245f58e19329d3d23c62c7e1c3a704009d08bbd3. Branch: feat/examination-reports-0.11.0, stacked on feat/health-care-artwork-0.10.1. MINOR: new local report-viewing workflow and stricter presentation/cache sanitization. No persistent schema/item/API/network/sandbox identifier change.

[VERIFIED — source] See EXAMINATION_REPORTS.md for ownership, configuration assessment, limits and actual vanilla UI contracts. Steam build 25485521; engine patch UNKNOWN. API_EVIDENCE_0_11_0.json binds installed vanilla source and current clean sibling checkouts. Three scoped API findings were recorded in the unmanaged local draft library. No raw native bodies or private diagnostic logs are committed.

[TESTED — offline Windows / bundled Python / lupa.lua51]

The new malformed-provider reproduction failed against the old formatter, while existing tests exposed two dependency changes: absent SP realm flags in the literature fixture and the renamed SPXTRM source root. No dependency source was changed; fixture/runner updates reflect those verified contracts. All 20 cases pass after implementation. Dedicated Knowledge & Wisdom storage remains deliberately blocked; an explicit fixture now asserts that guard instead of claiming multiplayer progression works.

Exact commands from the repository root (PowerShell):

```powershell
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/validate_source.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/run_host_tests.py
```

PASS: canonical 0.11.0 with 12 current mirrors; Lua-only 145 source authoring files / 19 modules / exact internal require case / 29 locale key sets; 20/20 Lua 5.1 regressions. Added 52 UI keys plus one menu key per existing locale, all following the English-fallback policy. No claim of 29 translated languages.

An inline Python retention/dependency check verified the retained 0.9.3 and 0.10.1 ZIP SHA-256 and CRC/data, byte-equivalent historical validation/upload/provenance documents, all 52 report keys in 29 locales, and unchanged dependency HEAD/source fingerprints. Prior packages were neither rebuilt nor relabelled. Current inventory declares no 0.11.0 package/manifest and preserves last_distributed_version 0.10.1.

Immediately before staging, Test-PZRepositoryFreshness.ps1 fetched origin and returned REVIEW solely for the intentional feature changes. HEAD and parent upstream were both 245f58e19329d3d23c62c7e1c3a704009d08bbd3 (ahead 0 / behind 0); main ahead 7 / behind 0; no unfinished operations. The new feature branch tracks that parent until its first push establishes its own upstream. No stash/reset/pull/merge/rebase. `git diff --cached --check` PASS; `python scripts/check_public_tree.py` PASS (244 indexed files, zero findings). Targeted staging contains the intended feature, tests, translations and docs only; generated outputs, local authentication state, symlinked configuration and private diagnostics remain excluded. The exact staged/tracked files were reviewed before public push. CI is not configured or claimed.

[RUNTIME GATE] Native PZ UI/SP/hosted/dedicated NOT TESTED for 0.11.0. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Pure local presentation needs no new gameplay transport, but the overall mod's dedicated gates remain in force. Native viewport/font/focus/controller behavior, remote snapshot freshness/consent, recovery arguments/timing/inventory/anatomy sync, save/reload and join/restart remain required. Current dependency multiplayer storage is unavailable and is not bypassed. No build/package, deployment, publish, game/server launch or Steam restart. Retained 0.10.1 distribution is separate historical evidence.
