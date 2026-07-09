import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('wrong feedback recedes only its table context', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
    ).readAsStringSync();

    expect(source, contains('shouldDeemphasizeTableForWrongFeedback'));
    expect(
      source,
      contains('runner.reviewQuality == Act0FeedbackQualityV1.wrong'),
    );
    expect(source, contains('act0_shell_feedback_table_context_receded_'));
    expect(
      source,
      contains('shouldDeemphasizeTableForWrongFeedback ? 0.68 : 1'),
    );
    expect(source, contains("'Try same clue'"));
    expect(source, contains("'Next hand'"));
  });
}
