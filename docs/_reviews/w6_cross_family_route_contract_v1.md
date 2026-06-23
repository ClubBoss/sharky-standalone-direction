# W6 Cross-Family Route Contract v1

Date: 2026-06-23

Origin main: `c3cb477b8a7025045764a5ca92d9214f17cfd4ff`

## Contract summary

The canonical session-drill launch path now accepts optional
`initialDrillId` and `isRecheckLaunchV1` fields. It carries both through the
canonical launcher, terminal payload, terminal dispatch, and surfaced
session-drill runner.

This is a route-to-runner prerequisite only. It does not add an Act0 queue
consumer, UI, task-intent mapping, content, telemetry schema, or a visible W6
repair CTA.

## Files changed

- `lib/ui_v2/runner/canonical_launcher_api_v1.dart`
- `lib/ui_v2/runner/canonical_terminal_host_contract_v1.dart`
- `lib/ui_v2/runner/canonical_terminal_runner_surface_v1.dart`
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- `test/ui_v2/runner/session_drill_launch_target_contract_v1_test.dart`

## Normal launch behavior

Without `initialDrillId`, the surfaced runner preserves its existing index-zero
start. Without `isRecheckLaunchV1`, normal terminal completion still invokes
`ProgressService.markModuleCompleted(sessionId)` and emits the existing
`session_drills_complete_v1` event with the unchanged payload.

## Targeted recheck launch behavior

When `initialDrillId` matches a loaded session-drill id, the runner begins at
that exact drill. `isRecheckLaunchV1` is an explicit route-to-runner policy
flag; it suppresses the existing normal-session completion/progress call and
the existing normal-session completion event.

The W6 queue remains the owner of source-world/session/drill provenance and
target-drill identity. This wave does not convert that data into an Act0 task
intent or expose it through Home, Review, or Practice.

## Invalid target behavior

An absent, blank, or unmatched `initialDrillId` resolves deterministically to
index zero. The runner does not throw and normal launches retain their existing
behavior. A launch explicitly marked as recheck remains under the recheck
completion policy even when its target falls back to index zero.

## Completion/progress policy

`shouldSignalNormalSessionDrillCompletionV1` is the single local gate around
the pre-existing normal completion side effects. It returns false when a
completion was already signaled or when `isRecheckLaunchV1` is true. This keeps
targeted rechecks from recording normal-session module completion or normal
session-complete telemetry.

## Telemetry policy

No telemetry schema or payload changed. Recheck launches suppress the existing
normal `session_drills_complete_v1` producer rather than emitting a new event.
A future explicitly scoped telemetry policy may add a recheck event only if an
owned schema and consumer contract are approved.

## Tests run

- `flutter test test/ui_v2/runner/session_drill_launch_target_contract_v1_test.dart`
- `flutter test test/services/session_drill_recheck_launch_queue_v1_test.dart`
- `graphify hook-check`
- `flutter analyze`
- formatting and diff/status checks

## Remaining limitations

- No visible Act0/Home/Review consumer reads
  `SessionDrillRecheckLaunchQueueItemV1` yet.
- Targeted recheck launches begin at the requested drill but retain existing
  sequential runner behavior after that drill; this wave does not define a
  separate one-drill completion surface.
- Existing adjacent tests have stale paths on clean `origin/main`:
  `canonical_session_launch_route_ownership_contract_test.dart` names a missing
  `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`, and
  `canonical_terminal_world1_runtime_config_v1_test.dart` imports a missing
  `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`. Neither
  file was changed here. They are source-proven pre-existing path residue, but
  are not recorded as baseline-green tests by this review.

## Next step for a visible consumer

Only after product scope explicitly opens it, add a separate user-initiated
cross-family launch-target consumer that reads the existing W6 queue item and
passes its `launchSessionId`, `targetDrillId`, and recheck flag into this
contract. That wave must decide the visible Home/Review ownership and any
recheck-specific telemetry semantics without fabricating `Act0RepairIntentV1`.
