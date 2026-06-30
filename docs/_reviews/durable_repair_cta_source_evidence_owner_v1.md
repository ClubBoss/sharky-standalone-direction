# Durable Repair CTA Source Evidence Owner v1

## 1. Verdict

durable_repair_cta_source_evidence_owner_landed

## 2. Context router usage

- Router: `docs/context/CONTEXT_ROUTER_v1.md`.
- Lane: `durable_repair`.
- Capsules: `CURRENT_STATE_CAPSULE_v1.md`, `DURABLE_REPAIR_CAPSULE_v1.md`, and token protocol.
- Scope stayed inside durable repair source attribution and local proof.

## 3. Files inspected

- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- Latest durable repair artifacts for Session Summary CTA, transfer measurement, and practice-action join.
- Bounded Act0 durable repair source/test files touched by this wave.

## 4. Existing source evidence available/missing

- Available: `Act0EvidenceRunKeyV1.startedBy` already exists at run start.
- Available: `_startLearningEvidenceRunV1` already accepts `evidenceStartedBy`.
- Available: completed decision append already receives the active run key.
- Missing before this wave: `Act0LearningEvidenceRecordV1` did not persist `startedBy`.
- Missing before this wave: `practice_repair_queue` was a generic repair launch source, not Session Summary CTA proof.

## 5. Source owner decision

- Owner: existing local learning evidence record payload.
- Persist the existing run-key `startedBy` as optional local evidence.
- Tag only Session Summary Practice CTA launch as `session_summary_practice_cta`.
- Treat non-empty non-CTA repair sources as other repair source.
- Treat missing source on old records as source unavailable.

## 6. Implementation summary if any

- Added optional `startedBy` to `Act0LearningEvidenceRecordV1` parse, payload, equality, and hash.
- Updated Practice repair queue launch owner to accept an explicit evidence source.
- Passed `session_summary_practice_cta` only from Session Summary CTA callback.
- Added source-specific practice-action join states and source field.
- Updated focused contract tests for persistence, source split, and shell launch owner.

## 7. Ordering policy

- Ordering remains `createdOrder`.
- Source attribution does not replace the existing before/after later-correct ordering gate.
- Old records without source remain ordered evidence with unavailable source.

## 8. Join/transfer impact

- Transfer projection remains unchanged.
- Practice-action join can now distinguish Session Summary CTA source from other repair and unknown source.
- Later-correct evidence remains evidence sequencing, not a practice-causal claim.

## 9. Claim safety

- No learner-facing copy was added.
- No mastery, fixed, Human QA, 9.0, or launch-ready claim was added.
- The new states are engine/test evidence only.

## 10. Tests

- `flutter test test/ui_v2/act0_learning_evidence_contract_v1_test.dart test/ui_v2/act0_practice_action_transfer_join_projection_v1_test.dart test/ui_v2/act0_repair_outcome_contract_v1_test.dart` passed.

## 11. Validation

- `dart format` on touched Dart files passed.
- `flutter analyze` passed.
- `git diff --check` passed.
- `git diff --cached --check` passed before staging.
- `graphify hook-check` passed.
- Artifact ASCII, trailing whitespace, CRLF, and final-newline checks passed.

## 12. Score impact

- No score movement.
- W1-W12 remains `8.3/10`.

## 13. Route impact

- No new route, screen, Practice redesign, queue architecture, or learner-facing display.
- Existing Act0 preview-shell launch owner remains the only launch owner used here.

## 14. Deferred v2 items

- Decide if any future learner-facing proof surface may display source-specific evidence.
- Decide if additional repair entry points need named source constants.

## 15. Token budget result

- Stayed under the 35k target.

## 16. Next recommendation

- Keep source-specific join evidence engine-only until a bounded display-owner wave separates sequencing evidence from any learner-facing claim.
