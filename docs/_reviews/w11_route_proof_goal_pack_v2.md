# W11 Route Proof Goal Pack v2

## 1. Verdict

`w11_route_backed_not_learner_visible`

W11 now has a route-backed proof identity that uses the source-owned route
admission contract and preserves all W11 beat fields without forcing them into
`MicroTaskStep`. The proof is intentionally not learner-visible and does not
add W10 handoff, progression, Learn surface, or runtime launch behavior.

## 2. Gate results

### Gate 1 - Route-backed admission owner

- Result: pass.
- Evidence:
  - Existing W7-W10 active owner remains
    `lib/campaign/campaign_pack_registry_v1.dart`.
  - W11 source-owned admission contract lives in
    `lib/campaign/w11_route_admission_contract_v1.dart`.
  - Selected proof owner:
    `lib/campaign/w11_route_backed_proof_registry_v1.dart`.
- Decision: W11 route-backed proof belongs beside campaign ownership in
  `lib/campaign/`, but outside the legacy `MicroTaskStep` registry. It does
  not require `ProgressService` or `CampaignSpineRunnerV1` yet.

### Gate 2 - Non-learner-visible route proof

- Result: pass.
- Evidence:
  - `W11RouteBackedProofV1` exposes a stable route proof ID:
    `w11_source_route_proof_v1`.
  - The proof carries `W11RouteAdmissionBeatV1` items built from the accepted
    fixture/projection path.
  - The proof explicitly stores `learnerVisible: false` and
    `w10HandoffEnabled: false`.
- Decision: W11 can be route-backed for proof without becoming learner-visible.

### Gate 3 - Runtime compatibility

- Result: pass for no-runtime-wiring proof.
- Evidence:
  - No W7-W10 campaign registry, runner, progress, or route file changed.
  - The proof registry does not import `MicroTaskStep`, progress, UI, W10, W12,
    or W13 seams.
- Decision: runtime compatibility is preserved by not wiring W11 into the
  active runner yet.

### Gate 4 - Learner surface safety

- Result: pass.
- Evidence: no learner surface file changed.
- Decision: W11 remains not learner-visible. Learn copy and active route
  surfaces are unchanged.

### Gate 5 - W10 transition policy

- Result: deferred.
- Evidence: the proof descriptor keeps `w10HandoffEnabled: false`.
- Decision: W10 remains terminal until a separate transition policy wave proves
  safe handoff.

### Gate 6 - Boundary proof

- Result: pass.
- Evidence: no W12, W13, commerce, AI, mastery, leak, specialization, UI,
  Modern Table, or telemetry file changed.
- Decision: W12 remains planned and W13+ remains frontier-only.

## 3. Admission owner analysis

Selected owner:

- `lib/campaign/w11_route_backed_proof_registry_v1.dart`

Why this avoids `MicroTaskStep` loss:

- The proof registry accepts `W11RouteAdmissionBeatV1`.
- It never converts W11 `continue` / `fold` choices into seat taps or legacy
  action semantics.
- It preserves the source-owned beat list rather than flattening it into a
  campaign pack.

Why this avoids Frankenstein mechanics:

- It is standalone, deterministic, and non-learner-visible.
- It does not add a `world11_` campaign row.
- It does not add one-off UI, route, progress, or runner behavior.
- It gives future route proof a stable identity without pretending the active
  campaign runner can execute W11 today.

W7-W10 compatibility proof:

- `lib/campaign/campaign_pack_registry_v1.dart` was not touched.
- `lib/services/progress_service.dart` was not touched.
- `lib/services/campaign_spine_runner_v1.dart` was not touched.
- Existing W11 guards still prove no `world11_` campaign pack registration.

## 4. Route-backed proof summary

Implemented proof seam:

- `W11RouteBackedProofV1`
- `buildW11RouteBackedProofV1(...)`

Route proof identity:

- `w11_source_route_proof_v1`

Learner-visible:

- no

Fields preserved:

- route proof ID
- world ID
- session ID
- all source-owned `W11RouteAdmissionBeatV1` items
- explicit learner visibility flag
- explicit W10 handoff flag

Tests added:

- `test/guards/w11_route_backed_proof_contract_test.dart`

## 5. Runtime compatibility proof

- W11 source-owned contract is used.
- No lossy `MicroTaskStep` conversion was added.
- W7-W10 route/campaign behavior is unchanged.
- No progression drift was added.
- No active runner consumes W11 yet.

## 6. Learner surface proof

- W11 is not learner-visible.
- Learn copy did not change.
- No false completion, unlock, premium, paywall, trial, AI, mastery, leak, or
  specialization claim was added.

## 7. W10 transition proof

- W10 remains terminal.
- No W10-to-W11 handoff was added.
- Handoff is deferred because this wave only proves a non-learner-visible W11
  route-backed identity.

## 8. Boundary proof

- W12 remains planned.
- W13+ remains frontier-only.
- No W13 unlock claim.
- No Volume I completion claim.
- No commerce, paywall, trial, or entitlement.
- No AI, mastery, leak, specialization, scheduler, dashboard, or gamification.
- No Modern Table or UI drift.

## 9. Tests / guards

Added:

- `test/guards/w11_route_backed_proof_contract_test.dart`

Run with:

- `test/guards/w11_route_admission_runtime_contract_test.dart`
- `test/guards/w11_projection_adapter_contract_test.dart`
- `test/guards/w11_campaign_fixture_contract_test.dart`
- `test/guards/foundation_campaign_rep_contract_v1_test.dart`
- `test/guards/w11_active_source_draft_contract_test.dart`
- `test/guards/campaign_pack_registry_invariants_test.dart`

What they prove:

- W11 route-backed proof has a stable non-learner-visible route proof identity.
- W11 proof preserves source-owned admission beats.
- No active `world11_` campaign pack is registered.
- W11 proof registry does not depend on `MicroTaskStep`, progress, UI, W10,
  W12, or W13 seams.

What they intentionally do not prove:

- learner-visible W11 launch;
- W10-to-W11 transition;
- campaign-spine runtime execution;
- result/progression mutation;
- W12 or W13 readiness.

Baseline residue encountered:

- `test/guards/campaign_spine_structure_contract_test.dart` fails on
  `Missing contrast beat: world2_spine_campaign_v1`.
- The same failure reproduced in a clean detached `origin/main` worktree at
  `f88354541133941ede31a2694b1886b52f0095e2`.
- This W11 proof wave did not touch `campaign_pack_registry_v1.dart` or the
  campaign spine structure guard, so this is recorded as pre-existing residue
  rather than current-wave regression.

## 10. Next recommended wave

`W10-to-W11 Transition Policy Tiny Slice v1`

Reason: W11 is now route-backed for proof but not learner-visible, and W10
handoff remains intentionally disabled. The next narrow question is whether
the existing transition owner can safely hand off to this proof-backed W11
identity without false completion, false unlock, or progression drift.
