# Achievement Seed Projection v1

## 1. Verdict

achievement_seed_projection_data_only_ready

## 2. Achievement contract implemented

Implemented a bounded data-only projection for the achievement seed contract
from `docs/_reviews/profile_evidence_capture_achievement_seed_contract_v1.md`.

The projection covers the six available fact-based seeds:

- `first_correct_read_v1`
- `first_repair_note_v1`
- `first_review_history_item_v1`
- `first_evidence_signal_v1`
- `first_session_complete_v1`
- `three_day_streak_v1`

The two blocked seeds are represented only as blocked metadata:

- `first_lesson_complete_v1`
- `first_clean_mini_drill_v1`

No achievement UI, badge strip, animation, reward surface, XP/economy behavior,
telemetry, route state, progression state, or persistence path was added.

## 3. Projection owner/model

Owner:

- `lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart`

Models:

- `Act0AchievementSeedProjectionV1`
- `Act0AchievementSeedV1`

Seed fields:

- stable `id`
- internal title
- `sourceOwner`
- `state`
- `earned`
- optional `earnedSequence`
- safe `sourceSummary`
- `eligibilityState`

Allowed projection states:

- `earned_v1`
- `not_earned_v1`
- `blocked_missing_source_v1`
- `deferred_v1`

## 4. Trigger source map

| Seed | Source owner | Earned rule |
| --- | --- | --- |
| `first_correct_read_v1` | `Act0LearningEvidenceHistoryV1` | At least one completed decision record with `isCorrect == true`. |
| `first_repair_note_v1` | `Act0RepairIntentV1` and `Act0ReviewMistakeHistoryV1` | At least one active repair intent or one unresolved mistake history record. |
| `first_review_history_item_v1` | `Act0ReviewMistakeHistoryV1` | At least one persisted unresolved mistake history record. |
| `first_evidence_signal_v1` | `Act0ProfileEvidenceProjectionV1` | At least one profile evidence signal with `eligible_signal_v1`. |
| `first_session_complete_v1` | `Act0LearningEvidenceHistoryV1.latestRunSummary()` | A grouped current-run summary exists with `currentSessionOnly == true` and `spotsPlayed > 0`. |
| `three_day_streak_v1` | `Act0ProfileStateV1.streakDays` | Owned streak count is at least `3`. |

## 5. Earned-state rules

Available seeds default to `not_earned_v1`.

When their exact source proof exists, they become:

- `state: earned_v1`
- `earned: true`
- `eligibilityState: earned_v1`

The projection uses deterministic contract order, not score ranking or UI order.
Source summaries contain only counts, source ids, run identity, or source order
values that already exist in admitted owners.

## 6. Blocked/deferred trigger rules

`first_lesson_complete_v1` stays `blocked_missing_source_v1` because this PR did
not admit a durable lesson-completion proof owner.

`first_clean_mini_drill_v1` stays `blocked_missing_source_v1` because this PR
did not admit an all-correct practice-run proof owner.

No blocked trigger is inferred from route labels, shell copy, profile counters,
practice UI, or lesson display state.

## 7. Forbidden-claim proof

The projection does not introduce claims for:

- mastered skill;
- leak repair;
- AI-found insight;
- GTO or solver approval;
- top-player status;
- premium value;
- rank or leaderboard state;
- reward, badge, or unlocked runtime UI;
- fixed/cleared Review state.

The focused projection test scans both payload text and the projection source
for the forbidden claim/reward vocabulary admitted by this wave.

## 8. Consumer admission status

No consumer was added in this PR.

The projection is ready for a later consumer-admission decision, but no Profile,
Session Summary, Review, Practice, Home, Learn, route, progression, telemetry,
or screenshot capture surface was changed.

## 9. Tests / validation

Focused test added:

- `test/ui_v2/act0_achievement_seed_projection_v1_test.dart`

Coverage:

- empty sources earn no available seeds;
- correct completed decision earns `first_correct_read_v1`;
- repair intent or unresolved mistake source earns `first_repair_note_v1`;
- unresolved history earns `first_review_history_item_v1`;
- eligible profile evidence earns `first_evidence_signal_v1`;
- session complete requires explicit grouped current-run summary evidence;
- streak requires owned count `>= 3`;
- blocked lesson/drill triggers remain blocked and unearned;
- forbidden claim/reward vocabulary is absent from payload/source;
- seed ordering is deterministic.

Validation run:

- `flutter test test/ui_v2/act0_achievement_seed_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_learning_evidence_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_review_mistake_history_v1_test.dart`
- `flutter test test/ui_v2/act0_profile_evidence_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart`
- `graphify hook-check`
- `flutter analyze`
- `dart format --set-exit-if-changed lib/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart test/ui_v2/act0_achievement_seed_projection_v1_test.dart`

Final hygiene checks before commit:

- `git diff --check`
- `git status --short`

## 10. Next recommended PR

Achievement Seed Consumer Admission v1 — Local Only.

Recommended scope:

- decide whether the data projection should feed Profile, Session Summary, or
  remain data-only longer;
- if admitted, add a compact non-reward consumer contract before rendering UI;
- keep route/progression/telemetry and economy untouched unless explicitly
  reopened.
