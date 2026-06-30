# Durable Repair Practice Action Evidence Join v1

## 1. Verdict

durable_repair_practice_action_evidence_join_landed_engine_only

## 2. Context router usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Used lane: `durable_repair`.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Read `CURRENT_STATE_CAPSULE_v1.md`, `DURABLE_REPAIR_CAPSULE_v1.md`, and the four latest durable/integration artifacts named by the prompt.
- Used exact Act0 durable-repair seam search before opening source/test slices.

## 3. Files inspected

- `lib/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- Focused transfer, learning-evidence, and repair-outcome tests.

## 4. Practice action evidence available

- Existing Practice repair launch path starts an evidence run with `runKind: repair`.
- Completed repair-run decisions are stored in `Act0LearningEvidenceHistoryV1`.
- Those records already carry `createdOrder`, correctness, `repairFocusId`, `skillAtomId`, `errorType`, target task id, and run identity.

## 5. Practice action evidence missing

- `startedBy` is not stored on each evidence record, so the join cannot prove the exact CTA source after persistence.
- No deterministic field proves causal practice transfer, mastery, Human QA, or public learning-effect proof.
- Launch without any completed repair-run decision remains insufficient attempt evidence.

## 6. Join model

- Added `Act0PracticeActionTransferJoinProjectionV1`.
- States: `later_correct_without_practice_evidence_v1`, `practice_attempt_before_later_correct_v1`, `practice_attempt_after_later_correct_v1`, `practice_evidence_unordered_v1`, `unrelated_practice_target_v1`, `insufficient_evidence_v1`, `unsafe_evidence_v1`.
- The positive joined state means only ordered same-concept repair-run evidence before a later correct signal.

## 7. Ordering policy

- Uses `createdOrder`.
- Repair evidence may be the latest same-concept miss and still count as an attempt before later correct.
- Repair evidence after later correct is not prior evidence.
- Negative repair evidence order is `practice_evidence_unordered_v1`.

## 8. Same-concept / target policy

- Concept fallback matches transfer memory: `repairFocusId`, then `skillAtomId`, then `errorType`.
- Only `runKind: repair` records count as local practice-action evidence.
- Different concept repair records return `unrelated_practice_target_v1`.

## 9. Implementation summary if any

- Added pure engine join projection in `act0_practice_action_transfer_join_projection_v1.dart`.
- Added focused tests for no practice evidence, before/after later-correct ordering, unrelated target, insufficient evidence, unordered evidence, unknown concept, and claim-safe source guard.
- Updated current and durable capsules with compact landed-state lines.

## 10. Tests

- Red run failed on missing join projection API and constants.
- Focused green run passed: 8 join projection tests.

## 11. Validation

- Focused join projection tests: passed.
- Broader focused durable tests, format, analyze, diff checks, graphify, and artifact checks are reported in the final Codex summary.

## 12. Score impact

- W1-W12 remains `8.3/10`.
- Overall top-1 may move +0.1 max as internal evidence architecture only.
- No Human QA, 9.0, launch, monetization, public learning-effect, or mastery claim becomes safe.

## 13. Claim safety

- Internal wording only: repair-run evidence before later correct.
- Does not say practice caused improvement, proven improvement, fixed, mastered, leak fixed, AI, GTO, solver, or guaranteed improvement.

## 14. Route impact

- No learner-facing display, Review/Profile mirror, dashboard, route, screen, navigation change, Practice redesign, queue mutation, telemetry, server analytics, screenshots, or output changes.

## 15. Deferred v2 items

- Persist `startedBy` or explicit launch-intent evidence only if a future owner admits the storage contract.
- Add learner-facing display only after copy and claim-owner review.
- Keep causal learning-effect proof separate from local evidence joins.

## 16. Token budget result

- Stayed under the 35k target and far below the 55k hard stop.

## 17. Next recommendation

Run a bounded evidence-owner decision for storing explicit CTA launch intent only if the product needs to separate Session Summary CTA launches from other repair runs.
