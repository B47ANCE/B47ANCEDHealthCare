# Version and source policy

Root `VERSION` is canonical. On 2026-10-16 the user approved the observed legacy 0.9.2 baseline and requested 0.9.3 for the Health Care rename and Mod ID migration. The requested PATCH number is retained explicitly even though changing the activation identifier requires consumer configuration changes. It is not a backwards-compatible or stable-release claim.

Current mirrors are enumerated exactly in `SOURCE_INVENTORY.json`. Run `python scripts/check_versions.py` before/after edits. Authoritative source is `src/B47ANCEDHealthCare`; `Contents` is stale derived staging (0.9.0), and `dist` packages/staging backups are historical. Neither is current source. The 0.9.2 package and SHA256SUMS remain immutable. Test fixture versions, native audit fingerprints and historical headings are not active mirrors.

Gameplay remains Lua-only, server authoritative, and server sandbox controlled. G7 dedicated multiplayer NOT TESTED / BLOCKED; stable G8 BLOCKED. `--release` must fail until those gates have real evidence. An authorized labelled Workshop MP test upload is distribution evidence only. No stable tag.

Current development version: 0.11.0. Public repository B47ANCE/B47ANCEDHealthCare. Source/package/activation ID B47ANCEDHealthCare. For the historical 0.9.3 rename, the user explicitly authorized the pre-1.0 PATCH number despite the public activation-ID break. It must not be represented as automatic save/dependency compatibility. Existing Workshop ID 3788592396 is unchanged. The medWorks API/item/network/sandbox/ModData keys remain documented compatibility contracts.

The named current validation record is docs/VALIDATION_0_11_0.md. docs/history/pre-health-care-0.9.2 contains immutable pre-rename evidence. Contents is historical, never an input to current packaging. dist is generated and untracked; the previous package is retained. Packaging creates separate versioned staging, a ZIP, integrity verification and a Git-bound release manifest.

## 0.10.0 development iteration

MINOR: recovery uses the native server timed-action route, while the legacy client commit command is rejected. Client-only examination uses local perform completion. Seconds are converted to native 20 ms action units; procedure context/replay binding is tightened. Persistent procedure schema remains 1; missing optional legacy maps initialize only through authoritative writes, malformed maps are preserved and rejected. Retain named 0.9.3 validation/distribution/provenance documents as historical evidence and the 0.9.3 ZIP unchanged. They are removed from the active mirror inventory, not rewritten. Current evidence is VALIDATION_0_10_0.md. No 0.10.0 package exists, and none is requested. Source validation and historical package verification are distinct; current_package/current_manifest are null until an explicitly requested build.

## 0.10.1 artwork iteration

PATCH: user-supplied thumbnail/poster assets and verified-preview descriptor preparation only. Runtime version metadata changes in lockstep; gameplay/API/save contracts are unchanged. Preserve VALIDATION_0_10_0.md as historical evidence, not current runtime proof. At the artwork implementation no 0.10.1 package existed. The later explicit publish request generated and uploaded 0.10.1; current package/manifest paths and last_distributed_version are recorded in SOURCE_INVENTORY.json. See WORKSHOP_UPLOAD_0_10_1.md and RELEASE_PROVENANCE_0_10_1.json. The earlier artwork validation record retains its original no-package evidence. G7 and stable G8 remain blocked for the overall mod.

## 0.11.0 examination report iteration

MINOR: new local report-viewing workflow and defensive presentation/cache contracts. Public API/item/network/sandbox/save identities remain medWorks; the cache remains session-local and its sanitization is stricter. No persistent migration. Earlier 0.10.1 validation/upload/provenance and package are historical, immutable evidence. Current package/manifest are null for 0.11.0, while last_distributed_version remains 0.10.1. G7 and stable G8 remain blocked.
