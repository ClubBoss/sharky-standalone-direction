# Volume I Route Admission Planning Gate v1

## 1. Identity

- Wave: Volume I Route Admission Planning Gate v1.
- Lane: repo_hygiene plus bounded route-admission planning.
- Scope: docs-only route admission plan for W7-W12.
- Non-scope: no route opening, runtime edit, product implementation, tests, screenshots, output folders, telemetry, monetization, Human QA, ML/AI/persona, solver/GTO, W1-W6 rework, W8-W12 implementation, or Modern Table work.

## 2. Verdict

`volume_i_route_admission_planning_gate_landed_route_blocked`

The planning gate is now documented, but Volume I W7-W12 remain route-locked and non-admitted.

## 3. Stage 0 Result

- Stage 0 artifact: `docs/_reviews/repo_integration_volume_i_route_admission_planning_v32.md`.
- Stage 0 commit: `321dba244a2b3089cd12648d551d87c203133a04`.
- Stage 0 preserved the accepted pre-route/status artifacts and confirmed mainline hygiene before this planning gate.

## 4. Context Router Usage

- Router read: `docs/context/CONTEXT_ROUTER_v1.md`.
- Lane used: `repo_hygiene`.
- Token protocol read: `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Supporting capsules used only for bounded planning facts:
  - `docs/context/CURRENT_STATE_CAPSULE_v1.md`
  - `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
  - `docs/context/HUMAN_QA_CAPSULE_v1.md`

## 5. Admission Model Decision

Adopt staged admission: W7 first, then W8-W10, then W11-W12.

Do not batch-open W7-W12. The current blockers differ by owner and risk:

- W7 has the first route-facing title/copy mismatch and is the smallest meaningful route delta.
- W8-W10 should follow only after W7 proves display-title, intro, progression, stale-resume, mapper, and Practice CTA policy.
- W11-W12 should remain later because W12 is a review-world framing, not a mastery capstone, and because transfer/review copy is more likely to be mistaken for public learner-outcome proof.

## 6. Route-Facing Owner Findings

- World card title/subtitle/status owner: `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`, `_act0PreviewWorlds`.
- Current W7 card still says `Range Thinking Lite`; the accepted learner-facing title is `Visible Cards Change Ranges`.
- Current W8-W12 cards remain locked and non-selectable.
- Russian localized card copy exists in `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`; English route-facing card copy appears inline in active state.
- Selected-world route/progression copy owner includes `lib/ui_v2/act0_shell/act0_learn_path_shell_v1.dart`.
- Hidden internal world task owners exist for W7-W12, but they are not route admission owners.
- W7-W12 route-visible intro owner is not established in the inspected active route and must be selected before implementation.
- Completion/progression chrome currently keeps future route locked after W6 and must not be changed until a route-opening implementation wave.
- Stale-resume owner is the progress/active-pack route path; existing guards prevent stale W7-W10 from becoming the learner route.
- Practice CTA owner is the durable repair/session-summary path, gated by the pure concept-candidate mapper.
- Mapper allowlist owner is `lib/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart`.

## 7. Mapper Policy

- No W7-W12 mapper targets are admitted by this wave.
- Keep W8-W12 no-target route-locked behavior until their own route stages.
- For future W7 route opening, do not add a mapper target in the first route wave unless the W7 target is owned, route-visible, tested, and copy-reviewed.
- A future mapper admission must be one world at a time and must include:
  - explicit candidate-to-owned-task mapping;
  - allowed target world transition;
  - no bridge-limited leakage;
  - no hidden-world launch;
  - route-lock transition tests updated intentionally.

## 8. Practice CTA Policy

- Practice CTA remains absent for W7-W12 unless the mapper returns a safe launch request.
- W7 first admission should prefer no Practice CTA.
- If a W7 Practice CTA is later admitted before Human QA, its label must be bounded and must not claim repair, proof, mastery, outcome lift, or learner improvement.
- Session Summary may expose Practice only for mapped safe targets; route-locked worlds must continue to produce no-target reasons.

## 9. Stale-Resume Policy

- Existing stale W7-W10 blocked behavior remains valid before route admission.
- A future W7 opening must decide and test one of two behaviors:
  - resume the exact W7 active task only after W7 route and stale-state ownership are admitted; or
  - fall back safely to the W6/future-locked route state.
- Do not permit stale W8-W12 resume during W7 admission.
- Do not permit stale W12 review resume before the W12 route stage.

## 10. Post-W6 Progression Policy

- W7 should appear as the next extension step, not as `Lite`.
- W7 route-facing copy should use the accepted title `Visible Cards Change Ranges`.
- W6 completion/progression copy must stay locked until a future implementation wave changes tests and route behavior together.
- W12 should be framed as `Volume I Review: Putting the Clues Together`, not as a final mastery capstone.

## 11. Human QA Boundary

- This wave defines planning gates only.
- Human QA cannot begin until there is route-visible W7 copy and route behavior to inspect.
- No Human QA execution, Human QA pass, 9.0 claim, launch claim, public route claim, or learning-effect claim is made here.

## 12. Implementation Sequence

1. W7 route-copy prep: choose active route-facing intro owner and align W7 card title/subtitle copy.
2. W7 route-lock test prep: write failing route transition expectations for W7 only.
3. W7 route opening implementation: update W7 card status/selectability, progression copy, and stale-resume behavior together.
4. W7 route safety pass: keep mapper and Practice CTA absent unless separately admitted.
5. W7 Human QA packet: inspect route-visible title, intro, progression, completion, and no-overclaim copy.
6. W8-W10 planning and opening: repeat only after W7 passes route safety.
7. W11-W12 planning and opening: handle transfer/review framing with extra copy-safety review.

## 13. Route Admission Status

- W7: planned, still blocked.
- W8-W10: planned after W7 proof, still blocked.
- W11-W12: planned after W8-W10 proof, still blocked.
- W1-W6: unchanged and frozen by this wave.

## 14. Score Impact

- No W1-W12 score movement.
- No top-1 score movement.
- No 8.3 movement.
- No Human QA, 9.0, launch, route, monetization, or public learning-effect claim.

## 15. Forbidden Scope Proof

- Runtime/product files: not modified.
- Test files: not modified.
- Screenshots/output folders: not modified or staged.
- Route opening: not performed.
- UI/navigation/card unlock: not performed.
- Mapper allowlist: not changed.
- Practice CTA: not changed.
- Stale resume: not changed.
- Telemetry/content expansion: not changed.
- Human QA: not executed.
- Monetization, ML/AI/persona, solver/GTO, W1-W6 rework, and Modern Table: not touched.

## 16. Next Recommendation

Run a W7-only route-copy and lock-transition implementation wave. It should change route-facing W7 copy and tests together, keep W8-W12 locked, keep Practice CTA absent unless explicitly admitted, and avoid Human QA claims until the route-visible W7 packet exists.
