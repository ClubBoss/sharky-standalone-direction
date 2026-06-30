# Durable Repair Learning Transfer Measurement v1

## 1. Verdict

durable_repair_learning_transfer_measurement_landed_engine_only

## 2. Context router usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Used lane: `durable_repair`.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Read `CURRENT_STATE_CAPSULE_v1.md`, `DURABLE_REPAIR_CAPSULE_v1.md`, and the three latest durable/integration artifacts named by the prompt.
- Used exact Act0 durable-repair seam search before opening source slices.

## 3. Files inspected

- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart`
- Focused learning-evidence and concept-memory tests.

## 4. Evidence available

- `Act0LearningEvidenceHistoryV1` stores local ordered decision records.
- Records include correctness, `repairFocusId`, `skillAtomId`, `errorType`, and `createdOrder`.
- Existing concept-family repair memory already defines the same-family fallback order.

## 5. Evidence missing

- No deterministic evidence proves the learner acted on the Practice CTA.
- No causal practice-transfer, Human QA, public learning-effect, mastery, or durable learner-proof claim is safe.
- Bridge, route-locked, or unmapped records cannot create a positive transfer claim.

## 6. Transfer model

- Added `Act0RepairTransferProjectionV1`.
- States: `no_prior_miss_v1`, `miss_still_active_v1`, `later_correct_signal_v1`, `insufficient_ordering_v1`, `unmapped_concept_v1`, `unsafe_evidence_v1`.
- The positive state means only same-concept miss-to-later-correct evidence.

## 7. Ordering policy

- Uses `createdOrder`.
- Negative order marks the concept `insufficient_ordering_v1`.
- A correct record must occur after the latest same-concept miss.
- A correct record before the latest miss does not count.

## 8. Same-concept policy

- Concept id fallback: `repairFocusId`, then `skillAtomId`, then `errorType`.
- The fallback matches the existing concept-family repair memory policy.
- Blank and `none` concept ids do not create signals.

## 9. Unrelated-evidence policy

- Correct evidence from a different concept family cannot clear or improve a missed concept.
- Unknown lookup returns `unmapped_concept_v1`.

## 10. Implementation summary if any

- Added pure engine projection in `act0_repair_transfer_projection_v1.dart`.
- Added focused tests for same-concept later correct, unrelated no-count, insufficient ordering, ordering, deterministic sort, unmapped lookup, and claim-safe source guard.
- Updated current and durable capsules with compact landed-state lines.

## 11. Tests

- Red run failed on missing projection API and constants.
- Focused green run passed: 7 transfer projection tests.

## 12. Validation

- Focused transfer projection tests: passed.
- Broader focused durable tests, format, analyze, diff checks, graphify, and artifact checks are reported in the final Codex summary.

## 13. Score impact

- W1-W12 remains `8.3/10`.
- No launch, Human QA, 9.0, monetization, public learning-effect, or mastery score movement.

## 14. Claim safety

- Internal wording only: local same-concept miss-to-later-correct signal.
- Does not say mastered, fixed, leak fixed, guaranteed, proven, AI, GTO, solver, or practice-caused transfer.

## 15. Deferred v2 items

- Practice-action evidence if a future owner records safe action completion.
- Learner-facing display owner and copy review.
- Route-locked and bridge-limited evidence policy if future routes reopen.

## 16. Token budget result

- Stayed under the 35k target and far below the 55k hard stop.

## 17. Next recommendation

Run a bounded display-owner decision wave only after the product can distinguish local later-correct evidence from practice-causal learning claims.
