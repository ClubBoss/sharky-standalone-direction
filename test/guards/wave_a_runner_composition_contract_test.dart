import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
  ).readAsStringSync();

  test('Wave A keeps the shared lower dock visually owned', () {
    expect(source, contains('_sharedRunnerLowerDockDecorationV1'));
    expect(source, contains('decoration: fillLowerStage'));
    expect(source, contains('Act0ShellTokensV1.info.withValues(alpha: 0.26)'));
  });

  test('Wave A makes selectable seats visually distinct from passive seats', () {
    expect(
      source,
      contains(
        'final shouldShowRing = seatVisualState != _SeatVisualStateV1.passive;',
      ),
    );
    expect(
      source,
      contains('_SeatVisualStateV1.selectable => Act0ShellTokensV1.info'),
    );
  });

  test('Wave A preserves distinct dealer and hero-position semantics', () {
    expect(source, contains('if (seat.isDealerButton &&'));
    expect(source, contains("child: const Text(\n            'D'"));
  });
}
