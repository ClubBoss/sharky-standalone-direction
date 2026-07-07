# W1-W6 Repair Wave 5 Telemetry Repair Proof v1

Date: 2026-07-07

Branch: `codex/w1-w6-repair-wave5-telemetry-repair-proof-v1`

Base HEAD: `11ff0585d845a813bad8df465e165a813c4c92c7`

Implementation commit: `12b57076`

## 1. Verdict

`w1_w6_repair_wave5_telemetry_repair_proof_closed`

The admitted Wave 5 telemetry proof is closed for the active Act0 learner
decision path. Every committed active runner option decision now emits a single
`user_choice` event with deterministic attribution, result classification,
error type, elapsed decision time, attempt identity, and repair-family
projection. The canonical `decision_made` and local `task_result` events use
the same projection.

No ML, ranking, external analytics SDK, backend, W7+ route activation, content
expansion, scoring change, progression change, or learner-facing copy redesign
was introduced.

## 2. Telemetry Owner Before And After

Before:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` emitted
  `user_choice`, `decision_made`, and `task_result`.
- `decision_made` carried canonical aliases but used generic `unknown` for
  incorrect `error_type`.
- `user_choice` carried only minimal choice and time-bucket fields.

After:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart` remains the single
  active runner telemetry owner.
- `lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart` remains the local sink
  contract; no parallel analytics system was added.
- `_decisionTelemetryProjectionV1` centralizes the event projection used by
  `user_choice`, `decision_made`, and `task_result`.

## 3. Event Schema

`user_choice` is emitted once per committed option choice and now includes:

- `worldId`
- `lessonId`
- `taskId`
- `choiceId`
- `chosen_action`
- `expected_action`
- `acceptable_action_ids`
- `correct`
- `result_classification`
- `error_type`
- `repair_family_id` when repairable
- `route_source_owner`
- `drill_kind`
- `attempt_id`
- `time_to_decision_ms`
- `board_card_ids` when structured board context exists
- `street_v1` when street context exists
- existing `decisionTimeBucket` and `attemptOrdinal`

`decision_made` and `task_result` receive the same result/error/repair and
structured board projection.

## 4. Timer Semantics

The active runner stopwatch still starts when the drill task becomes
actionable in `_maybeEmitTaskShownTelemetry`. The final
`time_to_decision_ms` is captured before the choice commit path stops the
stopwatch. Values are non-negative and local monotonic elapsed time; no wall
clock timezone is involved. The event keeps the existing bucket field for
backward compatibility.

## 5. Evaluator Projection

The projection derives result truth from the same `Act0RunnerOptionV1` fields
used by feedback:

- `Act0FeedbackQualityV1.correct` -> `correct`
- `Act0FeedbackQualityV1.wrong` -> `incorrect`
- `Act0FeedbackQualityV1.suboptimal` -> `suboptimal`

It does not duplicate evaluator logic or reinterpret scoring.

## 6. Error Taxonomy

The deterministic error taxonomy reuses the existing Act0 skill receipt
contract:

- correct choices emit `none`
- incorrect repairable choices emit `missed_<skillAtomId>`
- suboptimal repairable choices emit `thin_<skillAtomId>`
- unrecoverable/no-receipt choices fail closed as `unknown`

Representative active proof includes `missed_action_read`.

## 7. Repair-Family Mapping

Repair-family identity is derived from the same skill receipt:

`<skillAtomId>:<sourceSignalId>`

Example:

`action_read:no_bet_yet`

The repair target hint remains the existing receipt next-rep id, for example
`repeat_action_read`. The active repair queue/router remains owned by the
existing repair-intent and repair-outcome contracts.

## 8. Repair Routing Proof

Existing repair-routing tests prove:

- wrong `actions_legal_context` choice creates `missed_action_read`;
- the repair family maps to the active `actions_check_drill` target;
- Practice queue CTA launches that mapped active target;
- correct repair answer records `repair_correct_v1`;
- failed repair answer records needs-rep outcome and keeps resolver priority;
- repeated derivation stays deterministic and idempotent.

## 9. Representative Paths

Focused telemetry coverage now proves representative active runtime paths:

| World | Representative task | Proof |
| --- | --- | --- |
| W1 | `actions_legal_context` | incorrect action-read miss emits `missed_action_read`, `action_read:no_bet_yet`, attempt id, and decision time |
| W3 | `button_advantage_button_open` | representative W3 decision emits one attributed `user_choice` and one correlated `decision_made` |
| W4 | `w4_good_price_call` | representative W4 price decision emits typed result/error/repair attribution |
| W5 | `board_texture_basics_w5_dry_board` | W5 board-aware decision emits `board_card_ids` and `street_v1` |
| W6 | `w6_missed_dry_board` | representative W6 range-thinking decision emits typed result/error/repair attribution |

## 10. Broad Guard Result

The focused broad guards remain green:

- active W1-W6 feedback completeness: `374` active rows, zero violations;
- runtime-bundle parity guard: active W1-W6 drill indexes stay in source, test
  bundle, and runtime bundle parity;
- canonical truth map guard locks learner-facing world identity;
- W3 and W5 runtime truth guards pass;
- W5 structured context guards pass.

The prior stale command name `test/guards/tier0_admission_set_contract_test.dart`
does not exist in this repository state. The current release gate provides the
Tier0/state/all-guards selected set and passed.

## 11. Exactly-Once And No-Drop Proof

Exactly-once proof:

- `user_choice` is keyed by world, lesson, task, phase, and option id.
- repeated taps after commit do not produce a second `user_choice` in the
  covered active runner path.
- representative W1/W3/W4/W5/W6 guard asserts exactly one `user_choice` and
  one correlated `decision_made` per committed decision.

No-drop proof:

- event projection is computed before the sink call;
- sink failure remains non-blocking through the existing try/catch policy;
- existing non-blocking sink tests still pass.

## 12. Semantic Diff

Changed:

- telemetry fields for active Act0 runner choices.

Unchanged:

- expected actions;
- acceptable actions;
- option quality;
- scoring;
- feedback meaning;
- route order;
- progression;
- canonical world identity;
- W1-W6 source/runtime parity;
- W5 structured content source;
- learner-visible copy and layout.

## 13. Validation

Focused red-green proof:

- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart --plain-name 'Act0 runner emits safe incorrect result telemetry' -r compact`
  - red: failed because `chosen_action` and deterministic error projection were absent;
  - green: passed after projection implementation.
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart --plain-name 'W5 structured board context is attributed to decision telemetry' -r compact`
  - red: failed because `board_card_ids` was absent;
  - green: passed after structured table projection.

Focused tests and guards:

- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart -r compact`: PASS, 18 tests.
- `flutter test test/ui_v2/act0_repair_intent_resolver_v1_test.dart -r compact`: PASS, 21 tests.
- `flutter test test/ui_v2/act0_repair_outcome_projection_v1_test.dart test/ui_v2/act0_queue_resolution_contract_v1_test.dart -r compact`: PASS, 22 tests.
- `flutter test test/services/drill_runtime_adapter_v1_asset_bundle_test.dart -r compact`: PASS, 9 tests.
- `dart test test/tools/w1_w6_feedback_completeness_guard_v1_test.dart -r compact`: PASS, 2 tests; `374` active rows.
- `flutter test test/guards/canonical_truth_map_v1_contract_test.dart -r compact`: PASS, 15 tests.
- `flutter test test/guards/world3_early_arc_runtime_truth_contract_test.dart test/guards/world5_early_runtime_truth_contract_test.dart -r compact`: PASS, 5 tests.
- `flutter test test/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1_test.dart test/ui_v2/session_drill_player_world5_structured_context_contract_test.dart -r compact`: PASS, 3 tests.
- `dart run tools/term_coverage_scanner.dart --help`: PASS.
- `./tools/fast_loop_world1_v1.sh`: PASS.
- `./tools/release_gate_world1.sh`: PASS.
- `flutter analyze`: PASS.
- `git diff --check`: PASS.
- `git diff --cached --check`: PASS.
- `graphify hook-check`: PASS.

Checkpoint:

- `./tools/checkpoint_world1_v1.sh` passed release-gate/Tier0/checkpoint
  contract sections.
- It then entered the known unrelated global full-suite debt zone and was
  stopped after repeated non-Wave-5 failures appeared.
- Observed unrelated failures included missing `audit_hub_v1` imports, stale
  personalization expectation drift, stale `stack_range_filter_test.dart`
  function-call syntax, stale smoke syntax/API drift, missing archived/dormant
  UI imports, and `actionsMap` gaps for legacy MVS spot kinds.

## 14. Remaining Unrelated Global Debt

The global full-suite remains outside this Wave 5 lane. The failures reproduced
during checkpoint are not caused by the telemetry projection diff and are not in
the active Act0 W1-W6 repair path touched here.

## 15. W1-W6 Repair-Program Closure Readiness

Wave 5 is ready for owner review as closed for deterministic active-runner
decision telemetry and repair proof. Human QA is still not executed and no
public learning-effect, launch, mastery, or 9.0 claim becomes safe from this
technical proof alone.

## 16. Next Owner Action

Review and, if accepted, integrate
`codex/w1-w6-repair-wave5-telemetry-repair-proof-v1` into `main` without
opening unrelated full-suite debt.

## 17. Token Efficiency Report

- exact_usage: unavailable from local runtime
- estimated_total_tokens: 60000-80000
- estimate_confidence: medium
- estimated_input_context: attachment, AGENTS, context capsules, owner slices,
  focused test and validation output
- estimated_reasoning_and_output: high due bounded implementation, repeated
  validation, and checkpoint output
- estimate_basis: local transcript length and command output volume
