import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s02/session.md',
    'content/worlds/world0/v1/sessions/w0.s03/session.md',
    'content/worlds/world0/v1/sessions/w0.s04/session.md',
    'content/worlds/world0/v1/sessions/w0.s07/session.md',
    'content/worlds/world0/v1/sessions/w0.s08/session.md',
    'content/worlds/world0/v1/sessions/w0.s09/session.md',
  ];

  test('World 0 session copy no longer uses the generic template phrasing', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(
        content.contains(
          'apply the drill sequence to reinforce the target decision pattern.',
        ),
        isFalse,
        reason: path,
      );
      expect(
        content.contains(
          'use the provided table state and seat cues for this session.',
        ),
        isFalse,
        reason: path,
      );
      expect(
        content.contains('choose the strongest action using the session cues.'),
        isFalse,
        reason: path,
      );
      expect(
        content.contains('review why the chosen action best fits this spot.'),
        isFalse,
        reason: path,
      );
    }

    expect(
      File('content/worlds/world0/v1/sessions/w0.s07/session.md')
          .readAsStringSync()
          .toLowerCase()
          .contains('dealer button seat'),
      isTrue,
    );
    expect(
      File('content/worlds/world0/v1/sessions/w0.s08/session.md')
          .readAsStringSync()
          .toLowerCase()
          .contains('big blind seat'),
      isTrue,
    );
  });

  test('validator no longer reports World 0 generic session-template failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('world0_session_generic_template_copy_leak_v1'),
      isFalse,
      reason: combined,
    );
  });
}
