# Only Cure+ dependency and coexistence audit

Date: 2026-10-17, America/Phoenix. Health Care **0.11.0**, baseline
`c6eae57de7e32ccef862372d1f63e5215783d847`. Documentation-only: no version,
runtime, dependency metadata, license or save-schema change. The owner selected
independent support for the separately installed original, superseding absorption.

**Result: conditional observation integration is feasible; full gameplay
compatibility is NOT ESTABLISHED.** Do not add a hard dependency to the base mod,
advertise supported coexistence, or route medical execution through upstream
relay commands on this evidence. No implementation is included in this audit.

## Exact scope and provenance

- Original: [The Only Cure+ (Field Surgery), Workshop 3818733381](https://steamcommunity.com/sharedfiles/filedetails/?id=3818733381), NEXCONKER, Mod ID `TheOnlyCurePlus`. Public [source revision](https://github.com/Nexconker/TheOnlyCurePlus/tree/9e08c4b54df008595418f36aa0c648d197290518) is 3.2.0; GitHub main was rechecked at that SHA.
- Local Workshop metadata initially reported 3.1.1. External files changed during the audit. The final captured 3.2.0 main-mod tree matches the pinned source byte-for-byte: 903 files, 66 Lua files (65 within realm directories, plus the media registry). Scoped source hashes were checked again after collection. The initial version observation is not used as the final fingerprinted snapshot. This is a local installed match, not proof of every subscriber's download or an atomic Steam distribution guarantee.
- The optional `TheOnlyCurePlusTombBody` profile separately declares `TheOnlyCurePlus` and `TombBody` requirements. Its metadata was inspected only as a profile example. Body-model compatibility and its runtime/assets were not audited or imported.
- Dependencies inspected locally: MORTIS **0.25.0-dev.4**, commit `f0358fef2ec4519cbfb26bad641699488c7f8ec9`; Knowledge & Wisdom **0.16.0**, with the exact commit in the evidence inventory. These checkouts are source evidence, not proof of installed dependency versions.
- Installed game Steam build **25485521**. Exact engine patch remains UNKNOWN. TOC+ metadata minimum 42.20 and README 42.21+ differ; Health Care minimum 42.20.3 does not settle compatibility.
- Root GPL-3.0 license and original-author credits remain upstream. No foreign implementation, asset, recipe, balancing table, UI text, translation or documentation body is imported; no external mod is modified or executed. The earlier external research snapshot and abandoned fork metadata stay outside this repository. Public interface names below identify interoperability only.

The [evidence inventory](ONLY_CURE_PLUS_AUDIT_EVIDENCE_2026_10_17.json) records
portable relative paths, source hashes, inspected ranges, tree fingerprint format,
metadata deltas and exact local source revisions. It contains no foreign source
bodies, credentials, logs or player records. The original Workshop page could not
be fetched during this audit; live description claims are not refreshed evidence.

## Findings and decisions

| ID / severity | Verified source observation and implication | Required response |
|---|---|---|
| TOC-A01 / blocker for treatment | `client/TOC/API.lua:14-18,53-65` defaults some missing/unready queries to availability, no amputation, or full mobility. Functional availability also includes prosthetic replacement. No public snapshot generation/freshness or readiness result accompanies these queries. | Distinguish unavailable/unknown, anatomical loss and functional replacement. Never treat a positive result as surgery permission or healthy anatomy. A version string and `pcall` do not establish readiness. |
| TOC-A02 / blocker for pure observation | `getMobility` reaches `LegMobility.Evaluate`; the latter changes module-level `oneLeg` and `missingSide` (`client/TOC/Plus/LegMobility.lua:69-95`). Loading that module also registers player/cache callbacks. | Exclude this call from a non-mutating examination provider. Do not use a remote/split-screen examination to update another player's shared module scratch state. No substitute movement simulation. |
| TOC-A03 / blocker for gameplay RPC reuse | `server/TOC/ServerRelayCommands.lua` accepts client-supplied clinical/prosthetic updates. The staged-surgery route rebuilds a plan on the server, which is useful, but the inspected path does not establish a Health Care reservation, consent, elapsed-work or exactly-once transaction contract. The legacy amputation route is labelled admin in a comment without an admin check in that handler. Bounded post-op effect inputs do not establish authorization. | Treat these as upstream implementation transport, not an approved third-party treatment API. Do not emit them from Health Care. Any new procedure needs authoritative identity/consent/resources/time/replay validation and a supported outcome/receipt contract before implementation. These are static integration blockers, not a reproduced exploit or a comprehensive upstream security certification. |
| TOC-A04 / blocker for remote observation | `ClientDataController.Request` initializes state directly in SP or creates a client shell and asks the server in MP. Server initialization may migrate/create data. `RelayRequestDataController` and `SendCache` do not establish observer consent/range/privacy semantics for Health Care. Ready/cache events identify usernames without a monotonic clinical observation token. | Never request/initialize/migrate another mod's state while formatting an examination. A ready event is an invalidation hint, not proof of current remote data. Remote support needs a bounded, non-mutating, authorized snapshot contract with lifetime and patient identity. |
| TOC-A05 / blocker for canonical anatomy | TOC+ owns cut/prosthesis data separately; its amputation path changes TOC state, heals vanilla part fields, changes visuals and can emit a severed item. MORTIS owns independent region attachment/socket state. No `TOC`/`TheOnlyCurePlus` adapter was found in the inspected Health Care/MORTIS Lua roots. MORTIS aliases collapse forearm/upper arm and lower/upper leg into coarser regions. | Do not mirror a cut flag into `Mortis.Anatomy.sever`, equate an upstream prosthesis with a MORTIS socket attachment, or generate another detached item. Missing-limb recovery after death is a duplication/inconsistency RISK requiring proof, not a reproduced failure. Resolve the granularity and corpse/death handoff contract before shared clinical actions. |
| TOC-A06 / coexistence runtime gate | Both mods wrap `ISHealthPanel.doBodyPartContextMenu`, and both call a captured predecessor in the inspected code. TOC+ also wraps panel rendering, medical-check completion, and `ISBaseTimedAction.adjustMaxTime` / `perform`. Those base wrappers can change action duration and apply upstream bleeding/wear behavior when Health Care calls its base method. | Captured predecessors are promising for menu chaining, not proof of load-order independence. Test both wrapping orders, cancellation, native duration/completion, remote patients and split screen. Do not blindly set the upstream bypass flag: suppressing its rules is a gameplay decision requiring a supported contract. |
| TOC-A07 / module-resolution gate | Main-mod Lua has an existing shared/server `TOC/Events.lua` require-key overlap. No custom Java/JAR/class/DLL/SO/ZBS paths were found in the captured main-mod tree. Core namespaces `TOC`, `Mortis` and `medWorks` differ, but realm selection/event creation is not proven by that fact. | Do not add another `TOC` module or require a client-only API from server code. Verify event availability after native loading and Linux case-sensitive resolution. Lua-only inventory is a bounded static check, not engine or MP compatibility. |
| TOC-A08 / presentation gap | Health Care's provider pipeline can hold another owner's section, but the existing report formatter renders its known health/part/count fields. Vanilla BodyDamage observations alone cannot distinguish a healed native part from an upstream absent limb. | Add an original bounded/localized observation representation and formatter support together. Do not encode amputation as a fabricated vanilla injury or count it as a healthy limb. Preserve observer/patient scoping and observation age. |
| TOC-A09 / existing dedicated blocker | Current Knowledge & Wisdom `AuthorityGuard` rejects dedicated-server storage with `MULTIPLAYER_STORAGE_UNAVAILABLE`. | Do not add duplicate progression or bypass the guard. Any extension requiring Health Care knowledge remains blocked in dedicated MP until the owner resolves the storage contract. Pure local observation does not prove treatment readiness. |

All rows are [VERIFIED — bounded source observations] with their consequences
expressed as integration decisions or risks. None is a runtime PASS. The absence
of an adapter in scanned roots is not proof that no future upstream integration
could exist. Health Care's existing corpse recovery requires persisted MORTIS
anatomy; this audit does not assert that it currently recovers arbitrary player
corpses or demonstrate a duplication.

## Dependency/profile audit

[VERIFIED — vanilla source] Installed `ModSelectorModel.lua` obtains `modInfo`,
reads requirements through `getRequire()`, builds dependency edges and queries
availability. This confirms a native client metadata route; it does not prove
server availability of the same UI helpers, dependency download, exact native
version parsing, realm execution order or dedicated startup.

Use an opt-in integration profile with an explicit requirement on the original
and Health Care, retaining Health Care's existing MORTIS/Knowledge & Wisdom
requirements. Keep the original and Plus mutually exclusive as declared upstream.
Do not invent a bridge activation ID or add a new Workshop item during research.
The native leading-backslash metadata examples require actual loader validation
before packaging; copying an example is not that validation. A `loadModAfter`
hint cannot replace a dependency requirement. Keep base Health Care usable alone.

Optional TombBody changes the visual test matrix and is outside the initial
supported profile. Wound Expansion is also outside this integration slice; its
previous license/compatibility unknowns are not resolved here.

## Neutral first implementation contract

1. **Capability and readiness, no gameplay writes.** Detect exact activation and supported revision on the appropriate side. Source-inspected `DataController.GetReady` returns an existing ready controller without creating/migrating state; it is a possible version-specific readiness dependency, not a stable public compatibility guarantee. Establish that supported contract explicitly before implementing. Module availability alone is insufficient.
2. **Start with local self-observation.** Accept only the exact local examiner/patient. Unknown/malformed/unready state yields unavailable, never an anatomical assertion. Remote patients remain unsupported until their authorization, snapshot freshness, identity and privacy contract is proven. Do not infer fresh data from a cached username or import the client API on dedicated servers.
3. **Bounded independent report data.** Separate anatomical loss, functional aid and unknown. Use original Health Care labels/formatting, stable IDs, existing observer-scoped cache limits and validated detached values. No direct clinical tables, hidden disease values, upstream private save editing, balance reuse or mobility evaluation. Account for unknown granularity rather than flattening stage differences.
4. **Preserve ownership.** Do not reserve a second upstream operation, grant XP, consume materials, create items, change topology or synthesize treatment success from an upstream event. Events may invalidate observations only after their realm and identity behavior is verified. No permanent foreign-state mirror.
5. **Later original extension.** Specify one unmet follow-up/rehabilitation need only after current blockers clear. Health Care owns its new outcome; effects on original state require a supported upstream server transaction. Meaningful shared controls belong to localized authoritative sandbox options with old-save behavior; add none for protocol details or the audit itself.

This contract permits continued design and capability work. It is not approval
to claim that a safe read-only adapter already exists, nor to implement a blocked
gameplay path. No request to contact the original author has been sent.

## Required proof before support claims

- Offline: absent/unsupported/unready dependency, malformed observations, no writes from reads, no duplicate registration or foreign source/assets, version and case checks, original report bounds/localization, both wrapper orders in isolated mocks. These future adapter tests are NOT RUN because no adapter is implemented.
- SP/runtime: exact subscribed versions and engine patch; clean and disposable existing saves; loss levels on each side, prostheses and aids, Health Care report/context menu, actual duration/cancel/completion, split screen, death/corpse handoff and no duplicated output. NOT TESTED.
- Dedicated/runtime: server startup, two clients, unauthorized requests, observer privacy, join/rejoin, stale snapshots, save/reload/restart, exactly-once outcomes and authority. NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

No game/server launch, package, deploy, publication, upstream modification or
Steam restart was performed. The exact offline checks for this documentation
revision are recorded below; baseline tests never certify the combined mods.

## Clean-room review

- [x] Original identity, author, license, exact source revision and mutable installed-payload limits recorded.
- [x] Prior source exposure disclosed; no claim of hermetically separated authorship.
- [x] Foreign code/assets/tuning/text imported: NONE. Upstream modified/executed: NONE.
- [x] New report contains facts and neutral acceptance criteria, no foreign implementation bodies or close pseudocode.
- [ ] Independent reviewer signoff on this new audit and plan: PENDING. The earlier research review does not cover this revision.

No legal clearance or automatic license change is inferred from compatibility
research. Review the actual independently written adapter and its distribution
before merge; preserve original attribution and original-item links.

## Validation of this documentation revision

[TESTED — offline] `python scripts/check_versions.py` PASS: 0.11.0 and 12
current mirrors/identities. `python scripts/validate_source.py` PASS: 148 authoring
files, 22 Lua modules, 29 locale folders, exact internal require case, Lua-only,
artwork and Workshop text/identity. `python scripts/run_host_tests.py
--dependencies "C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories"`
PASS: 22/22 existing offline Lua 5.1 regressions. The executable was the verified
bundled Python; its refreshed bundle initially lacked `lupa`. A cached binary
`lupa==2.6` was installed with pip `--target` into external audit tooling and
provided through that shell's `PYTHONPATH`. Neither runtime dependencies nor
repository tooling were modified to make the checks pass.

An inline Python rehash checked 37 scoped evidence files and all 903 installed
main-mod files against the captured fingerprint. The installed/public main-mod
tree comparison had zero missing, extra or changed files. The overview helper's
`validate_descriptor` and `fingerprint` checks confirmed schema, canonical version
and current source digest. The vanilla `getRequire()` finding was recorded through
`api_library.py record` into the unmanaged local API draft, not the shared catalog.

`git diff --check` PASS. `git diff --exit-code c6eae57 -- src scripts tests VERSION
SOURCE_INVENTORY.json` PASS: no production/test/tooling/identity changes. No new
adapter tests were written for a documentation-only audit. Historical validation
records and distributed packages remain unchanged.

Before commit, the freshness helper fetched origin and reported REVIEW solely
for these intentional documentation files: HEAD/upstream/main
`c6eae57de7e32ccef862372d1f63e5215783d847`, ahead 0 / behind 0, no unfinished
operations. This uses a fresh audit worktree; the older planning and source
worktrees were preserved without stash, reset, pull, merge or rebase. Independent
review and combined-mod runtime gates remain pending irrespective of offline PASS.
