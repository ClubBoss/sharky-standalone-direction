import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'visible runner progress labels the existing step count without changing it',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      ).readAsStringSync();
      final start = source.indexOf('class _RunnerProgressV1');
      final end = source.indexOf('class _SeatTapPromptV1');
      final owner = source.substring(start, end);

      expect(owner, contains('value: runner.beatIndex / runner.beatCount'));
      expect(
        owner,
        contains("'Step \${runner.beatIndex}/\${runner.beatCount}'"),
      );
      expect(owner, isNot(contains('worldNumber')));
    },
  );
}
