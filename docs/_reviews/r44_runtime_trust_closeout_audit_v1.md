# R44 Runtime Trust Closeout Audit v1

## Milestone purpose/scope recap
- Milestone intent: close one bounded map/header trust mismatch around global `Top leak` wording.
- Scope held: one deterministic presentation rule only; no broad map redesign, no multi-family trust cleanup, no schema/dependency changes.

## Verification inventory summary
- Surface inventory:
  1) Session result recommendation reason (`SessionResultScreen` + `FocusRecommendationRouterV1`) already gated by R43 to campaign context.
  2) Global map/header learning details (`UiV2ProgressMapScreenV2`) still used literal `Top leak: ...` wording.
  3) Today-plan strip uses `today_plan_top_leak_*` keys but not direct `Top leak:` user text in the selected mismatch path.
- Trigger condition for mismatch: map campaign details render global learning stats text independent of session-type recommendation context.
- Risk finding: `Top leak` wording in this global context can be interpreted as direct session recommendation/trust signal where context is aggregate, not per-session strategic guidance.
- Existing signal/contracts reused: R43 recommendation gating preserved in session-result contracts; map wording isolated as a separate presentation surface.

## Selected trust rule and why it won
- Selected rule: relabel global map/header wording from `Top leak: <value>` to neutral `Top focus: <value>`.
- Why selected:
  - deterministic and single-surface,
  - low regression risk,
  - fences misleading wording without hiding useful aggregate signal,
  - preserves R43 campaign/session-result trust behavior.

## Exact closure evidence
- Runtime change:
  - `lib/ui_v2/map/ui_v2_progress_map_screen_v2.dart`
  - Added deterministic helper `mapLearningTopFocusLabelV1(String)` and applied it in map learning details line.
- Contract proof:
  - `test/ui_v2/map_top_leak_context_label_contract_test.dart` ensures map/global label is `Top focus: ...` and never `Top leak: ...`.
  - Existing strategic behavior retained through prior R43 contracts (`test/ui_v2/session_result_screen_contract_test.dart`, `test/personalization/focus_recommendation_router_v1_test.dart`).

## Proof recap (gates + targeted test)
- `flutter analyze` -> PASS
- `./tools/fast_loop_world1_v1.sh` -> PASS
- `flutter test test/ui_v2/map_top_leak_context_label_contract_test.dart` -> PASS
- `flutter test test/guards/world_campaign_map_home_contract_test.dart --plain-name "campaign map keeps learning stats in details only"` -> PASS

## Open-risk list
- Today-plan naming keys still contain `top_leak` in identifiers (internal key names), though selected user-facing mismatch is fenced.
- Verify-first onboarding/binding duplication candidate remains deferred.

## Explicit defer list
- Internal key-name normalization for `top_leak` identifiers.
- Onboarding/binding verify-then-fix class.
- Remaining learning-truth/content-integrity families outside this runtime presentation slice.

## Anti-drift note
- R44 closes exactly one map/header wording mismatch class.
- Do not extend this closeout into multi-surface runtime redesign or content cleanup batches.

## Ambiguous P0 status
- No ambiguous P0 remains for the selected R44 map/header trust rule.

## Transition note (next focus only)
- R45 must be defined before execution starts, using evidence-first weakest-link selection from deferred classes.
