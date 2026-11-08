import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets('ASM03 repaired alternative reasons reach EN 14Pro feedback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final tasks = Act0ShellStateV1.sample.worlds
        .expand((w) => w.lessons)
        .expand((l) => l.taskList);
    for (final selection in const [
      ('first_table_guide_one_clear_choice', 'co_still_acting'),
      ('outs_improvement_w5_straight_out', 'nine'),
      ('w6_missed_dry_board', 'bluff'),
      ('w6_turn_pressure_shift_transfer', 'bet_value'),
    ]) {
      final task = tasks.singleWhere((t) => t.taskId == selection.$1);
      final choice = task.runner.options.singleWhere(
        (o) => o.id == selection.$2,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              key: ValueKey(task.taskId),
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: choice.id,
              ),
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              tableVisualVariant: Act0ShellTableVisualVariantV1.refinedDev2,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: task.taskId);
      final guide = tester.widget<Act0LearningSceneGuideV3>(
        find.byType(Act0LearningSceneGuideV3),
      );
      expect(
        guide.support,
        choice.feedbackReason,
        reason: '${task.taskId}/${choice.id}',
      );
      expect(guide.phase, switch (choice.quality) {
        Act0FeedbackQualityV1.correct =>
          Act0LearningScenePhaseV3.feedbackCorrect,
        Act0FeedbackQualityV1.wrong => Act0LearningScenePhaseV3.feedbackWrong,
        Act0FeedbackQualityV1.suboptimal =>
          Act0LearningScenePhaseV3.feedbackSuboptimal,
      });
    }
  });
}
