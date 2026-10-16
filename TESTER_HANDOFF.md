# B47ANCE'd Health Care 0.10.0 playtester handoff

Begin only after the first two dependency-stage reports are reviewed as PASS.
Enable only B47ANCED Knowledge & Wisdom, Project M.O.R.T.I.S., and B47ANCE'd Health Care (`B47ANCEDHealthCare`) on a disposable
single-player save. Open the Lua debug console and run `medWorksTestStart(true)`.

1. Run `medWorksTestExamine()`, then confirm the console shows a readable examination and nothing was treated or changed.
2. Open your health panel and use **Perform examination**. Check that moving away cancels it and completing it shows a short result.
3. Read **Field Care: Safe Handling**. Confirm **Anatomical Recovery Manual** is locked beforehand and readable afterward; then run `medWorksTestKnowledge()`.
4. With a working saw in a bag, inspect a fresh zombie corpse. Clothing should block covered parts; removing the covering garment should expose the option.
5. Recover one body part. Confirm exactly one part appears and the same region, including its child region, cannot be recovered again.
6. Save/quit/reload. Confirm that region remains unavailable, then run `medWorksTestReload()`.
7. Change the visible recovery/examination enable switches and durations in a disposable world; verify menus and queued actions respect them.
8. Mark hosted/dedicated testing BLOCKED until actually performed.
9. Run `medWorksTestReport()`.

Return `%USERPROFILE%\Zomboid\Lua\B47ANCED Health Care Test Results.txt`,
`console.txt`, and screenshots for visual failures. Do not add powerWorks or
later Nightfall dependencies until this stage is reviewed.

MP testing build - dedicated multiplayer NOT TESTED. Prior 0.8.2/0.9.2 reports are historical. Activate B47ANCEDHealthCare, ProjectMORTIS and B47ANCEDKnowledgeAndWisdom; use a disposable save.

0.10.0 source changes native action routing and seconds conversion. Verify actual timing and native constructor arguments before expanding the procedure loop; the legacy direct recovery command must do nothing. No 0.10.0 package or deployment has been made by this development task.
