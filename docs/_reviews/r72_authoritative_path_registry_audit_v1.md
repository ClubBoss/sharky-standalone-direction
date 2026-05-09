# R72 Authoritative Path Registry Audit v1

## Milestone purpose/scope recap
- Audit authoritative ownership across main user-visible flow phases and critical secondary paths.
- Prove where presentation/routing ownership is single-source vs duplicated/parallel/shadow.
- Produce a concrete consolidation plan so future fixes land on real user-path seams.
- Scope is audit + plan (doc-first), no broad runtime refactor.

## Phase-by-phase authoritative map

### 1) Entry / map / home / today-plan
- Canonical route entry:
  - `UiV2ProgressMapScreenV2` start controls.
- Authoritative screen owner:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
- Authoritative builder/helper owners:
  - `_handleCampaignStartNowActionV1()`
  - `_openNextCampaignPackFromSsoT()`
  - `_resolveEarliestIncompleteWorld1PackIdV1()`
- Authoritative state owner:
  - progression/session completion state in `ProgressService`.
- Contract coverage:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - world campaign routing matrix/map-node state tests.

### 2) Start-now / route resolution / first-pack launch
- Canonical route entry:
  - map CTA keys `today_plan_start_cta` / `world_campaign_next_pack_cta`.
- Authoritative screen owner:
  - `ui_v2_progress_map_screen_v2.dart`
- Authoritative builder/helper owners:
  - `_handleCampaignStartNowActionV1()`
  - `_openNextCampaignPackFromSsoT()`
  - `_openCampaignPack(...)`
- Authoritative state owner:
  - world1 canonical order + pack completion in `ProgressService`.
- Contract coverage:
  - `world_campaign_map_home_contract_test.dart`
  - `world1_act0_to_spine_transition_contract_test.dart`

### 3) Onboarding / Act0 / initial guidance
- Canonical route entry:
  - first launched pack `world1_act0_table_literacy`.
- Authoritative screen owner:
  - `world1_foundations_microtask_runner_screen.dart`
- Authoritative builder/helper owners:
  - seat-quiz guidance family now consolidated through `_seatQuizGuidanceForTargetV1(...)`.
- Authoritative state owner:
  - `_currentCampaignRunnerMode` and seat target derivation in runner state.
- Contract coverage:
  - `test/guards/world1_foundations_microtask_contract_test.dart` (seat guidance and mode contracts).

### 4) Runner seat-quiz phase
- Canonical route entry:
  - runner in `_CampaignRunnerMode.seatQuiz`.
- Authoritative screen owner:
  - `world1_foundations_microtask_runner_screen.dart`
- Authoritative builder/helper owners:
  - seat quiz target + expected seat derivation,
  - seat quiz instruction render paths (`table`/`header`) using consolidated guidance helper.
- Authoritative state owner:
  - runner-local seat quiz state (`_selectedSeatId`, `_seatQuizTargetSeatIdV1`, mode resolver).
- Contract coverage:
  - `world1_foundations_microtask_contract_test.dart` seat loop/instruction/highlight/auto-advance coverage.

### 5) Runner action-decision phase
- Canonical route entry:
  - runner in `_CampaignRunnerMode.handLoop`.
- Authoritative screen owner:
  - `world1_foundations_microtask_runner_screen.dart`
- Authoritative builder/helper owners:
  - `_buildCampaignActionChips(...)`
  - action label/allowed-action mapping
  - outcome line builders for `Expected/Correct/Why`.
- Authoritative state owner:
  - step `allowedActions`, runner action UI state, `toCall/currentBet/pot`.
- Contract coverage:
  - `world1_foundations_microtask_contract_test.dart` action-contract suites.

### 6) Result / finish / up-next phase
- Canonical route entry:
  - transition from runner completion to `SessionResultScreen`.
- Authoritative screen owner:
  - `lib/ui_v2/screens/session_result_screen.dart`
- Authoritative builder/helper owners:
  - `_primaryCtaLabelV1(...)`
  - `_resultWhyLineV1()`
  - `_upNextFocusLineV1()`
- Authoritative state owner:
  - result-screen state + `ProgressService` next-session routing.
- Contract coverage:
  - `test/ui_v2/session_result_screen_contract_test.dart`.

### 7) Return-to-map / progression continuity
- Canonical route entry:
  - result screen primary/back CTA navigation.
- Authoritative owner:
  - `SessionResultScreen` navigation handlers + `ProgressService`.
- Authoritative state owner:
  - progression/checkpoint/review flags in `ProgressService`.
- Contract coverage:
  - `session_result_screen_contract_test.dart`
  - map/progression contracts.

### 8) Secondary critical flows
- Checkpoint flow:
  - Route owners:
    - map checkpoint strip/entry (`ui_v2_progress_map_screen_v2.dart`)
    - checkpoint pack/routing state (`ProgressService`)
    - checkpoint runner mode in foundations runner.
  - Coverage:
    - `world_campaign_map_home_contract_test.dart`
    - checkpoint entry/locked/marker tests
    - session result checkpoint continuity tests.
- Review queue flow:
  - Route owners:
    - map review-gate strip + CTA (`ui_v2_progress_map_screen_v2.dart`)
    - review queue state/priority in `ProgressService`
    - review pass execution in foundations runner.
  - Coverage:
    - map home contracts
    - `test/services/review_queue_v1_test.dart`
    - runner review queue contracts.
- World transition / next lesson handoff:
  - Owner:
    - `SessionResultScreen` primary CTA routing and `ProgressService.nextCampaignPackIdV1`.
  - Coverage:
    - result contract tests + map home today-plan contracts.
- Track handoff (world10):
  - Owner:
    - `SessionResultScreen` track-choice routing.
  - Coverage:
    - track-choice tests in `session_result_screen_contract_test.dart`.

## Duplication / shadow / legacy findings

### AUTHORITATIVE and CLEAN
- Entry/map and start-now dispatch chain.
- Action-decision action-bar branch ownership.
- Result CTA/why ownership.
- Progression-return ownership.
- Checkpoint/review/track route ownership in service + map/result entry points.

### DUPLICATED / PARALLEL (confirmed)
- Phase: Onboarding/Act0 + seat-quiz guidance presentation.
- Files:
  - `lib/ui_v2/screens/world1_foundations_microtask_runner_screen.dart`
- Overlapping responsibilities:
  - multiple branches composing similar instruction text (target/fallback/preview/header/table/overlay/override families).
- Authoritative seam after R71:
  - `_seatQuizGuidanceForTargetV1(...)` for seat-quiz guidance family.
- Secondary/fallback branches:
  - compatibility call sites and non-seat-quiz prompt overlays.
- Migration status:
  - bounded consolidation completed in R71 for seat-quiz guidance family.
- Later action:
  - freeze non-authoritative seat-quiz wording branches from introducing new phrasing.

### LEGACY / SHADOW (bounded)
- Legacy-seam risk:
  - old seat-quiz instruction call sites can still read through compatibility wrapper.
- Why shadow risk persists:
  - wrapper prevents breakage but can hide drift if future edits bypass authoritative helper.
- Current recommendation:
  - keep wrapper temporarily; mark for future removal once direct call-site cleanup is safe and contract-backed.

### INSUFFICIENTLY PROVEN
- No additional phase has strong overlapping-responsibility proof at R72 depth.
- Adjacent complexity exists, but not enough to classify as active duplication root-cause.

## Authoritative ownership registry (operational)

| Phase | Authoritative route | Authoritative screen | Authoritative builder/helper | Authoritative state owner | Allowed secondary branches | Disallowed/misleading branches | Fix target files | Avoid-as-primary files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Entry/map/home | map start-now CTA | `ui_v2_progress_map_screen_v2.dart` | `_handleCampaignStartNowActionV1`, `_openNextCampaignPackFromSsoT` | `ProgressService` completion/progression | map node preview UI only | ad-hoc launch bypasses | `ui_v2_progress_map_screen_v2.dart`, `progress_service.dart` | any non-map ad-hoc launcher |
| Start-now resolution | start-now -> first pack | map screen | `_resolveEarliestIncompleteWorld1PackIdV1`, `_openCampaignPack` | `ProgressService.kWorld1CanonicalModuleOrder` | none | spine-first assumptions on fresh install | `ui_v2_progress_map_screen_v2.dart`, `progress_service.dart` | runner-local pack selection |
| Act0 initial guidance | first pack launch | runner screen | `_seatQuizGuidanceForTargetV1` | runner mode + target seat derivation | compatibility wrapper (temporary) | new seat-quiz wording outside helper | `world1_foundations_microtask_runner_screen.dart` | scattered seat-quiz text literals |
| Seat-quiz phase | runner seat mode | runner screen | seat target + seat quiz instruction render paths | runner seat state | header/table surfaces using same guidance family | branch-specific wording forks | `world1_foundations_microtask_runner_screen.dart` | adding new fallback text seams |
| Action phase | runner hand-loop mode | runner screen | `_buildCampaignActionChips`, outcome line builders | runner action state + `allowedActions` | none | alternate action UI injection | `world1_foundations_microtask_runner_screen.dart` | non-action-mode overlays as action truth |
| Result/finish | runner -> result | `session_result_screen.dart` | `_primaryCtaLabelV1`, `_resultWhyLineV1`, `_upNextFocusLineV1` | result screen + `ProgressService` | confirmation dialogs only | parallel CTA label sources | `session_result_screen.dart`, `progress_service.dart` | runner-side finish CTA ownership |
| Return/progression | result CTA -> map/next | result + map + service | result navigation handlers | `ProgressService` | none | custom route forks bypassing service | `session_result_screen.dart`, `progress_service.dart` | local navigation hacks |
| Checkpoint flow | map strip / checkpoint entry | map + runner | checkpoint entry handlers | `ProgressService` checkpoint state | selector helper for checkpoint pack only | manual checkpoint routing bypass | map/result/progress service | ad-hoc direct checkpoint launch |
| Review queue flow | map review strip + review routing | map + runner | review queue launch/consume handlers | `ProgressService` review queue state | none | direct review launch bypassing due logic | map/runner/progress service | arbitrary review-only navigation |
| Track handoff | world10 result route | result screen | track chooser handlers | `ProgressService` track prefs | none | external track route bypass | `session_result_screen.dart`, `progress_service.dart` | non-result track routing |

## Consolidation plan

### A) Must consolidate now
- None beyond completed R71 seat-quiz guidance-family consolidation.

### B) Safe to freeze/deprecate
- Seat-quiz instruction compatibility wrapper path:
  - freeze as pass-through only; no new wording logic permitted there.
- Branch-specific instruction text forks for seat-quiz phase:
  - freeze from introducing unique phrasing outside authoritative helper.

### C) Archive/delete later
- Remove obsolete wrapper call-site usage once:
  - all seat-quiz instruction consumers call authoritative helper directly,
  - one targeted contract confirms no behavior change.

### D) Acceptable as-is
- Start-now resolution chain.
- Action-bar/action-semantics ownership path.
- Result CTA/why ownership path.
- Checkpoint/review/track ownership paths.

### E) Needs further proof
- Whether any result-surface wording family is duplicated in ways that impact first-user delta.
- Whether any non-seat-quiz coach overlay path can override authoritative messaging during first 3-5 minutes.

## Guard strategy (deterministic, lightweight)
- Registry-as-contract:
  - keep this R72 registry as reference for where fixes must land.
- Code annotations (future tiny change):
  - add short comments on authoritative helpers in map/runner/result indicating “primary ownership seam.”
- Contract guard extensions (next bounded milestone):
  - seat-quiz guidance ownership contract: fail if command-style or non-authoritative phrasing appears in seat-quiz mode.
  - route ownership contract: start-now must remain map-owned and service-resolved.
- Review checklist rule:
  - PR touching first-user flow must state “authoritative seam touched” and cite registry row.

## Open-risk list
- High-local-complexity runner still has multiple visual surfaces; without guard tightening, drift can re-enter through secondary branches.
- Registry drift risk if new routes are added without updating ownership map.

## Anti-drift note
- R72 intentionally avoids broad refactor work.
- Output is a concrete ownership map + consolidation plan so future implementation lands on authoritative seams only.
