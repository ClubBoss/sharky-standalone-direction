# W11 Route Admission Minor Fix v1

## 1. Verdict

`w11_runtime_contract_ready_for_route_proof`

W11 now has a tiny, source-owned, non-registering route-admission contract that
preserves the accepted fixture/projection fields losslessly without forcing W11
into the legacy `MicroTaskStep` campaign-pack shape.

This does not route W11, make it learner-visible, add W10 handoff, or mutate
progression.

## 2. Problem statement

The existing route-backed W7-W10 owner is the legacy-compatible campaign-pack
path in `lib/campaign/campaign_pack_registry_v1.dart`. It uses
`MicroTaskStep`, which is built around prompt, hint, expected seat IDs, and
optional table/action execution fields.

The accepted W11 projection carries a different source-owned contract:

- source reference
- rep identity
- visible state
- binary legal choices
- expected answer
- target skill
- error type
- repair cue
- feedback
- telemetry intent

Forcing W11 into `MicroTaskStep` would either lose those fields or require
inventing seat/action semantics for `continue` / `fold`.

## 3. Runtime shape options

### A. Extend MicroTaskStep

- Data preservation: possible only by adding W11-only fields to a legacy
  compatibility type.
- Runtime risk: high; W7-W10 and older world1 runner tests depend on this
  shape.
- W7-W10 compatibility: risky because the active route owner would gain fields
  unrelated to its current contract.
- Testability: possible, but would blur source-owned W11 proof with legacy
  campaign mechanics.
- Frankenstein risk: high.

Decision: rejected.

### B. Add a separate W11/source-owned route beat type

- Data preservation: full.
- Runtime risk: low if non-registering and not wired into active routes.
- W7-W10 compatibility: unchanged.
- Testability: high; the helper can be tested directly against the accepted
  fixture/projection.
- Frankenstein risk: low when kept non-learner-visible.

Decision: selected as the smallest safe contract.

### C. Add a wrapper/admission contract that can later feed CampaignSpineRunnerV1

- Data preservation: full if the wrapper remains source-owned.
- Runtime risk: low for a pure helper; higher if prematurely connected to the
  current campaign runner.
- W7-W10 compatibility: unchanged while non-registering.
- Testability: high.
- Frankenstein risk: low now, but a later runner adapter must prove semantics
  before route admission.

Decision: effectively combined with B. The selected helper is a source-owned
beat contract that can feed a future route proof without claiming runner
compatibility today.

### D. Keep W11 non-routed and require a future runner

- Data preservation: full.
- Runtime risk: lowest.
- W7-W10 compatibility: unchanged.
- Testability: limited to source/fixture/projection, leaving no route-admission
  bridge.
- Frankenstein risk: low, but the route-proof blocker would remain unchanged.

Decision: rejected as too passive after the projection gap was isolated.

## 4. Selected contract / decision

Selected approach:

- `W11RouteAdmissionBeatV1`
- `buildW11RouteAdmissionBeatsV1(...)`
- Path: `lib/campaign/w11_route_admission_contract_v1.dart`

Why it avoids Frankenstein mechanics:

- It is not a `MicroTaskStep`.
- It does not register a `world11_` campaign pack.
- It does not import route, UI, progress, W10, W12, or W13 seams.
- It preserves source-owned W11 fields instead of translating them into legacy
  action/seat semantics.

Why it preserves W7-W10:

- No existing W7-W10 campaign registry, runner, progress, or route code changed.
- The helper is standalone and only consumes the accepted W11 projection DTO.

Why W11 stays source-owned:

- The route-admission beat is built from `W11CampaignFixtureProjectionV1`.
- It preserves all fixture/projection fields directly.
- It remains non-registering and non-learner-visible.

## 5. Implementation summary

Code changed:

- `lib/campaign/w11_route_admission_contract_v1.dart`
- `test/guards/w11_route_admission_runtime_contract_test.dart`

Review artifact:

- `docs/_reviews/w11_route_admission_minor_fix_v1.md`

The new guard proves:

- all six W11 projected reps produce route-admission beats;
- stable route-beat IDs are derived from world/session/rep identity;
- every source-owned projection field is preserved;
- no `world11_` campaign registration is added;
- the helper does not depend on `MicroTaskStep`, progress, UI, W10, W12, or
  W13 seams.

Behavior changed:

- No learner-facing behavior changed.
- No active route behavior changed.
- No progression behavior changed.
- No telemetry schema changed.

## 6. Boundary proof

- W11 route status: still non-routed.
- Learner visibility: none added.
- W10 handoff status: none added.
- W12/W13 boundary: W12 remains planned; W13+ remains frontier-only.
- Commerce/AI/mastery/leak: none added.
- UI/Modern Table drift: none.

## 7. Tests / guards

Added:

- `test/guards/w11_route_admission_runtime_contract_test.dart`

Run with the W11 source, fixture, projection, and foundation guards.

The tests prove source-owned field preservation and non-registration. They do
not prove learner-visible route launch, W10 handoff, campaign-spine runtime
execution, result handling, or progression mutation.

## 8. Next recommended wave

`W11 Route Proof Goal Pack v2`

Reason: the missing runtime-shape bridge is now represented as a small,
lossless, non-registering contract. The next wave can test whether W11 can be
route-backed safely using this contract, while still keeping W10 handoff and
learner visibility gated.
