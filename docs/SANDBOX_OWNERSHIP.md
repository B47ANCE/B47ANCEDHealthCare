# Sandbox ownership

| Activity | Policy | Duration |
|---|---|---|
| Corpse recovery | EnableCorpseRecovery, RequireRecoveryKnowledge | CorpseRecoverySeconds (10–3600, default 120) |
| Local read-only examination | EnableExaminations | ExaminationSeconds (5–600, default 30) |

Recovery policy is rechecked in shared complete on the native server action path. Native server getDuration derives from server sandbox seconds, converted to 20 ms action units; caller-supplied completion messages cannot shortcut timing. Current native action behavior after live sandbox duration changes is a runtime gate, not a guarantee of mid-action rescheduling. Existing save keys and defaults remain stable.

Examination has no shared medical mutation. Its local enable/duration controls use world sandbox values for observation presentation. getDuration now converts seconds to action units, and completion occurs locally in perform. Missing or invalid duration values still use the existing clamp/default.

ExaminationMaxBodyParts was an exposed technical safety limit, not meaningful gameplay policy. It is no longer offered or consumed as a sandbox setting. Old save/config values remain untouched and are ignored. Default provider traversal is 32 with a hard internal ceiling of 64; registered provider callers retain their bounded maxBodyParts context argument. These limits protect work/memory, so they remain internal.

Generic procedure registry/transport internals, validation guards and UI coordinates are not sandbox settings. New clinical gameplay needs its own meaningful server-enforced policy once a procedure and authority/consent contract are established. No speculative global procedure bypass is added.
