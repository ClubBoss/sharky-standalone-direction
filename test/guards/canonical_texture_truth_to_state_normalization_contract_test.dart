import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'surfaced texture family derives board state from one canonical normalization seam',
    () {
      final stateSource = File(
        'lib/ui_v2/runner/session_drill_canonical_board_texture_scenario_state_v1.dart',
      ).readAsStringSync();
      final runnerSource = File(
        'lib/ui_v2/runner/canonical_terminal_session_drill_surfaced_runner_v1.dart',
      ).readAsStringSync();
      final sourceMetaSource = File(
        'lib/ui_v2/runner/session_drill_canonical_source_meta_entries_v1.dart',
      ).readAsStringSync();

      expect(
        stateSource.contains(
          'resolveSessionDrillCanonicalBoardTextureScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains(
          'resolveSessionDrillCanonicalBoardTextureScenarioStateV1(',
        ),
        isTrue,
      );
      expect(
        runnerSource.contains('_resolvedWorld5BoardTextureStreetV1('),
        isFalse,
      );
      expect(
        runnerSource.contains('_world5BoardTextureBoardCardIdsV1('),
        isFalse,
      );
      expect(sourceMetaSource.contains('resolvedTextureStateV1'), isTrue);
    },
  );
}
