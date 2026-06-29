# Durable Repair Candidate Resolution Contract v1

## 1. Verdict

durable_repair_candidate_resolution_contract_landed_engine_only

## 2. Context Router Usage

- Router read: `docs/context/CONTEXT_ROUTER_v1.md`.
- Lane used: `durable_repair`.
- Capsule reads stayed within lane: token budget protocol, current state capsule,
  durable repair capsule, and latest durable repair artifacts only.
- No W1-W6 ledgers, product docs, fixtures, runtime screenshots, output folders,
  W7-W12, or broad history were opened.

## 3. Files Changed

- `lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart`
- `test/ui_v2/act0_concept_family_repair_memory_v1_test.dart`
- `test/ui_v2/act0_learning_evidence_contract_v1_test.dart`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/durable_repair_candidate_resolution_contract_v1.md`

## 4. Existing Behavior Found

- Concept-family repair memory grouped evidence by `repairFocusId`, then
  `skillAtomId`, then `errorType`.
- Candidate selection admitted any family with historical incorrect evidence.
- Session Summary displayed `Recommended repair: <safe label>.` from the chosen
  candidate.

## 5. Resolution Rule Selected

- A family is active only when its latest relevant same-family evidence is
  incorrect.
- A family is cleared when it has historical incorrect evidence but its latest
  same-family evidence is correct.
- A correct record for another concept family does not clear the active family.

## 6. Active/Clear Contract

- Active state: `active_latest_incorrect_v1`.
- Cleared state: `cleared_latest_correct_v1`.
- No-miss state: `no_miss_v1`.
- `nextRepairCandidate` now filters to active summaries only.

## 7. Repeated Miss Handling

- Repeated same-family misses stay active while the latest same-family record is
  incorrect.
- Repeated misses keep `selectionReasonCode: repeated_incorrect_family`.
- A later correct same-family record clears the repeated candidate.

## 8. Mixed Evidence Handling

- Multiple active families still use deterministic ordering: repeated miss
  count, latest incorrect order, then stable concept id.
- Active unrelated misses can outrank older active misses by the existing
  ordering.

## 9. Unrelated Evidence Handling

- Unrelated correct evidence creates or updates only its own family summary.
- It does not clear another family's active candidate.

## 10. Determinism Proof

- Candidate state is derived only from local ordered evidence fields.
- There is no ML, AI, solver, randomness, wall-clock dependency, or route state.
- Stable id tie-break coverage was added for equal active scores.

## 11. Session Summary Impact

- Same surface, same copy contract.
- The existing Session Summary recommendation disappears after same-family
  correct evidence.
- No new screen, route, navigation, or UI layout was added.

## 12. Tests

- Added engine coverage for same-family clear, unrelated correct isolation,
  repeated miss clear, and stable active tie-break.
- Added Session Summary adapter coverage for clearing the recommendation after
  same-family correct evidence.

## 13. Claim Safety

- The implementation keeps safe copy only: `Recommended repair: <safe label>.`
- No mastered, leak solved, AI, solver, GTO, Human QA, launch-ready, or durable
  mastery claim was added.

## 14. Route Impact

- No route files changed.
- No Practice queue, Review admission, Profile mirror, or new personalization
  route was opened.

## 15. Score Impact

- No readiness score changed.
- This is a bounded deterministic contract improvement, not Human QA or launch
  evidence.

## 16. Deferred v2 Items

- Durable persistence expansion.
- Repair queue admission.
- Review/Profile ownership.
- Learner-facing reason expansion beyond Session Summary.

## 17. Token Budget Result

- Target: under 35k tokens.
- Result: stayed within target.

## 18. Next Recommendation

Commit this bounded engine-only contract, then keep the next durable wave
focused on one admitted owner only: persistence, queue admission, or Review/Profile.
