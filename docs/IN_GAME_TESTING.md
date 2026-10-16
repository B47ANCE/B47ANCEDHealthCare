# B47ANCE'd Health Care in-game validation

medWorks is stage 3 of the progressive Nightfall test. Begin only after the
B47ANCEDKnowledgeAndWisdom and Project M.O.R.T.I.S. reports are reviewed as PASS. Enable
only `B47ANCEDKnowledgeAndWisdom`, `ProjectMORTIS`, and `B47ANCEDHealthCare` on a disposable save.

## Commands

| Command | Purpose |
| --- | --- |
| `medWorksTestStart(true)` | Reset the session, validate all three mods, and write the first report. |
| `medWorksTestAuto()` | Recheck canonical APIs, medical research registration, diagnostics, and report writing. |
| `medWorksTestExamine()` | Run a read-only self-examination and verify that a bounded clinical report is produced. |
| `medWorksTestKnowledge()` | Verify the prompted medical reading has unlocked corpse recovery. |
| `medWorksTestReload()` | After save/quit/reload, prove the test session reached a new Lua runtime. |
| `medWorksTestPass("note")` | Mark the next pending manual observation PASS. |
| `medWorksTestFail("issue")` | Mark the next pending observation FAIL. |
| `medWorksTestBlocked("reason")` | Mark the next pending observation BLOCKED by an unavailable prerequisite. |
| `medWorksTestReport()` | Print and rewrite the complete report. |
| `medWorksTestWhere()` | Print the Windows result location. |

Every command rewrites `%USERPROFILE%\Zomboid\Lua\B47ANCED Health Care Test Results.txt`.
Host tests do not certify native timed actions, corpse lifecycle, rendering,
persistence, or multiplayer authority.
