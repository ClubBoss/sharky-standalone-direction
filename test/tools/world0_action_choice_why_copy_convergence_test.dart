import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const normalizedPaths = <String>[
    'content/worlds/world0/v1/sessions/w0.s01/drills/d.choose_fold.json',
    'content/worlds/world0/v1/sessions/w0.s02/drills/d.choose_call.json',
    'content/worlds/world0/v1/sessions/w0.s03/drills/d.choose_raise.json',
    'content/worlds/world0/v1/sessions/w0.s04/drills/d.choose_fold_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s05/drills/d.choose_call_repeat.json',
    'content/worlds/world0/v1/sessions/w0.s06/drills/d.choose_raise_repeat.json',
  ];

  test(
    'World 0 action-choice why_v1 copy no longer uses the generic template',
    () {
      for (final path in normalizedPaths) {
        final content = File(path).readAsStringSync();
        expect(
          content.contains(
            'This drill checks basic action recognition on the table.',
          ),
          isFalse,
          reason: path,
        );
      }

      expect(
        File(
          'content/worlds/world0/v1/sessions/w0.s02/drills/d.choose_call.json',
        ).readAsStringSync().contains('middle action button'),
        isTrue,
      );
      expect(
        File(
          'content/worlds/world0/v1/sessions/w0.s06/drills/d.choose_raise_repeat.json',
        ).readAsStringSync().contains('checkpoint set'),
        isTrue,
      );
    },
  );

  test(
    'validator no longer reports generic World 0 action-choice why_v1 failures',
    () async {
      final result = await Process.run('dart', [
        'run',
        'tools/validate_world_content_v1.dart',
      ]);
      final combined = '${result.stdout}\n${result.stderr}';
      expect(
        combined.contains('world0_drill_why_generic_action_copy_leak_v1'),
        isFalse,
        reason: combined,
      );
    },
  );
}
