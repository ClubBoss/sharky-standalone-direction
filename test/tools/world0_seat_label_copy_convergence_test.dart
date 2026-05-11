import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPromptFiles = <String>[
    'content/worlds/world0/v1/sessions/w0.s07/drills/d.find_btn_focus.json',
    'content/worlds/world0/v1/sessions/w0.s08/drills/d.find_bb_focus.json',
    'content/worlds/world0/v1/sessions/w0.s09/drills/d.find_sb_focus.json',
    'content/worlds/world0/v1/sessions/w0.s10/drills/d.find_btn_focus.json',
  ];
  const normalizedIndexFiles = <String>[
    'content/worlds/world0/v1/sessions/w0.s05/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s07/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s10/drills/index.md',
  ];

  test('World 0 surfaced seat prompts avoid btn/sb/bb shorthand', () {
    for (final path in normalizedPromptFiles) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains(' btn seat'), isFalse, reason: path);
      expect(content.contains(' sb seat'), isFalse, reason: path);
      expect(content.contains(' bb seat'), isFalse, reason: path);
    }
  });

  test('World 0 drill indexes use dealer button wording', () {
    for (final path in normalizedIndexFiles) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('tap the button seat'), isFalse, reason: path);
      expect(content.contains('dealer button seat'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 prompt shorthand failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_seat_label_shorthand_prompt_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drills_index_button_seat_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
