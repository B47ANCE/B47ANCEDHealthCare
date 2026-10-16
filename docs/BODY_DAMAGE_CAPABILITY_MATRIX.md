# Build 42 human BodyDamage capability matrix

Status: static Build 42.20 evidence complete; runtime and multiplayer gates remain.

This matrix classifies the installed human-health surface used by medWorks. It
is derived from the exposed native signatures and installed Lua call-site leads
captured in `audit/native-api.csv`, plus the action and network traces in
`VANILLA_TREATMENT_MATRIX.md` and `HEALTH_PANEL_INTEGRATION.md`. A public Java
signature proves availability to the exposed class, not safe execution on every
receiver, authority role, or remote snapshot.

## Capability decisions

| Surface | Static evidence | medWorks decision | Remaining proof |
| --- | --- | --- | --- |
| `BodyDamage:getBodyParts()` / `getBodyPart(BodyPartType)` | Exposed; installed Lua call-site leads | Supported bounded read adapter for human patients | Real self, local-other, remote-other, reconnect |
| `BodyPart:getType()`, `getHealth()`, `HasInjury()` | Exposed and used by installed UI/actions | Safe observation after receiver/type validation | Malformed providers and remote snapshots |
| Scratch, cut, bite, bleed, burn, deep wound, stitch, glass, bullet and fracture getters | Exposed; relevant getters have installed UI/action leads | Observation only; preserve native state ownership | Verify values during actions, cancellation and reload |
| Bandage, splint, alcohol/disinfection, pain and wound-infection getters | Exposed with installed treatment/UI leads | Observation only; local wound infection is not Knox infection | Treatment decay, serialization and remote differential updates |
| BodyPart mutation setters | Exposed; vanilla actions use specific setters and synchronization masks | Provider-specific mutation only after an audited procedure contract | Exact masks, authority, rollback and dedicated-server replication |
| `SetCauterized` | Exposed; no installed Lua use found; native behavior clears several injury states | Rejected as a generic condition flag; no medWorks action yet | Full consequence and packet-mask proof before any procedure |
| `BodyDamageRemote` | Vanilla health panel maintains a disposable server-fed snapshot | Read-only remote examination input | Subscription lifecycle, consent policy, late join and disconnect |
| `syncBodyPart` / `BodyPartSyncPacket` | Server-only IsoPlayer packet with a fixed human field mask | Human-player transport only; never species-generic M.O.R.T.I.S. replication | Hosted/dedicated execution and reconciliation |
| M.O.R.T.I.S. anatomy/trauma | Separate species-generic API and persistence contract | Canonical non-vanilla anatomy owner | Engine sever visuals and multiplayer transport |

## Observation allow-list

The current examination adapter may read only bounded, validated values from:

- body-part identity, health and `HasInjury`;
- scratch/cut/bite/bleeding and their timers;
- burn, deep wound, stitch, glass, bullet, fracture and splint state;
- bandage life/type, alcohol/disinfection and additional pain;
- local wound infection and wound-infection level.

These observations may describe what a provider saw. They do not grant mutation
authority, diagnose Knox infection, prove consent, or make a remote snapshot
canonical.

## Mutation rule

No generic setter passthrough will be exposed. Each medWorks procedure must name
its exact patient kind, preconditions, affected native fields, rollback limits,
server command, synchronization route, semantic experience event and recovery
quarantine behavior. Existing vanilla actions remain the owner for ordinary
bandaging, disinfecting, stitching, splinting, glass/bullet removal and burn
cleaning unless a later audited extension adds materially different behavior.

## Rejected shortcuts

- Do not extend `BodyPartType` or map arbitrary species into the human enum.
- Do not write `BodyDamageRemote`; it is a disposable observation snapshot.
- Do not use `syncBodyPart` for zombies, animals, NPC anatomy or detached parts.
- Do not equate `isInfectedWound` with Knox infection.
- Do not use `SetCauterized` as a harmless medWorks marker.
- Do not infer an overload, receiver type, side effect or packet route from a
  name match in the generated CSV.

## Release gates

Static API coverage is complete enough to constrain further vertical slices.
Actual treatment outcomes, interruption, save/load, local-other treatment,
remote subscription/consent, late join, reconnect and dedicated-server packet
behavior remain in-game gates and must not be represented as certified.
