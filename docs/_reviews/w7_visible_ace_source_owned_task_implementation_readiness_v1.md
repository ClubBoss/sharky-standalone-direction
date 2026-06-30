# W7 Visible Ace Source-Owned Task Implementation Readiness v1

## 1. Verdict

w7_visible_ace_source_owned_task_readiness_landed

## 2. Stage 0 Sync Result

- Synced accepted commit `29bf282d` into `main` by fast-forward.
- Added `docs/_reviews/repo_integration_w7_visible_ace_task_owner_design_v11.md`.
- Pushed `main` normally, non-force, at `86c12e4372a3b653ecf2becd418306528f61ff7e`.

## 3. Context Router Usage

- Read `docs/context/CONTEXT_ROUTER_v1.md`.
- Followed `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`.
- Stage 0 used lane `repo_hygiene`.
- Stage 1 used the smallest durable-repair/W7 readiness context.
- Searched exact task/evidence/route-lock seams before naming future files.

## 4. Files Inspected

- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/REPO_HYGIENE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/w7_range_thinking_lite_concept_family_admission_packet_v1.md`
- `docs/_reviews/w7_visible_ace_combo_reduction_task_owner_design_v1.md`
- `docs/_reviews/repo_integration_w7_visible_ace_task_owner_design_v11.md`

## 5. Existing Implementation Seams

- Content/schema: `tools/content_factory_import_export_mvp_v1.dart`,
  `tools/content_schema_foundation_validator_v1.dart`,
  `tools/content_schema_l2_l3_validator_v1.dart`, and matching `test/tools/*`.
- Evidence/telemetry: `act0_learning_evidence_contract_v1.dart`,
  `act0_lesson_runner_shell_v1.dart`, `act0_telemetry_sink_v1.dart`, and
  matching `test/ui_v2/*` contract tests.
- Route locks: `w7_w10_route_status_alignment_contract_test.dart` and
  `world7_campaign_routing_contract_test.dart`.

## 6. Future Task Owner Recommendation

- Use one source-owned task definition for `visible_ace_combo_reduction_intro`.
- Prefer a future narrow content-factory/source-task owner, not a routed W7
  lesson, screen, or Practice queue owner.
- Candidate future source artifact: `test/fixtures/content_factory_mvp/w7_visible_ace_combo_reduction_intro_v1.json`.
- Candidate future validators/tests are content-factory/schema plus focused Act0 evidence tests.
- Do not attach the task to learner navigation until a separate route-opening
  wave admits W7.

## 7. Required Task Model Fields

- `world_id: world_7`
- `lesson_id: range_thinking_lite_combo_density`
- `task_id: visible_ace_combo_reduction_intro`
- `source_task_id: visible_ace_combo_reduction_intro`
- table/card context for `A72 rainbow`
- learner prompt
- ordered choices: `ace_combos_reduced`, `ace_combos_unchanged`,
  `ace_combos_increased`, `ace_combos_impossible`
- `expected_choice: ace_combos_reduced`
- explanation and per-incorrect safe feedback
- `concept_family_id: w7_combo_density_visible_card_removal`
- `repair_focus_id: w7_visible_card_combo_reduction`
- `skill_atom_id: w7_combo_density_card_removal`
- `error_type: missed_visible_card_combo_reduction`

## 8. Evidence Emission Policy

- Emit deterministic local evidence only after a future admitted implementation.
- Required signal fields: `user_choice`, `correct`, `error_type`, `time_to_decision`, and ordered evidence.
- Evidence must remain same-concept matchable without relying on screen copy.
- Later-correct proof may support only:
  `You later answered this focus correctly.`
- No practice-causal, mastery, solver, Human QA, launch, or public learning-effect claim becomes safe.

## 9. Route Lock Policy

- W7 remains locked and non-routed.
- Future task addition must not make W7 selectable, reachable, promoted, or resumed from stale active state.
- Route-lock guards must remain green after any future implementation.

## 10. Mapper No-Target Policy

- Keep mapper result explicit no-target.
- Required reason: `w7_route_locked_no_safe_practice_target_v1`.
- No Practice CTA, queue launch, mapper allowlist entry, or repair launch request is admitted.

## 11. Required Tests

- Content/schema validator proof for the single source-owned task.
- Task-model proof for board context, choices, expected answer, and explanation.
- Evidence contract proof for required ids and signal fields.
- Lifecycle proof for miss, repeated miss, and quiet-after-correct.
- Transfer proof for same-concept later correct and unrelated-concept exclusion.
- Mapper proof that W7 remains no-target.
- Route-lock proof that W7 remains inaccessible.
- Copy guard proof for forbidden claims and raw ids.

## 12. Runtime Implementation DoD

- One task only; no broad W7 content expansion.
- No fixture/content family beyond the admitted single source-owned task.
- No route, screen, UI, Practice, telemetry expansion, or mapper change unless a
  future prompt separately admits it.
- Validation must include focused content/schema, evidence, mapper no-target,
  route-lock, and copy-safety tests.

## 13. Blocked / Deferred Items

- Dart/runtime implementation, W7 route opening, Practice target owner, mapper allowlist, and fixture/content creation are deferred.
- W8-W12, W13+, Human QA, monetization, screenshots, ML/AI/persona, and solver validation remain out of scope.

## 14. Validation

- `git diff --check` passed.
- `git diff --cached --check` passed.
- `graphify hook-check` passed.
- New artifact ASCII, trailing whitespace, CRLF, and final-newline checks passed.

## 15. Score Impact

- Stage 0 sync: no score movement.
- Readiness audit: W1-W12 remains `8.3/10`.
- Overall top-1 movement: `+0.0`; implementation risk is clarified, not reduced by runtime proof.

## 16. Next Recommendation

Run a future single-task implementation wave only after accepting this readiness contract and keeping W7 route locked plus mapper no-target.
