import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'surfaced spatial family derives runner state from one canonical normalization seam',
    () {
      final stateSource = File(
        'lib/ui_v2/runner/session_drill_canonical_spatial_scenario_state_v1.dart',
      ).readAsStringSync();
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();

      expect(
        stateSource.contains(
          'resolveSessionDrillCanonicalSpatialScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'resolveSessionDrillCanonicalSpatialScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'boardCardsV1: spec.scenarioBoardContextV1?.boardCardsV1,',
        ),
        isFalse,
      );
      expect(
        runnerSource.contains(
          'final boardCards = spec.scenarioBoardContextV1?.boardCardsV1;',
        ),
        isFalse,
      );
      expect(
        runnerSource.contains(
          'final heroHoleCards = spec.scenarioBoardContextV1?.heroHoleCardsV1;',
        ),
        isFalse,
      );
      expect(
        runnerSource.contains(
          'final seatContext = spec.scenarioSeatContextV1;',
        ),
        isFalse,
      );
    },
  );
}
