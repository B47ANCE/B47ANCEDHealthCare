# Build 42 medical precedent and B47ANCE'd Health Care gap report

Status: public-description review completed 2026-08-31. Third-party claims are
not engine verification, compatibility certification, or permission to reuse
code, text, assets, data, or implementation structure.

## Current public precedents

| Project | Publicly described scope | medWorks consequence |
| --- | --- | --- |
| [Wounds Overhaul B42](https://steamcommunity.com/sharedfiles/filedetails/?id=3775026731) | Examination, staged sepsis, skill-sensitive stitching, optional blood typing/transfusion, organ consequences and granular sandbox controls; its page claims dedicated-server validation | Preserve medWorks' provider/authority design, test every action on a real dedicated server, and do not assume another overhaul can share canonical health state |
| [The Only Cure B42](https://steamcommunity.com/sharedfiles/filedetails/?id=3580276809) | Amputation and missing-limb gameplay with SP/MP claims and host-mode caveat | Keep amputation consequences/prosthetic fitting in medWorks while M.O.R.T.I.S. owns topology; require an explicit compatibility adapter rather than competing limb state |
| [Bruise System B42.20](https://steamcommunity.com/sharedfiles/filedetails/?id=3775583500) | Persistent body-part bruises, pain, physical penalties, treatment and multiplayer synchronization | A medWorks bruise condition would duplicate an active focused owner; prefer optional observation/provider compatibility unless a distinct unmet requirement appears |
| [Extensive Health Rework Evolved](https://steamcommunity.com/sharedfiles/filedetails/?id=3726328119) | Broad disease, symptom, medication, diagnostic, blood and knowledge systems; page describes Build 42.20 and cautions that MP can still contain bugs | Avoid a monolithic parallel health simulation; isolate conditions and procedures behind registries, persistence schemas and explicit ownership |
| [BB Common Sense Medical Rebooted](https://steamcommunity.com/sharedfiles/filedetails/?id=3727572012) | Doctor-skill timing, treatment failures, skill gates, corpse practice and per-feature sandbox controls without replacing the panel | Reuse vanilla actions for vanilla care, expose knowledge/skill policy through providers, and avoid duplicating its focused QoL behavior in medWorks core |
| [Physiks Medical Enhancements B42](https://steamcommunity.com/sharedfiles/filedetails/?id=3733672911) | WIP placed IV support and configurable medical-action slowdown; page claims server-authoritative world mutation | Treat placed equipment, interruption and server-owned item mutation as mandatory IV design gates; do not infer its implementation or stability |

Pages marked removed, incompatible, WIP, or unsupported by Steam remain useful
only as records of author-described player expectations. Workshop descriptions
cannot prove safe APIs, save compatibility or multiplayer correctness.

## medWorks differentiation

medWorks is not intended to win ownership of every medical mechanic. Its stable
core should provide:

- species-aware procedure, observation, reservation and recovery contracts;
- human BodyDamage adapters that preserve vanilla treatment state;
- Project M.O.R.T.I.S. topology/trauma integration without duplicating anatomy;
- authoritative detached-part recovery, later surgery and prosthetic fitting;
- B47ANCEDKnowledgeAndWisdom-owned knowledge and semantic progression;
- bounded diagnostics, sandbox controls and explicit third-party providers;
- no client-trusted mutations and no global corpse, patient or inventory scans.

## Feature decisions

| Feature family | Decision before runtime work |
| --- | --- |
| Basic bandage, disinfect, stitch, splint, glass/bullet removal, burn cleaning | Vanilla owns; medWorks may add audited depth, not replacements |
| Examination | Existing medWorks provider/timed-action layer; validate remote subscription and consent in game |
| Corpse anatomical recovery | Existing medWorks vertical slice; extend through canonical biological-material transactions for autopsy/harvesting |
| Bruising | Compatibility provider candidate; no first-party duplicate currently justified |
| Blood, IV and transfusion | Future medWorks-owned modular procedure family after exact item/network/condition contracts |
| Anesthesia and surgery | Future medWorks-owned procedure family with knowledge, risk, interruption and recovery state |
| Living amputation/prosthetics | medWorks procedure/consequence owner over M.O.R.T.I.S. anatomy; compatibility work required for existing limb mods |
| Disease/sepsis | Registry-based future conditions only; no global health replacement |
| Veterinary medicine | animalWorks content consuming generic medWorks procedures |

## Ordered implementation gaps

1. Complete in-game validation of existing examination and corpse recovery.
2. Add a corpse autopsy/biological-harvest vertical slice using the canonical
   Project M.O.R.T.I.S. material API; no new BodyDamage setters are required.
3. Add one controlled custom condition only after its persistence, symptoms,
   treatment and network ownership are independently auditable.
4. Design blood/IV storage and procedures with server-owned item transactions.
5. Add anesthesia and surgery, then living amputation and prosthetic fitting.
6. Expand disease/sepsis and veterinary consumers only after the generic
   condition/procedure contracts survive hosted and dedicated testing.

## Compatibility posture

Health-overhaul coexistence is not assumed. medWorks should detect optional
providers and fail closed on overlapping ownership. Compatibility patches may
translate observation or procedure results, but must never mirror two canonical
states or silently overwrite another mod's injury, blood, limb or disease data.
