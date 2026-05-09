import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'surfaced outs family derives runner state from one canonical normalization seam',
    () {
      final stateSource = File(
        'lib/ui_v2/runner/session_drill_canonical_outs_scenario_state_v1.dart',
      ).readAsStringSync();
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();
      final sourceMetaSource = File(
        'lib/ui_v2/runner/session_drill_canonical_source_meta_entries_v1.dart',
      ).readAsStringSync();

      expect(
        stateSource.contains(
          'resolveSessionDrillCanonicalOutsScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'resolveSessionDrillCanonicalOutsScenarioStateV1(',
        ),
        isTrue,
      );
      expect(sourceMetaSource.contains('resolvedOutsStateV1'), isTrue);
      expect(
        runnerSource.contains(
          'final boardCards = spec.scenarioOutsContextV1?.boardCardsV1;',
        ),
        isFalse,
      );
      expect(
        runnerSource.contains(
          'final heroHoleCards = spec.scenarioOutsContextV1?.heroHoleCardsV1;',
        ),
        isFalse,
      );
    },
  );
}
