import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';

void main() {
  testWidgets(
    'fallback renderer respects source actor and street-owned chip identities',
    (t) async {
      t.view.physicalSize = const Size(393, 852);
      t.view.devicePixelRatio = 1;
      t.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPadding);
      Future<void> mount(
        String lesson,
        String id, {
        bool feedback = false,
      }) async {
        final task = Act0ShellStateV1.sample
            .lessonById(lesson)
            .taskList
            .firstWhere((t) => t.taskId == id);
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                key: ValueKey('$id:$feedback'),
                runner: task.runner.copyWith(
                  phase: feedback
                      ? Act0LessonPhaseV1.review
                      : Act0LessonPhaseV1.drill,
                  teachingStepIndex: task.runner.teachingSteps.length,
                  selectedOptionId: feedback
                      ? task.runner.options.first.id
                      : null,
                ),
                selectedWorldId: Act0ShellStateV1.sample.worlds
                    .firstWhere(
                      (w) => w.lessons.any((l) => l.lessonId == lesson),
                    )
                    .worldId,
                selectedLessonId: lesson,
                selectedTaskId: id,
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
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }

      await mount(
        'what_poker_is',
        'what_poker_is_table_read_transfer',
        feedback: true,
      );
      expect(find.textContaining('To act'), findsNothing);
      await mount('fold_check_call_raise', 'actions_check_drill');
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_sb')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_bb')),
        findsNothing,
      );
      expect(find.text('0.5 BB'), findsNothing);
      expect(find.text('1 BB'), findsNothing);
      await mount('price_checkpoint', 'w4_checkpoint_table_price');
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_bb')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('act0_shell_bet_chip_owner_hj')),
        findsNothing,
      );
    },
  );
}
