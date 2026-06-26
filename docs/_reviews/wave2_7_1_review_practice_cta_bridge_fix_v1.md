# Wave 2.7.1 - Review Practice CTA Bridge Fix v1

## 1. Verdict

wave2_7_1_review_practice_cta_bridge_fix_ready

## 2. Claude P1 source summary

Claude's Wave 2.7 review flagged one P1 blocker on the Review active-repair state: after the hero and `What to fix next` coaching card, the lower half of the screen felt empty and did not give the learner an obvious next action. The fix target was a small CTA bridge from the Review repair coaching card to the already-existing practice repair path.

## 3. Wave goal and scope

Goal: add a visible, compact `Practice this spot` action directly under the existing active-repair coaching card when Review has an active repair target.

Scope held to Review presentation and existing launch callback wiring. No broad shell redesign, new Review history, queue resolution, route family, telemetry, or progression model was introduced.

## 4. Files changed

- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `test/ui_v2/act0_review_shell_v1_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/wave2_7_1_review_practice_cta_bridge_fix_v1.md`

## 5. Implementation summary

`_ReviewRepairCoachCardV1` now renders a compact `FilledButton` with copy `Practice this spot` when the existing `onFixMistake` launch callback is present. The CTA sits directly below the existing `Keep this clue in view before your next hand.` support line, preserving the accepted Review hierarchy while closing the empty handoff gap.

The CTA invokes `onFixMistake(mistake)`, which keeps ownership with the existing Act0 active repair path. The shell preview route continues to launch through the existing mistake-repair flow and lands in the repair runner state.

## 6. Route/boundary proof

- No route family was added.
- No progression state was mutated by the CTA.
- No model or durable evidence contract changed.
- No telemetry call site was added.
- No queue item is removed, cleared, resolved, or completed by the CTA.
- Review history remains read-only where it already existed.
- The CTA is hidden when Review is rendered without an active repair launch callback.

## 7. Claim-safety proof

The added copy is limited to `Practice this spot`. Focused tests assert absence of forbidden claim families around the new active-repair CTA, including fixed/cleared/resolved language, AI, GTO, solver, premium, level, radar, rating, mastery, and all-time claims.

## 8. Tests and validation run

- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Debug Day 2 proof surfaces expose open repair return story|Debug capture review entry keeps active repair as compact context|Debug capture review Practice CTA launches existing repair task"`
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_review_shell_v1.dart test/ui_v2/act0_review_shell_v1_test.dart test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

## 9. Screenshot proof run and result

- `./tools/screen_review_fast_v1.sh day2_return compact`
  - Result: passed.
  - Local packet: `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - Local zip: `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `./tools/screen_review_fast_v1.sh first_week compact`
  - Result: passed.
  - Local packet: `output/screen_review/current/first_week_fast/contact_sheet.png`
  - Local zip: `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

`full_scroll` was not run because the change was a narrow Review-shell CTA bridge, not a broad shell layout change.

## 10. Generated/untracked artifact status

Generated screenshot output remains local-only under `output/screen_review/current/`. Generated review output under `output/claude_review/` also remains untracked. No generated screenshots, zips, or output directories are part of the commit.

## 11. Expected TOP1 matrix movement

- Review coaching depth: modest lift from a clearer active-repair handoff.
- First proof loop: modest lift because Review now visibly bridges into the existing repair rep.
- Visual premium feel: small lift from reducing the empty lower-half impression in the active Review state.
- Route-truth safety: unchanged, because the CTA uses existing active repair launch ownership.

## 12. Caveats

This does not add Review history, fixed/cleared state, durable mistake resolution, or a broader repair backlog. It only makes the currently active Review repair handoff actionable.

## 13. Next recommendation

Run a small post-fix visual recheck against the Wave 2.7 Claude packet before opening the next product slice. If no new P1 appears, the safest next implementation family is still data-backed repair payoff and evidence surfacing rather than broader shell redesign.
