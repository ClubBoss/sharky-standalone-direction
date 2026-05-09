# R74 Authoritative User-Visible Surface Registry v1

## Milestone purpose/scope recap
- Build one practical, project-level registry for user-visible phase ownership.
- Consolidate route/screen/helper/state truth now spread across R67-R73 artifacts.
- Ensure future fixes target authoritative surfaces and avoid secondary/shadow paths by default.
- Scope is doc-only registry + guidance; no runtime refactor, archive, or delete actions.

## Evidence basis reconciled (PIEC)
- SSOT and closeouts reconciled: R67-R73.
- Authoritative route/phase evidence source docs:
  - `docs/_reviews/r67_route_screen_truth_lock_v1.md`
  - `docs/_reviews/r68_observed_symptom_branch_proof_v1.md`
  - `docs/_reviews/r69_act0_guidance_closeout_audit_v1.md`
  - `docs/_reviews/r70_blindspot_and_action_seam_closeout_v1.md`
  - `docs/_reviews/r71_authoritative_surface_audit_v1.md`
  - `docs/_reviews/r72_authoritative_path_registry_audit_v1.md`
  - `docs/_reviews/r73_action_bar_legality_closeout_v1.md`
- Runtime ownership surfaces reconciled:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
  - `lib/ui_v2/screens/session_result_screen.dart`
  - `lib/services/progress_service.dart`
- Contract surfaces reconciled (representative):
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/guards/world1_act0_to_spine_transition_contract_test.dart`
  - `test/guards/world1_foundations_microtask_contract_test.dart`
  - `test/ui_v2/session_result_screen_contract_test.dart`
  - `test/services/review_queue_v1_test.dart`
  - world campaign routing matrix and map-node state contracts.

## Authoritative user-visible surface registry

### 1) Entry / map / home / today-plan
- Canonical route entry:
  - map shell primary CTA (`today_plan_start_cta` / `world_campaign_next_pack_cta`).
- Authoritative screen/widget owner:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
- Authoritative builder/helper owner:
  - `_handleCampaignStartNowActionV1()`
  - `_openNextCampaignPackFromSsoT()`
- Authoritative state/source-of-truth owner:
  - `lib/services/progress_service.dart` progression and next-pack state.
- Main user-visible responsibility:
  - expose one dominant start path and launch the canonical next session.
- Current tests/contracts:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/guards/world_campaign_routing_matrix_contract_test.dart`
  - `test/ui_v2/world1_map_node_states_contract_test.dart`

### 2) Start-now / route resolution / first-pack launch
- Canonical route entry:
  - start-now dispatch on map/home.
- Authoritative screen/widget owner:
  - `ui_v2_progress_map_screen_v2.dart`
- Authoritative builder/helper owner:
  - `_resolveEarliestIncompleteWorld1PackIdV1()`
  - `_openNextCampaignPackFromSsoT()`
  - `_openCampaignPack(...)`
- Authoritative state/source-of-truth owner:
  - `ProgressService` + world1 canonical module ordering.
- Main user-visible responsibility:
  - deterministic first-pack selection (Act0-first on fresh install) and launch.
- Current tests/contracts:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/guards/world1_act0_to_spine_transition_contract_test.dart`

### 3) Onboarding / Act0 / initial guidance
- Canonical route entry:
  - first opened `world1_act0_table_literacy` session.
- Authoritative screen/widget owner:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Authoritative builder/helper owner:
  - `_seatQuizGuidanceForTargetV1(...)`
- Authoritative state/source-of-truth owner:
  - runner mode and seat-target state inside foundations runner.
- Main user-visible responsibility:
  - first-user guidance framing for the initial seat-recognition flow.
- Current tests/contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart` (Act0 seat guidance and deterministic wording contracts).

### 4) Runner seat-quiz phase
- Canonical route entry:
  - `_CampaignRunnerMode.seatQuiz` in foundations runner.
- Authoritative screen/widget owner:
  - `world1_foundations_microtask_runner_screen.dart`
- Authoritative builder/helper owner:
  - seat instruction/idle/title composition through `_seatQuizGuidanceForTargetV1(...)` family.
- Authoritative state/source-of-truth owner:
  - `_selectedSeatId`, `_seatQuizTargetSeatIdV1`, `_resolveCampaignRunnerModeForCurrentStep()`.
- Main user-visible responsibility:
  - highlight target seat, guidance line, and lock-in behavior.
- Current tests/contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart` seat-loop/highlight/instruction coverage.

### 5) Runner action-decision phase
- Canonical route entry:
  - `_CampaignRunnerMode.handLoop` in foundations runner.
- Authoritative screen/widget owner:
  - `world1_foundations_microtask_runner_screen.dart`
- Authoritative builder/helper owner:
  - `_buildCampaignActionChips(...)`
  - outcome helper family (`Expected` / `Correct` / `Why`).
- Authoritative state/source-of-truth owner:
  - step `allowedActions`, action-state values (`toCall`, `currentBet`, `pot`), and runner decision model.
- Main user-visible responsibility:
  - legal action affordances, deterministic action semantics, and action outcome framing.
- Current tests/contracts:
  - `test/guards/world1_foundations_microtask_contract_test.dart` action-contract truth invariants.

### 6) Result / finish / up-next phase
- Canonical route entry:
  - runner completion into result screen.
- Authoritative screen/widget owner:
  - `lib/ui_v2/screens/session_result_screen.dart`
- Authoritative builder/helper owner:
  - `_primaryCtaLabelV1(...)`
  - `_resultWhyLineV1()`
  - `_upNextFocusLineV1()`
- Authoritative state/source-of-truth owner:
  - result-screen routing state + `ProgressService` progression/queue state.
- Main user-visible responsibility:
  - finish framing, primary CTA truth, and next-step focus line.
- Current tests/contracts:
  - `test/ui_v2/session_result_screen_contract_test.dart`

### 7) Return-to-map / progression continuity
- Canonical route entry:
  - result CTA/back path to map and next module.
- Authoritative screen/widget owner:
  - `session_result_screen.dart` + map screen navigation sink.
- Authoritative builder/helper owner:
  - result navigation handlers and map open-next handlers.
- Authoritative state/source-of-truth owner:
  - `ProgressService` completion/progression and due-state transitions.
- Main user-visible responsibility:
  - coherent return path and stable next-step continuity.
- Current tests/contracts:
  - `test/ui_v2/session_result_screen_contract_test.dart`
  - `test/guards/world_campaign_map_home_contract_test.dart`

### 8) Secondary but user-visible paths

#### 8a) Checkpoint flow
- Canonical route entry:
  - map checkpoint strip / checkpoint node open.
- Authoritative owners:
  - map: `ui_v2_progress_map_screen_v2.dart`
  - runner checkpoint mode: `world1_foundations_microtask_runner_screen.dart`
  - state: `ProgressService` checkpoint flags/seeds.
- Current tests/contracts:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/guards/world1_checkpoint_entry_contract_test.dart`
  - `test/ui_v2/session_result_screen_contract_test.dart`

#### 8b) Review queue flow
- Canonical route entry:
  - map review strip / review CTA gate.
- Authoritative owners:
  - map entry: `ui_v2_progress_map_screen_v2.dart`
  - queue state and deterministic selection: `progress_service.dart`
  - runner consumption: `world1_foundations_microtask_runner_screen.dart`.
- Current tests/contracts:
  - `test/services/review_queue_v1_test.dart`
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - runner review-related contracts in `world1_foundations_microtask_contract_test.dart`.

#### 8c) World transition / next lesson handoff
- Canonical route entry:
  - result primary CTA (`NEXT LESSON`/`BACK TO MAP`/`REVIEW`) semantics.
- Authoritative owners:
  - `session_result_screen.dart` + `ProgressService.nextCampaignPackIdV1` pathing.
- Current tests/contracts:
  - `test/ui_v2/session_result_screen_contract_test.dart`
  - `test/guards/world_campaign_map_home_contract_test.dart`

#### 8d) Track handoff
- Canonical route entry:
  - world10 completion path on result screen.
- Authoritative owners:
  - `session_result_screen.dart` track chooser/transition
  - `progress_service.dart` track state.
- Current tests/contracts:
  - track-route coverage in `test/ui_v2/session_result_screen_contract_test.dart`

## Branch classification by phase

### 1) Entry / map / home / today-plan
- AUTHORITATIVE:
  - `ui_v2_progress_map_screen_v2.dart` start-now/next-pack CTA handlers.
- ALLOWED SECONDARY:
  - map node preview overlay/sheet presentation components.
- AVOID-AS-PRIMARY:
  - any runner-local session launch bypassing map start-now path for first-user repair work.

### 2) Start-now / route resolution / first-pack launch
- AUTHORITATIVE:
  - `_resolveEarliestIncompleteWorld1PackIdV1()` + `_openNextCampaignPackFromSsoT()`.
- FALLBACK ONLY:
  - modal node preview open paths (UI affordance, not primary first-user owner).
- AVOID-AS-PRIMARY:
  - direct hardcoded pack launch for first-user bugfixes.

### 3) Onboarding / Act0 / initial guidance
- AUTHORITATIVE:
  - `_seatQuizGuidanceForTargetV1(...)` family.
- LEGACY / SHADOW RISK:
  - pre-consolidation seat-guidance branch fragments; risk documented in R71/R72.
- AVOID-AS-PRIMARY:
  - adding new guidance wording in compatibility or scattered fallback text paths.

### 4) Runner seat-quiz phase
- AUTHORITATIVE:
  - seat-quiz mode branch and consolidated guidance helper in foundations runner.
- ALLOWED SECONDARY:
  - presentation wrappers that consume authoritative guidance output.
- AVOID-AS-PRIMARY:
  - branch-specific ad-hoc seat instructions outside the guidance helper.

### 5) Runner action-decision phase
- AUTHORITATIVE:
  - `_buildCampaignActionChips(...)` and adjacent action outcome helpers.
- ALLOWED SECONDARY:
  - compact/right-label presentation variants that do not redefine legality.
- AVOID-AS-PRIMARY:
  - editing content-only prompts to fix action legality symptoms that are runtime-affordance issues.

### 6) Result / finish / up-next phase
- AUTHORITATIVE:
  - `session_result_screen.dart` CTA/why/focus helpers.
- INSUFFICIENTLY PROVEN:
  - additional residual duplication beyond already-closed R64 family.
- AVOID-AS-PRIMARY:
  - trying to fix finish semantics from map screen copy only.

### 7) Return-to-map / progression continuity
- AUTHORITATIVE:
  - result navigation + `ProgressService` progression state.
- ALLOWED SECONDARY:
  - map render-only status chips/labels.
- AVOID-AS-PRIMARY:
  - local route forks that bypass service-owned progression decisions.

### 8) Secondary paths
- Checkpoint:
  - AUTHORITATIVE: map strip/node entry + runner checkpoint mode + `ProgressService` checkpoint state.
- Review queue:
  - AUTHORITATIVE: `ProgressService` queue/priority + map entry + runner consume.
- World transition / next lesson:
  - AUTHORITATIVE: result primary CTA routing + `ProgressService` next-pack resolver.
- Track handoff:
  - AUTHORITATIVE: result track chooser + `ProgressService` track state.

## Future-fix guidance (target vs avoid)

### Phase 1-2 (entry + start-now)
- MUST target:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - `lib/services/progress_service.dart`
- AVOID unless re-authorized:
  - runner screen for first-user pack-selection logic.
- Watch risk:
  - first-user truth drift if non-map launch routes are edited without start-now contract checks.
- Ownership re-check needed before editing:
  - quick check only when fix touches both map and service routing.

### Phase 3-4 (Act0 + seat-quiz)
- MUST target:
  - `_seatQuizGuidanceForTargetV1(...)` family in `world1_foundations_microtask_runner_screen.dart`.
- AVOID unless re-authorized:
  - scattered fallback text branches for seat guidance.
- Watch risk:
  - reintroducing parallel guidance families.
- Ownership re-check needed before editing:
  - yes, quick re-check if adding any new instruction surface.

### Phase 5 (action-decision)
- MUST target:
  - `_buildCampaignActionChips(...)` and immediate action outcome helpers in foundations runner.
- AVOID unless re-authorized:
  - unrelated prompt copy or map-level copy to solve legality/affordance defects.
- Watch risk:
  - label/affordance mismatch between expected-action helpers and visible chip labels.
- Ownership re-check needed before editing:
  - yes, if changing both action labels and expected-action contract helpers.

### Phase 6-7 (result + progression return)
- MUST target:
  - `session_result_screen.dart` CTA/why/focus helpers
  - `progress_service.dart` for progression decisions.
- AVOID unless re-authorized:
  - runner-side finish copy as primary owner of result decisions.
- Watch risk:
  - duplicating CTA decision logic across result and map.
- Ownership re-check needed before editing:
  - yes, if touching both result CTA semantics and map continuation labels.

### Phase 8 (checkpoint/review/world transition/track)
- MUST target:
  - checkpoint/review state logic in `progress_service.dart`
  - user entry points in map/result surfaces.
- AVOID unless re-authorized:
  - one-off route forks bypassing service-owned due-state and queue logic.
- Watch risk:
  - hidden divergence between entry screen labels and service-owned next-step decisions.
- Ownership re-check needed before editing:
  - yes, for any cross-phase change involving checkpoint/review/track routing.

## Deferred consolidation guidance

### Proven duplicate/parallel hotspots already addressed
- Act0 seat-quiz guidance duplication hotspot:
  - proven in R71, consolidated to authoritative guidance helper.

### Residual duplication risks not fully proven
- Potential finish/result wording composition overlap outside R64-closed family.
- Potential secondary presentation wrappers drifting from authoritative helper output in runner.

### Future freeze/archive/delete candidates (not executed in R74)
- Candidate freeze:
  - compatibility guidance wrapper paths in runner that should remain pass-through only.
- Candidate archive/delete later:
  - any obsolete seat-guidance branch fragments once contracts show no remaining call-site dependency.

### VALUE TO EXTRACT BEFORE RETIREMENT
- If future audit finds non-authoritative branch variants with better pedagogical phrasing, extract that phrasing into the authoritative helper first, then retire the branch.
- If non-authoritative wrappers include stronger deterministic guard conditions, extract those guard conditions into authoritative seam tests before retirement.

## Practical usage rule for future engineers
- When fixing a first-user visible bug:
  1) map symptom to phase in this registry,
  2) edit only files listed as MUST target for that phase,
  3) avoid listed non-authoritative paths unless explicitly re-authorized by a new route/ownership proof milestone.

## Open risks
- Registry can drift if new route entry points are added without updating this document.
- Some residual duplication hypotheses remain intentionally labeled as unproven.

## Anti-drift note
- R74 is registry consolidation only.
- No runtime, content, or structural cleanup was executed in this milestone.
