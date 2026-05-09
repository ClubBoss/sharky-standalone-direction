# World 6 Ranges Not Single Hands Plan V1

## A) Cognitive Shift
- Move from single-hand thinking to range-vs-range decisions where actions are selected from distribution strength, not one-card-story bias.

## B) Sessions s01..s10
- `w6.s01` Title: Range Buckets Intro
  - Objective: Identify basic value, medium, and bluff range buckets before selecting action.
  - Drill mix: `action_choice`, `seat_tap`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: single_hand_overfit.
- `w6.s02` Title: Position and Range Width
  - Objective: Adjust range width by position and avoid copying one-position assumptions to all seats.
  - Drill mix: `seat_tap`, `action_choice`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: range_width_position_mismatch.
- `w6.s03` Title: Flop Range Advantage
  - Objective: Detect which side holds range advantage on flop texture and choose compatible action family.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: missed_range_advantage.
- `w6.s04` Title: Turn Range Compression
  - Objective: Re-evaluate range density on turn and avoid stale flop-only action plans.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: stale_range_update.
- `w6.s05` Title: River Polarization
  - Objective: Separate polarized versus merged range endings and select disciplined closures.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: merged_vs_polar_confusion.
- `w6.s06` Title: In Position Range Pressure
  - Objective: Apply in-position pressure using range structure instead of isolated hand anecdotes.
  - Drill mix: `seat_tap`, `action_choice`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: ip_range_pressure_mismatch.
- `w6.s07` Title: Out of Position Range Defense
  - Objective: Choose stable defensive lines out of position based on range equity and texture.
  - Drill mix: `seat_tap`, `action_choice`, `board_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: oop_range_overdefend.
- `w6.s08` Title: Blockers in Range Context
  - Objective: Use blocker cues as range modifiers, not as standalone action triggers.
  - Drill mix: `hole_cards_tap`, `action_choice`, `board_tap`, `seat_tap` (6+ drills).
  - Target error class: blocker_overweighting.
- `w6.s09` Title: Range Transition by Street
  - Objective: Track range transitions from flop to river and keep action families consistent with updated density.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: street_transition_drift.
- `w6.s10` Title: Range Synthesis Checkpoint
  - Objective: Integrate position, texture, and range density into deterministic final decisions.
  - Drill mix: `seat_tap`, `board_tap`, `hole_cards_tap`, `action_choice` (6+ drills).
  - Target error class: range_signal_integration_failure.

## C) Guardrails
- No schema changes.
- No tool changes.
- Reuse existing `why_v1` patterns and runtime-valid constraints.
- Keep fast loop and deterministic checkpoints stable.

## D) Exit Criteria for World 6 Content Completion
- `dart format --set-exit-if-changed .` passes.
- `flutter analyze` passes.
- `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 9` passes.
- `dart run tools/audit_why_v1_coverage_v1.dart --world-min 1 --world-max 9` reports `sessions_missing=0` and `invalid_why_v1=0`.
