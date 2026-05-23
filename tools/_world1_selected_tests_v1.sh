#!/usr/bin/env bash

# SSOT for World1 selected guard tests used by release/demo/speed scripts.
# Keep the full list stable for direct checkpoint/release use, then expose
# narrower families for default fast-loop tiering.
WORLD1_SELECTED_TESTS_V1=(
  test/ui_v2/act0_shell_preview_screen_v1_test.dart
  test/ui_v2/act0_play_shell_v1_test.dart
  test/ui_v2/act0_en_alpha_residue_guard_test.dart
  test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart
  test/guards/campaign_pack_registry_invariants_test.dart
  test/guards/campaign_followup_pack_registry_invariants_test.dart
  test/ui_v2/act0_shell_state_v1_feedback_test.dart
)

WORLD1_SELECTED_TESTS_STATE_V1=(
  test/ui_v2/act0_shell_preview_screen_v1_test.dart
)

WORLD1_SELECTED_TESTS_SURFACE_V1=(
  test/ui_v2/act0_play_shell_v1_test.dart
)

WORLD1_SELECTED_TESTS_COPY_GUARDS_V1=(
  test/ui_v2/act0_en_alpha_residue_guard_test.dart
  test/ui_v2/act0_ru_surface_no_unapproved_latin_test.dart
  test/ui_v2/act0_shell_state_v1_feedback_test.dart
)

WORLD1_SELECTED_TESTS_CAMPAIGN_GUARDS_V1=(
  test/guards/campaign_pack_registry_invariants_test.dart
  test/guards/campaign_followup_pack_registry_invariants_test.dart
)
