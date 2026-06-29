# Durable Repair Candidate Surface Admission v1

## 1. Verdict

Verdict: `durable_repair_candidate_surface_landed_session_summary`

## 2. Context router usage

Lane: `durable_repair`.

Read: `AGENTS.md`, context router, token budget protocol, current capsule,
durable repair capsule, and latest durable repair artifact only. Searched exact
surface seams before reading files.

Did not read old W1-W6 artifacts, ledgers, screenshots, output folders, or
W7-W12.

## 3. Files inspected

- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_review_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart`
- `lib/ui_v2/act0_shell/act0_profile_shell_v1.dart`
- focused tests for Session Summary, learning evidence, and repair memory.

## 4. Surface ownership matrix

| Surface | Existing owner | Admission decision |
| --- | --- | --- |
| Session Summary | `Act0SessionSummaryEvidenceViewModelV1` over learning evidence | Selected. Already owns current run proof and compact safe evidence copy. |
| Review | Active repair and read-only mistake history | Deferred. More likely to imply review queue/state ownership. |
| Practice | Repair queue projection and launchability | Deferred. Candidate exposure could imply queue mutation or launch target. |
| Profile | Evidence mirror and earned moments | Deferred. Profile should not become a repair-state owner. |

## 5. Selected surface or deferral

Selected: Session Summary.

Reason: it already receives `Act0LearningEvidenceHistoryV1`, renders a compact
evidence card, and has route-neutral tests. No new screen, navigation, route, or
Practice queue behavior was needed.

## 6. Copy-safety review

Admitted copy: `Recommended repair: <safe label>.`

Forbidden copy remains blocked: AI, GTO, solver, leak, mastered, guaranteed,
perfect next step, launch-ready, Human-QA-proven.

Unsafe labels suppress the candidate line rather than rendering raw ids or
overclaiming.

## 7. Implementation summary

- `Act0SessionSummaryEvidenceViewModelV1` now has `repairCandidateLine`.
- `fromHistory` reuses `Act0ConceptFamilyRepairMemoryV1.nextRepairCandidate`.
- The existing Session Summary evidence card renders the line when safe.
- No telemetry, persistence, route, navigation, content, or queue semantics
  changed.

## 8. Tests

Focused tests cover:

- model candidate copy from existing learning evidence;
- claim-safe suppression for unsafe labels;
- existing Session Summary rendering of the candidate line;
- route-neutral callbacks and existing repair-memory behavior.

## 9. Route impact

No route impact. Act0 remains the canonical runtime surface.

## 10. Claim safety

Safe claim: bounded Session Summary repair recommendation from deterministic
local evidence.

Unsafe claims remain closed: Human QA proof, mastery, launch readiness, AI/ML,
solver advice, GTO, leak detection, or guaranteed improvement.

## 11. Score impact

W1-W12 remains `8.3`. Overall top-1 may move `6.7 -> 6.8` max because a tested
existing-surface exposure landed.

## 12. Deferred v2 items

- Review admission for read-only candidate context.
- Practice queue admission only if launch/queue ownership is clarified.
- Profile mirror admission only after a non-owner proof contract.
- Candidate resolution/clear policy.
- Durable persistence expansion beyond existing evidence history.

## 13. Token budget result

Stayed under the focused implementation target; no scope split needed.

## 14. Next recommendation

Run a bounded candidate-resolution contract wave before adding Review or
Practice queue behavior.
