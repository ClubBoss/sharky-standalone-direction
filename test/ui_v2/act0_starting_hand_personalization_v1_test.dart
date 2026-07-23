import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_run_payoff_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_personalized_return_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_starting_hand_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'starting-hand adapter admits only the exact canonical repair tuple',
    () {
      final family = Act0StartingHandPersonalizationV1.fromRepairIntent(
        _intent(),
      );

      expect(family, isNotNull);
      expect(
        family!.feedbackFocus,
        'KQo in HJ is a clean open when the pot is unopened.',
      );
      expect(family.repairStrategyId, 'compare_seat_and_action_frame_v1');
      expect(
        family.recheckMappingId,
        'same_starting_hand_discipline_signal_v1',
      );
      expect(
        Act0StartingHandPersonalizationV1.isCanonicalSourceTask(
          Act0StartingHandPersonalizationV1.sourceTaskId,
        ),
        isTrue,
      );

      final adjacentIntents = <Act0RepairIntentV1>[
        _intent(sourceTaskId: 'apply_btn_open'),
        _intent(targetTaskId: 'continue_or_let_go_weak_let_go'),
        _intent(errorType: 'misread_table_position'),
        _intent(skillAtomId: 'starting_hand_read'),
        _intent(missedSignalId: 'hero_cards'),
        _intent(mappingType: 'exact'),
      ];
      for (final intent in adjacentIntents) {
        expect(
          Act0StartingHandPersonalizationV1.fromRepairIntent(intent),
          isNull,
        );
      }
      expect(
        Act0StartingHandPersonalizationV1.isCanonicalSourceTask(
          'continue_or_let_go_medium_call_or_fold',
        ),
        isFalse,
      );
    },
  );

  test(
    'authored source and target frames retain their canonical poker truth',
    () {
      final world = Act0ShellStateV1.sample.worldById(
        Act0StartingHandPersonalizationV1.worldId,
      );
      final sourceLesson = world.lessons.firstWhere(
        (lesson) =>
            lesson.lessonId == Act0StartingHandPersonalizationV1.sourceLessonId,
      );
      final source = sourceLesson.taskList.firstWhere(
        (task) => task.taskId == Act0StartingHandPersonalizationV1.sourceTaskId,
      );
      final targetLesson = world.lessons.firstWhere(
        (lesson) =>
            lesson.lessonId == Act0StartingHandPersonalizationV1.repairLessonId,
      );
      final target = targetLesson.taskList.firstWhere(
        (task) => task.taskId == Act0StartingHandPersonalizationV1.repairTaskId,
      );

      expect(source.runner.caption, 'HJ. Pot unopened. Hero holds K♦ Q♣.');
      expect(source.runner.table.activeSeatId, 'hj');
      expect(source.runner.table.heroCards.map((card) => card.label), <String>[
        'Kd',
        'Qc',
      ]);
      expect(
        source.runner.options.singleWhere((option) => option.isCorrect).id,
        'raise',
      );
      expect(source.runner.feedbackTitle, 'HJ open is clean.');

      expect(target.runner.caption, 'CO opened. Hero is BTN with KQo.');
      expect(target.runner.table.activeSeatId, 'btn');
      expect(target.runner.table.centerLabel, 'CO opened');
      expect(target.runner.table.toCallLabel, 'To call 2.5 BB');
      expect(target.runner.table.heroCards.map((card) => card.label), <String>[
        'Kd',
        'Qc',
      ]);
      expect(
        target.runner.options.singleWhere((option) => option.isCorrect).id,
        'call',
      );
    },
  );

  testWidgets(
    'W2 repair remains incomplete until the original-source recheck recovers it',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpStartingHandTask(
        tester,
        sink,
        initialTab: Act0ShellTabV1.learn,
      );

      await _answer(tester, correct: false);
      expect(
        sink.events.where((event) => event.name == 'learning_run_started'),
        hasLength(1),
      );
      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        isEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name.startsWith('learning_effect_delta_'),
        ),
        isEmpty,
      );
      final state =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final intent =
          state.debugOpenRepairIntentPayloadForSourceTaskV1(
                Act0StartingHandPersonalizationV1.sourceTaskId,
              )
              as Map<String, Object?>?;
      expect(intent, <String, Object?>{
        'schemaVersion': 1,
        'sourceWorldId': 'world_2',
        'sourceLessonId': 'hand_discipline_apply',
        'sourceTaskId': 'apply_hj_decision',
        'choiceId': 'fold',
        'result': 'incorrect',
        'errorType': 'misread_starting_hand_discipline',
        'missedSignalId': 'hero_seat',
        'missedSignalLabel': 'Hero seat',
        'skillAtomId': 'table_read',
        'skillLabel': 'Table read',
        'targetWorldId': 'world_2',
        'targetLessonId': 'continue_or_let_go',
        'targetTaskId': 'continue_or_let_go_medium_call_or_fold',
        'mappingType': 'repair',
        'reasonCode': 'same_signal_table_read_hero_seat',
      });

      await tester.tap(find.text('Try same clue'));
      await tester.pumpAndSettle();
      expect(
        state.debugSelectedTaskIdV1(),
        Act0StartingHandPersonalizationV1.repairTaskId,
      );
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.runner.caption, 'CO opened. Hero is BTN with KQo.');

      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        state.debugOpenRepairIntentPayloadForSourceTaskV1(
          Act0StartingHandPersonalizationV1.sourceTaskId,
        ),
        isNull,
      );
      expect(
        state.debugSelectedTaskIdV1(),
        Act0StartingHandPersonalizationV1.sourceTaskId,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        isEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name.startsWith('learning_effect_delta_'),
        ),
        isEmpty,
      );

      await _answer(tester, correct: true);
      final outcomes = sink.events
          .where((event) => event.name == 'learning_run_outcome_recorded')
          .toList(growable: false);
      expect(outcomes, hasLength(1));
      expect(outcomes.single.fields['task_id'], 'apply_hj_decision');
      expect(outcomes.single.fields['repair_attempted'], isTrue);
      expect(outcomes.single.fields['recheck_result'], isTrue);
      expect(outcomes.single.fields['outcome_type'], 'recoveredAfterRepair');
      expect(
        sink.events.where(
          (event) => event.name == 'learning_effect_delta_viewed',
        ),
        hasLength(1),
      );
      await _continueFeedback(tester);
      expect(
        sink.events.where((event) => event.name == 'recheck_result'),
        hasLength(1),
      );
      expect(
        sink.events.where(
          (event) => event.name == 'learning_effect_delta_completed',
        ),
        hasLength(1),
      );
      expect(
        sink.events.where(
          (event) => event.name == 'starting_hand_personalization_payoff',
        ),
        isEmpty,
      );
    },
  );

  testWidgets('W2 correct-first emits one clean payoff and no repair', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();
    await _pumpStartingHandTask(tester, sink);

    await _answer(tester, correct: true);
    await _continueFeedback(tester);

    final payoffs = sink.events
        .where((event) => event.name == 'starting_hand_personalization_payoff')
        .toList(growable: false);
    expect(payoffs, hasLength(1));
    expect(
      payoffs.single.fields['final_learning_outcome'],
      'hand_discipline_read_cleanly',
    );
    expect(
      sink.events.where((event) => event.name == 'repair_started'),
      isEmpty,
    );
    expect(
      sink.events.where(
        (event) => event.name == 'starting_hand_personalization_classified',
      ),
      isEmpty,
    );
  });

  testWidgets(
    'W2 incomplete and failed repair evidence stays unresolved without duplicate payoff',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpStartingHandTask(
        tester,
        sink,
        initialTab: Act0ShellTabV1.learn,
      );

      await _answer(tester, correct: false);
      final state =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final failedRepairIntent =
          state.debugOpenRepairIntentPayloadForSourceTaskV1(
                Act0StartingHandPersonalizationV1.sourceTaskId,
              )
              as Map<String, Object?>?;
      expect(failedRepairIntent, isNotNull);
      expect(failedRepairIntent?['skillAtomId'], 'table_read');
      expect(failedRepairIntent?['missedSignalId'], 'hero_seat');
      expect(
        sink.events.where(
          (event) => event.name == 'starting_hand_personalization_payoff',
        ),
        isEmpty,
      );

      await tester.tap(find.text('Try same clue'));
      await tester.pumpAndSettle();
      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        state.debugSelectedTaskIdV1(),
        Act0StartingHandPersonalizationV1.sourceTaskId,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        isEmpty,
      );
      await _answer(tester, correct: false);
      await _continueFeedback(tester);
      expect(
        state.debugOpenRepairIntentPayloadForSourceTaskV1(
          Act0StartingHandPersonalizationV1.sourceTaskId,
        ),
        isNotNull,
      );
      final outcomes = sink.events
          .where((event) => event.name == 'learning_run_outcome_recorded')
          .toList(growable: false);
      expect(outcomes, hasLength(1));
      expect(outcomes.single.fields['outcome_type'], 'stillNeedsPractice');
      expect(outcomes.single.fields['missed_signal'], 'hero_seat');
      expect(
        outcomes.single.fields['recommendation_signal'],
        'compare_seat_and_action_frame',
      );
    },
  );

  test(
    'Learning Run precedence and return reason stay conservative for W2',
    () {
      final unresolved = _learningOutcome(
        id: 'starting_hand:unresolved',
        finalOutcome: Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
        order: 3,
      );
      final recovered = _learningOutcome(
        id: 'starting_hand:recovered',
        finalOutcome: Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
        order: 2,
      );
      final clean = _learningOutcome(
        id: 'starting_hand:clean',
        finalOutcome: Act0LearningRunFinalOutcomeV1.masteredFirstTry,
        order: 1,
        firstCorrect: true,
      );
      final payoff = Act0LearningRunPayoffPolicyV1.evaluate(
        Act0LearningRunStateV1(
          runId: 'w2-precedence',
          startedAtMilliseconds: 1,
          outcomes: <Act0LearningRunOutcomeV1>[clean, recovered, unresolved],
        ),
      );
      expect(payoff, isNotNull);
      expect(payoff!.unresolved?.outcomeId, unresolved.outcomeId);
      expect(payoff.recovered?.outcomeId, recovered.outcomeId);

      final reason = Act0PersonalizedReturnReasonV1.fromSources(
        activeRepairIntents: <Act0RepairIntentV1>[_intent()],
      );
      expect(reason.reasonType, act0ReturnReasonContinueUnresolvedRepairV1);
      expect(reason.conceptFamilyId, 'hero_seat');
      expect(reason.sourceTaskId, 'apply_hj_decision');
      expect(reason.recommendedDestination, 'review');
      expect(reason.recommendedAction, 'repair');
    },
  );
}

Act0RepairIntentV1 _intent({
  String sourceTaskId = Act0StartingHandPersonalizationV1.sourceTaskId,
  String targetTaskId = Act0StartingHandPersonalizationV1.repairTaskId,
  String errorType = Act0StartingHandPersonalizationV1.errorType,
  String skillAtomId = Act0StartingHandPersonalizationV1.skillId,
  String missedSignalId = Act0StartingHandPersonalizationV1.missedSignalId,
  String mappingType = 'repair',
}) => Act0RepairIntentV1(
  sourceWorldId: Act0StartingHandPersonalizationV1.worldId,
  sourceLessonId: Act0StartingHandPersonalizationV1.sourceLessonId,
  sourceTaskId: sourceTaskId,
  choiceId: 'fold',
  result: 'incorrect',
  errorType: errorType,
  missedSignalId: missedSignalId,
  missedSignalLabel: 'Hero seat',
  skillAtomId: skillAtomId,
  skillLabel: 'Table read',
  targetWorldId: Act0StartingHandPersonalizationV1.worldId,
  targetLessonId: Act0StartingHandPersonalizationV1.repairLessonId,
  targetTaskId: targetTaskId,
  mappingType: mappingType,
  reasonCode: 'same_signal_table_read_hero_seat',
);

Act0LearningRunOutcomeV1 _learningOutcome({
  required String id,
  required Act0LearningRunFinalOutcomeV1 finalOutcome,
  required int order,
  bool firstCorrect = false,
}) => Act0LearningRunOutcomeV1(
  outcomeId: id,
  lessonId: Act0StartingHandPersonalizationV1.sourceLessonId,
  taskId: Act0StartingHandPersonalizationV1.sourceTaskId,
  skillId: Act0StartingHandPersonalizationV1.skillId,
  firstAttemptCorrect: firstCorrect,
  errorType: firstCorrect
      ? 'none'
      : Act0StartingHandPersonalizationV1.errorType,
  repairAttempted: !firstCorrect,
  recheckResult: finalOutcome == Act0LearningRunFinalOutcomeV1.incomplete
      ? null
      : finalOutcome == Act0LearningRunFinalOutcomeV1.recoveredAfterRepair,
  finalOutcome: finalOutcome,
  missedSignal: Act0StartingHandPersonalizationV1.missedSignalId,
  recommendationSignal: 'compare_seat_and_action_frame',
  eventOrder: order,
);

Future<void> _pumpStartingHandTask(
  WidgetTester tester,
  Act0InMemoryTelemetrySinkV1 sink, {
  Act0ShellTabV1 initialTab = Act0ShellTabV1.play,
}) async {
  tester.view.physicalSize = const Size(375, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
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
        initialTab: initialTab,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
        state: Act0ShellStateV1.sample,
        telemetrySink: sink,
        debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
          mode: Act0ControlledDemoCaptureModeV1.directState,
          surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
          worldId: Act0StartingHandPersonalizationV1.worldId,
          lessonId: Act0StartingHandPersonalizationV1.sourceLessonId,
          taskId: Act0StartingHandPersonalizationV1.sourceTaskId,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _answer(WidgetTester tester, {required bool correct}) async {
  var runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  var option = runner.runner.options.firstWhere(
    (candidate) => candidate.isCorrect == correct,
  );
  var finder = find.byKey(Key('act0_shell_option_${option.id}'));
  for (var i = 0; i < 4 && finder.evaluate().isEmpty; i++) {
    final continueCta = find.byKey(const Key('act0_shell_continue_cta'));
    expect(continueCta, findsOneWidget);
    await tester.tap(continueCta);
    await tester.pumpAndSettle();
    runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    option = runner.runner.options.firstWhere(
      (candidate) => candidate.isCorrect == correct,
    );
    finder = find.byKey(Key('act0_shell_option_${option.id}'));
  }
  expect(finder, findsOneWidget);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _continueFeedback(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    if (cta.evaluate().isEmpty) return;
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    expect(tester.getRect(cta).bottom, lessThanOrEqualTo(812));
    await tester.tap(cta);
    await tester.pumpAndSettle();
  }
}

Future<void> _openRepair(WidgetTester tester) async {
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('Practice'));
  await tester.pumpAndSettle();
  final queue = find.byKey(const Key('act0_shell_play_repair_queue'));
  expect(queue, findsOneWidget);
  await tester.tap(
    find.descendant(of: queue, matching: find.text('Practice this')),
  );
  await tester.pumpAndSettle();
}
