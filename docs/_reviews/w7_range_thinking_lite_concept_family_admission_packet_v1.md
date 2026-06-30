# W7 Range Thinking Lite Concept-Family Admission Packet v1

## 1. Verdict

w7_range_thinking_lite_admission_packet_landed

## 2. Context router usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Used durable repair lane plus targeted W7 / Volume I SSOT slices.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Read current capsule, durable repair capsule, and W7-W12 admission plan.
- Searched exact W7/combo-density terms before opening SSOT slices.

## 3. Selected W7 concept family

- Family: one-visible-card combo reduction.
- Concept-family id: `w7_combo_density_visible_card_removal`.
- Learner idea: a visible card reduces how many private-card combinations remain for that rank.
- Scope: one narrow card-removal read only.
- Not included: paired boards, suited blockers, bluff blockers, exhaustive combo counting, solver ranges, or broad range theory.

## 4. Proposed world/module/task ids

- `world_id`: `world_7`
- `lesson_id`: `range_thinking_lite_combo_density`
- `task_id`: `visible_ace_combo_reduction_intro`
- `source_task_id`: `visible_ace_combo_reduction_intro`
- Future module label: `Range Thinking Lite`
- Route state: locked/non-routed until a later implementation wave passes admission tests.

## 5. Proposed repair/evidence ids

- `repair_focus_id`: `w7_visible_card_combo_reduction`
- `skill_atom_id`: `w7_combo_density_card_removal`
- `error_type`: `missed_visible_card_combo_reduction`
- Safe label: `Combo density`
- Safe focus copy: `Visible cards change what hands are possible.`

## 6. Learner decision

- Prompt shape: a board or exposed/public card contains one ace.
- Decision: choose whether ace-heavy private hand combinations are unchanged or reduced.
- Correct choice: visible ace reduces remaining ace-combo density.
- Incorrect choice A: visible ace does not change combo density.
- Incorrect choice B: visible ace increases ace-combo density.
- Incorrect choice C: visible ace proves opponent cannot hold any ace.

## 7. Expected and incorrect choices

- `expected_choice`: `ace_combos_reduced`
- Incorrect: `ace_combos_unchanged`
- Incorrect: `ace_combos_increased`
- Incorrect: `ace_combos_impossible`
- Feedback policy: explain card removal in plain language; do not mention optimal play, solver output, or exact strategy charts.

## 8. Evidence contract

- Required fields:
  - `world_id`
  - `lesson_id`
  - `task_id`
  - `source_task_id`
  - `user_choice`
  - `expected_choice`
  - `correct`
  - `error_type`
  - `skill_atom_id`
  - `repair_focus_id`
  - `time_to_decision`
  - ordered local evidence record
- Evidence must be same-concept matchable without screen text.
- Evidence must support old/missing-field parse safety.

## 9. Mapper policy

- Initial mapper state: explicit no-target.
- No-target reason: `w7_route_locked_no_safe_practice_target_v1`.
- Rationale: no W7 Practice target is admitted in this wave.
- Future mapping may be admitted only after a W7 task owner exists with source-owned repair target, stable ids, and no unrelated concept launch.
- Practice CTA must not appear from this family before that mapping wave.

## 10. Lifecycle policy

- New miss may create an active concept-family candidate.
- Repeated miss may stay active or repeated-miss.
- Later same-family correct may become quiet-after-correct.
- Quiet state may support `You later answered this focus correctly.` only after ordered same-focus evidence exists.
- No fixed, solved, mastered, completed, or guaranteed copy.

## 11. Transfer/proof policy

- Transfer may use same-concept miss-to-later-correct ordering only.
- Practice-action join is not required until a future mapped repair target exists.
- CTA source evidence remains unavailable until a future Practice launch owner exists.
- Later-correct proof is a signal, not causality or mastery.

## 12. Claim-safety policy

- Allowed: `range thinking`, `combo density`, `visible cards change what hands are possible`.
- Allowed future proof copy: `You later answered this focus correctly.` if evidence supports it.
- Forbidden: GTO range, solver-approved, optimal range, perfect range, mastered combos, leak fixed, guaranteed improvement, AI found your range leak.
- No raw ids in learner-facing copy.

## 13. Future implementation DoD

- Add source-owned W7 task with the proposed ids.
- Emit all required evidence fields through existing learning evidence owner.
- Add lifecycle tests for miss, repeated miss, and quiet-after-correct.
- Add transfer tests for same-concept later correct and unrelated-concept exclusion.
- Add mapper test proving no Practice CTA until target owner exists.
- Add copy guard tests for forbidden terms and raw ids.
- Keep W7 route locked unless route admission separately opens it.

## 14. Blockers/deferred items

- W7 content/runtime implementation deferred.
- W7 Practice target mapping deferred.
- Paired-board density, suited blockers, and bluff blockers deferred.
- W8-W12 and W13+ remain unopened.
- Human QA, monetization, screenshots, telemetry expansion, and solver validation remain out of scope.

## 15. Score impact

- No W1-W12 movement.
- Overall top-1 may move at most `+0.1` for reduced W7 implementation risk.
- No Human QA, 9.0, monetization, launch, or public learning-effect claim becomes safe.

## 16. Validation

- `git diff --check` passed.
- `git diff --cached --check` passed before staging.
- `graphify hook-check` passed.
- New artifact ASCII, trailing whitespace, CRLF, and final-newline checks passed.

## 17. Next recommendation

- Run a docs-only W7 task-owner design wave for `visible_ace_combo_reduction_intro` before any Dart, fixture, route, or Practice mapper implementation.
