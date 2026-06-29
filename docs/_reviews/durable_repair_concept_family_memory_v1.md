# Durable Repair Concept Family Memory v1

## 1. Verdict

Verdict: `durable_repair_concept_family_memory_landed_engine_only`

## 2. Context router usage

Lane: `durable_repair`.

Read: `AGENTS.md`, `docs/context/CONTEXT_ROUTER_v1.md`,
`docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`,
`docs/context/CURRENT_STATE_CAPSULE_v1.md`,
`docs/context/DURABLE_REPAIR_CAPSULE_v1.md`, exact searched seams, and focused
tests.

Did not broad-read W1-W6 artifacts, W7-W12, screenshots, or output folders.

## 3. Files changed

- `lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart`
- `test/ui_v2/act0_concept_family_repair_memory_v1_test.dart`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/durable_repair_concept_family_memory_v1.md`

## 4. Entry points found

- `Act0CompletedDecisionV1`: existing normalized decision signal.
- `Act0LearningEvidenceHistoryV1`: existing evidence history with
  correct/incorrect, error type, repair focus, skill atom, and decision-time
  bucket.
- `Act0ReviewMistakeHistoryV1`: existing unresolved-only Review mistake source.
- Existing Practice/Review/Session Summary consumers were found but not changed.

## 5. Data model

Added pure engine records:

- `Act0ConceptFamilyRepairMemoryV1`
- `Act0ConceptFamilyRepairSummaryV1`
- `Act0ConceptFamilyRepairCandidateV1`

The model aggregates existing evidence only. It does not own telemetry,
persistence, routes, UI, or content.

## 6. Concept-family mapping

Concept family id priority:

1. `repairFocusId`
2. `skillAtomId`
3. `errorType`

No new taxonomy was invented.

## 7. Repair-memory behavior

The memory groups records deterministically, tracks correct count, incorrect
count, latest order, latest incorrect order, latest error type, latest decision
time bucket, and `over_10s` count.

## 8. Repair candidate selection rule

Eligible families must have at least one incorrect record.

Priority:

1. latest family attempt is incorrect;
2. higher incorrect count;
3. more recent incorrect order;
4. stable concept family id.

## 9. UI/surface exposure decision

Engine-only. Existing Review/Practice/Session Summary surfaces were not changed
because exposing a new candidate requires a separate ownership and copy-safety
decision.

## 10. Telemetry/event compatibility

No telemetry event schema changed. The engine consumes existing local evidence
fields and does not add network, vendor, or product-state telemetry.

## 11. Tests

Focused tests cover grouping, fallback mapping, latest-incorrect priority,
repeated-miss priority, deterministic tie behavior, correct-only no-candidate
behavior, and source dependency boundaries.

## 12. Claim safety

Safe claim: deterministic concept-family repair memory and rule-based next
repair candidate.

Unsafe claims remain closed: Human QA proof, mastery, launch readiness, ML/AI,
solver advice, or durable learning-effect proof.

## 13. Route impact

No route change. Act0 remains the canonical runtime surface.

## 14. Score impact

W1-W12 remains `8.3`. Overall top-1 readiness may move from `6.6` to `6.7` at
most because a tested engine-only durable repair slice landed.

## 15. Deferred v2 items

- Persisted candidate owner beyond existing evidence history.
- Safe Review/Practice/Session Summary exposure.
- Exact decision-time milliseconds if a local owner is admitted.
- Resolution/clear policy for repair candidates.

## 16. Token budget result

Stayed in focused implementation mode and did not require scope split.

## 17. Next recommendation

Run a bounded surface-admission wave to decide where, if anywhere, the engine's
next repair candidate should appear without changing route ownership.
