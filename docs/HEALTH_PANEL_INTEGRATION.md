# Health-panel integration contract — Build 42.20.3

This audit covers the installed client `ISHealthPanel`,
`ISMedicalCheckAction`, shared vanilla medical timed actions, and decompiled
native `IsoPlayer`/`BodyDamageSync`. It defines how medWorks may integrate with
the vanilla panel without treating a remote UI snapshot as authority.

## Roles and object mapping

For a self panel, `panel.character` is both doctor and patient. For a medical
check of another player, `ISMedicalCheckAction` constructs the panel around the
patient, then calls `setOtherPlayer(doctor)`. Consequently:

- `BaseHandler:getDoctor()` returns `panel.otherPlayer or panel.character`.
- `BaseHandler:getPatient()` returns `panel.character`.
- the treatment timed action is queued on the doctor's action queue;
- the selected BodyPart belongs to the patient.

medWorks extensions must use these role accessors and cannot infer roles from a
field name such as `otherPlayer` in isolation.

## Opening, range, identity, and closure

`ISMedicalCheckAction` records the patient's initial X/Y and remains valid when
the patient has not moved, when doctor and patient occupy the same vehicle and
the doctor is not driving, or when multiplayer medical-cheat capability applies.
Its duration is `150 - DoctorLevel * 2.5` unless timed actions are instant.

After opening, the remote panel:

- closes if the remote player object was recreated for the same online ID;
- closes/cleans up when hidden or when either character moves more than 0.5 tile
  from the opening position, except the same-car and medical-cheat cases;
- suspends remote BodyDamage updates and clears the remote snapshot when doctor
  and patient exceed two tiles, then resubscribes if they return;
- stops receiving updates when the panel closes.

The recreation check is essential across reconnect/relevance changes. A
medWorks action or diagnostic must never retain a patient BodyPart reference
after the owning player object has been replaced.

Vanilla `DidPatientMove` is also used by treatment actions. Self-treatment is
invalid while driving. For another patient it permits an unchanged position,
rejects a driving doctor after movement, permits a patient in a vehicle, and
otherwise rejects patient movement. This is a movement predicate, not a complete
range, life, consent, tool, authority, or ownership check.

## Observation subscription

On a client, a local doctor inspecting a different remote player resets that
player's `BodyDamageRemote` and sends a `BodyDamageUpdate` start request. The
server maintains a doctor/patient updater and emits differential snapshots no
more often than every 500 ms. Native evidence includes overall health, pain
moodle level, fake-infection state, zombie-infection stat, and BodyPart fields
reported by `BodyPart.sync`. Stop requests remove the updater.

The panel reads the patient's `BodyDamageRemote` for remote observations. That
object is a presentation snapshot created lazily on the patient object. It is
not the patient's canonical BodyDamage and cannot be mutated to perform care.
Clearing it with `RestoreToFullHealth` on range loss is further evidence that it
is disposable UI state.

The subscription is player-only and online-ID/connection routed. It is not a
generic M.O.R.T.I.S. anatomy transport, does not include medWorks modData merely
because a panel is open, and does not grant the doctor server authority.

## Menu dispatch and progress presentation

Each vanilla handler builds options from currently observed state and currently
enumerated doctor items. Selecting an option queues a zero-duration
`HealthPanelAction` on the doctor. That wrapper delegates `isValid` to the
handler and calls the handler's `perform`, which may queue inventory transfers
and the actual treatment action.

Items outside the doctor's main inventory are transferred first with an
inventory-transfer action. Installed source carries a FIXME that the panel's
transfer-action tracking table is never cleared. medWorks must not depend on
that table as a durable lock or proof of ownership; its own authoritative
reservation must revalidate exact items at completion.

`ISHealthPanel.setBodyPartActionForPlayer` publishes action type, progress delta,
and feature flags to the local health view and any medical-check window found
for that player object. This is UI presentation only. It does not replicate a
custom action, authorize mutation, or serialize a medWorks reservation.

## Mutation and synchronization boundary

Vanilla treatment actions mutate the patient's actual BodyPart at completion
and call `syncBodyPart` with explicit native field masks. Static native evidence
shows that packet casts the parent to `IsoPlayer`; it is not species-generic.

A compatible medWorks health-panel procedure therefore needs all of the
following independently:

1. A handler that uses current panel observations only to offer an option.
2. A doctor-owned timed action with patient identity, initial position and exact
   item/tool references captured safely.
3. An authority-owned reservation/lock that revalidates doctor, patient,
   canonical BodyPart or M.O.R.T.I.S. region, range, tools and consent policy.
4. A commit that mutates only the canonical owner and uses the correct player or
   M.O.R.T.I.S. synchronization contract.
5. Best-effort panel progress/notification that cannot roll back or duplicate a
   committed medical transaction.

## Consent boundary

No explicit patient-approval handshake was found in the inspected vanilla
medical-check/panel flow. Proximity and action validity are not consent. medWorks
must define any remote invasive-procedure consent policy explicitly rather than
claim vanilla provides it. Self-treatment and non-invasive examination may use
different policies, but clients cannot grant themselves authority by setting a
UI flag.

## Remaining in-game gates

- Verify remote panel opening, suspension/resubscription, closure and recreated
  player handling on hosted and dedicated servers.
- Verify what every `BodyPart.sync` field presents at the 500 ms observation
  cadence and whether late join starts with a complete snapshot.
- Exercise two doctors, simultaneous handlers, queued transfers, moving items,
  vehicle transitions, patient/doctor death, disconnect and reconnect.
- Confirm medWorks examination output and progress are visible only to intended
  viewers and never leak hidden diagnosis or Knox state.
- Verify cancellation and uncertain-commit recovery while the panel closes or
  the patient object is recreated.

These gates prevent a multiplayer compatibility claim; they do not block the
documented server-authoritative medWorks transaction architecture.

## Implemented alignment checkpoint

The medWorks timed examination now follows this boundary in source. Local and
single-player examinations use canonical local BodyDamage; a client examining a
remote player reads the subscribed `BodyDamageRemote` snapshot explicitly. A
missing snapshot fails closed instead of falling back to unsynchronized state.
The action captures the patient's online ID and rejects a recreated player
object, while self/vehicle driving checks match the vanilla movement contract.
Host tests cover source selection, missing snapshots and identity replacement;
actual subscription timing and multiplayer visibility remain the gates above.

## 0.10.0 current installed-source checkpoint

Examination is a client-only presentation action. It no longer defines complete, which selects native server action dispatch; perform publishes the bounded observation locally. Recovery remains a shared native server completion action, with full canonical validation. Both convert sandbox seconds to 50 native action units. Current evidence is fingerprinted in API_EVIDENCE_0_10_0.json (Steam build 25485521; exact engine patch UNKNOWN). This checkpoint does not upgrade the historical Build 42.20.3/native/SP/MP evidence above.
