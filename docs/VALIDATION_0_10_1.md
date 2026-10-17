# Health Care artwork development validation

Current version: 0.10.1.

Recorded 2026-10-16. Base commit: 0c7fd8defe24d859db69d585c7a3f0b5f9649c76 (0.10.0). Branch: feat/health-care-artwork-0.10.1, stacked on feat/authoritative-recovery-0.10.0. PATCH presentation/tooling change: thumbnail/poster exports and package-bound preview selection. Gameplay, item/API/save/network/sandbox identities are unchanged; only runtime version metadata advances.

[VERIFIED — source / supplied asset]

The user attached the original Health Care medical-bag PNG on 2026-10-16. artwork/health-care-original.png retains the exact 1,634,849 input bytes, SHA-256 5656c81da79c59efcb72cabaf0a8cb161f8ff07422f366bbeb60e6ae27548643. No generative edit, crop or redraw. Three identical 512x512 RGB PNG exports use full-frame Pillow 12.3.0 LANCZOS resizing with optimize=True. Each is 308,715 bytes, SHA-256 247793bab8b3cf86b0f38b1a93b4e2cfe442ff7b31b37a366a819d2e6cae579c. Exact source/export/previous-art/icon records are in artwork/ARTWORK.json. Previous artwork is recoverable at the base commit; original authoring input is outside runtime source. The existing 32x32 icon is unchanged.

Steam's official [SetItemPreview documentation](https://partner.steamgames.com/doc/api/isteamugc#SetItemPreview) specifies an image under 1 MB; exports are below 1,000,000 bytes. The existing project already uses 512x512 PNG thumbnail/poster roles. scripts/prepare_workshop.py includes the verified staged preview in a future descriptor and preserves omission of visibility/tags. It still requires current package verification; it never authenticates, uploads or restarts Steam.

[TESTED — offline, Windows / bundled Python / Pillow / lupa.lua51]

All commands below used the bundled Python executable at `C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe` from the repository root:

```powershell
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/check_versions.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/validate_source.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' scripts/run_host_tests.py
& 'C:/Users/willi/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/python.exe' -m py_compile scripts/prepare_workshop.py scripts/validate_source.py
```

PASS: 12 current version mirrors and identities; Lua-only 115 authoring files / 18 modules / 29 locale key sets; artwork hashes/role paths/dimensions/size; 18/18 isolated Lua 5.1 host regressions; Python syntax.

An inline Python/Pillow check verified complete PNG decode for all source/export/icon assets, exact equality with the attached original, unchanged icon and 0.10.0 validation, and the retained 0.9.3 package SHA-256 057f52568dab18a2e6c64d151856ecc498e75464fbf1ac882564f2e177ab25ed. Visual inspection of preview.png at 512x512 confirms the full composition and readable lettering; this is a tool preview, not PZ evidence.

An isolated temporary descriptor fixture exercised prepare_workshop.main with three prerequisite subprocess invocations mocked (versions/source/package). It round-tripped actual paragraph breaks and previewfile, omitted visibility/tags, and rejected an altered staged preview via its package hash. It neither builds a real package nor proves a real upload.

Public push preflight: `git diff --cached --check` PASS and `python scripts/check_public_tree.py` PASS (207 indexed files, zero findings) after targeted staging. Reviewed tracked/staged assets, metadata, scripts and docs; ignored staging, authentication state and local diagnostics remain excluded. GitHub repository visibility verified PUBLIC.

Immediately before commit, Test-PZRepositoryFreshness.ps1 fetched origin and returned REVIEW solely for these intentional uncommitted changes. HEAD and the verified parent feature upstream were both 0c7fd8defe24d859db69d585c7a3f0b5f9649c76 (ahead 0 / behind 0); main comparison ahead 4 / behind 0; no unfinished operations. The artwork branch initially tracks its verified parent until the first push establishes its own remote branch. No stash/reset/pull/merge/rebase. No CI configured or claimed.

[RUNTIME GATE]

In-game poster display, live Workshop thumbnail and subscriber download NOT TESTED for 0.10.1. This patch only changes presentation/tooling, but the overall gameplay build still requires native SP/hosted/dedicated tests documented for 0.10.0. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED. No package, local deployment, Workshop upload, game/server launch or Steam restart. The last distributed version remains 0.9.3. Named 0.10.0 validation and retained packages remain historical, unchanged evidence.
