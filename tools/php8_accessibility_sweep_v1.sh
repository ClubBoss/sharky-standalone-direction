#!/usr/bin/env bash
set -euo pipefail

flutter test \
  test/guards/world1_a11y_semantics_contract_test.dart \
  test/ui_v2/session_result_text_scale_contract_test.dart \
  test/ui_v2/compact_decision_integrity_repair_v1_test.dart \
  test/guards/world1_today_plan_text_safety_contract_test.dart
