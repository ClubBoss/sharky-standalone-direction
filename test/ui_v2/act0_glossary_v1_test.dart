import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_sheet_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// HLP-02.a: the beginner glossary and hand ranks open from inside a lesson,
// every term shown there is defined, and opening it changes nothing in the
// task (no answer is chosen or revealed).

final _rows = [
  for (final w in Act0ShellStateV1.sample.worlds)
    for (final l in w.lessons)
      for (final t in l.taskList) (world: w, lesson: l, task: t),
];

// Start the transition on a frame, then advance past the modal or tile motion.
Future<void> _pumpTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _checkNumericTools(WidgetTester tester, Finder sheet) async {
  Future<void> tapTool(String title) async {
    final header = find.descendant(of: sheet, matching: find.text(title));
    await tester.ensureVisible(header);
    await tester.pump();
    expect(header.hitTestable(), findsOneWidget);
    await tester.tap(header);
    await _pumpTransition(tester);
  }

  Future<void> enterVisibleText(Finder field, String value) async {
    await tester.ensureVisible(field);
    await tester.pump();
    await tester.enterText(field, value);
    await tester.pump();
  }

  await tapTool('Price Bar and pot odds');
  final pot = find.byKey(const Key('act0_tool_pot'));
  final call = find.byKey(const Key('act0_tool_call'));
  await enterVisibleText(pot, '30');
  await enterVisibleText(call, '10');
  expect(
    find.text('Pot after call 40.00 · Break-even equity 25.00%'),
    findsOneWidget,
  );
  expect(find.text('Pot odds 3.00 to 1'), findsOneWidget);
  await enterVisibleText(call, '31');
  expect(
    find.text('Enter a positive pot and a valid call amount.'),
    findsOneWidget,
  );
  FocusManager.instance.primaryFocus?.unfocus();
  await tapTool('Price Bar and pot odds');

  await tapTool('BB and chips');
  await enterVisibleText(
    find.byKey(const Key('act0_tool_blind_amount')),
    '2.5',
  );
  await enterVisibleText(find.byKey(const Key('act0_tool_blind_rate')), '20');
  expect(find.text('50.00 chips'), findsOneWidget);
  FocusManager.instance.primaryFocus?.unfocus();
  await tapTool('BB and chips');

  await tapTool('Outs to percentage');
  await enterVisibleText(find.byKey(const Key('act0_tool_outs')), '9');
  expect(find.text('Next card 19.15%'), findsOneWidget);
  expect(find.text('By the river 34.97%'), findsOneWidget);
  FocusManager.instance.primaryFocus?.unfocus();
  await tapTool('Outs to percentage');
}

void main() {
  test('every term the glossary shows for a W1–W12 task is defined', () {
    final names = act0GlossaryTermsV1.map((t) => t.name).toList();
    expect(names.toSet().length, names.length, reason: 'duplicate terms');
    final problems = <String>[];
    for (final t in act0GlossaryTermsV1) {
      if (t.definition.trim().length < 20) {
        problems.add('${t.name}: no real definition');
      }
      // The sheet decides "in this task" by the same pattern, so a term must
      // at least be found in its own name.
      if (!t.usedIn(t.name)) problems.add('${t.name}: pattern misses its name');
    }
    var tasksWithTerms = 0;
    for (final r in _rows) {
      final shown = act0GlossaryTermsInV1(
        act0GlossaryTaskTextV1(r.task.runner),
      );
      if (shown.isNotEmpty) tasksWithTerms++;
      for (final t in shown) {
        if (t.definition.trim().isEmpty) {
          problems.add('${r.task.taskId}: ${t.name} shown without definition');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
    expect(tasksWithTerms, greaterThan(_rows.length * 0.9));
  });

  test('hand ranks run from royal flush down to high card', () {
    expect(act0HandRanksV1.map((r) => r.name), [
      'Royal flush',
      'Straight flush',
      'Four of a kind',
      'Full house',
      'Flush',
      'Straight',
      'Three of a kind (trips)',
      'Two pair',
      'One pair',
      'High card',
    ]);
    for (final r in act0HandRanksV1) {
      expect(r.example.trim(), isNotEmpty, reason: r.name);
      expect(r.definition.trim(), isNotEmpty, reason: r.name);
    }
  });

  testWidgets(
    'lesson glossary shows shared definitions and opens all three numeric tools',
    (tester) async {
      final row = _rows.firstWhere(
        (r) =>
            r.world.worldNumber == 1 &&
            r.task.runner.options.length > 1 &&
            r.task.runner.teachingSteps.isNotEmpty &&
            act0GlossaryTermsInV1(
              act0GlossaryTaskTextV1(r.task.runner),
            ).isNotEmpty,
      );
      final task = row.task;
      final chosen = <Act0RunnerOptionV1>[];
      var assistance = 0;
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<void> mount(
        Act0LessonPhaseV1 phase, {
        String? selectedOptionId,
        bool teaching = false,
      }) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: phase,
                selectedOptionId: selectedOptionId,
                teachingStepIndex: teaching
                    ? 0
                    : task.runner.teachingSteps.length,
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
              onChooseOption: chosen.add,
              onContinueReview: () {},
              onChoiceAssistance: (_) => assistance++,
            ),
          ),
        ),
      );
      final glossary = find.byKey(const Key('act0_shell_runner_glossary'));
      await mount(Act0LessonPhaseV1.drill);
      await _pumpTransition(tester);
      expect(glossary, findsNothing);

      await mount(Act0LessonPhaseV1.theory);
      await _pumpTransition(tester);
      expect(glossary, findsOneWidget);

      await mount(Act0LessonPhaseV1.drill, teaching: true);
      await _pumpTransition(tester);
      await tester.tap(glossary);
      await _pumpTransition(tester);
      final sheet = find.byKey(const Key('act0_glossary_sheet'));
      expect(sheet, findsOneWidget);

      String slug(String s) =>
          s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
      final scrollable = find
          .descendant(of: sheet, matching: find.byType(Scrollable))
          .first;
      final inTask = find.byKey(const Key('act0_glossary_in_task'));
      await tester.scrollUntilVisible(inTask, 200, scrollable: scrollable);
      expect(inTask.hitTestable(), findsOneWidget);
      for (final t in act0GlossaryTermsInV1(
        act0GlossaryTaskTextV1(task.runner),
      )) {
        final entry = find.byKey(Key('act0_glossary_term_${slug(t.name)}'));
        await tester.scrollUntilVisible(entry, 200, scrollable: scrollable);
        expect(
          find.descendant(of: entry, matching: find.text(t.definition)),
          findsOneWidget,
          reason: t.name,
        );
      }
      final firstRank = find.byKey(const Key('act0_glossary_rank_royal_flush'));
      await tester.scrollUntilVisible(firstRank, 200, scrollable: scrollable);
      expect(firstRank, findsOneWidget);

      tester.state<ScrollableState>(scrollable).position.jumpTo(0);
      await tester.pump();
      await _checkNumericTools(tester, sheet);

      await tester.tap(find.byKey(const Key('act0_glossary_close')));
      await _pumpTransition(tester);
      expect(find.byKey(const Key('act0_glossary_sheet')), findsNothing);

      await mount(
        Act0LessonPhaseV1.review,
        selectedOptionId: task.runner.options.firstWhere((o) => o.isCorrect).id,
      );
      await _pumpTransition(tester);
      await tester.tap(glossary);
      await _pumpTransition(tester);
      expect(sheet, findsOneWidget);
      expect(chosen, isEmpty);
      expect(assistance, 0);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
