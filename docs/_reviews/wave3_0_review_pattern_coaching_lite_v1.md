# Wave 3.0 - Review Pattern Coaching Lite v1

## 1. Verdict

wave3_0_review_pattern_coaching_lite_ready

## 2. TOP1 matrix row target

- Primary: Review coaching depth.
- Secondary: Practice usefulness, habit loop / return reason, first proof loop, Review/Profile trust.

## 3. Wave goal and scope

Goal: make the existing Act0 Review repair area feel more like a helpful coach by adding one compact local pattern/focus signal where existing active-repair evidence supports it.

Scope stayed inside the Review handoff/repair surface. This wave did not create analytics, all-time history, ratings, radar, levels, Review resolution, queue mutation, a new route family, telemetry, or a durable evidence model.

## 4. Files changed

- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `test/ui_v2/act0_review_shell_v1_test.dart`
- `docs/_reviews/wave3_0_review_pattern_coaching_lite_v1.md`

## 5. Existing Review evidence audit

Review already receives the current active repair through `Act0ReviewStateV1.mistakes`. The active repair card uses `review.mistakes.first` as the single current repair item and already renders:

- the guarded clue line from `act0ReviewRepairCoachCopyGuardLinesV1`;
- the local repair action or reason;
- the compact Sharky Review coach line;
- the existing `Practice this spot` CTA when `onFixMistake` is present.

Review also has read-only mistake history and session-drill recheck queue seams, but those were not used to infer a broader pattern. History remains secondary proof and queue state remains separate.

## 6. Pattern coaching implemented or admitted as blocked if evidence is insufficient

Implemented one compact section inside `_ReviewRepairCoachCardV1`:

- `Pattern to practice`
- `You are working on <active repair title>.`
- `Next rep: spot the clue before choosing.`

The section appears only when the current active repair has a non-empty title. No grouped pattern card, all-time detector, leak diagnosis, count, or trend was added.

## 7. Evidence source for the pattern coaching

The evidence source is the existing active repair item already selected by Review:

- `Act0ReviewStateV1.mistakes.first`
- `Act0MistakeCardV1.title`

The title is treated as a local current focus label. It is not treated as all-time proof, a durable diagnosis, or a recovered/resolved state.

## 8. Why the coaching supports Review usefulness rather than analytics theater

The new section turns the active repair into a clearer coaching cue: what pattern/focus to keep in mind and how to approach the next rep. It does not add metrics, charts, counts, rankings, or historical inference. The user still sees the same repair path: read the clue, practice the spot, and keep moving.

## 9. Claim-safety proof

Visible copy avoids AI, GTO, solver, mastery, permanent fix, cleared, resolved, recovered, all-time analytics, rating, radar, level, premium/paywall, guaranteed improvement, win-rate, and broad leak claims.

The active repair title is locally guarded before display. If it contains unsafe claim-family terms, the coaching line falls back to `this table clue`.

## 10. No route/progression/model/telemetry boundary proof

No route, progression, telemetry, queue, repair outcome, or data model files were changed. The implementation only reads the already-rendered active repair card input and adds local presentation copy.

## 11. Review CTA bridge preservation proof

The existing `Practice this spot` CTA remains in `_ReviewRepairCoachCardV1`, uses the same key `act0_shell_review_practice_cta`, and still calls `onFixMistake!(mistake)`.

Focused preview route coverage passed for:

- `Debug capture review entry keeps active repair as compact context`
- `Debug capture review Practice CTA launches existing repair task`

## 12. Sharky Soul preservation proof if touched

The Sharky phrase source was not changed. The existing compact Review Sharky line remains in the active repair card through `Act0SharkyCoachMomentV1.reviewActiveRepair`.

`flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart` passed.

## 13. Earned Rewards preservation proof if touched

Earned Rewards code and copy were not touched. No reward hook, badge, XP, achievement, or Session Summary expansion was added.

## 14. Tests and validation run

Passed:

- `flutter test test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "Debug capture review entry keeps active repair as compact context|Debug capture review Practice CTA launches existing repair task"`
- `flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_review_shell_v1.dart test/ui_v2/act0_review_shell_v1_test.dart`
- `flutter analyze`
- `graphify hook-check`
- `git diff --check`
- `git diff --cached --check`
- `git status --short`

## 15. Screenshot proof run and result

Passed:

- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh first_week compact`

Observed local packets:

- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

The contact sheets show the Review repair continuation / handoff with the new compact `Pattern to practice` cue and the unchanged `Practice this spot` CTA.

## 16. Generated/untracked artifact status

Generated screenshot outputs remain local-only and untracked under:

- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/first_week_fast/`

Pre-existing untracked generated output also remains uncommitted under `output/claude_review/`.

## 17. Expected TOP1 matrix movement

- Review coaching depth: moves up modestly because Review now explains the current repair focus as a coaching cue instead of only an item-level note.
- Practice usefulness: improves indirectly because the cue frames what to notice before pressing `Practice this spot`.
- Habit loop / return reason: improves lightly because the next rep has a clearer reason to exist.
- First proof loop: improves lightly because the mistake -> repair -> Review handoff feels more coherent.
- Review/Profile trust: Review trust improves through local evidence-safe copy; Profile trust is unchanged because Profile was not touched.

## 18. Caveats

This is not durable pattern intelligence. It does not count repeated misses, cluster history, clear repairs, or prove a repaired weakness. The current implementation intentionally treats the active repair title as a local focus only.

## 19. Next recommendation

The safest next prompt is a bounded Review evidence contract selection: decide whether repeated local repair evidence should become a small durable Review pattern contract, or whether the next TOP1 move should target Practice rep selection using already-proven active repair state.
