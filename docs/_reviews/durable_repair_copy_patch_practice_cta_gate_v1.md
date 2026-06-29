# Durable Repair Copy Patch + Practice CTA Gate v1

## 1. Verdict

durable_repair_copy_patch_landed_cta_deferred

## 2. Context router usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Used lane: `durable_repair`.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Read `CURRENT_STATE_CAPSULE_v1.md`, `DURABLE_REPAIR_CAPSULE_v1.md`, and the latest admitted durable repair artifacts only.
- Used exact seam search before reading Act0 files.

## 3. Files changed

- `lib/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart`
- `test/ui_v2/act0_learning_evidence_contract_v1_test.dart`
- `test/ui_v2/act0_session_summary_earned_moment_v1_test.dart`
- `test/ui_v2/wave4_3_premium_reward_session_summary_payoff_v1_test.dart`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/durable_repair_copy_patch_practice_cta_gate_v1.md`

## 4. Claude red-team findings addressed

- Recommendation now has evidence-backed causality when a current incorrect run supplies an allowlisted concept.
- Dead-end action issue is acknowledged; CTA remains deferred because Session Summary has no safe existing Practice action seam.
- Raw/internal labels are blocked by an explicit display allowlist.
- `Recommended repair` wording was removed from learner-facing Session Summary copy.
- Repeated-candidate lifecycle remains deferred.

## 5. Copy before/after

- Before: `Main repair focus: <label>.`
- Before: `Recommended repair: <label>.`
- After: `You missed Action reads recently.`
- After: `Suggested focus: Action reads. Worth practicing next.`

## 6. Human-readable label policy

- Display labels come from an explicit local allowlist only.
- Current allowlist maps `no_bet_yet`, `action_read`, and `missed_action_read` to `Action reads`.
- Raw ids and caller-supplied labels are not rendered in Session Summary repair focus/candidate copy.
- Unknown concept candidates stay silent instead of falling back to unsafe copy.

## 7. Causality evidence policy

- `You missed... recently.` appears only when latest-run evidence has at least one incorrect item and an allowlisted repair focus.
- `Suggested focus... Worth practicing next.` appears only when the concept-family repair memory returns an allowlisted active candidate.
- No AI, GTO, solver, leak, mastery, guarantee, fixed-status, or completion claim is introduced.

## 8. Mapper consumption decision

- Mapper output was not consumed by Session Summary UI in this wave.
- Existing mapper tests continue to prove allowlisted target and no-target behavior.
- Consumption would require a safe Session Summary action seam; that seam is not present.

## 9. CTA landed or deferred

- Deferred.
- `Act0BlockCompletionShellV1` exposes continue, replay, review, and back-to-map callbacks.
- Practice launch callback exists in `Act0PlayShellV1`, not the Session Summary surface.
- Adding Session Summary Practice launch wiring would be route/action architecture work outside this wave.

## 10. Tests

- `flutter test test/ui_v2/act0_learning_evidence_contract_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/ui_v2/act0_concept_candidate_practice_mapper_v1_test.dart test/ui_v2/wave4_3_premium_reward_session_summary_payoff_v1_test.dart`
- Result: passed, 44 tests.

## 11. Validation

- `dart format` on touched Dart files: passed, 0 changed after format.
- `flutter analyze`: passed, no issues found.
- `git diff --check`: passed.
- `git diff --cached --check`: passed before staging.
- `graphify hook-check`: passed with exit 0.
- Artifact checks: 102 lines, ASCII-only, no trailing whitespace, LF-only, final newline present.

## 12. Score impact

- W1-W12 remains `8.3/10`.
- Overall top-1 remains unchanged because CTA was deferred and no Human QA / durable learner proof was added.

## 13. Route impact

- No new route, screen, navigation, Practice queue redesign, or queue mutation policy.
- Session Summary remains route-neutral.

## 14. Deferred v2 items

- Add a bounded Session Summary Practice CTA only after an explicit safe action owner is admitted.
- Define repeated-candidate lifecycle copy if repeated exposure becomes learner-facing.
- Broaden display labels only through explicit allowlist additions with tests.

## 15. Token budget result

- Stayed under the 35k target and far below the 55k hard stop.

## 16. Next recommendation

Run a bounded Session Summary Practice CTA action-owner wave, or keep the next durable repair wave focused on persistence/lifecycle proof before UI admission.
