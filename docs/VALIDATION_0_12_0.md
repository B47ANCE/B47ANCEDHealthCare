# Health Care Only Cure+ self-observation validation

Current version: 0.12.0.

MINOR: additive client-only capability detection and local self-observation; no new dependency, persistent schema, gameplay mutation or identity change. This record belongs to this source iteration. Earlier validation records remain historical. Native SP/hosted/dedicated NOT TESTED; G7 and stable G8 BLOCKED. No package, deploy or publish.

Baseline: `5ec0615f21baad5d4635f991d77579e67d9507c1`, the preceding clean-room
dependency audit. Source-authoring path remains src/B47ANCEDHealthCare. Prior
VALIDATION_0_11_0.md and dated upstream fingerprints are retained unchanged;
last confirmed Workshop distribution remains 0.10.1. No release tag.

## Implemented boundary

`client/medWorks/OnlyCureObservation.lua` is loaded only by the client entry point.
It imports external interfaces conditionally after local-self/realm/activation
checks, accepts the inspected Only Cure+ 3.2.0 contract, and validates existing
structural fields without creating/migrating a controller. Reports contain at most
twelve detached structural observations. No mobility queries, remote observations,
clinical simulation, foreign state writes, commands, progression or topology sync.
Ten new UI keys use English fallbacks in 29 locale folders; translation quality
is not claimed. Shared report formatting is pure presentation. No new gameplay
setting or save schema is needed. Existing examination sandbox settings apply.

## Offline commands and outcomes

[TESTED — Windows, bundled Python 3.12 / isolated lupa 2.6 Lua 5.1, 2026-10-17]
The bundled interpreter was used with the external audit-tool installation in
PYTHONPATH. Command names below refer to that interpreter, not a game process.

- `python scripts/check_versions.py` — PASS: 0.12.0 / 12 current mirrors and identities.
- `python scripts/validate_source.py` — PASS: 149 authoring files / 23 Lua modules / 29 locale folders; Lua-only, syntax, internal require case, localization parity, artwork and Workshop text/identity checks.
- `python scripts/run_host_tests.py --dependencies "C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories"` — PASS: 24/24 existing and new offline regression files. No external mod code is executed by these tests.
- `git diff --check` and `git diff --cached --check` — PASS.
- `python scripts/check_public_tree.py` — PASS: 263 indexed files, zero findings; only the 57 intended source, locale, regression and documentation paths were staged. No generated packages, private logs/settings or upstream source/assets are included.

The source-bound overview passed the installed helper's schema, version and
digest checks. A static prohibited-call screen found no command, ModData,
mobility or initialization call in the adapter; this supplements the runtime-stub
sentinels, not native proof. Pre-commit freshness fetched origin: REVIEW only for
these intentional changes, baseline/upstream `5ec0615`, ahead 0 / behind 0;
main ahead 1 / behind 0, no unfinished operations. The earlier audit PR remains
the stacked base; no main merge is authorized or performed here.

New regression cases use independently authored interface fixtures: absent,
conflicting, unsupported, unready and malformed dependencies; metadata/interface
failure; server/remote/impostor rejection; exact second-local-player identity;
detached results; query failures; readiness, activation and local-object changes
during capture; duplicate-load registration; localized unknowns and malformed
report bounds. ModData/command/mobility sentinels reject prohibited calls. A real
Health Care timed-action completion is exercised through provider, formatter and
historical cache using a stub native base; repeated completion cannot re-observe.
Rendering a saved observation never queries upstream. Existing native recovery,
procedure integrity, report/cache and Spectrum regressions remain passing.

## Native gates and review

[RUNTIME GATE] Exact installed engine patch and subscribed dependency versions,
SP and split-screen display/identity, native duration/cancellation, wrapper order,
upstream bleeding/wear hooks and passive coexistence remain NOT TESTED.
The query layer writes no upstream state; the existing action's base completion
may still invoke Only Cure+'s original general-action wear/bleeding rules after
the historical capture. No bypass flag or suppression is added.
Dedicated
startup/join/rejoin/restart and remote clinical authority remain NOT TESTED.
G7 BLOCKED / NOT TESTED; stable G8 BLOCKED for the overall mod. The existing
Knowledge & Wisdom dedicated-storage guard is unchanged. A source-only local
presentation adapter does not validate the rest of this gameplay mod.

Clean-room checklist: prior source exposure and pinned GPL-3.0 upstream identity
disclosed; foreign source/assets/algorithms/tuning/text imported NONE; external
modifications NONE; independent code, labels, output contract and fixtures;
independent provenance/compatibility reviewer signoff PENDING before merge.
No claim of hermetically separated authorship or legal clearance. No package,
deployment, Workshop upload, game/server launch or Steam restart was performed.
