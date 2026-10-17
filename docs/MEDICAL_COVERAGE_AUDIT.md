# Medical coverage audit — static coverage complete

The 2026-08-26 medical handoff requires this audit to finish BEFORE further new
medical feature implementation. Existing corpse recovery and the in-progress
medical literature changes are retained, not rewritten. They are not proof that
the general medical framework is complete.

## Ownership and implementation rules

M.O.R.T.I.S. owns species anatomy, topology, trauma, limb/sever/attachment state.
medWorks owns examination, diagnosis, treatments, procedures, complications,
anesthesia, medication, blood/infusion, recovery and prosthetic fitting.
B47ANCEDKnowledgeAndWisdom owns semantic XP; its internal homeWorks subsystem owns learned
knowledge/provenance. animalWorks owns veterinary content. Preserve current
`B47ANCEDKnowledgeAndWisdom` identifiers until the naming migration is audited.

Do not extend the fixed vanilla BodyPartType enum or build a competing anatomical
graph. Human BodyDamage/BodyPart is a compatibility adapter, not generic anatomy.
Preserve vanilla injury and treatment state, and distinguish local wound infection
from Knox infection. No global health replacement or parallel basic bandaging.

The local copies at `C:\Users\willi\Zomboid\mods\FadedAdvancedMedical` and
`C:\Users\willi\Zomboid\mods\FadedsLastChance` are clean-room research sources
only. They may identify engine API and lifecycle questions to verify independently;
their code, data, text, assets, recipes, and implementation structure must not be
copied into medWorks.

## Clean-room research record — vanilla examination boundary (2026-08-27)

REFERENCE MOD: FadedAdvancedMedical

DOMAIN: medWorks

QUESTION: Can Build 42 expose human injury observations without replacing or
mutating vanilla treatment state?

ENGINE CAPABILITY OBSERVED: exposed `BodyDamage:getBodyParts()` and read-only
BodyPart getters provide bounded injury observations. Per-part
`isInfectedWound`/`getWoundInfectionLevel` represent local wound state and are
not evidence of Knox infection.

VERIFIED AGAINST VANILLA: yes — public native signatures and installed vanilla
Lua call sites are indexed in `docs/audit/native-api.csv`.

OUR DESIGN CONSEQUENCE: medWorks uses an original, provider-oriented read-only
examination report with hard traversal bounds and failure isolation. It does not
duplicate vanilla treatments and does not query Knox infection.

SOURCE CODE COPIED: NO

IMPLEMENTATION DERIVED FROM REFERENCE: NO

FOLLOW-UP: the original timed health-panel examination layer is now implemented;
validate its presentation, remote-player consent/snapshots, and hosted/dedicated
behavior in game before claiming multiplayer support or adding diagnosis.

## Initial installed-source evidence

- `media/lua/shared/TimedActions/ISStitch.lua`: completion consumes the item with
  `UseAndSync`, awards First Aid through `addXp(..., Perks.Doctor, 15)`, changes
  native stitched/stitch-time/pain/wound-infection fields, then calls
  `syncBodyPart` with an explicit field mask. Skill affects duration and outcomes.
  This is a vanilla-extension opportunity, not a missing stitching system.
- Native health panel located at `client/XpSystem/ISUI/ISHealthPanel.lua`.
  Complete extension-point and self/other-player review remains pending.
- Medical actions located: ISDisinfect, ISCleanBurn, ISRemoveGlass,
  ISRemoveBullet, ISStitch, ISSplint. Full inventories and call chains pending.
- `ISReadABook.lua` updates page progress on the item and character, including
  network-action progress. Its completion path can call `learnRecipe`.
  Existing homeWorks-style archive grants are completion-based; partial journal
  writing requires a separate persistent physical-item work queue.
- Current corpse bridge evidence and unresolved engine gates are in
  `CORPSE_RECOVERY_AUDIT.md`; do not infer living-player surgery support from it.

## Coverage classification to verify

| Classification | Feature family | Rule |
| --- | --- | --- |
| VANILLA | Bandaging, scratches/cuts/bites, basic disinfecting, stitching, glass/bullet extraction, splints, burn washing, poultices, common medication | Preserve existing actions/state; inspect exact installed implementations |
| VANILLA EXTENSION | Dressing/closure quality, irrigation/debridement, extraction trauma, fracture reduction, burn depth, local infection progression, analgesia | Add only meaningful depth using compatible native state |
| MEDWORKS | Generic procedures, examination, custom conditions, blood/typing/transfusion, IV, anesthesia, surgery, recovery | Modular providers; no monolithic replacement health loop |
| M.O.R.T.I.S. | Generic topology, trauma channels, sever/limb state, attachment sockets | API ownership, not medical procedures |
| EXPERIENCEWORKS | Knowledge, literature/study, semantic XP, anti-farming | No scattered arbitrary XP awards or shadow vanilla XP |
| ANIMALWORKS | Species-specific veterinary/husbandry outcomes | Consume generic procedures, do not assume human BodyPart mapping |
| REJECT | Duplicate vanilla basic treatments, dynamic native body enum, unrelated injury flags, default DBNO revival, unjustified granular simulation | Do not implement |

The first complete inventory of the ten installed body-part treatment actions is
now recorded in [VANILLA_TREATMENT_MATRIX.md](VANILLA_TREATMENT_MATRIX.md),
including validation, tools/items, effects, XP, synchronization masks,
presentation and interruption boundaries. API names outside that inspected set
remain leads until verified in installed classes and Lua exposure. Native
cauterization usage, BodyPartContacts, save/load, body synchronization, common
medication routes, and every proposed new getter/setter still require individual
evidence.

The adjacent consumable paths are now separated in
[VANILLA_MEDICATION_MATRIX.md](VANILLA_MEDICATION_MATRIX.md): tagged drainable
consumables use `ISTakePillAction` and native `BodyDamage:JustTookPill`, whereas
food-form antibiotics use `ISEatFoodAction` and `IsoGameCharacter:Eat`. This
closes the Lua ownership/action inventory. Installed-jar inspection now also
records exact built-in pill dispatch, intoxication modifiers, stress/callback/
`UseAndSync` ordering, and antibiotics' fake-infection/zombie-fever behavior.
Transport contents, runtime stacking/decay, serialization and multiplayer
behavior remain explicit verification gates rather than inferred claims.

## Remaining audit deliverables

Generated evidence inventory: [public native signatures](audit/native-api.csv)
and [input hashes](audit/manifest.json). The original generator is
`tools/audit_native_api.py`. It indexes 375 signatures across BodyPart,
BodyDamage and XP and 1,395 installed Lua files. Call-name matches are only leads:
they do not establish receiver type, overload, behavior or runtime safety.

### Network ownership evidence

Installed `LuaManager.GlobalObject.syncBodyPart` sends only when running on the
server and the body part belongs to an IsoPlayer. `BodyPartSyncPacket.setData`
casts its parent to IsoPlayer; it carries player identity, body-part index and a
64-bit field mask. The packet writes/reads 42 supported field slots by mask.
Consequently it cannot be treated as species-generic replication for M.O.R.T.I.S.
anatomy. Animal/zombie state requires its owning framework's replication contract.
The presence of a client-callable global does not mean client-side changes are
automatically synchronized. Packet routing, authority checks, reconnect and
late-join behavior still need full review and hosted/dedicated validation.

The complete panel-side contract is now recorded in
[HEALTH_PANEL_INTEGRATION.md](HEALTH_PANEL_INTEGRATION.md). Installed Lua and
native inspection confirms that remote health observation uses a disposable
`BodyDamageRemote` subscription snapshot, updated by a server differential
stream at most every 500 ms. It is distinct from canonical treatment mutation,
contains no implicit medWorks/M.O.R.T.I.S. replication, and supplies no patient
consent or authority grant.

### Additional installed evidence (2026-08-26)

Native `LuaManager$Exposer` explicitly registers BodyPart and BodyDamage. Static
inspection establishes class exposure, not successful execution of every method.
The native names are **`IsCauterized` / `SetCauterized`**, including capitalization.
`SetCauterized(true)` clears bleeding, bleeding-stemmed, deep-wounded and bandaged
flags. It is not a harmless isolated custom-condition marker. The inspected
BodyPart serializer contains cauterized-state read/write paths. No cauterization
reference was found by the installed Lua scan; that does not prove absence of
all native gameplay usage. Do not build a custom action until consequences and
network masks are fully traced.

Observed native treatment completion signals below come from the named files in
`media/lua/shared/TimedActions`. XP entries are call amounts, not guaranteed final
awards; skill/conditions and vanilla progression policy still apply.

| Action | Existing state/effect | Explicit syncBodyPart mask | Doctor XP call |
| --- | --- | --- | --- |
| ISApplyBandage | Native bandage operation and manipulation state | 0xc001966b8e | 5, conditional |
| ISDisinfect | Alcohol level and pain | 0x00608200 | None observed |
| ISStitch | Stitches, time, pain, infection | 0x00570188 | 15, conditional |
| ISSplint | Splint state/factor/item | 0x430000000 | 15, conditional |
| ISRemoveGlass | Glass removal and pain | 0x00480000 | 15 |
| ISRemoveBullet | Bullet removal with doctor level and pain | 0x40460108 | 20 |
| ISCleanBurn | Burn wash state and pain | 0x380400000 | 10 |
| ISPlantainCataplasm | Native Plantain factor | 0x0000000800000000 | None observed |
| ISComfreyCataplasm | Native Comfrey factor | 0x0000001000000000 | None observed |
| ISGarlicCataplasm | Native Garlic factor | 0x0000002000000000 | None observed |

These masks are evidence, NOT recommended constants to copy into new procedures.
Each new mutation needs the exact affected fields and current packet semantics.
ISApplyBandage validation uses ISHealthPanel.DidPatientMove; clients use captured
item/bandage availability while the non-client path queries inventory/body state.
The health panel has a HealthPanelAction/handler layer and per-body-part action
tracking. This argues for integrating its existing action lifecycle rather than
globally replacing the panel. Complete handler/network review remains open.

1. Complete medWorks source/docs/tests/package audit and M.O.R.T.I.S. anatomy,
   trauma and attachment API audit.
2. Native/runtime-verify the completed body-part and medication matrices;
   authority, dose effects, serialization and replication remain in-game/native
   inspection gates.
3. The static [BodyPart/BodyDamage capability matrix](BODY_DAMAGE_CAPABILITY_MATRIX.md)
   now distinguishes exposed native methods, installed Lua evidence, supported
   observation, restricted mutation and runtime-unverified behavior. Its named
   in-game and multiplayer gates remain open.
4. In-game verify the completed health-panel extension and self/other-player
   synchronization analysis, including consent policy and reconnect behavior.
5. The current public-description review is recorded in
   [WORKSHOP_PRECEDENT_GAP_REPORT.md](WORKSHOP_PRECEDENT_GAP_REPORT.md). These are
   third-party claims, not verified compatibility or implementation evidence.
6. The same report records the architecture gaps, ordered vertical slices and
   feature-by-feature ownership decisions.

## Post-audit sequence

### Workshop precedent checked

[Wounds Overhaul B42](https://steamcommunity.com/sharedfiles/filedetails/3775026731)
currently describes procedure quality, optional blood/transfusion, complications
and per-system settings. It warns against other health/blood overhauls and lists
dedicated-server fixes for action placement and networked item handling. These
are author claims, not our verification of compatibility or internal architecture.
Use them to prioritize state ownership and dedicated-server tests; no code copied.

Vanilla adapters → reusable transactional procedure vertical slice → examination
(observations vs diagnoses) → one controlled custom condition → blood/infusion →
surgery → prosthetic medical workflow → disease/sepsis → veterinary consumers.
Do not begin blood, sepsis and full surgery simultaneously.

Every procedure must cover self/other treatment, movement, interruption, tool loss,
inventory transfer, both deaths, disconnect/reconnect, late join, save/load,
replay/duplicate completion and server authority. No client-trusted medical state
or multiplayer compatibility claim without hosted/dedicated tests.
