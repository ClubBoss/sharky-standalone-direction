# Practice Repair Queue Consumer Admission v1

## 1. Verdict

practice_repair_queue_consumer_ready

## 2. Accepted projection consumed

The Practice UI consumes `Act0PracticeRepairQueueProjectionV1` through a new read-only adapter, `Act0PracticeRepairQueueConsumerV1`.

The accepted projection remains the only source of queue rows. The consumer does not read Review history records or active repair intents directly.

## 3. Consumer/adapter owner map

- Projection owner: `lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart`
- Consumer owner: `lib/ui_v2/act0_shell/act0_practice_repair_queue_consumer_v1.dart`
- Practice UI owner: `lib/ui_v2/act0_shell/act0_play_shell_v1.dart`
- Preview wiring owner: `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- Focused tests: `test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart`, `test/ui_v2/act0_play_shell_v1_test.dart`, `test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart`

## 4. Practice UI scope

Practice now has a compact read-only `Repair queue` section when projection-backed rows exist. It appears after the daily Practice hero and before the existing quick reps/topic rep support.

The section title is `Repair queue`. The subtitle is `Spots Sharky can prove are worth repeating.`

There is no new button, tap handler, drill launch, route change, progression mutation, or telemetry call in the queue section.

## 5. No-render behavior

When the projection is empty, `Act0PracticeRepairQueueConsumerV1.hasItems` is false and `Act0PlayShellV1` omits the queue section entirely.

Practice still renders the existing daily hero and previous empty/support surfaces. No placeholder queue card is shown.

## 6. Queue item copy map

Rows render at most three items.

- Primary row title: `safeLabel`, falling back to a safe skill tag only when it is displayable.
- Detail line: safe `context`, only when displayable.
- Action line: `You chose <selected> - better: <better>` only when title and both actions are safe.
- Unsafe, empty, underscore-heavy, or forbidden copy falls back to `Practice repair` with unsafe detail/action copy omitted.
- One active repair projection item can be pinned and rendered first.

## 7. Active repair boundary

The consumer recognizes active repair rows only by the projection source type. It caps active/pinned display to one row.

It does not import or read the active repair intent contract.

## 8. Review history boundary

The consumer imports only the projection contract.

It does not import Review history, parse Review records, or inspect unresolved Review storage directly.

## 9. Resolution-state boundary

The UI renders only queued projection rows and does not display state text.

No `fixed`, `cleared`, `resolved`, or `completed` semantics were introduced in the queue copy.

## 10. Forbidden-claim proof

The consumer filters forbidden claim/commercial fragments from rendered item copy:

- AI/persona expansion: not introduced.
- Leak/mastery/GTO/solver claims: filtered or absent.
- Premium/paywall copy: filtered or absent.
- Fixed/cleared/resolved/completed claims: filtered or absent.

## 11. Screenshot proof

Local-only screenshot packet commands requested for this slice:

- `./tools/screen_review_fast_v1.sh first_week compact`
- `./tools/screen_review_fast_v1.sh day2_return compact`
- `./tools/screen_review_fast_v1.sh full_scroll compact`

Generated packets remain under `output/screen_review/current/` and are not source artifacts.

Captured locally:

- `output/screen_review/current/first_week_fast/contact_sheet.png`
- `output/screen_review/current/first_week_fast/screen_review_first_week_fast.zip`
- `output/screen_review/current/day2_return_fast/contact_sheet.png`
- `output/screen_review/current/day2_return_fast/screen_review_day2_return_fast.zip`
- `output/screen_review/current/full_scroll_fast/contact_sheet.png`
- `output/screen_review/current/full_scroll_fast/screen_review_full_scroll_fast.zip`

## 12. Tests / validation

Focused validation targets:

- Empty projection renders no queue block.
- Non-empty projection renders the queue block.
- Queue renders at most three items.
- Active item is pinned first and capped to one pinned item.
- Unsafe/empty labels use safe fallback or are omitted.
- Forbidden queue claims are absent.
- Existing Practice hero/daily drill remains.
- Queue section has no button/tap behavior.
- Consumer has no Review history or active repair imports.

Validation run:

- `flutter test test/ui_v2/act0_practice_repair_queue_consumer_v1_test.dart test/ui_v2/act0_play_shell_v1_test.dart test/ui_v2/act0_practice_repair_queue_projection_v1_test.dart` - passed.
- `./tools/screen_review_fast_v1.sh first_week compact` - passed.
- `./tools/screen_review_fast_v1.sh day2_return compact` - passed.
- `./tools/screen_review_fast_v1.sh full_scroll compact` - passed.
- `graphify hook-check` - passed.
- `flutter analyze` - passed.
- `dart format --set-exit-if-changed` on touched Dart/test files - passed.
- `git diff --check` - passed.

## 13. Next recommended PR

Practice Repair Queue Launch Admission v1: only after this read-only consumer is accepted, decide whether a queue row may open an existing drill target without creating new progression, telemetry, or repair-state semantics.
