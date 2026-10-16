# B47ANCE'd Health Care

B47ANCE'd Health Care (formerly medWorks) is the planned species-agnostic medical-procedure framework for the
Works ecosystem. It will ship human-focused medical content while allowing
providers such as animalWorks to register procedures for any compatible Project
M.O.R.T.I.S. anatomy.

- Status: foundation development; bounded examination, its player-facing timed health-panel workflow, authoritative severing, and detached-part provenance are implemented, while diagnosis/treatment actions and visuals remain in development.
- Version: `0.9.3`. See [release work](docs/ROADMAP.md) for the remaining gameplay and safety gates.

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
movement and two-tile range (or shared vehicle), then prints a bounded detailed
report and displays a concise result. It observes state only; diagnosis and
treatment remain separate. Availability and duration are sandbox configurable.

Successful completion also publishes a five-minute, session-local observation
scoped to the exact examiner and patient. `medWorks.getCompletedExamination`
returns a detached sanitized report for presentation consumers; it cannot start
an examination or bypass the timed action, consent, or remote snapshot checks.

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
Remote clients submit a bounded request; the server reconstructs the exact
loaded corpse and exact owned nested saw, then repeats reach, clothing,
knowledge, anatomy, and provenance validation before the canonical transaction.
See [testing](docs/TESTING.md).
- Hard dependencies: `ProjectMORTIS` and `B47ANCEDKnowledgeAndWisdom` (its current canonical Mod ID).
- Optional integrations: waterWorks, powerWorks, and lightWorks where justified.

See [docs/B42_API_RESEARCH_HANDOFF.md](docs/B42_API_RESEARCH_HANDOFF.md) for the Build 42 healthcare audit plan. Proposed procedures remain unimplemented until their technical spikes pass.
- Ownership: procedure validation/execution, medical timed actions, tools,
  consumables, pain/anesthesia abstractions, treatment events, and MP authority.
- Non-goal: owning anatomy or animal-specific veterinary content.

Authoritative assets are under `src/B47ANCEDHealthCare/`: Steam `thumbnail.png` at the mod root,
with the Build 42 `poster.png` and canonical `icon.png` under `42/`.

## Identity and migration

- Current version: 0.9.3; root `VERSION` is canonical.
- New Mod ID: `B47ANCEDHealthCare` (replaces `medWorks`). Existing Workshop ID: `3788592396`.
- Public source: https://github.com/B47ANCE/B47ANCEDHealthCare
- Required: `ProjectMORTIS` and `B47ANCEDKnowledgeAndWisdom` (the renamed Knowledge & Wisdom dependency).
- Existing configurations must select `B47ANCEDHealthCare` in place of `medWorks`; dependent mod metadata must update its required Mod ID. Nightfall still requires that separate update.
- Lua `medWorks/*` imports, `_G.medWorks`, item full types, procedure/knowledge IDs, saved ModData, network channels and SandboxVars keys are preserved. They are compatibility contracts, not the activation ID. No saved-state schema is rewritten.
- MP testing build - dedicated multiplayer NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.

See [migration](docs/IDENTITY_MIGRATION.md), [version policy](docs/VERSION_POLICY.md) and [validation](docs/VALIDATION_0_9_3.md). `Contents/` and older packages are historical; builds use authoritative source into separate staging. Artwork retains the supplied bytes.

## Offline checks

Run `python scripts/check_versions.py`, `python scripts/validate_source.py`, and `python scripts/run_host_tests.py`. The host runner requires `lupa.lua51` and the declared sibling dependency checkouts; it never launches PZ or a server. Use `python scripts/check_public_tree.py` after targeted staging and before every public push. Package verification uses `python scripts/package_project.py --verify`. `--release` deliberately blocks stable G8 without required runtime evidence.
