import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';

import '../support/act0_source_choreography_test_wait_v1.dart';

import 'package:poker_analyzer/ui_v2/act0_shell/act0_glossary_sheet_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_task_help_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
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
        [
          r.task.runner.lessonTitle,
          r.task.runner.caption,
          r.task.runner.question,
          r.task.runner.hint,
          for (final step in r.task.runner.teachingSteps) step.body,
          for (final o in r.task.runner.options) o.label,
        ].join(' '),
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

  test(
    'catalogue examples select the same task-relevant tools as the runner',
    () {
      final cases = <String, Set<Act0TaskHelpToolV1>>{
        'what_poker_is_find_hero': {},
        'actions_legal_context': {},
        'w4_pot_bet': {},
        'w4_price_intro': {Act0TaskHelpToolV1.potOdds},
        'w4_good_price_call': {Act0TaskHelpToolV1.potOdds},
        'outs_improvement_w5_table_outs_flush_transfer': {
          Act0TaskHelpToolV1.potOdds,
          Act0TaskHelpToolV1.outs,
        },
        'outs_improvement_w5_table_outs_straight_transfer': {
          Act0TaskHelpToolV1.potOdds,
          Act0TaskHelpToolV1.outs,
        },
        'w6_ak_combos': {},
        'w7_clean_outs_lower_price': {Act0TaskHelpToolV1.potOdds},
        'w12_clean_outs_vs_set': {Act0TaskHelpToolV1.potOdds},
        'w12_turn_count_heart_outs': {},
      };
      for (final entry in cases.entries) {
        final task = _rows.singleWhere((r) => r.task.taskId == entry.key).task;
        final runner = task.phase == Act0LessonPhaseV1.theory
            ? task.runner
            : task.runner.copyWith(
                teachingStepIndex: task.runner.teachingSteps.length,
              );
        expect(
          act0TaskHelpToolsForRunnerV1(runner),
          entry.value,
          reason: entry.key,
        );
      }
    },
  );

  testWidgets('manual calculators retain formulas and validate inputs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          splashFactory: InkRipple.splashFactory,
        ),
        home: const Scaffold(
          body: Act0GlossarySheetV1(
            taskText: '',
            tools: {
              Act0TaskHelpToolV1.potOdds,
              Act0TaskHelpToolV1.blindUnits,
              Act0TaskHelpToolV1.outs,
            },
          ),
        ),
      ),
    );
    await _checkNumericTools(
      tester,
      find.byKey(const Key('act0_glossary_sheet')),
    );
  });

  for (final assisted in [false, true]) {
    testWidgets(
      'W4 Help restores exact decision; calculator assisted=$assisted',
      (tester) async {
        final row = _rows.singleWhere(
          (r) => r.task.taskId == 'w4_good_price_call',
        );
        final task = row.task;
        final chosen = <Act0RunnerOptionV1>[];
        final assistance = <Act0DecisionAssistanceV1>[];
        final ack = Completer<bool>();
        var requests = 0;
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final runner = task.runner.copyWith(
          phase: Act0LessonPhaseV1.drill,
          teachingStepIndex: task.runner.teachingSteps.length,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark().copyWith(
              splashFactory: InkRipple.splashFactory,
            ),
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
                onChooseOption: chosen.add,
                onContinueReview: () {},
                onChoiceAssistance: assistance.add,
                onAssistanceExposureRequested: (kind) {
                  expect(kind, Act0DecisionAssistanceV1.quickHint);
                  requests++;
                  return ack.future;
                },
              ),
            ),
          ),
        );
        await pumpSourceChoreographyToDecisionV1(tester, runner.table);
        final answer = task.runner.options.firstWhere((o) => o.isCorrect);
        final option = find.byKey(Key('act0_shell_option_${answer.id}'));
        expect(option, findsOneWidget);
        final before = tester.getRect(option);
        await tester.tap(find.byKey(const Key('act0_shell_runner_glossary')));
        await _pumpTransition(tester);
        expect(find.byKey(const Key('act0_glossary_sheet')), findsOneWidget);
        expect(find.text('Price Bar and pot odds'), findsOneWidget);
        expect(find.text('BB and chips'), findsNothing);
        expect(find.text('Outs to percentage'), findsNothing);
        expect(find.byKey(const Key('act0_glossary_term_pot')), findsOneWidget);
        expect(
          find.byKey(const Key('act0_glossary_term_showdown')),
          findsNothing,
        );
        expect(requests, 0);
        if (assisted) {
          await tester.tap(find.text('Price Bar and pot odds'));
          await tester.pump();
          expect(requests, 1);
          expect(
            find.byKey(const Key('act0_tool_pot')),
            findsNothing,
            reason: 'no tool before durable acknowledgement',
          );
          ack.complete(true);
          await _pumpTransition(tester);
          final pot = find.byKey(const Key('act0_tool_pot'));
          expect(pot, findsOneWidget);
          expect(
            tester
                .widget<EditableText>(
                  find.descendant(of: pot, matching: find.byType(EditableText)),
                )
                .controller
                .text,
            isEmpty,
          );
          expect(assistance, [Act0DecisionAssistanceV1.quickHint]);
        }
        await tester.tap(find.byKey(const Key('act0_glossary_close')));
        await _pumpTransition(tester);
        expect(chosen, isEmpty);
        expect(tester.getRect(option), before);
        final restored = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(restored.runner, same(runner));
        await tester.ensureVisible(option);
        await tester.tap(option);
        await _pumpTransition(tester);
        expect(chosen, [answer]);
        expect(
          assistance.last,
          assisted
              ? Act0DecisionAssistanceV1.quickHint
              : Act0DecisionAssistanceV1.none,
        );
        expect(requests, assisted ? 1 : 0);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets(
    'calculator-assisted correct is not first independent on Result or archive',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final sample = Act0ShellStateV1.sample;
      final row = _rows.singleWhere(
        (r) => r.task.taskId == 'w4_good_price_call',
      );
      final task = row.task;
      final lesson = row.lesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        tasks: [task],
      );
      final world = row.world.copyWith(
        status: Act0WorldStateV1.current,
        isSelectable: true,
        isLocked: false,
        lessons: [lesson],
      );
      final state = Act0ShellStateV1(
        courseTitle: sample.courseTitle,
        courseSubtitle: sample.courseSubtitle,
        levelLabel: sample.levelLabel,
        xp: sample.xp,
        xpTarget: sample.xpTarget,
        streakDays: sample.streakDays,
        dailyGoalLabel: sample.dailyGoalLabel,
        dailyGoalValue: sample.dailyGoalValue,
        pathProgressLabel: sample.pathProgressLabel,
        selectedWorldId: world.worldId,
        worlds: [world],
        lessons: [lesson],
        review: sample.review,
        profile: sample.profile,
      );
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(splashFactory: InkRipple.splashFactory),
          home: Act0ShellPreviewScreenV1(
            debugLegacyPlacementOnStart: true,
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: state,
            debugHarnessEntry: Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: world.worldId,
              lessonId: lesson.lessonId,
              taskId: task.taskId,
            ),
          ),
        ),
      );
      await _pumpTransition(tester);
      await pumpSourceChoreographyToDecisionV1(tester, task.runner.table);
      Future<void> tap(Finder target) async {
        await tester.ensureVisible(target);
        await tester.pump();
        expect(target.hitTestable(), findsOneWidget);
        await tester.tap(target.hitTestable());
        await _pumpTransition(tester);
      }

      await tap(find.byKey(const Key('act0_shell_runner_glossary')));
      await tap(find.text('Price Bar and pot odds'));
      for (
        var i = 0;
        i < 20 && find.byKey(const Key('act0_tool_pot')).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byKey(const Key('act0_tool_pot')), findsOneWidget);
      await tap(find.byKey(const Key('act0_glossary_close')));
      final answer = task.runner.options.firstWhere((o) => o.isCorrect);
      await tap(find.byKey(Key('act0_shell_option_${answer.id}')));
      final shell = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(shell.isAssistedDecision, isTrue);
      await tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
      final result = tester.widget<Act0BlockCompletionShellV1>(
        find.byType(Act0BlockCompletionShellV1),
      );
      expect(result.summary.assistedCorrectCount, 1);
      expect(result.summary.independentCount, 0);
      expect(result.firstCorrectEarnedThisRun, isFalse);
      await tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_result_close')),
          matching: find.byType(IconButton),
        ),
      );
      await tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Review'),
        ),
      );
      await tap(find.byKey(const Key('act0_review_open_attempts')));
      expect(find.textContaining('· Assisted'), findsWidgets);
    },
  );
}
