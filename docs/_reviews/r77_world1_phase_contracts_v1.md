# R77 World1 Phase Contracts v1

## Scope
- Main first-user World1 phases only.
- Phase truth rules and ownership contracts, no implementation rewrite.

## 1) Map / Start-Now
- Authoritative owner:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - `lib/services/progress_service.dart`
- Allowed outputs:
  - deterministic `today_plan_start_cta` / `world_campaign_next_pack_cta` path,
  - launch of earliest incomplete World1 pack.
- Forbidden outputs:
  - direct launch to non-canonical pack in fresh state,
  - multi-primary CTA conflict for same route decision.
- CTA rules:
  - one dominant primary start CTA in default state.
- Minimal current test coverage:
  - `test/guards/world_campaign_map_home_contract_test.dart`
  - `test/ui_v2/today_plan_routing_reason_contract_test.dart`
- Future contract gap:
  - compact end-to-end phase lock from start-now to Act0-first runner handoff.

## 2) Act0 guidance
- Authoritative owner:
  - runner screen guidance seam `_seatQuizGuidanceForTargetV1(...)`.
- Allowed outputs:
  - short purposeful seat/position guidance without answer leakage.
- Forbidden outputs:
  - command-only fallback phrasing drift in authoritative seat-quiz branch.
- CTA rules:
  - no prelude dead-end gating before first actionable seat interaction.
- Minimal current test coverage:
  - `test/guards/world1_foundations_microtask_contract_test.dart` (R62/R63/R69 families).
- Future contract gap:
  - scenario field-level linkage between `learning_objective` and rendered guidance family.

## 3) Seat-quiz phase
- Authoritative owner:
  - runner seat mode state + seat quiz render branches.
- Allowed outputs:
  - highlighted target, deterministic expected/chosen feedback, stable progression.
- Forbidden outputs:
  - mixed action-decision affordances while in seat mode,
  - conflicting guidance sources for same seat target.
- CTA rules:
  - lock-in/continue behavior deterministic and mode-correct.
- Minimal current test coverage:
  - foundations guard suite seat quiz/layout/flow contracts.
- Future contract gap:
  - explicit scenario `scenario_kind=seat_quiz` completeness validator.

## 4) Action-decision phase
- Authoritative owner:
  - `_buildCampaignActionChips(...)` + legality/action state + expected-family resolver.
- Allowed outputs:
  - legal affordance set for state,
  - deterministic expected-family and mismatch semantics.
- Forbidden outputs:
  - facing-bet `CHECK` or generic `BET` contradictions,
  - expected-family derived from illegal explicit metadata.
- CTA rules:
  - action commit should enter outcome phase with deterministic single outcome surface.
- Minimal current test coverage:
  - foundations action-state truth + expected-line normalization + mismatch contracts.
- Future contract gap:
  - validator-time expected/legal/acceptable coherence check for migrated pilot scenarios.

## 5) Footer/outcome feedback phase
- Authoritative owner:
  - outcome helper chain in runner (`Expected`, `Correct`, `Why`, `Because`).
- Allowed outputs:
  - coherent legal expected action + matching why-family,
  - deterministic mismatch explanation for selected action.
- Forbidden outputs:
  - illegal `Expected` for current action state,
  - why-family contradictions against rendered expected-family.
- CTA rules:
  - single primary continue/retry semantics per outcome context.
- Minimal current test coverage:
  - foundations contracts around expected/why/focus suppression and mismatch families (R75/R76).
- Future contract gap:
  - scenario-truth compiler check to reject contradiction before runtime.

## 6) Result/finish phase
- Authoritative owner:
  - `lib/ui_v2/screens/session_result_screen.dart`.
- Allowed outputs:
  - one coherent status + why line + next-step CTA hierarchy.
- Forbidden outputs:
  - duplicate/contradictory completion framing,
  - CTA semantics that conflict with progression state.
- CTA rules:
  - label hierarchy remains deterministic (`NEXT LESSON`, `REVIEW`, `BACK TO MAP` families).
- Minimal current test coverage:
  - `test/ui_v2/session_result_screen_contract_test.dart`.
- Future contract gap:
  - phase-level assertion tying result wording family to progression state categories.

## 7) Progression return phase
- Authoritative owner:
  - result navigation + `ProgressService` progression/routing state.
- Allowed outputs:
  - deterministic return to map or next module consistent with completion state.
- Forbidden outputs:
  - stale route return that contradicts completion/review/checkpoint status.
- CTA rules:
  - return path must preserve one clear next-step decision.
- Minimal current test coverage:
  - session result contracts + map/home contracts + review queue service contracts.
- Future contract gap:
  - compact first-user phase chain contract to detect ownership drift across map->runner->result->map.
