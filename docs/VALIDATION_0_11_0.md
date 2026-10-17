# Health Care combined source validation

Current version: 0.11.0.

This merges the two compatible, unreleased MINOR feature branches: localized
examination reports and authoritative optional cold-pack self-care. No public
identifier, save schema, dependency identity, Workshop item or source root changes.
The last confirmed Workshop distribution stays 0.10.1; this is source-only work.

Original branch reports are preserved byte-for-byte under
`history/0.11.0-branches/` and listed below. Their prior passes remain tied to
their original branches, not combined runtime proof. The integration resolves
dictionary additions, documentation, current distribution metadata and equivalent
SP-role fixture setup. Production modules merge without source conflict edits.
The newer malformed-provider/cache/expiry and unavailable-MP-storage checks remain;
native timed self-care, exact consumed supply, canonical dose receipts and
uncertain-operation locks remain unchanged.

Combined offline validation is recorded after running:

[TESTED, offline Windows Python 3.12 / Lua 5.1] Combined suite: 22/22 host
regression files PASS. All 12 current version mirrors pass; source validation
passes for 148 authoring files, 22 Lua modules, exact requires, 29 fallback locales,
artwork and Workshop identities/text. Both report-viewer and cold-pack receipt/
recovery fixtures run in the same combined tree. Source checks are not native
timed-action, UI or multiplayer evidence.

An initial combined run exposed a nondeterministic existing harness fixture:
its same-VM module reload could reuse a collected temporary table address and
produce the same string identity. The fixture now stops GC during that simulated
reload and restarts it afterward; assertions and production diagnostic behavior
are unchanged. This stabilizes the host experiment, not proof of a native restart.

```text
python scripts/check_versions.py
python scripts/validate_source.py
python scripts/run_host_tests.py --dependencies <verified-developer-mod-root>
python scripts/check_public_tree.py
git diff --cached --check
```

[RUNTIME GATE] PZ/SP/dedicated NOT TESTED. G7 BLOCKED / NOT TESTED; stable G8 BLOCKED.
Knowledge & Wisdom's multiplayer storage refusal remains in force. No package,
deployment, game/server launch, Workshop upload or Steam restart.

Preserved branch report hashes:
- `docs/history/0.11.0-branches/coldpack-validation.md`: `a14e37229327ba4ecc25c472da75258bb5bcd4831cf8ed035a86d09d2e893aed`
- `docs/history/0.11.0-branches/examination-validation.md`: `e58af336037f886df26670183530ab095ffd6e77bc66de33185c5e437b9c13af`
