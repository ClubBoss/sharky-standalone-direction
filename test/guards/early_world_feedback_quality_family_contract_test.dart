import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_price_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  testWidgets(
    'canonical Act0 learner route surfaces specific corrective feedback after a wrong decision',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: Act0ShellStateV1.sample,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: Act0PricePersonalizationV1.worldId,
              lessonId: Act0PricePersonalizationV1.lessonId,
              taskId: Act0PricePersonalizationV1.sourceTaskId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final routeRunner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      final wrong = routeRunner.runner.options.firstWhere(
        (option) => !option.isCorrect,
      );
      await tester.tap(find.byKey(Key('act0_shell_option_${wrong.id}')));
      await tester.pumpAndSettle();

      expect(find.byType(Act0FeedbackShellV1), findsOneWidget);
      final feedback = tester.widget<Act0FeedbackShellV1>(
        find.byType(Act0FeedbackShellV1),
      );
      expect(feedback.quality, Act0FeedbackQualityV1.wrong);
      expect(feedback.selectedLabel, wrong.label);
      expect(feedback.betterLabel, isNotEmpty);
      expect(feedback.betterLabel, isNot(wrong.label));
      expect(feedback.reason, isNotEmpty);
      expect(feedback.nextClueLine, isNotEmpty);
      expect(
        find.byKey(const Key('act0_shell_feedback_primary_result_block')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_feedback_next_clue')),
        findsOneWidget,
      );
      expect(find.text(feedback.betterLabel), findsOneWidget);
    },
  );
}
