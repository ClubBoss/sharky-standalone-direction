# Session Summary Earned Moment v1

## 1. Verdict

session_summary_earned_moment_read_only_ready

## 2. Accepted achievement source consumed

Session Summary now consumes the accepted achievement source through
`Act0AchievementSeedConsumerV1`, which itself reads only
`Act0AchievementSeedProjectionV1`.

The Session Summary surface does not synthesize earned moments from local UI
state, current-run copy, XP, route state, progression state, Review history, or
repair intent owners directly.

## 3. Session Summary owner map

Session Summary owner:

- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`

Act0 wiring:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

Accepted achievement source:

- `lib/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart`
- `lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart`

Focused test:

- `test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`

## 4. No-render behavior

`Act0BlockCompletionShellV1` accepts an optional
`earnedMomentConsumer`, defaulting to an empty
`Act0AchievementSeedConsumerV1`.

When the consumer has no moments, no
`act0_shell_block_summary_earned_moment` block renders. Existing Session Summary
milestone, evidence, next-step, accuracy, XP, and CTA content stays materially
unchanged.

## 5. Earned moment UI scope

When an earned seed exists, Session Summary renders exactly one compact
read-only card:

- label: `Earned moment`
- seed label: the first safe label from `Act0AchievementSeedConsumerV1`
- proof line: `Small win Sharky can prove.`

The card has no button, no detail screen, no animation, no confetti, no badge
inventory, no XP/economy behavior, and no reward currency.

Profile remains the only surface that can show up to three earned moments. The
Session Summary V1 surface shows at most one.

## 6. Copy/trigger safety

Allowed rendered labels are inherited from `Act0AchievementSeedConsumerV1`:

- `First correct read`
- `First repair note`
- `First review note`
- `First evidence signal`
- `First session complete`
- `3-day streak`

Blocked and unearned seeds are filtered by the accepted consumer and do not
reach the Session Summary card.

Forbidden labels remain absent:

- `Clean mini-drill`
- `Lesson complete`

## 7. Forbidden-claim proof

The focused Session Summary test checks the rendered earned-moment block for
forbidden copy families:

- achievement-unlocked ceremony copy;
- mastered/mastery claims;
- leak-fixed claims;
- AI/GTO/solver claims;
- premium/top-player/leaderboard claims;
- clean mini-drill or lesson-complete labels;
- resolved/fixed reward claims;
- XP/reward language inside the earned-moment card.

No route/progression, telemetry, Modern Table, premium/paywall, XP/economy, or
animation changes were added.

## 8. Screenshot proof

Ran because Session Summary UI was touched:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Local-only generated artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated screenshot/zipped output remains untracked and must not be committed.

## 9. Tests / validation

Validation run:

- `flutter test test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `flutter test test/ui_v2/act0_achievement_seed_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_achievement_seed_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Block summary renders current-run evidence summary lines'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Block summary hides evidence summary when evidence is empty'`

- `graphify hook-check`
- `flutter analyze`
- `dart format --set-exit-if-changed` on touched Dart/test files only
- `git diff --check`
- `git status --short`

`git status --short` shows only intended source/test/review changes plus
generated output directories under `output/`, which remain untracked.

## 10. Next recommended PR

Achievement Seed Screenshot Capture v1 — Local Only, only if future review
packets need a deterministic capture state where the Session Summary earned
moment is guaranteed visible.

Keep badge inventory, detail screens, reward animation, XP/economy,
route/progression changes, telemetry changes, and blocked trigger activation out
of scope.
