import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_price_personalization_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('price family accepts only the canonical Pot / to call repair', () {
    final family = Act0PricePersonalizationV1.fromRepairIntent(_intent());

    expect(family, isNotNull);
    expect(
      family!.feedbackFocus,
      'Compare Pot 8 BB with To call 7 BB before you decide.',
    );
    expect(family.repairStrategyId, 'compare_pot_to_call_then_choose_v1');
    expect(family.recheckMappingId, 'same_pot_to_call_signal_v1');
    expect(
      Act0PricePersonalizationV1.fromRepairIntent(
        _intent(targetTaskId: Act0PricePersonalizationV1.sourceTaskId),
      ),
      isNull,
    );
    expect(
      Act0PricePersonalizationV1.fromRepairIntent(
        _intent(missedSignalId: 'board_cards'),
      ),
      isNull,
    );
  });

  testWidgets(
    'W4 price miss repairs and rechecks the Pot / to call signal with ordered telemetry',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpPriceTask(tester, sink, initialTab: Act0ShellTabV1.learn);

      await _answer(tester, correct: false);
      await _continueFeedback(tester);

      final state =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final intent =
          state.debugOpenRepairIntentPayloadForSourceTaskV1(
                Act0PricePersonalizationV1.sourceTaskId,
              )
              as Map<String, Object?>?;
      expect(intent?['errorType'], 'misread_bet_price');
      expect(intent?['missedSignalId'], 'pot_to_call');
      expect(intent?['skillAtomId'], 'price_read');
      expect(intent?['targetTaskId'], Act0PricePersonalizationV1.repairTaskId);

      expect(
        state.debugSelectedTaskIdV1(),
        Act0PricePersonalizationV1.repairTaskId,
      );
      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        isEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'price_personalization_recheck',
        ),
        isEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'price_personalization_payoff',
        ),
        isEmpty,
      );
      expect(
        state.debugSelectedTaskIdV1(),
        Act0PricePersonalizationV1.sourceTaskId,
      );
      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        state.debugOpenRepairIntentPayloadForSourceTaskV1(
          Act0PricePersonalizationV1.sourceTaskId,
        ),
        isNull,
      );

      final familyEvents = sink.events
          .where((event) => event.name.startsWith('price_personalization_'))
          .toList(growable: false);
      expect(familyEvents.map((event) => event.name), <String>[
        'price_personalization_classified',
        'price_personalization_recheck',
        'price_personalization_payoff',
      ]);
      expect(
        familyEvents.map((event) => event.fields['final_learning_outcome']),
        <String>[
          'repair_required',
          'price_signal_recovered',
          'price_signal_recovered',
        ],
      );
      for (final event in familyEvents) {
        expect(event.fields['lesson_id'], 'call_price');
        expect(event.fields['skill_id'], 'price_read');
        expect(
          event.fields['repair_strategy'],
          'compare_pot_to_call_then_choose_v1',
        );
      }

      final choices = sink.events
          .where((event) => event.name == 'user_choice')
          .toList(growable: false);
      expect(choices, hasLength(3));
      expect(
        choices.first.fields['taskId'],
        Act0PricePersonalizationV1.sourceTaskId,
      );
      expect(choices.first.fields['error_type'], 'misread_bet_price');
      expect(choices.first.fields['decisionTimeBucket'], isNotEmpty);
      final outcomes = sink.events
          .where(
            (event) =>
                event.name == 'learning_run_outcome_recorded' &&
                event.fields['outcome_type'] == 'recoveredAfterRepair',
          )
          .toList(growable: false);
      expect(outcomes, hasLength(1));
      expect(outcomes.single.fields['outcome_type'], 'recoveredAfterRepair');
    },
  );

  testWidgets(
    'W4 price correct-first outcome stays truthful and needs no repair',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpPriceTask(tester, sink);

      await _answer(tester, correct: true);
      await _continueFeedback(tester);

      final payoffs = sink.events
          .where((event) => event.name == 'price_personalization_payoff')
          .toList(growable: false);
      expect(payoffs, hasLength(1));
      expect(
        payoffs.single.fields['final_learning_outcome'],
        'price_signal_read_cleanly',
      );
      expect(
        sink.events.where((event) => event.name == 'repair_started'),
        isEmpty,
      );
    },
  );

  testWidgets(
    'W4 failed source recheck records one unresolved Learning Run outcome',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpPriceTask(tester, sink, initialTab: Act0ShellTabV1.learn);

      await _answer(tester, correct: false);
      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        isEmpty,
      );
      await _continueFeedback(tester);
      final state =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      expect(
        state.debugSelectedTaskIdV1(),
        Act0PricePersonalizationV1.repairTaskId,
      );
      await _answer(tester, correct: true);
      await _continueFeedback(tester);
      expect(
        state.debugSelectedTaskIdV1(),
        Act0PricePersonalizationV1.sourceTaskId,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        isEmpty,
      );
      await _answer(tester, correct: false);
      await _continueFeedback(tester);

      final outcomes = sink.events
          .where((event) => event.name == 'learning_run_outcome_recorded')
          .toList(growable: false);
      expect(outcomes, hasLength(1));
      expect(outcomes.single.fields['outcome_type'], 'stillNeedsPractice');
      expect(outcomes.single.fields['skill_id'], 'price_read');
      expect(outcomes.single.fields['repair_attempted'], isTrue);
      expect(outcomes.single.fields['recheck_result'], isFalse);
      expect(outcomes.single.fields['missed_signal'], 'pot_to_call');
      final rechecks = sink.events
          .where((event) => event.name == 'price_personalization_recheck')
          .toList(growable: false);
      expect(rechecks, hasLength(1));
      expect(
        rechecks.single.fields['final_learning_outcome'],
        'price_signal_still_needs_rep',
      );
      expect(
        sink.events.where(
          (event) => event.name == 'price_personalization_payoff',
        ),
        isEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name.startsWith('learning_effect_delta_'),
        ),
        isEmpty,
      );
    },
  );

  testWidgets(
    'W4 failed repair remains incomplete without family terminal events',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await _pumpPriceTask(tester, sink, initialTab: Act0ShellTabV1.learn);

      await _answer(tester, correct: false);
      await _openRepair(tester);
      await _answer(tester, correct: false);

      expect(
        sink.events.where(
          (event) => event.name == 'learning_run_outcome_recorded',
        ),
        isEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'price_personalization_recheck',
        ),
        isEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'price_personalization_payoff',
        ),
        isEmpty,
      );
      final state =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      expect(
        state.debugOpenRepairIntentPayloadForSourceTaskV1(
          Act0PricePersonalizationV1.sourceTaskId,
        ),
        isNotNull,
      );
    },
  );
}

Act0RepairIntentV1 _intent({
  String targetTaskId = Act0PricePersonalizationV1.repairTaskId,
  String missedSignalId = Act0PricePersonalizationV1.missedSignalId,
}) => Act0RepairIntentV1(
  sourceWorldId: Act0PricePersonalizationV1.worldId,
  sourceLessonId: Act0PricePersonalizationV1.lessonId,
  sourceTaskId: Act0PricePersonalizationV1.sourceTaskId,
  choiceId: 'call',
  result: 'incorrect',
  errorType: Act0PricePersonalizationV1.errorType,
  missedSignalId: missedSignalId,
  missedSignalLabel: 'Pot / to call',
  skillAtomId: Act0PricePersonalizationV1.skillId,
  skillLabel: 'Price read',
  targetWorldId: Act0PricePersonalizationV1.worldId,
  targetLessonId: Act0PricePersonalizationV1.lessonId,
  targetTaskId: targetTaskId,
  mappingType: 'repair',
  reasonCode: 'same_signal_price_read_pot_to_call',
);

Future<void> _pumpPriceTask(
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
          worldId: Act0PricePersonalizationV1.worldId,
          lessonId: Act0PricePersonalizationV1.lessonId,
          taskId: Act0PricePersonalizationV1.sourceTaskId,
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
