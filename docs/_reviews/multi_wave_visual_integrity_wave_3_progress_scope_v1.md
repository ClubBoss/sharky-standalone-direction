# Multi-Wave Visual Integrity — Wave 3 Progress Scope

## Verdict

`green__visible_step_progress_scope_clarified`

## Source trace and bounded change

The visible compact runner header is `_RunnerProgressV1`, which renders the
existing `runner.beatIndex / runner.beatCount` value and progress-bar value.
The similarly named learning-rail helper derives from teaching-step fields but
is not the visible compact header in the active refined route. The original
mission's teaching-step attribution is therefore stale for this capture.

The displayed value and progress-bar inputs remain unchanged. The visible
header now labels them `Step 1/4` (and remains compact at 375pt), making the
local sequence scope explicit without implying world or lesson completion.

## Validation

- `flutter test test/guards/multi_wave_learning_rail_progress_scope_v1_test.dart`
  — passed.
- `flutter test test/guards/w7_w12_table_context_readiness_audit_contract_test.dart`
  — passed (4 tests).
- `flutter analyze` — passed with no issues.
- Fresh compact active-route capture confirms `Step 1/4` is complete and does
  not crowd the back control or bar.

## Fresh literal evidence

- `output/evidence/multi_wave_visual_integrity_v1/wave_3_progress_scope/compact.w7_first_route_task_table.png`
- `output/evidence/multi_wave_visual_integrity_v1/wave_3_progress_scope/compact.w9_first_route_task_table.png`
- `output/evidence/multi_wave_visual_integrity_v1/wave_3_progress_scope/compact.w12_first_review_task_table.png`
- `output/evidence/multi_wave_visual_integrity_v1/wave_3_progress_scope/compact.terminal_no_w13_copy_detail.png`
- `output/evidence/multi_wave_visual_integrity_v1/wave_3_progress_scope/compact.welcome_decision.png`

## Regression and non-claims

No progression data, completion logic, route ownership, W13 behavior,
telemetry, table design, Sharky, or onboarding grammar changed. This is a
compact-header clarity repair only; it makes no Human QA, public-readiness, or
10/10 claim.
