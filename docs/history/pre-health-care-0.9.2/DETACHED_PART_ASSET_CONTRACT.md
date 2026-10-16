# Detached-part presentation: source evidence and integration gates

Inspected 2026-09-26. This records existing behavior, not a new visual API or
approval of native rendering. No runtime or frozen-candidate changes were made.

## Established item mapping

`src/medWorks/42/media/lua/shared/medWorks/init.lua` maps the neck to
`DetachedHead`; both arm sides to `DetachedArm`; both hand sides to
`DetachedHand`; both leg sides to `DetachedLeg`; and both foot sides to
`DetachedFoot`. The script file `medWorks_DetachedParts.txt` defines these five
items with the Bandage placeholder icon and no world-model assignment.

Thus five static item definitions do not imply five fully representative meshes.
A single left-hand mesh assigned to both sides would misrepresent some records.
Do not add separate item IDs or rewrite provenance merely to fit artwork.

Project M.O.R.T.I.S. `Definitions/CoreAnatomy.lua` defines hands as children of
arms and feet as children of legs. `Runtime/AnatomyRuntime.lua` collects attached
descendants for severance; medWorks also locks overlapping parent/child operations.
Before finishing arm/leg presentation, test a whole limb and a limb whose distal
part was already removed. Do not visually restore missing anatomy or assume every
arm output contains a hand. Separate editable distal geometry is appropriate for
source-art preparation; runtime mesh selection still needs engine evidence.

## Nightfall consumer boundary

`ProjectNightfall/PN_Effigies.lua` accepts human, regular, feral and smartFeral
provenance, rejects mixed signatures, and retains per-part records in composition.
Its `onObjectAdded` handler recognizes a dropped `ProjectNightfall.Effigy` item
through `object:getItem()` and registers its stored composition. The item currently
has a Bandage icon and no world model. A replacement must preserve this existing
item/world-object path, not replace it with a decorative object that loses state.

No composition-driven rendering adapter was established by this inspection.
A fixed head-and-arms effigy mesh must not be called composition-accurate for an
effigy built from other parts. Whether the first release uses a generic symbolic
model or fully composition-driven presentation needs an explicit visual decision;
the existing simulation alone does not settle that policy.

## Validation needed before integration is complete

- Correct item identity and unchanged provenance after pickup/drop and save/load.
- Left/right representation and parent-with/without-distal-part cases.
- Source-class appearance choices must not change gameplay classifications.
- Floor placement, scale, inventory readability and native texture resolution.
- Effigy world registration, consumption/destruction and reload retain composition.
- Hosted/dedicated authority and late-join presentation; host tests are insufficient.
- Attached-body visuals remain behind the roadmap's native render-hook proof gate.

Original source models and textures may be prepared without claiming these gates
passed. No third-party code or assets were used in this inspection.
