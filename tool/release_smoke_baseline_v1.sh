#!/usr/bin/env bash
set -euo pipefail

workspace_root="$(cd "$(dirname "$0")/.." && pwd)"

echo "Step 1/8: boot to canonical entry smoke"
(
  cd "$workspace_root"
  flutter test test/guards/app_boot_release_smoke_test.dart
)

echo "Step 2/8: onboarding starter-pack host smoke"
(
  cd "$workspace_root"
  flutter test test/ui_v2/onboarding_first_win_test.dart
)

echo "Step 3/8: intake to Today deterministic flow smoke"
(
  cd "$workspace_root"
  flutter test test/guards/world1_app_root_startup_contract_test.dart
)

echo "Step 4/8: first-session result continuation smoke"
(
  cd "$workspace_root"
  flutter test test/ui_v2/session_result_world1_onboarding_payoff_test.dart
)

echo "Step 5/8: Today premium preview truth smoke"
(
  cd "$workspace_root"
  flutter test test/ui_v2/today_plan_entitlement_truth_v1_test.dart
)

echo "Step 6/8: premium hub access-state smoke"
(
  cd "$workspace_root"
  flutter test test/ui_v2/premium_hub_access_state_v1_test.dart
)

echo "Step 7/8: premium-target route gating smoke"
(
  cd "$workspace_root"
  flutter test test/guards/world_campaign_map_home_contract_test.dart --plain-name "today plan gates world5 placement behind premium preview and restore unblocks next attempt"
  flutter test test/guards/world_campaign_map_home_contract_test.dart --plain-name "today plan allows trial-active entitlement to open premium-target placement deterministically"
)

echo "Step 8/9: branch progression boundary smoke"
(
  cd "$workspace_root"
  flutter test test/guards/module_launcher_legacy_bridge_boundary_contract_test.dart
)

echo "Step 9/9: legal surface presence smoke"
(
  cd "$workspace_root"
  flutter test test/ui_v2/legal_screen_v1_test.dart
)

echo "Release smoke baseline steps completed"
