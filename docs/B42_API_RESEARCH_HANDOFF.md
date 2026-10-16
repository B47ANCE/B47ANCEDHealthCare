> Historical research brief: current source, AUDIT_0_10_0.md and MASTER_ROADMAP.md define implementation status and priorities. Proposed capabilities below are not runtime proof or approval to bypass authority/API gates.

# B47ANCE'd Health Care — PROJECT ZOMBOID BUILD 42 HEALTHCARE SYSTEM API DEEP-DIVE
# Vanilla Healthcare Audit, Medical Framework, Procedures, Equipment,
# Pharmaceuticals, Diagnostics & Cross-Works Integration

TARGET:
Project Zomboid Build 42.x current stable branch.

PROJECT:
MedWorks

MISSION:
Transform Project Zomboid's existing first-aid mechanics into a coherent
healthcare framework without replacing the vanilla BodyDamage system.

MedWorks should improve:

- first aid;
- trauma care;
- wound management;
- infection management;
- burns;
- fractures;
- medication;
- diagnostics;
- clinical procedures;
- medical equipment;
- IV/fluid therapy where feasible;
- blood management where feasible;
- surgery/procedure infrastructure;
- recovery;
- medical skill/knowledge progression.

M.O.R.T.I.S. remains the anatomical/body-structure framework.

======================================================================
0. FUNDAMENTAL ARCHITECTURAL RULE
======================================================================

DO NOT BUILD A SECOND BODY DAMAGE SYSTEM.

Project Zomboid already provides:

    BodyDamage
        ↓
    BodyPart
        ↓
    localized injury states

MedWorks should become:

    Vanilla BodyDamage
            ↓
    MedWorks Clinical Adapter
            ↓
    diagnosis
    treatment
    medication
    procedures
    equipment
    recovery
    healthcare APIs

M.O.R.T.I.S. extends:

    anatomy
    structural body state
    limb state
    limb loss
    limb containers
    prosthetic attachment points
    anatomical procedures

MedWorks consumes M.O.R.T.I.S. anatomy when installed.

======================================================================
1. IMPLEMENTATION CONFIDENCE
======================================================================

Every feature must be classified:

CONFIRMED
    Proven against current B42 runtime/repository.

HIGH
    Appropriate vanilla API exists and implementation is straightforward,
    but production implementation still requires testing.

EXPERIMENTAL
    Engine primitives appear sufficient but exact behavior/API access
    requires a technical spike.

BLOCKED
    Current API cannot support a clean implementation.

UNVERIFIED
    Documentation suggests support but current B42 runtime has not been
    checked.

IMPORTANT:

OLD JAVADOC METHOD
!=
CURRENT B42 LUA CONTRACT.

Codex must audit installed B42 files.

======================================================================
2. VANILLA BODY MODEL
======================================================================

Project Zomboid BodyDamage contains a collection of BodyPart objects.

BodyPartType exposes:

    Head

    Neck

    Torso_Upper
    Torso_Lower

    Groin

    UpperArm_L
    UpperArm_R

    ForeArm_L
    ForeArm_R

    Hand_L
    Hand_R

    UpperLeg_L
    UpperLeg_R

    LowerLeg_L
    LowerLeg_R

    Foot_L
    Foot_R

This should remain the canonical vanilla medical-region mapping.

MedWorks must not invent incompatible body regions for ordinary treatment.

M.O.R.T.I.S. may provide finer anatomical structure beneath these regions.

======================================================================
3. BODYDAMAGE API
======================================================================

Research confirms BodyDamage exposes substantial health information.

Important concepts include:

    getBodyPart(type)
    getBodyParts()
    getBodyPartHealth(...)
    getHealth()

    AddDamage(...)
    AddGeneralHealth(...)
    ReduceGeneralHealth(...)

    doesBodyPartHaveInjury(...)
    HasInjury()

    isBodyPartBleeding(...)
    getNumPartsBleeding()
    getNumPartsScratched()
    getNumPartsBitten()

    IsBandaged(...)
    IsDeepWounded(...)
    IsBitten(...)

    infection state
    apparent infection state

    cold state
    wetness
    sickness-related state

MedWorks should create adapters around this rather than directly scattering
BodyDamage calls throughout the project.

======================================================================
4. BODYPART API
======================================================================

BodyPart is substantially richer than simply:

    health = 100

Research exposes concepts including:

    health

    bandaged
    bandageLife
    bandageType
    dirty bandage

    bitten

    scratched

    cut

    bleeding
    bleedingTime
    bleeding stemmed

    deep wound

    embedded glass

    embedded bullet

    burn
    burn time
    burn washing

    fracture
    fracture time

    splint
    splint factor

    stitched
    stitch time

    wound infection

    pain

    alcohol/disinfectant state

    stiffness

This is an excellent foundation.

======================================================================
5. VANILLA INJURY TYPES
======================================================================

Treat as first-class adapters:

SCRATCH

CUT / LACERATION

BITE

DEEP WOUND

GLASS WOUND

BULLET / FIREARM WOUND

BURN

FRACTURE

BLEEDING

LOCAL WOUND INFECTION

BANDAGED WOUND

SUTURED WOUND

SPLINTED FRACTURE

Do not replace these with:

    MedWorksScratch
    MedWorksBurn
    MedWorksFracture

unless absolutely necessary.

Wrap vanilla state.

======================================================================
6. VANILLA HEALTHCARE LOOP
======================================================================

Vanilla largely operates around:

    Injury
       ↓
    inspect Health panel
       ↓
    perform contextual treatment
       ↓
    bandage / disinfect / suture / splint / remove object
       ↓
    wait for recovery

MedWorks should deepen each stage:

    INJURY
       ↓
    ASSESSMENT
       ↓
    DIAGNOSIS
       ↓
    STABILIZATION
       ↓
    TREATMENT
       ↓
    AFTERCARE
       ↓
    RECOVERY

This is the core gameplay expansion.

======================================================================
7. CLINICAL ADAPTER
======================================================================

Proposed abstraction:

MedWorks.Patient

Provides normalized access to:

    character
    BodyDamage
    BodyParts
    injuries
    vitals
    treatment state
    medication state
    procedure state

Example conceptual API:

    MedWorks.Patient.get(character)

    patient:getBodyRegion(...)
    patient:getInjuries()
    patient:getBleeding()
    patient:getPain()
    patient:getTreatments()

Do not finalize API names before repository audit.

======================================================================
8. INJURY ADAPTER
======================================================================

Create normalized injury representation.

Concept:

MedWorks.Injury

Properties:

    type
    bodyPart
    severity
    bleeding
    contamination
    infection
    foreignObject
    treatmentState
    pain
    healingState

Backing data remains vanilla whenever possible.

This allows medical content to interact with injuries generically.

======================================================================
9. BLEEDING
======================================================================

Vanilla already models localized bleeding.

MedWorks should extend management options.

Potential treatments:

    direct pressure
    bandage
    pressure dressing
    wound packing
    tourniquet
    hemostatic dressing

Do NOT simply create stronger bandages.

Different interventions should have different purposes.

======================================================================
10. DIRECT PRESSURE
======================================================================

Add emergency action:

    Apply Pressure

Requires:

    hand availability
    suitable cloth/dressing optionally

Effect:

    temporarily reduce bleeding

Tradeoff:

    occupies character
    interrupted by movement/combat

Excellent early-game stabilization mechanic.

FEASIBILITY:
HIGH.

======================================================================
11. PRESSURE DRESSINGS
======================================================================

More effective than ordinary dressing for serious bleeding.

Potential:

    gauze
    elastic wrap
    pressure bandage

Effect:

    bleeding control

Not necessarily:

    infection treatment.

FEASIBILITY:
HIGH.

======================================================================
12. WOUND PACKING
======================================================================

Potential for deep wounds.

Requires:

    gauze / suitable packing material

Effect:

    strong bleeding control

May require later removal/replacement.

Do not use on every wound type.

FEASIBILITY:
HIGH.

======================================================================
13. TOURNIQUETS
======================================================================

Excellent M.O.R.T.I.S./MedWorks crossover.

Valid only for suitable limb regions.

MedWorks owns:

    tourniquet item
    application procedure
    bleeding-control effect
    timing/medical consequence

M.O.R.T.I.S. provides:

    limb topology / anatomical validity.

Potential consequences:

    severe bleeding reduction

but prolonged use:

    tissue damage
    ischemic consequences
    potential limb viability effects

Do not model limb destruction in MedWorks.

Delegate structural consequence to M.O.R.T.I.S.

FEASIBILITY:
HIGH with custom metadata.

======================================================================
14. BANDAGES
======================================================================

Vanilla already supports:

    bandaged state
    bandage type
    bandage life
    dirty bandage

MedWorks should extend the dressing ecosystem.

Possible:

    improvised cloth
    sterile gauze
    adhesive dressing
    pressure dressing
    burn dressing
    hemostatic dressing

Each should map into vanilla bandage behavior where possible.

======================================================================
15. STERILITY
======================================================================

Introduce reusable sterility abstraction.

Possible states:

    STERILE
    CLEAN
    DIRTY
    CONTAMINATED

Applicable to:

    dressings
    tools
    procedure surfaces
    surgical instruments

This is separate from item condition.

A perfect-condition scalpel can still be contaminated.

======================================================================
16. DISINFECTION
======================================================================

Vanilla already has wound disinfectant/alcohol-related treatment state.

MedWorks should adapt it.

Potential antiseptics:

    alcohol
    disinfectant
    iodine-type antiseptic
    appropriate medical antiseptic

Avoid redundant chemicals with identical mechanics.

Different products may have:

    effectiveness
    pain
    quantity
    suitability.

======================================================================
17. WOUND IRRIGATION
======================================================================

New procedure:

    Irrigate Wound

Consumes:

    clean/sterile water or saline

Removes/reduces:

    contamination
    debris

waterWorks integration:

    waterWorks can report whether supplied water is medically appropriate.

MedWorks owns wound consequence.

Excellent ecosystem integration.

======================================================================
18. SALINE
======================================================================

Add medical saline as a fluid/item concept.

Uses:

    wound irrigation
    IV therapy
    procedural cleaning

If B42 FluidContainer integration proves appropriate:

represent saline as an actual fluid.

Otherwise use medical consumable abstraction.

Prototype first.

======================================================================
19. SUTURES
======================================================================

Vanilla already models:

    stitched
    stitch time

MedWorks should preserve this.

Potential expansion:

    suture kit
    needle
    thread
    surgical suture

Skill and equipment affect:

    procedure time
    pain
    contamination risk
    healing outcome

Do not create a parallel stitched state.

======================================================================
20. STAPLES
======================================================================

Potential alternative closure method.

Add:

    skin stapler
    staple remover

Useful for certain wounds.

State can map onto vanilla closure/healing where possible.

FEASIBILITY:
HIGH.

======================================================================
21. ADHESIVE CLOSURE STRIPS
======================================================================

Potential treatment for smaller lacerations.

Less invasive than sutures.

Historically appropriate.

Useful for creating treatment progression.

======================================================================
22. EMBEDDED GLASS
======================================================================

Vanilla explicitly tracks embedded glass.

MedWorks should improve extraction.

Possible equipment:

    tweezers
    forceps

Skill affects:

    pain
    bleeding
    additional tissue damage
    contamination

Use vanilla glass state as canonical.

======================================================================
23. BULLETS
======================================================================

Vanilla BodyPart tracks embedded bullets.

MedWorks can substantially deepen firearm trauma.

Possible workflow:

    control bleeding
        ↓
    assess wound
        ↓
    remove projectile when appropriate
        ↓
    irrigate
        ↓
    close/pack
        ↓
    dress
        ↓
    monitor infection

Do NOT assume every gunshot requires bullet removal.

Gameplay should not teach obviously bad medical rules.

======================================================================
24. FIREARM TRAUMA
======================================================================

Potential advanced metadata:

    entry wound
    projectile retained
    tissue severity

True ballistic anatomy belongs to M.O.R.T.I.S. if ever implemented.

Initial MedWorks should adapt vanilla bullet/deep-wound states.

======================================================================
25. FRACTURES
======================================================================

Vanilla already tracks:

    fracture time
    splinted
    splint factor

MedWorks should deepen fracture treatment.

Potential:

    improvised splint
    commercial splint
    rigid splint
    sling
    cast

Different body regions require different treatments.

======================================================================
26. CASTS
======================================================================

Potential advanced fracture treatment.

Requirements:

    medical supplies
    water
    skill
    procedure time

Benefits:

    superior stabilization
    recovery modifier

Costs:

    movement limitations
    removal procedure.

FEASIBILITY:
HIGH as custom treatment metadata over vanilla fracture.

======================================================================
27. CRUTCHES
======================================================================

Potential mobility aid for lower-limb injuries.

Implementation depends on animation/equipment support.

Potential effect:

    reduced movement penalty from one injured leg

Tradeoff:

    hand occupation
    reduced combat ability.

CLASSIFICATION:
EXPERIMENTAL/HIGH.

======================================================================
28. SLINGS
======================================================================

Upper-limb immobilization.

Can modify:

    healing
    use of injured arm
    combat effectiveness.

M.O.R.T.I.S. should provide limb-function abstraction if available.

======================================================================
29. BURNS
======================================================================

Vanilla BodyPart exposes:

    burn state
    burn time
    need burn wash

MedWorks should extend burn care.

Potential:

    cooling
    cleaning
    sterile burn dressing
    burn gel
    infection prevention
    fluid consequences for severe burns

Do not replace vanilla burn state.

======================================================================
30. lightWorks SUNBURN INTEGRATION
======================================================================

lightWorks owns:

    UV exposure
    UV dose
    sunburn generation/severity.

MedWorks owns:

    clinical treatment.

Potential:

    cool compress
    burn treatment
    pain relief
    severe-burn management.

MedWorks MUST NOT calculate environmental UV.

======================================================================
31. WOUND INFECTION
======================================================================

Critical distinction:

VANILLA WOUND INFECTION
!=
KNOX INFECTION.

MedWorks should preserve this distinction.

Local wound infection may be affected by:

    contamination
    dirty dressings
    poor treatment
    hygiene

Potential treatment:

    irrigation
    antiseptic
    clean dressing
    antibiotics where appropriate.

======================================================================
32. KNOX INFECTION
======================================================================

Do NOT make MedWorks automatically cure Knox Infection.

Vanilla infection rules remain authoritative.

Expose compatibility API:

    MedWorks.Infection.getKnoxState(...)

Potential other mods may deliberately alter it.

Project Nightfall may eventually consume medical APIs where appropriate.

But:

medWorks DEFAULT
    no magical zombie cure.

======================================================================
33. ANTIBIOTICS
======================================================================

Vanilla pharmaceutical behavior should be audited.

MedWorks can create generalized medication framework.

Antibiotics should target:

    bacterial/local/systemic infection mechanics

NOT:

    Knox virus.

Potential:

    dose
    duration
    course
    side effects

Keep complexity appropriate for gameplay.

======================================================================
34. MEDICATION FRAMEWORK
======================================================================

Create:

MedWorks.Medications

Definition:

    id
    route
    dose
    onset
    duration
    effects
    contraindications
    stacking
    overdose behavior

Routes:

    ORAL
    TOPICAL
    INJECTION
    IV
    INHALATION

Only implement routes supported by actual content.

======================================================================
35. VANILLA PILLS
======================================================================

BodyDamage exposes medication hooks such as:

    JustTookPill(...)
    JustTookPainMeds(...)

Audit all current B42 medications and their implementations.

Do NOT replace vanilla pills.

Create adapters.

Potential vanilla categories include:

    pain management
    sleep
    anxiety/stress
    antibiotics
    other current medical consumables.

Exact current B42 item list MUST be generated from installed scripts.

======================================================================
36. DOSAGE
======================================================================

Vanilla medication is often comparatively item/action based.

MedWorks can track:

    dose
    administration time
    active concentration/effect window

Do NOT implement full pharmacokinetic simulation.

Use simplified medication state.

======================================================================
37. OVERDOSE / INTERACTIONS
======================================================================

Potential:

    excessive sedatives
    excessive analgesics
    alcohol + medication interactions

Must be predictable.

Do not turn medications into opaque random-death mechanics.

======================================================================
38. PAIN
======================================================================

BodyPart exposes additional pain.

Vanilla also has systemic pain behavior.

MedWorks should preserve vanilla pain.

Potential treatments:

    non-opioid analgesic
    stronger analgesic
    local anesthetic
    procedural anesthesia

Avoid inventing a second independent pain number unless necessary.

======================================================================
39. LOCAL ANESTHESIA
======================================================================

Potential procedural system.

Used for:

    suturing
    foreign-object removal
    minor surgery

Effect:

    temporarily reduces procedural pain in body region.

CLASSIFICATION:
HIGH as MedWorks metadata/effect.

======================================================================
40. GENERAL ANESTHESIA
======================================================================

Much more complex.

Potential later system for major M.O.R.T.I.S. procedures.

Requires:

    medication
    equipment
    monitoring
    medical skill

Risks:

    respiratory depression
    overdose
    procedural complications.

Do NOT include in initial release unless required by surgical architecture.

CLASSIFICATION:
EXPERIMENTAL/FUTURE.

======================================================================
41. VITAL SIGNS
======================================================================

Vanilla does not expose a complete hospital-style vital-sign model.

MedWorks can provide derived clinical observations.

Potential:

    pulse
    respiratory status
    temperature
    blood-pressure abstraction
    consciousness

But:

DO NOT simulate physiology at ICU precision.

Derive values from actual game state where possible.

======================================================================
42. VITALS PROVIDER API
======================================================================

Concept:

MedWorks.Vitals.get(patient)

Returns normalized:

    circulation
    bleedingSeverity
    temperature
    pain
    consciousness
    respiratoryStatus

Some values may be derived rather than literal engine variables.

======================================================================
43. DIAGNOSTICS
======================================================================

Major vanilla opportunity.

Currently the Health panel often reveals injury information directly.

MedWorks can make medical knowledge/equipment improve interpretation.

Potential actions:

    Examine Patient
    Check Wound
    Check Pulse
    Check Temperature
    Assess Fracture
    Inspect Burn
    Check Pupils

Do not unnecessarily hide vanilla information unless configured.

Default should augment rather than frustrate.

======================================================================
44. THERMOMETERS
======================================================================

Add/use:

    clinical thermometer.

Can improve illness assessment.

Temperature value may be derived from vanilla sickness/temperature systems.

CLASSIFICATION:
HIGH/VERIFY.

======================================================================
45. STETHOSCOPE
======================================================================

Potential diagnostic equipment.

Could improve:

    respiratory assessment
    certain illness diagnosis.

Its usefulness depends on how far disease mechanics expand.

Do not add useless decorative equipment.

======================================================================
46. BLOOD PRESSURE CUFF
======================================================================

Potential advanced diagnostic item.

Useful only if MedWorks provides meaningful circulation/shock abstraction.

Do not add until that system exists.

======================================================================
47. SHOCK
======================================================================

Potential major MedWorks extension.

Severe:

    blood loss
    trauma
    burns

could produce a simplified shock state.

Effects:

    weakness
    reduced consciousness
    recovery risk.

CLASSIFICATION:
HIGH conceptually, but interaction with vanilla health must be prototyped.

======================================================================
48. BLOOD VOLUME
======================================================================

Vanilla models bleeding but not necessarily a first-class clinical blood-volume
resource suitable for transfusion.

MedWorks could derive:

    bloodVolumeNormalized

from:

    accumulated bleeding
    trauma
    treatment.

Do not replace BodyDamage health.

Blood volume should be an additional clinical state.

CLASSIFICATION:
EXPERIMENTAL/HIGH.

======================================================================
49. BLOOD TYPES
======================================================================

Potential:

    O+
    O-
    A+
    A-
    B+
    B-
    AB+
    AB-

This can support transfusion gameplay.

Persist per character.

Do not randomly regenerate.

======================================================================
50. BLOOD DRAWING
======================================================================

Potential procedure:

    Blood Collection Bag
    Needle/IV equipment

Donor loses:

    blood volume.

Creates:

    typed blood bag.

Requires:

    suitable skill/equipment.

CLASSIFICATION:
HIGH if blood-volume abstraction succeeds.

======================================================================
51. BLOOD TRANSFUSION
======================================================================

Potential advanced treatment.

Requires:

    IV access
    compatible blood
    blood bag
    procedure knowledge.

Effect:

    restore blood-volume state.

Wrong blood:

    dangerous transfusion reaction.

This should be advanced gameplay, not routine first aid.

======================================================================
52. IV SYSTEM
======================================================================

Potential generic IV procedure framework.

MedWorks.IV

Can administer:

    saline
    blood
    medications

Patient state:

    IV site
    line attached
    fluid source
    infusion state.

CLASSIFICATION:
HIGH/EXPERIMENTAL.

======================================================================
53. IV SALINE
======================================================================

Potential treatment for:

    severe dehydration
    blood-loss stabilization
    certain medical procedures.

Do not let saline magically restore lost red blood cells.

Saline != blood transfusion.

======================================================================
54. waterWorks INTEGRATION
======================================================================

waterWorks owns:

    water
    water quality
    purification
    distribution.

MedWorks consumes water quality for:

    wound irrigation
    instrument cleaning
    hygiene
    procedural suitability.

Example:

river water:
    terrible wound irrigation choice

waterWorks-treated potable water:
    acceptable

sterile saline:
    preferable.

======================================================================
55. MEDICAL HYGIENE
======================================================================

Potential:

    hand washing
    clean work surface
    sterile field
    tool sterilization.

Should affect procedural infection risk.

Do not require absurd micromanagement for ordinary bandaging.

Use mainly for invasive procedures.

======================================================================
56. INSTRUMENT STERILIZATION
======================================================================

Potential:

    boiling
    chemical disinfection
    autoclave

Different effectiveness.

powerWorks:
    power for autoclave.

waterWorks:
    water supply.

MedWorks:
    sterilization procedure/result.

======================================================================
57. AUTOCLAVE
======================================================================

Excellent late-game medical infrastructure.

Requires:

    electricity
    water
    time.

Produces:

    sterile instruments.

powerWorks supplies power.

waterWorks supplies suitable water.

MedWorks owns sterilization.

======================================================================
58. MEDICAL TOOLS
======================================================================

Potential:

    tweezers
    forceps
    scissors
    scalpel
    hemostat
    needle holder
    thermometer
    stethoscope
    tourniquet
    syringe
    IV set
    surgical tray

Do not add items without gameplay purpose.

======================================================================
59. MEDICAL CONTAINERS
======================================================================

Potential:

    first aid kit
    trauma kit
    surgical kit
    instrument tray
    sharps container
    organ container

The previously planned ORGAN CONTAINER remains appropriate.

======================================================================
60. ORGAN CONTAINER
======================================================================

Ownership:

M.O.R.T.I.S.:
    organ/body-part identity and anatomical extraction.

MedWorks:
    clinical storage container
    preservation procedure where appropriate.

Potential:

    sterile organ container
    preservation fluid
    labeling.

Do NOT let MedWorks invent detached anatomy independently.

======================================================================
61. LIMB CONTAINERS
======================================================================

IMPORTANT OWNERSHIP RULE:

M.O.R.T.I.S. OWNS LIMB CONTAINERS.

Reason:

M.O.R.T.I.S. owns structural/anatomical limb state.

MedWorks can use them during:

    surgery
    preservation
    treatment

but does not define them.

======================================================================
62. PROSTHETICS
======================================================================

M.O.R.T.I.S. owns:

    limb state
    attachment framework
    prosthetic attachment points.

MedWorks owns:

    surgical/clinical procedure to fit a prosthetic.

A separate content provider could eventually supply specialized prostheses.

Do not hard-code prosthetic mechanics into medical wound code.

======================================================================
63. AMPUTATION
======================================================================

M.O.R.T.I.S. owns:

    anatomical limb removal
    resulting limb state.

MedWorks owns:

    medical procedure
    instruments
    anesthesia
    bleeding control
    infection risk
    aftercare.

This separation is mandatory.

======================================================================
64. SURGERY FRAMEWORK
======================================================================

MedWorks should expose a generic procedure framework.

Concept:

MedWorks.Procedures.register({
    id,
    targetRequirements,
    skillRequirements,
    toolRequirements,
    consumables,
    duration,
    sterility,
    anesthesia,
    steps,
    outcomes
})

Consumers can register procedures.

======================================================================
65. PROCEDURE PIPELINE
======================================================================

Potential:

ASSESS
    ↓
PREPARE
    ↓
STERILIZE
    ↓
ANESTHETIZE
    ↓
OPERATE
    ↓
CLOSE
    ↓
DRESS
    ↓
RECOVER

Not every procedure needs every stage.

Simple suturing should remain simple.

======================================================================
66. PROCEDURAL COMPLICATIONS
======================================================================

Possible:

    bleeding
    contamination
    wound infection
    additional tissue damage
    failed procedure
    pain
    shock.

Do not use arbitrary RNG.

Risk should derive from:

    skill
    tools
    sterility
    patient condition
    procedure complexity.

======================================================================
67. MEDICAL SKILL
======================================================================

Vanilla First Aid should remain meaningful.

Do NOT create:

    MedWorksMedicalSkill

unless vanilla cannot support progression needs.

Use First Aid wherever appropriate.

Potential First Aid effects:

    faster treatment
    less pain
    reduced complications
    better diagnosis
    improved bandaging
    improved procedures.

======================================================================
68. KNOWLEDGE SYSTEM
======================================================================

MedWorks should add books/manuals.

Potential:

    First Aid Manual
    Advanced Trauma Care
    Emergency Medicine
    Surgical Procedures
    Pharmacology Reference
    Field Medicine

Books can unlock procedure knowledge.

This matches the theWorks ecosystem philosophy.

======================================================================
69. RECIPE VS KNOWLEDGE
======================================================================

Do not reduce medicine to crafting recipes.

Knowledge should unlock:

    procedures
    diagnoses
    equipment use

not merely:

    craft MedicalThing.

======================================================================
70. HOSPITAL EQUIPMENT
======================================================================

Potential functional world equipment:

    examination table
    hospital bed
    IV stand
    surgical table
    autoclave
    medical cabinet
    diagnostic equipment.

Prefer adapting vanilla hospital furniture where possible.

======================================================================
71. HOSPITAL BEDS
======================================================================

Potential:

    improved patient recovery/rest
    procedure target
    IV attachment point.

Do not make a second sleeping framework.

Adapt vanilla furniture.

======================================================================
72. IV STANDS
======================================================================

Physical support for:

    blood bags
    saline
    IV medications.

Portable and hospital variants possible.

======================================================================
73. SURGICAL TABLE
======================================================================

Potential procedure workstation.

Benefits:

    complex procedure eligibility
    better positioning
    reduced complication risk.

Could adapt appropriate vanilla furniture.

======================================================================
74. MEDICAL CABINETS
======================================================================

Mostly vanilla loot/storage.

Do not create special framework behavior without purpose.

======================================================================
75. WHEELCHAIRS
======================================================================

Potential mobility equipment.

Likely requires substantial animation/vehicle work.

CLASSIFICATION:
EXPERIMENTAL.

Do not make core dependency.

======================================================================
76. STRETCHERS
======================================================================

Potential multiplayer rescue mechanic.

Could transport incapacitated characters.

Requires:

    character carrying/animation/network work.

CLASSIFICATION:
EXPERIMENTAL.

Very valuable if technically possible.

======================================================================
77. PATIENT TRANSPORT API
======================================================================

Do not tie future stretchers exclusively to MedWorks.

Potential generic interface:

    MedWorks.PatientTransport

M.O.R.T.I.S. and other mods may consume it.

Only implement after technical proof.

======================================================================
78. animalWorks INTEGRATION
======================================================================

Earlier ecosystem decision:

animalWorks uses MedWorks as the medical/procedure API.

animalWorks owns:

    animal anatomy mapping
    animal health consequences
    veterinary behavior
    species rules
    veterinary knowledge books.

MedWorks owns generic:

    procedure framework
    medical tools
    medication framework
    sterility
    suturing
    wound care
    clinical concepts.

======================================================================
79. M.O.R.T.I.S. + animalWorks
======================================================================

M.O.R.T.I.S. may provide generic anatomical/procedural structure usable by
animalWorks.

animalWorks defines animal-specific anatomy.

MedWorks provides clinical operations.

Example:

Animal injured leg
        ↓
animalWorks patient adapter
        ↓
MedWorks procedure
        ↓
M.O.R.T.I.S.-style anatomical target if applicable
        ↓
animalWorks consequence.

Avoid hardcoding IsoPlayer assumptions throughout MedWorks.

======================================================================
80. PATIENT PROVIDER API
======================================================================

This is important for animalWorks.

Do not define MedWorks exclusively around:

    IsoPlayer.

Conceptually support:

MedWorks.PatientProvider

Human provider:
    vanilla BodyDamage.

Animal provider:
    animalWorks.

This could make the medical framework reusable.

Prototype before over-generalizing.

======================================================================
81. HEALTH PANEL
======================================================================

Do not replace vanilla Health UI immediately.

Extend it.

Potential additions:

    injury details
    treatment state
    medications
    vitals
    procedures
    diagnosis information.

Preserve familiar vanilla workflow.

======================================================================
82. BODY PART INVENTORY ICONS
======================================================================

Previously planned MedWorks assets should correspond to vanilla PZ regions:

    Head

    Neck

    Upper Torso
    Lower Torso
    Groin

    Left Upper Arm
    Right Upper Arm

    Left Forearm
    Right Forearm

    Left Hand
    Right Hand

    Left Upper Leg
    Right Upper Leg

    Left Lower Leg
    Right Lower Leg

    Left Foot
    Right Foot

But:

These icons are presentation/medical UI assets.

Actual detached body-part state belongs to M.O.R.T.I.S.

======================================================================
83. MEDICAL INVENTORY ICON PLAN
======================================================================

Asset categories:

DRESSINGS
TOOLS
MEDICATION
DIAGNOSTICS
IV/BLOOD
SURGERY
CONTAINERS
EQUIPMENT

Maintain Project Zomboid visual language.

Do not add hundreds of near-identical medical items.

======================================================================
84. HEALTH RECORDS
======================================================================

Potential:

    patient chart
    medical notes
    blood type record.

Could be useful in multiplayer.

Not initial priority.

======================================================================
85. BLOOD-TYPE DISCOVERY
======================================================================

Blood type should not necessarily appear magically.

Possible:

    medical record
    blood typing kit
    known character history.

Once discovered:

persist knowledge.

======================================================================
86. SYRINGES
======================================================================

Generic reusable/consumable administration tool.

Potential:

    sterile syringe
    used syringe.

Supports injection medication.

Contaminated needle reuse should carry consequences.

Do not overdo needle micromanagement.

======================================================================
87. SHARPS
======================================================================

Potential:

    used needles
    sharps container.

Mostly relevant if injection/IV system becomes substantial.

Not core release requirement.

======================================================================
88. MEDICATION STORAGE
======================================================================

Some drugs may benefit from storage requirements.

But refrigeration systems should be delegated to appropriate vanilla/powerWorks
infrastructure.

Do not create medical refrigeration physics.

======================================================================
89. REFRIGERATED MEDICAL STORAGE
======================================================================

Potential later:

    blood
    certain medicines
    biological material.

powerWorks:
    electricity.

MedWorks:
    preservation requirement.

M.O.R.T.I.S.:
    anatomical material state where appropriate.

======================================================================
90. CORPSE SICKNESS
======================================================================

Vanilla BodyDamage contains corpse-sickness related behavior.

MedWorks should not automatically replace it.

Potential:

    diagnostic interpretation
    symptom treatment.

A sanitation/environment framework may own broader environmental disease later.

======================================================================
91. COLDS / ILLNESS
======================================================================

BodyDamage exposes cold state including:

    cold strength
    progression
    sneeze/cough
    wetness interaction.

MedWorks may provide:

    symptom treatment
    diagnostics

but should not replace vanilla illness progression unless specifically justified.

======================================================================
92. DISEASE FRAMEWORK
======================================================================

Do NOT immediately turn MedWorks into a giant epidemiology simulation.

Potential future API:

MedWorks.Disease

But initial priority:

TRAUMA + CLINICAL CARE.

Disease expansion can come later.

======================================================================
93. FOOD POISONING / TOXINS
======================================================================

Vanilla already contains systemic sickness/poisoning behavior.

MedWorks may provide:

    diagnosis
    supportive care

but should not duplicate food safety mechanics.

======================================================================
94. MEDICAL CONSEQUENCE PROVIDER
======================================================================

Potential cross-mod API:

MedWorks can receive conditions from other theWorks projects.

Examples:

lightWorks:
    sunburn

waterWorks:
    unsafe-water exposure

M.O.R.T.I.S.:
    anatomical trauma

animalWorks:
    veterinary patient state.

MedWorks decides clinical treatment.

======================================================================
95. MULTIPLAYER
======================================================================

Critical.

B42 increasingly uses server-authoritative TimedActions.

Medical procedures must follow that architecture.

SERVER AUTHORITATIVE:

    treatment validation
    item consumption
    wound changes
    medication
    procedure outcomes
    blood state
    IV state
    sterility
    persistent medical metadata.

CLIENT:

    UI
    animations
    progress
    cosmetic presentation.

======================================================================
96. OTHER-PLAYER TREATMENT
======================================================================

Vanilla already supports treatment interactions involving another player.

MedWorks must preserve this.

Every procedure should identify:

    practitioner
    patient

They may be the same character.

Do not assume:

    practitioner == patient.

This also prepares architecture for animalWorks.

======================================================================
97. PROCEDURE AUTHORITY
======================================================================

Concept:

Client requests:

    perform procedure X
    on patient Y
    target body part Z.

Server validates:

    distance
    patient
    tools
    consumables
    skill
    injury
    procedure
    permissions.

Server applies outcome.

======================================================================
98. INTERRUPTED PROCEDURES
======================================================================

Procedure can be interrupted by:

    movement
    combat
    practitioner injury
    patient movement
    missing equipment
    network disconnect.

Define rollback/partial-outcome behavior.

Do not duplicate consumed items.

======================================================================
99. PERSISTENCE
======================================================================

Vanilla state remains in BodyDamage.

Persist MedWorks-only state such as:

    medication state
    blood type
    blood volume if implemented
    treatment metadata
    procedure recovery
    sterility where needed
    IV state
    diagnostic knowledge.

Do NOT copy every vanilla BodyPart property into ModData.

======================================================================
100. PERFORMANCE
======================================================================

Medical state should be almost entirely:

    event driven
    +
    coarse scheduled updates.

Never:

for every player
    every frame
        recalculate all medication
        all wounds
        all treatments.

Use:

injury event
treatment event
medication event
periodic clinical update.

======================================================================
101. MEDICATION UPDATE FREQUENCY
======================================================================

Medication effects do not require render-frame updates.

Use coarse time intervals.

Store:

    administeredAt
    dose
    duration

derive current effect.

Avoid decrementing dozens of timers every frame.

======================================================================
102. DEBUGGING
======================================================================

MedWorks needs strong diagnostics.

Patient debugger:

BODY

    part
    health
    injuries
    bleeding
    burn
    fracture
    glass
    bullet
    infection
    bandage
    stitch
    splint
    pain

CLINICAL

    medication
    blood state
    vitals
    procedures
    treatment
    sterility
    recovery.

======================================================================
103. PROCEDURE DEBUGGER
======================================================================

Display:

Procedure ID
Practitioner
Patient
Target
Requirements
Skill
Tools
Consumables
Sterility
Risk
Stage
Remaining time
Outcome state

Essential for MP debugging.

======================================================================
104. FEATURE FEASIBILITY MATRIX
======================================================================

FEATURE                                  STATUS

BodyDamage adapter                       VERY HIGH
BodyPart adapter                         VERY HIGH
Vanilla injury adapter                   VERY HIGH
Bandage expansion                        VERY HIGH
Dirty dressing integration               VERY HIGH
Disinfection expansion                   VERY HIGH
Direct pressure                          HIGH
Pressure dressing                        HIGH
Wound packing                            HIGH
Tourniquets                              HIGH
Sutures                                  VERY HIGH
Staples                                  HIGH
Closure strips                           HIGH
Glass removal                            VERY HIGH
Bullet removal                           VERY HIGH
Fracture treatment                       VERY HIGH
Advanced splints                         HIGH
Casts                                    HIGH
Slings                                   HIGH
Crutches                                 HIGH/EXPERIMENTAL
Burn care                                VERY HIGH
Wound infection                          VERY HIGH
Antibiotics                              HIGH
Medication framework                     HIGH
Dosage/duration                          HIGH
Drug interactions                        HIGH
Local anesthesia                         HIGH
General anesthesia                       EXPERIMENTAL
Wound irrigation                         HIGH
Saline                                   HIGH
Medical sterility                        HIGH
Tool sterilization                       HIGH
Autoclave                                HIGH
Diagnostics                              HIGH
Thermometer                              HIGH
Stethoscope                              HIGH/CONTENT-DEPENDENT
Blood pressure                           HIGH/NEW PHYSIOLOGY
Shock                                    HIGH/EXPERIMENTAL
Blood-volume model                       HIGH/EXPERIMENTAL
Blood types                              HIGH
Blood collection                         HIGH/EXPERIMENTAL
Blood transfusion                        HIGH/EXPERIMENTAL
IV framework                             HIGH/EXPERIMENTAL
IV saline                                HIGH/EXPERIMENTAL
IV medication                            HIGH/EXPERIMENTAL
Medical procedure framework              HIGH
Surgery framework                        HIGH
Amputation procedure                     HIGH WITH M.O.R.T.I.S.
Limb removal                             M.O.R.T.I.S.
Limb containers                          M.O.R.T.I.S.
Organ anatomy                            M.O.R.T.I.S.
Organ container clinical use             HIGH
Prosthetic fitting procedure             HIGH WITH M.O.R.T.I.S.
Prosthetic attachment framework          M.O.R.T.I.S.
Hospital beds                            HIGH
IV stands                                HIGH
Surgical tables                          HIGH
Wheelchairs                              EXPERIMENTAL
Stretchers                               EXPERIMENTAL
Other-player treatment                   VERY HIGH
Animal patient support                   HIGH/VERIFY ARCHITECTURE
waterWorks medical-water integration     HIGH
lightWorks sunburn treatment             HIGH
First Aid skill integration              VERY HIGH
Medical books                            VERY HIGH
Procedure knowledge                      HIGH

======================================================================
105. REQUIRED TECHNICAL SPIKES
======================================================================

MW-SPIKE-01
Enumerate current B42 BodyParts.

MW-SPIKE-02
Read all injury state from Lua.

MW-SPIKE-03
Modify vanilla bleeding safely.

MW-SPIKE-04
Apply/remove vanilla bandage.

MW-SPIKE-05
Dirty-bandage lifecycle.

MW-SPIKE-06
Deep wound + suture lifecycle.

MW-SPIKE-07
Glass extraction.

MW-SPIKE-08
Bullet extraction.

MW-SPIKE-09
Fracture/splint lifecycle.

MW-SPIKE-10
Burn treatment lifecycle.

MW-SPIKE-11
Wound-infection lifecycle.

MW-SPIKE-12
Other-player treatment.

MW-SPIKE-13
Server-authoritative custom treatment.

MW-SPIKE-14
Persistent custom treatment metadata.

MW-SPIKE-15
Medication state.

MW-SPIKE-16
Tourniquet affecting vanilla bleeding.

MW-SPIKE-17
Custom procedure pipeline.

MW-SPIKE-18
Procedure interruption.

MW-SPIKE-19
waterWorks wound irrigation.

MW-SPIKE-20
lightWorks sunburn treatment.

MW-SPIKE-21
M.O.R.T.I.S. anatomical procedure provider.

MW-SPIKE-22
animalWorks patient provider.

MW-SPIKE-23
Dedicated-server full medical interaction.

======================================================================
106. REQUIRED VANILLA ITEM AUDIT
======================================================================

Codex must enumerate current B42 scripts for:

    Bandage
    Ripped Sheets
    Sterilized dressings
    Alcohol/disinfectant
    Cotton balls
    Suture needle
    Suture needle holder
    Tweezers
    Splints
    Pain medication
    Antibiotics
    Sleeping medication
    Beta blockers
    Vitamins
    First Aid kits
    Medical gloves
    Masks
    medical containers
    B42-added medical items

Do NOT rely on an old wiki list.

Produce:

Vanilla Item
Item Type
Existing Function
Relevant Lua/Java API
MedWorks Adapter
Potential Improvement

======================================================================
107. REQUIRED VANILLA ACTION AUDIT
======================================================================

Locate current B42 implementations for:

    bandaging
    removing bandage
    disinfecting
    cleaning burns
    suturing
    removing stitches
    removing glass
    removing bullets
    splinting
    removing splint
    taking medication
    treating another player

Identify:

    TimedAction
    validation
    item consumption
    BodyPart mutation
    MP synchronization
    UI integration.

These are the strongest templates for MedWorks.

======================================================================
108. ROADMAP
======================================================================

MW0 — B42 API AUDIT

    BodyDamage
    BodyPart
    BodyPartType
    current medical items
    Health UI
    TimedActions
    MP
    First Aid skill
    medications.

MW1 — CLINICAL CORE

    PatientAdapter
    BodyPartAdapter
    InjuryAdapter
    treatment registry
    procedure registry
    diagnostics
    MP authority.

MW2 — VANILLA FIRST-AID INTEGRATION

    bandages
    disinfecting
    glass
    bullets
    sutures
    splints
    burns
    infection.

MW3 — TRAUMA CARE

    direct pressure
    pressure dressings
    wound packing
    tourniquets
    improved wound care.

MW4 — STERILITY

    clean/dirty/sterile state
    instrument cleaning
    sterile field
    wound irrigation.

MW5 — MEDICATION

    medication registry
    dose
    onset
    duration
    vanilla medication adapters
    interactions.

MW6 — DIAGNOSTICS

    examination
    thermometer
    medical assessment
    equipment.

MW7 — FRACTURE/RECOVERY

    advanced splints
    slings
    casts
    mobility aids if feasible.

MW8 — CLINICAL EQUIPMENT

    IV stand
    examination table
    surgical table
    autoclave
    instrument trays.

MW9 — IV/FLUID THERAPY

Only after physiology prototype succeeds.

    saline
    IV access
    infusion
    medication routes.

MW10 — BLOOD

Only after blood-volume prototype succeeds.

    blood type
    blood typing
    blood collection
    blood bags
    compatibility
    transfusion.

MW11 — M.O.R.T.I.S. PROCEDURES

    anatomy provider
    limb procedures
    amputation clinical workflow
    prosthetic fitting
    organ handling.

MW12 — animalWorks

    generic patient provider
    veterinary procedure reuse
    animal-specific consumers.

MW13 — CROSS-WORKS

    waterWorks medical water
    lightWorks sunburn
    powerWorks hospital equipment
    M.O.R.T.I.S. anatomy.

======================================================================
109. DEPENDENCY ARCHITECTURE
======================================================================

MedWorks
    ↓
Vanilla PZ healthcare APIs

MedWorks SHOULD NOT require:

    waterWorks
    lightWorks
    powerWorks
    animalWorks

Those are optional integrations.

M.O.R.T.I.S. relationship requires careful architecture.

Preferred:

M.O.R.T.I.S.
    provides anatomy framework

MedWorks
    detects/consumes anatomy API

while MedWorks remains usable for vanilla first aid without M.O.R.T.I.S.

Advanced surgical modules may require both.

animalWorks:
    consumes MedWorks API.

Do NOT create:

MedWorks -> animalWorks.

======================================================================
110. DOMAIN OWNERSHIP
======================================================================

medWorks OWNS:

    healthcare
    diagnosis
    first aid
    clinical treatment
    wound care
    medication framework
    medical tools
    sterility
    medical procedures
    surgery workflow
    blood/IV systems
    medical equipment
    recovery modifiers
    clinical APIs.

M.O.R.T.I.S. OWNS:

    anatomy
    structural body state
    limb state
    limb loss
    organs
    anatomical containers
    prosthetic attachment framework.

lightWorks OWNS:

    UV
    sunlight exposure
    sunburn generation.

medWorks treats sunburn.

waterWorks OWNS:

    water quality.

medWorks determines clinical suitability/use.

powerWorks OWNS:

    electrical infrastructure.

medWorks medical equipment consumes electricity.

animalWorks OWNS:

    animals
    animal anatomy mappings
    veterinary knowledge/content
    animal medical consequences.

animalWorks consumes MedWorks procedure APIs.

======================================================================
111. CORE DESIGN PRINCIPLE
======================================================================

DO NOT MAKE:

"Project Zomboid but with 50 extra bandages."

MAKE HEALTHCARE A SYSTEM.

Vanilla already gives us:

BODY
    ↓
BODY PART
    ↓
INJURY

MedWorks adds:

INJURY
    ↓
ASSESSMENT
    ↓
STABILIZATION
    ↓
TREATMENT
    ↓
PROCEDURE
    ↓
AFTERCARE
    ↓
RECOVERY

M.O.R.T.I.S. answers:

WHAT BODY STRUCTURE EXISTS?

MedWorks answers:

HOW DO WE KEEP IT ALIVE?

======================================================================
112. CODEX NEXT ACTION
======================================================================

Before implementing new content:

1. Audit the MedWorks repository.
2. Audit current installed B42 vanilla Lua/scripts.
3. Enumerate every current medical item.
4. Enumerate every BodyPartType.
5. Enumerate every BodyPart medical property callable from Lua.
6. Enumerate BodyDamage health/systemic properties.
7. Locate every vanilla medical TimedAction.
8. Trace each action from UI -> validation -> mutation -> MP.
9. Audit First Aid XP/skill effects.
10. Audit vanilla medication implementation.
11. Audit treatment-other-player implementation.
12. Audit health-panel extension points.
13. Run MW-SPIKE-01 through MW-SPIKE-23.
14. Reclassify each feature from actual runtime evidence.
15. Build the smallest stable Patient/Injury/Procedure API.
16. Preserve vanilla healthcare compatibility.
17. Keep advanced anatomy inside M.O.R.T.I.S.
18. Keep MedWorks functional without optional theWorks projects.
19. Test dedicated multiplayer from the first implementation phase.
20. Only then begin broad medical content implementation.

CURRENT B42 RUNTIME AND REPOSITORY OVERRIDE THIS DOCUMENT WHENEVER THEY
DISAGREE.
