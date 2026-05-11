import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedMarkdownPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s06/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s10/drills/index.md',
  ];
  const normalizedJsonPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s10/drills/d.tap_hole_left_focus.json',
  ];

  test('World 0 learner copy uses checkpoint set wording', () {
    for (final path in normalizedMarkdownPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('checkpoint mix'), isFalse, reason: path);
      expect(content.contains('checkpoint set'), isTrue, reason: path);
    }

    for (final path in normalizedJsonPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('checkpoint mix'), isFalse, reason: path);
      expect(content.contains('checkpoint set'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 checkpoint-mix jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_drills_index_checkpoint_mix_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drill_why_checkpoint_mix_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
