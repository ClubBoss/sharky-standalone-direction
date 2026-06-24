# W11 Route Surface Proof v1

## 1. Verdict

`w11_surface_truth_proven_screenshot_deferred`

The visible Learn/Act0 surface truth is proven by existing widget/copy guards:
W11 appears only as part of the planned W11-W12 foundation continuation, not as
a playable route, active entry, runtime target, or W10 handoff.

Screenshot proof is deferred because no surface code changed in this wave and
the existing focused widget/copy guards directly cover the route truth.

## 2. Surface owner proof

Owner:

- `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`

Relevant surface key:

- `act0_shell_levels_planned_foundation_line`

Visible copy:

- `W11-W12 planned foundation chapters, coming later.`
- `W13+ is later strategic depth.`

Evidence:

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart` includes
  `Learn status header states the truthful Volume I horizon`.
- `test/guards/w11_volume_i_admission_policy_contract_test.dart` binds the W11
  admission policy to `Act0LearnPathShellV1` and
  `act0_shell_levels_planned_foundation_line`.

Decision:

- Surface owner is correct.
- W11 appears only as planned/proof-backed continuation.
- Active entry remains false.

## 3. Surface truth proof

The current surface does not imply:

- W11 playable now;
- W10 handoff active;
- Volume I complete;
- W13 unlocked;
- premium, paywall, or trial access;
- AI, mastery, leak, or specialization behavior.

Evidence:

- The Learn horizon copy says W11-W12 are planned and coming later.
- The Learn widget test rejects `Unlock W13` and `Finish Volume I now`.
- Future-volume preview tests reject `Premium preview` and
  `See what premium adds` for the locked/future volume panels.
- The W11 admission policy guard rejects the same forbidden claims on the
  relevant Learn surface and verifies W11 active entry, runtime consumption,
  and W10 handoff are all false.

## 4. Guard / test proof

Reused guards:

- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
  - `Learn status header states the truthful Volume I horizon`
- `test/guards/w11_volume_i_admission_policy_contract_test.dart`
  - W11 planned continuation state
  - active entry false
  - runtime consumption false
  - W10 handoff false
  - W12 planned-only
  - W13 frontier-only
  - no forbidden W13 / completion / premium wording on the relevant surface

No new guard was added because the existing guards cover the required surface
truth without changing product code.

## 5. Screenshot decision

Screenshot proof is deferred.

Reason:

- No UI, copy, layout, or route behavior changed in Part B.
- Existing project practice uses focused widget/copy guards as sufficient
  proof when no visible code changed.
- Running screenshot tooling would create local artifacts but would not add
  stronger evidence for this no-code proof wave.

If a future visual or external review asks for image evidence, use the existing
fast screen-review lane locally and keep generated artifacts uncommitted.

## 6. Implementation summary

Part A of this workflow pushed the accepted legacy-compatibility decision doc.

Part B changes:

- Added this review artifact only:
  `docs/_reviews/w11_route_surface_proof_v1.md`

No product implementation changed:

- no active W11 entry;
- no W10-to-W11 handoff;
- no `ProgressService` mutation;
- no runtime consumption activation;
- no W12/W13 implementation;
- no W1-W10 migration or adapter;
- no UI/Modern Table redesign;
- no telemetry schema change.

## 7. Boundary proof

Confirmed boundaries:

- W11 is planned/proof-backed continuation only.
- W11 active entry is false.
- W11 runtime consumption is false.
- W10 handoff is false.
- W12 remains planned-only.
- W13+ remains frontier-only.
- No Volume I completion claim.
- No W13 unlock claim.
- No premium, paywall, trial, entitlement, AI, mastery, leak, or
  specialization claim.
- No Modern Table/UI drift.
- No W1-W10 migration or adapter.

## 8. Baseline residue note

Known unrelated baseline residue:

- `test/guards/campaign_spine_structure_contract_test.dart`
- failure: `Missing contrast beat: world2_spine_campaign_v1`
- previously reproduced on clean baseline

This wave did not run, fix, or rely on that guard.

## 9. Next recommended wave

`W12 Pattern Replay Decision v1`

Reason: W11 surface truth is proven while W11 remains planned/non-active. The
next highest-EV Volume I Foundation Green step is deciding the W12 pattern
replay boundary before any W11 activation or W10 handoff work.
