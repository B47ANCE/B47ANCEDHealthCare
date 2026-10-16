# B47ANCE'd Health Care release work

> Consolidated status: [MASTER_ROADMAP.md](MASTER_ROADMAP.md).

Nightfall needs real player-facing detached-part acquisition, not only test-kit
parts and a callable sever API. Runtime development is authorized.

## Implemented foundation

- Anatomical clothing access comes from Project M.O.R.T.I.S. Corpse recovery
  requires an exposed target region and revalidates access at completion;
  covering garments must be removed first. Host tests cover blocked start and
  mid-action obstruction; native corpse clothing refresh remains an in-game gate.

- Procedure registry with provider validation and authoritative execution.
- Detached anatomy provenance and item creation for supported regions.
- Reserved operation IDs, fail-closed authority, schema preservation and isolated
  completion notifications (0.1.1).
- Timed world-corpse recovery with reach, distance, saw ownership/condition,
  frozen provenance, completion revalidation, cancellation and sandbox controls.
- Historical 0.8.0 remote recovery used a corpse/tool command,
  bounded nested inventory search, rate limiting, replay, and sanitized results
  (0.8.0).
- Off-inventory output staging, verified rollback, source overlap locks and
  persisted uncertain-failure quarantine (0.2.0); host-tested, not in-game verified.
- Provenance-matched quarantine inspection and authoritative reconciliation
  (0.2.1): rolled-back outputs are removed and verified before retry; committed
  anatomy remains non-repeatable; ambiguous duplicates fail closed.
- General procedure reservations, provider-defined patient-resource locks,
  completion revalidation, cancellation, uncertain-execution quarantine, and
  authoritative recovery resolution (0.2.2).
- Field-safety and anatomical-recovery knowledge definitions are explicitly
  owned and registered through B47ANCEDKnowledgeAndWisdom before literature content (0.2.3).
- Successful corpse-part recovery reports a committed, source-keyed Doctor
  semantic action to B47ANCEDKnowledgeAndWisdom only after severing commits; invalid,
  cancelled, repeated, and no-op attempts grant nothing (0.3.0).
- Bounded read-only examination providers with deterministic priority, isolated
  diagnostics, a vanilla-human BodyDamage adapter, normalized injury observations,
  and explicit local-wound/Knox-infection separation (0.4.0).
- Timed health-panel examination with movement/range revalidation, bounded
  sanitized presentation, one-shot completion, and sandbox controls (0.5.0).
- Bounded read-only procedure/sever-recovery diagnostics and an admin/debug-only
  health-panel modal that cannot resolve authoritative state (0.6.0).
- Optional lightWorks sunburn-treatment provider using canonical medWorks
  reservations/skin locks and lightWorks-owned replay-safe state mutation (0.7.0).
- Player and zombie death provenance is frozen by Project M.O.R.T.I.S. while the
  source identity still exists. Verified Build 42 `IsoDeadBody` construction
  copies that ModData into the corpse before removing the character; medWorks
  recovers the frozen record without global corpse scans or identity guessing.
- Physical medical books and magazines register their appropriate advanced and
  simple knowledge through B47ANCEDKnowledgeAndWisdom; corpse recovery requires its learned
  anatomical-recovery knowledge unless the owning sandbox rule disables it.
- Installed Build 42 body-part treatments and both medication-consumption routes
  now have explicit source matrices in `docs/VANILLA_TREATMENT_MATRIX.md` and
  `docs/VANILLA_MEDICATION_MATRIX.md`. They preserve native action ownership and
  distinguish proven Lua boundaries from native/runtime verification gates.
- The vanilla health-panel/remote-patient contract is documented in
  `docs/HEALTH_PANEL_INTEGRATION.md`: remote BodyDamage is a disposable
  observation snapshot, while medWorks reservations and canonical mutation stay
  server-owned and use their actual player/M.O.R.T.I.S. synchronization path.
- Timed examination now uses `BodyDamageRemote` for subscribed remote-client
  observations, rejects recreated online-player objects, and fails closed when
  the snapshot is unavailable; it never mutates the disposable snapshot.

## Required next work

The [medical coverage audit](MEDICAL_COVERAGE_AUDIT.md), installed treatment and
medication matrices, health-panel/network analysis, and static
[BodyDamage capability matrix](BODY_DAMAGE_CAPABILITY_MATRIX.md) constrain new
features. Runtime and multiplayer claims remain gated by the tests below.

1. Verify timed examination presentation and remote-player consent/replication
   through the vanilla health-panel workflow in game.
2. Verify world-corpse action timing and the implemented server transport in game;
   prove carry/drop/save paths and native player-death provenance transfer.
3. Validate general clinical reservations/locks, both recovery APIs, and the
   operator diagnostic modal against native inventories and multiplayer roles.
4. Validate the implemented corpse-to-detached-part-to-Nightfall-effigy path in game;
   implement body visuals only after native render-hook proof.
5. Expand the implemented B47ANCEDKnowledgeAndWisdom-backed medical literature only alongside
   new procedures that have verified vanilla capability and treatment contracts.
6. Define additional provider-specific pain, bleeding, anesthesia, treatment and recovery
   consequences after vanilla-first API verification.
7. [Sandbox ownership](SANDBOX_OWNERSHIP.md) now maps every implemented
   player-facing activity to its settings and verifies that corpse recovery
   rechecks enable/knowledge policy through the authoritative completion path.
   New procedures must add server-enforced controls alongside established
   behavior rather than introducing a speculative global bypass.
8. Validate interrupted actions, failure recovery, save/load, concurrency and
   multiplayer replication before making release-readiness claims.

The core currently delegates clinical/tool/range checks to provider callbacks;
it does not yet supply a complete medical gameplay loop.

## Approved external-research support

- **EXT-01/02:** consume animalWorks veterinary-target capabilities through
  species/provider-owned observations; do not treat animals as vanilla humans.
- **EXT-27:** expose registered procedure/treatment results to Nightfall-owned
  condition definitions while retaining medWorks reservations and authority.
- **EXT-31:** accept explicitly registered dependent-character patient
  capabilities after MORTIS defines identity/lifecycle semantics. medWorks owns
  procedures, not custody, needs, progression, or dependent content.

All three remain behind the existing native treatment, remote-patient,
reservation, persistence, and multiplayer proof gates.

## 0.10.0 audit-driven first slice

Implemented native server recovery timing, disabled the direct commit shortcut, moved client-only examination completion to local perform, corrected seconds/action-unit conversion, and tightened procedure reservation identity/reentry/persistence. See MASTER_ROADMAP.md for the ordered remaining work and AUDIT_0_10_0.md for findings and evidence. This is source implementation, not native or multiplayer verification.
