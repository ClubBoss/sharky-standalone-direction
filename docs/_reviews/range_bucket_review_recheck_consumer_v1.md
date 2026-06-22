# Range-Bucket Review/Recheck Consumer v1

## Scope

Consume persisted W6 `range_bucket_classifier_v1` repair receipt provenance
through the smallest safe internal recheck seam.

No Review UI, visual layout, route, telemetry schema, Modern Table, content,
glossary, or screenshot tooling changed.

## Evidence used

- `docs/_reviews/range_bucket_receipt_mapping_v1.md`
- `docs/_reviews/session_drill_repair_receipt_adapter_v1.md`
- `docs/_reviews/session_drill_repair_receipt_persistence_v1.md`
- `lib/services/session_drill_repair_receipt_adapter_v1.dart`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
- Act0 repair intent and Review/recheck contracts
- existing W6 range-bucket content and runtime tests

## Previous limitation

Persisted session-drill repair receipts were durable provenance only. They
stored source/target drill identity but were not consumable by any repair or
recheck seam.

Directly mapping them into `Act0RepairIntentV1` is still unsafe because Act0
repair intents require launchable Act0 task ids. The persisted W6 receipt
owns session/drill ids, not Act0 task ids.

## Consumer seam decision

Implemented a service-level internal consumer:

- `SessionDrillRepairReceiptConsumerV1`
- `SessionDrillRepairRecheckCandidateV1`

The consumer reads persisted receipts and emits only supported W6 range-bucket
recheck candidates. It preserves source world/session/drill identity and target
session/drill identity from the persisted receipt.

## Implementation details

The consumer accepts only:

- schema version `1`
- `world_6`
- source session `w6.s01`
- target session `w6.s01`
- drill family `range_bucket_classifier_v1`
- missed signal ids beginning with `range_bucket_`
- target kind `same_signal_recheck` or `exact_replay`
- complete source, target, action, signal, and error-class fields

Malformed, incomplete, legacy, or unsupported receipts are ignored. Duplicates
by source session and source drill are suppressed.

## Behavior changed

Internal behavior changed: persisted W6 range-bucket miss receipts can now
become deterministic internal session-drill recheck candidates.

Visible learner behavior did not change.

## Product EV

This closes the next causal step for range-bucket practice:

missed range-bucket classification -> persisted receipt -> internal recheck
candidate with known source and target drill identity.

It keeps the proof loop honest without fabricating Act0 task ids or claiming a
Review continuation that the route cannot launch yet.

## Intentionally not changed

- No Review card or queue UI changed.
- No Act0 repair intent mapping was added.
- No route or launch behavior changed.
- No telemetry schema changed.
- No recovered-proof behavior changed.
- No content or glossary changed.
- No Modern Table code changed.
- No generated artifacts were committed.

## Checks

- Focused consumer tests.
- Existing persistence tests.
- Existing adapter tests.
- Existing W6 same-signal inventory/runtime test.
- Existing range-bucket evaluator test.
- Existing Act0 repair-intent resolver suite.
- Active term scanner.
- Flutter analyze.
- Formatting and diff checks.

## Remaining limitations

The consumer is internal and service-level. Act0 Review/recheck UI still does
not launch W6 session-drill repair candidates because that requires a safe
session-drill launch/queue contract, not an Act0 task-id mapping.

## Recommended next step

Add a narrow session-drill recheck launch/queue seam only if product review
needs W6 range-bucket repairs to appear inside Review. Keep it separate from
Review visual design.
