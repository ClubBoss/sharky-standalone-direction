import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s02/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s05/notes.md',
    'content/worlds/world0/v1/sessions/w0.s08/notes.md',
  ];

  test(
    'World 0 learner copy uses table layout wording instead of table read',
    () {
      for (final path in normalizedPaths) {
        final content = File(path).readAsStringSync().toLowerCase();
        expect(content.contains('table read'), isFalse, reason: path);
        expect(content.contains('table layout'), isTrue, reason: path);
      }
    },
  );

  test(
    'validator no longer reports World 0 table-read jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_notes_table_read_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drills_index_table_read_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
