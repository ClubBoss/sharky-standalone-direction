#!/usr/bin/env bash

# SSOT for World1 selected guard tests used by release/demo/speed scripts.
WORLD1_SELECTED_TESTS_V1=(
  test/guards/world1_readiness_smoke_contract_test.dart
  test/guards/world1_campaign_telemetry_contract_test.dart
  test/guards/world_campaign_routing_matrix_contract_test.dart
  test/guards/world_campaign_map_home_contract_test.dart
  test/guards/campaign_pack_registry_invariants_test.dart
  test/guards/campaign_followup_pack_registry_invariants_test.dart
  test/ui_v2/act0_shell_state_v1_feedback_test.dart
)
