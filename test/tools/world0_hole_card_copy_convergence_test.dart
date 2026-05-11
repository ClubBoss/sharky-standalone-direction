import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const indexPath = 'content/worlds/world0/v1/sessions/w0.s01/drills/index.md';

  test('World 0 drill index uses singular hole card wording', () {
    final content = File(indexPath).readAsStringSync().toLowerCase();
    expect(content.contains('left hole cards'), isFalse);
    expect(content.contains('right hole cards'), isFalse);
    expect(content.contains('left hole card'), isTrue);
    expect(content.contains('right hole card'), isTrue);
  });

  test(
    'validator no longer reports World 0 hole-card plural failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_drills_index_hole_cards_plural_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
