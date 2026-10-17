# B47ANCE'd Health Care 0.11.0 playtester handoff

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

## Optional Spectrum self-care (0.11.0)

With SPXTRM 0.30.0 or its compatible treatment-receipt API available, right-click a vanilla cold pack in your main inventory while you have documented sunburn. The native timed self-care action consumes the pack and reduces canonical Spectrum dose. It is self-only and server validated; no other-player treatment or free client RPC. Sandbox controls enablement, duration and reduction. Uncertain item/dose outcomes remain locked for inspection; see [current care validation](docs/VALIDATION_0_11_0.md)  Native SP/dedicated NOT TESTED; no package, deployment or upload.

0.10.1 changes thumbnail/poster artwork and future preview selection only. The subsequent explicit publish request distributed 0.10.1 to existing item 3788592396 for MP testing; see docs/WORKSHOP_UPLOAD_0_10_1.md. No local deployment/server changes. Verify the full Health Care poster and text in the mod selector; this visual check is currently NOT TESTED.

0.11.0 source adds View last examination. Following an explicitly requested test build/deployment, check that the option appears only after a completed observation and only for that local examiner/patient. Open and scroll the historical report; verify font/layout, mouse/keyboard/controller, split-screen window/focus isolation, expiry on reopening and unchanged game speed on close. An open report stays historical after expiry. No 0.11.0 package or deployment exists. Current Knowledge & Wisdom 0.16.0 blocks multiplayer storage; keep dedicated knowledge/recovery tests BLOCKED pending its owning-project fix. See docs/EXAMINATION_REPORTS.md and docs/VALIDATION_0_11_0.md.
