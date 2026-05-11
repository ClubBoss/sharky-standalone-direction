import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/index.md',
    'content/worlds/world0/v1/sessions/w0.s02/session.md',
    'content/worlds/world0/v1/sessions/w0.s03/session.md',
    'content/worlds/world0/v1/sessions/w0.s04/session.md',
    'content/worlds/world0/v1/sessions/w0.s05/session.md',
    'content/worlds/world0/v1/sessions/w0.s07/session.md',
    'content/worlds/world0/v1/sessions/w0.s08/session.md',
    'content/worlds/world0/v1/sessions/w0.s09/session.md',
  ];

  test(
    'World 0 learner copy uses seat/table wording instead of position phrasing',
    () {
      for (final path in normalizedPaths) {
        final content = File(path).readAsStringSync().toLowerCase();
        expect(content.contains('position cue'), isFalse, reason: path);
        expect(content.contains('position cues'), isFalse, reason: path);
        expect(content.contains('position checks'), isFalse, reason: path);
        expect(content.contains('button position'), isFalse, reason: path);
      }

      expect(
        File(
          'content/worlds/world0/v1/sessions/index.md',
        ).readAsStringSync().toLowerCase().contains('seat-layout checks'),
        isTrue,
      );
      expect(
        File(
          'content/worlds/world0/v1/sessions/w0.s05/session.md',
        ).readAsStringSync().toLowerCase().contains('dealer button seat'),
        isTrue,
      );
    },
  );

  test(
    'validator no longer reports World 0 position-language failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_sessions_index_position_language_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_session_position_language_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
