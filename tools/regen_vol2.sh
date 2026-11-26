#!/usr/bin/env bash
# Refresh only pilot snapshots and the strictly ratcheted Vol2 census.
set -euo pipefail
cd "$(dirname "$0")/.."
G1_UPDATE_SNAPSHOT=1 flutter test --dart-define=SHARKY_W13_PLUS_PILOT=true \
  test/ui_v2/act0_catalog_truth_guards_v1_test.dart --name 'pilot catalog snapshot'
G1_UPDATE_SNAPSHOT=1 flutter test --dart-define=SHARKY_W13_PLUS_PILOT=true \
  test/ui_v2/act0_catalog_vol2_census_v1_test.dart
# The pilot-off reference snapshot and route/XP hash must not change.
G1_UPDATE_SNAPSHOT=0 flutter test \
  test/ui_v2/act0_catalog_truth_guards_v1_test.dart \
  --plain-name 'W1–W12 catalog snapshot'
flutter test test/ui_v2/act0_vol2_principle_day7_v1_test.dart
flutter test --dart-define=SHARKY_W13_PLUS_PILOT=true \
  test/ui_v2/act0_vol2_principle_day7_v1_test.dart
flutter test --dart-define=SHARKY_W13_PLUS_PILOT=true \
  test/ui_v2/act0_due_review_route_v1_test.dart \
  --plain-name 'Day 7 opens a new task after Day 2 for world_13/range_advantage/range_advantage'
