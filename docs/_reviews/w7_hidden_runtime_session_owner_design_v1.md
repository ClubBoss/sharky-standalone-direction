# W7 Hidden Runtime Session Owner Design v1

## 1. Verdict
`w7_hidden_runtime_session_owner_design_landed`

Design-only. No runtime, route, UI, fixture, mapper, queue, telemetry, or
Practice CTA change was made.

## 2. Stage 0 sync result
- Synced accepted commit `1c1ef8bd` into `main`.
- Created sync artifact:
  `docs/_reviews/repo_integration_w7_route_runtime_owner_decision_v18.md`.
- Stage 0 commit: `58cba0e7`.
- Push result: `main` pushed normally to `origin/main`.
- Main after Stage 0: `58cba0e711663d8734e564049d63fcb023050ada`.

## 3. Context router usage
- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Stage 0 used `repo_hygiene`; Stage 1 used exact W7 design context.
- Read current capsule, durable repair capsule, accepted W7 fixture/evidence
  artifacts, blocker artifact, and targeted completed-decision/evidence seams.
- No broad W1-W6, W8-W12, W13+, screenshots, output, store, monetization, or
  Human QA execution reads.

## 4. Files inspected
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/w7_visible_ace_single_task_runtime_slice_v1.md`
- `docs/_reviews/w7_visible_ace_evidence_consumption_audit_v1.md`
- `docs/_reviews/w7_route_runtime_owner_tiny_playable_admission_v1.md`
- `docs/_reviews/repo_integration_w7_route_runtime_owner_decision_v18.md`
- `test/fixtures/content_factory_mvp/w7_visible_ace_combo_reduction_intro_v1.json`
- `test/tools/w7_visible_ace_single_task_runtime_slice_v1_test.dart`
- `test/guards/w7_w10_route_status_alignment_contract_test.dart`
- `lib/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`

## 5. Runtime owner blocker recap
The source-owned task `visible_ace_combo_reduction_intro` is schema-valid and
route-locked, but no admitted owner can host exactly that task and write ordered
local learner evidence. Existing W7 shell metadata/runners are broad locked W7
surfaces, not safe single-task owners.

## 6. Proposed hidden/internal owner
Add future internal owner `Act0W7VisibleAceHiddenRuntimeSessionOwnerV1`. It
should expose exactly one hidden session for `visible_ace_combo_reduction_intro`
and only create normalized internal decisions for the existing Act0 evidence
contract.

Implementation should use an app-safe const task spec, not runtime file I/O
from `test/fixtures`. A guard test must prove the const spec matches
`test/fixtures/content_factory_mvp/w7_visible_ace_combo_reduction_intro_v1.json`.

## 7. Task loading policy
- Allow exactly one world: `world_7`.
- Allow exactly one lesson: `range_thinking_lite_combo_density`.
- Allow exactly one task/source task: `visible_ace_combo_reduction_intro`.
- Require `route_gate_status=authored_but_not_routed` and `preview_only=true`.
- Require `drill_kind=combo_density_visible_card_choice_v1`.
- Require `board_context=A72 rainbow`.
- Require `expected_choice=ace_combos_reduced`.
- Reject any extra tasks, unknown choice ids, missing evidence fields, or copy
  that fails the existing W7 copy-safety guard.

## 8. Evidence write policy
The owner may emit evidence only by constructing `Act0CompletedDecisionV1` and
calling `Act0LearningEvidenceHistoryV1.appendCompletedDecision`. Required
fields:
- `worldId=world_7`
- `lessonId=range_thinking_lite_combo_density`
- `taskId/sourceTaskId=visible_ace_combo_reduction_intro`
- `expectedId=ace_combos_reduced`
- selected choice id from the fixture choices
- `errorType=missed_visible_card_combo_reduction`
- `skillAtomId=w7_combo_density_card_removal`
- `repairFocusId=w7_visible_card_combo_reduction`
- deterministic `decisionTimeBucket`; hidden/internal run key

No parallel evidence store, telemetry expansion, Session Summary claim, Profile
claim, or public learning-effect proof is admitted by this design.

## 9. Route lock/stale-resume policy
The owner must not change W7 card state, selectable state, route availability,
campaign pack progression, `ProgressService` next-pack selection, active pack
ids, or stale-resume storage. Interrupted hidden sessions are discarded unless
a future test harness explicitly passes the same hidden owner token.

## 10. Mapper no-target / Practice CTA policy
Keep `practice_cta_allowed=false` and
`mapper_no_target_reason=w7_route_locked_no_safe_practice_target_v1`. The owner
must not call the concept-candidate mapper, create an
`Act0PracticeRepairQueueLaunchRequestV1`, mutate a Practice queue, or show a
Practice CTA.

## 11. Copy safety
Learner-facing prompt, choices, and feedback must come from the accepted fixture
labels/reasons only. Do not show raw ids. Forbid GTO, solver, optimal, perfect,
mastered, fixed, guaranteed improvement, AI leak, launch, playable, or W7
available claims.

## 12. Future implementation DoD
- One const task spec and one hidden owner only.
- Fixture-match guard proves const spec parity with the JSON source artifact.
- Correct and incorrect selections produce complete completed-decision payloads.
- Evidence append uses only `Act0LearningEvidenceHistoryV1`.
- Route-lock and stale-resume guards remain green.
- Mapper/Practice CTA/queue behavior remains no-target.
- No W7 public route, broad W7 runner, or screen is admitted.

## 13. Required tests
- Const task spec matches the source fixture.
- Owner exposes exactly one task and rejects any other id.
- Correct choice appends a correct evidence record.
- Each incorrect choice appends an incorrect evidence record with the W7 error
  type, skill atom, and repair focus.
- Duplicate attempt key does not duplicate evidence.
- Route-lock guards still prove W7-W12 locked/non-selectable and stale W7-W10
  state is not returned.
- Mapper/Practice CTA remains no-target.
- Copy-safety guard remains green.
- `flutter analyze` for any future Dart implementation.

## 14. Validation
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- ASCII/trailing whitespace/CRLF/final-newline checks on this artifact.
- Flutter analyze/tests were not run because this wave changed docs only.

## 15. Score impact
No W1-W12 score movement. W1-W12 remains `8.3/10`. Top-1 planning confidence
may move `+0.1` at most for reducing the W7 runtime-owner ambiguity, but no
Human QA pass, 9.0, monetization, launch, W7 public opening, playable W7 claim,
or public learning-effect claim becomes safe.

## 16. Next recommendation
Run a bounded implementation wave for
`Act0W7VisibleAceHiddenRuntimeSessionOwnerV1`: const task spec, fixture-parity
test, hidden decision evaluation, evidence append tests, and unchanged
route/mapper/Practice locks.
