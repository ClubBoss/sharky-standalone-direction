import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s07/drills/index.md',
    'content/worlds/world0/v1/sessions/w0.s10/drills/index.md',
  ];

  test('World 0 drill indexes use acting seat wording', () {
    for (final path in normalizedPaths) {
      final content = File(path).readAsStringSync().toLowerCase();
      expect(content.contains('current actor area'), isFalse, reason: path);
      expect(content.contains('acting seat'), isTrue, reason: path);
    }
  });

  test(
    'validator no longer reports World 0 current-actor-area failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains(
          'world0_drills_index_current_actor_area_jargon_leak_v1',
        ),
        isFalse,
        reason: combined,
      );
    },
  );
}
