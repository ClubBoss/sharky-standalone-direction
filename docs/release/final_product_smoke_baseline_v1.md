# Final Product Smoke Baseline v1

## Purpose

This file is the canonical owner for bounded smoke and critical-flow coverage
truth on current `main`.

It does not claim complete full-product smoke coverage.

## Covered Now

- Executable bounded smoke runner exists:
  `tool/release_smoke_baseline_v1.sh`

- App boot stays non-throwing and reaches a canonical entry:
  `test/guards/app_boot_release_smoke_test.dart`
- Onboarding starter pack reaches the pack-play host instead of the legacy
  training session:
  `test/ui_v2/onboarding_first_win_test.dart`
- Cold-start intake reaches Today with a single deterministic start CTA:
  `test/guards/world1_app_root_startup_contract_test.dart`
- First-session result continuation stays deterministic:
  `test/ui_v2/session_result_world1_onboarding_payoff_test.dart`
- Free users are gated from premium-target placement until entitlement exists:
  `test/guards/world_campaign_map_home_contract_test.dart`
- Trial-active users can open premium-target placement deterministically:
  `test/guards/world_campaign_map_home_contract_test.dart`
- Premium hub reflects trial/premium state and lifecycle refresh:
  `test/ui_v2/premium_hub_access_state_v1_test.dart`
- Branch progression stays isolated from canonical launcher routes:
  `test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart`
- Legal/support runtime surfaces stay present and in-app:
  `test/ui_v2/legal_screen_v1_test.dart`

## Bounded Widening On Current Main

- This smoke family is wider than the older bounded beta slice.
- It now covers:
  - canonical entry and first-session continuation
  - premium-entry and premium-target gating truth
  - premium hub access-state truth
  - branch progression boundary isolation
  - legal/support runtime presence
- It is still a bounded smoke family, not whole-product smoke closure.

## Current Bounded Proof On Main

- `dart run tools/release_readiness_snapshot_v1.dart` must continue to report:
  - `boundedSmokeBaselinePresent = true`
  - `boundedSmokeBaselineSaysNotFullCoverage = true`
  - `fullProductSmokePathPresent = true`
  - `goNoGoStateIsHold = true`
  - `moduleLauncherBoundaryContractPresent = true`
- `tool/release_smoke_baseline_v1.sh` remains the executable smoke runner for
  this bounded family
- This owner records bounded smoke coverage only; it does not prove full-product
  smoke closure

## Not Covered Now

- No single smoke owner runs the full finished product across all worlds and
  route families
- No current-main smoke artifact proves real store purchase/restore behavior in
  external store consoles
- No current-main smoke artifact proves final launch/distribution tasks outside
  the repo-owned surfaces

## Human-Proof Still Needed

- Manual cross-surface walkthrough of the finished product breadth
- Human verification that the bounded smoke baseline still matches the active
  product promise and release scope
- Bounded operational review using
  `docs/release/operational_review_packet_truth_v1.md`
- Explicit decision review using `docs/release/go_hold_rollback_truth_v1.md`
- Any stronger human decision artifact must use
  `docs/release/release_owner_decision_template_v1.md`
- Human review owner:
  `docs/release/release_owner_review_v1.md`

## Guardrail

If a release-confidence surface claims “full-product smoke coverage,” it must
be backed by a newer active owner than this file. Otherwise it is overclaimed.
