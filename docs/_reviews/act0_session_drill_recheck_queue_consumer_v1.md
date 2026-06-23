# Act0 Session-Drill Recheck Queue Consumer v1

## Scope

Assess whether the existing W6 range-bucket session-drill recheck launch item
can safely enter the existing Act0 repair queue and open the canonical
session-drill runner.

No product, UI, route, telemetry, content, glossary, Modern Table, or
generated-output changes were made.

## PIEC result

The internal chain is complete through a deterministic launch descriptor:

`W6 miss -> receipt -> persisted candidate -> recheck candidate -> launch queue item`

`SessionDrillRecheckLaunchQueueItemV1` preserves `launchSessionId`,
`targetSessionId`, and `targetDrillId`. It accepts only supported W6
`range_bucket_classifier_v1` candidates.

The Act0 consumer is **documented unsafe** for this wave.

## Why it is not safe to connect now

1. Act0's existing queue is task-centric. Its visible Home, Review, and
   Practice launch path is `_Act0LearningRecommendationV1` followed by
   `_startRecommendation` / `_startMistakeRepair`, which require an
   `Act0WorldCardV1` lesson/task target and an `Act0RepairIntentV1`.
   A session-drill queue item has session/drill identity instead. Mapping it
   into an Act0 task intent would fabricate unsupported Act0 task ownership.
2. The canonical session-drill launch contract accepts only `sessionId`.
   `canonicalSessionDrillRouteV1`, `CanonicalLauncherV1`,
   `CanonicalTerminalSessionDrillSurfacedPayloadV1`, and
   `CanonicalTerminalSessionDrillSurfacedRunnerV1` do not accept or consume a
   target drill id. The runner always begins at index zero.
3. There is no existing visible Act0 queue consumer callback for a
   session-drill launch item. Adding one would require a new cross-family
   recommendation/CTA contract, which is visible queue behavior rather than a
   narrow adapter.

Launching only `w6.s01` would discard the queue item's `targetDrillId` and
would not meet the requested preservation of target identity. It is therefore
not an acceptable partial implementation.

## Exact safe prerequisite

Open a separate, explicitly scoped route-contract wave with both of these
contracts, covered by focused tests:

1. A validated optional `initialDrillId` passed from the canonical
   session-drill route through the launcher and terminal payload to the runner.
   The runner must select that drill deterministically or fail closed to its
   existing session start; unsupported ids must never create invented progress
   or recovered proof.
2. A cross-family Act0 launch-target seam that can represent a
   `SessionDrillRecheckLaunchQueueItemV1` alongside existing Act0 task targets,
   with an explicit user-initiated launch owner. It must preserve the queue
   item's source and target identity without creating `Act0RepairIntentV1`.

Only after those contracts exist should Home or Review choose whether and how
to surface the existing W6 continuation. That is intentionally not a Review
layout change in this assessment.

## Behavior truth

- Existing first-week repair and recheck behavior remains unchanged.
- Existing Day 2 open-repair prioritization remains unchanged.
- No duplicate recovered-proof behavior is introduced.
- No visible Review, Home, or Practice UI behavior changes.

## Evidence inspected

- `docs/_reviews/session_drill_recheck_launch_queue_seam_v1.md`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/runner/canonical_launcher_api_v1.dart`
- `lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart`
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- focused Act0 repair, queue, and session-drill contracts

## Checks

- Existing launch-queue, consumer, persistence, adapter, W6 inventory/runtime,
  evaluator, and Act0 repair-intent resolver tests.
- Active term scanner.
- Graphify hook check.
- Flutter analysis.
- Formatting and diff checks.

## Recommended next step

If visible W6 recheck continuation is still required, open the separate
cross-family route-contract wave above. Otherwise keep the current durable
receipt-to-launch-descriptor chain as the safe stopping point.
