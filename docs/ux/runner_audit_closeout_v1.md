# Runner Audit Closeout v1

## Scope
- Audited World1 runner correctness and learning-loop surfaces in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`.
- Focused on action availability, incorrect-answer handling, street progression, and visible explanation after error.
- Evidence is anchored to the existing runner contract tests in `test/guards/world1_core_loop_telemetry_contract_test.dart`.

## Guarantees
- Action availability: Call vs Check is derived from `toCall` through `_campaignActionUiStateForCurrentStep()` and `DecisionBarV1.buildFromSnapshot()` in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:2410` and `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:2467`.
  Contract: `CALL` is present when `toCall > 0`, and `CHECK` is present when `toCall == 0`, locked by `test/guards/world1_core_loop_telemetry_contract_test.dart:245` and `test/guards/world1_core_loop_telemetry_contract_test.dart:267`.
- Incorrect answer path: the runner returns `DecisionVerdictV1.incorrect` on hero-action mismatch or violation in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:1143` and `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:1163`.
  Contract: telemetry emits `correct == false` and `error_type == 'range'`, locked by `test/guards/world1_core_loop_telemetry_contract_test.dart:221` and `test/guards/world1_core_loop_telemetry_contract_test.dart:225`.
- Street progression: progression is gated by explicit continue/step flow in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:2238` and `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:2294`, while the outcome surface blocks live progression in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:1674`.
  Contract: no unintended street advance after the incorrect action is locked by `test/guards/world1_core_loop_telemetry_contract_test.dart:236`; explicit multi-step continue before the next action state is locked by `test/guards/world1_core_loop_telemetry_contract_test.dart:283` and `test/guards/world1_core_loop_telemetry_contract_test.dart:293`.
- Why visibility: incorrect outcomes render reason, category, and next hint via `_showOutcomeSurface()` in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:1674`; incorrect status lines read from the detailed outcome lines in `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart:2368`.
  Contract: the visible sentence `Action is valid but does not match expected strategy action` is asserted in `test/guards/world1_core_loop_telemetry_contract_test.dart:230`.

## Contract Tests
- `test/guards/world1_core_loop_telemetry_contract_test.dart:180`
  Covers incorrect path, visible `CALL`, visible why text, and no unintended `Street ->` progression after the wrong action.
- `test/guards/world1_core_loop_telemetry_contract_test.dart:245`
  Covers deterministic Check/Call invariants across a two-step hand loop with explicit continue between states.

## If Playtest Perceives Breakage
- Confirm the build includes the latest `main` after `world1_core_loop_telemetry_contract_test.dart` contract updates.
- Confirm the tested flow is the World1 runner path, not a legacy or non-campaign surface.
- Confirm the tester intentionally chooses a wrong action; the incorrect path is not expected on the correct action.
- Confirm the tester waits for the outcome surface before expecting the next state; progression is continue-gated.
- Confirm the exact scenario when reporting a missing `CALL` or `CHECK`; legality depends on `toCall` for that step.
- Confirm any cached local state is cleared if behavior does not match the contract path.

## Closeout
- Runner correctness for these issues is DONE.
- Future work for the runner should target perceived quality and premium feel, not re-opening these correctness guarantees unless a contract regression is reproduced.
