# Achievement Seed Consumer Admission v1

## 1. Verdict

achievement_seed_read_only_ui_ready

## 2. Accepted projection consumed

The accepted projection from `d57632f06c76d706835b2ae7bb0557a176c63500` is
consumed through `Act0AchievementSeedProjectionV1`.

The new adapter reads only projection rows. It does not synthesize earned
moments from Profile counters, Review history, repair intents, route state,
progression state, telemetry, or UI display state.

## 3. Consumer/adapter owner map

Adapter:

- `lib/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart`

Projection source:

- `lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart`

Profile rendering hook:

- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`

Act0 shell wiring:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

Focused tests:

- `test/ui_v2/act0_achievement_seed_consumer_v1_test.dart`

## 4. No-render behavior

`Act0AchievementSeedConsumerV1` returns an empty `moments` list when no earned
projection rows are eligible for display.

`Act0ProfileShellV1` renders no `act0_shell_profile_earned_moments` block when
the consumer has no moments. There is no placeholder, inventory, coming-soon
state, CTA, or detail screen.

## 5. Earned moments UI scope

Profile now has an optional compact read-only block:

- title: `Earned moments`
- subtitle: `Small wins Sharky can prove.`
- max rendered items: `3`
- format: compact chips inside the existing Profile stack

The block renders only when earned source-backed moments exist. It has no
buttons, animation, confetti, reward currency, XP behavior, navigation, or
interaction beyond normal scrolling.

The pre-existing Profile achievement state/card remains unchanged and was not
rewired in this PR.

## 6. Trigger copy map

| Seed id | Rendered label |
| --- | --- |
| `first_correct_read_v1` | `First correct read` |
| `first_repair_note_v1` | `First repair note` |
| `first_review_history_item_v1` | `First review note` |
| `first_evidence_signal_v1` | `First evidence signal` |
| `first_session_complete_v1` | `First session complete` |
| `three_day_streak_v1` | `3-day streak` |

Ordering is deterministic. Earned sequence is preferred when present; otherwise
contract order is used.

## 7. Blocked/unearned trigger proof

The consumer filters to:

- `seed.earned == true`
- `seed.state == earned_v1`
- seed id has an allowed safe display label

Blocked triggers remain invisible:

- `first_lesson_complete_v1`
- `first_clean_mini_drill_v1`

Unearned triggers remain invisible, including available seeds with
`not_earned_v1`.

## 8. Forbidden-claim proof

The new earned moments block does not render:

- `mastered`
- `leak fixed`
- `AI detected`
- `GTO`
- `solver`
- `premium`
- `top player`
- clear/fixed/resolved claims
- reward/XP/currency language
- leaderboard/ranking language

The focused consumer test scans the rendered earned-moments block for forbidden
copy families.

## 9. Screenshot proof

Ran because Profile UI was touched:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Local-only generated artifacts:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

Generated screenshot/zipped output remains untracked and must not be committed.

## 10. Tests / validation

Validation run:

- `flutter test test/ui_v2/act0_achievement_seed_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_achievement_seed_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_profile_evidence_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Profile compact progress stack avoids repeated mood-copy sections'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Profile ties identity, current focus, and progress into one compressed story'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Profile earned achievement unlocks after first task and streak stat appears'`

- `graphify hook-check`;
- `flutter analyze`;
- `dart format --set-exit-if-changed` on touched Dart/test files only;
- `git diff --check`;
- `git status --short`.

`git status --short` shows only intended source/test/review changes plus
generated output directories under `output/`, which remain untracked.

## 11. Next recommended PR

Achievement Seed Screenshot Capture v1 — Local Only.

Recommended scope:

- add a deterministic Profile capture fixture if future review packets need the
  earned-moments block visible on demand;
- keep achievement detail screens, reward animation, XP/economy, telemetry,
  route/progression, and blocked trigger activation out of scope.
