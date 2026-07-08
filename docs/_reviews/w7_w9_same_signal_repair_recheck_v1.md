# W7-W9 Same-Signal Repair/Recheck v1

Status: closed

## Scope

This pass integrates the accepted W7-W9 completion payoff baseline and adds
same-signal repair routing for the canonical W7-W9 source families without
changing W7-W9 identity, campaign progression, poker answers, monetization, or
visual surfaces.

## Closed

- W7 visible-card misses now map before the legacy W1 board fallback:
  - `visible_king_combo_reduction_intro` -> `paired_board_texture_lite_intro`
  - `paired_board_texture_lite_intro` -> `visible_card_combo_density_transfer_check`
  - `visible_card_combo_density_transfer_check` -> `visible_king_combo_reduction_intro`
- W8 stack-depth misses now map to launchable same-family W8 route drills:
  - `short_stack_all_in_pressure_intro` -> `w7_low_spr_commit`
  - `deep_stack_postflop_room_intro` -> `w7_high_spr_room`
  - `stack_to_pot_commitment_lite` -> `w7_spr4_middle`
  - `all_in_threshold_transfer_check` -> `w7_20bb_wider`
- W9 tournament-pressure misses now map to launchable same-family W9 route
  drills:
  - `bubble_survival_pressure_intro` -> `w9_short_stack_survival`
  - `risk_premium_medium_stack_intro` -> `w9_medium_stack_tighten`
  - `short_stack_ladder_pressure_lite` -> `w9_bubble_short_stack`
  - `pressure_transfer_check` -> `w9_checkpoint_table_notice`
- Practice queue repairs now emit safe repair start/completion telemetry from
  the queued source/target ids.
- Correct mapped repair completion clears matching open repair intents by
  completed target task; failed repair attempts keep the intent active.
- Mapped repair completion is target-scoped and does not mark the source world
  or lesson complete.

## Recheck

Targeted recheck telemetry remains owned by the existing Act0 retention recheck
path and is validated by `test/ui_v2/act0_telemetry_sink_v1_test.dart`.

## Notes

The current launchable W8 route drills still use legacy `w7_` task id prefixes
inside the canonical `world_8` Stack Depth And Risk world. This pass did not
rename route task ids because identity/curriculum migration was outside scope.
