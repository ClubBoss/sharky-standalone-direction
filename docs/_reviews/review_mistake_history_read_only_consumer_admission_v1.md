# Review Mistake-History Read-Only Consumer Admission v1

## 1. Verdict

review_history_read_only_ui_ready

## 2. Accepted write contract consumed

The accepted write contract is now consumed by Review through `Act0ReviewMistakeHistoryConsumerV1`.

Source remains `Act0ReviewMistakeHistoryV1`, restored from the existing Act0 progress snapshot field `reviewMistakeHistory`. Review does not synthesize mistake history from active repair intent alone.

## 3. Review consumer/adapter owner map

| Owner | Role |
| --- | --- |
| `Act0ReviewMistakeHistoryV1` | Persisted unresolved-only source records. |
| `Act0ReviewMistakeHistoryConsumerV1` | Pure read adapter that converts records to learner-safe read-only rows. |
| `Act0ShellPreviewScreenV1` | Wires restored history into Review and filters active repair source task ids. |
| `Act0ReviewShellV1` | Displays read-only history notes only inside Review. |
| `Act0RepairIntentV1` | Still owns active repair intent and active repair routing. |

## 4. Read-only list admission

Review can now show a compact read-only list titled `Past spots to review` when restored unresolved history records exist.

Rows show only owned fields derived from persisted records:

- concept/skill tag;
- error/detail label;
- selected versus better action;
- lesson/context label;
- relative order label.

Rows do not expose internal record ids, task ids, run ids, or attempt ids.

## 5. Empty-state behavior

When no mistake-history rows are available, Review preserves the honest empty state:

`No past spots to review yet`

The empty state does not imply hidden history or missing analysis.

## 6. Active repair boundary / dedup behavior

Active repair remains a separate note.

`Act0ShellPreviewScreenV1` passes active repair source task ids to the adapter. The adapter filters matching history rows so the same mistake is not presented as both the active repair and a read-only past note.

This is display dedup only. It does not delete history and does not mutate `Act0RepairIntentV1`.

## 7. Forbidden state/action proof

No new clear, fix, resolved, fixed, or cleared state was added to mistake-history records.

The read-only history rows have no buttons, no callbacks, and no mutation path. They do not include mastery, leak, AI, GTO, solver, premium, or paywall claims.

Existing recovered/repair UI terminology outside this new read-only history path was not expanded or changed.

## 8. UI scope, if any

UI scope was intentionally limited to `Act0ReviewShellV1`.

No Home, Learn, Practice, Profile, Modern Table, route, progression, telemetry, or content behavior was changed.

## 9. Screenshot proof, if any

Review UI was touched, so compact screen-review captures were run:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Generated artifacts remain local-only under:

- `output/screen_review/current/first_week_fast/`
- `output/screen_review/current/day2_return_fast/`
- `output/screen_review/current/full_scroll_fast/`

## 10. Tests / validation

Focused tests added/updated:

- `test/ui_v2/act0_review_mistake_history_consumer_v1_test.dart`
  - reads unresolved history records newest first;
  - filters active repair source without mutating history;
  - emits no forbidden action or capability claims.
- `test/ui_v2/act0_review_shell_v1_test.dart`
  - preserves honest empty state;
  - renders read-only history rows;
  - proves no clear/fix/resolved controls or claims in read-only rows;
  - keeps active repair note separate.
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - proves restored persisted history reaches Review as read-only notes.

Validation run:

- `flutter test test/ui_v2/act0_review_mistake_history_consumer_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_review_mistake_history_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_review_shell_v1_test.dart` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Review consumes persisted mistake history as read-only notes'` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Incorrect completed decisions persist unresolved mistake history'` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Correct completed decisions do not persist mistake history'` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Persisted review mistake history round-trips'` passed.
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --plain-name 'Old persisted progress without retention fields restores safely'` passed.
- Screen-review compact captures passed for first-week, day-2 return, and full-scroll packets.
- `graphify hook-check` passed.
- `flutter analyze` passed with no issues.
- `dart format --set-exit-if-changed` on touched Dart/test files passed.
- `git diff --check` passed.
- `git status --short` showed only intended source/test/review files plus untracked generated output directories.

## 11. Next recommended PR

Review Mistake-History Active-Repair Suppression Proof v1 — focused proof/refinement only if the next Claude or local review finds duplicated active repair/read-only rows in real capture packets. Do not add clear/fix/resolved state until a separate resolution-state data contract is admitted.
