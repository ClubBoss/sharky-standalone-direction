# W6 Visible Recheck CTA Owner Audit v1

Date: 2026-06-23

Origin main after user-launch consumer push:
`ff46680d67ccf8230b7f915da3abd79d573cd4ee`

Status: visible-owner audit; no product/UI/route/telemetry/content change.

## Scope

This audit decides whether Sharky can safely expose a user-facing W6
range-bucket recheck CTA now that the service-only route consumer exists.

The available safe chain is:

```
SessionDrillRecheckLaunchQueueItemV1
  -> pushSessionDrillRecheckLaunchV1
  -> canonicalSessionDrillRouteV1(
       sessionId: launchSessionId,
       initialDrillId: targetDrillId,
       isRecheckLaunchV1: true,
     )
```

This wave does not implement a visible CTA because no current visible owner has
an existing queue-item display/selection seam.

## Evidence read

- `docs/_reviews/w6_cross_family_route_contract_v1.md`
- `docs/_reviews/w6_user_initiated_recheck_consumer_v1.md`
- `docs/_reviews/w6_cross_family_route_contract_prerequisite_audit_v1.md`
- `docs/_reviews/active_vs_legacy_ownership_audit_v1.md`
- `docs/_agent_context/change_type_matrix_evidence_budget_v1.md`
- `docs/_agent_context/baseline_failure_ledger_v1.md`
- `docs/plan/MASTER_PLAN_v3.0.md`
- Active Act0 Home, Practice, Review, and feedback/result seams.
- Current canonical session-drill launch call sites.

Graphify was used only as advisory navigation. Source ownership and existing
callbacks below are the authority.

## Surface ownership findings

### Home

Home is the top-level next-action owner. Its repair CTA is backed by
`_startHomeRepairAction`, `_startHomeDailyPlanJob`, and Act0 task/mistake
recommendation state. Those paths eventually call `_startMistakeRepair` or
task launch helpers.

Home is the likely future place for an important return reason, but adding W6
queue data there now would require new display ranking and copy ownership. It
would also compete with existing Act0 next-action and daily-plan jobs unless a
specific priority policy is added.

Verdict: plausible future owner, not safe for a minimal CTA in this wave.

### Review

Review owns active mistake repair and pattern coaching. Its current CTAs call
`onFixMistake` / `onReplayFixedMistake`, which receive
`Act0MistakeCardV1` and route into `_startMistakeRepair`.

That seam is intentionally Act0 task/mistake based. A W6
`SessionDrillRecheckLaunchQueueItemV1` is not an `Act0MistakeCardV1`, and
turning it into one would fabricate Act0 task identity. A Review CTA would
need a separate queue item card or adapter with clear copy that this is a
session-drill recheck, not an Act0 repair intent.

Verdict: best conceptual owner for "fix this pattern", but not safe without a
scoped visible queue-card design.

### Practice

Practice owns practice groups and quick reps. The weak-spots group is also
Act0 task/mistake based: it starts `_topOpenMistake` or quick-fix mistake
cards through `_startMistakeRepair`.

Practice could eventually expose "one focused recheck" as a practice group,
but doing so now would require queue-loading, group ranking, copy, and a
policy for how this session-drill recheck relates to existing daily and weak
spot groups.

Verdict: plausible secondary future owner, not safe for minimal CTA now.

### Result / feedback surface

The feedback/result surfaces already show repair focus, repair result, and
session repair for active Act0 flow. They do not own persisted W6 queue item
loading or post-session queue selection.

Adding a W6 CTA there would change result ceremony behavior and blur the line
between immediate Act0 repair proof and a later session-drill recheck.

Verdict: not the v1 owner.

### Internal service only

The current safe owner remains the internal route-launch consumer. A future
visible owner can call `pushSessionDrillRecheckLaunchV1` after it has an
explicitly selected queue item.

Verdict: current v1 owner.

## Questions answered

1. Natural visible owner: Review conceptually fits best, Home may own return
   priority, Practice may own quick reps. None has a safe existing W6 queue
   seam today.
2. Existing non-redesign CTA seam: no. Existing CTAs are Act0 task/mistake
   callbacks.
3. User-initiated exact target launch: yes, but only after another owner
   selects a real `SessionDrillRecheckLaunchQueueItemV1`.
4. New copy/content ownership required: yes, for any visible card/CTA.
5. Telemetry schema required: no for launching, but visible-CTA telemetry
   policy is unresolved and should not be inferred.
6. Risk of confusing Act0 repair with session-drill recheck: high if placed
   into existing `Repair this clue` / mistake-card callbacks.
7. Smallest future focused test: a visible-owner widget/state test that injects
   one W6 queue item, taps its CTA, and verifies
   `pushSessionDrillRecheckLaunchV1` / `canonicalSessionDrillRouteV1` receives
   `launchSessionId`, `targetDrillId`, and `isRecheckLaunchV1: true` without
   constructing `Act0RepairIntentV1`.

## Verdict

`documented_visible_owner_only`

The exact launch contract is now available, but a visible CTA is not safe as a
small additive change. It requires a scoped owner decision and display policy:
where the queue item appears, how it ranks against existing Act0 repair items,
what copy distinguishes session-drill recheck from task repair, and whether any
launch telemetry is required.

## Not changed

- No Home, Review, Practice, or feedback UI.
- No route schema.
- No telemetry schema.
- No Modern Table.
- No content/glossary.
- No queue clear policy.
- No one-drill-only result flow.
- No `Act0RepairIntentV1` fabrication.

## Recommended next wave

If W6 recheck visibility remains the active priority, open a separate
`Visible W6 Recheck Queue Card v1` wave. It should choose one owner, preferably
Review unless Home priority is explicitly required, and add only one injected
queue-item card/CTA with a focused launch-target test.
