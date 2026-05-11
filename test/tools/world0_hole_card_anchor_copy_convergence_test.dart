import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedMarkdownPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s02/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s08/notes.md',
  ];
  const normalizedJsonPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s07/drills/d.tap_hole_right_focus.json',
    'content/worlds/world0/v1/sessions/w0.s08/drills/d.tap_hole_left_focus.json',
    'content/worlds/world0/v1/sessions/w0.s09/drills/d.tap_hole_right_focus.json',
  ];

  test('World 0 learner copy uses hole-card anchor wording', () {
    for (final path in normalizedMarkdownPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('hero-card anchor'), isFalse, reason: path);
      expect(content.contains('hero-card anchors'), isFalse, reason: path);
      expect(content.contains('hole-card anchor'), isTrue, reason: path);
    }

    for (final path in normalizedJsonPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('hero hole-card anchor'), isFalse, reason: path);
      expect(content.contains('hole-card anchor'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 hero-anchor jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_notes_hero_anchor_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drills_index_hero_anchor_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drill_why_hero_anchor_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
