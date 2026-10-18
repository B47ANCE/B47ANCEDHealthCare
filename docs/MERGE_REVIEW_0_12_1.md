# Owner-authorized source/provenance review — 0.12.1

Date: 2026-10-18, America/Phoenix. Request: use the approved cutout as the mod
icon, keep the thumbnail unchanged, merge all open PRs and publish after checks.
Owner B47ANCE explicitly authorized self-merge. The global owner self-merge
policy permits this without another developer approval after applicable checks.

Review scope: PR #7 at `5ec0615f21baad5d4635f991d77579e67d9507c1`, PR #8 at
`83a3f9e0876f392a989ffa4ba54fc37fe63576db`, and this additive 0.12.1 icon patch.
Review signoff: Codex release task, source/provenance review under the owner's
explicit merge authorization. This is the same authoring session, **not an
independent review**, legal clearance, GitHub review approval or runtime PASS.
The earlier independent-review checkboxes remain historical pending records;
they are not silently relabelled as independent PASS. Owner self-merge is the
selected approval path for this request.

## Clean-room and compatibility checklist

- [x] PR #7 is a neutral audit/specification with bounded source fingerprints, not transplanted implementation. Third-party identity, GPL-3.0 license, prior source exposure and limitations are disclosed.
- [x] PR #8 adds original client-only adapter/report code. Foreign module/API/schema identifiers are used for interoperability; no upstream implementation bodies, algorithms, balancing values, UI prose, translations or assets are bundled. Original files are not modified. Exact supported external version is 3.2.0; no automatic future-version promise.
- [x] Adapter rejects server, remote, wrong local object, conflicting original mod, unsupported/unready or malformed state. It reads only existing structural facts, returns bounded detached data and rechecks identity/readiness/activation. No initialization/migration, RPC, ModData write, clinical effect, XP/material or MORTIS topology operation is added.
- [x] Mobility evaluation and upstream clinical transports are not used. Reports separate structural loss/support from native health, and historical rendering does not query the original. Original general-action wear/bleeding hooks remain a documented native coexistence gate.
- [x] MORTIS, Knowledge & Wisdom, existing action authority and replay protections are unchanged. Dedicated storage remains fail-closed; its missing functionality is disclosed rather than bypassed. No new gameplay configuration is required for this presentation slice.
- [x] 0.12.1 changes the approved icon and metadata only. User-provided thumbnail/poster/preview and the previous icon are retained with hashes. Generated icon source/prompt are retained as authoring inputs, not foreign assets or runtime dependencies.
- [x] Current version mirrors, source inventory, README, changelog, testing/handoff, feature overview and Workshop drafts are synchronized. Historical validation and package evidence remain untouched.

[TESTED — offline] Version/source checks and 24/24 Lua 5.1 host regressions pass
on the cumulative source. Source inspection finds no introduced authority or
provenance blocker to the explicitly authorized Workshop MP test upload. Native
SP/split-screen/hosted/dedicated compatibility, actual action timing and original
hook interactions remain NOT TESTED. G7 and stable G8 stay BLOCKED.

GitHub reports no configured PR check runs and main has no branch protection;
no CI success is fabricated, no required check is bypassed and no settings are
changed. Local required checks are recorded in VALIDATION_0_12_1.md. Merge each
stacked PR into its parent, then main, verifying the final tree equals the checked
payload. Package/upload provenance must bind that final main commit. No stable tag,
local deployment, server change or Steam desktop restart is authorized by this review.
