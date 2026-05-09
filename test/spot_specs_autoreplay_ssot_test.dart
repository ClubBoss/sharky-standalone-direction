import 'package:poker_analyzer/testing/test_shims.dart';
import 'package:test/test.dart';

import 'package:poker_analyzer/ui/session_player/spot_specs.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';

void main() {
  group('L3 auto-replay SSOT', () {
    test('Exact set match', () {
      expect(
        autoReplayKinds,
        unorderedEquals({
          SpotKind.l3_flop_jam_vs_raise,
          SpotKind.l3_turn_jam_vs_raise,
          SpotKind.l3_river_jam_vs_raise,
        }),
      );
    });

    test('Actions invariant', () {
      for (final kind in autoReplayKinds) {
        expect(actionsMap[kind], ['jam', 'fold']);
      }
    });

    test('Subtitle invariant', () {
      for (final kind in autoReplayKinds) {
        final prefix = subtitlePrefix[kind];
        expect(prefix, isNotNull);
        expect(prefix!.isNotEmpty, true);
        expect(prefix.contains('Jam vs Raise • '), true);
      }
    });
  });
}
