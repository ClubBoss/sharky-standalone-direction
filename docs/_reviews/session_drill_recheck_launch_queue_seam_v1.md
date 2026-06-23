# Session-Drill Recheck Launch/Queue Seam v1

## Scope

Connect internal W6 range-bucket session-drill recheck candidates to the
smallest safe launch/queue descriptor.

No Review UI, visual layout, route, telemetry schema, Modern Table, content,
glossary, screenshot tooling, or generated output changed.

## Evidence used

- `docs/_reviews/range_bucket_review_recheck_consumer_v1.md`
- `lib/services/session_drill_repair_receipt_consumer_v1.dart`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
- `lib/services/session_drill_repair_receipt_adapter_v1.dart`
- `lib/ui_v2/runner/canonical_launcher_api_v1.dart`
- `lib/archive/legacy_runners/session_drill_player_v1_screen.dart`
- Act0 Home/Review repair and aged-recheck queue contracts
- W6 range-bucket runtime and evaluator tests

## Previous consumer limitation

The previous consumer could turn persisted W6 range-bucket miss receipts into
internal `SessionDrillRepairRecheckCandidateV1` values, but nothing could
represent those candidates as launchable queue work.

Directly creating an `Act0RepairIntentV1` remains unsafe because Act0 repair
intents require Act0 task ids. W6 session-drill receipts own session/drill
identity instead.

## Launch/queue seam decision

Implemented a service-level launch/queue descriptor:

- `SessionDrillRecheckLaunchQueueV1`
- `SessionDrillRecheckLaunchQueueItemV1`

The descriptor preserves the existing session-drill launch shape by carrying a
`launchSessionId` that can be used by the current canonical session-drill
route, plus source and target drill identity for the recheck candidate.

## Implementation details

The seam accepts only candidates with:

- schema version `1`
- consumer kind `session_drill_recheck`
- source world `world_6`
- source and target session `w6.s01`
- drill family `range_bucket_classifier_v1`
- missed signal ids beginning with `range_bucket_`
- target kind `same_signal_recheck` or `exact_replay`
- complete source, target, action, signal, and error-class fields

The queue item job id is deterministic:

`session_drill_recheck:<targetSessionId>:<targetDrillId>`

Unsupported or incomplete candidates are ignored.

## Behavior changed

Internal behavior changed: supported W6 range-bucket recheck candidates can now
be represented as launch queue items with preserved source/target identity.

Visible learner behavior did not change.

## Product EV

This advances the causal repair loop without fabricating missing state:

missed W6 range-bucket drill -> persisted receipt -> internal recheck
candidate -> session-drill launch queue item.

The app now has a bounded launch/queue descriptor for this provenance while
keeping Act0 Review visuals and task-id repair routing untouched.

## Intentionally not changed

- No Review card or queue UI changed.
- No Home daily-plan row was added.
- No Act0 repair intent mapping was added.
- No session-drill route API changed.
- No telemetry schema changed.
- No recovered-proof behavior changed.
- No content or glossary changed.
- No Modern Table code changed.
- No generated artifacts were committed.

## Tests/checks

- Focused launch/queue seam tests.
- Existing consumer tests.
- Existing persistence tests.
- Existing adapter tests.
- Existing W6 same-signal inventory/runtime test.
- Existing range-bucket evaluator test.
- Existing Act0 repair-intent resolver suite.
- Active term scanner.
- Graphify hook check.
- Flutter analyze.
- Formatting and diff checks.

## Remaining limitations

This is not yet a visible Review launch. The current session-drill route can
launch the target session, and the queue item preserves the target drill id,
but the visible Act0 Review/Home queue still does not consume these items or
start at a specific target drill.

## Recommended next step

If visible W6 range-bucket repair continuation is required, add one narrow
Act0 queue consumer that reads this launch item and opens the existing
session-drill runner. Keep start-at-target-drill behavior as a separate route
contract only if the current session-level launch is not sufficient.
