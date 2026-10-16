# Version and source policy

Root `VERSION` is canonical. On 2026-10-16 the user approved the observed legacy 0.9.2 baseline and requested 0.9.3 for the Health Care rename and Mod ID migration. The requested PATCH number is retained explicitly even though changing the activation identifier requires consumer configuration changes. It is not a backwards-compatible or stable-release claim.

Current mirrors are enumerated exactly in `SOURCE_INVENTORY.json`. Run `python scripts/check_versions.py` before/after edits. Authoritative source is `src/B47ANCEDHealthCare`; `Contents` is stale derived staging (0.9.0), and `dist` packages/staging backups are historical. Neither is current source. The 0.9.2 package and SHA256SUMS remain immutable. Test fixture versions, native audit fingerprints and historical headings are not active mirrors.

Gameplay remains Lua-only, server authoritative, and server sandbox controlled. G7 dedicated multiplayer NOT TESTED / BLOCKED; stable G8 BLOCKED. `--release` must fail until those gates have real evidence. An authorized labelled Workshop MP test upload is distribution evidence only. No stable tag.

Current development version: 0.9.3. Public repository B47ANCE/B47ANCEDHealthCare. Source/package/activation ID B47ANCEDHealthCare. The user explicitly authorized the pre-1.0 PATCH number despite the public activation-ID break. It must not be represented as automatic save/dependency compatibility. Existing Workshop ID 3788592396 is unchanged. The medWorks API/item/network/sandbox/ModData keys remain documented compatibility contracts.

The named current validation record is docs/VALIDATION_0_9_3.md. docs/history/pre-health-care-0.9.2 contains immutable pre-rename evidence. Contents is historical, never an input to current packaging. dist is generated and untracked; the previous package is retained. Packaging creates separate versioned staging, a ZIP, integrity verification and a Git-bound release manifest.
