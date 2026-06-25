# Profile Evidence Consumer Admission v1

## 1. Verdict

profile_evidence_read_only_ui_ready

## 2. Accepted projection consumed

This slice admits a Profile-only read-only consumer for the accepted
`Act0ProfileEvidenceProjectionV1`.

Accepted source:

- `Act0ProfileEvidenceProjectionV1`
- `Act0ProfileCapabilitySignalV1`
- `eligible_signal_v1` only

Not consumed:

- `Act0ReviewMistakeHistoryV1`
- `Act0RepairIntentV1`
- unresolved mistake rows
- activity counters as capability proof

## 3. Profile consumer/adapter owner map

Consumer/adapter owner:

- `lib/ui_v2/act0_shell/act0_profile_evidence_consumer_v1.dart`

Profile UI owner:

- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`

Runtime handoff:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart` builds
  `Act0ProfileEvidenceProjectionV1.fromLearningEvidenceHistory(...)` from the
  existing `_learningEvidenceHistoryV1`.
- The shell then passes only the optional
  `Act0ProfileEvidenceSignalViewModelV1` into `Act0ProfileShellV1`.

No route, progression, telemetry, Review, Home, Learn, or Practice ownership
changed.

## 4. Eligibility/no-render behavior

The consumer renders nothing unless it finds an eligible projection signal:

- `insufficient_sample_v1`: no Profile block.
- `needs_more_practice_v1`: no Profile block in this PR.
- `eligible_signal_v1`: may render one read-only Profile evidence signal.

If multiple eligible rows exist, the consumer uses projection order and picks
the first eligible signal. This is documented as deterministic first, not best,
strongest, weakest, or ranked.

If the eligible signal has no learner-safe skill label, the consumer renders
nothing.

## 5. Evidence signal UI scope

The admitted Profile UI is a compact read-only card with:

- header: `Evidence signal`
- body: `You are building this skill.`
- proof line: `X/Y correct in [learner-safe skill label]`

The card has no button, CTA, badge, achievement, reward, repair action, route
action, or progression mutation. It is inserted after the existing Profile
progress proof card and before existing skill/badge sections.

Current screen-review capture states did not show the card because those local
packets do not expose an eligible profile evidence signal. The no-render state
is therefore screenshot-proven, while the eligible-card render is covered by
focused widget tests.

## 6. Skill label safety

The consumer maps only known learner-safe skill atom ids:

- `action_read` -> `Action reading`
- `position_read` -> `Position reading`
- `table_position_read` -> `Position reading`
- `board_read` -> `Board reading`
- `price_read` -> `Price reading`
- `table_read` -> `Table reading`
- `starting_hand_read` -> `Starting hand reading`

Unknown skill atom ids do not render in Profile. This prevents raw internal
skill ids from becoming learner-facing copy.

## 7. No-ranking proof

The adapter does not sort by accuracy, attempt count, correct count, recency,
strength, or weakness. It consumes the projection's deterministic order and
labels the result only as an evidence signal.

Forbidden ranking language is not used:

- no `strongest skill`
- no `weakest skill`
- no `best`
- no ranking claim

## 8. Forbidden-claim proof

The admitted consumer/card does not add:

- mastery
- leak
- AI detected
- GTO
- solver
- premium/paywall/trial
- badge
- achievement
- reward/dopamine UI
- strongest/weakest/ranking
- `based on your last N decisions/hands`

Counts are displayed only as factual projection-owned `X/Y correct`.

## 9. Screenshot proof

Ran:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Generated artifacts remain local-only:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/full_scroll_fast/`

Inspection:

- First-week Profile return showed no new evidence card, matching no eligible
  signal in that capture state.
- Day-2 Profile active repair proof showed no new evidence card, preserving
  the current active repair Profile state.
- Full-scroll Profile showed the existing Profile top/middle/bottom structure
  without a new evidence card, matching no eligible signal in that capture
  state.

## 10. Tests / validation

Passed focused tests:

- `flutter test test/ui_v2/act0_profile_evidence_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_profile_evidence_consumer_v1_test.dart`

Passed affected Profile shell tests:

- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Profile shows compact progress header and encouraging completion line'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Profile identity and focus prefer wrapped density over hard truncation'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Profile first-start tools move behind a compact utility entry'`

Passed validation:

- `dart format --set-exit-if-changed` on touched Dart/test files
- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short` showed only touched source/test/review files plus
  generated local output directories before staging.

## 11. Next recommended PR

Profile Evidence Capture State v1 — Screenshot Fixture Only

Reason:

The current screen-review packet proves the no-render state but does not expose
an eligible Profile evidence signal. A small capture-state-only follow-up could
add an eligible evidence Profile fixture for visual proof without changing
product behavior.
