import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// ASM04 investigation only. Source inventory is not a semantic no-leak verdict.
// Review-role tasks enter drill; theory/explicit assistance are kept distinct.
final _catalog = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task),
];

void main() {
  test('inventory every canonical task and assessed pre-choice surface', () {
    final rows = [
      for (final row in _catalog)
        <String, Object?>{
          'worldId': row.world.worldId,
          'lessonId': row.lesson.lessonId,
          'taskId': row.task.taskId,
          'sourcePhase': row.task.phase.name,
          'entryPhase': row.task.entryPhase.name,
          'assessed':
              row.task.entryPhase != Act0LessonPhaseV1.theory &&
              row.task.runner.options.isNotEmpty,
          'family': row.task.resolvedTaskFamily.name,
          'composition': row.task.resolvedCompositionFamily.name,
          'tablePresentation': row.task.tablePresentation.name,
          'title': row.task.title,
          'runnerId': row.task.runner.lessonId,
          'caption': row.task.runner.caption,
          'question': row.task.runner.question,
          'hint': row.task.runner.hint,
          'hintPolicy': row.task.runner.hintPolicy.name,
          'centerLabel': row.task.runner.table.centerLabel,
          'focusCallout': row.task.runner.table.focusCalloutLabel,
          'scope': row.task.runner.table.scope.name,
          'highlightedSeats': row.task.runner.table.highlightedSeatIds,
          'selectableSeats': row.task.runner.table.selectableSeatIds,
          'highlightedCards': row.task.runner.table.highlightedCardIds,
          'teachingSteps': [
            for (final step in row.task.runner.teachingSteps)
              {
                'title': step.title,
                'body': step.body,
                'focusLabels': step.focusLabels,
                'focusSeats': step.focusSeatIds,
                'focusCards': step.focusCardIds,
              },
          ],
          'options': [
            for (final option in row.task.runner.options)
              {
                'id': option.id,
                'label': option.label,
                'correct': option.isCorrect,
                'seatId': option.seatId,
              },
          ],
        },
    ];
    expect(rows.map((row) => row['taskId']).toSet(), hasLength(rows.length));
    expect(_catalog.map((row) => row.world.worldId).toSet(), hasLength(12));
    final target = File('output/asm04/source-census.json');
    target.parent.createSync(recursive: true);
    target.writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(rows)}\n',
    );
    print(
      'ASM04 catalog=${rows.length} assessed=${rows.where((r) => r['assessed'] == true).length}',
    );
  });

  testWidgets(
    'inventory actual canonical before-choice consumers for all assessed tasks',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final observations = <Map<String, Object?>>[];
      for (final row in _catalog.where(
        (r) =>
            r.task.entryPhase != Act0LessonPhaseV1.theory &&
            r.task.runner.options.isNotEmpty,
      )) {
        final task = row.task;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: task.runner.copyWith(
                  phase: task.entryPhase,
                  teachingStepIndex: task.runner.teachingSteps.length,
                ),
                worldNumber: row.world.worldNumber,
                selectedWorldId: row.world.worldId,
                selectedLessonId: row.lesson.lessonId,
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
        final errors = <String>[];
        Object? error;
        while ((error = tester.takeException()) != null) {
          errors.add(error.toString());
        }
        final tables = find.byWidgetPredicate(
          (w) => w.runtimeType.toString() == '_Act0TableV1',
        );
        final tableInputs = [
          for (final w in tester.widgetList(tables))
            {
              'centerLabel': (w as dynamic).centerLabelOverride as String?,
              'highlightedCards': List<String>.from(
                (w as dynamic).highlightedCardIds as List,
              ),
              'interactiveCallout':
                  (w as dynamic).interactiveCalloutLabel as String,
            },
        ];
        observations.add({
          'worldId': row.world.worldId,
          'taskId': task.taskId,
          'textWidgets': [
            for (final w in tester.widgetList<Text>(find.byType(Text)))
              if (w.data != null) w.data,
          ],
          'tableInputs': tableInputs,
          'visibleBoardClueBrackets': find
              .byKey(const Key('act0_scene_clue_bracket_board'))
              .evaluate()
              .length,
          'visibleHeroClueBrackets': find
              .byKey(const Key('act0_scene_clue_bracket'))
              .evaluate()
              .length,
          'renderErrors': errors,
        });
      }
      File('output/asm04/consumer-census.json').writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(observations)}\n',
      );
      final errors = observations
          .where((r) => (r['renderErrors'] as List).isNotEmpty)
          .map((r) => r['taskId'])
          .toList();
      print(
        'ASM04 consumers=${observations.length} render-error-tasks=$errors',
      );
      expect(
        errors,
        isEmpty,
        reason:
            'Consumer census must disclose failed renders rather than claim complete coverage',
      );
    },
  );

  for (final taskId in [
    'w6_kicker_showdown_compare',
    'w6_checkpoint_table_best_five',
    'showdown_best_hand_drill',
  ]) {
    testWidgets('unassisted board tap does not compute answer highlights: $taskId', (
      tester,
    ) async {
      final row = _catalog.singleWhere((row) => row.task.taskId == taskId);
      final task = row.task;
      final runner = task.runner.copyWith(
        phase: task.entryPhase,
        teachingStepIndex: task.runner.teachingSteps.length,
      );
      expect(runner.phase, Act0LessonPhaseV1.drill);
      expect(runner.selectedOptionId, isNull);
      final assistance = <Act0DecisionAssistanceV1>[];
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              worldNumber: row.world.worldNumber,
              selectedWorldId: row.world.worldId,
              selectedLessonId: row.lesson.lessonId,
              selectedTaskId: task.taskId,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
              onChoiceAssistance: assistance.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final table = find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_Act0TableV1',
      );
      expect(table, findsOneWidget);
      List<String> highlights() => List<String>.from(
        (tester.widget(table) as dynamic).highlightedCardIds as List,
      );
      int visibleBoardBrackets() => find
          .byKey(const Key('act0_scene_clue_bracket_board'))
          .evaluate()
          .length;
      final before = highlights();
      final beforeBrackets = visibleBoardBrackets();
      final board = find.byKey(const Key('act0_shell_card_board_0'));
      expect(board, findsOneWidget);
      await tester.ensureVisible(board);
      await tester.tap(board);
      await tester.pumpAndSettle();
      final after = highlights();
      final afterBrackets = visibleBoardBrackets();
      final callout =
          (tester.widget(table) as dynamic).interactiveCalloutLabel as String;
      final choice = find.byKey(
        Key('act0_shell_option_${runner.options.first.id}'),
      );
      expect(choice, findsOneWidget);
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pump();
      print(
        'ASM04 $taskId before=$before after=$after computed=$callout boardBrackets=$beforeBrackets->$afterBrackets assistance=$assistance',
      );
      expect(assistance, [Act0DecisionAssistanceV1.none]);
      expect(callout, isEmpty);
      if (assistance.last == Act0DecisionAssistanceV1.none) {
        expect(
          afterBrackets,
          beforeBrackets,
          reason:
              'Rendered board clue brackets must not reveal computed winning cards for an unassisted answer',
        );
        expect(
          after.toSet(),
          before.toSet(),
          reason:
              'Computed best-five/winner highlights before an unassisted graded choice',
        );
      }
    });
  }
  for (final mode in ['theory', 'review', 'quickHint', 'theoryRecall']) {
    testWidgets('real source solver explanation remains available: $mode', (
      tester,
    ) async {
      final row = _catalog.singleWhere(
        (r) => r.task.taskId == 'w6_kicker_showdown_compare',
      );
      final task = row.task;
      final correct = task.runner.options.singleWhere((o) => o.isCorrect);
      final assistance = <Act0DecisionAssistanceV1>[];
      final choices = <Act0RunnerOptionV1>[];
      final runner = task.runner.copyWith(
        phase: mode == 'theory'
            ? Act0LessonPhaseV1.theory
            : mode == 'review'
            ? Act0LessonPhaseV1.review
            : Act0LessonPhaseV1.drill,
        teachingStepIndex: task.runner.teachingSteps.length,
        selectedOptionId: mode == 'review' ? correct.id : null,
      );
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: runner,
              worldNumber: row.world.worldNumber,
              selectedWorldId: row.world.worldId,
              selectedLessonId: row.lesson.lessonId,
              selectedTaskId: task.taskId,
              selectedTaskTitle: task.title,
              selectedTaskFamily: task.resolvedTaskFamily,
              compositionFamily: task.resolvedCompositionFamily,
              tablePresentation: task.tablePresentation,
              theoryRecallStep: task.runner.teachingSteps.first,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: choices.add,
              onContinueReview: () {},
              onChoiceAssistance: assistance.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (mode == 'quickHint' || mode == 'theoryRecall') {
        final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
        expect(hint, findsOneWidget);
        await tester.ensureVisible(hint);
        await tester.tap(hint);
        await tester.pumpAndSettle();
        if (mode == 'theoryRecall') {
          final full = find.byKey(const Key('act0_shell_review_full_idea_cta'));
          await tester.ensureVisible(full);
          await tester.tap(full);
          await tester.pumpAndSettle();
        }
        final close = find.byKey(
          const Key('act0_shell_theory_recall_close_cta'),
        );
        await tester.ensureVisible(close);
        await tester.tap(close);
        await tester.pumpAndSettle();
      }
      final board = find.byKey(const Key('act0_shell_card_board_0'));
      await tester.ensureVisible(board);
      await tester.tap(board);
      await tester.pumpAndSettle();
      final table = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_Act0TableV1',
      );
      final callout =
          (tester.widget(table) as dynamic).interactiveCalloutLabel as String;
      expect(callout, startsWith('Best shown hand: You'));
      // Feedback may add its own legitimate repair highlights. Require the
      // source-computed best-five board cards, not a global decoration count.
      for (final id in ['board_0', 'board_1', 'board_3']) {
        expect(
          find.descendant(
            of: find.byKey(Key('act0_shell_card_$id')),
            matching: find.byKey(const Key('act0_scene_clue_bracket_board')),
          ),
          findsOneWidget,
        );
      }
      if (mode == 'quickHint' || mode == 'theoryRecall') {
        final choice = find.byKey(Key('act0_shell_option_${correct.id}'));
        await tester.ensureVisible(choice);
        await tester.tap(choice);
        await tester.pump();
        expect(choices.single.id, correct.id);
        expect(choices.single.isCorrect, isTrue);
        expect(
          assistance.single,
          mode == 'quickHint'
              ? Act0DecisionAssistanceV1.quickHint
              : Act0DecisionAssistanceV1.theoryRecall,
        );
      }
    });
  }
}
