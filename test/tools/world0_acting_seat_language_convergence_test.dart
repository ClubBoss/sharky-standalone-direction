import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/world.md',
    'content/worlds/world0/v1/atoms.md',
    'content/worlds/world0/v1/sessions/index.md',
    'content/worlds/world0/v1/sessions/w0.s02/notes.md',
    'content/worlds/world0/v1/sessions/w0.s07/notes.md',
    'content/worlds/world0/v1/sessions/w0.s08/notes.md',
    'content/worlds/world0/v1/sessions/w0.s08/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s10/session.md',
  ];

  test('World 0 learner copy uses acting seat wording', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('current actor'), isFalse, reason: path);
      expect(content.contains('actor detection'), isFalse, reason: path);
      expect(content.contains('highlighted actor'), isFalse, reason: path);
      expect(content.contains('confirm the actor'), isFalse, reason: path);
      expect(content.contains('checking the actor'), isFalse, reason: path);
      expect(RegExp(r'\bactor-and-').hasMatch(content), isFalse, reason: path);
      expect(RegExp(r'\bactor,').hasMatch(content), isFalse, reason: path);
      expect(content.contains('acting seat'), isTrue, reason: path);
    }
  });

  test('validator no longer reports World 0 actor-language failures', () async {
    final result = await Process.run('dart', [
      'run',
      'tools/validate_world_content_v1.dart',
    ]);
    final combined = '${result.stdout}\n${result.stderr}';
    expect(
      combined.contains('world0_world_actor_language_leak_v1'),
      isFalse,
      reason: combined,
    );
    expect(
      combined.contains('world0_atoms_actor_language_leak_v1'),
      isFalse,
      reason: combined,
    );
    expect(
      combined.contains('world0_sessions_index_actor_language_leak_v1'),
      isFalse,
      reason: combined,
    );
    expect(
      combined.contains('world0_notes_actor_language_leak_v1'),
      isFalse,
      reason: combined,
    );
    expect(
      combined.contains('world0_drills_index_actor_language_leak_v1'),
      isFalse,
      reason: combined,
    );
    expect(
      combined.contains('world0_session_actor_language_leak_v1'),
      isFalse,
      reason: combined,
    );
  });
}
