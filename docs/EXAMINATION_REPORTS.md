# Detailed examination reports — 0.11.0 source

After completing Perform examination, reopen the body-region context menu for the same patient and select View last examination. The option is available only to the same local examiner while their session-local observation remains cached. The callback checks again, so an old menu cannot reopen an expired or different patient's report. No examination is started by viewing.

The scrolling window labels the recorded age at opening and explains that the contents are historical observations, not a diagnosis or live health reading. An open window remains a static snapshot after cache expiry; reopening requires a valid cache entry. No live patient data is read while rendering. Each local player has at most one report window; another local player cannot view the first examiner's cache. Reopening replaces only that player's window. Local examiner object replacement closes the old window. Patient object replacement cannot alias the old observation.

## Ownership and configuration

This is client presentation only. It reads CompletedExaminations, never writes ModData, sends commands, grants knowledge/XP, treats injuries, consumes items, or alters server-owned state. Local windows/caches are not saved or synchronized. Remote observation still uses the existing timed action and vanilla health-panel snapshot route. Snapshot freshness/privacy and invasive-care consent remain unproven gates; a report is no substitute for them.

Existing EnableExaminations and ExaminationSeconds control creating new observations. Existing recorded results can still be read after examinations are disabled. ExaminationSeconds defaults to 30 for absent/unparseable/NaN/infinite values and is clamped to 5–600 before conversion to 20 ms action units. New gameplay settings are unnecessary: viewport geometry, five-minute cache availability and traversal/text/count budgets are internal presentation/performance constraints.

## Defensive presentation

- At most 16 sections, 64 parts per section, 16 diagnostics and 80 lines, with 180 bytes per line and a visible truncation notice.
- Only finite numeric health/count values are formatted. Counts are nonnegative integers capped to the 64-part observation ceiling per section. Missing counts cannot be interpreted as a healthy examination; invalid entries are skipped safely.
- Provider data is plain text: angle brackets become inert square brackets, controls become spaces, strings are clipped before scanning, and UTF-8 character boundaries are preserved when truncating valid UTF-8 text. Only the viewer inserts LINE tags.
- Known human part labels, findings, summaries and viewer labels use 52 UI keys; the menu uses one ContextMenu key. All 29 locales carry the existing English-fallback policy. No new language translation quality is claimed. Provider IDs/free-form provider diagnostic text remain provider-owned data, safely bounded rather than automatically translated.
- Cache copies omit patients, functions, non-finite values and cycles; bound depth to 6, table nodes to 1024, attempted fields per table to 256, total visited fields to 4096, key lengths to 64 and strings to 180 bytes. Rejected/unsupported keys count toward the visit budget. Limit-induced omission is flagged for the viewer. Inspection returns detached copies.
- A finite nonnegative clock is required to publish/reopen. Timestamp zero still expires. Missing/invalid clocks or time going backwards invalidate the relevant cache rather than extending it indefinitely.

## Verified vanilla UI contract

Installed Steam build 25485521; full engine patch UNKNOWN. ISModalRichText provides a scrolling rich-text child and an OK controller button. Its constructor accepts player number; vanilla update sizes against the whole screen, and vanilla destroy alters paused-message visibility/game speed. Health Care supplies independent instance update/close methods: bounded centered layout in the selected viewport, reflow/scrollbar updates on resize, focus restoration only when this window owns focus, and no time-control calls. Viewports below 260x180 cannot open the viewer. No vanilla files are modified. API_EVIDENCE_0_11_0.json records source fingerprints/lines; three observations are also in the unmanaged local API draft catalog. This is source proof, not actual rendering/controller proof.

## Validation and remaining gates

20/20 isolated Lua 5.1 regressions PASS with Windows/bundled Python. The malformed-provider case failed against the previous formatter before implementation. New tests cover numeric/table/boolean malformed values, markup, line/section/part/count limits, UTF-8, translation/fallback, observer/patient isolation, menu availability, stale click, window replacement, viewport resize, focus/speed behavior, local-player replacement, cache zero/invalid/backward clocks, bounded copying and finite durations. UI/native APIs are stubs in these tests.

Actual PZ UI, mouse/keyboard/controller interaction, large fonts/UI scales, split-screen drawing, focus with other dialogs, health-panel integration and remote snapshots remain NOT TESTED. Required manual checks are in TESTING.md and TESTER_HANDOFF.md. No game/server launch, package, deployment or Workshop upload. Last distributed version remains 0.10.1.

The current Knowledge & Wisdom 0.16.0 dependency deliberately returns MULTIPLAYER_STORAGE_UNAVAILABLE for server reads/writes; knowledge-gated dedicated recovery is blocked. This change does not bypass it. The offline literature fixture now declares SP realm explicitly and verifies that the dedicated guard remains fail-closed. SPXTRM 0.30.0 has moved to its declared B47ANCEDSPXTRM source root while retaining lightWorks Lua imports; the host runner uses that verified root. Neither sibling repository was modified. Exact dependency versions, SHAs and fingerprints are in API_EVIDENCE_0_11_0.json.

G7 BLOCKED / NOT TESTED; stable G8 BLOCKED for the overall gameplay mod. Native recovery argument reconstruction/timing/sync, dedicated progression storage, live observation freshness and clinical authority/consent proof remain prerequisites before broader treatment work.
