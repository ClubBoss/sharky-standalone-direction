import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

final _catalog = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

void main() {
  for (final taskId in [
    'hand_rankings_pair_drill',
    'hand_rankings_trips_drill',
    'hand_rankings_full_house_drill',
    'hand_rankings_best_five_drill',
    'w4_big_price_marginal_fold',
    'outs_improvement_w5_clean_vs_risky_out_transfer',
    'w6_kicker_showdown_compare',
    'w6_checkpoint_table_best_five',
  ]) {
    testWidgets('actual predecision has no authored solution focus: $taskId', (
      tester,
    ) async {
      final row = _catalog.singleWhere((r) => r.task.taskId == taskId);
      await _mount(
        tester,
        row.world.worldNumber,
        row.lesson.lessonId,
        row.task,
        Act0LessonPhaseV1.drill,
      );
      final dynamic table = tester.widget(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_Act0TableV1',
        ),
      );
      expect(
        row.task.runner.table.highlightedCardIds,
        isNotEmpty,
        reason: 'The real source must carry the negative cue.',
      );
      expect(
        table.highlightedCardIds,
        isEmpty,
        reason: 'Merged board overlay must not preselect the solution.',
      );
      expect(
        (table.table as Act0TableStateV1).highlightedCardIds,
        isEmpty,
        reason: 'Seat cards must consume the same neutral projection.',
      );
      expect(
        (table.table as Act0TableStateV1).heroCards,
        row.task.runner.table.heroCards,
      );
      expect(
        (table.table as Act0TableStateV1).boardCards,
        row.task.runner.table.boardCards,
      );
      expect(
        find.byKey(const Key('act0_scene_clue_bracket_board')),
        findsNothing,
      );
      expect(find.byKey(const Key('act0_scene_clue_bracket')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final phase in [Act0LessonPhaseV1.theory, Act0LessonPhaseV1.review]) {
    testWidgets('authored card explanation remains in ${phase.name}', (
      tester,
    ) async {
      final row = _catalog.singleWhere(
        (r) => r.task.taskId == 'hand_rankings_pair_drill',
      );
      await _mount(
        tester,
        row.world.worldNumber,
        row.lesson.lessonId,
        row.task,
        phase,
      );
      final dynamic table = tester.widget(
        find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_Act0TableV1',
        ),
      );
      expect(table.highlightedCardIds, containsAll(['hero_0', 'board_0']));
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> _mount(
  WidgetTester tester,
  int world,
  String lesson,
  Act0LessonTaskV1 task,
  Act0LessonPhaseV1 phase,
) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Act0LessonRunnerShellV1(
          runner: task.runner.copyWith(
            phase: phase,
            teachingStepIndex: phase == Act0LessonPhaseV1.theory
                ? 0
                : task.runner.teachingSteps.length,
            selectedOptionId: phase == Act0LessonPhaseV1.review ? 'pair' : null,
          ),
          worldNumber: world,
          selectedWorldId: 'world_$world',
          selectedLessonId: lesson,
          selectedTaskId: task.taskId,
          selectedTaskTitle: task.title,
          selectedTaskFamily: task.resolvedTaskFamily,
          compositionFamily: task.resolvedCompositionFamily,
          tablePresentation: task.tablePresentation,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
