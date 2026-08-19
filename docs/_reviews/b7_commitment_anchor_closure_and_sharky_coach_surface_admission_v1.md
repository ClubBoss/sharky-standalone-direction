# B7 Commitment Anchor Closure + Sharky Coach Surface Admission v1

Status: AUTHORITY / ACTIVE DISPATCH
Freshness date: 2026-08-19
Repository: `ClubBoss/sharky-standalone-direction`

## Purpose

Reconcile merged PR #205, close the admitted player commitment-anchor subtask,
apply the B7 Completion Disposition Rule to the remaining material classes, and
advance B7 by exactly one bounded subtask:

`SHARKY_COACH_SURFACE_V1`.

This authority does not modify product code, tests, GitHub Actions workflows,
scene geometry, commitment geometry, poker truth, character assets, P02, HNP,
or B8.

Product direction remains governed by
`docs/plan/MASTER_PLAN_v4_NORTH_STAR_INTEGRATED.md`.

## Starting canonical state

Pre-authoring canonical main:

`7144e4c3bbe0319f9552637ca02d6450304f0a2f`

PR #205 final state:

- state: `CLOSED`
- merged: `TRUE`
- exact implementation head:
  `64da9ffca1a418ed98b9fe5fb23e978953d03289`
- merge commit / canonical main:
  `7144e4c3bbe0319f9552637ca02d6450304f0a2f`

The prior admission authority is:

`docs/_reviews/b7_scene_geometry_closure_and_commitment_anchor_admission_v1.md`

That authority admitted `PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1`. This document
closes that bounded subtask and advances B7 by exactly one bounded subtask.

## A. PR #205 / player commitment-anchor closure

Record:

`PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1 = CLOSED_PASS`

`PR205_IMPLEMENTATION = CLOSED_PASS`

Exact implementation head:

`64da9ffca1a418ed98b9fe5fb23e978953d03289`

Merge commit / canonical main:

`7144e4c3bbe0319f9552637ca02d6450304f0a2f`

### Accepted proof

- deterministic seat-ID commitment ownership;
- one physical commitment anchor per seat;
- same physical slot for post/call/bet/raise semantics;
- dealer ownership remains separate;
- center pot ownership remains separate;
- real W8 multi-seat fixture proves concurrent BTN / CO / BB ownership;
- rendered SB/BB commitment position remains invariant through:
  - decision;
  - correct feedback;
  - wrong feedback;
  - repair;
  - recheck;
  - continuation/result;
- invariant proven at `375 / 402 / 430`;
- existing `0.5 px` geometry tolerance respected;
- production camera/table geometry unchanged;
- no B4 `betAnchor` resurrection;
- valid required pre-merge exact-head repository CI green.

### PR #205 required gate disposition

Use the valid pre-merge exact-head gate evidence:

- R5 release gate = `SUCCESS`;
- Sharky Web QA Mirror = `SUCCESS`;
- Test Authority Lanes = `SUCCESS`;
- Theory Integrity run #942 (`32277507728`) = `SUCCESS`;
- Health = `SUCCESS`;
- L2 Tests (conditional) = policy `SKIPPED`.

`TestSprite Pre-Check` remains outside the required repository gate set.

### Theory Integrity run #943 forensic context

Record only as non-product CI context:

`THEORY_INTEGRITY_RUN_943 = CI_DIFF_DETECTION_RACE / INFRASTRUCTURE_ONLY`

`THEORY_CONTENT_FAILURE = FALSE`

`PR205_ATTRIBUTED_FAILURE = FALSE`

Run #943 (`32278682972`) failed only in
`Detect theory changes (git diff)` with:

`fatal: origin/main...aecc342b2cfd393a1e23772344d25b586b73b4f3: no merge base`

Strict theory verification never ran. The failure is not a PR #205 product or
theory failure and does not reopen PR #205.

Workflow repair is not admitted here.

Process guidance for later PRs: when `ready_for_review` triggers a fresh Theory
Integrity run, allow that run to settle before immediate merge so the same
live-base race is not recreated.

## B. W8 baseline residual

Record:

`W8_BTN_POT_OVERLAP = PRE_EXISTING_BASELINE_VISUAL_DEBT`

`PR205_ATTRIBUTION = FALSE`

Disposition:

`DEFER_LOW_EV`

`NOT_ADMITTED`

Do not repair it. Do not reopen camera, B4, table geometry, commitment ring,
commitment ownership, or pot geometry because of this residual.

## C. B7 Completion Disposition Rule

`B7_COMPLETION_DISPOSITION_RULE_V1 = ACTIVE`.

Every remaining material class receives one explicit disposition.

| Material class | Current evidence | Disposition |
| --- | --- | --- |
| Sharky Coach Surface | `SHARKY_COACH_SURFACE_HYPOTHESIS = STRONGLY_VALIDATED`; `COMPATIBLE_WITH_TARGETED_REWORK`; architecture estimate approximately `70-80%` | `IMPLEMENT_NOW` |
| Premium character art | `B7_CHARACTER_VERTICAL_SLICE_V1 = CLOSED_PASS_PROOF`; architecture proven; class-level lift yes; premium art not yet proven; production pipeline requires separate selection | `BLOCKED_PENDING_ASSET_OR_DEPENDENCY` |
| Full character pack | `NOT_STARTED / NOT_ADMITTED` | `BLOCKED_PENDING_ASSET_OR_DEPENDENCY`; remains not admitted |
| W8 BTN/pot overlap | pre-existing baseline visual debt; not attributable to PR #205 | `DEFER_LOW_EV` |
| Inherited reduced-motion proof-beat debt | pre-existing; not a B6 regression/blocker | `DEFER_TO_POST_B7_PRE_P02_MAINTENANCE` |

B7 is not closed by this disposition pass because one material class is now
admitted for bounded implementation.

## D. Sharky Coach Surface admission

Preserve:

`SHARKY_COACH_SURFACE_HYPOTHESIS = STRONGLY_VALIDATED`

`COMPATIBLE_WITH_TARGETED_REWORK`

`ARCHITECTURE_ESTIMATE = APPROXIMATELY_70_TO_80_PERCENT`

Disposition:

`IMPLEMENT_NOW`

Admit exactly:

`SHARKY_COACH_SURFACE_V1 = ACTIVE / ADMITTED`

Canonical product direction:

`SHARKY = VOICE OF THE SCENE`

`TABLE = STABLE PHYSICAL WORLD`

`BOTTOM SHELF = CONTROLS`

Implementation direction:

- large readable coaching text;
- Sharky as speaking owner;
- scene-integrated coaching / speech surface;
- explanation primarily above / within the scene;
- bottom shelf primarily owns actions / CTA;
- no duplicated long explanation above and below;
- Sharky strong in `UNDERSTAND / REPAIR`;
- Sharky restrained in `DECIDE`;
- reduced scaffold in `RECHECK / PROVE`;
- frozen PR #203 camera/table geometry;
- frozen PR #205 commitment ownership;
- existing poker truth and learning contracts.

This admission is for the bounded Coach Surface implementation only. It does
not prescribe or admit final premium character production.

## E. Premium character art remains blocked

Preserve:

`B7_CHARACTER_VERTICAL_SLICE_V1 = CLOSED_PASS_PROOF`

`CHARACTER_ASSET_ARCHITECTURE = PROVEN`

`CLASS_LEVEL_LIFT = YES`

`PREMIUM_CHARACTER_ART = NOT_YET_PROVEN`

`ART_PRODUCTION_PIPELINE = REQUIRES_SEPARATE_SELECTION`

`FULL_CHARACTER_PACK = NOT_STARTED / NOT_ADMITTED`

Disposition:

`PREMIUM_CHARACTER_ART = BLOCKED_PENDING_ASSET_OR_DEPENDENCY`

The character vertical slice remains proof of architecture, not proof of final
premium art quality. Do not admit a full character pack in this authority.

## F. Inherited reduced-motion debt

Preserve exactly:

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = NOT_B6_REGRESSION`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = NOT_B6_BLOCKER`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = MUST_RECEIVE_DISPOSITION_BEFORE_P02`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = DEFER_TO_POST_B7_PRE_P02_MAINTENANCE`

Do not reopen B6.

## G. Exact next action

Set:

`CURRENT_STAGE = VISUAL_GAUNTLET_B7_ACTIVE`

`B7 = ACTIVE / ADMITTED`

`PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1 = CLOSED_PASS`

`SHARKY_COACH_SURFACE_V1 = ACTIVE / ADMITTED`

`EXACT_NEXT_ACTION = IMPLEMENT_SHARKY_COACH_SURFACE_V1`

Do not close B7.

## H. Recommended executor routing

Orchestration guidance only; this is not product authority.

Recommended executor for `SHARKY_COACH_SURFACE_V1`:

`Claude`

Reason: the next bounded family is primarily visual hierarchy, scene
integration, comparative rendered judgment, and art-direction work over an
already-proven architecture.

`Codex` is fallback only if implementation exposes a genuine systemic
architecture blocker.

## Preserved global state

Preserve exactly:

`TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE`

`ACCESSIBILITY_TEXT_SCALING = DEFERRED_NOT_CURRENT_ACCEPTANCE`

`P02 = DEFERRED / NOT_STARTED`

`HNP_HARNESS = CLOSED_UNCHANGED`

`HUMAN_PROOF = FALSE`

`B8 = NOT_ADMITTED`

`CAMERA_RETUNE_AGAIN = NO`

Modern Table remains `MAINTENANCE_MODE` outside admitted Learning Scene work.

## Explicit non-closures / non-admissions

Do not record or infer:

- `B7 = CLOSED`;
- `FULL_CHARACTER_PACK = ADMITTED`;
- `PREMIUM_CHARACTER_ART = PROVEN`;
- `P02 = STARTED`;
- `HUMAN_PROOF = TRUE`;
- `B8 = ADMITTED`;
- W8 BTN/pot overlap repair admitted;
- camera/table geometry reopening;
- commitment-anchor redesign after closure.

## Dispatch after this authority merges

`CURRENT_STAGE = VISUAL_GAUNTLET_B7_ACTIVE`

`B7 = ACTIVE_ADMITTED`

`PLAYER_COMMITMENT_ANCHOR_SYSTEM_V1 = CLOSED_PASS`

`PR205_IMPLEMENTATION = CLOSED_PASS`

`W8_BTN_POT_OVERLAP = PRE_EXISTING_BASELINE_VISUAL_DEBT`

`PR205_ATTRIBUTION = FALSE`

`SHARKY_COACH_SURFACE_HYPOTHESIS = STRONGLY_VALIDATED`

`SHARKY_COACH_SURFACE_V1 = ACTIVE_ADMITTED`

`B7_CHARACTER_VERTICAL_SLICE_V1 = CLOSED_PASS_PROOF`

`CHARACTER_ASSET_ARCHITECTURE = PROVEN`

`CLASS_LEVEL_LIFT = YES`

`PREMIUM_CHARACTER_ART = NOT_YET_PROVEN`

`ART_PRODUCTION_PIPELINE = REQUIRES_SEPARATE_SELECTION`

`FULL_CHARACTER_PACK = NOT_STARTED_NOT_ADMITTED`

`INHERITED_REDUCED_MOTION_PROOF_BEAT_DEBT = DEFER_TO_POST_B7_PRE_P02_MAINTENANCE`

`EXACT_NEXT_ACTION = IMPLEMENT_SHARKY_COACH_SURFACE_V1`

`TEXT_SCALE_POLICY_V1 = SINGLE_CANONICAL_PRODUCT_SCALE`

`ACCESSIBILITY_TEXT_SCALING = DEFERRED_NOT_CURRENT_ACCEPTANCE`

`P02 = DEFERRED_NOT_STARTED`

`HNP_HARNESS = CLOSED_UNCHANGED`

`HUMAN_PROOF = FALSE`

`B8 = NOT_ADMITTED`
