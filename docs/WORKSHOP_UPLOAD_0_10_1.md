# Health Care 0.10.1 Workshop MP test distribution

[VERIFIED — distribution, 2026-10-16] The explicitly requested update to existing Workshop item **3788592396**, App ID **108600**, committed successfully through cached-login SteamCMD. Submitted title: **B47ANCE'd Health Care**; Mod ID **B47ANCEDHealthCare**. One upload attempt. No new item. The descriptor includes the supplied preview; visibility/tags are omitted to preserve existing settings.

- Published source commit: `042673cb25a7eddf2a1536a871ded89ca562c837` on `feat/health-care-artwork-0.10.1`.
- Public source: https://github.com/B47ANCE/B47ANCEDHealthCare ; review PR: https://github.com/B47ANCE/B47ANCEDHealthCare/pull/3 . No main merge or stable tag.
- Canonical text: WORKSHOP_DESCRIPTION.txt, WORKSHOP_CHANGE_NOTE.txt; canonical package descriptor: workshop.txt. Text covers changes since the last distributed 0.9.3 build, with real paragraph breaks, source link, testing label and known limitations. Live page comparison was unavailable; retained 0.9.3 canonical text was compared.
- Generated package: `dist/B47ANCEDHealthCare-0.10.1-workshop-ready.zip`; SHA-256 `981a55b05941cd60b1cbdf9884fc1f3aa0133f89a228502e237318bcb68df6c5`.
- Staging: `dist/workshop-0.10.1`, containing `Contents/mods/B47ANCEDHealthCare/42`.
- Generated upload descriptor: `dist/B47ANCEDHealthCare-0.10.1.vdf`; SHA-256 `b7422696d6a673b16f952c912b741c5cf59a863326fabd4a8434ea1479f38788`.
- Manifest: dist/RELEASE_0_10_1.json; sanitized public copy: RELEASE_PROVENANCE_0_10_1.json. Per-file source hashes, commit, build and testing status are bound in both records.
- Preview/poster SHA-256: `247793bab8b3cf86b0f38b1a93b4e2cfe442ff7b31b37a366a819d2e6cae579c`; 512x512 RGB PNG, 308,715 bytes. Original input retained separately; icon unchanged.
- SteamCMD exit **0**, cached login confirmed: **True**; actual output reached **Preparing update**, **Uploading content**, **Committing update...Success.** No raw authentication diagnostics or local logs are committed.
- Steam desktop: **BLOCKED: graceful shutdown timed out; no process killed**. No game/server launch, local deployment or server mutation.

[TESTED — offline Windows / bundled Python / Lua 5.1] Exact commands from repository root, using C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe:

```text
python scripts/check_versions.py
python scripts/validate_source.py
python scripts/run_host_tests.py
python scripts/package_project.py --steam-build-id 25485521
python scripts/package_project.py --verify
python scripts/prepare_workshop.py
git diff --cached --check
python scripts/check_public_tree.py
```

PASS: 12 current version mirrors/identity; Lua-only 115 source authoring files / 18 modules / 29 fallback locale sets; 18/18 host regressions; 116 exact package/staging files; CRC/data, safe paths, no duplicate/case collisions, correct require paths, per-file hashes and committed source binding. VDF round-trip verified exact item/App/version, full-frame preview, real paragraphs, omitted visibility/tags. UTF-8 description 4,186 bytes, changes 1,318 bytes. The public index was audited before the source push; final evidence index checked separately before push. CI is not configured or claimed.

[VERIFIED — freshness/provenance] Before packaging: HEAD and upstream `042673cb25a7eddf2a1536a871ded89ca562c837`, ahead 0 / behind 0, clean, main ahead 6 / behind 0; no unfinished Git operation. The upload helper fetched again and required the same source SHA, upstream, clean tree and main ancestry. Installed Steam build ID **25485521** rechecked from the installed app manifest; exact engine patch remains UNKNOWN. Minimum required game version **42.20.3** is metadata, not runtime proof.

[VERIFIED — retention] All **1096** pre-existing artifact/staging file hashes match the pre-upload ledger. The retained 0.9.3 ZIP remains SHA-256 057f52568dab18a2e6c64d151856ecc498e75464fbf1ac882564f2e177ab25ed. Older source/validation/distribution evidence is preserved; no cleanup or relabelling occurred.

[UNKNOWN — live view] Anonymous metadata result: **9**. Metadata/page verification: **UNAVAILABLE: anonymous API returned no accessible item metadata; visibility unchanged by descriptor**. Subscriber download and actual in-game artwork display remain NOT TESTED. SteamCMD commit success is upload evidence only; it does not prove subscription refresh, visibility or native gameplay.

**MP testing build - dedicated multiplayer NOT TESTED.** Native SP/hosted/dedicated NOT TESTED; G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. Authority is source-audited and fail-closed, while native corpse/tool argument reconstruction, real timing/cancellation, inventory/anatomy replication, simultaneous actors, save/reload, join/rejoin and restarts remain runtime gates. Clinical treatments and corpse limb visuals are unfinished. Nightfall still needs its separate dependency Mod ID update. Test the exact subscribed package on disposable SP and dedicated fixtures; server changes require separate authorization.
