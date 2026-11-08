import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_content_copy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';

void main() {
  const contracts = <String, (String, String)>{
    'cards_ranks_suits_recap': ('How many cards make your final hand?', 'five'),
    'fold_discipline_fold_recap': (
      'What is the disciplined action with this weak ace facing an open?',
      'fold',
    ),
    'weak_ace_warning_w3_dominated_recap': (
      'What is the disciplined action with this weak ace facing an open?',
      'fold',
    ),
    'apply_recap': (
      'What is the disciplined action with this weak ace facing an open?',
      'fold',
    ),
    'continue_or_let_go_continue_recap': (
      'What is the cleaner continue with this playable hand facing an open?',
      'call',
    ),
  };
  for (final entry in contracts.entries) {
    final world = Act0ShellStateV1.sample.worlds.firstWhere(
      (w) => w.lessons.any((l) => l.taskList.any((t) => t.taskId == entry.key)),
    );
    final lesson = world.lessons.firstWhere(
      (l) => l.taskList.any((t) => t.taskId == entry.key),
    );
    final task = lesson.taskList.singleWhere((t) => t.taskId == entry.key);
    test('source-semantic ${entry.key}', () {
      expect(task.runner.question, entry.value.$1);
      expect(
        task.runner.options.where((o) => o.isCorrect).single.id,
        entry.value.$2,
      );
      expect(task.runner.options.where((o) => !o.isCorrect), isNotEmpty);
    });
    testWidgets('rendered question and options ${entry.key}', (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.drill,
                teachingStepIndex: task.runner.teachingSteps.length,
              ),
              selectedWorldId: world.worldId,
              selectedLessonId: lesson.lessonId,
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
      // ASM-04 displays a neutral English question where the authored stem
      // names the answer; the source question above stays authored.
      expect(
        find.text(
          act0LocalizedRunnerQuestionAtomByTaskIdV1(
            entry.key,
            fallback: entry.value.$1,
          ),
        ),
        findsWidgets,
      );
      for (final option in task.runner.options) {
        expect(
          find.byKey(Key('act0_shell_option_${option.id}')),
          findsOneWidget,
        );
        expect(find.textContaining(option.label), findsWidgets);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
