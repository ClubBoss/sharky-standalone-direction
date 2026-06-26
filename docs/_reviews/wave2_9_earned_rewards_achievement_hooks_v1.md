# Wave 2.9 - Earned Rewards / Achievement Hooks v1

## 1. Verdict

wave2_9_earned_rewards_achievement_hooks_ready

## 2. TOP1 matrix row target

Primary row:

- rewards / achievements

Secondary rows:

- habit loop / return reason
- Session Summary payoff
- Profile identity and proof
- first proof loop

## 3. Wave goal and scope

Goal: make one existing earned proof moment feel more like a premium reward receipt without introducing badge art, RPG systems, levels, ratings, radar, profile economy, broad achievements, or fake mastery.

Scope stayed inside the existing Session Summary earned-moment presentation. No achievement projection, consumer, Profile, Review, route, progression, telemetry, or model contract changed.

## 4. Files changed

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `docs/_reviews/wave2_9_earned_rewards_achievement_hooks_v1.md`

## 5. Existing earned moment / achievement seam audit

Existing source seams:

- `Act0AchievementSeedProjectionV1` owns source-backed achievement seed state.
- Earned seeds currently come from:
  - first correct read in `Act0LearningEvidenceHistoryV1`;
  - first repair note from repair intent or Review mistake history;
  - first Review history item;
  - first eligible Profile evidence signal;
  - first current-session completion summary;
  - three-day rhythm from Profile streak days.
- Deferred / blocked states remain present for future sources:
  - first lesson complete;
  - first clean mini drill.

Existing consumer seam:

- `Act0AchievementSeedConsumerV1` reads only the projection.
- It filters to earned seeds, uses safe labels, sorts deterministically, and caps visible moments at three.

Existing presentation seams:

- Session Summary renders one earned moment card when `earnedMomentConsumer.moments.first` exists.
- Profile renders compact earned moments under `Small wins Sharky can prove.` when a consumer is provided.

Safe existing moments:

- `First correct read`
- `Back to the spot`
- `One miss to fix`
- `First evidence signal`
- `First session complete`
- `Three-day rhythm`

Deferred states must remain deferred because their proof sources are not active enough for a learner-facing reward hook.

## 6. Reward hook implemented

The Session Summary earned-moment card now reads as a compact proof receipt:

- Label changed from `Earned moment` to `Proof banked`.
- Support line changed from `Small win Sharky can prove.` to `Small win earned from local proof.`

The moment label itself remains source-owned by `Act0AchievementSeedConsumerV1`.

## 7. Evidence source for the reward hook

The hook appears only when `Act0BlockCompletionShellV1` receives a non-empty `Act0AchievementSeedConsumerV1`, which only exposes earned view models from `Act0AchievementSeedProjectionV1`.

The card does not compute reward state locally. It consumes the existing earned moment view model and renders the first eligible source-backed moment.

## 8. Why the reward supports proof/payoff rather than decoration

The hook stays tied to a concrete earned moment in the Summary close. `Proof banked` makes the moment feel earned and memorable, while `Small win earned from local proof.` keeps the claim local, deterministic, and bounded to evidence already available in the run.

No new icon system, badge art, gallery, inventory, celebration, XP economy, or reward state was introduced.

## 9. Claim-safety proof

The new copy avoids:

- AI;
- GTO;
- solver;
- mastery;
- permanent leak fix;
- fixed forever;
- cleared;
- resolved;
- recovered;
- all-time analytics;
- rating;
- radar;
- Level / Lv as proof;
- premium/paywall value;
- guaranteed improvement;
- win-rate improvement.

Focused tests keep the earned moment forbidden-copy guard green.

## 10. No route/progression/model/telemetry boundary proof

No changes were made to:

- routes or navigation;
- progression;
- telemetry;
- data models;
- achievement seed projection;
- achievement seed consumer;
- repair queue resolution or removal;
- Review clearing;
- durable all-time counts;
- Modern Table;
- AI/chat/persona;
- premium/paywall.

This is evidence-backed presentation copy only.

## 11. Sharky Soul preservation proof if touched

Wave 2.8 source was not modified. The preservation check passed:

- `flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`

## 12. Review CTA bridge preservation proof if touched

Review source was not modified. The preservation check passed:

- `flutter test test/ui_v2/act0_review_shell_v1_test.dart --name "Review keeps one compact active repair note without a Home redirect|Review practice CTA uses existing active repair callback"`

## 13. Tests and validation run

RED check first failed for missing reward receipt copy:

- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart --name "Session Summary renders exactly one earned moment|Session Summary hides blocked and unearned seeds|Session Summary earned moment contains no forbidden copy"`

GREEN checks:

- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart --name "Session Summary renders exactly one earned moment|Session Summary hides blocked and unearned seeds|Session Summary earned moment contains no forbidden copy"`
- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_sharky_coach_phrase_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart --name "Review keeps one compact active repair note without a Home redirect|Review practice CTA uses existing active repair callback"`
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- `git status --short`

## 14. Screenshot proof run and result

- `./tools/screen_review_fast_v1.sh day2_return compact`
  - Result: passed.
  - Local packet: `output/screen_review/current/day2_return_fast/contact_sheet.png`
  - Local zip: `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `./tools/screen_review_fast_v1.sh first_week compact`
  - Result: passed.
  - Local packet: `output/screen_review/current/first_week_fast/contact_sheet.png`
  - Local zip: `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`

`full_scroll compact` was not run because this was a narrow Session Summary reward-copy hook, not a broad shell-level change.

## 15. Generated/untracked artifact status

Generated outputs remain local-only and untracked:

- `output/claude_review/`
- `output/screen_review/`

No generated screenshots, zips, or output directories are included in the commit.

## 16. Expected TOP1 matrix movement

- rewards / achievements: `6.6-7.4` -> `6.9-7.6`
- habit loop / return reason: small lift from making the session close feel more earned.
- Session Summary payoff: small lift from a clearer proof receipt.
- Profile identity and proof: unchanged in UI, but supported by the same earned-moment seam.
- first proof loop: small lift because the earned proof close is clearer and still local.

## 17. Caveats

- This does not add badge art, badge galleries, reward inventory, or a broader achievement taxonomy.
- Profile earned moments were audited but not changed.
- Deferred achievement seeds remain deferred until their proof sources are real.

## 18. Next recommendation

Proceed to Wave 3.0 - Review Pattern Coaching v1 only after confirming the refreshed packets still feel calm and proof-led. Keep the next wave evidence-backed and avoid Review resolution, all-time analytics, ratings, radar, levels, or fake mastery.
