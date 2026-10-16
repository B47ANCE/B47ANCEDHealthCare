# Vanilla medication matrix — Build 42.20.3

This is a static audit of the installed Build 42.20.3 item scripts, inventory
context menu, `ISTakePillAction`, `ISEatFoodAction`, and decompiled native
`BodyDamage` from the installed `projectzomboid.jar`. It defines the boundary
medWorks must preserve. Runtime and network behavior remain separate gates.

## Two distinct consumption routes

### Drainable consumable route

The inventory menu treats a selected item as a pill only when every selection
has the `base:consumable` tag and is a `DrainableComboItem`. It no longer relies
on an item type beginning with `Pills`. The menu transfers the selected item to
the player's inventory if necessary, handles an eating mask, queues exactly one
`ISTakePillAction`, and then requests return to the original container.

`ISTakePillAction` revalidates the exact item by object ownership in local/server
play and by persistent item ID on a client. Client start reacquires the item by
ID. Running is allowed while walking or aiming but stops on running. Completion
delegates all medical interpretation and dose consumption to native
`BodyDamage:JustTookPill(item)`; a server then calls `sendPlayerEffects`.
The Lua action does not independently mutate medical stats or decrement the item.
Native `JustTookPill` applies its recognized effect, always applies the item's
script stress change, invokes a configured `OnEat` Lua callback when present,
then calls `UseAndSync` exactly once.

| Vanilla item | Script facts visible to Lua audit | Effect ownership |
| --- | --- | --- |
| `Base.Pills` | Drainable consumable, `UseDelta=0.1`, medical | Calls `PainMeds(0.45)` normally or `PainMeds(0.15)` above 10 intoxication |
| `Base.PillsAntiDep` | Drainable consumable, `UseDelta=0.1`, medical | Calls `BetaAntiDepress(0.3)` normally or `0.15` above 10 intoxication |
| `Base.PillsBeta` | Drainable consumable, `UseDelta=0.1`, medical | Calls `BetaBlockers(0.3)` normally or `0.15` above 10 intoxication |
| `Base.PillsSleepingTablets` | Drainable consumable, `UseDelta=0.1`, medical | Calls `SleepingTablet(0.1)` and increments an `IsoPlayer` sleeping-pill counter |
| `Base.PillsVitamins` | Drainable consumable, `UseDelta=0.2`, medical, `fatigueChange=-4`, `StressChange=1` | Adds full scripted fatigue change normally or half above 10 intoxication; shared processing also adds scripted stress |

The context-menu contract is intentionally tag-based and therefore already
permits modded drainable consumables. medWorks must not replace it with a fixed
vanilla item-ID list.

### Food/character-eat route

`Base.Antibiotics` is a `Food`, not a drainable pill. Its script declares
`Medical=true` and `ReduceInfectionPower=50`. It follows the general
`ISEatFoodAction`, which revalidates inventory ownership, supports incremental
consumption during the action, and delegates completion to
`IsoGameCharacter:Eat(item, percentage, useUtensil)`. It does not call
`JustTookPill` or `syncBodyPart`; the health panel's debug display reads the
character-level `getReduceInfectionPower()` value. Native `JustAteFood` sets
that character value to the food's declared power when positive; it does not
scale the assignment by the consumed percentage.

Native `BodyDamage:Update` consumes this power over time while removing
`CharacterStat.ZOMBIE_FEVER` and participating in the fake-infection recovery
path. It does not treat a particular BodyPart's local
`isInfectedWound`/wound-infection level. These are different systems; the field
must not be presented as a general wound antibiotic or cure for Knox infection.

## medWorks design consequences

- Preserve `ISTakePillAction` and `ISEatFoodAction` as vanilla transaction and
  animation boundaries. Do not duplicate their context options.
- Custom drainable medicine may use the generic consumable action, but native
  built-in pharmacology is hardcoded by exact vanilla item type. A consumable tag
  makes a modded item selectable; an `OnEat` callback or medWorks provider must
  define its effect without pretending native recognition exists.
- Custom food-form medicine must not assume `ReduceInfectionPower` is regional.
- Any medWorks dosing ledger, interaction, toxicity, anesthesia, or dependency
  effect must commit only after verified consumption and must tolerate action
  cancellation, item transfer, reconnect, and replay.
- Do not infer a consumed quantity from the requested `UseDelta`; read the
  post-completion item/native state or receive a verified completion report.
- Server `sendPlayerEffects` is evidence of a player-effect transport boundary,
  not proof that arbitrary medWorks modData or M.O.R.T.I.S. anatomy is included.
- M.O.R.T.I.S. remains the owner of non-player species anatomy. These player
  medicine paths are not generic zombie/animal treatment APIs.

## Runtime/native verification gates

- Runtime-test the stat/effect magnitudes verified from native
  `BodyDamage:JustTookPill`, including intoxication penalties, stacking, effect
  decay, sleeping-pill counter consequences, and persistence.
- Runtime-test `ReduceInfectionPower` assignment on partial antibiotic doses,
  item depletion, fake-infection recovery, save/load, and server authority.
- Verify `sendPlayerEffects` contents, client prediction, reconnect/late join,
  and dedicated-server behavior.
- Test interruption at partial progress, running cancellation, transfer between
  containers, death, disconnect, and repeated completion messages.
- Verify custom `OnEat` callbacks cannot double-consume or produce divergent
  client/server state when combined with native `UseAndSync`.

Until those gates pass, medWorks may expose observations and provider contracts
but must not claim a complete pharmacology or multiplayer medication system.
