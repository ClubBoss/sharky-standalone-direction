# W11 Route Proof Goal Pack v1

## 1. Verdict

`blocked_projection_to_route_shape_gap`

W11 cannot be safely admitted to the existing route-backed campaign owner in
this wave. The active W7-W10 route owner is the legacy-compatible
`MicroTaskStep` campaign-pack path, while the accepted W11 projection is a
source-owned transfer-rep DTO that preserves source references, binary
continue/fold decisions, error type, repair cue, and telemetry intent. Mapping
that DTO into `MicroTaskStep` would either lose required W11 proof fields or
invent seat/action semantics.

## 2. Gate results

### Gate 1 - Route owner discovery

- Result: pass.
- Evidence:
  - `lib/campaign/campaign_pack_registry_v1.dart` owns route-backed W7-W10
    campaign and followup pack IDs such as `world7_spine_campaign_v1` through
    `world10_spine_followup_v1_b2`.
  - `lib/services/progress_service.dart` resolves the next spine pack through
    W7-W10 calibration and followup state.
  - `lib/services/campaign_spine_runner_v1.dart` consumes
    `CampaignSpineBeatPointerV1` backed by `MicroTaskStep`.
  - Current guards include:
    `test/guards/campaign_pack_registry_invariants_test.dart`,
    `test/guards/campaign_spine_structure_contract_test.dart`,
    `test/guards/world7_campaign_routing_contract_test.dart`,
    `test/guards/world8_campaign_routing_contract_test.dart`,
    `test/guards/world9_campaign_routing_contract_test.dart`, and
    `test/guards/world10_campaign_routing_contract_test.dart`.
- Decision: route owner is known, but it is the legacy-compatible
  campaign-pack owner, not the W11 source-owned fixture/projection owner.

### Gate 2 - Projection compatibility

- Result: block.
- Evidence:
  - W11 projection helper:
    `lib/campaign/w11_campaign_fixture_projection_v1.dart`.
  - W11 fixture:
    `content/worlds/world11/v1/sessions/w11.s01/campaign/w11.s01_campaign_fixture_v1.json`.
  - Accepted projection verdict:
    `docs/_reviews/w11_projection_adapter_tiny_slice_v1.md`.
  - `MicroTaskStep` requires prompt, hint, expected seat IDs, and optional
    action/table fields. It does not carry source rep identity, source ref,
    target skill, error type, repair cue, or telemetry-input intent as owned
    first-class fields.
  - W11 legal choices are `continue` / `fold`. Forcing those into
    `expectedSeatIds`, `expectedActionKind`, or seat/action buttons would
    fabricate a runtime action contract the source packet has not proven.
- Decision: do not add W11 to the existing campaign registry in this wave.

### Gate 3 - Registration safety

- Result: deferred after Gate 2 block.
- Evidence: adding a `world11_spine_campaign_v1` row to
  `kCampaignPacksV1` would require either lossy projection-to-`MicroTaskStep`
  mapping or a one-off W11 special case.
- Decision: blocked as `blocked_projection_to_route_shape_gap`, not
  separately escalated to `blocked_frankenstein_route_risk`.

### Gate 4 - Learner entry safety

- Result: deferred after Gate 2 block.
- Evidence: no safe route-backed W11 runtime shape exists yet, so active Learn
  or Act0 learner entry would be premature.
- Decision: W11 remains non-learner-visible in this wave.

### Gate 5 - W10 transition policy

- Result: deferred.
- Evidence:
  - `test/services/campaign_spine_runner_v1_test.dart` proves world9 can
    advance to world10.
  - The same suite proves world10 terminal completion remains in a stable
    deterministic world10 state.
- Decision: no W10 handoff to W11 was added.

### Gate 6 - Boundary proof

- Result: pass for no-change boundary.
- Evidence:
  - `docs/plan/VOLUME_STRUCTURE_AND_SPECIALIZATION_POLICY_v1.md` keeps W1-W12
    as Volume I and W13+ as later planned depth.
  - `docs/plan/MASTER_PLAN_v3.0.md` preserves W13+ as locked/coming soon
    unless future seam proof explicitly opens it.
- Decision: W12 remains planned, W13+ remains frontier-only, and no W13 unlock
  or Volume I completion claim was added.

## 3. Route owner analysis

Active W7-W10 route-backed campaign packs are registered in
`lib/campaign/campaign_pack_registry_v1.dart` under IDs such as:

- `world7_spine_campaign_v1`
- `world8_spine_campaign_v1`
- `world9_spine_campaign_v1`
- `world10_spine_campaign_v1`
- `world7_spine_followup_v1_b0..b2`
- `world8_spine_followup_v1_b0..b2`
- `world9_spine_followup_v1_b0..b2`
- `world10_spine_followup_v1_b0..b2`

The canonical route naming pattern is `worldN_spine_campaign_v1` for the main
campaign and `worldN_spine_followup_v1_bX` for followups. Active route
selection is owned by `ProgressService.getNextSpinePackToRunV1()` and related
calibration/followup helpers. The campaign spine runner consumes the selected
pack through `CampaignSpineBeatPointerV1` and `MicroTaskStep`.

W11 cannot use this owner safely without an adapter that proves exact field
preservation from W11 source fixture/projection into a runtime shape. That
adapter does not exist yet.

## 4. Projection-to-route analysis

Projection helper:

- `lib/campaign/w11_campaign_fixture_projection_v1.dart`

Current route/campaign shape:

- `MicroTaskStep` in `lib/campaign/campaign_pack_registry_v1.dart`
- `CampaignSpineBeatPointerV1` in `lib/services/campaign_spine_runner_v1.dart`

Preserved by W11 projection:

- world ID
- session ID
- rep ID
- source reference
- visible state
- learner prompt
- legal choices
- expected answer
- target skill ID
- error type
- correct feedback
- incorrect feedback
- repair cue
- telemetry-input intent

Not representable in the current campaign route shape without loss or invented
semantics:

- source reference
- target skill ID
- error type
- repair cue
- telemetry-input intent
- binary continue/fold semantics as a first-class route action

## 5. Implementation summary

No product code changed in Part B.

Changed locally:

- `docs/_reviews/w11_route_proof_goal_pack_v1.md`

Exact blocker:

- Existing route-backed campaign owner is `MicroTaskStep`/campaign-pack based.
  W11's accepted source-owned fixture/projection cannot be consumed by that
  shape without losing proof fields or fabricating route semantics.

Required next input:

- A narrow W11 route-admission minor fix or legacy adapter audit that defines
  whether W11 should receive a source-owned runtime shape, a proven lossless
  adapter into an existing route owner, or remain source/projection-only until
  W12 policy work.

## 6. Learner surface proof

- W11 is not learner-visible from this wave.
- Learn copy did not change.
- No W11 route row, active map entry, visible unlock, completion state, or
  premium claim was added.
- No false Volume I completion, W13 unlock, or W12 availability claim was
  introduced.

## 7. W10 transition proof

- W10 remains terminal.
- No W10-to-W11 handoff was added.
- Handoff is deferred because W11 route-backed runtime admission is blocked at
  the projection-to-route shape boundary.

## 8. Boundary proof

- W12 remains planned.
- W13+ remains frontier-only / coming soon.
- No commerce, paywall, trial, or entitlement behavior changed.
- No AI, mastery, leak, specialization, scheduler, dashboard, or gamification
  behavior was added.
- No Modern Table or learner UI changed.

## 9. Tests / guards

No new tests were added because no route implementation was admitted.

Validation run for this goal pack should keep using the existing W11 source,
fixture, projection, and foundation guards:

- `test/guards/w11_projection_adapter_contract_test.dart`
- `test/guards/w11_campaign_fixture_contract_test.dart`
- `test/guards/foundation_campaign_rep_contract_v1_test.dart`
- `test/guards/w11_active_source_draft_contract_test.dart`

These prove W11 source, fixture, and projection integrity. They intentionally
do not prove runtime routing, learner-visible launch, W10 handoff, result
handling, or progression mutation.

## 10. Next recommended wave

`W11 Route Admission Minor Fix v1`

Reason: the route owner is known, but admission is blocked by a precise shape
gap. The next wave should decide the smallest safe adapter or runtime contract
that can preserve W11 source-owned fields without forcing the existing
`MicroTaskStep` campaign path to carry unsupported semantics.
