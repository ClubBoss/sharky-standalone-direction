# Review Repair Queue Multi-Family Display v1

- Branch: `main`
- Base after Part A push: `eae027d3431e3584535922c6fbfb5cb006043609`
- Mode: local-only minimal Review display generalization.

## Scope

This wave generalizes the existing Review session-drill recheck card from a
W6-only visible contract to a supported multi-family queue display. It supports
the already-mapped W6 range-bucket queue items and W5 board-texture queue
items.

## PIEC result

`SessionDrillRecheckLaunchQueueItemV1` already carries enough metadata for a
safe generic display:

- `drillFamilyId`
- `missedSignalId`
- `missedSignalLabel`
- `chosenActionId`
- `expectedActionId`
- `launchSessionId`
- `targetDrillId`
- `isRecheckLaunchV1` via the existing route consumer

No new queue-item display field was required.

## Behavior added

- `SessionDrillRecheckLaunchQueueV1.loadSupportedLaunchQueueItems()` returns
  supported range-bucket and board-texture launch queue items.
- `Act0ShellPreviewScreenV1` now loads the supported multi-family queue instead
  of W6 range-bucket items only.
- Review uses the same compact session-drill recheck card for supported queue
  families.
- The card copy is generic:
  - `Practice this spot again`
  - `Review this practice mistake`
  - chosen-vs-expected signal line from the queue item
  - exact practice-drill support line
- The CTA still calls the existing user-initiated route consumer and preserves
  exact `launchSessionId`, `targetDrillId`, and recheck flag.

## Supported visible families

- W6 `range_bucket_classifier_v1`
- W5 `board_texture_classifier_v1`

## Non-scope

- No new route schema.
- No telemetry schema change.
- No queue clear/resolution policy.
- No one-drill-only result flow.
- No new UI per family.
- No Act0 repair intent fabrication.
- No Modern Table changes.
- No Home/Practice ranking.
- No content/glossary changes.

## Tests

- Review still shows and launches W6 range-bucket queue items.
- Review shows and launches W5 board-texture queue items through the same card.
- Combined launch queue includes both supported families.
- Existing W6 queue/user-launch and board-texture receipt tests remain green.

## Remaining limitations

- Review displays only the first available queue item.
- Queue clear/resolution remains unimplemented.
- Recheck completion/result policy remains owned by a future scoped wave.
- Screen-review is acceptance evidence only; it is not a polish loop for this
  wave.
