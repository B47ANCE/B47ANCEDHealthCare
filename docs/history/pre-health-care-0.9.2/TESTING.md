# medWorks 0.9.2 testing

Automated cases in the suite include `test_severing`, `test_procedure_runtime`,
`test_sever_transaction`, `test_corpse_recovery`,
`test_corpse_recovery_server`, `test_corpse_recovery_client`, `test_examination`, and
`test_examination_action`. They cover authority, replay, event isolation, nested
tools, range, missing provenance, completed/repeated actions, menu callback
safety, insertion failure/no-op, rollback, overlapping callbacks and quarantine.
They also cover verified quarantine inspection/reconciliation for both an orphaned
staged output and an anatomy transition that committed before throwing.
They do not execute native game timing, serialization, models or networking.

`test_sunburn_treatment` covers bounded source/amount validation, canonical
medWorks reservation and skin locking, lightWorks dose/severity mutation,
operation replay rejection, and client-authority rejection. In game, verify the
optional module does not affect standalone medWorks loading and that remote
patient state replicates before adding a concrete topical item/action.

`test_load_graph` executes both production loaders with isolated module stubs.
It verifies that the optional sunburn provider is requested exactly once on the
client and server paths and that the client loads the corpse-recovery interaction
after its transport alongside the established medWorks runtime modules.

The procedure-runtime case covers independent/provider-shared resource keys,
conflict rejection, pre-execution cancellation, completion revalidation,
definitive failure, uncertain execution, explicit recovery, and replay denial.

The examination case covers provider ordering, provider-failure containment,
bounded BodyPart traversal, normalized injury fields, unsupported patients, and
the invariant that Knox infection is never queried or conflated with local wound
infection. Native UI and remote-player behavior remain in-game gates.

The timed-action case covers duration clamps, range, movement, death, one-shot
completion, bounded/sanitized report formatting, local-infection wording, the
health-panel wrapper, queueing, and its sandbox disable switch. Native panel
layout, vanilla remote consent, and network replication remain in-game gates.

## In game

Use the dependency-ordered guided commands and report format in
[IN_GAME_TESTING.md](IN_GAME_TESTING.md). Mocked harness execution is not an
in-game PASS.

0. Open the vanilla health panel, right-click a body region, and choose **Perform
   examination**. Verify the duration setting, movement/range cancellation,
   concise overhead result, detailed console report, and no treatment mutation.
   Repeat through another player's accepted vanilla medical-check request.

1. Enable medWorks and required dependencies. Kill a newly loaded typed zombie
   after M.O.R.T.I.S. 0.11.2 is loaded; keep a working Saw/Garden Saw in a bag.
2. Stand within two tiles, right-click the body, choose **Recover body part**.
   A clothed region must be unavailable with an access explanation. Remove its
   covering garments through corpse inventory and retry. Torn clothing still
   obstructs access; unrelated clothing must not block the selected region.
   Confirm duration matches the sandbox value and movement cancels without output.
3. Complete one action: exactly one part appears, retaining original source type.
   Repeat on the same region: unavailable. Removing an arm also excludes its hand.
4. Queue recovery then move/remove/break the saw, move or drag the corpse, or have
   another action recover the region first. Completion must not create a duplicate.
   If clothing is equipped over the target region while recovery is queued,
   completion must reject without producing a part or awarding XP.
5. Try across walls/floors, outside range, unknown old corpses, and unsupported
   objects. No valid action and no context-menu errors should occur.
6. Save/reload and repeat: severed regions stay unavailable. Verify source
   classification through Nightfall's effigy construction and reaction tests.
7. Disable corpse recovery and vary duration in sandbox. Confirm both menu and
   already-queued completion respect the current setting.
8. Repeat with hosted/remote/dedicated clients. Verify the remote client sends one
   request, the server returns exactly one part, replay cannot duplicate it, and
   stale corpse/tool identities reject. Check corpse ModData and inventory
   replication. Multiplayer remains unverified until this is recorded.
9. For a deliberately quarantined developer fixture, call
   `medWorks.inspectSeverRecovery(source, inventory)`, then
   `medWorks.resolveSeverRecovery(source, inventory)`. An attached source must
   remove every matching staged output before unlocking; a committed detached
   source may unlock but must remain impossible to sever again. Duplicate or
   uninspectable output fails closed.

Inspect console for medWorks, MORTIS and ProjectNightfall errors afterward.
Human corpse origin, rendered limb removal, and broader clinical knowledge remain
unfinished; no stability claim is implied by host-test success.

Version 0.9.0 tests completed-examination scoping, detached report copies,
non-serializable fact removal, expiry, and publication only after successful
timed-action completion. In game, verify local and consented remote patients,
expiration, recreated player objects, disconnect, and split-screen isolation.
