# World 7 Stack Depth Changes Strategy Plan V1

## A) Cognitive Shift
- Move from static action habits to stack-depth-aware strategy where ranges and action sizes change as effective stacks change.

## B) Sessions s01..s10
- `w7.s01` Title: Stack Depth Buckets Intro
  - Objective: Identify shallow, medium, and deep stack buckets before selecting any action line.
  - Drill mix: `action_choice`, `seat_tap`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: stack_depth_misread.
- `w7.s02` Title: Shallow Stack Discipline
  - Objective: Use tighter, lower-complexity actions at shallow depth and avoid deep-stack assumptions.
  - Drill mix: `action_choice`, `seat_tap`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: shallow_overplay.
- `w7.s03` Title: Medium Stack Flexibility
  - Objective: Apply balanced call-raise mix at medium depth without drifting to single-line play.
  - Drill mix: `action_choice`, `board_tap`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: medium_depth_line_lock.
- `w7.s04` Title: Deep Stack Leverage
  - Objective: Expand strategic options at deep depth while keeping range and board context coherent.
  - Drill mix: `action_choice`, `board_tap`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: deep_stack_underrealization.
- `w7.s05` Title: Depth Shift on Turn
  - Objective: Re-evaluate plan when effective stack depth changes after prior actions by turn.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: depth_shift_ignored.
- `w7.s06` Title: In Position by Depth
  - Objective: Adjust in-position pressure cadence based on current depth bucket.
  - Drill mix: `seat_tap`, `action_choice`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: ip_depth_pressure_mismatch.
- `w7.s07` Title: Out of Position by Depth
  - Objective: Choose defensive lines out of position that match depth-constrained risk profile.
  - Drill mix: `seat_tap`, `action_choice`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: oop_depth_overdefend.
- `w7.s08` Title: Depth and Blocker Interaction
  - Objective: Apply blocker cues only after depth bucket and range context are established.
  - Drill mix: `hole_cards_tap`, `action_choice`, `board_tap`, `seat_tap` (6+ drills).
  - Target error class: blocker_depth_mismatch.
- `w7.s09` Title: River Closure by Depth
  - Objective: Close river actions with depth-aware thresholds for call, fold, or raise decisions.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: depth_closure_error.
- `w7.s10` Title: Depth Synthesis Checkpoint
  - Objective: Integrate depth bucket, position, board, and range into deterministic final decisions.
  - Drill mix: `seat_tap`, `board_tap`, `hole_cards_tap`, `action_choice` (6+ drills).
  - Target error class: depth_signal_integration_failure.

## C) Guardrails
- No schema changes.
- No tool changes.
- Reuse existing `why_v1` patterns and runtime-valid constraints.
- Keep fast loop and deterministic checkpoints stable.

## D) Exit Criteria for World 7 Content Completion
- `dart format --set-exit-if-changed .` passes.
- `flutter analyze` passes.
- `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 9` passes.
- `dart run tools/audit_why_v1_coverage_v1.dart --world-min 1 --world-max 9` reports `sessions_missing=0` and `invalid_why_v1=0`.
