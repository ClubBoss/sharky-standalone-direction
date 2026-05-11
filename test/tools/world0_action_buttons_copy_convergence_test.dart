import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/atoms.md',
    'content/worlds/world0/v1/sessions/w0.s01/notes.md',
    'content/worlds/world0/v1/sessions/w0.s04/notes.md',
    'content/worlds/world0/v1/sessions/w0.s06/notes.md',
    'content/worlds/world0/v1/sessions/w0.s07/notes.md',
    'content/worlds/world0/v1/sessions/w0.s07/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s09/notes.md',
  ];

  test('World 0 learner copy uses action buttons wording', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('action row'), isFalse, reason: path);
      expect(content.contains('action buttons'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 action-row jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_notes_action_row_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_atoms_action_row_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drills_index_action_row_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
