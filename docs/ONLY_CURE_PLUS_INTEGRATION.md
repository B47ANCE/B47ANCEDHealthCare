# Only Cure+ dependency integration plan

Original planning decision: 2026-10-16. Historical planning baseline: 0.11.0, commit
`b2e05c73a40680edac3ed76d7f7ff3416031762b`.

The owner stopped the absorption/fork direction and requested clean-room support
for the original mod as a direct plug-in/dependency. This supersedes the earlier
reuse proposal. Status: **planned, not implemented**. No runtime, dependency,
license, save-schema, activation ID or Workshop metadata change in this revision.
This documentation-only follow-up retains canonical version 0.11.0. Classify and
record the next development version before implementing the adapter.

## Product and distribution contract

- Keep the original [The Only Cure+ (Field Surgery)](https://steamcommunity.com/sharedfiles/filedetails/?id=3818733381), by NEXCONKER, separately installed from its original Workshop item. Support and credit that item directly.
- Health Care supplies an independently authored integration and extension layer. Do not bundle a fork, copied source, recipes, balance tables, translations, UI, models, animations or sounds. Do not patch the installed original.
- The integration profile must explicitly require original Mod ID `TheOnlyCurePlus` and Health Care with its existing MORTIS and Knowledge & Wisdom dependencies. Implement it in this repository; no new repository or Workshop item is authorized or needed for planning. Select and validate the native dependency/profile packaging before assigning any additional activation ID. A load-order hint alone is not a dependency declaration.
- Base Health Care remains usable without Only Cure+. The explicit requirement belongs to the integration profile; do not silently add it to the base mod before compatibility is proven. Publish a clear installation order and original-item link when the integration is available.
- With a missing, unsupported or unready dependency, the bridge reports unavailable and adds no treatment actions. Never substitute a bundled implementation or attempt automatic installation.

## Audit follow-up

The [2026-10-17 dependency audit](ONLY_CURE_PLUS_AUDIT_2026_10_17.md) is the current source-evidence follow-up. It records the now-installed 3.2.0 payload, remaining interface/authority blockers, and the narrow observation-first contract. Historical source/runtime evidence below is retained, not promoted to compatibility PASS.

## Provenance and factual boundary

Reference: [public source](https://github.com/Nexconker/TheOnlyCurePlus) at pinned
commit `9e08c4b54df008595418f36aa0c648d197290518`, source version **3.2.0**.
The original planning inspection saw Workshop description **3.1.0** and could not
establish source-to-installed-Workshop equivalence. The 2026-10-17 audit now records
a matching local 3.2.0 main-mod tree; other subscribers' payloads remain unverified.
Metadata minimum 42.20 and README 42.21+ differ; neither proves compatibility with
the local installed engine patch.

[VERIFIED â€” inspected source declarations] A client interface is returned by
`TOC/API`, with hand/leg availability, anatomical-loss and mobility queries. This
is a compatibility lead, not a documented server transaction or readiness
contract. Some query fallbacks conflate unavailable state with healthy/available
state; a fitted prosthesis can affect functional availability. Do not infer
anatomical presence from functional capability, or a healthy patient from an
unready controller. Purity/freshness and server availability must be established
for each query before use. No upstream internal field is a supported API merely
because it is visible in source.

[VERIFIED â€” license file] The pinned repository has a
[GPL-3.0 license](https://github.com/Nexconker/TheOnlyCurePlus/blob/9e08c4b54df008595418f36aa0c648d197290518/LICENSE).
The abandoned fork preparation copied a license and provenance draft into an
untracked research folder; both were moved, with matching SHA-256 verification,
to external audit storage. The upstream snapshot remains outside this repository.
No third-party implementation or asset is included in this plan or runtime.
No license change to Health Care is made. Calling another mod's interfaces is
not, by itself, a legal determination about a combined work; review the actual
adapter's licensing and distribution before merge.

Prior implementation-source inspection is disclosed; this is not a claim of a
hermetically separated clean-room team. Implement from this neutral requirements
contract and verified vanilla/public interfaces. Require independent provenance
and similarity review before merging compatibility code. Do not closely rewrite
previously inspected implementation. Wound Expansion is outside this dependency
plan and has no copying authorization.

## Ownership and conflict policy

| State or action | Owner and bridge boundary |
|---|---|
| Original surgery, amputation, prosthesis simulation and saves | Only Cure+ owns its existing behavior and storage. Health Care must not replay its action, run another complication loop, rewrite its state or duplicate its consumable/XP rewards. |
| Canonical species anatomy, severing and attachment topology | MORTIS remains Health Care's canonical owner. A foreign limb flag is an observation, never an instruction to sever a MORTIS region. Do not create a second living-human amputation path. |
| Examination presentation | Health Care may format a bounded, localized, patient/observer-scoped observation after a verified read-only contract. Distinguish unknown, missing anatomy and functional replacement. Preserve privacy and observation age. |
| New aftercare procedures and outcomes | Health Care owns only explicitly new medical state. The server validates actor, patient, consent, region, inventory, elapsed work and settings. Any effect on upstream state must use a proven upstream authoritative transaction interface. |
| Progression | Knowledge & Wisdom owns Health Care knowledge. Upstream progression stays upstream. No duplicate XP, shadow progression store or bypass of the current dedicated-storage guard. |

The two anatomy systems' coexistence is **UNKNOWN**, including their global hooks,
load order, original human actions and native visuals. Bridge disablement cannot
make an unsafe pair of base mods compatible. First audit passive coexistence and
define a verified ownership/disable contract; if they conflict and no supported
control exists, mark that combination unsupported and block gameplay integration.
Never solve it with client authority, monkey patches or silent save migration.

## Delivery slices and acceptance criteria

| Order | Independent work | Exit condition |
|---|---|---|
| 1 | Dependency/profile and passive-coexistence audit | Verify exact installed payload, game patch, native dependency resolution, load graph, hooks and MORTIS overlap. Missing/unsupported profiles fail safely. No unconditional require of absent client-only modules on server. |
| 2 | Read-only observation adapter | Verify a public non-mutating ready/snapshot contract for the execution side. If no contract exists, record unsupported rather than reading private mutable stores. Bounded detached results; unknown is explicit; no hidden infection/clinical disclosure. No permanent mirror or automatic reconciliation. |
| 3 | Health-panel examination integration | Show supported observed limb/prosthetic facts and extension readiness through Health Care's existing report/provider surface. Original actions remain upstream. Test stale snapshots, split screen, disconnect, malformed data and absent dependency. |
| 4 | One original aftercare extension | Specify one unmet care need, such as follow-up assessment or an independently defined rehabilitation procedure. Verify native effects and upstream server transaction contract before mutation. No duplicated sepsis, wound cleaning, surgery or prosthetic wear simulation. |
| 5 | Broader extension points | Consider original prosthetic fitting/maintenance services or additional care only after ownership and transaction APIs support them. A missing upstream API is a blocker to document, not authorization to patch upstream. No author contact without separate messaging authorization. |

Slice 1 is the next implementation prerequisite for this track. The existing
native recovery, diagnostic hardening and clinical-adapter roadmap gates remain
in force. The pinned client API alone cannot authorize slices 4 or 5.

Meaningful new shared gameplay configuration must use stable localized sandbox
options interpreted and bounded on the server, with documented defaults and
existing-save behavior. Do not duplicate upstream settings or expose protocol
internals. Presentation-only detection needs no new gameplay setting. No new
settings or schema are established by this plan.

## Validation and review gates

Offline adapter tests must cover dependency absent/unsupported/unready; explicit
unknown observations; anatomy versus functional prostheses; malformed/reentrant
providers; no writes from reads; no duplicate registration; correct realm and
case-sensitive imports. Gameplay tests must additionally cover malicious client
requests, two practitioners, exact-once materials/outcomes, cancellation,
disconnect, rejoin, restart and disposable old-save fixtures.

[RUNTIME GATE] Validate the exact subscribed originals with Health Care and its
dependencies in SP and dedicated MP, including server startup, client join/rejoin,
observation synchronization, treatment ownership and restart persistence. No
game/server launch, deployment, package or upload is authorized by this plan.
G7 remains BLOCKED / NOT TESTED and stable G8 BLOCKED. There is no compatibility
or runtime PASS from documentation or host tests.

Clean-room checklist: references/revisions and prior source exposure recorded;
third-party code/assets imported **NONE**; upstream modifications **NONE**;
independent implementation required; independent reviewer signoff **PENDING**.
Review actual API permissions, adapter licensing, attribution, state ownership
and source provenance before merge. No automatic reviewer signoff is claimed.

## Historical planning revision validation

[TESTED â€” offline, 2026-10-16] From this checkout, using the bundled Python with
`lupa.lua51`:

- `python scripts/check_versions.py` â€” PASS, 0.11.0 / 12 current mirrors and identities.
- `python scripts/validate_source.py` â€” PASS, 148 authoring files / 22 Lua modules / 29 locale folders, Lua-only and source identity checks.
- `python scripts/run_host_tests.py --dependencies "C:/Users/willi/Desktop/Work/Project Zomboid/Mod Repositories"` â€” PASS, 22/22 existing offline Lua 5.1 tests. These are baseline regressions, not tests of an implemented Only Cure+ adapter.
- `git diff --check` â€” PASS. Runtime source, tests, scripts, VERSION and source inventory are unchanged from the baseline above.

The fresh planning checkout started at current `origin/main`, ahead 0 / behind 0,
with no unfinished Git operation. It preserves the earlier worktree rather than
merging or resetting it. No SP, hosted, dedicated or combined-mod runtime test
was run. No package, deployment, Workshop edit or license change was performed.
