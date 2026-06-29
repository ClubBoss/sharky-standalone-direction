# Durable Repair Session Summary Practice CTA Action Owner v1

## 1. Verdict

durable_repair_session_summary_practice_cta_landed_existing_action_owner

## 2. Context router usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Used lane: `durable_repair`.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Read `CURRENT_STATE_CAPSULE_v1.md`, `DURABLE_REPAIR_CAPSULE_v1.md`, and the two latest durable artifacts named by the prompt.
- Used exact seam search before opening Act0 files.

## 3. Files inspected

- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart`
- `lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart`
- Focused Session Summary, learning evidence, and mapper tests.

## 4. Existing action seam found or not found

- Found an existing owned launch path: `Act0ShellPreviewScreenV1._startPracticeRepairQueueTarget`.
- Found an existing Session Summary action surface: `Act0BlockCompletionShellV1` callback-driven buttons.
- The seam did not previously accept `Act0PracticeRepairQueueLaunchRequestV1`.

## 5. Action-owner decision

- Existing action owner is sufficient.
- Added a minimal optional adapter from Session Summary to the existing preview-shell Practice repair launch owner.
- No new route, screen, queue architecture, persistence, or telemetry owner was created.

## 6. Mapper consumption

- `Act0SessionSummaryEvidenceViewModelV1.fromHistory` consumes the concept-candidate mapper.
- It stores `practiceLaunchRequest` only when safe copy exists and the mapper returns a launchable request.
- Unknown, route-locked, bridge-limited, and unsafe targets remain no-target through mapper policy.

## 7. CTA visibility policy

- CTA text: `Practice this next`.
- CTA appears only when a launchable `Act0PracticeRepairQueueLaunchRequestV1` exists and an action-owner callback is present.
- CTA does not appear for no-target mapper results or missing callback.
- CTA displays no raw schema ids and adds no AI/GTO/solver/mastery/fixed/guarantee copy.

## 8. CTA action behavior

- Tapping the CTA calls the existing launch owner with the mapper request.
- Target remains `world_1/fold_check_call_raise/actions_check_drill`.
- Source remains `actions_legal_context`; repair task remains `actions_check_drill`.
- Existing `_startTaskByIds` clears Session Summary and enters the Play repair path.

## 9. Implementation summary if any

- Added `practiceLaunchRequest` to the Session Summary evidence model.
- Added optional `onLaunchPracticeRepairQueueTarget` callback to `Act0BlockCompletionShellV1`.
- Rendered the CTA in the existing Session Summary evidence card.
- Wired preview shell callback to `_startPracticeRepairQueueTarget`.
- Updated current and durable capsules with compact landed-state lines.

## 10. Tests

- Added model tests for safe mapped request and unknown no-target.
- Added widget tests for CTA visibility, absence without mapped target, and action target.
- Mapper no-target tests remain in the focused validation set.

## 11. Validation

- Red test run failed on missing `practiceLaunchRequest` and action callback.
- Focused green run passed: learning evidence + Session Summary widget tests, 36 tests.
- Focused mapper-inclusive run passed: 43 tests.
- Full focused validation run passed: 46 tests.
- `flutter analyze`: passed, no issues found.
- `git diff --check`: passed.
- `git diff --cached --check`: passed before staging.
- `graphify hook-check`: passed with exit 0.
- Artifact checks: 107 lines, ASCII-only, no trailing whitespace, LF-only, final newline present.

## 12. Score impact

- W1-W12 remains `8.3/10`.
- Overall top-1 may move at most +0.1 as architecture readiness only.
- No Human QA, 9.0, launch, monetization, persistence, or cross-session learning proof claim becomes safe.

## 13. Route impact

- No new route or screen.
- Reuses existing Act0 preview-shell Practice repair launch owner.
- No Practice queue redesign or queue mutation policy change.

## 14. Deferred v2 items

- Durable persistence expansion.
- Repeated-candidate lifecycle copy.
- Additional allowlist entries after explicit source ownership.
- Broader Practice UI admission beyond Session Summary CTA.

## 15. Token budget result

- Stayed under the 35k target and far below the 55k hard stop.

## 16. Next recommendation

Run a bounded durable persistence / repeated-candidate lifecycle wave before expanding repair CTA coverage beyond the current allowlisted target.
