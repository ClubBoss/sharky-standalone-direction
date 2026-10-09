import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_scene_v3.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('F01 follow-up: unsure is coaching, never a correct read', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
        .taskList
        .firstWhere(
          (entry) => entry.taskId == 'what_poker_is_table_read_transfer',
        );
    final check = placementQuickCheckRunnerV1(
      task.runner.copyWith(
        phase: Act0LessonPhaseV1.drill,
        teachingSteps: const <Act0TeachingStepV1>[],
      ),
      signalId: 'board_private_cards',
      checkIndex: 2,
      checkCount: 3,
    );
    expect(
      check.options.firstWhere((option) => option.id == 'not_sure_yet').quality,
      Act0FeedbackQualityV1.suboptimal,
    );

    Future<Act0LearningSceneGuideV3> renderReview(String selectedId) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: check.copyWith(
                phase: Act0LessonPhaseV1.review,
                selectedOptionId: selectedId,
                primaryCtaLabel: 'Next check',
              ),
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
      expect(tester.takeException(), isNull);
      return tester.widget<Act0LearningSceneGuideV3>(
        find.byType(Act0LearningSceneGuideV3),
      );
    }

    final unsure = await renderReview('not_sure_yet');
    expect(unsure.phase.name, 'feedbackSuboptimal');
    expect(unsure.eyebrow, 'LET\'S CHECK THE CLUE');
    expect(unsure.headline, 'Not sure yet? Let\'s check the table clue.');
    expect(unsure.support, isNotEmpty);
    expect(unsure.sharkyState, Act0SharkyCompanionStateV1.neutral);
    expect(unsure.eyebrow, isNot('CORRECT READ'));
    expect(unsure.headline, isNot(contains('was right')));
    expect(unsure.eyebrow, isNot('MISSED CLUE'));

    final correct = await renderReview('board_cards');
    expect(correct.phase.name, 'feedbackCorrect');
    expect(correct.eyebrow, 'CORRECT READ');
    expect(correct.headline, contains('was right'));

    final wrong = await renderReview('hero_private_cards');
    expect(wrong.phase.name, 'feedbackWrong');
    expect(wrong.eyebrow, 'MISSED CLUE');
    expect(wrong.headline, contains('better play'));
  });
}
