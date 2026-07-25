---
status: "undeclared"
status_source: "absent"
baseline: "19fb45ae7b0a"
generated_by: "docs_frontmatter_v1"
---

# W7-W9 Canonical Route Ownership And Learner-Reachability Admission Audit v1

## 1. Executive Verdict

Overall verdict: `w7_w9_canonical_route_blocked_missing_or_conflicting_ownership`.

W7-W9 are not admitted for a deep content-quality audit yet. Current source proves several route pieces are present and tested, but the normal required learner chain is not owned by one reconciled canonical route:

- Act0 normal route ownership exists in `lib/ui_v2/act0_shell/act0_shell_state_v1.dart` and `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`.
- A separate `ProgressService` / campaign route also admits W7-W9 packs through `lib/services/progress_service.dart` and `lib/campaign/campaign_pack_registry_v1.dart`.
- W8 and W9 meanings conflict between canonical truth / Act0 state and campaign or hidden-source owners.
- W7+ world-completion payoff is explicitly deferred in `Act0BlockCompletionSummaryV1`, and the test suite locks that World 7 is not yet covered by completion payoff.
- Hidden/internal W7-W9 evidence owners have no Practice launch request and are not sufficient proof of the normal learner route.

No learning-quality score, content closure, Alpha closure, Human-QA readiness, or release readiness is claimed.

## 2. Base Repository Proof

- Branch: `main`.
- Expected local HEAD: `19fb45ae7b0a464ea98d7b2aa6009a4ddb76b4b5`.
- Actual local HEAD: `19fb45ae7b0a464ea98d7b2aa6009a4ddb76b4b5`.
- Actual `origin/main`: `19fb45ae7b0a464ea98d7b2aa6009a4ddb76b4b5`.
- Ahead/behind: `0/0`.
- Initial worktree state: clean.
- `PROJECT_RULES_VFINAL.md`: not present at repository root or in `rg --files`; treated as absent reference authority, not an active SSOT blocker because the active SSOT chain required by AGENTS is present.

## 3. Authority And Files Inspected

Authority and context:

- `docs/plan/MASTER_PLAN_v3.0.md`
- `docs/context/CONTEXT_ROUTER_v1.md`
- `AGENTS.md`
- `docs/plan/PROJECT_TOPOLOGY_AND_TRUTH_MAP_v1.md`
- `lib/canonical/canonical_truth_map_v1.dart`

Runtime and source owners:

- `lib/ui_v2/app_root.dart`
- `lib/ui_v2/ui_v2_beta_shell.dart`
- `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`
- `lib/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart`
- `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`
- `lib/ui_v2/act0_shell/act0_telemetry_sink_v1.dart`
- `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`
- `lib/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_w8_draws_hidden_runtime_session_owner_v1.dart`
- `lib/ui_v2/act0_shell/act0_w9_price_hidden_runtime_session_owner_v1.dart`
- `lib/services/progress_service.dart`
- `lib/campaign/campaign_pack_registry_v1.dart`

Focused tests:

- `test/ui_v2/act0_w7_completion_pack_v1_test.dart`
- `test/ui_v2/act0_w8_internal_world_source_template_v1_test.dart`
- `test/ui_v2/act0_w8_hidden_evidence_consumption_internal_harness_v1_test.dart`
- `test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart`
- `test/ui_v2/act0_w9_w10_hidden_evidence_consumption_internal_harness_v1_test.dart`
- `test/guards/world7_campaign_routing_contract_test.dart`
- `test/guards/world8_campaign_routing_contract_test.dart`
- `test/guards/world9_campaign_routing_contract_test.dart`
- `test/guards/world_campaign_routing_matrix_contract_test.dart`
- `test/guards/w7_w10_route_status_alignment_contract_test.dart`
- `test/ui_v2/act0_telemetry_sink_v1_test.dart`
- `test/ui_v2/act0_repair_intent_contract_v1_test.dart`
- `test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart`
- `test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart`
- `test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart`

## 4. Canonical Boot/Home/Learn Entry Chain

Canonical boot remains Act0:

- `lib/ui_v2/app_root.dart` routes `_EntryGate.build` to `Act0ShellPreviewScreenV1`.
- `lib/ui_v2/ui_v2_beta_shell.dart` routes `buildCanonicalPathRootV1` to `Act0ShellPreviewScreenV1`.
- `Act0ShellPreviewScreenV1` owns Home/Learn/Play/Review/Profile runtime selection.
- Learn starts tasks through `onStartTask`, which sets `_selectedLessonId`, `_selectedTaskId`, `_tab = Act0ShellTabV1.play`, `_showPlayHub = false`, and `_phase`.
- Play renders `Act0LessonRunnerShellV1` with `selectedWorldId`, `selectedLessonId`, `selectedTaskId`, `selectedTaskFamily`, and `_sessionAwareTelemetrySinkV1()`.
- Completion persists through `_completeCurrentTask`, `_persistProgress`, and `_Act0PersistedProgressV1`.

This proves an Act0 route exists, but it does not prove W7-W9 can be admitted because completion payoff and single ownership are not reconciled.

## 5. W7 Ownership Matrix

| Dimension | Owner | ID / Symbol | Required route? | Evidence | Coverage |
|---|---|---|---|---|---|
| world identity and promise | `canonical_truth_map_v1.dart`; `act0_shell_state_v1.dart` | `world_7`; `Visible Cards Change Ranges` | yes | canonical truth marks retired `Range Thinking Lite`; Act0 card uses visible-card title | guard coverage |
| route entry | `Act0ShellPreviewScreenV1`; `ProgressService` | Act0 Learn; `world7_spine_campaign_v1` | yes, conflicting layers | Act0 has `world_7`; ProgressService returns W7 campaign after W6 completion | focused route tests |
| unlock/prerequisite logic | `Act0ShellPreviewScreenV1._progressWorld`; `ProgressService.getNextSpinePackToRunV1` | previous-world completion; W6 followup/calibration | yes | two independent prerequisite systems | route tests |
| lesson/task order | `act0_shell_state_v1.dart` | `_visibleCardRangeContinuationLessons` | yes | W7 lesson list starts with hidden visible-card specs and recap | source inspected |
| learner-facing content | `act0_shell_state_v1.dart` | W7 visible-card runners/tasks | yes | Act0 task data renders in runner | source inspected |
| guided practice | `Act0LessonRunnerShellV1` | drill phase | yes | runner emits task events and handles choices | telemetry tests |
| independent assessment | `Act0LessonRunnerShellV1` | `onChooseOption` / `onContinueReview` | yes | choices move to review and complete task | repair/telemetry tests |
| evaluator / acceptable action | `Act0RunnerOptionV1` inside Act0 runners | expected option fields | yes | runner option correctness controls result | telemetry tests |
| feedback | `Act0LessonRunnerShellV1` / `Act0FeedbackShellV1` | feedback viewed path | yes | feedback telemetry path tested | telemetry tests |
| mistake/error taxonomy | `Act0RepairIntentV1`; completed-decision evidence | `errorType`, `repairFocusId` | yes | wrong/suboptimal create repair intent | repair tests |
| repair target selection | `Act0RepairIntentV1`; preview mapper | target world/lesson/task | yes | same-signal or exact fallback | repair tests |
| targeted recheck launch | `Act0ShellPreviewScreenV1` Review | `pushSessionDrillRecheckLaunchV1`; Practice repair queue | partial | generic recheck path exists; hidden W7 owner exposes no Practice launch request | telemetry / hidden tests |
| targeted recheck completion | `Act0ShellPreviewScreenV1` | `recheck_completed` | partial | generic Act0 recheck telemetry exists | telemetry test |
| persistence/restoration | `Act0ShellPreviewScreenV1._Act0PersistedProgressV1` | `act0_shell_progress_v1` | yes | selected/completed/open repair state serialized | source inspected |
| telemetry | `Act0TelemetrySinkV1` via runner/preview | `task_shown`, `decision_made`, `feedback_viewed`, `world_complete` | yes | generic Act0 telemetry, not W7-specific full-route proof | telemetry tests |
| world completion | `Act0ShellPreviewScreenV1._progressWorld` | all lessons complete | yes | generic world completion can happen | source inspected |
| payoff | `Act0BlockCompletionSummaryV1` | `hasWorldCompletionPayoff` | yes | W7+ payoff explicitly deferred | failing admission defect |
| next routing | `Act0ShellPreviewScreenV1._advanceAfterTask`; block summary continue | yes | next world can be selected when progression allows | source inspected |

Disposition: `canonical_route_admitted_with_bounded_defects`.

## 6. W8 Ownership Matrix

| Dimension | Owner | ID / Symbol | Required route? | Evidence | Coverage |
|---|---|---|---|---|---|
| world identity and promise | `canonical_truth_map_v1.dart`; `act0_shell_state_v1.dart` | `world_8`; `Stack Depth And Risk` | yes | canonical and Act0 agree on stack-depth meaning | source/guard |
| conflicting source identity | `campaign_pack_registry_v1.dart`; `Act0W8DrawsHiddenRuntimeSessionOwnerV1` | `_w8DrawImprovement*`; `draws_equity_intuition_lite` | no for canonical route | current source still presents W8 as draws/improvement | hidden/campaign tests |
| route entry | `Act0ShellPreviewScreenV1`; `ProgressService` | Act0 Learn; `world8_spine_campaign_v1` | yes, conflicting layers | ProgressService route admits W8 campaign | route tests |
| unlock/prerequisite logic | Act0 previous-world completion; ProgressService W7 completion/calibration | yes | two independent systems | route tests |
| lesson/task order | `act0_shell_state_v1.dart` | `_stackDepthRiskLessons` | yes | stack-depth tasks use `w7_*` task IDs under `world_8` | source inspected |
| learner-facing content | `act0_shell_state_v1.dart` | effective stack, depth shift, SPR, format | yes | Act0 W8 card points here | source inspected |
| guided practice / assessment / feedback | `Act0LessonRunnerShellV1` | runner drill/review flow | yes | generic Act0 route | telemetry tests |
| repair / recheck | generic Act0 repair plus hidden W8 owner | `Act0RepairIntentV1`; `Act0W8DrawsHiddenRuntimeSessionOwnerV1` | partial | hidden owner has no Practice launch request and uses retired W8 meaning | repair/hidden tests |
| persistence/telemetry/completion | `Act0ShellPreviewScreenV1`; `Act0TelemetrySinkV1` | persisted progress; telemetry events | yes | generic coverage only | telemetry tests |
| payoff / next routing | `Act0BlockCompletionSummaryV1`; preview continue | yes | W7+ payoff deferred, so W8 payoff absent | source/test |

Disposition: `blocked_by_authority_conflict`.

## 7. W9 Ownership Matrix

| Dimension | Owner | ID / Symbol | Required route? | Evidence | Coverage |
|---|---|---|---|---|---|
| world identity and promise | `canonical_truth_map_v1.dart`; `act0_shell_state_v1.dart` | `world_9`; `Tournament Pressure` | yes | canonical and Act0 agree on tournament-pressure meaning | source |
| conflicting source identity | `campaign_pack_registry_v1.dart`; `Act0W9PriceHiddenRuntimeSessionOwnerV1` | `_w9CallPrice*`; `pot_odds_price_intuition_lite` | no for canonical route | current campaign/hidden source still presents W9 as call-price/pot-odds | hidden/campaign tests |
| route entry | `Act0ShellPreviewScreenV1`; `ProgressService` | Act0 Learn; `world9_spine_campaign_v1` | yes, conflicting layers | ProgressService admits W9 campaign after W8 | route tests |
| unlock/prerequisite logic | Act0 previous-world completion; ProgressService W8 completion/calibration | yes | two independent systems | route tests |
| lesson/task order | `act0_shell_state_v1.dart` | `_tournamentPressureLessons` | yes | tournament-pressure tasks exist under Act0 | source inspected |
| learner-facing content | `act0_shell_state_v1.dart` | survival, zones, bubble, pressure transfer | yes | Act0 W9 card points here | source inspected |
| guided practice / assessment / feedback | `Act0LessonRunnerShellV1` | runner drill/review flow | yes | generic Act0 route | telemetry tests |
| repair / recheck | generic Act0 repair plus hidden W9 owner | `Act0RepairIntentV1`; `Act0W9PriceHiddenRuntimeSessionOwnerV1` | partial | hidden owner has no Practice launch request and uses retired W9 meaning | repair/hidden tests |
| persistence/telemetry/completion | `Act0ShellPreviewScreenV1`; `Act0TelemetrySinkV1` | persisted progress; telemetry events | yes | generic coverage only | telemetry tests |
| payoff / next routing | `Act0BlockCompletionSummaryV1`; preview continue | yes | W7+ payoff deferred, so W9 payoff absent | source/test |

Disposition: `blocked_by_authority_conflict`.

## 8. W6-To-W7 Transition Proof

Act0 transition: W6 complete makes W7 selectable through `_progressWorld`, because each world becomes available when the previous world is complete.

ProgressService transition: `getNextSpinePackToRunV1` returns `world7_spine_campaign_v1` after W6 followup completion and while `world7_calibration_completed_v1` is false.

Verdict: reachable, but not single-owner. Act0 and ProgressService use different persistence keys and route concepts.

## 9. W7-To-W8 Transition Proof

Act0 transition: W7 complete makes W8 selectable through `_progressWorld`.

ProgressService transition: W7 campaign completion and `world8_calibration_completed_v1 == false` route to `world8_spine_campaign_v1`.

Verdict: blocked by ownership conflict. Act0 W8 is Stack Depth And Risk; campaign/hidden W8 source is draw improvement.

## 10. W8-To-W9 Transition Proof

Act0 transition: W8 complete makes W9 selectable through `_progressWorld`.

ProgressService transition: W8 campaign completion and `world9_calibration_completed_v1 == false` route to `world9_spine_campaign_v1`.

Verdict: blocked by ownership conflict. Act0 W9 is Tournament Pressure; campaign/hidden W9 source is call price / pot odds.

## 11. W9-To-W10 Transition Proof

Act0 transition: W9 complete makes W10 selectable through `_progressWorld`.

ProgressService transition: W9 campaign completion and `world10_calibration_completed_v1 == false` route to `world10_spine_campaign_v1`.

Verdict: blocked for admission because W9 itself has conflicting source identity and no W9 payoff ownership.

## 12. Parallel / Noncanonical Owner Exclusion Matrix

| Surface / owner | Excluded from closure? | Reason |
|---|---:|---|
| `lib/campaign/campaign_pack_registry_v1.dart` W7-W9 microtask packs | partial | It is live source for `ProgressService`, but not the Act0 lesson/task owner and conflicts for W8/W9 meaning. |
| `ProgressService.getNextSpinePackToRunV1` | partial | It proves a campaign route gate, not Act0 task progression/completion ownership. |
| `Act0W7VisibleAceHiddenRuntimeSessionOwnerV1` | yes for normal route closure | Hidden evidence owner; no Practice launch request; not a Home/Learn route owner. |
| `Act0W8DrawsHiddenRuntimeSessionOwnerV1` | yes for normal route closure | Hidden evidence owner and retired W8 meaning. |
| `Act0W9PriceHiddenRuntimeSessionOwnerV1` | yes for normal route closure | Hidden evidence owner and retired W9 meaning. |
| `content/worlds/world7-9/v1/**` | yes for runtime closure | Source inventory only; not enough without runtime consumption. |
| archive/donor roots | yes | Forbidden by mission and AGENTS. |

## 13. Repair And Targeted-Recheck Proof

Generic Act0 repair proof exists:

- `Act0RepairIntentV1` stores source world/lesson/task, choice, result, error type, missed signal, target world/lesson/task, mapping type, and reason code.
- Wrong/suboptimal choices create open repair intents; correct choices do not.
- Practice queue repair can clear matching intent when correct and keep it active when failed.
- Telemetry emits `repair_started`, `repair_completed`, `recheck_completed`, and `prove_completed`.

Admission blocker:

- Hidden W7-W9 owners expose `practiceLaunchRequest => null`.
- W8/W9 hidden repair focuses are tied to retired/noncanonical world meanings.
- The generic recheck path is not enough to prove reachable same-signal W7-W9 recheck for the normal Act0 route.

## 14. Completion / Persistence / Telemetry Proof

Completion:

- `_completeCurrentTask` adds `_selectedTaskId` to `_completedTaskIds`, updates lesson completion, and calls `_persistProgress`.
- `_progressWorld` computes world complete when all lessons are complete and makes the next world available if the previous world is complete.
- `_maybeShowBlockCompletionSummary` emits `session_complete`; when `isWorldComplete`, it emits `world_complete`.

Persistence:

- `_Act0PersistedProgressV1` serializes completed/skipped tasks, completed lessons, selected world/lesson/task, repair intents, evidence history, review history, session identity, repair outcome projection, and last-session learner state.
- `_restorePersistedProgress` rehydrates only valid world/lesson/task IDs from current Act0 state.

Telemetry:

- `Act0LessonRunnerShellV1` emits `task_shown`, `user_choice`, `decision_made`, `feedback_viewed`, and `task_result`.
- `Act0ShellPreviewScreenV1` emits session, lesson, practice, repair, recheck, prove, and world completion events through `Act0TelemetrySinkV1`.

Defect:

- W7+ completion payoff is intentionally not active: `hasWorldCompletionPayoff` only allows world numbers 2-6.

## 15. Defect Ledger

ID: `W7W9-CRA-001`

- world/seam: W7-W9 completion payoff.
- severity: P1.
- defect class: world completion without payoff or next-step ownership.
- exact canonical owner: `Act0BlockCompletionSummaryV1.hasWorldCompletionPayoff` in `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`.
- exact missing/broken contract: Required W7-W9 world completion payoff is absent; code restricts ordinary world payoff to W2-W6 and states W7+ payoff remains deferred.
- learner impact: A learner can complete W7-W9 through generic progression without a canonical world-specific payoff contract.
- deterministic evidence: `test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart` includes `World 7 is not yet covered by any completion payoff`.
- minimum bounded repair: Add W7-W9 payoff metadata and tests tied to canonical Act0 world identities, then prove W7/W8/W9 completion renders payoff and next-world copy.
- affected files: `lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart`; `test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart`.
- required validation: focused completion payoff tests plus Act0 route/telemetry tests.
- blocks W7-W9 deep content audit admission: yes.

ID: `W7W9-CRA-002`

- world/seam: W8 identity/source ownership.
- severity: P1.
- defect class: parallel route owners / retired mapping returned to active runtime.
- exact canonical owner: `canonicalTruthWorldIdentitiesV1` and `_act0PreviewWorlds` say `world_8 = Stack Depth And Risk`; `campaign_pack_registry_v1.dart` and `Act0W8DrawsHiddenRuntimeSessionOwnerV1` still own W8 draw-improvement content.
- exact missing/broken contract: No single canonical W8 owner reconciles Stack Depth And Risk with draw-improvement campaign/hidden evidence.
- learner impact: W8 admission evidence can prove the wrong semantic route.
- deterministic evidence: canonical truth marks `Draws as W8 primary route` retired, while campaign registry still maps `world8_spine_campaign_v1` to `_w8DrawImprovementCampaignPackV1`.
- minimum bounded repair: Either retire/remap the W8 campaign/hidden owners or explicitly mark them noncanonical and create Stack Depth And Risk campaign/hidden evidence owners.
- affected files: `lib/canonical/canonical_truth_map_v1.dart`; `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`; `lib/campaign/campaign_pack_registry_v1.dart`; `lib/ui_v2/act0_shell/act0_w8_draws_hidden_runtime_session_owner_v1.dart`.
- required validation: W8 route identity guard, ProgressService route guard, hidden-owner exclusion guard.
- blocks W7-W9 deep content audit admission: yes.

ID: `W7W9-CRA-003`

- world/seam: W9 identity/source ownership.
- severity: P1.
- defect class: parallel route owners / retired mapping returned to active runtime.
- exact canonical owner: `canonicalTruthWorldIdentitiesV1` and `_act0PreviewWorlds` say `world_9 = Tournament Pressure`; `campaign_pack_registry_v1.dart` and `Act0W9PriceHiddenRuntimeSessionOwnerV1` still own W9 call-price content.
- exact missing/broken contract: No single canonical W9 owner reconciles Tournament Pressure with call-price/pot-odds campaign/hidden evidence.
- learner impact: W9 admission evidence can prove the wrong semantic route.
- deterministic evidence: canonical truth marks `Price and Pot Odds as W9 primary route` retired, while campaign registry still maps `world9_spine_campaign_v1` to `_w9CallPriceCampaignPackV1`.
- minimum bounded repair: Either retire/remap the W9 campaign/hidden owners or explicitly mark them noncanonical and create Tournament Pressure campaign/hidden evidence owners.
- affected files: `lib/canonical/canonical_truth_map_v1.dart`; `lib/ui_v2/act0_shell/act0_shell_state_v1.dart`; `lib/campaign/campaign_pack_registry_v1.dart`; `lib/ui_v2/act0_shell/act0_w9_price_hidden_runtime_session_owner_v1.dart`.
- required validation: W9 route identity guard, ProgressService route guard, hidden-owner exclusion guard.
- blocks W7-W9 deep content audit admission: yes.

ID: `W7W9-CRA-004`

- world/seam: W7-W9 normal-route repair/recheck.
- severity: P2.
- defect class: repair receipt without reachable same-signal recheck.
- exact canonical owner: `Act0RepairIntentV1` and `Act0ShellPreviewScreenV1` generic repair/recheck flow.
- exact missing/broken contract: Generic Act0 repair/recheck exists, but W7-W9 hidden owners expose no Practice launch request and W8/W9 hidden owners are semantically stale.
- learner impact: Audit cannot prove a same-signal W7-W9 repair/recheck path for the normal learner route.
- deterministic evidence: each hidden runtime owner has `practiceLaunchRequest => null`; hidden tests assert no Practice launch request.
- minimum bounded repair: Add or explicitly bind W7-W9 canonical Act0 tasks to same-signal repair/recheck target specs, with W8/W9 meaning reconciled first.
- affected files: `lib/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart`; W7-W9 hidden owners; Act0 state task definitions.
- required validation: W7-W9 same-signal repair/recheck tests from normal Act0 tasks.
- blocks W7-W9 deep content audit admission: yes.

## 16. Per-World Terminal Disposition

- W7: `canonical_route_admitted_with_bounded_defects`.
- W8: `blocked_by_authority_conflict`.
- W9: `blocked_by_authority_conflict`.

## 17. Highest-EV Next Bounded Action

Run a W8/W9 canonical identity reconciliation wave before any W7-W9 deep content-quality audit:

1. Decide whether `ProgressService` campaign route and hidden evidence owners are still active for W8/W9 or must be explicitly marked noncanonical.
2. If active, rewrite/remap W8 campaign/hidden owners to Stack Depth And Risk and W9 owners to Tournament Pressure.
3. Add W7-W9 completion payoff ownership in `Act0BlockCompletionSummaryV1`.
4. Add focused guards proving W8/W9 source meanings match canonical truth and W7-W9 completion payoff exists.

## 18. Explicit Non-Claims

- No W7-W9 learning-quality score.
- No W7-W9 content closure.
- No W1-W6 hard closure.
- No Alpha closure.
- No Human QA result.
- No release readiness.
- No W13+ activation.
- No Modern Table change.
- No screenshot or visual-quality claim.

## 19. Validation Results

Graphify:

- `graphify query "W7 W8 W9 canonical Act0 route ownership progression repair recheck telemetry completion payoff next world"`: completed, but too broad and included legacy/archive route nodes.
- `graphify path "Act0ShellPreviewScreenV1" "ProgressService"`: no path found.
- `graphify path "Act0LessonRunnerShellV1" "Act0RepairIntentV1"`: found a path through Act0 shell preview references.
- `graphify query "world7_spine_campaign_v1 world8_spine_campaign_v1 world9_spine_campaign_v1 ProgressService Act0ShellPreviewScreenV1"`: completed and confirmed Act0/ProgressService route nodes are distinct.

Focused tests:

- `flutter test test/ui_v2/act0_w7_completion_pack_v1_test.dart test/ui_v2/act0_w8_internal_world_source_template_v1_test.dart test/ui_v2/act0_w8_hidden_evidence_consumption_internal_harness_v1_test.dart test/ui_v2/act0_w9_w10_internal_world_source_template_batch_v1_test.dart test/ui_v2/act0_w9_w10_hidden_evidence_consumption_internal_harness_v1_test.dart`: 33 passed.
- `flutter test test/guards/world7_campaign_routing_contract_test.dart test/guards/world8_campaign_routing_contract_test.dart test/guards/world9_campaign_routing_contract_test.dart test/guards/world_campaign_routing_matrix_contract_test.dart test/guards/w7_w10_route_status_alignment_contract_test.dart`: 17 passed.
- `flutter test test/ui_v2/act0_telemetry_sink_v1_test.dart test/ui_v2/act0_repair_intent_contract_v1_test.dart test/ui_v2/act0_repair_intent_lifecycle_v1_test.dart test/ui_v2/act0_wave3_canonical_repair_recheck_coverage_v1_test.dart test/ui_v2/act0_w2_w6_completion_payoff_v1_test.dart`: 90 passed.

Post-write validation:

- `flutter analyze`: passed, no issues found.
- `git diff --check`: passed.
- `git diff --cached --check`: passed.
- `graphify hook-check`: passed.

## 20. Token Efficiency Report

- exact_usage: unavailable.
- estimated_total_tokens: 52000.
- estimate_confidence: medium.
- estimated input-context tokens: 39000.
- estimated reasoning/output tokens: 13000.
- estimate basis: attachment size, targeted `rg`/`sed` output volume, Graphify output, test output, and artifact length.
- files opened: 21 source/test/doc files plus the attached mission and memory registry excerpt.
- files read in full: none of the large source files; the mission attachment was read in full.
- targeted searches: 14.
- broad searches: 1 overly broad `rg` over source/tests/docs; output was truncated and then replaced with targeted searches.
- Graphify queries: 4.
- commands run: 23 before artifact creation.
- tests run: 3 focused `flutter test` invocations, 140 total passing tests.
- generated log lines versus lines actually inspected: large `rg` and test logs generated thousands of lines; only route-relevant snippets were inspected.
- largest token sinks: broad `rg` over Act0/source/tests; `act0_shell_preview_screen_v1.dart` targeted excerpts; test output.
- repeated investigation: low; one broad query was narrowed after it pulled legacy/archive nodes.
- avoidable token cost: the first source/test `rg` was too broad.
- whether another discovery pass is required: yes, after a repair wave, specifically for W8/W9 source-owner reconciliation and W7-W9 payoff proof.
- contracts closed per estimated 10k tokens: about 0.6; this audit closes repository preflight, route-owner classification, and blocker identification but does not admit the deep content audit.
