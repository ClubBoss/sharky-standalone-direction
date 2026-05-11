import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/world.md',
    'content/worlds/world0/v1/atoms.md',
    'content/worlds/world0/v1/sessions/index.md',
    'content/worlds/world0/v1/sessions/w0.s01/session.md',
    'content/worlds/world0/v1/sessions/w0.s01/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s02/notes.md',
    'content/worlds/world0/v1/sessions/w0.s02/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s03/notes.md',
    'content/worlds/world0/v1/sessions/w0.s03/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s04/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s05/session.md',
    'content/worlds/world0/v1/sessions/w0.s05/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s06/notes.md',
    'content/worlds/world0/v1/sessions/w0.s06/session.md',
    'content/worlds/world0/v1/sessions/w0.s06/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s07/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s08/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s09/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s10/session.md',
    'content/worlds/world0/v1/sessions/w0.s10/drills/index.md',
  ];

  test('World 0 learner copy uses action button wording', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('action label'), isFalse, reason: path);
      expect(content.contains('action labels'), isFalse, reason: path);
      expect(content.contains('action button'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 action-label jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_world_action_label_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_atoms_action_label_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_sessions_index_action_label_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_notes_action_label_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drills_index_action_label_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_session_action_label_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
