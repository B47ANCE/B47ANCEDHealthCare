# Health Care icon and merged-source validation

Current version: 0.12.1.

PATCH: approved transparent medical-bag mod icon; thumbnail, poster and Workshop preview preserved. Carries 0.12.0 independent local self-observation and all prior merged source. Native SP/hosted/dedicated NOT TESTED; G7/stable G8 BLOCKED. Explicitly authorized Workshop MP test publication after offline checks and owner-requested PR merges.

Baseline: `83a3f9e0876f392a989ffa4ba54fc37fe63576db`. Existing Mod ID
B47ANCEDHealthCare / Workshop 3788592396 / App 108600 are preserved. Gameplay
from 0.12.0 is unchanged; the only runtime texture change is 42/icon.png.
No generated packages or prior evidence are overwritten. Prior validation and
distribution records retain their original version, commit and runtime limits.

[TESTED — offline, Windows / Python 3.12 / lupa 2.6 Lua 5.1, 2026-10-18]

- `python scripts/check_versions.py` PASS: 0.12.1 / 12 active mirrors and identities.
- `python scripts/validate_source.py` PASS: 149 authoring files / 23 modules / 29 locale folders, Lua-only, syntax, require case, translations, artwork hashes and Workshop metadata. Pillow verifies the new icon is 32x32 RGBA with alpha range 0–255 and transparent corners.
- `python scripts/run_host_tests.py --dependencies "C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories"` PASS: 24/24 host regression files. No external mod is executed by the fixtures; offline tests are not native coexistence or dedicated proof.
- The approved authoring icon is copied byte-for-byte, SHA-256 b58b89c9fb92c55d6e17d97ee16735e85d646b5ecba5dec2b48c278d1c1639cf. The deterministic 32x32 RGBA export is SHA-256 87883d9b5e4ec034a28f949a5e0fd3745c7ebf4235e9dfa474a77099392984af, 2,635 bytes. Visual source inspection confirms the medical bag, no lettering or background fill.
- Preview, source thumbnail and 42/thumbnail.png remain SHA-256 247793bab8b3cf86b0f38b1a93b4e2cfe442ff7b31b37a366a819d2e6cae579c each. No thumbnail/poster re-export or generative change.

The original user image, generated alpha source/prompt and pre-0.12.1 icon are
retained and hash-checked in artwork/ARTWORK.json. The icon export uses existing
Pillow authoring tooling; it does not introduce a runtime dependency. Mod source,
source-bound feature overview and canonical Workshop drafts are reviewed together.

See MERGE_REVIEW_0_12_1.md for the owner-authorized source/provenance signoff and
its explicit lack of independent/runtime certification. Final staged public-file,
freshness and package/VDF checks remain required immediately before their actions.
Missing MP evidence permits this labelled test upload under the global policy;
it does not clear G7 or stable G8. Steam restart needs a new specific confirmation
after verified upload success. Publication never implies local/server deployment.

Publication will use `python scripts/prepare_workshop.py --preserve-existing-preview`: the descriptor omits previewfile as well as visibility/tags, preserving the live Workshop thumbnail even if its server-side copy differs from local authoring assets. The staged preview remains hash-checked. Final package/VDF evidence is recorded with the upload result.
