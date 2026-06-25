# Repair Outcome Consumer / Local Proof Surface v1

## 1. Verdict

repair_outcome_local_proof_ready

## 2. Accepted projection consumed

`Act0RepairOutcomeProjectionV1` remains the source-owned outcome contract. The new `Act0RepairOutcomeConsumerV1` reads that projection and maps the latest deterministic repair outcome to a compact local proof line.

Accepted outcome states consumed:

- `repair_correct_v1`
- `repair_still_needs_rep_v1`
- `repair_attempted_v1`

## 3. Consumer owner map

- Projection owner: `lib/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart`
- Consumer owner: `lib/ui_v2/act0_shell/act0_repair_outcome_consumer_v1.dart`
- Local proof rendering owner: `Act0FeedbackShellV1` in `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- Active-shell handoff owner: `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

## 4. Local proof copy rules

The visible proof surface uses a single title and one compact detail line:

- Title: `Repair rep`
- Correct: `Good rep - you chose the better action.`
- Still needs rep: `Still worth repeating.`
- Attempted: `Repair rep attempted.`

The copy stays local and descriptive. It does not claim the queue item was fixed, cleared, resolved, completed, mastered, or removed.

## 5. UI placement

The proof appears inside the existing Act0 answer feedback receipt area after a Practice queue-launched repair answer. It is not a new screen, badge, animation, route, or Practice redesign.

The proof is keyed separately from the older repair-result receipt:

- `act0_shell_repair_outcome_proof`
- `act0_shell_repair_outcome_proof_card`
- `act0_shell_repair_outcome_proof_title`
- `act0_shell_repair_outcome_proof_line`

## 6. Correct / incorrect / attempted behavior

Correct active repair answer:

- projection emits `repair_correct_v1`
- consumer shows `Repair rep`
- detail shows `Good rep - you chose the better action.`

Incorrect active repair answer:

- projection emits `repair_still_needs_rep_v1`
- consumer shows `Repair rep`
- detail shows `Still worth repeating.`

Attempted state:

- consumer maps `repair_attempted_v1` to `Repair rep attempted.`

## 7. Queue-resolution boundary

The consumer is read-only. It does not remove queue rows, mark queue items done, clear repair history, or write any resolution state.

Existing tests continue to assert that the active repair intent remains after repair answers unless an older pre-existing resolver rule explicitly prioritizes otherwise.

## 8. Route/progression/telemetry boundary

No route family changed. No progression mutation was added. No telemetry call site was added.

The Act0 preview shell still reuses the existing selected task and repair source flow. The new proof line is derived from the local projection only when the active repair task matches the selected play task.

## 9. Forbidden-copy proof

Focused tests scan the new consumer proof copy for forbidden claim families. The new local proof avoids:

- fixed
- cleared
- resolved
- completed
- mastered
- leak
- AI
- GTO
- solver
- premium

## 10. Screenshot proof

Required compact packets were regenerated locally:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Generated artifacts remain local under `output/screen_review/current/` and are not part of the commit.

## 11. Tests / validation

Focused tests:

- `flutter test test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_repair_outcome_consumer_v1_test.dart test/ui_v2/act0_result_feedback_rhythm_surface_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart`

Static validation:

- `graphify hook-check`
- `flutter analyze`
- `dart format --set-exit-if-changed` on touched Dart/test files only
- `git diff --check`
- `git status --short`

## 12. Fixes, if any

One local rendering blocker was fixed: the existing feedback receipt guard suppressed receipt-style proof on wrong answers. The guard now still suppresses legacy repair receipt semantics for wrong answers, while allowing the new read-only outcome proof because it uses non-resolution copy.

## 13. Next recommended PR

Next safest PR: a bounded repair-outcome review/audit pass that proves the local proof remains read-only across additional active-repair fixtures, without adding queue clearing or Review history resolution semantics.
