import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test(
    'W3 CO notice reports position order without granting Button credit',
    () {
      final task = Act0ShellStateV1.sample.worlds
          .expand((world) => world.lessons)
          .expand((lesson) => lesson.tasks)
          .firstWhere(
            (task) =>
                task.taskId ==
                'position_checkpoint_position_checkpoint_table_notice',
          );
      final runner = task.runner;

      expect(
        task.taskId,
        'position_checkpoint_position_checkpoint_table_notice',
      );
      expect(runner.lessonId, 'position_checkpoint');
      expect(runner.feedbackSignalId, 'players_behind');
      expect(runner.options.map((option) => option.id), <String>[
        'acts_last',
        'late_free_pass',
        'players_behind',
      ]);
      expect(
        runner.options.map((option) => option.quality),
        <Act0FeedbackQualityV1>[
          Act0FeedbackQualityV1.wrong,
          Act0FeedbackQualityV1.suboptimal,
          Act0FeedbackQualityV1.correct,
        ],
      );

      for (final option in runner.options) {
        final receipt = act0FirstValueSkillReceiptForRunnerV1(
          runner: runner,
          option: option,
          taskFamily: task.resolvedTaskFamily,
        );

        expect(receipt, isNotNull, reason: option.id);
        expect(receipt!.sourceSignalId, 'players_behind', reason: option.id);
        expect(receipt.sourceSignalLabel, 'Players behind', reason: option.id);
        expect(receipt.skillAtomId, 'table_position_read', reason: option.id);
        expect(receipt.sourceSignalId, isNot('hero_button'), reason: option.id);
        expect(receipt.sourceSignalId, isNot('pot_to_call'), reason: option.id);
        expect(receipt.skillAtomId, isNot('price_read'), reason: option.id);
        expect(receipt.outcome, switch (option.quality) {
          Act0FeedbackQualityV1.correct => Act0SkillReceiptOutcomeV1.learned,
          Act0FeedbackQualityV1.wrong =>
            Act0SkillReceiptOutcomeV1.repairStarted,
          Act0FeedbackQualityV1.suboptimal =>
            Act0SkillReceiptOutcomeV1.needsRep,
        }, reason: option.id);
      }

      final originalButtonRoute = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_position_read',
        skillAtomId: 'table_position_read',
        sourceSignalId: 'hero_button',
        sourceTaskId: Act0PositionPersonalizationV1.sourceTaskId,
        receiptOutcome: 'repair_started',
      );
      expect(
        originalButtonRoute?.taskId,
        Act0PositionPersonalizationV1.repairTaskId,
      );

      final w3ButtonDebtRoute = act0FirstValueSameSignalRepMappingV1(
        nextRepId: 'repeat_table_position_read',
        skillAtomId: 'table_position_read',
        sourceSignalId: 'players_behind',
        sourceTaskId: task.taskId,
        receiptOutcome: 'learned',
      );
      expect(w3ButtonDebtRoute, isNull);
    },
  );
}
