import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'surfaced runner and headless validator both pass through the shared invariant spine',
    () {
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();
      final validatorSource = File(
        'lib/services/headless_scenario_validation_v1.dart',
      ).readAsStringSync();
      final spineSource = File(
        'lib/services/session_drill_projection_truth_invariant_spine_v1.dart',
      ).readAsStringSync();

      expect(
        runnerSource.contains('buildValidatedSessionDrillProjectedScenarioV1('),
        isTrue,
      );
      expect(
        validatorSource.contains(
          'buildValidatedSessionDrillProjectedScenarioV1(',
        ),
        isTrue,
      );
      expect(
        spineSource.contains('scenario.validate();'),
        isTrue,
        reason: 'shared invariant spine must reuse ScenarioSpecV1.validate()',
      );
      expect(
        runnerSource.contains('.buildScenarioSpec('),
        isFalse,
        reason:
            'surfaced runner should no longer bypass the shared invariant spine for the admitted subset',
      );
    },
  );
}
