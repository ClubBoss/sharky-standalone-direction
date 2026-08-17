# Visual Gauntlet B3 Closure + B4 Admission v1

Status: `VISUAL_GAUNTLET_B4_ADMITTED`.
Freshness date: 2026-08-17.
Repository: `ClubBoss/sharky-standalone-direction`.

This is a control-plane authority record. It closes the already-reviewed and
merged B3 implementation and admits exactly one next visual-production wave. It
does not implement B4, run P02, reopen the HNP harness, or promote Human proof.

## 1. Exact B3 closure provenance

B3 mission:

`VISUAL_GAUNTLET_B3_PLAYER_EMBODIMENT_V1`

B3 implementation PR:

`#190`

Pre-merge main:

`13f33b0c97d95ea72872bcdb8bf509078dac96cb`

Exact implementation head admitted by Mastermind:

`25efe1871f987d6ff121e46e536787b66b7f679e`

B3 merge commit / post-B3 main:

`19f97534aae83ef508193b50408dbfa9a0707bf5`

Mastermind independently reviewed the original B3 gap map, first B3 candidate,
exact B2-vs-B3 rendered evidence, first-pass `INSUFFICIENT` disposition,
bounded B3 completion pass, exact-head completion renders, decision/theory/
correct/wrong states, responsive and 1.4x evidence, and exact-head CI.

Canonical verdict:

- `VISUAL_GAUNTLET_B3_PLAYER_EMBODIMENT_V1 = CLOSED_PASS`
- `VISUAL_GAUNTLET_B3 = CLOSED_PASS`
- `VISUAL_GAUNTLET_B2 = CLOSED_PASS`
- `VISUAL_GAUNTLET_B1 = CLOSED_PASS`
- `WAVE_A = CLOSED_PASS`
- `P02 = DEFERRED`
- `HNP_HARNESS = CLOSED_UNCHANGED`
- `HUMAN_PROOF = FALSE`

The first silhouette-only pass was correctly rejected. The accepted completion
pass established:

- recognisable seated people instead of blobs/cutouts;
- coherent original Sharky player family;
- skin / hair / clothing value separation;
- multiple garment/archetype treatments;
- near / mid / far detail falloff;
- rail occlusion ownership;
- first-person hero sleeves / cuffs / hands;
- preservation of B1 scene geometry and anchors;
- preservation of B2 table / room / shared lighting;
- preservation of Wave A learning semantics.

B3 does not establish final character illustration parity. Final costume
richness, props, and cohesion remain later polish territory.

B3 character language is now protected foundation. Do not reopen B3 merely for
facial detail, richer clothes, decorative props, or cosmetic character variants
unless later evidence proves a real regression/blocker.

## 2. Residual debt disposition

`TABLE_OVAL_IDENTITY_REFINEMENT` remains deferred to B7.

No B3 evidence proved it to be a causal blocker. Do not open a standalone table
shape wave.

## 3. Human evidence boundary

P01 remains canonical Human evidence history:

- `REAL_HUMAN_HNP = P01_EXECUTED_ACTIONABLE_STOP`
- `HNP_P01_VERDICT = HUMAN_NOVICE_PROOF_V1_FAILED_WITH_ACTIONABLE_FINDINGS`
- `P02 = DEFERRED / NOT_STARTED`
- `HUMAN_PROOF = FALSE`

Wave A and B1-B3 do not retroactively convert P01 into PASS.

`HNP_HARNESS = CLOSED_UNCHANGED`.

Do not run P02 or reopen the prior HNP harness during B4.

## 4. Visual Gauntlet roadmap after B3

1. `B1 SPATIAL_CHARACTER_READY_SCENE_FOUNDATION` - **CLOSED_PASS**
2. `B2 PREMIUM_TABLE_AND_ENVIRONMENT_ART` - **CLOSED_PASS**
3. `B3 PLAYER_EMBODIMENT` - **CLOSED_PASS**
4. `B4 OBJECT_ATTACHED_HUD` - **ACTIVE / ADMITTED**
5. `B5 ATTENTION_AWARE_RENDERING` - **DEFERRED**
6. `B6 SEMANTIC_MOTION` - **DEFERRED**
7. `B7 BENCHMARK_COHESION_AND_POLISH_GAUNTLET` - **DEFERRED**

Only B4 is authorized now. B5-B7 require a fresh Mastermind gate after B4
review.

## 5. Exact B4 admission

Mission:

`VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1`

Exact next action:

`IMPLEMENT_VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1`

Executor:

`Claude Code`

Preferred model:

`latest available Claude Opus`

Reasoning / effort:

`HIGH / MAXIMUM PRACTICAL`

Mode:

`ITERATIVE LOCAL VISUAL GAUNTLET`

## 6. B4 product objective

B1 established spatial anchors. B2 established the premium physical
environment. B3 established actual player embodiment.

B4 must now make information belong to the poker objects and players it
describes.

Target transformation:

`premium inhabited poker scene + floating / app-like HUD labels`

->

`premium inhabited poker scene where stacks, positions, bets, statuses and learning-relevant indicators are spatially attached to their owners`

The learner should not need to mentally map a detached UI chip back to a player.

## 7. B4 primary ownership

B4 owns object-attached HUD only.

### 7.1 Player identity / stack ownership

At minimum evaluate:

- player name / identity;
- stack;
- position.

These should feel attached to the player / seat volume rather than floating
independently.

Use B1:

- `plateAnchor`;
- `characterAnchor`.

Do not redesign characters.

### 7.2 Bet / commitment ownership

Bets / blind commitments / player-local chip information should visually belong
to the player who made them.

Use:

- `betAnchor`;
- existing pot / blind semantics.

Do not change poker truth or calculation.

### 7.3 Acting / state ownership

Where current semantics already expose states such as:

- acting;
- active;
- inactive;
- folded;
- selected / eligible;

the visual status should belong to that player's local object system.

Do not invent new poker semantics.

### 7.4 Position / dealer ownership

Position / dealer information should read as table/player metadata, not generic
screen UI.

Preserve current meaning exactly.

### 7.5 Learning clue attachment

Where Wave A feedback already points to a causal table object, B4 may make the
visual clue more spatially attached to that object.

Do not create B5 attention-aware rendering.

B4 attachment is not B5 selective focus.

### 7.6 Hero HUD ownership

Hero stack / position / identity should belong to the hero zone and remain
compatible with the first-person embodiment created in B3.

Do not cover:

- hole cards;
- dealer button;
- hero hands;
- actions.

## 8. B4 North Star

Avoid:

`Flutter chips floating over a poker illustration.`

Target:

`the table itself carries the information I need.`

HUD should behave more like instrumentation belonging to scene objects than
independent application cards.

## 9. B4 gap map - required before mutation

Claude must inspect actual B3 renders and classify:

- identity attachment;
- stack attachment;
- position attachment;
- dealer attachment;
- bet ownership;
- blind ownership;
- acting-state ownership;
- active/inactive/folded state ownership;
- eligible/tappable state ownership;
- hero HUD ownership;
- feedback clue attachment;
- HUD/character collisions;
- HUD/cards collisions;
- HUD/table readability;
- depth scaling;
- far-seat legibility;
- near-seat clutter;
- learning hierarchy risk.

Separate clearly:

- B4;
- deferred B5 attention-aware rendering;
- deferred B6 motion;
- deferred B7 cohesion/polish.

## 10. B4 iteration strategy

Default: two strong iterations.

### Iteration 1 - player-local HUD ownership

Focus on:

- identity;
- stack;
- position;
- dealer / player-local metadata;
- character / plate attachment;
- depth scaling.

Goal:

Player information clearly belongs to each seated player.

### Iteration 2 - bet / state / learning attachment

Focus on:

- bets;
- blinds;
- acting / active / folded state where existing semantics permit;
- hero ownership;
- causal learning clue attachment;
- collision / clutter discipline.

Goal:

The action state and learning state belong to objects in the scene rather than
floating in generic UI space.

Allow iteration 3 only if one large B4 class-level problem survives.

Do not spend iterations on micro-polish.

## 11. Depth rules

HUD must respect scene depth.

Far-player HUD:

- compact;
- restrained;
- highly legible;
- minimal information.

Near-player HUD:

- may carry slightly more detail;
- must not dominate table objects.

Do not simply draw every HUD plate at identical scale.

B1 depth / anchors remain authoritative.

## 12. Character rule

B3 is `CLOSED_PASS`.

Do not redesign the player family during B4.

HUD should attach to the accepted character geometry.

Only touch B3 implementation if actual rendered evidence proves a causal HUD
attachment blocker.

## 13. Learning rule

Wave A information hierarchy remains protected:

`VERDICT -> CAUSAL REASON -> TABLE CLUE -> CONTINUE`

B4 may make table-clue attachment stronger.

B4 must not:

- alter answer truth;
- alter feedback wording semantics;
- alter repair/recheck;
- invent new coaching logic;
- build B5 selective attention.

## 14. B4 acceptance bar

B4 is `INSUFFICIENT` if:

- identity/stack plates still look randomly floated;
- players and HUD feel like separate layers;
- bets are visually ambiguous about ownership;
- status indicators create clutter;
- near players collide with metadata;
- far players become unreadable;
- hero HUD competes with cards/actions;
- learning clarity regresses.

Successful B4 should make a viewer immediately understand:

`this information belongs to THIS player / THIS bet / THIS object.`

without consciously tracing UI elements.

## 15. Strict non-scope

Do not:

- redesign table materials;
- redesign room/environment;
- redesign B3 characters;
- implement B5 attention-aware rendering;
- implement depth-of-field / selective blur;
- implement B6 motion;
- implement B7 final parity;
- fix table oval preference unless proven causal;
- change curriculum;
- change poker truth;
- change evaluation;
- change telemetry semantics;
- run P02;
- reopen HNP harness;
- redesign unrelated screens;
- add unrelated dependencies;
- clean unrelated technical debt.

## 16. Protected foundation

Preserve Wave A:

- learning hierarchy;
- interaction grammar;
- feedback;
- repair/recheck;
- continuation;
- telemetry;
- accessibility.

Preserve B1:

- perspective;
- scene planes;
- seat slots;
- `plateAnchor`;
- `characterAnchor`;
- `betAnchor`;
- `cardAnchor`;
- hero zone.

Preserve B2:

- table material;
- environment;
- room;
- shared lighting.

Preserve B3:

- player family;
- character silhouettes;
- skin/hair/clothing language;
- near/mid/far detail model;
- hero embodiment.

## 17. Validation strategy

During internal iterations, do not run the full validation matrix repeatedly.

Use:

- `402x874`;
- theory;
- table task;
- decision;
- correct feedback;
- wrong feedback;
- minimal focused smoke.

After visual convergence run full validation once:

- format/analyze;
- directly affected focused tests;
- fast loop / release gate per repository authority;
- responsive captures;
- durable matched evidence.

## 18. Evidence

Publish matched:

`B3 BASELINE vs B4 CANDIDATE`

for:

- theory;
- table task;
- decision;
- correct feedback;
- wrong feedback.

Also publish:

- nominal contact sheet;
- compact;
- large;
- 1.4x text;
- exact candidate SHA provenance.

## 19. Post-B4 gate

Open one draft B4 PR.

Do not merge.

Do not self-admit B5.

Return to Mastermind.

`HUMAN_PROOF` remains `FALSE`.

## 20. Exact Claude B4 execution packet

```text
SHARKY - VISUAL GAUNTLET B4 OBJECT-ATTACHED HUD V1

EXECUTOR:
Claude Code

MODEL:
latest available Claude Opus

REASONING / EFFORT:
HIGH / MAXIMUM PRACTICAL

MODE:
ITERATIVE LOCAL VISUAL GAUNTLET

REPOSITORY:
ClubBoss/sharky-standalone-direction

STARTING AUTHORITY:
Re-resolve live origin/main first. Expected integrated B3 main at admission:
19f97534aae83ef508193b50408dbfa9a0707bf5

MISSION:
VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1

EXACT NEXT ACTION:
IMPLEMENT_VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1

HUMAN_PROOF = FALSE
P02 = DEFERRED
HNP_HARNESS = CLOSED_UNCHANGED
B5-B7 = DEFERRED
TABLE_OVAL_IDENTITY_REFINEMENT = DEFERRED_TO_B7

B1 established spatial anchors.
B2 established the premium physical environment.
B3 established actual player embodiment and is CLOSED_PASS.

B4 must make information BELONG TO the poker objects and players it describes.

Target transformation:

premium inhabited poker scene
+
floating / app-like HUD labels

->

premium inhabited poker scene where stacks, positions, bets, statuses and
learning-relevant indicators are spatially attached to their owners.

The learner should not need to mentally map a detached UI chip back to a player.

B4 OWNS OBJECT-ATTACHED HUD ONLY.

At minimum evaluate and, where the current semantics support it, improve:

1. PLAYER IDENTITY / STACK OWNERSHIP
- player name / identity
- stack
- position
- attach to player / seat volume
- use plateAnchor / characterAnchor
- do not redesign characters

2. BET / COMMITMENT OWNERSHIP
- bets
- blind commitments
- player-local chip information
- use betAnchor and existing pot/blind semantics
- do not change poker truth or calculation

3. ACTING / STATE OWNERSHIP
- acting
- active
- inactive
- folded
- selected / eligible
- use only states already exposed by current semantics
- do not invent poker semantics

4. POSITION / DEALER OWNERSHIP
- make position/dealer read as table/player metadata
- preserve meaning exactly

5. LEARNING CLUE ATTACHMENT
- where Wave A already identifies a causal table object, strengthen spatial
  attachment to that object
- do not build B5 selective attention

6. HERO HUD OWNERSHIP
- hero identity / stack / position belongs to hero zone
- preserve B3 first-person embodiment
- never cover hole cards, dealer button, hero hands, or actions

NORTH STAR:
Avoid "Flutter chips floating over a poker illustration."
Target "the table itself carries the information I need."

REQUIRED GAP MAP BEFORE MUTATION:
Inspect actual B3 renders and classify:
- identity attachment
- stack attachment
- position attachment
- dealer attachment
- bet ownership
- blind ownership
- acting-state ownership
- active/inactive/folded state ownership
- eligible/tappable state ownership
- hero HUD ownership
- feedback clue attachment
- HUD/character collisions
- HUD/cards collisions
- HUD/table readability
- depth scaling
- far-seat legibility
- near-seat clutter
- learning hierarchy risk

Separate B4 from deferred B5 attention-aware rendering, deferred B6 motion,
and deferred B7 cohesion/polish.

ITERATION STRATEGY:
Default TWO strong iterations.

ITERATION 1 - PLAYER-LOCAL HUD OWNERSHIP
Focus:
- identity
- stack
- position
- dealer / player-local metadata
- character / plate attachment
- depth scaling
Goal: player information clearly belongs to each seated player.

ITERATION 2 - BET / STATE / LEARNING ATTACHMENT
Focus:
- bets
- blinds
- acting / active / folded state where existing semantics permit
- hero ownership
- causal learning clue attachment
- collision / clutter discipline
Goal: action and learning state belong to scene objects rather than generic UI.

Allow ITERATION 3 only if one large B4 class-level problem survives.
Do not spend iterations on micro-polish.

DEPTH RULES:
Far-player HUD: compact, restrained, highly legible, minimal information.
Near-player HUD: may carry slightly more detail, must not dominate table objects.
Do not draw every plate at identical scale.
B1 depth / anchors remain authoritative.

CHARACTER RULE:
B3 is CLOSED_PASS.
Do not redesign the player family.
Only touch B3 implementation if rendered evidence proves a causal HUD attachment
blocker.

LEARNING RULE:
Protect:
VERDICT -> CAUSAL REASON -> TABLE CLUE -> CONTINUE

B4 may strengthen TABLE CLUE attachment only.
Do not alter answer truth, feedback semantics, repair/recheck, or coaching logic.
Do not build B5 selective attention.

ACCEPTANCE BAR:
INSUFFICIENT if:
- identity/stack plates still look randomly floated
- players and HUD feel like separate layers
- bet ownership is ambiguous
- state indicators create clutter
- near players collide with metadata
- far players become unreadable
- hero HUD competes with cards/actions
- learning clarity regresses

Success means the viewer immediately reads:
"this information belongs to THIS player / THIS bet / THIS object."

STRICT NON-SCOPE:
- no table material redesign
- no room/environment redesign
- no B3 character redesign
- no B5 attention-aware rendering
- no depth-of-field / selective blur
- no B6 motion
- no B7 final parity
- no table oval preference fix unless proven causal
- no curriculum changes
- no poker truth changes
- no evaluation changes
- no telemetry semantic changes
- no P02
- no HNP harness reopening
- no unrelated screen redesign
- no unrelated dependencies
- no unrelated technical-debt cleanup

PROTECTED FOUNDATION:
Wave A: learning hierarchy, interaction grammar, feedback, repair/recheck,
continuation, telemetry, accessibility.
B1: perspective, scene planes, seat slots, plateAnchor, characterAnchor,
betAnchor, cardAnchor, hero zone.
B2: table material, environment, room, shared lighting.
B3: player family, character silhouettes, skin/hair/clothing language,
near/mid/far detail model, hero embodiment.

VALIDATION:
During iterations use 402x874, theory, table task, decision, correct feedback,
wrong feedback, and minimal focused smoke.
Do not run the full matrix repeatedly.
After visual convergence run full validation ONCE: format/analyze, directly
affected focused tests, fast loop / release gate per repo authority, responsive
captures, durable matched evidence.

EVIDENCE:
Publish matched B3 BASELINE vs B4 CANDIDATE for theory, table task, decision,
correct feedback, wrong feedback.
Also publish nominal contact sheet, compact, large, 1.4x text, and exact candidate
SHA provenance.

POST-B4 GATE:
Open ONE draft B4 PR.
Do NOT merge.
Do NOT self-admit B5.
Return to Mastermind.
HUMAN_PROOF remains FALSE.
```

## 21. Terminal authority state

`VISUAL_GAUNTLET_B3 = CLOSED_PASS`

`VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1 = ADMITTED`

`CURRENT_STAGE = VISUAL_GAUNTLET_B4_ACTIVE`

`EXACT_NEXT_ACTION = IMPLEMENT_VISUAL_GAUNTLET_B4_OBJECT_ATTACHED_HUD_V1`

`B5_B7 = DEFERRED`

`TABLE_OVAL_IDENTITY_REFINEMENT = DEFERRED_TO_B7`

`P02 = DEFERRED_NOT_STARTED`

`HNP_HARNESS = CLOSED_UNCHANGED`

`HUMAN_PROOF = FALSE`
