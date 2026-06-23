# W6 Post-Launch Queue Behavior Audit v1

Date: 2026-06-23

Origin main after visible queue-card push:
`d3955e693eae73fe52945e3d3f2c20fc2ee92a6d`

Status: post-launch lifecycle audit; no product code change.

## Scope

This audit decides whether the visible W6 Review recheck card can safely clear
or mutate its queue item after the learner taps `Practice this spot again`.

The current chain is:

```
persisted session-drill repair receipt
  -> SessionDrillRepairReceiptConsumerV1
  -> SessionDrillRecheckLaunchQueueV1
  -> SessionDrillRecheckLaunchQueueItemV1
  -> pushSessionDrillRecheckLaunchV1
  -> canonicalSessionDrillRouteV1(
       sessionId: launchSessionId,
       initialDrillId: targetDrillId,
       isRecheckLaunchV1: true,
     )
```

This wave does not change Review UI, route behavior, telemetry, receipt
persistence, or session-drill completion policy.

## Evidence read

- `docs/_reviews/w6_visible_recheck_queue_card_v1.md`
- `docs/_reviews/w6_user_initiated_recheck_consumer_v1.md`
- `docs/_reviews/w6_cross_family_route_contract_v1.md`
- `docs/_reviews/w6_visible_recheck_cta_owner_audit_v1.md`
- `docs/_agent_context/change_type_matrix_evidence_budget_v1.md`
- `docs/_agent_context/baseline_failure_ledger_v1.md`
- `lib/services/session_drill_repair_receipt_persistence_v1.dart`
- `lib/services/session_drill_repair_receipt_consumer_v1.dart`
- `lib/services/session_drill_recheck_launch_queue_v1.dart`
- `lib/services/session_drill_recheck_user_launch_consumer_v1.dart`
- Review queue-card state in
  `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- Act0 shell queue loading and launch callback in
  `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- Recheck launch completion gating in
  `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`

Graphify was used only as advisory navigation. Source ownership above is the
decision authority.

## Questions answered

### 1. When should the queue item be cleared?

Not in v1.

Clearing on CTA tap or route launch is unsafe because launch is not learning
success. The route may fail, the learner may back out, or the target drill may
not be completed.

Clearing on completion is also unsafe today because recheck launches
intentionally suppress the normal session completion/progress path and do not
emit a recheck-specific result, receipt-resolution, or queue-resolution event.

### 2. Is there an existing queue-store mutation owner?

No. `SessionDrillRecheckLaunchQueueV1` derives queue items from persisted
repair receipt candidates. It is not a mutable queue store.

The persistence owner stores repair receipt candidates under
`session_drill_repair_receipts_v1` and replaces candidates by source drill when
new candidates are saved. It does not expose a consume, resolve, or remove API.

### 3. Does queue clear need persistence or in-memory mutation?

It needs explicit persistence ownership if the card should stay hidden across
relaunch. An in-memory hide would only mask the card for the current shell
instance while leaving the persisted receipt available for the next load.

That may be useful as optimistic UI in a future wave, but it would not be a
real queue lifecycle policy.

### 4. What if route launch fails?

The queue item should remain. A failed or skipped navigation is not evidence
that the repair was completed.

### 5. What if the user backs out before completing the recheck?

The queue item should remain. Backing out means the learner has not resolved
the queued recheck.

### 6. Should Review hide the card immediately after tap?

No for v1. Immediate hiding would imply progress from launch intent alone and
could lose the learner's visible return path if they back out.

The accepted limitation is that the Review card may still be visible after a
launch until a future queue-resolution owner exists.

### 7. Telemetry now or deferred?

Deferred. Launch telemetry or completion telemetry needs an explicitly owned
schema and consumer policy. This audit does not add or infer one.

### 8. What focused test is needed later?

A future lifecycle wave should test all of these cases:

- persisted W6 receipt appears as a Review queue card;
- successful user launch does not clear the receipt by itself;
- failed launch or back navigation leaves the queue item visible;
- an explicitly approved recheck-resolution event clears or marks the receipt;
- cleared/resolved state survives relaunch if persistence is part of the
  approved policy.

## Verdict

`documented_queue_lifecycle_only`

The safe current behavior is to keep the W6 queue item derived from persisted
repair receipts and not clear it after launch. A queue-clear policy requires a
separate owner for receipt resolution, persistence mutation, and any
recheck-specific completion/telemetry semantics.

## Product impact

- Product code changed: no.
- Visible Review/UI changed: no.
- Route behavior changed: no.
- Telemetry schema changed: no.
- Modern Table changed: no.
- Content/glossary changed: no.
- Generated outputs committed: no.

## Remaining limitations

- The visible Review W6 card can repeat after launch.
- No resolved/consumed receipt state exists.
- No one-drill-only recheck result flow exists.
- No recheck-specific telemetry exists.
- The session-drill runner starts at the target drill but still uses its
  existing sequential runner behavior after that drill.

## Recommended next step

If W6 recheck continuation remains the active bottleneck, open a separate
`W6 Recheck Resolution Policy v1` wave. That wave should choose the owner of
receipt resolution, define whether resolution happens on exact target success
or another explicit event, add persistence mutation tests, and keep launch
intent separate from learning success.
