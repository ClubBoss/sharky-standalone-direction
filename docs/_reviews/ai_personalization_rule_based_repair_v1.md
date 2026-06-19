# AI Personalization / Rule-Based Repair Layer v1

Date: 2026-06-19
Branch: `codex/ai-personalization-rule-based-repair-v1`
Mode: bounded deterministic product scope

## 1. Branch and Base Commit

Started from `main` after PR #5 merge. Base observed before branch creation:
`ef86825`.

## 2. Product Goal

Add the smallest real deterministic personalization layer that can translate an
open Act0 missed-choice repair intent into one auditable repair decision:

- what clue was missed;
- which task repairs it;
- which stable rule selected that task;
- whether the repair should be next or first due to repeat pressure.

This is not AI, ML, solver, GTO, analytics-dashboard, paywall, trial, commerce,
Premium Hub, or public copy work.

## 3. Existing Seams Used

The implementation uses the existing Act0 repair-intent contract:

- `Act0RepairIntentV1`
- `buildAct0RepairIntentV1(...)`
- open/closed lifecycle in `Act0ShellPreviewScreenV1`
- resolver selection sources:
  - `repair_intent_mapped`
  - `repair_intent_exact_replay`
  - `existing_fallback`

The new builder does not own:

- mistake storage;
- repair queue lifecycle;
- review rendering;
- telemetry emission;
- route progression;
- content mapping.

## 4. Contracts Added / Changed

Added:

- `Act0RuleBasedRepairDecisionV1`
- `buildAct0RuleBasedRepairDecisionV1(...)`

Contract fields:

- `schemaVersion`
- `recommendationSource`
- `actionType`
- `selectionSource`
- `decisionRule`
- `priorityBand`
- `priorityScore`
- source world / lesson / task ids
- `choiceId`
- `result`
- `errorType`
- `missedSignalId`
- `skillAtomId`
- target world / lesson / task ids
- `mappingType`
- `reasonCode`

No existing product, UI, content, route, telemetry, monetization, entitlement,
or copy contract was changed.

## 5. Telemetry Verification

Existing local telemetry remains the observer seam, not the owner of
personalization state.

Observed current facts:

- `task_result` already carries `choiceId`, `result`, `errorType`, feedback
  signal, and skill receipt fields when available.
- `feedback_viewed`, `repair_started`, `repair_completed`, and repair item
  events remain local-only through `Act0TelemetrySinkV1`.
- `ACT0_TELEMETRY_TRUTH_MAP_v1.md` still documents `user_choice` and
  `decisionTimeBucket` / `time_to_decision` as future event contract work.

This wave intentionally does not add network telemetry, analytics ownership,
timing instrumentation, or a new event payload.

## 6. Determinism Guarantees

The builder is pure:

- no time;
- no RNG;
- no persistence;
- no network;
- no global state;
- no route mutation.

Decision rules:

- no open intent -> no decision;
- closed intent -> no decision;
- correct result -> no decision;
- `mappingType == exact` -> `exact_replay` via
  `exact_replay_fallback_v1`;
- other open repair intents -> `same_signal_repair` via
  `same_signal_repair_v1`;
- repeat pressure increases priority score by a bounded deterministic step.

Priority scoring:

- mapped repair base: `80`;
- exact replay base: `70`;
- repeat boost: `+5` per extra miss, capped after three extra misses;
- `priorityScore >= 85` -> `repair_first`;
- otherwise -> `repair_next`.

## 7. Files Changed

- `lib/ui_v2/act0_shell/act0_rule_based_repair_personalization_v1.dart`
- `test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart`
- `docs/_reviews/ai_personalization_rule_based_repair_v1.md`

## 8. What Intentionally Not Done

- No Act0 UI or copy changes.
- No Home / Practice / Review route behavior change.
- No telemetry expansion.
- No public AI/adaptive/ML claims.
- No solver/GTO/optimal/win-rate claims.
- No monetization, entitlement, trial, paywall, pricing, purchase, restore, or
  Premium Hub work.
- No generated outputs.
- No workflow changes.
- No `external_competitors/` changes.

## 9. Risk Assessment

Risk: low.

Reason:

- The new layer is pure and unreferenced by runtime UI.
- Existing repair intent, lifecycle, resolver, copy guard, and telemetry tests
  remain the behavioral protection.
- The new payload deliberately excludes forbidden AI/ML/commerce/premium fields.

Remaining risk:

- This v1 does not yet prove runtime consumption by Home, Practice, or Review.
  Existing resolver behavior already performs target selection, so runtime
  consumption should be admitted as a separate narrow wave if needed.

## 10. Checks Run

Initial TDD proof:

- `flutter test test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart`
  failed before implementation because the helper did not exist.

Post-implementation at artifact creation time:

- `dart format lib/ui_v2/act0_shell/act0_rule_based_repair_personalization_v1.dart test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart`
- `flutter test test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart`

Final verification:

- `flutter test test/ui_v2/act0_rule_based_repair_personalization_v1_test.dart test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_repair_intent_resolver_v1_test.dart test/ui_v2/act0_repair_intent_copy_guard_v1_test.dart`
  - passed, `+33`
- `flutter analyze`
  - passed
- `git diff --check`
  - passed
- `./tools/fast_loop_world1_v1.sh`
  - passed, `FAST LOOP PASS`
- `./tools/release_gate_world1.sh`
  - passed, `World1 release gate passed`

Known non-fatal test-suite warning:

- The broad Act0 preview suite emitted the existing Flutter tap hit-test warning
  during release gate execution, but all selected tests passed.

## 11. PR Readiness Verdict

Ready for verification.

If gates pass, this is a clean small PR: one pure deterministic contract, one
focused test file, and one review artifact.

## 12. Follow-Up Recommendation

Next exact wave:

`Act0 Rule-Based Repair Decision Runtime Consumption v1`

Scope:

- consume `Act0RuleBasedRepairDecisionV1` at the existing next-useful-hand
  reason receipt seam;
- do not change public copy;
- prove mapped/exact decisions preserve existing resolver behavior;
- keep telemetry as observer only unless a separate telemetry contract wave is
  admitted.
