# W11 Volume I Admission Goal Pack v1

## 1. Verdict

`w11_visibility_planned_continuation_ready`

W11 has source-owned route proof and an existing Learn surface horizon, so it
can be represented as a planned Volume I continuation. It is not ready for an
active learner entry or W10 handoff.

## 2. Gate results

| Gate | Result | Files inspected | Evidence | Decision |
| --- | --- | --- | --- | --- |
| Surface owner | Pass | `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | `Act0LearnPathShellV1` owns the learner-visible Volume I horizon line and tests guard the current/future volume copy. | Use the existing Learn horizon as the only learner-visible owner. |
| Visibility truth | Pass for planned continuation | `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`, `test/guards/w11_volume_i_admission_policy_contract_test.dart` | The surface says `W11-W12 planned foundation chapters, coming later.` and the new guard binds the policy to that surface key. | Admit W11 only as planned/proof-backed continuation. |
| Runtime consumption | Deferred | `lib/campaign/w11_route_backed_proof_registry_v1.dart`, `lib/campaign/w11_route_admission_contract_v1.dart`, `test/guards/w11_route_admission_runtime_contract_test.dart` | Route-proof fields are preserved, but no active runner, campaign pack, or ProgressService consumer is wired. | Keep active entry disabled. |
| Handoff policy | Deferred | `lib/campaign/w10_to_w11_transition_policy_v1.dart`, `test/guards/w10_to_w11_transition_policy_contract_test.dart`, `lib/services/progress_service.dart` | W10-to-W11 policy is descriptor-only; `ProgressService` does not reference `w11_source_route_proof_v1`. | Keep W10 handoff disabled. |
| Surface / copy boundary | Pass | `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`, `test/ui_v2/act0_shell_preview_screen_v1_test.dart` | Existing tests prove W13 unlock and Volume I completion copy are absent from the Learn horizon. | No Learn copy change needed. |
| Boundary / regression | Pass | `test/guards/w11_campaign_fixture_contract_test.dart`, `test/guards/foundation_campaign_rep_contract_v1_test.dart`, `test/guards/w11_active_source_draft_contract_test.dart` | W11 remains non-routed; W12/W13 are not introduced into the W11 contract files. | Do not touch W12, W13, Modern Table, telemetry, UI, or content. |

## 3. Visibility options matrix

| Option | Decision | Why | Expectation risk | W13 inference risk | Premium implication risk | Progression drift risk | Size | Testability |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A. Hidden / proof-only | Too conservative | W11 already has a truthful existing horizon line. | Low | Low | Low | Low | Low | High |
| B. Planned / proof-backed continuation | Selected | Matches current surface truth and route proof without activating entry. | Low | Low | Low | Low | Low | High |
| C. Available but handoff-disabled | Not safe | Would imply runtime access that is not consumed by the active route. | Medium | Medium | Low | Medium | Medium | Medium |
| D. Active learner entry | Not safe | Requires runner/ProgressService ownership beyond this slice. | High | High | Low | High | High | Medium |
| E. Active W10-to-W11 handoff | Not safe | Requires runtime consumption and transition ownership proof. | High | High | Low | High | High | Medium |

Risk columns compare user expectation, W13 inference, premium implication,
progression drift, implementation size, and testability.

## 4. Selected admission state

`W11VolumeIAdmissionStateV1.plannedContinuationHandoffDisabled`

The descriptor records:

- W11 route proof identity: `w11_source_route_proof_v1`.
- surface owner: `Act0LearnPathShellV1`;
- surface copy key: `act0_shell_levels_planned_foundation_line`;
- learner-visible planned continuation: true;
- active entry: false;
- W10 handoff: false;
- runtime consumption: false;
- W12 planned-only: true;
- W13 frontier-only: true.

This is the strongest safe state because it moves W11 beyond pure hidden proof
while preserving the route/runtime boundary. Anything stronger would require an
active runner/progression consumer that this wave did not prove.

## 5. Implementation summary

Added a descriptor-only policy and guard:

- `lib/campaign/w11_volume_i_admission_policy_v1.dart`
- `test/guards/w11_volume_i_admission_policy_contract_test.dart`

No Learn UI, route, ProgressService, runner, telemetry, campaign registry, or
content files changed.

Behavior changed: no learner-facing behavior changed. The new descriptor
records and guards the current safe admission state only.

## 6. Surface / copy proof

The existing Learn surface remains the owner. It says:

- `W11-W12 planned foundation chapters, coming later.`
- `W13+ is later strategic depth.`

The guard proves the selected surface key exists and that false claims such as
`Unlock W13`, `Finish Volume I now`, `Premium preview`, and
`See what premium adds` are absent from that Learn surface.

## 7. Transition / handoff proof

W10 handoff remains disabled. The admission descriptor does not reference
`ProgressService`, and the earlier W10-to-W11 transition policy remains
descriptor-only.

Active handoff does not exist. It is deferred because W11 route proof is not
yet runtime-consumed by the active route and no W10 terminal owner has been
proven safe to point at W11.

## 8. Boundary proof

- No Volume I completion claim.
- No W13 unlock or access path.
- No W12 active entry.
- No premium, paywall, trial, entitlement, AI, mastery, leak, scheduler,
  dashboard, or gamification claim.
- No Modern Table change.

## 9. Baseline residue note

The known `campaign_spine_structure_contract_test.dart` World2 contrast-beat
baseline residue was not touched and is not part of this admission goal pack.

## 10. Tests / guards

Local verification for this unpushed Part B slice:

```bash
flutter test test/guards/w11_volume_i_admission_policy_contract_test.dart
flutter test test/guards/w11_volume_i_admission_policy_contract_test.dart test/guards/w10_to_w11_transition_policy_contract_test.dart test/guards/w11_route_backed_proof_contract_test.dart test/guards/w11_route_admission_runtime_contract_test.dart test/guards/w11_projection_adapter_contract_test.dart test/guards/w11_campaign_fixture_contract_test.dart test/guards/foundation_campaign_rep_contract_v1_test.dart test/guards/w11_active_source_draft_contract_test.dart
dart run tools/term_coverage_scanner.dart
graphify hook-check
flutter analyze
dart format --set-exit-if-changed lib/campaign/w11_volume_i_admission_policy_v1.dart test/guards/w11_volume_i_admission_policy_contract_test.dart
git diff --check
git status --short
```

What the new guard proves:

- W11 is planned-visible only through the existing Learn horizon.
- W11 active entry, W10 handoff, and runtime consumption are disabled.
- W12 remains planned-only and W13 remains frontier-only.
- The Learn surface does not claim W13 unlock, Volume I completion, or premium
  preview access.

What it intentionally does not prove:

- a runnable W11 learner entry;
- W10 terminal handoff into W11;
- screenshot proof;
- W12 or W13 admission.

## 11. Next recommended wave

`W11 Route Surface Proof v1`

Reason: W11 is now admitted only as planned/proof-backed continuation. The next
safe step is to prove the learner-visible surface state and screenshot/widget
evidence before any active entry or handoff work.
