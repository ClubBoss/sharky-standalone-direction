# Durable Repair Persistence and Repeated Candidate Lifecycle v1

## 1. Verdict

durable_repair_persistence_lifecycle_landed_existing_owner

## 2. Context router usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Used lane: `durable_repair`.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Read `CURRENT_STATE_CAPSULE_v1.md`, `DURABLE_REPAIR_CAPSULE_v1.md`, and the five latest durable artifacts named by the prompt.
- Used exact seam search before opening Act0 source/test slices.

## 3. Files inspected

- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `test/ui_v2/act0_learning_evidence_contract_v1_test.dart`
- `test/ui_v2/act0_concept_family_repair_memory_v1_test.dart`

## 4. Persistence owner decision

- Existing owner is safe: `_Act0PersistedProgressV1` already stores and restores `Act0LearningEvidenceHistoryV1`.
- No new storage schema, server persistence, route owner, Profile mirror, Review mirror, or telemetry owner was added.
- Lifecycle is derived from local persisted learning evidence already owned by the Act0 preview shell.

## 5. Lifecycle model

- Added Session Summary lifecycle states:
  - `no_signal_v1`
  - `new_focus_v1`
  - `still_active_v1`
  - `repeated_miss_v1`
  - `quiet_after_correct_v1`
- `new_focus_v1`: latest run contains the first allowlisted active miss.
- `still_active_v1`: older persisted evidence still contains an active allowlisted candidate not cleared by the latest run.
- `repeated_miss_v1`: latest run misses the same allowlisted concept again.
- `quiet_after_correct_v1`: latest same-concept evidence is correct; no learner-facing clearing copy is rendered.

## 6. Lifecycle copy policy

- New focus: `Suggested focus: Action reads. Worth practicing next.`
- Still active: `Still worth practicing: Action reads.`
- Repeated miss: `You missed this again: Action reads.`
- Quiet after correct: no visible copy, to avoid implying fixed/mastered.
- No raw ids, AI, GTO, solver, leak, fixed, mastered, guarantee, or perfect-next-step copy.

## 7. Implementation summary if any

- Added lifecycle constants and `repairLifecycleState` to `Act0SessionSummaryEvidenceViewModelV1`.
- Derived lifecycle copy from `Act0ConceptFamilyRepairMemoryV1` plus latest-run records.
- Kept Practice CTA mapping unchanged; launch request still appears only for safe allowlisted active candidates.
- Updated current and durable capsules with compact landed-state lines.

## 8. Tests

- Red test run failed on missing lifecycle constants/model field.
- Added tests for still-active persisted candidate copy.
- Added tests for repeated miss copy and forbidden-copy absence.
- Extended same-concept correct coverage to assert quiet state, no CTA request, and no clearing copy.
- Existing concept memory tests cover unrelated correct evidence not clearing an active candidate.

## 9. Validation

- Focused lifecycle test: passed.
- Focused durable suite passed: 54 tests.
- `flutter analyze`: passed, no issues found.
- `git diff --check`: passed.
- `git diff --cached --check`: passed before staging.
- `graphify hook-check`: passed with exit 0.
- Artifact checks: 104 lines, ASCII-only, no trailing whitespace, LF-only, final newline present.

## 10. Score impact

- W1-W12 remains `8.3/10`.
- Overall top-1 may move +0.1 max as architecture/UX clarity only.
- No Human QA, 9.0, launch, monetization, or measured learning-effect claim becomes safe.

## 11. Route impact

- No new route, screen, navigation architecture, Practice redesign, queue mutation policy, Review/Profile admission, telemetry expansion, or persistence architecture.

## 12. Claim safety

- Lifecycle copy is evidence-backed and local.
- Quiet-after-correct is modeled but not rendered as positive clearing copy.
- No mastery, fixed, leak solved, AI, solver, GTO, guarantee, Human QA, or cross-session transfer proof claim was added.

## 13. Deferred v2 items

- Broader lifecycle surfacing outside Session Summary.
- Additional allowlisted concepts after source ownership is explicit.
- Repeated-candidate aging policy if future evidence supports it.
- Review/Profile mirrors only if separately admitted.

## 14. Token budget result

- Stayed under the 35k target and far below the 55k hard stop.

## 15. Next recommendation

Run a bounded allowlist-expansion or aging-policy decision wave only after the current lifecycle copy has enough real learner evidence; keep Human QA and score claims separate.
