# W7 Visible Ace Combo Reduction Task Owner Design v1

## 1. Verdict

w7_visible_ace_combo_reduction_task_owner_design_landed

## 2. Stage 0 Sync Result

- Synced accepted commit `57dbdea9` into `main` by fast-forward.
- Added `docs/_reviews/repo_integration_w7_range_thinking_lite_admission_packet_v10.md`.
- Pushed `main` normally, non-force, at `5c757cd75c00a7d400f4d5140f5f7cadcc16db16`.

## 3. Context Router Usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Stage 0 used lane `repo_hygiene`.
- Stage 1 used the admitted W7 packet plus durable-repair capsule only.
- Did not open W1-W6 artifacts, runtime code, fixtures, screenshots, or output folders.

## 4. Files Inspected

- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/REPO_HYGIENE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/w7_range_thinking_lite_concept_family_admission_packet_v1.md`
- `docs/_reviews/repo_integration_w7_range_thinking_lite_admission_packet_v10.md`

## 5. Task Owner Definition

- World: `world_7`
- Module / lesson: `range_thinking_lite_combo_density`
- Task id: `visible_ace_combo_reduction_intro`
- Source task id: `visible_ace_combo_reduction_intro`
- Concept family: `w7_combo_density_visible_card_removal`
- Repair focus: `w7_visible_card_combo_reduction`
- Skill atom: `w7_combo_density_card_removal`
- Error type: `missed_visible_card_combo_reduction`
- Safe display label: `Combo density`
- Owner purpose: teach that one visible rank card reduces remaining private-card combinations for that rank.

## 6. Learner Prompt And Choices

Prompt:

`Board: A72 rainbow. You can see one ace on the board. Before we guess a hand,
what happens to the number of ace-heavy hands an opponent can still have?`

Choices:

- `ace_combos_reduced`: `Fewer ace-heavy combinations remain.`
- `ace_combos_unchanged`: `The visible ace does not change ace combinations.`
- `ace_combos_increased`: `The visible ace creates more ace combinations.`
- `ace_combos_impossible`: `The opponent can never have an ace.`

## 7. Correct Answer And Explanation

- Correct answer: `ace_combos_reduced`.
- Explanation: one ace is already visible, so fewer unseen aces remain for
  private hands. This does not identify the exact hand; it only changes how many
  hands are possible.

## 8. Incorrect Feedback Policy

- For `ace_combos_unchanged`: visible cards are unavailable to private hands, so
  density changes.
- For `ace_combos_increased`: seeing a card removes, not adds, private-card
  combinations.
- For `ace_combos_impossible`: one visible ace reduces ace combos but does not
  make every ace hand impossible.
- Feedback must avoid GTO, solver, optimal range, mastery, leak-fixed, or AI
  language and must not render raw ids.

## 9. Evidence Output Contract

Future implementation must emit:

- `world_id: world_7`
- `lesson_id: range_thinking_lite_combo_density`
- `task_id: visible_ace_combo_reduction_intro`
- `source_task_id: visible_ace_combo_reduction_intro`
- `user_choice`
- `expected_choice: ace_combos_reduced`
- `correct`
- `error_type: missed_visible_card_combo_reduction`
- `skill_atom_id: w7_combo_density_card_removal`
- `repair_focus_id: w7_visible_card_combo_reduction`
- `time_to_decision`
- ordered local evidence record

## 10. Lifecycle / Transfer / Proof Compatibility

- Incorrect answer may create an active concept-family repair candidate.
- Repeated same-family miss may remain active or repeated-miss.
- Later same-family correct may become quiet-after-correct.
- Same-focus later-correct proof may support only:
  `You later answered this focus correctly.`
- No copy may claim practice causality, mastery, fixed leaks, Human QA, launch readiness, or public learning-effect proof.

## 11. Mapper / No-Target Policy

- Current mapper state remains explicit no-target.
- No-target reason: `w7_route_locked_no_safe_practice_target_v1`.
- No Practice CTA, queue admission, launch request, route opening, or mapper
  expansion is admitted by this design.

## 12. Claim Safety

- Safe claims: `range thinking`, `combo density`, and `visible cards change what
  hands are possible`.
- Unsafe claims: GTO range, solver-approved, optimal range, perfect range,
  mastered combos, leak fixed, guaranteed improvement, AI-found leak, Human QA,
  9.0, launch-ready, or monetization-ready.

## 13. Future Implementation DoD

- Add the task only in a future admitted W7 implementation wave.
- Add a source-owned task or fixture with the ids above.
- Prove the expected choice, incorrect choices, safe feedback, and evidence
  fields with focused validators or tests.
- Prove mapper no-target behavior remains locked unless a separate mapping wave
  admits a safe Practice target.
- Preserve W7 non-routed state unless a separate route-opening wave is admitted.

## 14. Validation

- `git diff --check` passed.
- `git diff --cached --check` passed.
- `graphify hook-check` passed.
- New artifact ASCII, trailing whitespace, CRLF, and final-newline checks passed.

## 15. Score Impact

- W1-W12 remains `8.3/10`.
- Overall top-1 score movement: `+0.0`; this only reduces future W7 task
  implementation ambiguity.

## 16. Next Recommendation

Run a bounded W7 implementation-readiness or source-owned task wave only after
confirming the route remains locked and the mapper stays no-target.
