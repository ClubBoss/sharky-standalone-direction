# W6 User-Initiated Recheck Consumer v1

Date: 2026-06-23

Origin main after route contract push:
`290d99fe75854fb14576cda119f2b2a3ecbc619e`

Status: minimal route-launch consumer; no visible Act0 queue consumer.

## Scope

This wave adds the smallest safe consumer for an already-selected
`SessionDrillRecheckLaunchQueueItemV1`. It converts the queue item into the
new canonical session-drill route contract by passing:

- `launchSessionId` as `sessionId`;
- `targetDrillId` as `initialDrillId`;
- `isRecheckLaunchV1: true`.

It does not add Review, Home, or Practice UI. It does not read the queue
automatically, pick a queue item, fabricate `Act0RepairIntentV1`, change
telemetry, or alter session-drill content.

## PIEC result

### 1. Consumer ownership

The safe v1 owner is an internal route-launch consumer service:
`SessionDrillRecheckLaunchQueueItemV1 -> canonicalSessionDrillRouteV1`.

Review, Home, and Practice are not safe owners yet because their visible repair
affordances are Act0 task/mistake oriented. W6 range-bucket rechecks own
session/drill identity. A visible card or CTA would require a scoped product
decision about where the queue appears and how the learner initiates it.

### 2. Existing CTA seam

No existing visible CTA can consume the W6 queue without changing Review/Home/
Practice behavior. The current safe seam is route-level only: a future visible
owner can call `pushSessionDrillRecheckLaunchV1` after the user explicitly
chooses a queue item.

### 3. Target identity

The consumer preserves target identity without inventing Act0 task identity.
It uses the route contract added in W6 Cross-Family Route Contract v1, so the
surfaced session-drill runner receives the target drill and recheck policy.

### 4. After launch

After launch, the existing session-drill runner owns behavior. Recheck mode
starts at the target drill and suppresses normal session completion/progress
and the normal `session_drills_complete_v1` event. This wave does not add a
new post-recheck result, queue-clear policy, or telemetry event.

### 5. Focused proof

`test/services/session_drill_recheck_user_launch_consumer_v1_test.dart`
asserts that the route consumer builds a `CanonicalLauncherV1.sessionDrill`
with the queue item's launch session, target drill, and recheck flag.

## Files changed

- `lib/services/session_drill_recheck_user_launch_consumer_v1.dart`
- `test/services/session_drill_recheck_user_launch_consumer_v1_test.dart`

## Product impact

- Product UI changed: no.
- Visible Review/Home/Practice behavior changed: no.
- Route consumer added: yes.
- Route schema changed: no; it uses the existing route contract.
- Telemetry schema changed: no.
- Modern Table changed: no.
- Content/glossary changed: no.

## Remaining limitations

- No visible Act0 queue consumer exists yet.
- No queue-selection policy exists in Home, Review, or Practice.
- No queue-clear, one-drill result, or recheck-specific telemetry policy is
  added.
- This service should be used only from an explicitly user-initiated future
  visible owner.

## Recommended next step

Open a separate visible-owner wave only if W6 recheck continuation remains
the active priority. That wave should decide whether Review, Home, or Practice
owns the queue affordance and prove a user-initiated CTA without changing the
session-drill target contract.
