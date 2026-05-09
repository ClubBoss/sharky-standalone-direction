import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPromptPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s01/drills/d.tap_flop_left.json',
    'content/worlds/world0/v1/sessions/w0.s01/drills/d.tap_river.json',
    'content/worlds/world0/v1/sessions/w0.s02/drills/d.tap_turn.json',
    'content/worlds/world0/v1/sessions/w0.s02/drills/d.tap_flop_mid.json',
    'content/worlds/world0/v1/sessions/w0.s03/drills/d.tap_river.json',
    'content/worlds/world0/v1/sessions/w0.s03/drills/d.tap_turn.json',
    'content/worlds/world0/v1/sessions/w0.s04/drills/d.tap_turn_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s05/drills/d.tap_flop_mid_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s06/drills/d.tap_river_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s07/drills/d.tap_flop_left_focus.json',
    'content/worlds/world0/v1/sessions/w0.s08/drills/d.tap_river_focus.json',
    'content/worlds/world0/v1/sessions/w0.s09/drills/d.tap_turn_focus.json',
    'content/worlds/world0/v1/sessions/w0.s10/drills/d.tap_flop_mid_focus.json',
  ];

  test('World 0 board prompts avoid internal slot jargon', () {
    for (final path in normalizedPromptPaths) {
      final decoded = jsonDecode(File(path).readAsStringSync()) as Map;
      final prompt = (decoded['prompt'] as String).toLowerCase();
      expect(prompt.contains('flop_left'), isFalse, reason: path);
      expect(prompt.contains('flop_mid'), isFalse, reason: path);
      expect(prompt.contains('left flop card slot'), isFalse, reason: path);
      expect(prompt.contains('middle flop card slot'), isFalse, reason: path);
      expect(prompt.contains('turn card slot'), isFalse, reason: path);
      expect(prompt.contains('river card slot'), isFalse, reason: path);
    }
  });

  test('validator no longer reports World 0 board-slot jargon failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('world0_board_slot_prompt_jargon_leak_v1'),
      isFalse,
      reason: combined,
    );
  });
}
