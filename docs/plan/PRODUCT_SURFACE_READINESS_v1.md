# PRODUCT_SURFACE_READINESS_v1
Status: ACTIVE
Purpose: subordinate learner-facing surface-quality control layer for current
`main`.
Last updated: 2026-04-03

## Purpose / authority

This document sits beneath:

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md`
- `docs/plan/WORLD_READINESS_REGISTRY_v1.md`

Use it to answer the product-surface questions the main readiness SSOT and the
world registry should not carry directly:

- which learner-facing surfaces define the first-user product route
- what release-grade means for those surfaces
- which failures are source, layout, copy, hierarchy, payoff, access-state, or
  degraded-path problems
- which surfaces can be audited mechanically versus which still need human
  proof

Authority / non-authority:

- `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` remains the top readiness,
  scoring, and bottleneck authority.
- `docs/plan/WORLD_READINESS_REGISTRY_v1.md` remains the subordinate
  world-quality layer.
- This document is the subordinate learner-facing surface-quality layer.
- It does not create a second readiness verdict, weighted score, or competing
  control plane.

## Canonical first-user spine

The release-critical first-user product spine on current `main` is:

1. `Today Plan / intake`
2. `first-user intro / trust-primer`
3. `first runner`
4. `first result / next step`
5. `premium interruption / access state` when present

This spine is one governed product-quality route, not a set of disconnected
screens.

## Degraded-state rule

Release-grade evaluation covers the happy path plus:

- empty states
- partial states
- fallback states
- stale/internal/beta text leakage
- locked/unlocked premium states

A surface is not release-grade if only the primary happy path looks correct.
Degraded-path failures use the same failure classes and severity model as
primary-path failures.

## Learner-critical text classes

The following text is learner-critical whenever it appears on the active
surface:

- task / instruction text
- prompt-band text
- title / subtitle text where meaning is required to act
- result explanation text
- next-step / payoff text
- CTA label text
- premium / trial / access-state meaning text

## Hard visibility invariants

Learner-critical text must satisfy all of the following:

- fully visible
- not clipped
- not truncated
- not hidden behind CTA stacks or safe-area loss
- not occluded by seats, badges, pot layers, overlays, or shell chrome
- not ellipsized when the missing text changes the learner's required action,
  payoff understanding, or access-state meaning

If learner-critical text cannot fit, the surface must:

- reflow
- resize safely
- or degrade into progressive disclosure without losing the required meaning

## Protected geometry zones

The following protected zones must remain readable and unobstructed:

- `runner prompt safe zone` for active task / instruction / prompt-band text
- `result readable zone` for closure, explanation, and next-step meaning
- `CTA safe-area zone` for continuation and access-state actions

## Small-screen and density coverage

The following are first-class audit conditions, not optional polish checks:

- narrow portrait
- denser runner state
- larger text scale
- longer localized copy
- degraded / fallback copy paths

## Failure classes and severity

Failure classes:

- `source_content_problem`
- `host_layout_problem`
- `copy_language_problem`
- `hierarchy_cta_problem`
- `result_payoff_problem`
- `intro_onboarding_absence`
- `premium_access_state_problem`
- `degraded_fallback_state_problem`
- `geometry_occlusion_clipping_problem`
- `critical_text_occlusion`
- `critical_text_truncation`
- `prompt_safe_zone_violation`
- `result_meaning_clipped`
- `cta_visibility_failure`
- `small_screen_readability_failure`

Severity:

- `P0` = release blocker
- `P1` = major learner-trust / first-user-path issue
- `P2` = non-blocking but real product debt

Severity interpretation for learner-text visibility:

- `P0` when the learner cannot fully see the required task, action, or next
  step; when the prompt is occluded; or when the CTA / critical meaning is
  pushed into an unsafe area
- `P1` when result or support meaning is clipped/truncated but the core task is
  still barely recoverable
- `P2` when density/readability debt is real but not yet blocking task
  completion

## Surface families matrix

| Surface family | Route role | Release-grade criteria | Degraded-state coverage | Failure classes | Severity guidance | Likely owner seams | Likely test seams | Likely audit/tool seams | Likely fix strategy | Human-only residue |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `Today Plan / intake` | first entry and route framing | no learner-visible internal IDs or authoring labels; one dominant primary action; no competing primary blocks above the fold; readable hierarchy on small portrait screens; learner-critical text fully visible; no clipping, truncation, or safe-area loss on title, CTA, or access-state meaning | empty, partial, stale, entitlement-driven, and larger-text variants must stay product-real and fully readable | `source_content_problem`; `host_layout_problem`; `copy_language_problem`; `hierarchy_cta_problem`; `degraded_fallback_state_problem`; `premium_access_state_problem`; `geometry_occlusion_clipping_problem`; `critical_text_truncation`; `cta_visibility_failure`; `small_screen_readability_failure` | `P0` if CTA loss, clipped critical text, or internal IDs leak on the first-user path; `P1` for weak hierarchy, stale state truth, or recoverable clipping | `lib/ui_v2/screens/universal_intake_plan_screen.dart` | `test/guards/world1_intake_plan_flow_contract_test.dart`; `test/ui_v2/today_plan_entitlement_truth_v1_test.dart`; `test/guards/world_campaign_map_home_contract_test.dart` | future Today non-overlap contract; CTA safe-area contract; small-screen text-fit contract; text-scale contract | source fix; hierarchy/CTA fix; host layout fix; state mapping fix | human review of whether bounded Today scope matches the real first-user promise |
| `first-user intro / trust-primer` | first framing and trust handoff before or at first entry | clear intro/trust layer exists on the first-user path; purpose/value is understandable; no transitional or beta framing leakage; dominant next action is obvious; learner-critical title/subtitle/CTA meaning stays fully visible | skipped, resumed, partial, longer-copy, and text-scale variants must preserve trust meaning | `copy_language_problem`; `hierarchy_cta_problem`; `intro_onboarding_absence`; `degraded_fallback_state_problem`; `critical_text_truncation`; `cta_visibility_failure`; `small_screen_readability_failure` | `P0` if the first-user path has no trust-primer layer or cannot show its required meaning; `P1` for confusing or transitional framing with recoverable action | `lib/ui_v2/onboarding/onboarding_how_it_works_screen.dart`; `lib/ui_v2/onboarding/onboarding_welcome_screen.dart` | `test/ui_v2/onboarding_how_it_works_trust_primer_test.dart`; `test/ui_v2/onboarding_first_win_test.dart`; `test/guards/result_onboarding_visual_cohesion_contract_test.dart` | future trust-primer readability contract; CTA safe-area contract; text-scale contract | intro copy fix; missing-surface fix; hierarchy fix | human review of whether the intro promise matches the shipped product surface |
| `runner prompt / table surface` | first live teaching surface | no learner-visible internal IDs or topology codes; prompt/instruction layer is readable and dominant; learner-critical prompt text fully visible; no overlap with table, seat, badge, position, or pot layers; no clipped text, reveal loss, or ellipsized task meaning | degraded runner states, denser board/seat states, larger text, and longer copy must keep prompt meaning visible | `source_content_problem`; `host_layout_problem`; `copy_language_problem`; `geometry_occlusion_clipping_problem`; `degraded_fallback_state_problem`; `critical_text_occlusion`; `critical_text_truncation`; `prompt_safe_zone_violation`; `small_screen_readability_failure` | `P0` for occluded prompt, hidden task meaning, or internal-ID leakage on the active runner; `P1` for weak prompt dominance with barely recoverable meaning | `lib/ui_v2/runner/runner_host_prompt_reveal_presentation_v1.dart` plus the current surfaced runner host family | `test/ui_v2/runner_host_prompt_reveal_presentation_v1_test.dart`; `test/ui_v2/factual_runner_host_contract_v1_test.dart`; relevant runner/table guards | future rendered non-overlap contract; prompt safe-zone contract; small-screen text-fit contract; text-scale contract | copy fix; host layout fix; geometry fix; source normalization fix | human review of whether the runner still reads cleanly at true first-user scale |
| `result / next-step surface` | closure, payoff, and continuation | readable closure and next-step clarity; one clear continuation action; no placeholder or transitional tone; learner-critical result/payoff text fully visible; no CTA loss at compact heights; no ellipsis where next-step meaning changes action | non-spine, retry, partial, longer-copy, and text-scale variants must keep closure and next-step meaning visible | `copy_language_problem`; `hierarchy_cta_problem`; `result_payoff_problem`; `degraded_fallback_state_problem`; `geometry_occlusion_clipping_problem`; `result_meaning_clipped`; `critical_text_truncation`; `cta_visibility_failure`; `small_screen_readability_failure` | `P0` for lost continuation CTA or unreadable next-step meaning; `P1` for clipped support/result meaning with barely recoverable action | `lib/ui_v2/screens/session_result_screen.dart` | `test/ui_v2/session_result_screen_contract_test.dart`; `test/guards/world1_result_whats_next_block_contract_test.dart`; `test/guards/result_onboarding_visual_cohesion_contract_test.dart` | future result readability contract; CTA safe-area contract; small-screen text-fit contract; text-scale contract | result/payoff fix; hierarchy/CTA fix; copy fix | human review of whether bounded payoff/next-step truth matches the claimed product route |
| `premium / trial / access-state surface` | access-state truth inside the real first-user path | premium/trial state reads as product-real in current path context; locked/unlocked states are clear; trial/premium labels match entitlement state; learner-critical access-state meaning is fully visible; no stale or contradictory status text; preview/manage/restore states stay consistent across resumed and refreshed states | locked, unlocked, restore, stale, lifecycle-refresh, longer-copy, and text-scale variants must remain readable and consistent | `source_content_problem`; `copy_language_problem`; `premium_access_state_problem`; `degraded_fallback_state_problem`; `hierarchy_cta_problem`; `critical_text_truncation`; `cta_visibility_failure`; `small_screen_readability_failure` | `P0` for contradictory or hidden access-state truth on the real path; `P1` for stale or clipped premium/trial meaning with recoverable action | `lib/ui_v2/screens/universal_intake_plan_screen.dart`; `lib/services/premium_service.dart` | `test/ui_v2/today_plan_entitlement_truth_v1_test.dart`; `test/ui_v2/premium_hub_access_state_v1_test.dart`; `test/services/premium_restore_flow_v1_test.dart` | future access-state readability contract; CTA safe-area contract; small-screen text-fit contract; text-scale contract | state mapping fix; copy fix; source fix | human review of whether access-state messaging is strong enough for broader release claims |

## Usage / next-wave guidance

- Use this layer to turn screenshot complaints into source-diagnosable failures.
- Use `docs/plan/PROJECT_READINESS_EPICS_SSOT_v1.md` for readiness scoring,
  bottleneck choice, and closure claims.
- Use `docs/plan/WORLD_READINESS_REGISTRY_v1.md` for per-world visibility, not
  cross-surface product route truth.
- The next implementation wave should be chosen from surfaced `P0` / `P1`
  failures in one surface family, not from ad hoc screenshot comparisons.
