# B47ANCE'd Health Care Master Roadmap

Canonical version: 0.11.0.

## First slice completed in source

- 0.9.3 foundation remains: procedure registry, reservations/locks/quarantine, MORTIS clothing/provenance/sever transactions, medical knowledge/semantic XP, bounded examinations, optional Spectrum sunburn integration and diagnostics.
- 0.10.0: native server recovery timing replaces the unchecked custom commit path; client-only examination finishes locally; sandbox seconds convert to native action units. Procedure/operation/patient/resource identities are rechecked, lock arrays detached, validation reentry blocked and diagnostic reads made non-mutating. Malformed saved maps are preserved/rejected. Internal traversal limits are no longer sandbox gameplay options.
- 0.10.0 evidence: 18/18 offline Lua 5.1 tests PASS. Native/SP/hosted/dedicated NOT TESTED. Findings and evidence: AUDIT_0_10_0.md and VALIDATION_0_10_0.md.

## Ordered work and acceptance gates

| Priority | Slice | Required evidence / exit condition |
|---|---|---|
| 1 | Native recovery path | Disposable SP and dedicated tests of corpse/item constructor resolution, actual seconds, cancellation, clothing/tool movement, two practitioners, exactly one output, save/reload, join/rejoin and restart. Verify subscribed versions and native inventory/anatomy replication. No fabricated runtime PASS. |
| 2 | Examination usability/accuracy — report UI implemented in 0.11.0 source | Verify local perform timing/UI, subscribed remote snapshots, object recreation, stale/cleared snapshots and split-screen isolation. Report UI/localization/defensive formatting are implemented; verify their native display. define privacy/consent requirements before invasive care. |
| 3 | Shared clinical adapters | Prove native human canonical BodyPart mutation/sync, actor/patient/region identity, exact nested tool/consumable ownership and server consent. Reuse vanilla treatments, never duplicate bandaging. Record one approved procedure and its sandbox/knowledge policies before implementation. |
| 4 | First treatment extension + matching literature | One vanilla-compatible procedure provider with meaningful server settings, item consumption/rollback/uncertain-state behavior, semantic XP without duplicate vanilla XP and disposable save migration tests. Requires slice 3's authority proof. |
| 5 | Pain/anesthesia/recovery | Provider-specific consequences only after installed getter/setter, stacking, native serialization and sync contracts are verified. No hidden/global health simulation. |
| 6 | Corpse-to-Nightfall path / visuals | Coordinate Nightfall's new Mod ID dependency separately. Verify detached part -> effigy in game. Rendered limb removal requires one proven Lua-visible renderer hook; do not substitute Java. |
| 7 | Veterinary/condition/dependent consumers | MORTIS identity/lifecycle capability first; content stays with the owning provider. No animal-as-human BodyDamage assumptions. |

## Cross-cutting open audit work

0.11.0 completes bounded examination report formatting/localization/escaping, finite examination durations, and bounded clock-safe observation caching. Procedure diagnostic traversal/localization and long-lived procedure-ledger retention remain open; never delete replay protection merely to bound storage. Save corruption/reconnect/restart cases need native fixtures as well as host tests.

G7 dedicated multiplayer BLOCKED / NOT TESTED. Stable G8 BLOCKED. No 0.10.0 package, deploy, Workshop update, game/server launch or Steam restart was requested or performed. The retained 0.9.3 artifacts remain historical and unchanged.

## Optional Spectrum self-care (0.11.0)

With SPXTRM 0.30.0 or its compatible treatment-receipt API available, right-click a vanilla cold pack in your main inventory while you have documented sunburn. The native timed self-care action consumes the pack and reduces canonical Spectrum dose. It is self-only and server validated; no other-player treatment or free client RPC. Sandbox controls enablement, duration and reduction. Uncertain item/dose outcomes remain locked for inspection; see [current care validation](VALIDATION_0_11_0.md)  Native SP/dedicated NOT TESTED; no package, deployment or upload.

0.10.1 adds the supplied Health Care thumbnail/poster and package-bound preview selection only. See VALIDATION_0_10_1.md. Gameplay roadmap priorities and runtime gates are unchanged. The subsequent explicit publish request produced a verified 0.10.1 Workshop MP test upload; see WORKSHOP_UPLOAD_0_10_1.md. No local deploy or server change.

0.11.0 source: View last examination, observer-scoped historical report, viewport-bound scrolling, safe close/focus restoration, 52 UI keys and English fallbacks, malformed-provider/markup/count/UTF-8 limits and clock-safe cache expiry. See EXAMINATION_REPORTS.md and VALIDATION_0_11_0.md. Dedicated recovery remains blocked both by missing native evidence and the current Knowledge & Wisdom 0.16.0 MULTIPLAYER_STORAGE_UNAVAILABLE guard. No 0.11.0 package/deploy/upload. The next implementation slice is diagnostic presentation hardening; native recovery/snapshot/clinical authority gates remain mandatory.

## External medical-reference candidates (research only)

The user-requested audit of The Only Cure+ (3818733381) and Wound Expansion (3819438691) is recorded in [THIRD_PARTY_RESEARCH.md](THIRD_PARTY_RESEARCH.md), with separately pinned public-source/installed-package evidence. No runtime change, version bump, imported implementation/asset or compatibility claim.

Proposed order: read-only procedure-readiness information; then, after existing clinical authority and dedicated dependency gates, one wound-care/aftercare provider plus its original supplies/literature; later finite postoperative complications, staged surgery and MORTIS-owned prosthetic fitting. Blood/infusion, permanent deficits and movement effects remain later audited capabilities. These proposals do not replace the ordered mandatory gates or the current diagnostic-hardening slice.

Important findings: the inspected Wound 1.0.5 compatibility path identifies original TheOnlyCure rather than TheOnlyCurePlus and does not establish the pair's leg/prosthetic compatibility. Its getters can initialize/clean up state and are not automatically safe for read-only examinations. The optional ZombieBuddy Java add-on is excluded. TOC+ public Git source is 3.2.0 while the inspected Workshop description shows 3.1.0; payload equivalence is unknown. No foreign canonical limb/condition state will be silently mirrored into MORTIS.

Independent clean-room reviewer signoff is pending before the research PR can merge. No new PZ runtime or G7/G8 evidence comes from this audit.
