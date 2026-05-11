import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/index.md',
    'content/worlds/world0/v1/sessions/w0.s05/session.md',
    'content/worlds/world0/v1/sessions/w0.s06/session.md',
    'content/worlds/world0/v1/sessions/w0.s10/notes.md',
    'content/worlds/world0/v1/sessions/w0.s10/session.md',
    'content/worlds/world0/v1/sessions/w0.s10/drills/index.md',
  ];

  test('World 0 learner copy uses street order wording', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('street flow'), isFalse, reason: path);
      expect(content.contains('street-flow'), isFalse, reason: path);
      expect(content.contains('street-order'), isFalse, reason: path);
      expect(content.contains('street order'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 street-flow jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_sessions_index_street_flow_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_notes_street_flow_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_drills_index_street_flow_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
      expect(
        combined.contains('world0_session_street_flow_jargon_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
