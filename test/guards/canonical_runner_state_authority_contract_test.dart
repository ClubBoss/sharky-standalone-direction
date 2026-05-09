import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'surfaced runner derives hand-chain scenario state from one canonical seam',
    () {
      final stateSource = File(
        'lib/ui_v2/runner/session_drill_canonical_hand_chain_scenario_state_v1.dart',
      ).readAsStringSync();
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();
      final sourceMetaSource = File(
        'lib/ui_v2/runner/session_drill_canonical_source_meta_entries_v1.dart',
      ).readAsStringSync();

      expect(
        stateSource.contains(
          'resolveSessionDrillCanonicalHandChainScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'resolveSessionDrillCanonicalHandChainScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'normalizedStep?.tableContextV1 ?? step.scenarioTableContextV1',
        ),
        isFalse,
      );
      expect(
        runnerSource.contains('normalizedStep?.coreV1.availableActionsV1 ??'),
        isFalse,
      );
      expect(sourceMetaSource.contains('resolvedHandChainStateV1'), isTrue);
    },
  );
}
