# World 8 Tournament Basics ICM Plan V1

## A) Cognitive Shift
- Move from chip-EV-only decisions to tournament-survival-aware choices where ICM pressure changes correct actions by payout context.

## B) Sessions s01..s10
- `w8.s01` Title: ICM Buckets Intro
  - Objective: Identify low, medium, and high ICM pressure buckets before choosing an action.
  - Drill mix: `action_choice`, `seat_tap`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: icm_pressure_misread.
- `w8.s02` Title: Risk Premium Basics
  - Objective: Apply risk premium logic to avoid chip-EV calls that are tournament-negative under pressure.
  - Drill mix: `action_choice`, `board_tap`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: risk_premium_ignore.
- `w8.s03` Title: Survival Versus Aggression
  - Objective: Balance survival and aggression based on ICM pressure and stack distribution.
  - Drill mix: `action_choice`, `seat_tap`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: survival_aggression_imbalance.
- `w8.s04` Title: Bubble Pressure Reads
  - Objective: Detect bubble-like pressure states and tighten or loosen ranges appropriately.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: bubble_pressure_misplay.
- `w8.s05` Title: Covering Versus Covered
  - Objective: Adjust strategy when covering opponents versus when covered under ICM constraints.
  - Drill mix: `seat_tap`, `action_choice`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: stack_relation_icm_error.
- `w8.s06` Title: Short Stack Push-Fold ICM
  - Objective: Choose push or fold with short stacks using ICM-aware thresholds.
  - Drill mix: `action_choice`, `seat_tap`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: short_stack_icm_threshold_error.
- `w8.s07` Title: Medium Stack Navigation
  - Objective: Navigate medium stacks with selective pressure while preserving tournament life value.
  - Drill mix: `action_choice`, `board_tap`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: medium_stack_icm_drift.
- `w8.s08` Title: ICM and Blocker Context
  - Objective: Use blocker cues only after confirming ICM pressure and payout-sensitive risk levels.
  - Drill mix: `hole_cards_tap`, `action_choice`, `board_tap`, `seat_tap` (6+ drills).
  - Target error class: blocker_icm_mismatch.
- `w8.s09` Title: Late Street ICM Closure
  - Objective: Close river decisions with ICM-aware call-fold-raise thresholds.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: late_street_icm_closure_error.
- `w8.s10` Title: ICM Synthesis Checkpoint
  - Objective: Integrate pressure bucket, stack relation, blockers, and board flow into deterministic final decisions.
  - Drill mix: `seat_tap`, `board_tap`, `hole_cards_tap`, `action_choice` (6+ drills).
  - Target error class: icm_signal_integration_failure.

## C) Guardrails
- No schema changes.
- No tool changes.
- Reuse existing `why_v1` patterns and runtime-valid constraints.
- Keep fast loop and deterministic checkpoints stable.

## D) Exit Criteria for World 8 Content Completion
- `dart format --set-exit-if-changed .` passes.
- `flutter analyze` passes.
- `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 9` passes.
- `dart run tools/audit_why_v1_coverage_v1.dart --world-min 1 --world-max 9` reports `sessions_missing=0` and `invalid_why_v1=0`.
