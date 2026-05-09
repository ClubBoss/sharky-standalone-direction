import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'surfaced runner and headless validator both depend on the reconciled projection seam',
    () {
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();
      final validatorSource = File(
        'lib/services/headless_scenario_validation_v1.dart',
      ).readAsStringSync();

      expect(
        runnerSource.contains('reconcileSessionDrillTableTruthV1('),
        isTrue,
      );
      expect(
        runnerSource.contains('resolveSessionDrillProjectedStreetV1('),
        isTrue,
      );
      expect(
        validatorSource.contains('reconcileSessionDrillTableTruthV1('),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'SessionDrillSeatOrderPolicyV1.canonicalAuthoredArcOrder',
        ),
        isTrue,
      );
      expect(
        validatorSource.contains(
          'SessionDrillSeatOrderPolicyV1.canonicalAuthoredArcOrder',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains('final seatOrder = <String>['),
        isFalse,
        reason:
            'seat-order assembly should no longer be owned inline by the surfaced runner for the admitted subset',
      );
    },
  );
}
