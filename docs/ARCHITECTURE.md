# B47ANCE'd Health Care Architecture

Project M.O.R.T.I.S. owns anatomy. medWorks owns generic medical procedure
execution. Procedure providers own their content and domain-specific outcomes.

The planned patient adapter will support vanilla human `BodyDamage` where it is
appropriate and Project M.O.R.T.I.S. anatomy for extended or non-human regions.
The procedure registry must not require `patient:isPlayer()`, hard-coded human
body regions, or player-only inventories in its core.

## Implemented foundation

- `medWorks.getRegionAccess(patient, region)` consumes canonical Project
  M.O.R.T.I.S. anatomy and `Mortis.ClothingCoverage.region` facts. It reports
  covering garment types, anatomical coverage, and attached/access status.
- Procedure definitions may set `requiresExposedRegion=true`; those procedures
  require `context.region` and recheck clothing before reservation and completion.
  Unknown coverage fails closed. Holes do not imply safe surgical access.
  Corpse-part recovery checks this access before starting and at completion;
  practitioners must remove covering clothing first. This contract does not
  yet add clothing-cutting/opening actions or retrofit every treatment provider.

- `medWorks.sever` captures provenance, creates the detached inventory item,
  and rolls item creation back if canonical anatomy detachment fails.
- Project M.O.R.T.I.S. owns structural anatomy mutation and the versioned
  provenance contract; medWorks owns the procedure transaction.
- The procedure registry validates content-provider callbacks, requires
  canonical authority and persistent patient state, records replay identifiers,
  and emits `MedicalProcedureCompleted` only after successful execution.
- `beginProcedure`, `completeProcedure`, and `cancelProcedure` provide a shared
  timed-action boundary. Provider-defined resource keys prevent overlapping
  operations; completion repeats provider validation before execution.
- Throwing execution enters a persistent `uncertain` state and retains its
  resource locks. `inspectProcedureRecovery` returns protected diagnostic data;
  `resolveProcedureRecovery` requires an explicit authoritative outcome.
- `ProcedureDiagnostics` combines bounded procedure history, active locks, and
  sever quarantine into a sanitized read-only snapshot. Debug/admin users may
  open it from the health panel; the modal has no mutation or unlock controls.
- A shared timed corpse-recovery action and protected world context menu now
  call the sever API. Automatic combat severing, clinical procedures,
  consequences, and body visuals remain later milestones.
- Examination is a separate read-only provider pipeline. Providers declare an
  owner, stable ID and priority; at most 16 are registered, and each failure is
  isolated into diagnostics. The first-party human adapter observes at most 64
  BodyParts (32 by default), never mutates BodyDamage, and never reports Knox
  infection as local wound infection.

The current core validates patient availability, provider validation results,
canonical authority, state schema and replay IDs. Practitioner, region,
distance, knowledge, skill, tools, consumables and timing checks must currently
be supplied by each procedure provider; shared adapters and player-facing
clinical procedures remain incomplete. The corpse recovery provider supplies
living-practitioner, exact saw, nested ownership, condition, reach, distance,
world-corpse membership, anatomy and frozen-provenance checks. It repeats them
at action completion; canonical mutation remains authority-gated. animalWorks may register veterinary definitions
and recovery hooks without duplicating the execution engine.

## Replay and authority contract (0.1.1)

Missing or throwing authority providers fail closed before severing creates an
item. Medical execution reserves its replay ID before calling provider code.
Records carry `reserved`, `executing`, `uncertain`, `cancelled`, `completed`, or `failed` status in the existing
`completedProcedures` ledger for compatibility. All attempted IDs reject replay:
a callback that throws may already have changed the patient and therefore keeps
its locks until explicit recovery resolution. A false return is recorded as a
definitive failed attempt and releases locks, but its ID remains non-replayable.

Unknown/malformed ledger schemas are preserved and rejected, not overwritten.
Post-commit event-listener failures are isolated; they cannot turn a completed
operation into a retryable error.

## Sever transaction (0.2.0)

Outputs are allocated off-inventory with `instanceItem` and receive provenance
before insertion. Insertion is verified with `contains`; even AddItem that
inserts then throws can be rolled back using the exact object. Failed canonical
detachment removes the output and verifies absence. Successful outputs are
replicated only after the anatomy commit. Whole-source synchronous locks also
exclude overlapping parent/child sever calls with different operation IDs.

Unverifiable output rollback or a throwing anatomy transition quarantines the
source. `medWorksSeverRecovery` persists the inspection requirement when ModData
is available. Runtime locks cover sources without ModData only for the current
session.

Version 0.2.1 exposes `inspectSeverRecovery` and `resolveSeverRecovery`. They
match staged outputs by immutable M.O.R.T.I.S. source/region provenance. An
attached source is unlocked only after all matching rollback outputs are removed
and absence is verified. A detached source is recognized as committed and stays
non-repeatable. Missing provenance, unavailable inventories and duplicate output
remain quarantined for manual inspection. The 0.6.0 operator modal presents
this state without resolving it. Mid-transaction crashes and network
reconciliation remain release-validation work.

## Optional sunburn treatment (0.7.0)

`SunburnTreatment.lua` conditionally registers `medWorks.treatSunburn` only when
lightWorks is installed. medWorks owns procedure reservation, a dedicated
`skin:uv-exposure` lock, bounded treatment-source/amount validation, completion
revalidation, and uncertain-execution handling. lightWorks remains the sole
owner of sunburn dose, severity, operation replay state, and ModData sync.

This is a provider-level integration, not yet a complete consumable-item or UI
workflow. A missing lightWorks installation leaves medWorks fully loadable and
simply marks the integration unavailable.

Version 0.8.2 includes this provider in both production load graphs. Client and
server therefore agree on procedure availability when lightWorks is present,
while the provider's guarded require preserves standalone medWorks loading.
The client graph also installs the corpse-recovery menu after its transport, so
the documented part-acquisition path is reachable through normal startup.

## Corpse-recovery transport (0.8.0)

Single-player recovery commits directly after timed-action revalidation. A
remote client sends only bounded identity assertions: request ID, square,
static-object index, region, and saw ID/type. The server reconstructs the exact
loaded corpse, requires two-tile reach, and resolves the saw through at most 512
nested owned inventory entries before calling the canonical completion path.

A per-player rate limit and 64-result replay cache prevent flooding and duplicate
severing. Replies expose only success, a bounded failure reason, and output type.
The client never creates anatomy products or mutates corpse state. Hosted and
dedicated behavior remains an explicit live validation gate.

## Completed examination observations (0.9.0)

Only `MWExaminationAction:complete` publishes a UI-consumable examination. The
session-local cache is keyed by exact examiner and patient objects, retains at
most 16 observations per examiner, expires entries after five real-time minutes,
removes object/function/non-finite facts, and returns a detached copy. Remote
consent and `BodyDamageRemote` validation still occur before publication.
