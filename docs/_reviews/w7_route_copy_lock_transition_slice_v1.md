# W7 Route Copy Lock Transition Slice v1

## 1. Verdict

`w7_route_copy_lock_transition_slice_landed`

W7 route-facing copy now uses the approved learner-facing title while W7 remains locked and non-selectable. W8-W12, mapper target, Practice CTA, and stale resume remain blocked.

## 2. Stage 0 Result

- Stage 0 artifact: `docs/_reviews/repo_integration_w7_route_copy_lock_transition_v33.md`.
- Stage 0 commit: `ce44650469e15c4190a92731311732229e722e0f`.
- Stage 0 passed with `main` equal to `origin/main` and only known untracked output folders present.

## 3. Branch / Commit

- Branch: `main`.
- Stage 1/2 commit: commit containing this artifact.
- Commit message: `feat: prepare w7 route copy lock transition`.

## 4. Files Inspected

- `docs/context/CONTEXT_ROUTER_v1.md`
- `docs/context/TOKEN_BUDGET_PROTOCOL_v1.md`
- `docs/context/CURRENT_STATE_CAPSULE_v1.md`
- `docs/context/DURABLE_REPAIR_CAPSULE_v1.md`
- `docs/_reviews/volume_i_route_admission_planning_gate_v1.md`
- `docs/plan/VOLUME_I_ROUTE_ADMISSION_CHECKLIST_v1.md`
- `docs/_reviews/volume_i_pre_route_naming_copy_capstone_contract_v1.md`
- `docs/plan/VOLUME_I_EV_BACKLOG_v1.md`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- `lib/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart`
- focused W7 route-lock, mapper, Practice CTA, stale-resume, and shell preview tests.

## 5. Files Changed

- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/l10n/act0_copy_ru_v1.dart`
- `test/guards/w7_w10_route_status_alignment_contract_test.dart`
- `test/ui_v2/act0_shell_preview_screen_v1_test.dart`
- `docs/_reviews/w7_route_copy_lock_transition_slice_v1.md`

## 6. Route / Copy / Status Owner Decision

The smallest existing owner is the active Act0 world-card metadata in `act0_shell_state_v1.dart`, backed by localized world display copy in `act0_copy_ru_v1.dart`.

No new display-title architecture was introduced.

## 7. W7 Title Implementation Status

- W7 card title is now `Visible Cards Change Ranges`.
- W7 card subtitle is now `Use visible cards to narrow what hands can still be there.`
- W7 localized Russian card title/subtitle were aligned to the same meaning.
- W7 route-scaffold lesson subtitles no longer use `Range Thinking Lite`.
- Internal world ids, lesson ids, task ids, and legacy implementation identifiers remain unchanged.

## 8. W7 Lock Status

- W7 remains `Act0WorldStateV1.locked`.
- W7 remains `isLocked: true`.
- W7 remains `isSelectable: false`.
- W7 still depends on completion of W6 `Range Thinking`.
- No W7 route opening was performed.

## 9. W8-W12 Lock Status

- W8-W12 remain locked and non-selectable.
- W8 unlock copy now points to the new W7 title.
- No W8-W12 content, route, mapper, Practice CTA, stale-resume, or status opening was performed.

## 10. Mapper Status

- Mapper allowlist was not changed.
- Focused guard proves an attempted W7 allowlist target still returns `no_target_route_locked_v1`.
- Existing mapper tests still pass.

## 11. Practice CTA Status

- Practice CTA behavior was not changed.
- W7 hidden owner still has `practiceLaunchRequest == null`.
- Session Summary still hides Practice CTA without a safe mapped target.

## 12. Stale-Resume Status

- Stale active W7-W10 pack state remains blocked from the learner route.
- The active route still falls back to `world6_spine_followup_v1_b2`.
- No stale W7-W12 resume was opened.

## 13. W1-W6 No-Regression Proof

- W1-W6 route behavior was not edited.
- Existing W6 final progression chrome still keeps future route locked and claim-safe.
- Focused route tests confirm post-W6 progression does not promote W7-W10.

## 14. Copy / Claim Safety

W7 route-facing copy avoids:

- `Range Thinking Lite`
- combo density
- unexplained card removal
- raw task ids
- solver/GTO
- Human QA, launch, 9.0, mastery, fixed-forever, or learning-effect claims

## 15. Tests

Passed:

- `flutter test test/guards/w7_w10_route_status_alignment_contract_test.dart test/ui_v2/act0_concept_candidate_practice_mapper_v1_test.dart test/ui_v2/act0_w7_visible_ace_hidden_runtime_session_owner_v1_test.dart test/ui_v2/act0_session_summary_earned_moment_v1_test.dart test/guards/world7_campaign_routing_contract_test.dart test/ui_v2/runner/session_drill_runner_progression_chrome_contract_v1_test.dart`
- `flutter test test/ui_v2/act0_shell_preview_screen_v1_test.dart --name "World 7|Worlds route order|levels menu"`
- `flutter analyze`

## 16. Validation

Required validation performed:

- Stage 0 repo hygiene checks
- `dart format` on touched Dart files
- focused Flutter tests
- `flutter analyze`
- `git diff --check`
- `git diff --cached --check`
- `graphify hook-check`
- ASCII / trailing whitespace / CRLF / final-newline checks on new docs

## 17. Score Impact

- No W1-W12 readiness movement.
- No top-1 readiness movement.
- No Human QA pass.
- No 9.0, monetization, launch, public/playable opening, full route admission, or public learning-effect claim.

## 18. Forbidden Scope Proof

- No W7 card unlock.
- No W7 route admission.
- No W8-W12 route work.
- No UI/screen/navigation redesign.
- No mapper allowlist.
- No Practice CTA.
- No stale resume opening.
- No queue mutation, telemetry expansion, content expansion, screenshots, output edits, generated assets, monetization, Human QA execution, ML/AI/persona, solver/GTO claim, W1-W6 rework, or Modern Table work.

## 19. Next Recommendation

Run a W7 route-lock transition decision wave only if the product is ready to choose whether W7 remains preview-locked or becomes selectively route-visible. Keep mapper, Practice CTA, and stale resume out of that wave unless explicitly admitted.
