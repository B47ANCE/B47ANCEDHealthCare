# B47ANCE'd Health Care Master Roadmap

Canonical version: 0.11.0.

## First slice completed in source

- 0.9.3 foundation remains: procedure registry, reservations/locks/quarantine, MORTIS clothing/provenance/sever transactions, medical knowledge/semantic XP, bounded examinations, optional Spectrum sunburn integration and diagnostics.
- 0.10.0: native server recovery timing replaces the unchecked custom commit path; client-only examination finishes locally; sandbox seconds convert to native action units. Procedure/operation/patient/resource identities are rechecked, lock arrays detached, validation reentry blocked and diagnostic reads made non-mutating. Malformed saved maps are preserved/rejected. Internal traversal limits are no longer sandbox gameplay options.
- 18/18 offline Lua 5.1 tests PASS. Native/SP/hosted/dedicated NOT TESTED. Findings and evidence: AUDIT_0_10_0.md and VALIDATION_0_10_0.md.

## Ordered work and acceptance gates

| Priority | Slice | Required evidence / exit condition |
|---|---|---|
| 1 | Native recovery path | Disposable SP and dedicated tests of corpse/item constructor resolution, actual seconds, cancellation, clothing/tool movement, two practitioners, exactly one output, save/reload, join/rejoin and restart. Verify subscribed versions and native inventory/anatomy replication. No fabricated runtime PASS. |
| 2 | Examination usability/accuracy | Verify local perform timing/UI, subscribed remote snapshots, object recreation, stale/cleared snapshots and split-screen isolation. Complete localization/defensive formatting; define privacy/consent requirements before invasive care. |
| 3 | Shared clinical adapters | Prove native human canonical BodyPart mutation/sync, actor/patient/region identity, exact nested tool/consumable ownership and server consent. Reuse vanilla treatments, never duplicate bandaging. Record one approved procedure and its sandbox/knowledge policies before implementation. |
| 4 | First treatment extension + matching literature | One vanilla-compatible procedure provider with meaningful server settings, item consumption/rollback/uncertain-state behavior, semantic XP without duplicate vanilla XP and disposable save migration tests. Requires slice 3's authority proof. |
| 5 | Pain/anesthesia/recovery | Provider-specific consequences only after installed getter/setter, stacking, native serialization and sync contracts are verified. No hidden/global health simulation. |
| 6 | Corpse-to-Nightfall path / visuals | Coordinate Nightfall's new Mod ID dependency separately. Verify detached part -> effigy in game. Rendered limb removal requires one proven Lua-visible renderer hook; do not substitute Java. |
| 7 | Veterinary/condition/dependent consumers | MORTIS identity/lifecycle capability first; content stays with the owning provider. No animal-as-human BodyDamage assumptions. |

## Cross-cutting open audit work

Bound presentation-provider values/diagnostic traversal, complete report/diagnostic localization and escaping, validate finite examination duration inputs, and define safe long-lived procedure-ledger retention without deleting replay protection. These are open findings, not completed features. Save corruption/reconnect/restart cases need native fixtures as well as host tests.

G7 dedicated multiplayer BLOCKED / NOT TESTED. Stable G8 BLOCKED. No 0.10.0 package, deploy, Workshop update, game/server launch or Steam restart was requested or performed. The retained 0.9.3 artifacts remain historical and unchanged.

## Optional Spectrum self-care (0.11.0)

With SPXTRM 0.30.0 or its compatible treatment-receipt API available, right-click a vanilla cold pack in your main inventory while you have documented sunburn. The native timed self-care action consumes the pack and reduces canonical Spectrum dose. It is self-only and server validated; no other-player treatment or free client RPC. Sandbox controls enablement, duration and reduction. Uncertain item/dose outcomes remain locked for inspection; see [current care validation](VALIDATION_0_11_0.md)  Native SP/dedicated NOT TESTED; no package, deployment or upload.
