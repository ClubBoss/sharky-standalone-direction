import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'repair-learning feedback recedes table context without changing CTA copy',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart',
      ).readAsStringSync();

      expect(source, contains('shouldDeemphasizeTableForRepairLearning'));
      expect(source, contains('usesCompactRepairFeedbackDock'));
      expect(source, contains('act0_shell_feedback_table_context_receded_'));
      expect(
        source,
        contains('shouldDeemphasizeTableForRepairLearning ? 0.68 : 1'),
      );
      expect(source, contains('isRepairFocusFeedback'));
      expect(
        source,
        contains('_runnerRepairFeedbackDockTargetLowerSlotHeightV1'),
      );
      expect(source, contains("'Try same clue'"));
      expect(source, contains("'Next hand'"));
    },
  );
}
