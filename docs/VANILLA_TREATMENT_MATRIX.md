# Vanilla medical treatment matrix — Build 42.20.3

This is a static source audit of the installed Build 42.20.3 Lua under
`media/lua/shared/TimedActions` and the client `ISHealthPanel`. It records the
boundary medWorks must preserve; it is not proof of runtime or multiplayer
behavior. Method calls were inspected in their complete source files rather than
treated as valid merely because a name appeared in a search result.

## Shared action lifecycle

All ten inspected body-part treatments derive from `ISBaseTimedAction`. They use
`ISHealthPanel.DidPatientMove` to invalidate treatment after the patient moves,
turn toward another patient in `waitToStart`, register a per-player/body-part
action while running, and clear that registration on stop/perform. Their normal
presentation is the Bandage animation (with Loot fallback), and stop paths clear
job progress where an item exposes it. Completion owns mutations; interruption
does not call the completion mutation path.

Client-side health-panel handlers can first queue transfers into the doctor's
inventory and then queue the treatment with `ISTimedActionQueue.addAfter`.
Consequently, a medWorks extension must revalidate actual item identity and
ownership at completion rather than assuming that menu-time availability or a
queued transfer still proves access.

## Treatment inventory

| Action | Start/revalidation inputs | Completion effects | Consumption/output | XP call | Native sync mask |
| --- | --- | --- | --- | --- | --- |
| Apply/remove bandage | Patient movement; exact selected item remains in doctor inventory when applying | `BodyDamage:SetBandaged`; optional dirty-bandage infection roll; clears manipulating user | Apply removes exact bandage; removal returns recorded bandage type and uses it | Doctor 5, conditional on application | `0xc001966b8e` |
| Disinfect | Patient movement; exact alcohol item remains in doctor inventory | Adds alcohol power and skill-adjusted pain | `UseAndSync` on disinfectant | None observed | `0x00608200` |
| Stitch/remove stitch | Patient movement; exact thread/needle remains in inventory when stitching | Stitched flag, stitch time, pain; failed low-skill work can set local wound infection | `UseAndSync` except reusable suture needle; holder/needle changes time and outcome | Doctor 15, conditional on stitching | `0x00570188` |
| Apply/remove splint | Patient movement; exact cloth and plank, or recorded splint item | Splint flag/factor and recorded splint item | Apply removes components; removal reconstructs recorded items | Doctor 15, conditional on application | `0x430000000` |
| Remove glass | Patient movement; UI distinguishes bare-hand versus tool route | Clears glass; adds skill/tool-dependent pain | No treatment item consumed by the action | Doctor 15 | `0x00480000` |
| Remove bullet | Patient movement | Clears bullet with doctor level; adds skill-dependent pain | Health panel requires/queues its selected item, but the action itself does not consume it | Doctor 20 | `0x40460108` |
| Clean burn | Patient movement | Clears burn-wash requirement; adds skill-dependent pain | `UseAndSync` on selected bandage | Doctor 10 | `0x380400000` |
| Plantain cataplasm | Patient movement; exact item remains in inventory | Sets plantain factor using doctor skill and item power | Removes exact item and sends container removal | None observed | `0x0000000800000000` |
| Comfrey cataplasm | Patient movement; exact item remains in inventory | Sets comfrey factor using doctor skill and item power | Removes exact item and sends container removal | None observed | `0x0000001000000000` |
| Garlic cataplasm | Patient movement; exact item remains in inventory | Sets garlic factor using doctor skill and item power | Removes exact item and sends container removal | None observed | `0x0000002000000000` |

The hexadecimal masks document the installed vanilla calls only. They are not
general-purpose constants for medWorks procedures. A new procedure must identify
its own mutated fields and verified synchronization contract.

## Ownership decisions

- medWorks must not replace these actions merely to rename or rebalance them.
- Extensions may add procedure quality, diagnosis, complications, or recovery
  only when they preserve the native fields and completion/interrupt boundary.
- Local wound infection fields are never evidence of Knox infection.
- `syncBodyPart` is player-specific: its packet casts the parent to `IsoPlayer`.
  It cannot synchronize M.O.R.T.I.S. zombie/animal anatomy.
- Native Doctor XP remains vanilla-owned. New semantic procedure credit uses
  B47ANCEDKnowledgeAndWisdom after authoritative medWorks commit and must not double-award
  the vanilla action.
- Item transfers, patient movement, doctor/patient death, disconnect, and exact
  body-part ownership remain completion-time validation requirements.

## Adjacent vanilla systems

Common medication is not implemented by a body-part treatment timed action in
this inventory. Eating/using consumables routes through the general food/item
use system and native stats; medWorks must audit each candidate medicine there
before adding pharmacology. `ISCleanBandage` is item maintenance rather than
patient treatment. Washing characters/clothing and removing world glass are
also separate domains despite similar names.

## Evidence still requiring runtime verification

- Whether every action's patient-facing progress and cancellation state is
  correctly visible to remote players on hosted and dedicated servers.
- Exact client/server ownership around health-panel handlers, queued inventory
  transfers, `UseAndSync`, container messages, and `syncBodyPart`.
- Disconnect/reconnect, death during treatment, late join, and simultaneous
  doctors targeting one body part.
- Native animation fallback, sounds, item-model presentation, and action timing.
- Save/load behavior while an action is queued or a custom medWorks reservation
  is uncertain.

These are in-game gates. Static source evidence is sufficient to design a
compatible transaction boundary, but not to claim multiplayer certification.
