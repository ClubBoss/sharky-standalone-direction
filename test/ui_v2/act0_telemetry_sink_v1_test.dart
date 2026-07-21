import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_hnp_trace_file_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_telemetry_sink_v1.dart';

class _ThrowingTelemetrySinkV1 implements Act0TelemetrySinkV1 {
  @override
  void record(Act0TelemetryEventV1 event) {
    throw StateError('telemetry disabled');
  }
}

class _MemoryHnpTraceFileStoreV1 implements Act0HnpTraceFileStoreV1 {
  String contents = '';

  @override
  Future<String> getPath() async => '/local/act0_hnp_trace_v1.jsonl';

  @override
  Future<void> replace(String jsonl) async {
    contents = jsonl;
  }
}

const _alphaQaTracePathV1 = String.fromEnvironment('ALPHA_QA_TRACE_PATH');
const _actionHnpPhysicalTracePathV1 = String.fromEnvironment(
  'ACTION_HNP_PHYSICAL_TRACE_PATH',
);
const _actionPreconditionFixturePathV1 =
    'tools/contracts/alpha_action_capability_prerequisite_progression_v1.json';

void _writeAlphaQaTraceV1(List<Act0TelemetryEventV1> events) {
  if (_alphaQaTracePathV1.isEmpty) return;
  final file = File(_alphaQaTracePathV1);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(<String, Object?>{
          'schema': 'alpha_journey_qa_trace_v1',
          'journey_id': 'alpha_action_repair_recovery_unlocked_v2',
          'contract_version': 2,
          'black_box_test_name':
              'unlocked Action capability journey completes the alpha loop with ordered safe telemetry',
          'execution_mode': 'deterministic_widget_replay',
          'entry_mode': 'unlocked_action_visible_controls',
          'cta_reachability': 'ensureVisible_before_each_visible_control_tap',
          'debug_harness_used': false,
          'starting_progression': <String, Object?>{
            'kind': 'persisted_progression_fixture',
            'fixture_id': 'alpha_action_capability_prerequisite_progression_v1',
            'obtained_by': 'completed prerequisite learner history',
          },
          'events': events
              .map(
                (event) => <String, Object?>{
                  'name': event.name,
                  'fields': event.fields,
                },
              )
              .toList(growable: false),
        }) +
        '\n',
  );
}

void _writeActionHnpPhysicalTraceV1(String jsonl) {
  if (_actionHnpPhysicalTracePathV1.isEmpty) return;
  final file = File(_actionHnpPhysicalTracePathV1);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(jsonl);
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

  testWidgets(
    'Home generic fallback does not emit personalized-next-step telemetry',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await tester.pumpWidget(previewHost(telemetrySink: sink));
      await tester.pumpAndSettle();

      expect(
        sink.events.where(
          (event) => event.name == 'personalized_next_step_selected',
        ),
        isEmpty,
      );

      await tester.tap(find.byKey(const Key('act0_shell_main_cta')));
      await tester.pumpAndSettle();
      expect(
        sink.events.where(
          (event) => event.name == 'personalized_next_step_opened',
        ),
        isEmpty,
      );
    },
  );

  Future<void> seedActionCapabilityPreconditionV1() async {
    final decoded =
        jsonDecode(File(_actionPreconditionFixturePathV1).readAsStringSync())
            as Map<String, dynamic>;
    expect(decoded['schema'], 'act0_progression_fixture_v1');
    expect(
      decoded['fixture_id'],
      'alpha_action_capability_prerequisite_progression_v1',
    );
    final completedLessonIds =
        (decoded['completed_lesson_ids'] as List<dynamic>)
            .map((value) => value.toString())
            .toList(growable: false);
    final state = Act0ShellStateV1.sample;
    final world = state.worldById(decoded['world_id'] as String);
    final completedTaskIds = <String>[
      for (final lessonId in completedLessonIds)
        ...world.lessons
            .firstWhere((lesson) => lesson.lessonId == lessonId)
            .taskList
            .map((task) => task.taskId),
    ];
    final target = decoded['target'] as Map<String, dynamic>;
    final targetLessonId = target['lesson_id'] as String;
    final targetTaskId = target['task_id'] as String;
    expect(
      world.lessons
          .firstWhere((lesson) => lesson.lessonId == targetLessonId)
          .taskList
          .any((task) => task.taskId == targetTaskId),
      isTrue,
    );
    SharedPreferences.setMockInitialValues(<String, Object>{
      'intake_completed_v1': true,
      'act0_welcome_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 16,
        'completedTaskIds': completedTaskIds,
        'skippedTaskIds': <String>[],
        'completedLessonIds': completedLessonIds,
        'selectedWorldId': world.worldId,
        'selectedLessonId': targetLessonId,
        'selectedTaskId': targetTaskId,
        'earnedXp': 0,
      }),
    });
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
      () {
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        if (runner.selectedTaskId == 'actions_theory') {
          return false;
        }
        return find
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
                .isNotEmpty;
      },
      failureMessage: 'Runner did not advance into a drill prompt.',
      maxTaps: 12,
    );
  }

  Future<void> advanceActionTheoryToCanonicalDecisionV1(
    WidgetTester tester,
  ) async {
    await advanceRunnerUntilV1(
      tester,
      () {
        final runner = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        return runner.selectedLessonId == 'fold_check_call_raise' &&
            runner.selectedTaskId == 'actions_check_drill' &&
            runner.runner.phase == Act0LessonPhaseV1.drill &&
            find
                .byKey(const Key('act0_shell_option_check'))
                .evaluate()
                .isNotEmpty;
      },
      failureMessage: 'Action theory did not reach actions_check_drill.',
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

  Future<void> continueVisibleFeedbackV1(WidgetTester tester) async {
    final cta = find.byKey(const Key('act0_shell_feedback_continue_cta'));
    expect(cta, findsOneWidget);
    await tester.ensureVisible(cta);
    await tester.pumpAndSettle();
    await tester.tap(cta);
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
    await seedActionCapabilityPreconditionV1();
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

  ({Act0LessonCardV1 lesson, Act0LessonTaskV1 task}) taskByIdV1({
    required String worldId,
    required String taskId,
  }) {
    final world = Act0ShellStateV1.sample.worldById(worldId);
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        if (task.taskId == taskId) {
          return (lesson: lesson, task: task);
        }
      }
    }
    fail('Missing $worldId task $taskId');
  }

  Future<void> pumpTelemetryTaskV1({
    required WidgetTester tester,
    required String worldId,
    required String taskId,
    required Act0TelemetrySinkV1 sink,
  }) async {
    final resolved = taskByIdV1(worldId: worldId, taskId: taskId);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0LessonRunnerShellV1(
            runner: resolved.task.runner.copyWith(
              phase: Act0LessonPhaseV1.drill,
              teachingSteps: const <Act0TeachingStepV1>[],
            ),
            selectedWorldId: worldId,
            selectedLessonId: resolved.lesson.lessonId,
            selectedTaskId: resolved.task.taskId,
            selectedTaskFamily: resolved.task.resolvedTaskFamily,
            telemetrySink: sink,
            onBack: () {},
            onContinueTheory: () {},
            onChooseOption: (_) {},
            onContinueReview: () {},
          ),
        ),
      ),
    );
  }

  Future<void> chooseOptionByQualityV1(
    WidgetTester tester,
    Act0FeedbackQualityV1 quality,
  ) async {
    final runnerFinder = find.byType(Act0LessonRunnerShellV1);
    expect(runnerFinder, findsOneWidget);
    final runnerWidget = tester.widget<Act0LessonRunnerShellV1>(runnerFinder);
    final option = runnerWidget.runner.options.firstWhere(
      (candidate) => candidate.quality == quality,
      orElse: () => runnerWidget.runner.options.firstWhere(
        (candidate) => candidate.quality != Act0FeedbackQualityV1.correct,
      ),
    );
    final optionFinder = find.byKey(Key('act0_shell_option_${option.id}'));
    await tester.ensureVisible(optionFinder);
    await tester.pumpAndSettle();
    await tester.tap(optionFinder);
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
      expect(event.fields.containsKey('board_card_ids'), isFalse);
      expect(event.fields.containsKey('tableSignal'), isFalse);
      expect(event.fields.containsKey('missedSignal'), isFalse);
      expect(event.fields.containsKey('tableContextKey'), isFalse);
      expect(event.fields.containsKey('table_context_key'), isFalse);
      expect(event.fields.containsKey('time_to_decision_ms'), isFalse);
      expect(
        jsonEncode(event.fields),
        isNot(contains('w1_action_words_no_bet_read_v1')),
      );
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
      expect(userChoice['chosen_action'], 'raise');
      expect(userChoice['expected_action'], 'raise');
      expect(userChoice['correct'], isTrue);
      expect(userChoice['result_classification'], 'correct');
      expect(userChoice['error_type'], 'none');
      expect(userChoice['route_source_owner'], 'act0_runner');
      expect(userChoice['drill_kind'], 'decision');
      expect(userChoice['attempt_id'], isA<String>());
      expect(userChoice['review_kind'], 'initialAssessment');
      expect(userChoice, isNot(contains('time_to_decision_ms')));
      expect(userChoice['acceptable_action_ids'], <String>['call', 'raise']);
      expect(userChoice['option_quality'], 'correct');
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
        'chosen_action',
        'expected_action',
        'correct',
        'result_classification',
        'error_type',
        'route_source_owner',
        'drill_kind',
        'attempt_id',
        'review_kind',
        'street_v1',
        'acceptable_action_ids',
        'option_quality',
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
            reviewKindId: 'spacedReview',
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
    final userChoice = sink.events.singleWhere(
      (event) => event.name == 'user_choice',
    );
    expect(
      sink.events.where((event) => event.name == 'decision_made'),
      hasLength(1),
    );
    expect(userChoice.fields['correct'], isTrue);
    expect(userChoice.fields['error_type'], 'none');
    expect(userChoice.fields, isNot(contains('time_to_decision_ms')));
    expect(userChoice.fields['review_kind'], 'spacedReview');
    expect(canonicalDecision.fields['world_id'], 'world_1');
    expect(canonicalDecision.fields['lesson_id'], 'fold_check_call_raise');
    expect(canonicalDecision.fields['task_id'], 'actions_raise_drill');
    expect(canonicalDecision.fields['concept_family_id'], 'decision');
    expect(canonicalDecision.fields['selected_action'], 'raise');
    expect(canonicalDecision.fields['correct_action'], 'raise');
    expect(canonicalDecision.fields['is_correct'], isTrue);
    expect(canonicalDecision.fields['error_type'], 'none');
    expect(canonicalDecision.fields['source_surface'], 'act0_runner');
    expect(canonicalDecision.fields['review_kind'], 'spacedReview');
    expect(canonicalDecision.fields, isNot(contains('time_to_decision_ms')));

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
        .firstWhere((candidate) => candidate.taskId == 'actions_legal_context');
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

    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();

    expect(
      sink.events.where((event) => event.name == 'user_choice'),
      hasLength(1),
    );
    expect(
      sink.events.where((event) => event.name == 'decision_made'),
      hasLength(1),
    );
    expect(
      sink.events.where((event) => event.name == 'task_result'),
      hasLength(1),
    );

    final userChoice = sink.events.firstWhere(
      (event) => event.name == 'user_choice',
    );
    expect(userChoice.fields['choiceId'], 'fold');
    expect(userChoice.fields['chosen_action'], 'fold');
    expect(userChoice.fields['expected_action'], 'check');
    expect(userChoice.fields['correct'], isFalse);
    expect(userChoice.fields['result_classification'], 'incorrect');
    expect(userChoice.fields['error_type'], 'misread_action_legality');
    expect(userChoice.fields['repair_family_id'], 'action_legality');
    expect(userChoice.fields['route_source_owner'], 'act0_runner');
    expect(userChoice.fields['drill_kind'], 'decision');
    expect(userChoice.fields['attempt_id'], isA<String>());
    expect(userChoice.fields, isNot(contains('time_to_decision_ms')));
    expect(
      userChoice.fields['decisionTimeBucket'],
      isIn(<Object?>['under_3s', '3_to_10s', 'over_10s', 'unknown']),
    );

    final canonicalDecision = sink.events.firstWhere(
      (event) => event.name == 'decision_made',
    );
    expect(canonicalDecision.fields['selected_action'], 'fold');
    expect(canonicalDecision.fields['expected_action'], 'check');
    expect(canonicalDecision.fields['correct_action'], 'check');
    expect(canonicalDecision.fields['correct'], isFalse);
    expect(canonicalDecision.fields['is_correct'], isFalse);
    expect(canonicalDecision.fields['result'], 'incorrect');
    expect(canonicalDecision.fields['result_classification'], 'incorrect');
    expect(canonicalDecision.fields['error_type'], 'misread_action_legality');
    expect(canonicalDecision.fields['repair_family_id'], 'action_legality');
    expect(
      canonicalDecision.fields['repair_target_task_id'],
      'repeat_action_read',
    );
    expect(
      canonicalDecision.fields['attempt_id'],
      userChoice.fields['attempt_id'],
    );
    expect(
      canonicalDecision.fields['decisionTimeBucket'],
      isIn(<Object?>['under_3s', '3_to_10s', 'over_10s', 'unknown']),
    );
    expect(canonicalDecision.fields, isNot(contains('time_to_decision_ms')));

    final result = sink.events.firstWhere(
      (event) => event.name == 'task_result',
    );
    expect(result.fields['choiceId'], 'fold');
    expect(result.fields['result'], 'incorrect');
    expect(result.fields['errorType'], 'misread_action_legality');
    expect(result.fields['error_type'], 'misread_action_legality');
    expect(result.fields['repairFamilyId'], 'action_legality');
    expect(result.fields['repair_family_id'], 'action_legality');

    expectNoForbiddenTelemetryFieldsV1(sink.events);
  });

  testWidgets(
    'W5 structured board context is attributed to decision telemetry',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await pumpTelemetryTaskV1(
        tester: tester,
        worldId: 'world_5',
        taskId: 'board_texture_basics_w5_dry_board',
        sink: sink,
      );

      await tester.tap(find.byKey(const Key('act0_shell_option_wet')));
      await tester.pumpAndSettle();

      final userChoice = sink.events.firstWhere(
        (event) => event.name == 'user_choice',
      );
      expect(userChoice.fields['worldId'], 'world_5');
      expect(userChoice.fields['taskId'], 'board_texture_basics_w5_dry_board');
      expect(userChoice.fields, isNot(contains('board_card_ids')));
      expect(userChoice.fields['street_v1'], 'Flop');

      final canonicalDecision = sink.events.firstWhere(
        (event) => event.name == 'decision_made',
      );
      expect(canonicalDecision.fields, isNot(contains('board_card_ids')));
      expect(canonicalDecision.fields['street_v1'], 'Flop');

      expectNoForbiddenTelemetryFieldsV1(sink.events);
    },
  );

  testWidgets(
    'representative W1 W3 W4 W5 W6 paths emit attributed decision telemetry',
    (tester) async {
      final cases = <({String worldId, String taskId})>[
        (worldId: 'world_1', taskId: 'actions_legal_context'),
        (worldId: 'world_3', taskId: 'button_advantage_button_open'),
        (worldId: 'world_4', taskId: 'w4_good_price_call'),
        (worldId: 'world_5', taskId: 'board_texture_basics_w5_dry_board'),
        (worldId: 'world_6', taskId: 'w6_missed_dry_board'),
      ];

      for (final path in cases) {
        final sink = Act0InMemoryTelemetrySinkV1();
        await pumpTelemetryTaskV1(
          tester: tester,
          worldId: path.worldId,
          taskId: path.taskId,
          sink: sink,
        );
        await chooseOptionByQualityV1(tester, Act0FeedbackQualityV1.wrong);

        final userChoices = sink.events
            .where((event) => event.name == 'user_choice')
            .toList(growable: false);
        expect(userChoices, hasLength(1), reason: path.taskId);
        final userChoice = userChoices.single.fields;
        expect(userChoice['worldId'], path.worldId, reason: path.taskId);
        expect(userChoice['taskId'], path.taskId, reason: path.taskId);
        expect(userChoice['chosen_action'], isA<String>(), reason: path.taskId);
        expect(
          userChoice['expected_action'],
          isA<String>(),
          reason: path.taskId,
        );
        expect(userChoice['correct'], isFalse, reason: path.taskId);
        expect(
          userChoice['result_classification'],
          isIn(<String>['incorrect', 'suboptimal']),
          reason: path.taskId,
        );
        expect(userChoice['error_type'], isA<String>(), reason: path.taskId);
        expect(userChoice['error_type'], isNot('unknown'), reason: path.taskId);
        expect(
          userChoice['repair_family_id'],
          isA<String>(),
          reason: path.taskId,
        );
        expect(userChoice['attempt_id'], isA<String>(), reason: path.taskId);
        expect(
          userChoice,
          isNot(contains('time_to_decision_ms')),
          reason: path.taskId,
        );

        final canonicalDecisions = sink.events
            .where((event) => event.name == 'decision_made')
            .toList(growable: false);
        expect(canonicalDecisions, hasLength(1), reason: path.taskId);
        expect(
          canonicalDecisions.single.fields['attempt_id'],
          userChoice['attempt_id'],
          reason: path.taskId,
        );
      }
    },
  );

  testWidgets(
    'Act0 runner emits one safe feedback_viewed event from the real feedback path',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await startActionsTheoryFromLearnV1(tester, telemetrySink: sink);
      await advanceActionTheoryToCanonicalDecisionV1(tester);
      expect(
        tester
            .widget<Act0LessonRunnerShellV1>(
              find.byType(Act0LessonRunnerShellV1),
            )
            .selectedTaskId,
        'actions_check_drill',
      );
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
      expect(feedbackViewed['taskId'], 'actions_check_drill');
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
      final sessionStart = sink.events.firstWhere(
        (event) => event.name == 'session_start',
      );
      final decisionMade = sink.events.lastWhere(
        (event) => event.name == 'decision_made',
      );
      expect(sessionStart.fields['session_id'], isNot(isEmpty));
      expect(
        repairAttemptedEvents.single.fields['session_id'],
        sessionStart.fields['session_id'],
      );
      expect(
        decisionMade.fields['session_id'],
        sessionStart.fields['session_id'],
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
      expect(
        fixLandedEvents.single.fields['session_id'],
        sessionStart.fields['session_id'],
      );

      final repairItemEvents = sink.events
          .where((event) => event.name == 'repair_item_completed')
          .toList(growable: false);
      expect(repairItemEvents, hasLength(1));
      expect(sink.events.last.name, 'personalized_next_step_selected');

      final nextStep = sink.events.last.fields;
      expect(nextStep['surface'], 'review');
      expect(nextStep['reason_type'], isA<String>());
      expect(nextStep['evidence_kind'], isA<String>());
      expect(nextStep['priority_class'], isA<int>());
      expect(nextStep.keys, isNot(contains('conceptFamilyId')));
      expect(nextStep.keys, isNot(contains('sourceTaskId')));

      final repairItem = repairItemEvents.single.fields;
      expect(repairItem['schemaVersion'], 1);
      expect(repairItem['sourceTaskId'], repairStart['sourceTaskId']);
      expect(repairItem['targetTaskId'], repairStart['repairTaskId']);
      expect(repairItem['outcome'], 'repaired');
      expect(repairItem['correct'], isTrue);
      expect(repairItem, isNot(contains('missedSignal')));
      expect(repairItem, isNot(contains('skillAtomId')));

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
    expect(sessionStart.fields['session_id'], isNot(isEmpty));

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
      final sessionStartEvents = sink.events
          .where((event) => event.name == 'session_start')
          .toList(growable: false);
      final sessionCompleteEvents = sink.events
          .where((event) => event.name == 'session_complete')
          .toList(growable: false);
      expect(sessionStartEvents, hasLength(1));
      expect(sessionCompleteEvents, hasLength(1));
      expect(sessionComplete.fields['source_surface'], 'act0_practice');
      expect(sessionComplete.fields['practice_group_id'], 'daily');
      expect(sessionComplete.fields['completed_rep_count'], 3);
      expect(
        sessionComplete.fields['session_id'],
        sessionStartEvents.single.fields['session_id'],
      );

      expectNoForbiddenTelemetryFieldsV1(sink.events);
    },
  );

  testWidgets('Act0 render alone does not create a session id', (tester) async {
    final sink = Act0InMemoryTelemetrySinkV1();

    await tester.pumpWidget(previewHost(telemetrySink: sink));
    await tester.pumpAndSettle();

    expect(
      sink.events.where((event) => event.name == 'session_start'),
      isEmpty,
    );
    expect(
      sink.events.any((event) => event.fields.containsKey('session_id')),
      isFalse,
    );
  });

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

    final worldCompleteEvents = worldSink.events
        .where((event) => event.name == 'world_complete')
        .toList(growable: false);
    expect(worldCompleteEvents, hasLength(1));
    final worldComplete = worldCompleteEvents.single;
    expect(worldComplete.fields['world_id'], 'world_1');
    expect(worldComplete.fields['source_surface'], 'act0_completion');

    await tester.ensureVisible(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    await tester.pumpAndSettle();

    expect(
      worldSink.events.where((event) => event.name == 'world_complete'),
      hasLength(1),
    );

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
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await startActionsTheoryFromLearnV1(
      tester,
      telemetrySink: _ThrowingTelemetrySinkV1(),
    );
    await advanceActionTheoryToCanonicalDecisionV1(tester);
    await answerVisiblePromptCorrectlyV1(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_feedback_card')), findsOneWidget);
  });

  testWidgets(
    'Action sequence surfaces a traceable deterministic recommendation',
    (tester) async {
      final sink = Act0InMemoryTelemetrySinkV1();
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            state: Act0ShellStateV1.sample,
            showPlacementOnStart: false,
            telemetrySink: sink,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_check_drill',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await answerVisiblePromptWronglyV1(tester);
      expect(
        find.byKey(const Key('act0_action_recommendation_surface')),
        findsOneWidget,
      );
      expect(find.textContaining('not stable yet'), findsOneWidget);

      final generated = sink.events.lastWhere(
        (event) => event.name == 'recommendation_generated',
      );
      expect(generated.fields['sequence_id'], 'w1_action_words_check_v1');
      expect(generated.fields['error_type'], 'misread_action_legality');
      expect(generated.fields['recommendation_reason'], 'recentError');
      expect(generated.fields['source_attempt_key'], isA<String>());

      final payoff = sink.events.lastWhere(
        (event) => event.name == 'action_payoff_generated',
      );
      expect(payoff.fields['payoff_type'], 'unresolvedSkill');
      expect(payoff.fields['proof_source'], 'sequence_outcomes');
      expect(payoff.fields['primary_action'], 'Repair now');

      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await answerVisiblePromptCorrectlyV1(tester);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      await answerVisiblePromptCorrectlyV1(tester);

      final recoveredPayoff = sink.events.lastWhere(
        (event) => event.name == 'action_payoff_generated',
      );
      expect(recoveredPayoff.fields['payoff_type'], 'recoveredSuccess');
      expect(
        sink.events.where((event) => event.name == 'recommendation_accepted'),
        isNotEmpty,
      );
      expect(
        sink.events.where(
          (event) => event.name == 'action_payoff_primary_action_selected',
        ),
        isNotEmpty,
      );
      expectNoForbiddenTelemetryFieldsV1(sink.events);
    },
  );

  testWidgets(
    'unlocked Action capability journey completes the alpha loop with ordered safe telemetry',
    (tester) async {
      final store = _MemoryHnpTraceFileStoreV1();
      final sink = Act0HnpTelemetrySinkV1(fileStore: store);
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await startActionsTheoryFromLearnV1(tester, telemetrySink: sink);
      await advanceActionTheoryToCanonicalDecisionV1(tester);

      expect(
        sink.events.where(
          (event) =>
              event.name == 'task_shown' &&
              event.fields['taskId'] == 'actions_check_drill',
        ),
        isNotEmpty,
      );

      await answerVisiblePromptWronglyV1(tester);
      await continueVisibleFeedbackV1(tester);
      await answerVisiblePromptCorrectlyV1(tester);
      await continueVisibleFeedbackV1(tester);
      await answerVisiblePromptCorrectlyV1(tester);
      await continueVisibleFeedbackV1(tester);
      await tester.pumpAndSettle();

      final recoveredPayoff = sink.events.lastWhere(
        (event) => event.name == 'action_payoff_generated',
      );
      expect(recoveredPayoff.fields['payoff_type'], 'recoveredSuccess');

      final names = sink.events.map((event) => event.name).toList();
      int positionOf(String name) => names.indexOf(name);
      expect(positionOf('lesson_started'), greaterThanOrEqualTo(0));
      expect(
        positionOf('theory_completed'),
        greaterThan(positionOf('lesson_started')),
      );
      expect(
        positionOf('user_choice'),
        greaterThan(positionOf('theory_completed')),
      );
      expect(
        positionOf('feedback_viewed'),
        greaterThan(positionOf('user_choice')),
      );
      expect(
        positionOf('repair_started'),
        greaterThan(positionOf('feedback_viewed')),
      );
      expect(
        positionOf('repair_completed'),
        greaterThan(positionOf('repair_started')),
      );
      expect(
        positionOf('recheck_started'),
        greaterThan(positionOf('repair_completed')),
      );
      expect(
        positionOf('recheck_result'),
        greaterThan(positionOf('recheck_started')),
      );
      expect(
        positionOf('action_sequence_completed'),
        greaterThan(positionOf('recheck_result')),
      );

      expect(
        sink.events.where((event) => event.name == 'theory_completed'),
        hasLength(1),
      );
      expect(
        sink.events.where((event) => event.name == 'repair_started'),
        hasLength(1),
      );
      expect(
        sink.events.where((event) => event.name == 'repair_completed'),
        hasLength(1),
      );
      final recheck = sink.events.lastWhere(
        (event) => event.name == 'recheck_result',
      );
      expect(recheck.fields['result'], 'correct');
      expect(recheck.fields['sequence_id'], 'w1_action_words_check_v1');

      await tester.tap(find.byKey(const Key('act0_shell_runner_back')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('act0_shell_learn_screen')), findsOneWidget);
      expect(
        sink.events.where((event) => event.name == 'session_exited'),
        hasLength(1),
      );
      final actionErrorEvents = sink.events.where((event) {
        final errorType = event.fields['error_type'];
        return errorType is String &&
            errorType.isNotEmpty &&
            errorType != 'none';
      });
      expect(actionErrorEvents, isNotEmpty);
      expect(
        actionErrorEvents.every(
          (event) => event.fields['error_type'] == 'misread_action_legality',
        ),
        isTrue,
      );
      expect(
        sink.events.any(
          (event) => event.fields['error_type'] == 'missed_action_read',
        ),
        isFalse,
      );
      expectNoForbiddenTelemetryFieldsV1(sink.events);
      await sink.flushExport();
      final physicalEvents = store.contents
          .trimRight()
          .split('\n')
          .map((line) => jsonDecode(line) as Map<String, dynamic>)
          .toList(growable: false);
      expect(physicalEvents, hasLength(sink.events.length));
      expect(
        physicalEvents.map((event) => event['name']),
        containsAll(<String>[
          'user_choice',
          'task_result',
          'repair_started',
          'repair_completed',
          'recheck_started',
          'recheck_result',
          'action_payoff_generated',
          'session_exited',
        ]),
      );
      for (final event in physicalEvents) {
        final fields = event['fields'] as Map<String, dynamic>;
        expect(fields, isNot(contains('tableContextKey')));
        expect(fields, isNot(contains('table_context_key')));
        expect(
          jsonEncode(fields),
          isNot(contains('w1_action_words_no_bet_read_v1')),
        );
      }
      final physicalChoice =
          physicalEvents.firstWhere(
                (event) => event['name'] == 'user_choice',
              )['fields']
              as Map<String, dynamic>;
      final physicalResult =
          physicalEvents.firstWhere(
                (event) => event['name'] == 'task_result',
              )['fields']
              as Map<String, dynamic>;
      expect(physicalChoice['choiceId'], 'fold');
      expect(physicalChoice['decisionTimeBucket'], isA<String>());
      expect(physicalResult['errorType'], 'misread_action_legality');
      _writeActionHnpPhysicalTraceV1(store.contents);
      _writeAlphaQaTraceV1(sink.events);
    },
  );

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
