# W7 Selective Route Entry Readiness Bundle v1

## 1. Verdict

`w7_selective_route_entry_blocked_by_stale_resume_dependency`

Stage 1 decision: stop. Do not make W7 selectable in this wave.

## 2. Identity

- Wave: W7 Selective Route Entry Readiness Bundle v1.
- Scope: W7-only readiness decision.
- Branch: `main`.
- Starting main hash: `aeaf3a1548802ecb0b1d05fc72a8588d922ea217`.

## 3. Stage 0

- `main` matched `origin/main`.
- Required W7 readiness docs existed.
- Only known untracked output folders were present and none were touched.
- No Stage 0 artifact was required.

## 4. Context Used

- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/REPO_HYGIENE_CAPSULE_v1.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/_reviews/w7_visible_locked_preview_implementation_v1.md`
- `docs/_reviews/w7_route_lock_transition_decision_gate_v1.md`
- `docs/plan/VOLUME_I_ROUTE_ADMISSION_CHECKLIST_v1.md`
- `docs/plan/VOLUME_I_EV_BACKLOG_v1.md`

## 5. Exact Seams Inspected

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/services/progress_service.dart`
- `lib/canonical/progression_route_story_v1.dart`
- `lib/ui_v2/screens/universal_intake_plan_screen.dart`
- `test/guards/w7_w10_route_status_alignment_contract_test.dart`
- `test/guards/world7_campaign_routing_contract_test.dart`
- `test/guards/world8_campaign_routing_contract_test.dart`
- `test/guards/world9_campaign_routing_contract_test.dart`
- `test/guards/world10_campaign_routing_contract_test.dart`
- `test/guards/world6_to_world9_campaign_session_promotion_contract_test.dart`
- `test/guards/campaign_spine_structure_contract_test.dart`

## 6. Why B Is Not Safe Yet

W7 route entry cannot be admitted as a small isolated slice while stale resume
remains blocked.

`ProgressService.getNextSpinePackToRunV1()` currently returns
`world6_spine_followup_v1_b2` when an active W7-W10 pack is present. A W7 route
entry slice that launches a W7 campaign/session would need to define whether an
active W7 pack resumes W7 or falls back. Changing that behavior would be stale
resume admission, which this wave forbids.

## 7. Secondary Blocker

The route-card owner is static sample metadata. Making the W7 card selectable
only after the post-W6/progression condition would require a dynamic card-state
owner or a separate selectable-route owner, not a small metadata flip.

## 8. Current W7 Route State

- W7 remains visible as locked preview.
- W7 remains locked.
- W7 remains non-selectable.
- W7 remains not route-admitted.
- Learner-facing title remains `Visible Cards Change Ranges`.

## 9. Mapper / Practice / Stale Resume

- Mapper remains no-target for W7.
- Practice CTA remains absent for W7.
- Stale W7 active pack state remains blocked to W6 fallback.

## 10. W8-W12 / W1-W6 Boundaries

- W8-W12 remain locked, non-selectable, and no-target.
- W1-W6 route behavior was not changed.
- No post-W6 progression behavior was changed.

## 11. Tests

No source/test implementation landed. Existing focused seams were inspected,
but Flutter tests were not required for this docs-only decision artifact.

## 12. Validation

- `git status`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- ASCII, LF, final-newline, and trailing-whitespace checks on this artifact

## 13. Score Impact

No score movement. No top-1, 10/10, launch, Human QA, monetization, public
learning-effect, or public route-readiness claim.

## 14. Forbidden Scope Proof

No runtime/product/test code, W8-W12 route admission, mapper allowlist, Practice
CTA admission, stale resume opening, telemetry expansion, queue mutation, broad
content expansion, UI redesign, screenshots/output edits, generated assets,
monetization, Human QA execution, ML/AI/persona, solver/GTO claim, W1-W6
rework, W13+, or Modern Table work was performed.

## 15. Smallest Next Implementation Prompt

Run `W7 Selective Route Entry + Stale Resume Policy v1`: admit a W7-only route
entry policy that explicitly defines active W7 pack continuation, W7 completion
or exit behavior, post-W6 progression copy, and tests while keeping mapper,
Practice CTA, W8-W12, Human QA, screenshots/output, and public claims blocked.
