# Review Mistake-History Persistence/Write Integration v1

## 1. Verdict

review_history_write_data_only_ready

## 2. Projection source integrated

`Act0CompletedDecisionV1` remains the source. The existing Act0 shell completed-decision callback still calls the same local append helper after the runner emits a completed decision. That helper now updates two separate data histories:

- `Act0LearningEvidenceHistoryV1` for existing completed-decision evidence.
- `Act0ReviewMistakeHistoryV1` for unresolved review mistake history.

The mistake-history projection still admits only complete non-correct completed decisions. Correct decisions and incomplete decisions are skipped by the projection contract.

## 3. Persistence/write owner map

| Owner | Role |
| --- | --- |
| `Act0LessonRunnerShellV1` | Emits normalized `Act0CompletedDecisionV1`. |
| `Act0ShellPreviewScreenV1._appendLearningEvidenceV1` | Existing completed-decision write integration point; now appends learning evidence and review mistake history. |
| `_Act0PersistedProgressV1` | Existing local `SharedPreferences` snapshot owner; now serializes and restores `reviewMistakeHistory`. |
| `Act0ReviewMistakeHistoryV1` | Bounded unresolved-only projection, dedup, retention, and parser contract. |
| `Act0RepairIntentV1` | Still owns active repair intent. It is not mutated by mistake-history persistence. |

## 4. Write-path behavior

Incorrect or suboptimal completed decisions append one unresolved mistake-history record through the same shell write path that already persists learning evidence. The persisted JSON field is `reviewMistakeHistory`.

Correct completed decisions still write normal learning evidence when complete, but `reviewMistakeHistory` remains empty.

Older snapshots without `reviewMistakeHistory` restore safely and write the field back as an empty list.

## 5. Retention/dedup proof

Retention and deduplication remain owned by `Act0ReviewMistakeHistoryV1`:

- maximum retained records: `200`;
- newest first by `updatedOrder`;
- repeated same source mistake coalesces into the same `recordId`;
- duplicate attempt keys are ignored;
- fallback dedup is deterministic when concept fields are absent.

The write path does not implement a second retention policy. It delegates to the projection.

## 6. Active repair boundary proof

`Act0RepairIntentV1` remains unchanged and authoritative for active repair:

- the new history field does not replace `openRepairIntents`;
- incorrect decisions may create both an open repair intent and an unresolved history record;
- correct decisions create neither a mistake-history record nor an open repair intent;
- showing Review still does not clear an open repair intent prematurely.

The new record is historical unresolved evidence only. It does not choose a repair target.

## 7. Resolution-state boundary proof

All mistake-history records remain `unresolved_only_v1`.

No clear, fixed, resolved, repaired, or backlog action state was introduced. Parser tests still reject malformed or resolved-state records.

## 8. Consumer admission status

No UI consumer is admitted in this PR.

The only production consumer of `Act0ReviewMistakeHistoryV1` is the Act0 shell persistence/write owner. Review does not render the new history, Practice does not consume it as a queue, and Profile does not make capability claims from it.

## 9. Tests / validation

Focused tests added/updated:

- incorrect completed decision persists one unresolved mistake-history record;
- correct completed decision persists no mistake-history record;
- persisted `reviewMistakeHistory` round-trips through the existing progress snapshot;
- older progress snapshots default `reviewMistakeHistory` to an empty list;
- projection tests continue to prove incomplete decisions are skipped, repeated mistakes dedup, latest-200 retention, unresolved-only state, active repair non-mutation, and no Flutter/Review UI dependency.

Validation run:

- `flutter test test/ui_v2/act0_review_mistake_history_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Incorrect completed decisions persist unresolved mistake history'` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Correct completed decisions do not persist mistake history'` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Persisted review mistake history round-trips'` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Old persisted progress without retention fields restores safely'` passed.
- `flutter test test/ui_v2/act0_learning_evidence_contract_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_repair_intent_contract_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart --plain-name 'correct answer does not store open repair intent'` passed.
- `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart --plain-name 'suboptimal answer stores open repair intent'` passed.
- `flutter test test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart --plain-name 'showing Review does not clear open repair intent prematurely'` passed.

Known adjacent baseline note:

- The full `act0_repair_intent_lifecycle_v1_test.dart` file is currently red on unrelated copy/navigation expectations after payload assertions. The focused active-repair boundary tests above pass.

## 10. Next recommended PR

Review Mistake-History Read-Only Consumer Admission v1 — Review-only, read-only unresolved backlog projection. It should not add clear/fix/resolved state until the next data contract admits resolution.
