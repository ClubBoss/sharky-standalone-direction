# W6 Recheck Resolution Policy Audit v1

Date: 2026-06-23

Origin main after post-launch queue audit push:
`bc9468cbb27321742d6479ef08627ff40671a1d9`

Status: resolution-policy audit; no product code change.

## Scope

This audit decides whether a W6 session-drill recheck can safely be marked
consumed or resolved after the learner launches the queued recheck from Review.

The current chain is:

```
failed W6 range-bucket drill
  -> persisted repair receipt candidate
  -> range-bucket recheck candidate
  -> session-drill launch queue item
  -> Review queue card
  -> targeted session-drill recheck route
```

The current route contract can launch the exact target drill in recheck mode.
This audit does not add queue clearing, receipt mutation, telemetry, UI,
one-drill result flow, or runner refactor.

## Evidence read

- `docs/_reviews/w6_post_launch_queue_behavior_audit_v1.md`
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
- `lib/archive/legacy_runners/canonical_terminal_session_drill_surfaced_runner_v1.dart`
- Act0 repair-intent resolution semantics in
  `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`

Graphify was used only as advisory navigation. Source and tests remain the
authority.

## Current source truth

### Receipt store

`SessionDrillRepairReceiptPersistenceV1` stores a list under
`session_drill_repair_receipts_v1`. It can load candidates and save a candidate
by replacing another candidate with the same source session/drill.

It does not expose:

- remove by source drill;
- mark consumed;
- mark resolved;
- mark attempted;
- append resolution history;
- rollback on failed launch.

### Queue

`SessionDrillRecheckLaunchQueueV1` is derived. It maps supported persisted
range-bucket receipt candidates into `SessionDrillRecheckLaunchQueueItemV1`.
It is not a mutable queue store.

### Runner

The surfaced session-drill runner can evaluate answers and can start at
`initialDrillId`. In recheck mode, it intentionally suppresses normal session
completion/progress and the normal `session_drills_complete_v1` event.

The runner does not currently emit a durable recheck-resolution event or write
a receipt-resolution record.

### Act0 repair intents

Act0 task repair has separate open/cleared semantics:

- open repair intents are stored by source task id;
- a correct exact replay or mapped target clears the matching intent;
- retention memory records fixed/open states.

Those semantics are Act0 task-intent-specific. They should not be reused for W6
session-drill receipts because the W6 queue deliberately preserves
session/drill identity and does not fabricate `Act0RepairIntentV1`.

## Policy questions answered

### 1. What event should resolve a W6 recheck?

Not CTA tap, route launch, target viewed, or invalid-target fallback.

The most defensible future resolution event is:

`target drill answered correctly while launched in recheck mode and while the
current drill id equals the queue item's targetDrillId`.

That event is not yet exposed as a durable owned seam.

### 2. Does the current runner expose enough signal?

Not enough for persistence mutation outside the runner.

Internally, the runner knows:

- `widget.isRecheckLaunchV1`;
- `widget.initialDrillId`;
- current drill id and index;
- evaluation pass/fail for the current answer.

But that signal is local to the runner and is not connected to an owned W6
receipt-resolution store. Adding that connection would be a product/service
implementation wave, not a safe audit-only policy change.

### 3. Is there already a durable mutation owner?

No. The current receipt persistence owner can only load and save candidates.
There is no durable resolved/consumed owner.

### 4. Remove, consume, resolve, or keep?

Future policy should prefer `mark resolved` over blind removal.

Reason: removal hides the card but loses the evidence that the queued recheck
was completed. A resolved marker can support future proof, audit, and repeated
miss behavior without turning launch intent into success.

For now, keep the receipt open.

### 5. How should abandon/back-out be treated?

Abandon or back-out should leave the queue item open. The learner has not
answered the target drill correctly.

### 6. Should invalid target fallback resolve?

No. Invalid target fallback should remain open. Falling back to index zero is
a safe route behavior, not evidence that the intended queued target was
repaired.

### 7. Does resolution require one-drill-only result flow?

Not strictly, but it likely needs one of these explicitly scoped seams:

- a target-drill answer-resolution callback in the existing runner; or
- a one-target recheck result boundary.

Without one of those seams, any queue mutation would be guessed from broader
session completion or route return behavior.

### 8. Does resolution require telemetry now?

No. Telemetry can remain deferred. A future policy may add telemetry only after
an owned schema and consumer contract exist.

### 9. Smallest focused test for a future implementation

Future tests should prove:

1. a correct answer on the exact target drill in recheck mode marks the receipt
   resolved or consumed according to the approved persistence policy;
2. a wrong answer on the target drill leaves the receipt open or updates it as
   still needs recheck;
3. route launch without answer leaves the receipt open;
4. back-out before answer leaves the receipt open;
5. invalid target fallback leaves the intended receipt open;
6. normal session-drill launches do not mutate W6 recheck receipt resolution.

## Verdict

`documented_resolution_policy_only`

A minimal safe implementation is not available yet. The current code has local
answer correctness inside the session-drill runner, but no owned durable
receipt-resolution seam. Clearing or mutating queue state now would either
treat launch intent as success or introduce an under-specified persistence
contract.

## Not changed

- No product code.
- No tests.
- No visible Review/UI.
- No route behavior.
- No telemetry schema.
- No receipt/queue persistence mutation.
- No Modern Table.
- No content/glossary.
- No generated outputs.

## Remaining limitations

- The W6 Review queue card can repeat after launch.
- W6 recheck success is not persisted as resolved proof.
- Wrong recheck attempts do not update receipt status.
- There is no one-target recheck result boundary.
- There is no recheck-specific telemetry policy.

## Recommended next step

Open `W6 Recheck Resolution Store v1` only if W6 queue lifecycle remains the
active bottleneck. That wave should be test-first and define:

- a receipt-resolution model, preferably retaining evidence instead of blind
  deletion;
- a minimal runner-owned target-answer callback or equivalent seam;
- no mutation on tap, launch, back-out, invalid fallback, or wrong answer;
- no telemetry unless a separate owned schema is approved.
