# Sandbox ownership

medWorks exposes customization for every implemented player-facing activity:

| Activity | Enable/policy | Timing/budget |
|---|---|---|
| Corpse anatomical recovery | `EnableCorpseRecovery`, `RequireRecoveryKnowledge` | `CorpseRecoverySeconds` |
| Read-only patient examination | `EnableExaminations` | `ExaminationSeconds`, `ExaminationMaxBodyParts` |

Corpse recovery rechecks its enable and knowledge policies inside the shared
completion validator used by the authoritative server command. Hiding a client
menu is not treated as authorization. Timing is clamped in runtime to the same
bounds declared by `sandbox-options.txt`.

Examination currently presents a read-only observation and performs no
authoritative medical mutation. Its client-side enable and duration settings
therefore control presentation and work time only. Provider result size is
bounded by the shared examination layer.

The generic procedure registry deliberately has no global "allow procedures"
switch. Registered procedures are internal/public API contracts, and silently
disabling all of them would also change integration behavior without an
established product policy. New player-facing procedures must add their own
server-enforced policy controls when their behavior and consequences are
defined.

`test_sandbox_contract.lua` prevents option, translation, and runtime-consumer
drift. Native new-game UI presentation remains an in-game validation gate.
