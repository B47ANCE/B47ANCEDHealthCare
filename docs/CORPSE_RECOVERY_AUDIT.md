# Corpse recovery: implementation evidence and remaining validation gates

Installed-game/source inspection, updated 2026-08-30. The authoritative recovery
pipeline is implemented and host-tested. The remaining gates in this document are
in-game lifecycle and multiplayer validation, not missing runtime ownership.

## Confirmed

- Vanilla `media/lua/shared/TimedActions/ISGrabCorpseAction.lua` checks
  `corpseBody:getStaticMovingObjectIndex()` and square reachability, uses
  `corpseBody:getItem()`/`getModData()`, and executes human corpse dragging through
  `character:pickUpCorpse`. Animal corpse handling takes a separate path.
- Installed native `IsoDeadBody(IsoGameCharacter, boolean, boolean)` construction
  copies the dying character's ModData using
  `LuaManager.copyTable(this.getModData(), died.getModData())` before removing the
  character from its square and world. Its `reanimate` method copies corpse
  ModData into the replacement zombie. `getObjectName()` returns `DeadBody`,
  but `isZombie()` can still return true: this is not a safe live-entity test.
- `IsoDeadBody.getItem()` explicitly copies ModData to animal items; the human
  path instead stores corpse byte data and assigns `item.deadBodyObject`.
  `InventoryItem.getDeadBodyObject()` exposes that reference. This does NOT prove
  the reference survives every inventory save/load path; do not fabricate a
  default corpse when it is absent.
- M.O.R.T.I.S. now freezes source classifications/anatomy after zombie death
  callbacks and before identity cleanup. Native construction can carry this
  ModData into the corpse. Host tests simulate that copy, not engine execution.
- Anatomy runtime now rejects corpse attachment without complete compatible
  persisted anatomy; the living resolver cannot regenerate missing corpse limbs.
- `API/DetachedParts.lua:capture` needs anatomy and source identity and runs
  provider classifiers. Nightfall source class must be preserved, not guessed
  from a corpse's appearance or defaulted to regular zombie.

## Implemented bridge

Native NetTimedAction/PZNetKahluaTableImpl inspection now confirms a world corpse
argument travels as DeadBody ObjectID, while tools travel by container/item ID.
Either can resolve to nil after world/inventory changes. The medWorks constructor
fields match parameter names, its Type is globally defined in shared scope, and
complete repeats the shared validation before mutation. This supports the chosen
action structure but does not replace network playtesting. See the ecosystem
`docs/B42_TIMED_ACTION_AUDIT.md` for lighting dependency blockers found by this audit.

M.O.R.T.I.S. freezes anatomy and provider classifications on `OnZombieDead` and
on the player-only branch of `OnCharacterDeath`. The native constructor then
copies that record to the new `IsoDeadBody`. medWorks validates the real world
corpse, captures the frozen region record, performs the authoritative sever
transaction and writes provenance to the detached item. Project Nightfall reads
its own frozen classifier from those items when composing an effigy. No module
uses a square-wide nearest-zombie matching heuristic.

The remaining work is to verify corpse carry/drop/save paths and the player-death
lifecycle in game. Those are release-validation gates because host tests cannot
execute native object construction, serialization or network ObjectID resolution.

Test live death, already-missing limbs, corpse drag/carry/drop, save/reload,
reanimation, human versus infected origin, unknown corpse provenance and
concurrent actions. Any unsupported origin should fail closed without inventing
an effigy signature.

### Native evidence provenance

Inspection was reconfirmed on 2026-08-30 using the locally installed
`projectzomboid.jar`, SHA-256
`BDA809FB49004A07DBFC560D059C0EE58D0643AB0F33B53351B13BD62F1D8227`, with CFR 0.152
in a temporary audit directory. Relevant methods: `IsoDeadBody` constructor,
`getItem`, `getObjectName`, `isZombie`, `reanimate`; `InventoryItem.storeInByteData`
and `getDeadBodyObject`; `IsoGameCharacter.becomeCorpse` and death callbacks.
No native source is included in the mod. This evidence supports metadata flow,
not a claim of tested carry/save/network behavior.

## Prerequisite correction

The audit found and fixed a M.O.R.T.I.S. 0.11.1 sever rollback defect: failed
anatomy persistence previously reconstructed `disabled` from `attached`, losing
pre-existing disability. Rollback now restores both original fields independently
for the selected region and descendants. A malformed storage root is rejected
without replacing it. Host tests cover these failures, authority denial,
successful descendant detachment and repeated sever rejection.

## Superseding 0.10.0 source checkpoint

The historical custom command reconstruction above is disabled: it could not prove elapsed work. Current recovery uses shared native timed-action complete and its server duration with canonical validation. Client direct-command attempts are rejected. The native corpse/item constructor, ownership replication, save/reload and dedicated timing/cancellation checks remain unverified; see AUDIT_0_10_0.md.
