# Workshop MP test distribution

Current version: 0.9.3.

[VERIFIED — distribution, 2026-10-16] Existing Steam Workshop item **3788592396** was updated through the installed cached-login SteamCMD. App ID **108600**. Submitted title **B47ANCE'd Health Care**, Mod ID **B47ANCEDHealthCare**. No new item was created. Visibility, tags and remote preview were omitted from the update descriptor and remain outside this change.

- Release-source commit: `e5e0b128a8e6ec7545542436990216c67ab4aca4` on `feat/health-care-0.9.3`.
- Public source: https://github.com/B47ANCE/B47ANCEDHealthCare
- Review PR: https://github.com/B47ANCE/B47ANCEDHealthCare/pull/1 (open; main retains the legacy baseline until an authorized merge).
- Package: `dist/B47ANCEDHealthCare-0.9.3-workshop-ready.zip`.
- Package SHA-256: `057f52568dab18a2e6c64d151856ecc498e75464fbf1ac882564f2e177ab25ed`.
- Separate staging: `dist/workshop-0.9.3`, containing `Contents/mods/B47ANCEDHealthCare/42`.
- Bound manifest: `dist/RELEASE_0_9_3.json`; sanitized public copy: `docs/RELEASE_PROVENANCE_0_9_3.json`.
- Canonical description/change notes: `WORKSHOP_DESCRIPTION.txt`, `WORKSHOP_CHANGE_NOTE.txt`; canonical descriptor `workshop.txt`.
- Generated upload descriptor: `dist/B47ANCEDHealthCare-0.9.3.vdf` (not source and not committed).
- SteamCMD exit code: **0**. Authenticated upload reached **Preparing update**, **Uploading content**, and **Committing update...Success.** There was one upload; no repeat was used to verify it.
- The initial verifier expected an older Published File Id success format. Its result was corrected by inspecting this invocation's actual success format, exact item descriptor and zero exit code.
- Steam desktop restart: **PASS**, gracefully exited and started the same verified installed client. No forced termination, game launch, local deployment or server mutation.

[UNKNOWN — live metadata] Anonymous GetPublishedFileDetails returned result 9 and no item metadata. The public web tool could not open the page. Neither is treated as evidence of a failed authenticated upload or a new visibility setting. Live-page title/description visibility and actual subscriber download remain unverified; the title/content above are the exact submitted values with a confirmed upload commit.

[TESTED — offline] `python scripts/package_project.py` and `python scripts/package_project.py --verify` PASS: 116 exact source-derived ZIP/staging files, CRC/data, safe paths, duplicate and case checks, per-file SHA-256 and release-source commit binding. `python scripts/prepare_workshop.py` PASS: correct existing item/App IDs, canonical version/title/status/link, bounded text, VDF round-trip and actual paragraph breaks. Version/source/localization checks and all 15 Lua 5.1 host regressions PASS as recorded in VALIDATION_0_9_3.md. The public Git index was audited before each push. CI is not configured for this newly onboarded repository; these are local offline results, not CI or runtime evidence.

[VERIFIED — retention] Every pre-existing dist artifact/staging hash still matches the pre-edit retention ledger. Prior 0.9.2 package SHA-256: `b341504659c8f9052286b8ff643a7c225e278357f1adf1a644737fb22ca00502`. Source/stale staging and the prior package were backed up before editing; no historical package was relabelled or deleted. Supplied artwork bytes are retained.

**MP testing build - dedicated multiplayer NOT TESTED.** PZ native/SP/hosted/dedicated NOT TESTED for 0.9.3. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. `python scripts/check_versions.py --release` must reject stable G8. This successful distribution does not validate gameplay or Mod ID migration in an actual save.

Next human checks: subscribed download and activation using B47ANCEDHealthCare, dependency selection, server startup, client join/rejoin, remote examination consent, exactly-one recovery output, synchronization, save/reload, and restarts on disposable fixtures. Nightfall still needs its separate require=medWorks to require=B47ANCEDHealthCare metadata migration before using this build. Existing mod lists need the new activation ID; medWorks Lua/item/state/network/sandbox contracts remain stable.
