# Profile Evidence Capture + Achievement Seed Contract v1

## 1. Verdict

profile_evidence_capture_and_achievement_contract_ready

## 2. Part A — Profile evidence capture scope

This slice adds a deterministic screenshot/test-only Profile evidence capture
state. It does not add runtime fake evidence, new user state, achievement UI,
badge UI, reward animation, route/progression behavior, telemetry, or economy
changes.

The capture state exists to close visual proof for the already admitted
Profile evidence consumer:

- default Profile states still render no evidence card when no eligible signal
  exists;
- the new capture fixture renders exactly one read-only evidence card when one
  eligible signal exists;
- unknown skill atom labels still render nothing through the consumer.

## 3. Part A — fixture owner map

Capture fixture owner:

- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
  - `Act0ControlledDemoCaptureSurfaceV1.profileEvidence`
  - `_applyDebugProfileEvidenceSurface()`

Direct capture parser owner:

- `lib/ui_v2/app_root.dart`
  - `?act0_capture=profile_evidence`

Screen-review tooling owners:

- `tools/act0_real_text_surface_capture_v1.dart`
- `tools/screen_review_fast_v1.sh`
- `tools/package_screen_review_v1.py`
- `tools/package_screen_review_v1.sh`

The fixture uses the existing runtime handoff:

`Act0LearningEvidenceHistoryV1 -> Act0ProfileEvidenceProjectionV1 -> Act0ProfileEvidenceConsumerV1 -> Act0ProfileShellV1`.

## 4. Part A — evidence fixture details

The fixture is capture/test-only and seeds `_learningEvidenceHistoryV1` with
five `action_read` records:

- 5 attempts;
- 3 correct;
- 2 incorrect;
- `skillAtomId: action_read`;
- learner-safe label: `Action reading`;
- resulting state: `eligible_signal_v1`.

Visible copy remains modest and factual:

- `Evidence signal`
- `You are building this skill.`
- `3/5 correct in Action reading`

The fixture does not imply strongest, best, mastered, rank, leak, AI, GTO,
solver, reward, or premium value.

## 5. Part A — default no-render proof

Default no-render remains unchanged:

- `Act0ProfileEvidenceConsumerV1.fromProjection(...)` returns no signal when
  all rows are `insufficient_sample_v1` or `needs_more_practice_v1`.
- `Act0ProfileShellV1` receives a nullable `evidenceSignal` and renders no
  evidence card when it is null.
- First-week and full-scroll screenshot packets still show no Profile evidence
  card in their default fixture states.

## 6. Part A — evidence render proof

The new capture command:

- `./tools/screen_review_fast_v1.sh profile_evidence compact`

Generated:

- `output/screen_review/current/profile_evidence_fast/contact_sheet.png`
- `output/screen_review/current/profile_evidence_fast/screen_review_profile_evidence_fast.zip`

Visual inspection confirms the evidence card is fully visible and contains:

- `Evidence signal`
- `You are building this skill.`
- `3/5 correct in Action reading`

Focused widget proof:

- `Debug capture profile evidence entry renders one safe evidence card`

## 7. Part B — achievement seed contract

This contract defines achievement/dopamine seeds only. It does not implement
achievement UI, badges, persistence, animations, rewards, XP changes, or
economy behavior.

Principles:

- achievements must be earned from real existing or explicitly admitted events;
- no decorative/fake achievement state;
- no achievement may claim mastery, leak repair, ranking, AI, GTO, solver, or
  premium value;
- blocked triggers stay blocked until a source owner and proof gate are
  admitted.

Allowed seed states:

- `available_contract_v1`
- `blocked_missing_source_v1`
- `deferred_v1`

## 8. Part B — trigger table

| id | title | source owner | proof event | state | Later surface | Forbidden overclaim |
| --- | --- | --- | --- | --- | --- | --- |
| `first_correct_read_v1` | First correct read | `Act0LearningEvidenceHistoryV1` | first completed decision with `isCorrect: true` | `available_contract_v1` | Session Summary, Profile | no mastered/strong read claim |
| `first_repair_note_v1` | First repair note | `Act0RepairIntentV1` | first admitted active repair intent | `available_contract_v1` | Review, Profile | no leak fixed claim |
| `first_review_history_item_v1` | First review history item | `Act0ReviewMistakeHistoryV1` | first persisted unresolved mistake record | `available_contract_v1` | Review, Profile | no resolved/fixed claim |
| `first_evidence_signal_v1` | First evidence signal | `Act0ProfileEvidenceProjectionV1` | first `eligible_signal_v1` | `available_contract_v1` | Profile | no strongest/mastered claim |
| `first_session_complete_v1` | First session complete | current-run/session summary evidence | completed session summary proof | `available_contract_v1` | Session Summary, Profile | no course completion claim |
| `three_day_streak_v1` | Three-day streak | existing Profile streak count | `streakDays >= 3` from owned Profile state | `available_contract_v1` | Profile | no habit locked/permanent claim |
| `first_lesson_complete_v1` | First lesson complete | route/progression completion state | named completed lesson proof | `blocked_missing_source_v1` | Learn, Profile | no world complete claim |
| `first_clean_mini_drill_v1` | First clean mini-drill | practice/session run owner | all-correct mini-drill run | `blocked_missing_source_v1` | Practice, Session Summary | no perfect player claim |

## 9. Part B — source/proof gates

Gate rules:

- `first_correct_read_v1` must read completed-decision evidence only.
- `first_repair_note_v1` must read admitted active repair intent only.
- `first_review_history_item_v1` must read persisted unresolved Review history
  only.
- `first_evidence_signal_v1` must read `eligible_signal_v1` only.
- `first_session_complete_v1` must read an admitted session summary/current-run
  completion proof.
- `three_day_streak_v1` must read an owned Profile streak count, not inferred
  calendar copy.
- `first_lesson_complete_v1` remains blocked until a durable lesson-completion
  owner/proof gate is named.
- `first_clean_mini_drill_v1` remains blocked until an all-correct practice run
  owner/proof gate is named.

No trigger can be shown until its proof event exists in an admitted owner.

## 10. Part B — forbidden achievement claims

Forbidden achievement copy and semantics:

- no `mastered`;
- no `leak fixed` unless a real resolution event is admitted;
- no `AI found`;
- no `GTO` or `solver`;
- no `top player`;
- no premium reward;
- no rank, leaderboard, strongest, or weakest claim;
- no course/world/Volume completion claim unless that exact completion proof
  exists;
- no achievement from decorative profile counters alone.

## 11. Next implementation decision

Recommended next PR:

Achievement Seed Projection v1 — Data Only

Scope:

- implement a fact-only achievement seed projection over available owners;
- include only `available_contract_v1` triggers;
- keep blocked triggers documented but unimplemented;
- no UI, badges, animations, XP, rewards, telemetry, or economy changes.

## 12. Screenshot proof

Ran:

- `./tools/screen_review_fast_v1.sh profile_evidence compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Local-only artifacts:

- `output/screen_review/current/profile_evidence_fast/`
- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/full_scroll_fast/`

Generated screenshots and zips remain untracked and must not be committed.

## 13. Tests / validation

Passed focused tests:

- `flutter test test/ui_v2/act0_profile_evidence_projection_v1_test.dart`
- `flutter test test/ui_v2/act0_profile_evidence_consumer_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Debug capture profile evidence entry renders one safe evidence card'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Controlled demo capture query accepts first-week proof surfaces'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Fast screen review command exposes first-week proof packet group'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Fast screen review command exposes Day 2 return proof packet group'`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Fast screen review command exposes full-scroll evidence group'`

Passed screenshot commands:

- `./tools/screen_review_fast_v1.sh profile_evidence compact`
- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Passed validation:

- `dart format --set-exit-if-changed` on touched Dart files
- `graphify hook-check`
- `flutter analyze`
- `git diff --check`
- `git status --short` showed only touched source/test/tool/review files plus
  generated local output directories before staging.
