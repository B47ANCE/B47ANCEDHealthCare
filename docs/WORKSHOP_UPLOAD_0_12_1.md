# Health Care 0.12.1 Workshop MP test distribution

[VERIFIED — distribution, 2026-10-18] SteamCMD committed the explicitly authorized update to existing Workshop item **3788592396**, App **108600**, Mod ID **B47ANCEDHealthCare**, title **B47ANCE'd Health Care**. One upload attempt, exit **0**, cached login confirmed, actual Preparing update / Uploading content / Committing update...Success marker. No new item, visibility/tags change, local deployment or server mutation.

- Published source commit: `5d3fab7eebb3a290c88957adc94c7d9be7941a7c`, merged main. PRs #7, #8, #9 and the Windows packaging repair #10 are merged; their cumulative runtime tree passed the 24-file offline suite. No stable tag or independent/runtime certification is claimed.
- Package: `dist/B47ANCEDHealthCare-0.12.1-workshop-ready.zip`, SHA-256 `fbb2599e6ea23d1453e7d358c43c4375c18af4ed270e40115f32b89f9a982002`.
- Package manifest: `dist/RELEASE_0_12_1.json`; sanitized public copy [RELEASE_PROVENANCE_0_12_1.json](RELEASE_PROVENANCE_0_12_1.json) binds commit/version/IDs/build and 150 per-file hashes.
- VDF: `dist/B47ANCEDHealthCare-0.12.1.vdf`, SHA-256 `d648813f784c0a46982ed3aa6437e9e34fda57706c61a13b2fcc490b048c33c5`. Canonical inputs: WORKSHOP_DESCRIPTION.txt, WORKSHOP_CHANGE_NOTE.txt, workshop.txt. New notes cover changes since last distributed 0.10.1 and retain actual paragraphs, source/original-mod credit links and known limitations.
- New 32x32 RGBA icon: SHA-256 `87883d9b5e4ec034a28f949a5e0fd3745c7ebf4235e9dfa474a77099392984af`, actual alpha range 0–255 and transparent corners. Original generated alpha source/prompt and old icon retained as authoring evidence.
- Thumbnail, poster and packaged preview remain SHA-256 `247793bab8b3cf86b0f38b1a93b4e2cfe442ff7b31b37a366a819d2e6cae579c` each. The VDF omits previewfile, visibility and tags, so no live thumbnail replacement was submitted. No generative edit to thumbnail/poster/preview.
- Steam desktop was not automatically restarted. A new specific confirmation was requested separately after verified upload success; desktop action is not publication/download evidence.

[TESTED — offline] Exact project commands, using verified bundled Python with Pillow and isolated lupa.lua51:

```text
python scripts/check_versions.py
python scripts/validate_source.py
python scripts/run_host_tests.py --dependencies "C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories"
python -m unittest discover -s tests -p test_package_metadata.py
python scripts/package_project.py --steam-build-id 25485521
python scripts/package_project.py --verify
python scripts/prepare_workshop.py --preserve-existing-preview
git diff --cached --check
python scripts/check_public_tree.py
```

PASS: 0.12.1 / 12 mirrors; Lua-only 149 authoring files / 23 modules / 29 English-fallback locale folders; 24/24 Lua regression files; 3/3 metadata unittest methods (including LF/CRLF/BOM, duplicate and mismatched fields); 150 exact staging/ZIP members, CRC/data, safe paths, duplicate/case checks, source hashes and Git commit binding. VDF round-trip matches exact item/App/content/title/text and omits thumbnail/visibility/tag directives. Source-bound overview is current. GitHub has zero configured workflows; no CI PASS or bypass is claimed.

The first packaging attempt stopped before artifact creation due to an LF-only metadata substring check in the legacy builder. PR #10 fixes parsed-field validation for CRLF/LF without weakening identity/version/dependency checks. No failed artifact was relabelled, deleted or uploaded. The final real ZIP and descriptor passed all checks before the one SteamCMD attempt.

[VERIFIED — freshness/retention] Before build/upload, HEAD/upstream/main `5d3fab7eebb3a290c88957adc94c7d9be7941a7c`, ahead 0 / behind 0, clean, no unfinished Git operation. The uploader fetched and required exact source/manifest/upstream agreement. All three prior ZIP hashes still match the protected pre-upload ledger; no cleanup or overwrite occurred. Installed Steam build **25485521** was rechecked; exact engine patch remains UNKNOWN.

[UNKNOWN — live/subscriber view] Anonymous metadata result **9**; page/metadata access unavailable. SteamCMD commit success is verified upload evidence, not a claim of subscriber download, live page rendering, native icon display or MP compatibility.

**MP testing build - dedicated multiplayer NOT TESTED.** Native SP/split-screen/hosted/dedicated coexistence and original Only Cure+ action hooks remain untested; remote/treatment integration is unsupported. Knowledge & Wisdom's dedicated-storage guard remains fail-closed and blocks knowledge-dependent MP recovery. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No game/server launch or stable-release approval. See [validation](VALIDATION_0_12_1.md) and [owner-authorized review](MERGE_REVIEW_0_12_1.md). Publication payload remains unchanged by this evidence-only commit.
