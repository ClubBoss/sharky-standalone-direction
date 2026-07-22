import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_position_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_play_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_price_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

Act0LearningRunOutcomeV1 _outcome({
  required String id,
  required String skill,
  required Act0LearningRunFinalOutcomeV1 outcome,
  int order = 1,
  bool firstCorrect = true,
  bool repaired = false,
  bool? recheck,
}) => Act0LearningRunOutcomeV1(
  outcomeId: id,
  lessonId: switch (skill) {
    'table_position_read' => 'position_six_seats',
    'price_read' => 'call_price',
    _ => 'fold_check_call_raise',
  },
  taskId: switch (skill) {
    'table_position_read' => 'position_six_seats_positions_button',
    'price_read' => 'w4_bad_price_fold',
    _ => 'actions_check_drill',
  },
  skillId: skill,
  firstAttemptCorrect: firstCorrect,
  errorType: firstCorrect
      ? 'none'
      : switch (skill) {
          'table_position_read' => 'missed_table_position_read',
          'price_read' => 'missed_price_read',
          _ => 'missed_action_read',
        },
  repairAttempted: repaired,
  recheckResult: recheck,
  finalOutcome: outcome,
  missedSignal: switch (skill) {
    'table_position_read' => 'hero_button',
    'price_read' => 'pot_to_call',
    _ => 'no_bet_yet',
  },
  recommendationSignal: switch (skill) {
    'table_position_read' => 'find_button_before_late_position',
    'price_read' => 'compare_pot_to_call',
    _ => 'read_action_order',
  },
  eventOrder: order,
);

Act0LearningRunStateV1 _run(Iterable<Act0LearningRunOutcomeV1> outcomes) {
  var run = const Act0LearningRunStateV1(
    runId: 'learning_run_v1|1',
    startedAtMilliseconds: 100,
  );
  for (final outcome in outcomes) {
    run = run.record(outcome);
  }
  return run;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'a run is ineligible until it has two completed meaningful outcomes',
    () {
      final incomplete = _run(<Act0LearningRunOutcomeV1>[
        _outcome(
          id: 'action:1',
          skill: 'action_read',
          outcome: Act0LearningRunFinalOutcomeV1.incomplete,
          firstCorrect: false,
        ),
      ]);
      expect(incomplete.isPayoffEligible, isFalse);
      expect(Act0LearningRunPayoffPolicyV1.evaluate(incomplete), isNull);

      final meaningful = incomplete.record(
        _outcome(
          id: 'position:1',
          skill: 'table_position_read',
          outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
          order: 2,
        ),
      );
      expect(meaningful.isPayoffEligible, isFalse);
    },
  );

  test('Action clean plus Position recovery keeps both claims truthful', () {
    final payoff = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        _outcome(
          id: 'action:1',
          skill: 'action_read',
          outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
        ),
        _outcome(
          id: 'position:1',
          skill: 'table_position_read',
          outcome: Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
          order: 2,
          firstCorrect: false,
          repaired: true,
          recheck: true,
        ),
      ]),
    );
    expect(payoff, isNotNull);
    expect(payoff!.strength!.skillId, 'action_read');
    expect(payoff.recovered!.skillId, 'table_position_read');
    expect(payoff.unresolved, isNull);
    expect(payoff.nextClue, 'Find the Button before judging who acts late.');
  });

  test('unresolved position outranks a recovered action for next practice', () {
    final payoff = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        _outcome(
          id: 'action:1',
          skill: 'action_read',
          outcome: Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
          firstCorrect: false,
          repaired: true,
          recheck: true,
        ),
        _outcome(
          id: 'position:1',
          skill: 'table_position_read',
          outcome: Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
          order: 2,
          firstCorrect: false,
          repaired: true,
          recheck: false,
        ),
      ]),
    );
    expect(payoff!.recovered!.skillId, 'action_read');
    expect(payoff.unresolved!.skillId, 'table_position_read');
    expect(payoff.nextPractice, 'Practice one more Button read next.');
  });

  test('three-skill payoff scenarios preserve evidence priority and source', () {
    final recoveredPrice = _outcome(
      id: 'price:1',
      skill: 'price_read',
      outcome: Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
      order: 3,
      firstCorrect: false,
      repaired: true,
      recheck: true,
    );
    final unresolvedPrice = _outcome(
      id: 'price:1',
      skill: 'price_read',
      outcome: Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
      order: 3,
      firstCorrect: false,
      repaired: true,
      recheck: false,
    );
    final cleanAction = _outcome(
      id: 'action:1',
      skill: 'action_read',
      outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
      order: 1,
    );
    final cleanPosition = _outcome(
      id: 'position:1',
      skill: 'table_position_read',
      outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
      order: 2,
    );

    // A: two clean + recovered price; the price clue is the next local focus.
    final scenarioA = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        cleanAction,
        cleanPosition,
        recoveredPrice,
      ]),
    )!;
    expect(scenarioA.strength!.skillId, 'action_read');
    expect(scenarioA.recovered!.skillId, 'price_read');
    expect(scenarioA.unresolved, isNull);
    expect(
      scenarioA.nextClue,
      'Compare the pot with the amount you must call.',
    );

    // B: unresolved price controls focus over recovered action and clean position.
    final scenarioB = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        _outcome(
          id: 'action:1',
          skill: 'action_read',
          outcome: Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
          firstCorrect: false,
          repaired: true,
          recheck: true,
        ),
        cleanPosition,
        unresolvedPrice,
      ]),
    )!;
    expect(scenarioB.unresolved!.skillId, 'price_read');
    expect(
      scenarioB.nextPractice,
      'Practice one more pot-versus-call read next.',
    );

    // C: an unresolved Position stays ahead of a recovered price read.
    final scenarioC = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        _outcome(
          id: 'position:1',
          skill: 'table_position_read',
          outcome: Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
          firstCorrect: false,
          repaired: true,
          recheck: false,
        ),
        recoveredPrice,
      ]),
    )!;
    expect(scenarioC.unresolved!.skillId, 'table_position_read');
    expect(scenarioC.recovered!.skillId, 'price_read');

    // D: three clean reads make no repair claim or invented weakness.
    final scenarioD = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        cleanAction,
        cleanPosition,
        _outcome(
          id: 'price:1',
          skill: 'price_read',
          outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
          order: 3,
        ),
      ]),
    )!;
    expect(scenarioD.recovered, isNull);
    expect(scenarioD.unresolved, isNull);

    // E: a single meaningful price result is safely ineligible for a payoff.
    final scenarioE = _run(<Act0LearningRunOutcomeV1>[recoveredPrice]);
    expect(scenarioE.isPayoffEligible, isFalse);
    expect(Act0LearningRunPayoffPolicyV1.evaluate(scenarioE), isNull);

    // F: replay updates the one source outcome without a second payoff row.
    final scenarioF = _run(<Act0LearningRunOutcomeV1>[
      cleanAction,
      _outcome(
        id: 'price:1',
        skill: 'price_read',
        outcome: Act0LearningRunFinalOutcomeV1.incomplete,
        order: 2,
        firstCorrect: false,
      ),
    ]).record(recoveredPrice);
    expect(
      scenarioF.outcomes.where((item) => item.skillId == 'price_read'),
      hasLength(1),
    );
    expect(
      scenarioF.outcomes.last.finalOutcome,
      Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
    );

    // G: incomplete evidence cannot outrank an actual unresolved position.
    final scenarioG = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        cleanAction,
        _outcome(
          id: 'position:1',
          skill: 'table_position_read',
          outcome: Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
          firstCorrect: false,
          repaired: true,
          recheck: false,
        ),
        _outcome(
          id: 'price:1',
          skill: 'price_read',
          outcome: Act0LearningRunFinalOutcomeV1.incomplete,
          order: 2,
          firstCorrect: false,
        ),
      ]),
    )!;
    expect(scenarioG.unresolved!.skillId, 'table_position_read');
  });

  test('duplicate/replay updates one canonical outcome without reordering', () {
    final run =
        _run(<Act0LearningRunOutcomeV1>[
          _outcome(
            id: 'position:1',
            skill: 'table_position_read',
            outcome: Act0LearningRunFinalOutcomeV1.incomplete,
            firstCorrect: false,
            order: 2,
          ),
          _outcome(
            id: 'action:1',
            skill: 'action_read',
            outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
            order: 1,
          ),
        ]).record(
          _outcome(
            id: 'position:1',
            skill: 'table_position_read',
            outcome: Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
            firstCorrect: false,
            repaired: true,
            recheck: true,
            order: 8,
          ),
        );
    expect(run.outcomes, hasLength(2));
    expect(run.outcomes.first.outcomeId, 'action:1');
    expect(
      run.outcomes.last.finalOutcome,
      Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
    );
    expect(run.isPayoffEligible, isTrue);
  });

  test(
    'closed, completed run state is explicit and does not retain a payoff',
    () {
      final closed = _run(<Act0LearningRunOutcomeV1>[
        _outcome(
          id: 'action:1',
          skill: 'action_read',
          outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
        ),
        _outcome(
          id: 'action:2',
          skill: 'action_read',
          outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
          order: 2,
        ),
      ]).close(reason: 'explicit_learn_to_home', finalizedAtMilliseconds: 200);
      final completed = closed.markPayoffViewed().markPayoffCompleted();
      expect(completed.closureReason, 'explicit_learn_to_home');
      expect(completed.payoffCompleted, isTrue);
    },
  );

  testWidgets('compact payoff keeps its Home CTA reachable', (tester) async {
    var completed = false;
    final payoff = Act0LearningRunPayoffPolicyV1.evaluate(
      _run(<Act0LearningRunOutcomeV1>[
        _outcome(
          id: 'action:1',
          skill: 'action_read',
          outcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
        ),
        _outcome(
          id: 'position:1',
          skill: 'table_position_read',
          outcome: Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
          order: 2,
          firstCorrect: false,
          repaired: true,
          recheck: false,
        ),
      ]),
    )!;
    await tester.binding.setSurfaceSize(const Size(375, 812));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LearningRunPayoffSheetV1(
            payoff: payoff,
            onComplete: () => completed = true,
          ),
        ),
      ),
    );
    final cta = find.byKey(const Key('act0_learning_run_payoff_complete_cta'));
    await tester.ensureVisible(cta);
    expect(tester.getRect(cta).bottom, lessThanOrEqualTo(812));
    await tester.tap(cta);
    expect(completed, isTrue);
  });

  testWidgets('opening Learn and theory alone do not start a Learning Run', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.learn,
          showPlacementOnStart: false,
          state: Act0ShellStateV1.sample,
          telemetrySink: sink,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
    expect(
      sink.events.where((event) => event.name == 'learning_run_started'),
      isEmpty,
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('act0_shell_bottom_nav')),
        matching: find.text('Home'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      sink.events.where((event) => event.name == 'learning_run_closed'),
      isEmpty,
    );
  });

  testWidgets(
    'runner return preserves one-outcome run until explicit Home exit',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
          localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.learn,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: Act0ShellStateV1.sample,
            telemetrySink: sink,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: Act0PositionPersonalizationV1.worldId,
              lessonId: Act0PositionPersonalizationV1.lessonId,
              taskId: Act0PositionPersonalizationV1.sourceTaskId,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      final correct = runner.runner.options.firstWhere(
        (option) => option.isCorrect,
      );
      final answer = correct.seatId == null || correct.seatId!.isEmpty
          ? find.byKey(Key('act0_shell_option_${correct.id}'))
          : find.byKey(Key('act0_shell_seat_tap_${correct.seatId}'));
      await tester.tap(answer);
      await tester.pumpAndSettle();
      expect(
        sink.events.where((event) => event.name == 'learning_run_started'),
        hasLength(1),
      );
      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
      expect(
        sink.events.where((event) => event.name == 'learning_run_closed'),
        isEmpty,
      );
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('act0_shell_bottom_nav')),
          matching: find.text('Home'),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        sink.events.where((event) => event.name == 'learning_run_closed'),
        hasLength(1),
      );
      expect(
        sink.events.where(
          (event) =>
              event.name == 'session_payoff_skipped_insufficient_evidence',
        ),
        hasLength(1),
      );
      expect(find.byKey(const Key('act0_learning_run_payoff')), findsNothing);
    },
  );

  testWidgets('abandoning an open repair bridge to Home closes the run', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pumpPriceMissAndReturnToLearn(tester, sink);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('act0_shell_bottom_nav')),
        matching: find.text('Home'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      sink.events.where((event) => event.name == 'learning_run_closed'),
      hasLength(1),
    );
    expect(
      sink.events.where(
        (event) => event.name == 'session_payoff_skipped_insufficient_evidence',
      ),
      hasLength(1),
    );
    expect(
      sink.events.where(
        (event) => event.name == 'learning_run_outcome_recorded',
      ),
      isEmpty,
    );
  });

  testWidgets('an unrelated Practice group closes the pending repair run', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pumpPriceMissAndReturnToLearn(tester, sink);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('act0_shell_bottom_nav')),
        matching: find.text('Practice'),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      sink.events.where((event) => event.name == 'learning_run_closed'),
      isEmpty,
    );

    final playShell = tester.widget<Act0PlayShellV1>(
      find.byType(Act0PlayShellV1),
    );
    final unrelatedGroup = playShell.groups.firstWhere(
      (group) => group.isEnabled && group.groupId != 'weak_spots',
    );
    playShell.onStartGroup(unrelatedGroup);
    await tester.pumpAndSettle();

    expect(
      sink.events.where((event) => event.name == 'learning_run_closed'),
      hasLength(1),
    );
    expect(
      sink.events.where(
        (event) => event.name == 'session_payoff_skipped_insufficient_evidence',
      ),
      hasLength(1),
    );
  });
}

Future<void> _pumpPriceMissAndReturnToLearn(
  WidgetTester tester,
  Act0InMemoryTelemetrySinkV1 sink,
) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const <Locale>[Locale('en'), Locale('ru')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.learn,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
        state: Act0ShellStateV1.sample,
        telemetrySink: sink,
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
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final wrong = runner.runner.options.firstWhere((option) => !option.isCorrect);
  await tester.tap(find.byKey(Key('act0_shell_option_${wrong.id}')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
  expect(
    sink.events.where((event) => event.name == 'learning_run_started'),
    hasLength(1),
  );
}
