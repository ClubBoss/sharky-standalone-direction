import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

({Act0WorldCardV1 world, Act0LessonCardV1 lesson, Act0LessonTaskV1 task})
source(String id) {
  final world = Act0ShellStateV1.sample.worlds.firstWhere(
    (w) => w.lessons.any((l) => l.taskList.any((t) => t.taskId == id)),
  );
  final lesson = world.lessons.firstWhere(
    (l) => l.taskList.any((t) => t.taskId == id),
  );
  return (
    world: world,
    lesson: lesson,
    task: lesson.taskList.firstWhere((t) => t.taskId == id),
  );
}

Future<void> host(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));
  await tester.pumpAndSettle();
}

void activate(SemanticsNode node) {
  expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
  node.owner!.performAction(node.id, SemanticsAction.tap);
}

void main() {
  testWidgets(
    'ACC-03: table names visible cards and never reveals face-down opponent cards',
    (tester) async {
      final table = source('your_first_hand_recap').task.runner.table.copyWith(
        heroCards: const [
          Act0CardStateV1(rank: 'K', suit: 's'),
          Act0CardStateV1(rank: 'Q', suit: 'h'),
        ],
        boardCards: const [
          Act0CardStateV1(rank: '2', suit: 'c'),
          Act0CardStateV1(rank: '3', suit: 'd'),
          Act0CardStateV1(rank: '4', suit: 's'),
        ],
        seats: const [
          Act0SeatStateV1(
            seatId: 'btn',
            seatLabel: 'BTN',
            displayName: 'You',
            isHero: true,
          ),
          Act0SeatStateV1(
            seatId: 'bb',
            seatLabel: 'BB',
            displayName: 'Opponent',
            cardsVisibleMode: Act0CardsVisibleModeV1.faceDown,
            holeCards: [
              Act0CardStateV1(rank: 'A', suit: 'c'),
              Act0CardStateV1(rank: 'A', suit: 'd'),
            ],
          ),
        ],
        heroSeatId: 'btn',
        highlightedCardIds: const [],
        highlightedSeatIds: const [],
      );
      await host(tester, Act0TableSceneV1(table: table));
      expect(
        find.bySemanticsLabel('Your card, King of spades'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Your card, Queen of hearts'),
        findsOneWidget,
      );
      expect(find.bySemanticsLabel('Board card 1, 2 of clubs'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Board card 2, 3 of diamonds'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('Board card 3, 4 of spades'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(RegExp('Ace of (clubs|diamonds)')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ACC-03: source seat choice is named, selectable and uses the existing decision callback once',
    (tester) async {
      final row = source('positions_cutoff');
      final choices = <String>[];
      await host(
        tester,
        Act0LessonRunnerShellV1(
          runner: row.task.runner.copyWith(
            phase: row.task.entryPhase,
            teachingStepIndex: row.task.runner.teachingSteps.length,
          ),
          worldNumber: row.world.worldNumber,
          selectedWorldId: row.world.worldId,
          selectedLessonId: row.lesson.lessonId,
          selectedTaskId: row.task.taskId,
          selectedTaskTitle: row.task.title,
          selectedTaskFamily: row.task.resolvedTaskFamily,
          compositionFamily: row.task.resolvedCompositionFamily,
          tablePresentation: row.task.tablePresentation,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: (_) {},
          onChooseSeat: choices.add,
          onContinueReview: () {},
        ),
      );
      final node = tester.getSemantics(
        find.byKey(const Key('act0_shell_seat_tap_co')),
      );
      final data = node.getSemanticsData();
      expect(data.label, 'Select CO');
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(data.hasFlag(SemanticsFlag.isSelected), isFalse);
      activate(node);
      await tester.pump();
      expect(choices.single, 'co');
      activate(node);
      await tester.pump();
      expect(choices, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'ACC-03: first theory page names the exit action and can return to the lesson',
    (tester) async {
      final row = source('cards_ranks_suits_theory');
      var backs = 0;
      await host(
        tester,
        Act0LessonRunnerShellV1(
          runner: row.task.runner.copyWith(
            phase: Act0LessonPhaseV1.theory,
            teachingStepIndex: 0,
          ),
          selectedWorldId: row.world.worldId,
          selectedLessonId: row.lesson.lessonId,
          selectedTaskId: row.task.taskId,
          selectedTaskFamily: row.task.resolvedTaskFamily,
          compositionFamily: row.task.resolvedCompositionFamily,
          tablePresentation: row.task.tablePresentation,
          onBack: () => backs++,
          onContinueTheory: () {},
          onPreviousTheory: () {},
          onChooseOption: (_) {},
          onContinueReview: () {},
        ),
      );
      final data = tester
          .getSemantics(find.byKey(const Key('act0_shell_previous_cta')))
          .getSemanticsData();
      expect(data.label, 'Back to lesson');
      expect(data.hasFlag(SemanticsFlag.isButton), isTrue);
      expect(data.hasFlag(SemanticsFlag.hasEnabledState), isTrue);
      expect(data.hasFlag(SemanticsFlag.isEnabled), isTrue);
      activate(
        tester.getSemantics(find.byKey(const Key('act0_shell_previous_cta'))),
      );
      await tester.pump();
      expect(backs, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'ACC-03: sizing preset reports selection and accessible activation changes it',
    (tester) async {
      final row = source('w4_half_pot_bet');
      final options = row.task.runner.options;
      expect(options.length, greaterThan(1));
      var selected = options.first.id;
      await host(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Act0LessonRunnerShellV1(
            runner: row.task.runner.copyWith(
              phase: Act0LessonPhaseV1.drill,
              teachingSteps: const [],
              selectedPresetId: selected,
              sizingConfig: Act0SizingConfigV1(
                mode: Act0SizingUiModeV1.presetsOnly,
                presets: [
                  for (final option in options)
                    Act0SizingPresetV1(
                      id: option.id,
                      label: option.label,
                      potFraction: 0.5,
                    ),
                ],
              ),
            ),
            selectedWorldId: row.world.worldId,
            selectedLessonId: row.lesson.lessonId,
            selectedTaskId: row.task.taskId,
            selectedTaskFamily: row.task.resolvedTaskFamily,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
            onSelectSizingPreset: (preset) =>
                setState(() => selected = preset.id),
            onConfirmSizingPreset: () {},
          ),
        ),
      );
      final confirm = find.byKey(const Key('act0_shell_sizing_confirm_cta'));
      final readinessPumpLimit =
          row.task.runner.table.actionTrail.length * 2 + 4;
      for (
        var i = 0;
        i < readinessPumpLimit &&
            tester.widget<FilledButton>(confirm).onPressed == null;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 500));
      }
      expect(
        tester.widget<FilledButton>(confirm).onPressed,
        isNotNull,
        reason:
            'Preset activation is tested only after the authored replay is ready',
      );
      final first = find.byKey(
        Key('act0_shell_sizing_preset_${options.first.id}'),
      );
      final second = find.byKey(
        Key('act0_shell_sizing_preset_${options[1].id}'),
      );
      expect(
        tester
            .getSemantics(first)
            .getSemanticsData()
            .hasFlag(SemanticsFlag.isSelected),
        isTrue,
      );
      final node = tester.getSemantics(second);
      expect(node.getSemanticsData().label, contains(options[1].label));
      activate(node);
      await tester.pump();
      expect(selected, options[1].id);
      expect(
        tester
            .getSemantics(second)
            .getSemanticsData()
            .hasFlag(SemanticsFlag.isSelected),
        isTrue,
      );
      expect(
        tester
            .getSemantics(first)
            .getSemanticsData()
            .hasFlag(SemanticsFlag.isSelected),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
