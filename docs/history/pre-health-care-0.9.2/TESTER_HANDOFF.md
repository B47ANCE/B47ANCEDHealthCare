# medWorks 0.8.2 playtester handoff

Begin only after the first two dependency-stage reports are reviewed as PASS.
Enable only ExperienceWorks, Project M.O.R.T.I.S., and medWorks on a disposable
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

Return `%USERPROFILE%\Zomboid\Lua\theWorks Test Results - medWorks.txt`,
`console.txt`, and screenshots for visual failures. Do not add powerWorks or
later Nightfall dependencies until this stage is reviewed.
