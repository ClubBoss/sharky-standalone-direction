import 'package:test/test.dart';

import 'package:poker_analyzer/ui/session_player/models.dart';
import 'package:poker_analyzer/ui/session_player/spot_specs.dart' as specs;

void main() {
  const expectedPrefix = [
    'l2_open_fold',
    'l2_threebet_push',
    'l2_limped',
    'l4_icm',
    'callVsJam',
    'l3_postflop_jam',
    'l3_checkraise_jam',
    'l3_check_jam_vs_cbet',
    'l3_donk_jam',
    'l3_overbet_jam',
    'l3_raise_jam_vs_donk',
    'l3_bet_jam_vs_raise',
    'l3_raise_jam_vs_cbet',
    'l3_probe_jam_vs_raise',
    'l3_river_jam_vs_bet',
    'l3_turn_jam_vs_bet',
    'l3_flop_jam_vs_bet',
    'l3_flop_jam_vs_raise',
    'l3_turn_jam_vs_raise',
    'l3_river_jam_vs_raise',
    'l4_icm_bubble_jam_vs_fold',
    'l4_icm_ladder_jam_vs_fold',
    'l4_icm_sb_jam_vs_fold',
    'l4_icm_bb_jam_vs_fold',
    'l1_core_call_vs_price',
  ];

  group('SpotKind integrity smoke', () {
    test('SpotKind matches canonical prefix ordering', () {
      final names = SpotKind.values.map((e) => e.name).toList();
      expect(
        names.take(expectedPrefix.length).toList(),
        expectedPrefix,
        reason: 'SpotKind values must remain append-only with stable prefix',
      );
      expect(
        SpotKind.values.last.name,
        'l1_core_call_vs_price',
        reason: 'last SpotKind entry should remain the known guard sentinel',
      );
    });

    test('Jam-vs flows are all represented and jam/fold only', () {
      final jamKinds = [
        SpotKind.l3_flop_jam_vs_raise,
        SpotKind.l3_turn_jam_vs_raise,
        SpotKind.l3_river_jam_vs_raise,
        SpotKind.l4_icm_bubble_jam_vs_fold,
        SpotKind.l4_icm_ladder_jam_vs_fold,
        SpotKind.l4_icm_sb_jam_vs_fold,
        SpotKind.l4_icm_bb_jam_vs_fold,
        SpotKind.l1_core_call_vs_price,
      ];

      for (final kind in jamKinds) {
        final entry = specs.actionsMap[kind];
        expect(entry, isNotNull, reason: '$kind missing from actionsMap');
        expect(
          entry,
          equals(const ['jam', 'fold']),
          reason: '$kind should be jam/fold only',
        );
        expect(
          specs.subtitlePrefix[kind]?.isNotEmpty ?? false,
          isTrue,
          reason: '$kind requires subtitle prefix text',
        );
      }
      expect(
        specs.autoReplayKinds.every(jamKinds.contains),
        isTrue,
        reason: 'auto replay kinds must stay within jam/fold flows',
      );
    });
  });
}
