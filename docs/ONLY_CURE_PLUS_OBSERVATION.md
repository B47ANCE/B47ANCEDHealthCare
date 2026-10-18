# Only Cure+ local self-observation — 0.12.0

Implemented in development source, native coexistence NOT TESTED. The original
[Only Cure+](https://steamcommunity.com/sharedfiles/filedetails/?id=3818733381)
stays separately installed and owns surgery, prostheses, progression and saves.
This independently authored adapter adds no required Mod ID or Workshop item.

## Player workflow

With Only Cure+ 3.2.0 enabled, complete **Perform examination** on yourself.
The existing detailed report then includes twelve bounded limb observations:
no loss reported, loss with prosthetic support reported, or loss without
prosthetic support reported. These are upstream structural reports, not diagnosis,
mobility testing, proof of limb health or MORTIS topology. Native BodyDamage and
limb-loss facts describe separate systems; they are not reconciled automatically.

Use **View last examination** to reopen the historical result. Existing five-minute
cache expiry, exact examiner/patient identity, detached copies and viewport limits
remain. No upstream query runs while viewing a saved report. With Only Cure+
absent, the extra provider is omitted. Unready/unsupported/conflicting/malformed
active data produces a localized unavailable result, never a healthy limb default.
If native dependency detection itself is unavailable, no structural facts are inferred.

## Narrow compatibility contract

Reference: NEXCONKER's GPL-3.0 original, Mod ID `TheOnlyCurePlus`, source revision
`9e08c4b54df008595418f36aa0c648d197290518`, inspected version **3.2.0**. Source
and installed fingerprints are historical evidence in the
[2026-10-17 audit](ONLY_CURE_PLUS_AUDIT_2026_10_17.md). The field contract below
is deliberately version-specific; no promise of a stable upstream API is inferred.

`medWorks.OnlyCureObservation.getCapabilities(examiner, patient)` returns a fresh
plain table with `status`, `canObserve`, `scope="local-self"` and, when supported,
`version`. Ready means the interface/readiness shape permits an observation attempt,
not a treatment authorization or guarantee the next read succeeds.
`capture(examiner, patient)` returns bounded detached report data with `kind`,
`schemaVersion=1`, `scope`, `status`, optional `version` and up to twelve `parts`.
Each part contains only its vanilla type identifier, `lossReported` and
`supportReported`. Failure clears all part facts; no partial success survives.

The registered provider is `medWorks.OnlyCureSelf`. It is client-only, not imported
by the server/shared loader. It requires all of:

- Explicit non-server realm and valid client/SP realm detection; the exact living
  examiner must be the patient and the current object in their local player slot.
  A remote object or another local player's patient is rejected. Slots 0–3 are a
  technical local-player boundary, not a gameplay balance setting.
- Activation lookup confirms Plus active and original `TheOnlyCure` inactive.
  There is no filesystem scanning, download, polling or background player traversal.
- Conditional protected imports of `TOC/API` and shared
  `TOC/Controllers/DataController`. API version is exactly 3.2.0; `isCut`,
  `hasPart` and `GetReady` exist. These are original modules called as dependencies,
  not redistributed implementation. Standard module loading may register the
  original's own callbacks; Health Care adds no upstream lifecycle/reset callback.
- `GetReady(username)` supplies an existing controller with that exact username,
  explicit `isDataReady=true`, and existing structural data. To prevent the
  upstream getters' false/healthy fallbacks from hiding partial saves, the adapter
  validates only twelve existing limb `isCut` booleans and four existing prosthesis
  group `isProstEquipped` booleans. These field names are interoperability schema,
  not a copied simulation. No missing record is created or repaired. The clinical
  contents of those records and all other state are ignored and never exported.
- Only `isCut` and `hasPart` are queried. Results must be booleans consistent with
  the validated loss fact. The adapter rechecks controller identity/readiness,
  consumed structural flags, version and the exact local player after the queries.
  It discards the result if they change. It does not map amputation levels into
  MORTIS's coarser regions or claim native limb-function measurements.

Stable capability failure codes: `not-local-self`, `inactive`,
`detection-unavailable`, `conflicting-mod`, `interface-unavailable`,
`unsupported-version`, `not-ready`, `invalid-data`, `query-failed`.
Reports map them to bounded localized explanations and do not reveal foreign
exception strings. A self-reported version is an interface gate, not cryptographic
attestation of the installed code. Other mods can replace interfaces; support
remains tied to the audited original and native tests.

## Authority, persistence and configuration

This slice owns client presentation and session-local observations only. No
commands, GlobalModData requests, controller initialization/migration, shared
state writes, new items, anatomy operations, treatment, movement changes, knowledge
or XP grants occur. `getMobility` and internal simulation methods are never called.
No server capability is advertised. Client facts never authorize procedures.
Remote snapshots, invasive treatment and prosthesis mutation remain unsupported.

Read-only describes this adapter's queries and report data, not a promise that
the entire game stays unchanged. The existing timed examination still completes
through the native base action. Only Cure+'s general action-completion hooks can
apply its own wear/bleeding rules; this adapter does not bypass them. The cached
observation is captured before that base completion, so those subsequent effects
are not retroactively added. Verify this interaction natively before claiming
coexistence or advertising an action with no upstream side effects.

Existing examination enablement/duration settings govern the player workflow.
No new shared gameplay behavior exists to configure; capability versions, schema
checks and traversal limits are technical compatibility constraints, not sandbox
balance options. Captured observations are historical and do not invalidate or
refresh themselves on upstream events. Object replacement, stale data and cache
limits retain the existing fail-closed policy. No persistent migration is needed.

## Evidence and review

The adapter, output schema, UI wording and tests were authored independently from
the neutral audit requirements and vanilla part identifiers. Only API/module and
field identifiers necessary for interoperability are used. No third-party source,
algorithm, balance value, asset, recipe, translation or documentation body is
included or rewritten. Prior upstream source inspection is disclosed in the audit;
this is not a claim of hermetically separated authorship. Original GPL license and
credits stay with the separately installed original; this change makes no license
determination about future distribution. Independent clean-room review is pending.

See [current validation](VALIDATION_0_12_0.md) for exact offline commands and
limitations. Native wrapper order, actual timed-action duration and completion,
SP/split-screen and dedicated coexistence remain NOT TESTED. G7 and stable G8
remain BLOCKED for the overall mod. No game/server launch, package, deployment
or Workshop publication is part of this iteration.
