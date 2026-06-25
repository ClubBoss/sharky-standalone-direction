# Practice Repair Queue Row CTA v1

## 1. Verdict

practice_repair_queue_active_repair_cta_ready

## 2. Accepted launch contract consumed

The row CTA consumes the accepted `Act0PracticeRepairQueueLaunchTargetV1` contract through `Act0PracticeRepairQueueConsumerV1`.

The UI does not infer launchability from learner-facing labels, context, error detail, or row position.

## 3. CTA visibility rules

CTA copy: `Practice this`.

The CTA renders only when all of these are true:

- the row view model is launchable;
- the row has a launch target;
- the launch target has `targetType == active_repair_target_v1`;
- the Practice shell has a launch callback.

Rows with `not_launchable_v1` remain passive.

## 4. Launch behavior

The row CTA passes the projection-owned launch target to the Practice shell callback.

The Act0 preview shell accepts only `active_repair_target_v1` targets and routes through the existing world/lesson/task launch helper. No new route family, screen, drill engine, or route truth was added.

## 5. History-only passive boundary

History-only rows do not get a CTA.

They remain display-only until a future contract explicitly provides route-owned launch metadata.

## 6. Resolution-state boundary

The CTA does not remove a queue row.

The CTA does not mark a row fixed, clear, resolved, complete, mastered, or repaired.

## 7. Route/progression/telemetry boundary

No new telemetry call site was added.

No progression mutation or resolution state was added.

The route target must already be present in the launch contract; the CTA does not create or infer a route target.

## 8. Forbidden-copy proof

The only new visible CTA copy is `Practice this`.

Forbidden copy families were not added: fix, clear, resolve, complete, master, leak, AI, GTO, solver, premium.

## 9. Screenshot proof

Required local screenshot commands:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Generated packets remain local under `output/screen_review/current/` and are not source artifacts.

Captured locally:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

## 10. Tests / validation

Focused tests cover:

- CTA renders for `active_repair_target_v1`.
- CTA does not render for passive/history rows.
- CTA invokes the launch callback with expected target IDs.
- CTA does not remove the queue row.
- Existing Practice hero/daily drill remains.
- Forbidden copy families are absent.
- Projection/consumer launch contract tests remain green.
- Existing repair resolver tests remain green.

Validation run:

- `flutter test test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart` - passed.
- `./tools/screen_review_fast_v1.sh first_week compact` - passed.
- `./tools/screen_review_fast_v1.sh day2_return compact` - passed.
- `./tools/screen_review_fast_v1.sh full_scroll compact` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed` on touched Dart/test files - passed.
- `git diff --check` - passed.

## 11. Next recommended PR

Practice Queue Target Launch Audit v1: add a focused end-to-end Act0 shell test that enters Practice from a real active repair state, taps the row CTA, and verifies the selected task matches the launch target without adding resolution semantics.
