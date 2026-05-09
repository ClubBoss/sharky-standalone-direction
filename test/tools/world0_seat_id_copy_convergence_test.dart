import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const promptPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s02/drills/d.find_seat_s1.json',
    'content/worlds/world0/v1/sessions/w0.s03/drills/d.find_seat_s2.json',
    'content/worlds/world0/v1/sessions/w0.s04/drills/d.find_seat_s0_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s05/drills/d.find_seat_s1_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s06/drills/d.find_seat_s2_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s07/drills/d.find_seat_s3_focus.json',
    'content/worlds/world0/v1/sessions/w0.s08/drills/d.find_seat_s4_focus.json',
    'content/worlds/world0/v1/sessions/w0.s09/drills/d.find_seat_s5_focus.json',
    'content/worlds/world0/v1/sessions/w0.s10/drills/d.find_seat_s6_focus.json',
  ];

  const indexPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s02/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s03/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s04/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s05/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s06/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s07/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s08/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s09/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s10/drills/index.md',
  ];

  test('World 0 seat-id prompts use learner-facing labeled-seat wording', () {
    for (final path in promptPaths) {
      final decoded = jsonDecode(File(path).readAsStringSync()) as Map;
      final prompt = (decoded['prompt'] as String).toLowerCase();
      expect(prompt.contains('tap seat s'), isFalse, reason: path);
      expect(prompt.contains('tap the seat labeled s'), isTrue, reason: path);
    }
  });

  test('World 0 drill indexes use learner-facing labeled-seat wording', () {
    for (final path in indexPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('tap seat s'), isFalse, reason: path);
    }
  });

  test('validator no longer reports World 0 seat-id jargon failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('world0_seat_id_prompt_jargon_leak_v1'),
      isFalse,
      reason: combined,
    );
    expect(
      combined.contains('world0_drills_index_seat_id_jargon_leak_v1'),
      isFalse,
      reason: combined,
    );
  });
}
