#!/bin/bash
set -e
echo "Running analyzer and tests..."
targets=(
  lib/ui/flutter_stub_test.dart
  lib/ui/learning_path_booster_engine_stub.dart
  lib/ui/training_pack_storage_service_stub.dart
  lib/ui/training_pack_template_v2_stub.dart
  lib/ui/training_type_engine_stub.dart
  lib/ui/telemetry_test_harness.dart
  test_v2
)

dart format --set-exit-if-changed "${targets[@]}"
dart analyze "${targets[@]}"
dart test test_v2

# Generate coverage report
echo "Generating coverage report..."
dart test test_v2 --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
echo "✅ All checks passed. Coverage report generated at coverage/lcov.info"
