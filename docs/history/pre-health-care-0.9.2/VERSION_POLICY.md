# Version and source policy

Root `VERSION` is canonical. On 2026-10-16 the user approved the observed legacy 0.9.2 baseline and requested 0.9.3 for the Health Care rename and Mod ID migration. The requested PATCH number is retained explicitly even though changing the activation identifier requires consumer configuration changes. It is not a backwards-compatible or stable-release claim.

Current mirrors are enumerated exactly in `SOURCE_INVENTORY.json`. Run `python scripts/check_versions.py` before/after edits. Authoritative source is `src/medWorks`; `Contents` is stale derived staging (0.9.0), and `dist` packages/staging backups are historical. Neither is current source. The 0.9.2 package and SHA256SUMS remain immutable. Test fixture versions, native audit fingerprints and historical headings are not active mirrors.

Gameplay remains Lua-only, server authoritative, and server sandbox controlled. G7 dedicated multiplayer NOT TESTED / BLOCKED; stable G8 BLOCKED. `--release` must fail until those gates have real evidence. An authorized labelled Workshop MP test upload is distribution evidence only. No stable tag.
