import 'package:test/test.dart';
// ignore: unused_import
import 'package:poker_analyzer/ui/flutter_stub_test.dart'
    if (dart.library.ui) 'package:flutter/material.dart';
import 'package:poker_analyzer/ui/session_player/models.dart';

void main() {
  group('SpotKind integrity', () {
    test('names remain unique and append-only', () {
      final names = SpotKind.values.map((e) => e.name).toList();
      expect(
        names.toSet().length,
        names.length,
        reason: 'SpotKind names must remain unique.',
      );

      const baseline = <String>[
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

      expect(
        names.length >= baseline.length,
        isTrue,
        reason: 'Existing SpotKind entries must never be removed.',
      );
      expect(
        names.take(baseline.length).toList(),
        equals(baseline),
        reason: 'SpotKind entries must only be appended at the end.',
      );
    });
  });
}
