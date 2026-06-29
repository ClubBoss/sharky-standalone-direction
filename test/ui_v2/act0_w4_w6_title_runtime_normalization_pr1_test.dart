import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  group('W4-W6 title runtime normalization PR1', () {
    test('normalizes W4-W6 titles while preserving W1-W3 and W7-W10 locks', () {
      final worlds = Act0ShellStateV1.sample;

      expect(worlds.worldById('world_1').title, 'Poker from Zero');
      expect(worlds.worldById('world_2').title, 'Hand Discipline');
      expect(worlds.worldById('world_3').title, 'Position Thinking');

      expect(worlds.worldById('world_4').title, 'Bet Purpose / Price');
      expect(worlds.worldById('world_5').title, 'Board Awareness');
      expect(worlds.worldById('world_6').title, 'Range Thinking');

      for (final worldId in <String>[
        'world_7',
        'world_8',
        'world_9',
        'world_10',
      ]) {
        final world = worlds.worldById(worldId);
        expect(world.status, Act0WorldStateV1.locked, reason: worldId);
        expect(world.isLocked, isTrue, reason: worldId);
        expect(world.isSelectable, isFalse, reason: worldId);
      }
    });
  });
}
