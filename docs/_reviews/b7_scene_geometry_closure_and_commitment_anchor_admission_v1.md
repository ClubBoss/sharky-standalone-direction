# B7 Scene Geometry Closure + Commitment Anchor Admission v1

Status: AUTHORITY / ACTIVE DISPATCH
Freshness date: 2026-08-19
Repository: `ClubBoss/sharky-standalone-direction`

## Purpose

Reconcile merged PR #203, close the admitted canonical scene-geometry subtask,
record the returned Sharky Coach Surface and player commitment-anchor audits,
and admit exactly one next bounded B7 subtask:

`PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1`.

This authority does not implement product code, does not modify scene geometry,
does not implement commitment anchors, does not implement Sharky Coach Surface,
does not implement character assets, does not run P02, does not reopen HNP, and
does not admit B8.

Product direction remains governed by
`docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`.

## Starting canonical state

Starting canonical main:

`858c83ee5d927f08d5ad0fcdefd870156a389232`

PR #203 final state:

- state: `CLOSED`
- merged: `TRUE`
- exact implementation head:
  `7263cae12258ff2c963c0f154baf050859859b0c`
- merge commit / canonical main:
  `858c83ee5d927f08d5ad0fcdefd870156a389232`

The prior admission authority is:

`docs/_reviews/b7_character_slice_reconciliation_and_scene_geometry_admission_v1.md`

That authority admitted
`B7_CANONICAL_SCENE_COMPOSITION_AND_GEOMETRY_V1`. This document closes that
bounded subtask and advances B7 by exactly one bounded subtask.

## A. PR #203 / canonical scene geometry closure

Record:

`B7_CANONICAL_SCENE_COMPOSITION_AND_GEOMETRY_V1 = CLOSED_PASS`

`PR203_VISUAL_ACCEPTANCE = PASS`

`CLASS_LEVEL_LIFT = YES`

`TABLE_GEOMETRY_STABILITY = PASSED`

`TABLE_GEOMETRY_INVARIANT_V1 = PASS`

`BLIND_SEAT_REGRESSION = CLOSED_PASS`

`CAMERA_RETUNE_AGAIN = NO`

`TOP_COACH_TERRITORY = PRESERVE`

PR #203 merged from exact head:

`7263cae12258ff2c963c0f154baf050859859b0c`

into canonical main:

`858c83ee5d927f08d5ad0fcdefd870156a389232`

### Final production geometry

```text
outerTableWidthFraction      = 0.810
projectedTableHeightFraction = 0.500
farRailFraction              = 0.225
nearRailFraction             = 0.725
farWidthFactor               = 0.60
nearWidthFactor              = 0.99
depthEase                    = 1.55
horizonOffsetFraction        = 0.020
volumeScaleFar               = 0.95
commitmentSeatSeparation     = 0.006
```

### Accepted proof

- `0.0 px` table-geometry delta across six learning states;
- invariant proven at `375`, `402`, and `430` widths;
- board cards = `100%` baseline;
- hero cards = `99.7%` baseline;
- final blind/seat clearance:
  - SB `+8.50 px`;
  - BB `+6.70 px`;
  - blind-to-blind `+3.40 px`;
- exact-head required CI = green;
- no net-new attributed failures.

Required exact-head repo workflows on the implementation head were green:

- R5 release gate = `SUCCESS`;
- Sharky Web QA Mirror = `SUCCESS`;
- Test Authority Lanes = `SUCCESS`;
- Theory Integrity = `SUCCESS`;
- Health = `SUCCESS`;
- L2 Tests (conditional) = policy `SKIPPED`.

The unrelated `TestSprite Pre-Check` commit status is not part of the required
repo gate set above and does not alter the accepted PR #203 closure.

### Preserved physical-scene contract

Preserve:

- camera-owned physical scene;
- environment/world-plane ownership;
- scene-owned top territory;
- scene-attached content-sized bottom shelf;
- current perspective direction;
- room / player / hero breathing territory.

Do not reopen this geometry for cosmetic preference.

## B. Character state remains bounded proof

Preserve:

`B7_CHARACTER_VERTICAL_SLICE_V1 = CLOSED_PASS_PROOF`

`CHARACTER_ASSET_ARCHITECTURE = PROVEN`

`CLASS_LEVEL_LIFT = YES`

`PREMIUM_CHARACTER_ART = NOT_YET_PROVEN`

`ART_PRODUCTION_PIPELINE = REQUIRES_SEPARATE_SELECTION`

`FULL_CHARACTER_PACK = NOT_STARTED / NOT_ADMITTED`

The old script-generated PNGs remain prototype-only evidence. They must not be
canonized as premium character art or used to admit a full character pack.

Scene geometry is now closed, but premium character production still requires a
separate explicit admission and production-pipeline selection.

## C. Sharky Coach Surface audit reconciliation

Returned read-only audit verdict:

`SHARKY_COACH_SURFACE_HYPOTHESIS = STRONGLY_VALIDATED`

Compatibility verdict:

`COMPATIBLE_WITH_TARGETED_REWORK`

Seamless adaptation score:

`8.4 / 10`

Architecture estimate:

`APPROXIMATELY_70_TO_80_PERCENT_REQUIRED_STRUCTURE_ALREADY_EXISTS`

Canonical product hypothesis:

`SHARKY = VOICE OF THE SCENE`

`TABLE = STABLE PHYSICAL WORLD`

`BOTTOM SHELF = CONTROLS`

Important direction:

- large readable coaching text;
- Sharky as speaking owner;
- scene-integrated speech surface;
- explanation ownership primarily above/in scene;
- bottom owns action / CTA;
- no duplicated long explanation above and below;
- Sharky strong in `UNDERSTAND` / `REPAIR`;
- Sharky restrained in `DECIDE`;
- scaffold reduced in `RECHECK` / `PROVE`.

Disposition:

`SHARKY_COACH_SURFACE_V1 = HIGH_PRIORITY_CANDIDATE_NOT_ADMITTED`

Do not make it the exact next action yet.

Reason: commitment/object geometry should be formalized against the now-frozen
camera before final character / coach art production resumes.

This audit validates product direction only. It does not admit implementation.

## D. Player commitment-anchor audit reconciliation

Returned read-only audit verdict:

`CURRENT_COMMITMENT_PLACEMENT = MILDLY_WEAK`

`PRODUCT_GAP = REAL_BUT_BOUNDED`

The gap is not that current blinds are unreadable. The gap is the lack of a
fully explicit deterministic per-seat ownership contract under the frozen B7
camera.

Admit exactly:

`PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1 = ACTIVE / ADMITTED`

This is a bounded B7 subtask. It is not a new visual wave, B8, a reopening of
B4, a GGPoker clone, or arbitrary chip repositioning.

### Canonical ownership principle

One deterministic seat-local commitment anchor per player:

`PLAYER -> SEAT-LOCAL OBJECTS -> COMMITMENT -> CENTER POT`

Blind/post and live bet/call/raise use:

`SAME_PHYSICAL_COMMITMENT_SLOT`

with:

`DISTINCT_SEMANTIC_STATE`

Do not create separate simultaneous blind and live-bet lanes.

Dealer ownership:

`SEPARATE_SEAT_ADJACENT_DEALER_ANCHOR`

Pot ownership:

`ONE_CENTER_OWNED_POT_ANCHOR`

### Commitment invariant

Commitment position must remain invariant across:

- decision;
- correct feedback;
- wrong feedback;
- repair;
- recheck;
- continuation/result.

Allowed state variation:

- semantic state;
- amount;
- salience;
- object-bound clue emphasis.

Forbidden:

- state-dependent position changes;
- dock-dependent movement;
- answer-leaking movement;
- seat-specific pixel hacks.

### Historical B4 protection

B4 already tested moving commitments to the B1 `betAnchor` and rejected that
reposition after collision evidence.

Therefore this subtask must:

`FORMALIZE_AND_GUARD_EXISTING_OWNERSHIP`

and must not:

`REDESIGN_B4_COMMITMENT_TREATMENT`

The frozen camera and accepted PR #203 clearance are constraints, not tuning
inputs for another camera retune.

## Exact next action

Set:

`B7 = ACTIVE / ADMITTED`

`PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1 = ACTIVE / ADMITTED`

`EXACT_NEXT_ACTION = IMPLEMENT_PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1`

Recommended executor:

`CODEX`

Reason: this is geometry / ownership / invariant-contract work rather than
art-direction iteration.

Do not implement it in this reconciliation mission.

## Preserved global state

Preserve exactly:

`TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE`

`ACCESSIBILITY_TEXT_SCALING = DEFERRED_NOT_CURRENT_ACCEPTANCE`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = NOT_B6_REGRESSION`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = NOT_B6_BLOCKER`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = MUST_RECEIVE_DISPOSITION_BEFORE_P02`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = DEFER_TO_POST_B7_PRE_P02_MAINTENANCE`

`P02 = DEFERRED / NOT_STARTED`

`HNP_HARNESS = CLOSED_UNCHANGED`

`HUMAN_PROOF = FALSE`

`B8 = NOT_ADMITTED`

Modern Table remains `MAINTENANCE_MODE` outside admitted Learning Scene work.

## Explicit non-closures

Do not record or infer:

- `B7 = CLOSED`;
- `FULL_CHARACTER_PACK = ADMITTED`;
- `PREMIUM_CHARACTER_ART = PROVEN`;
- `SHARKY_COACH_SURFACE_V1 = ADMITTED`;
- `P02 = STARTED`;
- `HUMAN_PROOF = TRUE`;
- `B8 = ADMITTED`.

## Dispatch after this authority merges

`CURRENT_STAGE = VISUAL_GAUNTLET_B7_ACTIVE`

`B7 = ACTIVE_ADMITTED`

`B7_CANONICAL_SCENE_COMPOSITION_AND_GEOMETRY_V1 = CLOSED_PASS`

`PR203_VISUAL_ACCEPTANCE = PASS`

`TABLE_GEOMETRY_STABILITY = PASSED`

`TABLE_GEOMETRY_INVARIANT_V1 = PASS`

`BLIND_SEAT_REGRESSION = CLOSED_PASS`

`CAMERA_RETUNE_AGAIN = NO`

`B7_CHARACTER_VERTICAL_SLICE_V1 = CLOSED_PASS_PROOF`

`CHARACTER_ASSET_ARCHITECTURE = PROVEN`

`PREMIUM_CHARACTER_ART = NOT_YET_PROVEN`

`ART_PRODUCTION_PIPELINE = REQUIRES_SEPARATE_SELECTION`

`FULL_CHARACTER_PACK = NOT_STARTED_NOT_ADMITTED`

`SHARKY_COACH_SURFACE_HYPOTHESIS = STRONGLY_VALIDATED`

`SHARKY_COACH_SURFACE_V1 = HIGH_PRIORITY_CANDIDATE_NOT_ADMITTED`

`PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1 = ACTIVE_ADMITTED`

`EXACT_NEXT_ACTION = IMPLEMENT_PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1`

`TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE`

`ACCESSIBILITY_TEXT_SCALING = DEFERRED_NOT_CURRENT_ACCEPTANCE`

`P02 = DEFERRED_NOT_STARTED`

`HNP_HARNESS = CLOSED_UNCHANGED`

`HUMAN_PROOF = FALSE`

`B8 = NOT_ADMITTED`
