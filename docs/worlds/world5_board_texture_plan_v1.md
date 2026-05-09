# World 5 Board Texture Plan V1

## A) Cognitive Shift
- Move from static action recall to board-texture-first decisions where action quality depends on flop-turn-river pattern and position context.

## B) Sessions s01..s10
- `w5.s01` Title: Texture Buckets Intro
  - Objective: Identify dry, neutral, and wet board textures and map each to a baseline action intent.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: overgeneralized_action_on_texture.
- `w5.s02` Title: Dry Board Value Discipline
  - Objective: Reinforce value and control lines on dry textures with low draw pressure.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: missed_value_on_dry_board.
- `w5.s03` Title: Wet Board Protection
  - Objective: Select protection-oriented actions when texture supports many draws.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: underprotection_on_wet_board.
- `w5.s04` Title: Turn Texture Shift
  - Objective: Detect turn cards that change texture category and update action intent deterministically.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: stale_plan_after_turn_shift.
- `w5.s05` Title: River Texture Closure
  - Objective: Close lines correctly when river cards complete or fail key draws.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: incorrect_river_closure.
- `w5.s06` Title: In Position Texture Response
  - Objective: Apply texture-driven aggression control while acting in position.
  - Drill mix: `seat_tap`, `board_tap`, `action_choice`, `hole_cards_tap` (6+ drills).
  - Target error class: ip_timing_mismatch.
- `w5.s07` Title: Out of Position Texture Response
  - Objective: Apply texture-aware defensive and value lines while out of position.
  - Drill mix: `seat_tap`, `board_tap`, `action_choice`, `hole_cards_tap` (6+ drills).
  - Target error class: oop_overextension.
- `w5.s08` Title: Draw Completion Awareness
  - Objective: Track likely draw completion patterns and choose compatible action families.
  - Drill mix: `board_tap`, `action_choice`, `seat_tap`, `hole_cards_tap` (6+ drills).
  - Target error class: draw_completion_blindness.
- `w5.s09` Title: Texture and Blocker Context
  - Objective: Combine visible texture with hole-card blocker context for final action choice.
  - Drill mix: `hole_cards_tap`, `board_tap`, `action_choice`, `seat_tap` (6+ drills).
  - Target error class: blocker_texture_mismatch.
- `w5.s10` Title: Texture Synthesis Checkpoint
  - Objective: Integrate texture classification, position, and street transition into stable decisions.
  - Drill mix: `seat_tap`, `board_tap`, `hole_cards_tap`, `action_choice` (6+ drills).
  - Target error class: multi_signal_integration_failure.

## C) Guardrails
- No schema changes.
- No tool changes.
- Reuse existing `why_v1` patterns and runtime-valid constraints.
- Keep fast loop and deterministic checkpoints stable.

## D) Exit Criteria for World 5 Content Completion
- `dart run tools/checkpoint_drills_content_v1.dart --world-min 0 --world-max 9` passes.
- `audit_why_v1_coverage_v1` reports no missing staged-session coverage and no invalid `why_v1`.
- World 5 sessions `w5.s01..w5.s10` exist with 6+ drills each using existing drill kinds only.
- Session and drill manifests stay deterministic and checkpoint-export consistent.
