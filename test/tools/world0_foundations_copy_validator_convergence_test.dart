import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const cleanedWorld0Paths = <String>[
    'content/worlds/world0/v1/atoms.md',
    'content/worlds/world0/v1/sessions/w0.s01/notes.md',
    'content/worlds/world0/v1/sessions/w0.s02/notes.md',
    'content/worlds/world0/v1/sessions/w0.s03/notes.md',
    'content/worlds/world0/v1/sessions/w0.s04/notes.md',
    'content/worlds/world0/v1/sessions/w0.s05/notes.md',
    'content/worlds/world0/v1/sessions/w0.s06/notes.md',
    'content/worlds/world0/v1/sessions/w0.s07/notes.md',
    'content/worlds/world0/v1/sessions/w0.s08/notes.md',
    'content/worlds/world0/v1/sessions/w0.s09/notes.md',
    'content/worlds/world0/v1/sessions/w0.s10/notes.md',
    'content/worlds/world0/v1/sessions/w0.s02/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s03/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s04/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s06/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s07/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s08/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s09/drills/index.md',
  ];

  test('World 0 cleaned learner-copy files are free of TODO leakage', () {
    for (final path in cleanedWorld0Paths) {
      final content = File(path).readAsStringSync();
      expect(content.contains('TODO'), isFalse, reason: path);
    }
  });

  test('validator no longer reports World 0 content-path failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('validate_world_content_v1: content/worlds/world0/'),
      isFalse,
      reason: combined,
    );
  });
}
