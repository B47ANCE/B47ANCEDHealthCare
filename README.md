# B47ANCE'd Health Care

B47ANCE'd Health Care (formerly medWorks) is the planned species-agnostic medical-procedure framework for the
Works ecosystem. It will ship human-focused medical content while allowing
providers such as animalWorks to register procedures for any compatible Project
M.O.R.T.I.S. anatomy.

- Status: foundation development; bounded examination, its player-facing timed health-panel workflow, authoritative severing, and detached-part provenance are implemented, while diagnosis/treatment actions and visuals remain in development.
- Version: `0.11.0`. See [release work](docs/ROADMAP.md) for the remaining gameplay and safety gates.

Generic procedure providers can reserve an operation before a timed action,
lock one or more patient resources, revalidate at completion, cancel safely
before execution, and inspect or resolve uncertain execution after an exception.
When lightWorks is present, medWorks registers an authoritative sunburn-treatment
procedure while lightWorks retains ownership of dose and severity state.

`medWorks.registerExaminationProvider` and `medWorks.examine` expose a bounded,
read-only observation surface for species/provider-specific clinical data. The
built-in vanilla-human adapter reports normalized BodyPart injuries and local
wound infection separately from Knox infection. One failing modded provider is
reported diagnostically without breaking other examination sections.

Right-click a body region in the vanilla health panel and choose **Perform
examination**. The timed action revalidates both living participants, patient
movement and two-tile range (or shared vehicle), then finishes locally, prints a bounded detailed
report and displays a concise result. It observes state only; diagnosis and
treatment remain separate. Availability and duration are sandbox configurable.

Successful completion also publishes a five-minute, session-local observation
scoped to the exact examiner and patient. `medWorks.getCompletedExamination`
returns a detached sanitized report for presentation consumers; it cannot start
an examination or bypass its timed action or remote snapshot checks. Snapshot freshness and any invasive-procedure consent policy remain explicit runtime/design gates.

## Corpse part recovery

Carry a working Saw or Garden Saw, stand within two reachable tiles of a recently
killed zombie, and right-click its body. **Recover body part** offers available
regions with preserved M.O.R.T.I.S. anatomy/provenance. Recovery takes 120 seconds
by default; movement cancels it. Sandbox settings enable/disable recovery and
adjust duration. Providers may register equivalent saws through
`medWorks.CorpseRecovery.registerTool(fullType)`.

This is implemented but not yet verified in game. Older/unknown corpses and
human player corpses without lifecycle provenance are unsupported. Recovery
creates inventory parts; it does not yet visually remove limbs from the corpse.
Recovery uses the native Build 42 shared timed-action server callback. The server repeats reach, clothing, exact tool ownership, knowledge, anatomy and provenance validation before the canonical transaction. The legacy direct client commit command is rejected.
See [testing](docs/TESTING.md).
- Hard dependencies: `ProjectMORTIS` and `B47ANCEDKnowledgeAndWisdom` (its current canonical Mod ID).
- Optional integrations: waterWorks, powerWorks, and lightWorks where justified.

See [docs/B42_API_RESEARCH_HANDOFF.md](docs/B42_API_RESEARCH_HANDOFF.md) for the Build 42 healthcare audit plan. Proposed procedures remain unimplemented until their technical spikes pass.
- Ownership: procedure validation/execution, medical timed actions, tools,
  consumables, pain/anesthesia abstractions, treatment events, and MP authority.
- Non-goal: owning anatomy or animal-specific veterinary content.

Authoritative assets are under `src/B47ANCEDHealthCare/`: Steam `thumbnail.png` at the mod root,
with the Build 42 `thumbnail.png` poster and canonical `icon.png` under `42/`.

## Identity and migration

- Current version: 0.11.0; root `VERSION` is canonical.
- New Mod ID: `B47ANCEDHealthCare` (replaces `medWorks`). Existing Workshop ID: `3788592396`.
- Public source: https://github.com/B47ANCE/B47ANCEDHealthCare
- Required: `ProjectMORTIS` and `B47ANCEDKnowledgeAndWisdom` (the renamed Knowledge & Wisdom dependency).
- Existing configurations must select `B47ANCEDHealthCare` in place of `medWorks`; dependent mod metadata must update its required Mod ID. Nightfall still requires that separate update.
- Lua `medWorks/*` imports, `_G.medWorks`, item full types, procedure/knowledge IDs, saved ModData, network channels and SandboxVars keys are preserved. They are compatibility contracts, not the activation ID. No saved-state schema is rewritten.
- MP testing build - dedicated multiplayer NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

See [migration](docs/IDENTITY_MIGRATION.md), [version policy](docs/VERSION_POLICY.md) and [validation](docs/VALIDATION_0_11_0.md). `Contents/` and older packages are historical; builds use authoritative source into separate staging. The original supplied artwork is retained byte-for-byte under `artwork/`; thumbnail and poster exports are 512x512 PNGs.

## Offline checks

Run `python scripts/check_versions.py`, `python scripts/validate_source.py`, and `python scripts/run_host_tests.py`. The host runner requires `lupa.lua51` and the declared sibling dependency checkouts; it never launches PZ or a server. Use `python scripts/check_public_tree.py` after targeted staging and before every public push. Package verification uses `python scripts/package_project.py --verify`. `--release` deliberately blocks stable G8 without required runtime evidence.

The 0.9.3 Workshop MP test update was confirmed by SteamCMD and Steam restarted gracefully. See [distribution evidence](docs/WORKSHOP_UPLOAD_0_9_3.md). Anonymous live-page metadata and subscriber download remain unverified. Source is pushed on the PR branch; main remains the recorded legacy baseline pending merge.

## 0.10.0 roadmap slice

The audit and first implementation slice are in [AUDIT_0_10_0.md](docs/AUDIT_0_10_0.md). Source now uses native server recovery timing, client-only observation completion, correct seconds conversion and stronger procedure identity/resource/replay binding. Recovery diagnostics no longer initialize or repair save data. The obsolete ExaminationMaxBodyParts setting is ignored; the existing 32/64 internal/provider limits remain bounded. Native constructor/clock/replication tests are still required before clinical expansion or release claims. Current source is 0.11.0; the retained 0.9.3 Workshop package and distribution evidence remain historical. No 0.10.0 build/upload was performed.

## 0.10.1 artwork

The user-supplied medical-bag artwork is used for `preview.png`, the source-root `thumbnail.png` and the Build 42 poster. The original 1254x1254 PNG is retained outside runtime content; export settings, hashes and previous artwork provenance are in [artwork/ARTWORK.json](artwork/ARTWORK.json). The small icon is preserved. Future explicit Workshop preparation uses the verified staged preview. The subsequent explicitly requested 0.10.1 Workshop MP test upload was confirmed by SteamCMD; see [distribution evidence](docs/WORKSHOP_UPLOAD_0_10_1.md). In-game poster display remains NOT TESTED.

Current distribution: 0.10.1 Workshop MP testing build, source commit `042673cb25a7eddf2a1536a871ded89ca562c837`. Package and sanitized provenance are recorded in [WORKSHOP_UPLOAD_0_10_1.md](docs/WORKSHOP_UPLOAD_0_10_1.md). Native SP/dedicated and subscriber download remain NOT TESTED; G7/stable G8 BLOCKED.

## Detailed examination reports (0.11.0 source)

After completing **Perform examination**, reopen a body-region context menu in the same patient health panel and choose **View last examination**. It appears only while that exact examiner/patient observation is cached (five minutes with a valid clock). The report is a read-only historical snapshot, labelled with its age at opening. It does not update live or perform treatment. It can stay open after cache expiry; reopening rechecks expiry. One scrolling window per local player remains inside that player's viewport and restores controller focus when closed, without changing game speed.

Report labels/findings use translation keys with English fallback in all 29 locale folders; this is not a claim of 29 translated languages. Malformed providers are skipped or shown safely, markup is inert, and text/traversal/count budgets are internal safety limits. Missing/non-finite/backward clocks invalidate reopening; no save data is written. Native layout, gamepad, remote snapshots and dedicated behavior remain untested. See [report design/testing](docs/EXAMINATION_REPORTS.md). The current Knowledge & Wisdom 0.16.0 dependency explicitly blocks multiplayer storage, so knowledge-gated dedicated recovery remains blocked pending work in that owning project. Workshop still distributes 0.10.1; no 0.11.0 package or upload.

## Optional Spectrum self-care (0.11.0)

With SPXTRM 0.30.0 or its compatible treatment-receipt API available, right-click a vanilla cold pack in your main inventory while you have documented sunburn. The native timed self-care action consumes the pack and reduces canonical Spectrum dose. It is self-only and server validated; no other-player treatment or free client RPC. Sandbox controls enablement, duration and reduction. Uncertain item/dose outcomes remain locked for inspection; see [current care validation](docs/VALIDATION_0_11_0.md)  Native SP/dedicated NOT TESTED; no package, deployment or upload.
