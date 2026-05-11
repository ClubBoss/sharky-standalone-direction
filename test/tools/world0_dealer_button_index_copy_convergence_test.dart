import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'World 0 drill indexes use dealer button seat wording instead of dealer position',
    () {
      const targetFiles = <String>[
        'content/worlds/world0/v1/sessions/w0.s05/drills/index.md',
        'content/worlds/world0/v1/sessions/w0.s07/drills/index.md',
      ];

      for (final path in targetFiles) {
        final raw = File(path).readAsStringSync();
        expect(raw, isNot(contains('dealer position')), reason: path);
        expect(raw, contains('dealer button seat'), reason: path);
      }
    },
  );

  test(
    'validator no longer reports World 0 dealer-position jargon failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);

      expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined,
        isNot(contains('world0_drills_index_dealer_position_jargon_leak_v1')),
      );
    },
  );
}
