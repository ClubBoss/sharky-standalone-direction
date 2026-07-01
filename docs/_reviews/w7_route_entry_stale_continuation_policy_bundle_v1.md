# W7 Route Entry + Stale Continuation Policy Bundle v1

## 1. Verdict

`w7_route_entry_stale_policy_landed_mapper_cta_blocked`

## 2. Identity

- Wave: W7 Route Entry + Stale Continuation Policy Bundle v1.
- Scope: W7-only route entry and stale/active continuation policy.
- Branch: `main`.
- Starting main hash: `df0b8ef25e844c19fe66c13062f8ed7a31e48983`.

## 3. Stage 0

- `main` matched `origin/main`.
- Required W7 docs existed.
- Only known untracked output folders were present and none were touched.
- No Stage 0 artifact was required.

## 4. Context Used

- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/REPO_HYGIENE_CAPSULE_v1.md`
- `docs/_reviews/w7_selective_route_entry_readiness_bundle_v1.md`
- `docs/_reviews/w7_visible_locked_preview_implementation_v1.md`
- `docs/plan/VOLUME_I_ROUTE_ADMISSION_CHECKLIST_v1.md`
- Exact W7 route-entry, active-pack, stale-continuation, route-lock, mapper,
  Practice CTA, and W6 completion-copy seams.

## 5. Policy Decision

Chosen policy: A for W7 active packs, with a W7-only terminal fallback.

- Fresh W7 route entry after W6 enters `world7_spine_campaign_v1`.
- Incomplete active W7 packs resume the active W7 pack.
- Stale active W7 packs resume the active W7 pack.
- Completed W7 does not open W8.
- W7 completion/exit falls back to `world6_spine_followup_v1_b2` until a
  separate W7 follow-up or W8 route-admission wave.
- W7 progress persists through existing active-pack, hand-index, and completed
  pack storage.

## 6. Route Entry

W7 route entry is admitted through `ProgressService.getNextSpinePackToRunV1()`
only after W6 calibration and W6 follow-up completion. It uses the existing
campaign/session route owner and does not create a new navigation architecture.

## 7. W7 Title / Copy

W7 learner-facing title remains `Visible Cards Change Ranges`.

W6 final completion copy now points to `Visible Cards Change Ranges` as ready
next and avoids locked-future wording.

## 8. Mapper / Practice CTA

- No W7 mapper allowlist was added.
- W7 mapper remains no-target.
- W7 Practice CTA remains absent.

## 9. W8-W12 Boundary

- W8-W12 remain locked, non-selectable, and no-target.
- Active W8-W10 packs remain blocked to the W6 terminal fallback.
- No W8-W12 route admission was performed.

## 10. W1-W6 Boundary

W1-W6 route behavior was not reworked. The only W6-facing change is claim-safe
completion copy that no longer contradicts W7 route entry.

## 11. Files Changed

- `lib/services/progress_service.dart`
- `lib/canonical/progression_route_story_v1.dart`
- `test/guards/w7_w10_route_status_alignment_contract_test.dart`
- `test/guards/world7_campaign_routing_contract_test.dart`
- `test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`
- `docs/plan/VOLUME_I_ROUTE_ADMISSION_CHECKLIST_v1.md`
- `docs/_reviews/w7_route_entry_stale_continuation_policy_bundle_v1.md`

## 12. Tests

Passed focused tests for:

- W7 post-W6 route entry.
- W7 active/stale continuation policy.
- W7 completion fallback.
- W8-W10 route lock.
- Mapper no-target.
- Practice CTA absence.
- W6 completion copy safety.

## 13. Validation

- `dart format` on touched Dart files.
- Focused Flutter route/mapper/Practice/copy tests.
- `flutter analyze`.
- `git diff --check`.
- `git diff --cached --check`.
- `graphify hook-check`.
- ASCII, LF, final-newline, and trailing-whitespace checks on changed docs.

## 14. Score Impact

No score movement. No top-1, 10/10, launch, Human QA, monetization, public
learning-effect, or public route-readiness claim.

## 15. Forbidden Scope Proof

No W8-W12 route admission, mapper allowlist, Practice CTA admission, W8-W12
stale resume, broad stale-resume rewrite, telemetry expansion, queue mutation,
broad content expansion, UI redesign, screenshots/output edits, generated
assets, monetization, Human QA execution, ML/AI/persona, solver/GTO claim,
W1-W6 rework, W13+, or Modern Table work was performed.

## 16. Next Recommendation

Run a separate W7 follow-up/completion-depth wave only if product wants W7
follow-up packs or W8 admission. Keep mapper and Practice CTA blocked until a
separate route-owned practice target is admitted.
