# World-Completion Retention Return-Copy Contract v1

## 1. Current broad status

The broad Act0 shell preview gate is green after this wave.

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`
- Final result: pass, `+656`

## 2. Failure inventory

Starting blocker:

- `World completion seeds compact recheck targets and Home surfaces the return reason`
- First failing assertion: expected two widgets with `Still yours? Run this spot once more.`
- Actual result before repair: zero widgets with that old copy.

Classification:

- stale copy contract, not missing retention state.

## 3. Current completion/return state evidence

The test completes the current world path, reaches the block summary, opens Review, then returns Home.

Evidence found in code:

- World completion already seeds compact retention/recheck targets through retention memory.
- Review receives aged-recheck cards from `_retentionReviewCardForTaskV1`.
- Home receives a recheck job and surfaces the learner-facing `Check confidence` row without exposing internal `retentionSequence` or `agedRecheck`.
- The old phrase `Still yours? Run this spot once more.` was still present as an aged-recheck quality line, but Review also treated it as anxious old copy in `_recoveredDetailLineV1`.
- Existing Home recheck contracts still use the target title as the row detail; changing that globally created unrelated broad failures and was not kept.

## 4. Decision selected: B

Retention return behavior is still product truth, but the old copy is stale.

## 5. Rationale

The product behavior is correct: completed-world state can seed recheck targets, Review can show those targets, and Home can continue to surface a return path through `Check confidence`.

The old wording is not the current product tone. `Run this spot once more` reads more imperative and was already treated as anxious copy by Review. The current accepted return-copy model is the calmer phrase:

- `Still yours? One calm replay keeps it honest.`

This preserves the retention payoff without restoring old copy blindly and without broadening Home checklist semantics.

## 6. Changes applied

- Updated aged-recheck retention review card copy to `Still yours? One calm replay keeps it honest.`
- Updated the world-completion retention broad test to assert the current calmer copy.
- Preserved existing Home recheck row detail behavior after broad tests proved a global Home detail change would break unrelated contracts.

## 7. Tests updated, if any

Updated:

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - `World completion seeds compact recheck targets and Home surfaces the return reason`

The test still verifies:

- Review shows the seeded compact recheck targets.
- Home shows the daily plan card.
- Home shows `Check confidence`.
- Internal retention fields are not exposed.

## 8. Final broad status

Command:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --reporter expanded`

Result:

- Passed, `+656`

## 9. Fast-loop status

Command:

- `./tools/fast_loop_world1_v1.sh`

Result:

- Passed, `+679`
- Output ended with `FAST LOOP PASS`.

## 10. Remaining blockers, if any

None for this wave.

The Act0 broad preview gate and fast loop are green in the verified local run.
