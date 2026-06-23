# W6 Visible Recheck Queue Card v1

Date: 2026-06-23

Origin main after owner-audit push:
`4804ebe6723c0268baaff3ed8466470050854cb8`

Status: minimal Review-owned queue card; local only until pushed.

## Scope

This wave adds one visible W6 recheck queue card to Review. The card is shown
only when the active shell has a real
`SessionDrillRecheckLaunchQueueItemV1`.

The card does not reuse `Act0MistakeCardV1`, `onFixMistake`, or
`_startMistakeRepair`. It keeps W6 session-drill identity separate from Act0
task repair identity.

## Owner decision

Review is the v1 visible owner because it already owns mistake repair and
pattern coaching. Home remains top-level next-action owner, and Practice
remains the quick-rep/practice surface. This wave does not add Home or
Practice queue ranking.

## User-visible behavior

When a W6 range-bucket queue item exists, Review shows a compact card with:

- eyebrow: `Practice this spot again`
- title: `Review the range-bucket mistake`
- a short chosen-vs-expected line from the queue item
- a support line that this opens the exact W6 drill, not an Act0 task repair
- CTA: `Practice this spot again`

Tapping the CTA calls the existing service-only route consumer:

```
pushSessionDrillRecheckLaunchV1(context, item)
```

That consumer passes:

- `sessionId == item.launchSessionId`
- `initialDrillId == item.targetDrillId`
- `isRecheckLaunchV1 == true`

## Files changed

- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_review_shell_v1_test.dart`

## Tests

`test/ui_v2/act0_review_shell_v1_test.dart` covers:

- card appears when a real W6 session-drill queue item is injected
- card is hidden when no queue item exists
- CTA uses the route consumer and preserves launch session, target drill, and
  recheck flag
- existing Review mistake-repair tests continue to pass

## Product impact

- Visible Review UI changed: yes, only when a W6 queue item exists.
- Product route changed: no new route schema; existing route consumer is used.
- Telemetry schema changed: no.
- Modern Table changed: no.
- Content/glossary changed: no.
- Queue clearing changed: no.
- One-drill-only result flow added: no.

## Remaining limitations

- The queue is not cleared after launch.
- No recheck-specific telemetry event is emitted.
- The session-drill runner still owns post-launch behavior.
- Home and Practice do not rank or display W6 queue items.
- The card currently shows the first available W6 queue item only.

## Recommended next step

After validation, push this wave. Then decide separately whether queue clear,
post-recheck receipt, or Home return-priority behavior is needed.
