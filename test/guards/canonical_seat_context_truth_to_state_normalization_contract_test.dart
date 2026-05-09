import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'surfaced seat-context families derive runner state from one canonical normalization seam',
    () {
      final stateSource = File(
        'lib/ui_v2/runner/session_drill_canonical_seat_context_scenario_state_v1.dart',
      ).readAsStringSync();
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();
      final sourceMetaSource = File(
        'lib/ui_v2/runner/session_drill_canonical_source_meta_entries_v1.dart',
      ).readAsStringSync();

      expect(
        stateSource.contains(
          'resolveSessionDrillCanonicalSeatContextScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'resolveSessionDrillCanonicalSeatContextScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'final positionContext = spec.scenarioPositionContextV1;',
        ),
        isFalse,
      );
      expect(
        runnerSource.contains(
          'final initiativeContext = spec.scenarioInitiativeContextV1;',
        ),
        isFalse,
      );
      expect(sourceMetaSource.contains('resolvedSeatContextStateV1'), isTrue);
    },
  );
}
