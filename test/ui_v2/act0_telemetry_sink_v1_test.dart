import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

class _ThrowingTelemetrySinkV1 implements Act0TelemetrySinkV1 {
  @override
  void record(Act0TelemetryEventV1 event) {
    throw StateError('telemetry disabled');
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Widget previewHost({
    Act0TelemetrySinkV1? telemetrySink,
    Act0ShellStateV1? state,
  }) {
    return MaterialApp(
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        state: state,
        showPlacementOnStart: false,
        telemetrySink: telemetrySink,
      ),
    );
  }

  Future<void> openBottomTabV1(WidgetTester tester, String label) async {
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> advanceRunnerUntilV1(
    WidgetTester tester,
    bool Function() isDone, {
    String failureMessage = 'Runner did not advance.',
    int maxTaps = 16,
  }) async {
    for (var i = 0; i < maxTaps; i++) {
      if (isDone()) {
        return;
      }
      final cta = find.byKey(const Key('act0_shell_continue_cta'));
      expect(cta, findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(cta);
      await tester.pumpAndSettle();
    }
    if (isDone()) {
      return;
    }
    fail(failureMessage);
  }

  Future<void> advanceCurrentRunnerToDrillV1(WidgetTester tester) async {
    await advanceRunnerUntilV1(
      tester,
      () =>
          find
              .byKey(const Key('act0_shell_action_panel'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_raise'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_check'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_call'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_option_fold'))
              .evaluate()
              .isNotEmpty ||
          find
              .byKey(const Key('act0_shell_seat_tap_prompt'))
              .evaluate()
              .isNotEmpty,
      failureMessage: 'Runner did not advance into a drill prompt.',
      maxTaps: 12,
    );
  }

  Future<void> answerVisiblePromptCorrectlyV1(WidgetTester tester) async {
    final runnerFinder = find.byType(Act0LessonRunnerShellV1);
    expect(runnerFinder, findsOneWidget);
    final runnerWidget = tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
    final correctOption = runnerWidget.runner.options.firstWhere(
      (option) => option.isCorrect,
    );

    if (runnerWidget.runner.sizingConfig.isEnabled) {
      final preset = find.byKey(
        Key('act0_shell_sizing_preset_${correctOption.id}'),
      );
      expect(preset, findsOneWidget);
      await tester.tap(preset);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
      await tester.pumpAndSettle();
      return;
    }

    final answerKey = correctOption.seatId == null
        ? Key('act0_shell_option_${correctOption.id}')
        : Key('act0_shell_seat_tap_${correctOption.seatId}');
    final answerFinder = find.byKey(answerKey);
    await tester.ensureVisible(answerFinder);
    await tester.pumpAndSettle();
    await tester.tap(answerFinder);
    await tester.pumpAndSettle();
  }

  Future<void> answerVisiblePromptWronglyV1(WidgetTester tester) async {
    final runnerFinder = find.byType(Act0LessonRunnerShellV1);
    expect(runnerFinder, findsOneWidget);
    final runnerWidget = tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
    final wrongOption = runnerWidget.runner.options.firstWhere(
      (option) => !option.isCorrect,
    );

    if (runnerWidget.runner.sizingConfig.isEnabled) {
      final preset = find.byKey(
        Key('act0_shell_sizing_preset_${wrongOption.id}'),
      );
      expect(preset, findsOneWidget);
      await tester.tap(preset);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_sizing_confirm_cta')));
      await tester.pumpAndSettle();
      return;
    }

    final answerKey = wrongOption.seatId == null
        ? Key('act0_shell_option_${wrongOption.id}')
        : Key('act0_shell_seat_tap_${wrongOption.seatId}');
    final answerFinder = find.byKey(answerKey);
    await tester.ensureVisible(answerFinder);
    await tester.pumpAndSettle();
    await tester.tap(answerFinder);
    await tester.pumpAndSettle();
  }

  Future<void> startDailyPracticeFromHubV1(WidgetTester tester) async {
    final dailyTile = find.byKey(const Key('act0_shell_practice_group_daily'));
    if (dailyTile.evaluate().isNotEmpty) {
      await tester.ensureVisible(dailyTile);
      await tester.pumpAndSettle();
      await tester.tap(dailyTile);
      await tester.pumpAndSettle();
      return;
    }

    await tester.tap(find.byKey(const Key('act0_shell_play_featured_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> startActionsTheoryFromLearnV1(
    WidgetTester tester, {
    Act0TelemetrySinkV1? telemetrySink,
  }) async {
    await tester.pumpWidget(previewHost(telemetrySink: telemetrySink));
    await tester.pumpAndSettle();
    await openBottomTabV1(tester, 'Learn');

    final lessonFinder = find.byKey(
      const Key('act0_shell_lesson_Fold, check, call, raise'),
    );
    await tester.ensureVisible(lessonFinder);
    await tester.pumpAndSettle();
    await tester.tap(lessonFinder);
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    final stepFinder = find.byKey(
      const Key('act0_shell_lesson_step_actions_theory'),
    );
    await tester.scrollUntilVisible(
      stepFinder,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(stepFinder);
    await tester.pumpAndSettle();
    await tester.tap(stepFinder);
    await tester.pumpAndSettle();

    final startCta = find.byKey(const Key('act0_shell_selected_lesson_cta'));
    expect(startCta, findsOneWidget);
    await tester.tap(startCta);
    await tester.pumpAndSettle();
  }

  Future<void> waitForRapidPracticeTransitionV1(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
  }

  Future<void> completeDailySetFromPlayV1(WidgetTester tester) async {
    await openBottomTabV1(tester, 'Practice');
    await startDailyPracticeFromHubV1(tester);
    await advanceCurrentRunnerToDrillV1(tester);

    for (var round = 0; round < 3; round++) {
      await answerVisiblePromptCorrectlyV1(tester);
      await waitForRapidPracticeTransitionV1(tester);
      if (find
          .byKey(const Key('act0_shell_play_screen'))
          .evaluate()
          .isNotEmpty) {
        return;
      }
    }
    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
  }

  Future<void> createActionsMistakeFromPlayHubV1(WidgetTester tester) async {
    await openBottomTabV1(tester, 'Practice');
    final dailyTile = find.byKey(const Key('act0_shell_practice_group_daily'));
    if (dailyTile.evaluate().isNotEmpty) {
      await tester.tap(dailyTile);
      await tester.pumpAndSettle();
    } else {
      await tester.tap(find.byKey(const Key('act0_shell_play_featured_cta')));
      await tester.pumpAndSettle();
    }
    await advanceCurrentRunnerToDrillV1(tester);
    await answerVisiblePromptWronglyV1(tester);
  }

  Future<void> completeAgedRecheckFromHomeV1(
    WidgetTester tester, {
    Act0TelemetrySinkV1? telemetrySink,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object?>{
        'schemaVersion': 8,
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'what_poker_is',
        'selectedTaskId': 'what_poker_is_table_read_transfer',
        'retentionSequence': 10,
        'retentionMemory': const <Map<String, Object?>>[
          <String, Object?>{
            'taskId': 'what_poker_is_table_read_transfer',
            'lessonId': 'what_poker_is',
            'worldId': 'world_1',
            'status': 'agedRecheck',
            'attempts': 1,
            'fixedAtSequence': 4,
            'lastRecheckSequence': 0,
            'successfulRecheckCount': 0,
          },
        ],
      }),
    });

    await tester.pumpWidget(previewHost(telemetrySink: telemetrySink));
    await tester.pumpAndSettle();
    await openBottomTabV1(tester, 'Review');
    final replayFinder = find.byKey(
      const Key(
        'act0_shell_fixed_mistake_replay_what_poker_is_table_read_transfer',
      ),
    );
    await tester.ensureVisible(replayFinder);
    await tester.pumpAndSettle();
    await tester.tap(replayFinder);
    await tester.pumpAndSettle();
    await advanceCurrentRunnerToDrillV1(tester);
    await answerVisiblePromptCorrectlyV1(tester);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
  }

  Future<void> completeOwnedCandidateProveFromReviewV1(
    WidgetTester tester, {
    Act0TelemetrySinkV1? telemetrySink,
  }) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object?>{
        'schemaVersion': 8,
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'fold_check_call_raise',
        'selectedTaskId': 'actions_raise_drill',
        'retentionSequence': 10,
        'retentionMemory': const <Map<String, Object?>>[
          <String, Object?>{
            'taskId': 'actions_raise_drill',
            'lessonId': 'fold_check_call_raise',
            'worldId': 'world_1',
            'status': 'ownedCandidate',
            'attempts': 2,
            'fixedAtSequence': 4,
            'lastRecheckSequence': 9,
            'successfulRecheckCount': 1,
          },
        ],
      }),
    });

    await tester.pumpWidget(previewHost(telemetrySink: telemetrySink));
    await tester.pumpAndSettle();
    await openBottomTabV1(tester, 'Review');
    final replayFinder = find.byKey(
      const Key('act0_shell_fixed_mistake_replay_actions_raise_drill'),
    );
    await tester.ensureVisible(replayFinder);
    await tester.pumpAndSettle();
    await tester.tap(replayFinder);
    await tester.pumpAndSettle();
    await advanceCurrentRunnerToDrillV1(tester);
    await answerVisiblePromptCorrectlyV1(tester);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
  }

  void expectNoForbiddenTelemetryFieldsV1(List<Act0TelemetryEventV1> events) {
    for (final event in events) {
      expect(event.fields.containsKey('userId'), isFalse);
      expect(event.fields.containsKey('playerName'), isFalse);
      expect(event.fields.containsKey('email'), isFalse);
      expect(event.fields.containsKey('rawCopy'), isFalse);
      expect(event.fields.containsKey('localizedCopy'), isFalse);
      expect(event.fields.containsKey('promptText'), isFalse);
      expect(event.fields.containsKey('feedbackReason'), isFalse);
      expect(event.fields.containsKey('optionLabel'), isFalse);
      expect(event.fields.containsKey('handHistory'), isFalse);
      expect(event.fields.values, isNot(contains('Daily set complete')));
      expect(event.fields.values, isNot(contains('Repair this spot')));
      expect(event.fields.values, isNot(contains('Three short reps landed.')));
    }
  }

  testWidgets(
    'Act0 runner emits safe task telemetry without changing answer route',
    (tester) async {
      final task = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
          .taskList
          .firstWhere((candidate) => candidate.taskId == 'actions_raise_drill');
      final sink = Act0InMemoryTelemetrySinkV1();
      var selectedOptionId = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Act0LessonRunnerShellV1(
              runner: task.runner.copyWith(
                phase: Act0LessonPhaseV1.drill,
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedWorldId: 'world_1',
              selectedLessonId: 'fold_check_call_raise',
              selectedTaskId: task.taskId,
              selectedTaskFamily: task.resolvedTaskFamily,
              telemetrySink: sink,
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (option) {
                selectedOptionId = option.id;
              },
              onContinueReview: () {},
            ),
          ),
        ),
      );

      expect(sink.events.map((event) => event.name), <String>['task_shown']);

      await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
      await tester.pumpAndSettle();

      expect(selectedOptionId, 'raise');
      expect(sink.events.map((event) => event.name), <String>[
        'task_shown',
        'user_choice',
        'decision_made',
        'task_result',
      ]);

      final shown = sink.events[0].fields;
      expect(shown['schemaVersion'], 1);
      expect(shown['worldId'], 'world_1');
      expect(shown['lessonId'], 'fold_check_call_raise');
      expect(shown['taskId'], 'actions_raise_drill');
      expect(shown['taskFamily'], 'decision');
      expect(shown['phase'], 'drill');
      expect(shown['attemptOrdinal'], 1);

      final userChoice = sink.events[1].fields;
      expect(userChoice['schemaVersion'], 1);
      expect(userChoice['worldId'], 'world_1');
      expect(userChoice['lessonId'], 'fold_check_call_raise');
      expect(userChoice['taskId'], 'actions_raise_drill');
      expect(userChoice['choiceId'], 'raise');
      expect(
        userChoice['decisionTimeBucket'],
        isIn(<Object?>['under_3s', '3_to_10s', 'over_10s', 'unknown']),
      );
      expect(userChoice['attemptOrdinal'], 1);
      expect(userChoice.keys.toSet(), <String>{
        'schemaVersion',
        'worldId',
        'lessonId',
        'taskId',
        'choiceId',
        'decisionTimeBucket',
        'attemptOrdinal',
      });

      final result = sink.events
          .firstWhere((event) => event.name == 'task_result')
          .fields;
      expect(result['schemaVersion'], 1);
      expect(result['worldId'], 'world_1');
      expect(result['lessonId'], 'fold_check_call_raise');
      expect(result['taskId'], 'actions_raise_drill');
      expect(result['choiceId'], 'raise');
      expect(result['result'], 'correct');
      expect(result['errorType'], 'none');
      expect(result['attemptOrdinal'], 1);
      expect(result['repairStatus'], 'none');
      expect(
        sink.events.where((event) => event.name == 'repair_started'),
        isEmpty,
      );
      expect(
        sink.events.where((event) => event.name == 'repair_completed'),
        isEmpty,
      );

      for (final event in sink.events) {
        expect(event.fields.containsKey('userId'), isFalse);
        expect(event.fields.containsKey('playerName'), isFalse);
        expect(event.fields.containsKey('email'), isFalse);
        expect(event.fields.containsKey('rawCopy'), isFalse);
        expect(event.fields.containsKey('localizedCopy'), isFalse);
        expect(event.fields.containsKey('promptText'), isFalse);
        expect(event.fields.containsKey('feedbackReason'), isFalse);
        expect(event.fields.containsKey('optionLabel'), isFalse);
        expect(event.fields.containsKey('handHistory'), isFalse);
        expect(event.fields.values, isNot(contains('Button open')));
        expect(
          event.fields.values,
          isNot(
            contains(
              'First in on the Button, raising opens the pot and pressures the blinds.',
            ),
          ),
        );
      }
    },
  );

  testWidgets('Act0 runner emits canonical decision_made payload aliases', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
        .taskList
        .firstWhere((candidate) => candidate.taskId == 'actions_raise_drill');
    final sink = Act0InMemoryTelemetrySinkV1();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: task.runner.copyWith(
              phase: Act0LessonPhaseV1.drill,
              teachingSteps: const <Act0TeachingStepV1>[],
            ),
            selectedWorldId: 'world_1',
            selectedLessonId: 'fold_check_call_raise',
            selectedTaskId: task.taskId,
            selectedTaskFamily: task.resolvedTaskFamily,
            telemetrySink: sink,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('act0_shell_option_raise')));
    await tester.pumpAndSettle();

    final canonicalDecision = sink.events.firstWhere(
      (event) => event.name == 'decision_made',
    );
    expect(canonicalDecision.fields['world_id'], 'world_1');
    expect(canonicalDecision.fields['lesson_id'], 'fold_check_call_raise');
    expect(canonicalDecision.fields['task_id'], 'actions_raise_drill');
    expect(canonicalDecision.fields['concept_family_id'], 'decision');
    expect(canonicalDecision.fields['selected_action'], 'raise');
    expect(canonicalDecision.fields['correct_action'], 'raise');
    expect(canonicalDecision.fields['is_correct'], isTrue);
    expect(canonicalDecision.fields['error_type'], 'none');
    expect(canonicalDecision.fields['source_surface'], 'act0_runner');
    expect(
      canonicalDecision.fields['time_to_decision_ms'],
      anyOf(isA<int>(), isNull),
    );

    expectNoForbiddenTelemetryFieldsV1(sink.events);
  });

  testWidgets('Act0 runner emits safe incorrect result telemetry', (
    tester,
  ) async {
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'fold_check_call_raise')
        .taskList
        .firstWhere((candidate) => candidate.taskId == 'actions_raise_drill');
    final sink = Act0InMemoryTelemetrySinkV1();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: task.runner.copyWith(
              phase: Act0LessonPhaseV1.drill,
              teachingSteps: const <Act0TeachingStepV1>[],
            ),
            selectedWorldId: 'world_1',
            selectedLessonId: 'fold_check_call_raise',
            selectedTaskId: task.taskId,
            selectedTaskFamily: task.resolvedTaskFamily,
            telemetrySink: sink,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('act0_shell_option_call')));
    await tester.pumpAndSettle();

    final userChoice = sink.events.firstWhere(
      (event) => event.name == 'user_choice',
    );
    expect(userChoice.fields['choiceId'], 'call');
    expect(
      userChoice.fields['decisionTimeBucket'],
      isIn(<Object?>['under_3s', '3_to_10s', 'over_10s', 'unknown']),
    );

    final result = sink.events.firstWhere(
      (event) => event.name == 'task_result',
    );
    expect(result.fields['choiceId'], 'call');
    expect(result.fields['result'], 'incorrect');
    expect(result.fields['errorType'], 'unknown');

    expectNoForbiddenTelemetryFieldsV1(sink.events);
  });

  testWidgets(
    'Act0 runner emits one safe feedback_viewed event from the real feedback path',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();

      await startActionsTheoryFromLearnV1(tester, telemetrySink: sink);
      await advanceCurrentRunnerToDrillV1(tester);
      await answerVisiblePromptCorrectlyV1(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);

      final feedbackViewedEvents = sink.events
          .where((event) => event.name == 'feedback_viewed')
          .toList(growable: false);
      expect(feedbackViewedEvents, hasLength(1));

      final feedbackViewed = feedbackViewedEvents.single.fields;
      expect(feedbackViewed['schemaVersion'], 1);
      expect(feedbackViewed['worldId'], 'world_1');
      expect(feedbackViewed['lessonId'], 'fold_check_call_raise');
      expect(feedbackViewed['taskId'], 'actions_legal_context');
      expect(feedbackViewed['result'], 'correct');
      expect(feedbackViewed['attemptOrdinal'], 1);

      expectNoForbiddenTelemetryFieldsV1(sink.events);
    },
  );

  testWidgets(
    'Act0 repair flow emits safe repair_started and repair_completed telemetry',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();

      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            key: UniqueKey(),
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            telemetrySink: sink,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.day2ReturnHome,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await openBottomTabV1(tester, 'Review');
      final fixNext = find.byKey(const Key('act0_shell_review_practice_cta'));
      expect(fixNext, findsOneWidget);
      await tester.ensureVisible(fixNext);
      await tester.pumpAndSettle();
      await tester.tap(fixNext);
      await tester.pumpAndSettle();

      await advanceCurrentRunnerToDrillV1(tester);
      await answerVisiblePromptCorrectlyV1(tester);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);

      final repairStartedEvents = sink.events
          .where((event) => event.name == 'repair_started')
          .toList(growable: false);
      expect(repairStartedEvents, hasLength(1));

      final repairStart = repairStartedEvents.single.fields;
      expect(repairStart['schemaVersion'], 1);
      expect(repairStart['sourceTaskId'], allOf(isA<String>(), isNot(isEmpty)));
      expect(repairStart['repairTaskId'], allOf(isA<String>(), isNot(isEmpty)));
      expect(repairStart['attemptOrdinal'], 1);

      final repairAttemptedEvents = sink.events
          .where((event) => event.name == 'repair_attempted')
          .toList(growable: false);
      expect(repairAttemptedEvents, hasLength(1));
      expect(
        repairAttemptedEvents.single.fields['repair_focus_id'],
        repairStart['sourceTaskId'],
      );
      expect(repairAttemptedEvents.single.fields['task_id'], isNot(isEmpty));
      expect(
        repairAttemptedEvents.single.fields['source_surface'],
        'act0_review',
      );

      final repairEvents = sink.events
          .where((event) => event.name == 'repair_completed')
          .toList(growable: false);
      expect(repairEvents, hasLength(1));

      final repair = repairEvents.single.fields;
      expect(repair['schemaVersion'], 1);
      expect(repair['sourceTaskId'], allOf(isA<String>(), isNot(isEmpty)));
      expect(repair['repairTaskId'], allOf(isA<String>(), isNot(isEmpty)));
      expect(repair['result'], 'correct');
      expect(repair['attemptOrdinal'], 1);
      expect(repair['repairStatus'], 'fixed');
      expect(repair['sourceTaskId'], repairStart['sourceTaskId']);
      expect(repair['repairTaskId'], repairStart['repairTaskId']);

      final fixLandedEvents = sink.events
          .where((event) => event.name == 'fix_landed')
          .toList(growable: false);
      expect(fixLandedEvents, hasLength(1));
      expect(fixLandedEvents.single.fields['is_correct'], isTrue);
      expect(
        fixLandedEvents.single.fields['repair_focus_id'],
        repairStart['sourceTaskId'],
      );
      expect(fixLandedEvents.single.fields['source_surface'], 'act0_review');

      final repairItemEvents = sink.events
          .where((event) => event.name == 'repair_item_completed')
          .toList(growable: false);
      expect(repairItemEvents, hasLength(1));
      expect(sink.events.last.name, 'repair_item_completed');

      final repairItem = repairItemEvents.single.fields;
      expect(repairItem['schemaVersion'], 1);
      expect(repairItem['sourceTaskId'], repairStart['sourceTaskId']);
      expect(repairItem['targetTaskId'], repairStart['repairTaskId']);
      expect(repairItem['outcome'], 'repaired');
      expect(repairItem['correct'], isTrue);

      expectNoForbiddenTelemetryFieldsV1(sink.events);
    },
  );

  testWidgets('Act0 learn path emits one safe lesson_started telemetry event', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await startActionsTheoryFromLearnV1(tester, telemetrySink: sink);

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);

    final lessonStartedEvents = sink.events
        .where((event) => event.name == 'lesson_started')
        .toList(growable: false);
    expect(lessonStartedEvents, hasLength(1));

    final lessonStarted = lessonStartedEvents.single.fields;
    expect(lessonStarted['schemaVersion'], 1);
    expect(lessonStarted['lessonId'], 'fold_check_call_raise');
    expect(lessonStarted['taskId'], 'actions_theory');
    expect(lessonStarted.keys.toSet(), <String>{
      'schemaVersion',
      'lessonId',
      'taskId',
    });

    final sessionStart = sink.events.firstWhere(
      (event) => event.name == 'session_start',
    );
    expect(sessionStart.fields['lesson_id'], 'fold_check_call_raise');
    expect(sessionStart.fields['task_id'], 'actions_theory');
    expect(sessionStart.fields['source_surface'], 'act0_learn');

    expectNoForbiddenTelemetryFieldsV1(sink.events);
  });

  testWidgets(
    'Act0 daily loop emits safe practice_started and practice_completed telemetry',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();

      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(previewHost(telemetrySink: sink));
      await completeDailySetFromPlayV1(tester);

      expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);

      final practiceStartedEvents = sink.events
          .where((event) => event.name == 'practice_started')
          .toList(growable: false);
      expect(practiceStartedEvents, hasLength(1));

      final practiceStart = practiceStartedEvents.single.fields;
      expect(practiceStart['schemaVersion'], 1);
      expect(practiceStart['practiceGroupId'], 'daily');

      final practiceEvents = sink.events
          .where((event) => event.name == 'practice_completed')
          .toList(growable: false);
      expect(practiceEvents, hasLength(1));
      expect(sink.events.last.name, 'practice_completed');

      final practice = practiceEvents.single.fields;
      expect(practice['schemaVersion'], 1);
      expect(practice['practiceGroupId'], 'daily');
      expect(practice['completedRepCount'], 3);
      expect(practice['cleanRepCount'], inInclusiveRange(0, 3));
      expect(
        practice['resultSummary'],
        isIn(<Object?>['daily_clean_set_complete', 'daily_set_complete']),
      );
      expect(practice['practiceGroupId'], practiceStart['practiceGroupId']);

      final sessionComplete = sink.events.firstWhere(
        (event) => event.name == 'session_complete',
      );
      expect(sessionComplete.fields['source_surface'], 'act0_practice');
      expect(sessionComplete.fields['practice_group_id'], 'daily');
      expect(sessionComplete.fields['completed_rep_count'], 3);

      expectNoForbiddenTelemetryFieldsV1(sink.events);
    },
  );

  testWidgets('Act0 debug surfaces emit day2_return and world_complete', (
    tester,
  ) async {
    final day2Sink = Act0InMemoryTelemetrySinkV1();
    await tester.pumpWidget(
      previewHost(telemetrySink: day2Sink, state: Act0ShellStateV1.sample),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          showPlacementOnStart: false,
          telemetrySink: day2Sink,
          debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.day2ReturnHome,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final day2Return = day2Sink.events.firstWhere(
      (event) => event.name == 'day2_return',
    );
    expect(day2Return.fields['world_id'], 'world_1');
    expect(day2Return.fields['source_surface'], 'act0_home');

    final worldSink = Act0InMemoryTelemetrySinkV1();
    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          key: UniqueKey(),
          showPlacementOnStart: false,
          telemetrySink: worldSink,
          debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
            mode: Act0ControlledDemoCaptureModeV1.directState,
            surface: Act0ControlledDemoCaptureSurfaceV1.worldCompletion,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final worldComplete = worldSink.events.firstWhere(
      (event) => event.name == 'world_complete',
    );
    expect(worldComplete.fields['world_id'], 'world_1');
    expect(worldComplete.fields['source_surface'], 'act0_completion');

    expectNoForbiddenTelemetryFieldsV1(day2Sink.events);
    expectNoForbiddenTelemetryFieldsV1(worldSink.events);
  });

  testWidgets('Act0 recheck flow emits safe recheck_completed telemetry', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await completeAgedRecheckFromHomeV1(tester, telemetrySink: sink);

    final recheckEvents = sink.events
        .where((event) => event.name == 'recheck_completed')
        .toList(growable: false);
    expect(recheckEvents, hasLength(1));

    final recheck = recheckEvents.single.fields;
    expect(recheck['schemaVersion'], 1);
    expect(recheck['taskId'], 'what_poker_is_table_read_transfer');
    expect(recheck['result'], 'correct');
    expect(recheck['attemptOrdinal'], 1);
    expect(recheck['retentionStatus'], 'ownedCandidate');
    expect(recheck['successfulRecheckCount'], 1);

    expectNoForbiddenTelemetryFieldsV1(sink.events);
  });

  testWidgets('Act0 completion telemetry stays non-blocking when sink throws', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      previewHost(telemetrySink: _ThrowingTelemetrySinkV1()),
    );

    await completeDailySetFromPlayV1(tester);

    expect(find.byKey(const Key('act0_shell_play_screen')), findsOneWidget);
  });

  testWidgets('Act0 feedback telemetry stays non-blocking when sink throws', (
    tester,
  ) async {
    await startActionsTheoryFromLearnV1(
      tester,
      telemetrySink: _ThrowingTelemetrySinkV1(),
    );
    await advanceCurrentRunnerToDrillV1(tester);
    await answerVisiblePromptCorrectlyV1(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
  });

  testWidgets('Act0 prove flow emits safe prove_completed telemetry', (
    tester,
  ) async {
    final sink = Act0InMemoryTelemetrySinkV1();

    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await completeOwnedCandidateProveFromReviewV1(tester, telemetrySink: sink);

    final proveEvents = sink.events
        .where((event) => event.name == 'prove_completed')
        .toList(growable: false);
    expect(proveEvents, hasLength(1));

    final prove = proveEvents.single.fields;
    expect(prove['schemaVersion'], 1);
    expect(prove['taskId'], 'actions_raise_drill');
    expect(prove['result'], 'correct');
    expect(prove['attemptOrdinal'], 1);
    expect(prove['retentionStatus'], 'ownedCandidate');

    expectNoForbiddenTelemetryFieldsV1(sink.events);
  });

  testWidgets('Act0 recheck telemetry stays non-blocking when sink throws', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await completeAgedRecheckFromHomeV1(
      tester,
      telemetrySink: _ThrowingTelemetrySinkV1(),
    );

    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);
  });

  testWidgets('Act0 prove telemetry stays non-blocking when sink throws', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await completeOwnedCandidateProveFromReviewV1(
      tester,
      telemetrySink: _ThrowingTelemetrySinkV1(),
    );

    expect(find.byKey(const Key('act0_shell_review_screen')), findsOneWidget);
  });

  testWidgets(
    'Act0 lesson-start telemetry stays non-blocking when sink throws',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await startActionsTheoryFromLearnV1(
        tester,
        telemetrySink: _ThrowingTelemetrySinkV1(),
      );

      expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    },
  );
}
