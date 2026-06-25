# Repair Outcome Projection v1

## 1. Verdict

repair_outcome_data_only_ready

## 2. Prior source-link blocker addressed

The prior blocker was source linkage from Practice queue launch into the answered task context.

That blocker is now addressed by `Act0PracticeRepairQueueLaunchRequestV1`, which carries source identity and target identity together. This PR consumes that request plus the answered task result to create a data-only repair outcome.

## 3. Projection owner

`Act0RepairOutcomeProjectionV1` owns repair outcome view/state.

It does not own Practice queue removal, Review history resolution, progression, telemetry, Session Summary, achievements, or visible UI.

## 4. Source handoff consumed

The projection accepts an `Act0PracticeRepairQueueLaunchRequestV1`.

The Act0 shell stores the active Practice queue launch request only after a valid `Practice this` launch succeeds. When the learner answers the launched target task, the shell appends a repair outcome from:

- source handoff request;
- selected option id;
- correct option id;
- correctness result;
- deterministic outcome sequence.

Normal tasks and passive history rows create no repair outcome.

## 5. Outcome schema

`Act0RepairOutcomeV1` fields:

- `schemaVersion`
- `sourceTaskId`
- `repairTaskId`
- `repairFocusKey`
- `queueItemId`
- `targetWorldId`
- `targetLessonId`
- `targetTaskId`
- `selectedChoiceId`
- `correctChoiceId`
- `isCorrect`
- `outcomeState`
- `sequence`
- `sourceType`

## 6. Safe outcome states

Only these states are admitted:

- `repair_attempted_v1`
- `repair_correct_v1`
- `repair_still_needs_rep_v1`

Forbidden states were not admitted:

- `fixed_v1`
- `cleared_v1`
- `resolved_v1`
- `completed_v1`
- `mastered_v1`

## 7. Correctness mapping

Mapping:

- `isCorrect == true` -> `repair_correct_v1`
- `isCorrect == false` -> `repair_still_needs_rep_v1`
- `isCorrect == null` -> `repair_attempted_v1`

If the repair source request is missing or not an active repair request, no outcome is created.

## 8. Queue boundary

The Practice queue item remains queued/unresolved.

For Practice queue outcomes, the shell does not clear the active repair intent and does not emit fixed/cleared/resolved/completed learner-facing result copy.

## 9. Review history boundary

No Review history clearing or resolution behavior was added.

This projection does not mutate Review history state or claim that a Review item was fixed, cleared, resolved, completed, or mastered.

## 10. UI/Session Summary/Achievement boundary

No visible UI was added.

No Profile, Practice visual, Review UI, Home, Learn, Session Summary, achievement, Modern Table, premium/paywall, or route-family behavior changed.

## 11. Forbidden-claim proof

No learner-facing mastery, leak, AI, GTO, solver, premium, or paywall claim was added.

The data-only projection avoids fixed/cleared/resolved/completed/mastered state names.

Existing unrelated legacy copy was not edited in this task.

## 12. Tests / validation

Focused tests cover:

- repair-launched target answered correct creates `repair_correct_v1`;
- repair-launched target answered incorrect creates `repair_still_needs_rep_v1`;
- repair-launched target without correctness creates `repair_attempted_v1`;
- normal task without repair source creates no repair outcome;
- history/passive request creates no repair outcome;
- outcome preserves source identity and target identity;
- queue item/active repair intent remains present after Practice queue answer;
- no fixed/cleared/resolved/completed copy appears for Practice queue outcomes;
- deterministic ordering;
- safe states only.

Validation run:

- `flutter test test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_repair_outcome_contract_v1_test.dart test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed` on touched Dart/test files - passed.
- `git diff --check` - passed.
- `git status --short` - only intended source/test/review changes plus existing generated output directories.

Screenshots were not required because no visible UI changed.

## 13. Next recommended PR

Repair Outcome Consumer / Local Proof Surface v1.

Only after this data projection remains stable should a separate PR decide whether any compact, non-resolution local proof should be displayed. That future PR must still avoid queue clearing and Review history resolution unless a separate resolution contract is accepted.
