import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s03/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s03/notes.md',
    'content/worlds/world0/v1/sessions/w0.s05/session.md',
    'content/worlds/world0/v1/sessions/w0.s09/notes.md',
    'content/worlds/world0/v1/sessions/w0.s10/drills/index.md',
  ];

  test('World 0 learner copy uses table layout wording', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('table map'), isFalse, reason: path);
      expect(content.contains('table layout'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 table-map jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_notes_table_map_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drills_index_table_map_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_session_table_map_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
