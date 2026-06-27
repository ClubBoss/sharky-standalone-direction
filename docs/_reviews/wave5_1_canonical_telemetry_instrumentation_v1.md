# Wave 5.1 - Canonical Telemetry Instrumentation v1

## 1. Verdict

`wave5_1_canonical_telemetry_instrumentation_ready`

## 2. Source truth

- Prompt contract: Wave 5.1 - Canonical Telemetry Instrumentation v1.
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/plan/TOP1_PRODUCT_ATTACK_PLAN_SSOT_v1.md`
- `docs/_reviews/act0_rule_based_repair_telemetry_truth_v1.md`
- Existing local owners:
  - `lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart`
  - `lib/constants/telemetry_events.dart`
  - `lib/constants/telemetry_schema.dart`

## 3. Implementation summary

- `lib/constants/telemetry_events.dart`
  - Registered canonical local event names:
    `decision_made`, `repair_attempted`, `fix_landed`,
    `session_complete`, `day2_return`, `world_complete`,
    `practice_completed`.
- `lib/constants/telemetry_schema.dart`
  - Added schema definitions for the canonical local learning-loop events.
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
  - Instrumented canonical `decision_made` from the existing answer-selection
    owner, while preserving existing `user_choice` and `task_result`.
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
  - Instrumented canonical session, repair, practice, Day 2 return, and world
    completion events from existing Act0 shell owners.
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`
  - Added focused coverage for canonical event names, available payload fields,
    wrong/correct paths, repair/fix-landed path, practice completion, session
    completion, Day 2 return, world completion, and non-blocking local sink
    behavior.

## 4. Event coverage matrix

| Canonical event | Implemented | Call site | Payload fields emitted | Missing fields | Test coverage | Blocks now? |
| --- | --- | --- | --- | --- | --- | --- |
| `session_start` | Yes | Learn task start and practice start in `Act0ShellPreviewScreenV1` | `world_id`, `lesson_id`, `task_id`, `source_surface` | deterministic `session_id` | `Act0 learn path emits one safe lesson_started telemetry event`; practice path covered through daily loop | Later |
| `decision_made` | Yes | Answer selection in `Act0LessonRunnerShellV1` | `world_id`, `lesson_id`, `task_id`, `concept_family_id`, `selected_action`, `correct_action`, `is_correct`, `error_type`, `time_to_decision_ms`, `source_surface` | deterministic `session_id`; exact `repair_focus_id` only exists after repair mapping | canonical decision test plus existing correct/incorrect result tests | Later |
| `user_choice` | Existing | Answer selection in `Act0LessonRunnerShellV1` | `worldId`, `lessonId`, `taskId`, `choiceId`, `decisionTimeBucket`, `attemptOrdinal` | snake_case aliases are on `decision_made`, not duplicate `user_choice` | existing user-choice assertions | No |
| `repair_attempted` | Yes | Repair launch in `Act0ShellPreviewScreenV1` | `world_id`, `repair_focus_id`, `source_task_id`, `task_id`, `attempt_ordinal`, `source_surface` | deterministic `session_id` | repair flow test | No |
| `fix_landed` | Yes | Correct repair completion in `Act0ShellPreviewScreenV1` | `world_id`, `repair_focus_id`, `source_task_id`, `task_id`, `is_correct`, `result`, `source_surface` | deterministic `session_id`; richer transfer outcome | repair flow test | No |
| `session_complete` | Yes | Practice completion and lesson/world completion summary in `Act0ShellPreviewScreenV1` | `world_id`, `lesson_id`, `task_id`, optional `practice_group_id`, `completed_rep_count`, `clean_rep_count`, `result_summary`, `source_surface` | deterministic `session_id` | daily practice test | No |
| `day2_return` | Yes | Persisted last-session restore on consecutive local day; deterministic debug Day 2 return surface | `world_id`, optional `repair_focus_id`, optional `proof_result`, `source_surface` | first-week cohort fields; server-side return attribution | debug return test; persisted path uses existing local date state | Later |
| `world_complete` | Yes | World completion summary and deterministic debug world-completion surface | `world_id`, `completed_clear_count`, `perfect_clear_count`, `source_surface` | server-side cohort/progression attribution | debug world-completion test | No |
| `practice_completed` | Yes | Daily/practice completion in `Act0ShellPreviewScreenV1` | `practiceGroupId`, `completedRepCount`, `cleanRepCount`, `resultSummary`; paired `session_complete` has snake_case aliases | deterministic `session_id`; exact world/lesson aliases live on paired `session_complete` | daily practice test | No |

## 5. Payload safety

- No fake data was introduced.
- No nondeterministic timestamp payload was added.
- No server, Firebase, Mixpanel, vendor, or network sink was added.
- No PII, email, player name, raw copy, localized copy, prompt text,
  hand-history text, monetization, entitlement, price, or paywall data is
  emitted.

## 6. Learning-loop measurement readiness

The local Act0 telemetry layer can now measure:

- decisions through `user_choice`, `decision_made`, and `task_result`;
- correctness through `is_correct`, `result`, and `error_type`;
- repair starts through `repair_attempted`;
- fix landed through `fix_landed`;
- session completion through `session_complete`;
- practice completion through `practice_completed`;
- Day 2 return through `day2_return` when prior-session local state exists on
  a consecutive local day;
- world completion through `world_complete` where the current route supports
  world-completion summary state.

## 7. Remaining telemetry gaps

P1 for current local instrumentation:

- Define a deterministic local `session_id` owner if future measurement needs
  cross-event joins inside a run.
- Decide whether `practice_completed` should duplicate snake_case world/lesson
  aliases directly or continue using paired `session_complete`.

P2 before beta:

- Add first-week local aggregation fields only after the product decides the
  first-week proof contract.
- Add transfer-measurement events for OP-19 after the learning-transfer seam is
  explicitly defined.

Strategic/server-side later:

- Add server-side analytics sink only in OP-05 or a later approved analytics
  wave.
- Add cohort, retention, and learning-effect dashboards only after privacy,
  consent, and sink ownership are scoped.

## 8. Tests

Updated focused test:

`flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart -r expanded`

Coverage added or preserved:

- canonical event names emit;
- payload includes available fields;
- wrong and correct decision paths emit safely;
- repair attempt and fix-landed path emits;
- practice completion emits;
- session completion emits;
- Day 2 return and world completion emit;
- throwing telemetry sink remains non-blocking;
- no server sink is required.

## 9. Anti-drift proof

- No UI redesign.
- No W5-W12 route/content opening.
- No AI, chat, persona, or personalization expansion.
- No monetization, paywall, pricing, purchase, or entitlement change.
- No server analytics.
- No new dependencies.
- No screenshot pipeline changes.

## 10. Next recommendation

Next recommended wave:

`W1-W6 Content Depth / Same-Signal Coverage Audit`

Reason: OP-04 now has a local-first event contract for the current Act0/W1-W4
loop. The next highest leverage route is proving whether the visible foundation
content has enough same-signal coverage for those events to show real learning
effect rather than sparse activity.
