# W7 Hidden Evidence Consumption + Internal Harness v1

## 1. Verdict

`w7_hidden_evidence_consumption_internal_harness_landed`

Stage 1 consumption proof passed after a local projection compatibility fix.
Stage 2 hidden/internal harness landed for exactly one W7 task.

## 2. Stage 0 sync result

- Synced `5839abdb` into `main`.
- Added v20 sync artifact:
  `docs/_reviews/repo_integration_w7_hidden_runtime_owner_implementation_v20.md`.
- Stage 0 pushed `main` normally to `origin/main`.
- Final pushed `main` after metadata correction:
  `d922470a915cc1773cfa369b61167fa9be08d0de`.

## 3. Context router usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Stage 0 used `repo_hygiene`.
- Stage 1/2 used exact current, durable repair, W7 design/implementation,
  v20 sync, hidden owner, evidence, projection, route-lock, and mapper seams.
- Did not broad-read W1-W6 artifacts, W8-W12, W13+, screenshots, output
  folders, generated assets, store, monetization, or old visual docs.

## 4. Files inspected

- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/w7_hidden_runtime_session_owner_design_v1.md`
- `docs/_reviews/w7_hidden_runtime_session_owner_implementation_v1.md`
- `docs/_reviews/repo_integration_w7_hidden_runtime_owner_implementation_v20.md`
- `lib/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- Exact repair memory, repair transfer, practice-action join, route-lock, and
  mapper test/source seams found by search.

## 5. Files changed

- `lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_practice_action_transfer_join_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_w7_visible_ace_hidden_evidence_harness_v1.dart`
- `test/ui_v2/act0_w7_hidden_evidence_consumption_internal_harness_v1_test.dart`
- `docs/_reviews/w7_hidden_evidence_consumption_internal_harness_v1.md`

## 6. Hidden evidence source

Evidence source is `Act0W7VisibleAceHiddenRuntimeSessionOwnerV1`, supporting
only `world_7`, `range_thinking_lite_combo_density`, and
`visible_ace_combo_reduction_intro`. It appends through
`Act0LearningEvidenceHistoryV1.appendCompletedDecision`.

## 7. Stage 1 projection consumption decision

Landed. Hidden W7 evidence is consumable by concept-family repair memory,
repair transfer projection, and practice-action transfer join projection.

## 8. Stage 2 harness decision

Landed. Added `Act0W7VisibleAceHiddenEvidenceHarnessV1`, a tiny internal seam
that validates the one supported task and delegates choice submission to the
hidden owner. It renders no UI and has no route, mapper, or queue dependency.

## 9. Concept-family / repair-focus handling

Projection key helpers now prefer `record.conceptFamilyId` when present, then
fall back to existing `repairFocusId`, `skillAtomId`, and error-type behavior.
This preserves legacy evidence compatibility while allowing W7 hidden evidence
to group under `w7_combo_density_visible_card_removal`.

## 10. Later-correct / still-active behavior

Incorrect W7 hidden evidence produces an active local repair candidate and
`miss_still_active_v1`. Later correct W7 hidden evidence clears the candidate
and produces `later_correct_signal_v1`; the practice-action join remains
non-causal as `later_correct_without_practice_evidence_v1`.

## 11. Session Summary / Practice CTA safety

No Session Summary CTA was added. The harness exposes no Practice launch
request, does not call the mapper, and does not mutate a Practice queue. Mapper
tests still prove W7 route-locked targets return no-target.

## 12. Route/stale-resume lock proof

Focused guards still prove W7-W12 cards are locked/non-selectable, W7-W10 are
not promoted after W6 completion, stale W7-W10 active pack state is not returned
to the learner route, and World 7 routing remains blocked.

## 13. Tests

- Red: Stage 1 test failed because projections grouped W7 evidence by repair
  focus instead of `conceptFamilyId`.
- Red: Stage 2 test failed because the internal harness did not exist.
- `flutter test test/ui_v2/act0_w7_hidden_evidence_consumption_internal_harness_v1_test.dart`
- `flutter test test/ui_v2/act0_w7_visible_ace_hidden_runtime_session_owner_v1_test.dart`
- `flutter test test/tools/w7_visible_ace_single_task_runtime_slice_v1_test.dart`
- `flutter test test/ui_v2/act0_concept_family_repair_memory_v1_test.dart`
- `flutter test test/ui_v2/act0_practice_action_transfer_join_projection_v1_test.dart`
- `flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart`
- `flutter test test/guards/world7_campaign_routing_contract_test.dart`
- `flutter test test/ui_v2/act0_concept_candidate_practice_mapper_v1_test.dart`

## 14. Validation

- `dart format` on touched Dart files.
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- ASCII/trailing whitespace/CRLF/final-newline checks on this artifact.
- Screenshot pipeline was not run.

## 15. Score impact

Stage 0 sync: no score movement. Stage 1+2 hidden proof/harness may move
overall top-1 planning confidence `+0.1` max. W1-W12 remains `8.3/10`. No
Human QA pass, 9.0, monetization, launch, W7 public/playable opening, or public
learning-effect claim becomes safe.

## 16. Forbidden scope proof

No W7 route opening, public/playable admission, broad W7 shell, screen,
navigation, W7 unlock, W7 promotion after W6, stale resume into W7, Practice
CTA, mapper allowlist, queue mutation, telemetry expansion, fixture expansion,
second W7 task, W8-W12, W13+, W1-W6 rework, screenshots, output changes,
generated assets, monetization, Human QA execution, ML/AI/persona, or solver
claim.

## 17. Token budget result

Combined work stayed under the 55k target; no scope split needed.

## 18. Next recommendation

Run a bounded route-admission decision only if needed. Keep W7 hidden/internal
until a separate wave explicitly proves route, stale-resume, mapper, and copy
safety for public admission.
