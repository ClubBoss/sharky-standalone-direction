import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _oldSeed = Act0AchievementSeedConsumerV1(
  moments: [
    Act0AchievementMomentViewModelV1(
      seedId: act0AchievementSeedFirstCorrectReadV1,
      label: 'First correct read',
    ),
  ],
);

const _sourceHandoff = Act0SummaryNextHandoffV1(
  sourceTaskId: 'what_poker_is_find_hero',
  targetWorldId: 'world_1',
  targetLessonId: 'what_poker_is',
  targetTaskId: 'what_poker_is_find_hero',
  reasonCode: 'exact_replay_hero_identity',
  selectionSource: 'repair_intent_exact_replay',
  copyLine: 'Repeat the same hero clue before your next decision.',
);

const _cleanSummary = Act0BlockCompletionSummaryV1(
  lessonTitle: 'First table',
  xpEarned: 12,
  errorCount: 0,
  assistedCount: 0,
  independentProvenanceKnown: true,
  taskCount: 2,
  correctCount: 2,
  startLevel: 1,
  endLevel: 1,
  startXp: 10,
  endXp: 22,
  xpTarget: 100,
  nextLessonTitle: 'Next lesson',
);

const _assistedSummary = Act0BlockCompletionSummaryV1(
  lessonTitle: 'First table',
  xpEarned: 0,
  errorCount: 1,
  assistedCount: 1,
  independentProvenanceKnown: true,
  taskCount: 2,
  correctCount: 1,
  startLevel: 1,
  endLevel: 1,
  startXp: 10,
  endXp: 10,
  xpTarget: 100,
  nextLessonTitle: 'Next lesson',
);

Future<void> _pump(
  WidgetTester tester, {
  required Act0BlockCompletionSummaryV1 summary,
  required bool earnedNow,
  bool ru = false,
  Act0SummaryNextHandoffV1? next,
  VoidCallback? onNext,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(ru ? 'ru' : 'en'),
      supportedLocales: const [Locale('en'), Locale('ru')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: Act0BlockCompletionShellV1(
          summary: summary,
          firstCorrectEarnedThisRun: earnedNow,
          earnedMomentConsumer: _oldSeed,
          nextUsefulHand: next,
          onNextUsefulHand: onNext,
          onContinue: () {},
          onReplay: () {},
          onOpenReview: () {},
          onBackToMap: () {},
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 2200));
}

Future<void> _completeAssistedThenIndependentLesson(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final lesson = Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .firstWhere((item) => item.lessonId == 'fold_check_call_raise');
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  final hint = find.byKey(const Key('act0_shell_theory_recall_cta'));
  for (var i = 0; i < 12 && hint.evaluate().isEmpty; i++) {
    final next = find.byKey(const Key('act0_shell_continue_cta'));
    expect(next, findsOneWidget);
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  expect(hint, findsOneWidget);
  await tester.ensureVisible(hint);
  await tester.tap(hint);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('act0_shell_theory_recall_close_cta')));
  await tester.pumpAndSettle();

  for (final taskId in [
    'actions_legal_context',
    'actions_check_drill',
    'actions_fold_drill',
    'actions_call_drill',
    'actions_raise_drill',
    'actions_review',
  ]) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, taskId);
    if (taskId == 'actions_review') {
      final continueReview = find.byKey(
        const Key('act0_shell_feedback_continue_cta'),
      );
      expect(continueReview, findsOneWidget);
      await tester.tap(continueReview);
      await tester.pumpAndSettle();
      continue;
    }
    final task = lesson.taskList.firstWhere((item) => item.taskId == taskId);
    final answer = task.runner.options.firstWhere((option) => option.isCorrect);
    final option = find.byKey(Key('act0_shell_option_${answer.id}'));
    final seat = find.byKey(Key('act0_shell_seat_tap_${answer.seatId}'));
    for (
      var i = 0;
      i < 12 && option.evaluate().isEmpty && seat.evaluate().isEmpty;
      i++
    ) {
      final next =
          find
              .byKey(const Key('act0_shell_theory_continue_cta'))
              .evaluate()
              .isNotEmpty
          ? find.byKey(const Key('act0_shell_theory_continue_cta'))
          : find.byKey(const Key('act0_shell_continue_cta'));
      expect(
        next,
        findsOneWidget,
        reason:
            'task=$taskId, option=${answer.id}, phase=${runner.runner.phase}, visible=${tester.widgetList<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1)).length}',
      );
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    if (seat.evaluate().isNotEmpty) {
      await tester.tap(seat);
    } else {
      expect(option, findsOneWidget);
      await tester.tap(option);
    }
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
  }
  expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
}

Map<String, dynamic> _persistedLearningSnapshotV1(SharedPreferences prefs) =>
    jsonDecode(prefs.getString('act0_shell_progress_v1')!)
        as Map<String, dynamic>;

Future<void> _pumpPersistedW1Learner(WidgetTester tester) async {
  final firstLesson = Act0ShellStateV1.sample
      .worldById('world_1')
      .lessons
      .firstWhere((lesson) => lesson.lessonId == 'what_poker_is');
  const sourceTaskId = 'what_poker_is_find_hero';
  SharedPreferences.setMockInitialValues(<String, Object>{
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    'act0_shell_progress_v1': jsonEncode(<String, Object?>{
      'schemaVersion': 18,
      'completedTaskIds': [
        for (final task in firstLesson.taskList.takeWhile(
          (task) => task.taskId != sourceTaskId,
        ))
          task.taskId,
      ],
      'completedLessonIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': 'what_poker_is',
      'selectedTaskId': sourceTaskId,
      'earnedXp': 17,
    }),
  });
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.play,
        initialPhase: Act0LessonPhaseV1.drill,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  final root = tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
  expect(root.debugSelectedTaskIdV1(), sourceTaskId);
}

Future<void> _answerCurrentRunnerV1(
  WidgetTester tester, {
  required bool correct,
}) async {
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  final choice = runner.runner.options.firstWhere(
    (option) => option.isCorrect == correct,
  );
  final option = find.byKey(Key('act0_shell_option_${choice.id}'));
  final seat = find.byKey(Key('act0_shell_seat_tap_${choice.seatId}'));
  for (
    var i = 0;
    i < 20 && option.evaluate().isEmpty && seat.evaluate().isEmpty;
    i++
  ) {
    final next =
        find
            .byKey(const Key('act0_shell_theory_continue_cta'))
            .evaluate()
            .isNotEmpty
        ? find.byKey(const Key('act0_shell_theory_continue_cta'))
        : find.byKey(const Key('act0_shell_continue_cta'));
    expect(
      next,
      findsOneWidget,
      reason: 'Missing forward route for ${runner.selectedTaskId}',
    );
    await tester.tap(next);
    await tester.pumpAndSettle();
  }
  expect(option.evaluate().isNotEmpty || seat.evaluate().isNotEmpty, isTrue);
  await tester.tap(seat.evaluate().isNotEmpty ? seat : option);
  await tester.pumpAndSettle();
}

Future<void> _triggerHomeRepairV1(WidgetTester tester) async {
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
  final homeTab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Home'),
  );
  await tester.ensureVisible(homeTab);
  await tester.tap(homeTab);
  await tester.pumpAndSettle();
  final home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
  home.onStartRepair!();
  await tester.pumpAndSettle();
}

Future<void> _restartPersistedRootV1(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'persisted locked W3 directed repair does not grant curriculum or XP',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await _pumpPersistedW1Learner(tester);
      await _answerCurrentRunnerV1(tester, correct: false);
      final root =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final receipt =
          root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      const targetTask = 'position_checkpoint_position_checkpoint_table_notice';
      expect(receipt['sourceTaskId'], 'what_poker_is_find_hero');
      expect(receipt['targetWorldId'], 'world_3');
      expect(receipt['targetTaskId'], targetTask);
      final prefs = await SharedPreferences.getInstance();
      final before = _persistedLearningSnapshotV1(prefs);
      await _triggerHomeRepairV1(tester);
      expect(root.debugSelectedWorldIdV1(), 'world_3');
      expect(root.debugSelectedTaskIdV1(), targetTask);
      expect(
        root.debugActiveRepairContextPayloadV1()['sourceTaskId'],
        'what_poker_is_find_hero',
      );
      await _answerCurrentRunnerV1(tester, correct: true);
      await tester.tap(
        find.byKey(const Key('act0_shell_feedback_continue_cta')),
      );
      await tester.pumpAndSettle();
      final after = _persistedLearningSnapshotV1(prefs);
      final beforeCompleted = (before['completedTaskIds'] as List)
          .cast<String>();
      final completed = (after['completedTaskIds'] as List).cast<String>();
      expect(completed, orderedEquals(beforeCompleted));
      expect(completed, isNot(contains(targetTask)));
      expect(
        (after['completedLessonIds'] as List),
        isNot(contains(receipt['targetLessonId'])),
      );
      expect(after['earnedXp'], before['earnedXp']);
      expect(after['openRepairIntents'], isEmpty);
      final evidence = (after['learningEvidenceHistory'] as List)
          .cast<Map<String, dynamic>>();
      expect(
        evidence.any(
          (entry) =>
              entry['taskId'] == targetTask &&
              entry['isCorrect'] == true &&
              entry['assistanceKind'] == 'none',
        ),
        isTrue,
      );
      expect(root.debugOpenRepairIntentCountV1(), 0);
      await _restartPersistedRootV1(tester);
      final restored = _persistedLearningSnapshotV1(prefs);
      expect(restored['completedTaskIds'], orderedEquals(beforeCompleted));
      expect(
        (restored['completedLessonIds'] as List),
        isNot(contains(receipt['targetLessonId'])),
      );
      expect(restored['earnedXp'], before['earnedXp']);
      expect(restored['openRepairIntents'], isEmpty);
      expect(
        (restored['learningEvidenceHistory'] as List)
            .cast<Map<String, dynamic>>()
            .any(
              (entry) =>
                  entry['taskId'] == targetTask &&
                  entry['isCorrect'] == true &&
                  entry['assistanceKind'] == 'none',
            ),
        isTrue,
      );
    },
  );

  testWidgets('ordinarily available W1 task still earns curriculum and XP', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await _pumpPersistedW1Learner(tester);
    final prefs = await SharedPreferences.getInstance();
    final before = _persistedLearningSnapshotV1(prefs);
    const taskId = 'what_poker_is_find_hero';
    final task = Act0ShellStateV1.sample
        .worldById('world_1')
        .lessons
        .firstWhere((lesson) => lesson.lessonId == 'what_poker_is')
        .taskList
        .firstWhere((task) => task.taskId == taskId);
    await _answerCurrentRunnerV1(tester, correct: true);
    await tester.tap(find.byKey(const Key('act0_shell_feedback_continue_cta')));
    await tester.pumpAndSettle();
    final after = _persistedLearningSnapshotV1(prefs);
    expect((after['completedTaskIds'] as List), contains(taskId));
    expect(after['earnedXp'], (before['earnedXp'] as int) + task.rewardXp);
    await _restartPersistedRootV1(tester);
    final restored = _persistedLearningSnapshotV1(prefs);
    expect((restored['completedTaskIds'] as List), contains(taskId));
    expect(restored['earnedXp'], (before['earnedXp'] as int) + task.rewardXp);
  });

  for (final withWorld3 in [true, false]) {
    testWidgets('W1 mapped repair route (W3 present: $withWorld3)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final sample = Act0ShellStateV1.sample;
      final w1 = sample.worldById('world_1');
      final state = withWorld3
          ? sample
          : Act0ShellStateV1(
              courseTitle: sample.courseTitle,
              courseSubtitle: sample.courseSubtitle,
              levelLabel: sample.levelLabel,
              xp: sample.xp,
              xpTarget: sample.xpTarget,
              streakDays: sample.streakDays,
              dailyGoalLabel: sample.dailyGoalLabel,
              dailyGoalValue: sample.dailyGoalValue,
              pathProgressLabel: sample.pathProgressLabel,
              selectedWorldId: 'world_1',
              worlds: [w1],
              lessons: w1.lessons,
              review: sample.review,
              profile: sample.profile,
            );
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: state,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'what_poker_is',
              taskId: 'what_poker_is_find_hero',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, 'what_poker_is_find_hero');
      final wrong = runner.runner.options.firstWhere((o) => !o.isCorrect);
      final option = find.byKey(Key('act0_shell_option_${wrong.id}'));
      final seat = find.byKey(Key('act0_shell_seat_tap_${wrong.seatId}'));
      for (
        var step = 0;
        step < 12 && option.evaluate().isEmpty && seat.evaluate().isEmpty;
        step++
      ) {
        final next = find.byKey(const Key('act0_shell_continue_cta'));
        expect(next, findsOneWidget);
        await tester.tap(next);
        await tester.pumpAndSettle();
      }
      await tester.tap(seat.evaluate().isNotEmpty ? seat : option);
      await tester.pumpAndSettle();
      final root =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final summary =
          root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      final home =
          root.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>;
      final worldId = withWorld3 ? 'world_3' : 'world_1';
      final taskId = withWorld3
          ? 'position_checkpoint_position_checkpoint_table_notice'
          : 'what_poker_is_find_hero';
      expect(home['sourceTaskId'], 'what_poker_is_find_hero');
      expect(home['targetWorldId'], worldId);
      expect(home['targetTaskId'], taskId);
      for (final key in [
        'sourceTaskId',
        'targetWorldId',
        'targetLessonId',
        'targetTaskId',
        'reasonCode',
        'selectionSource',
      ]) {
        expect(summary[key], home[key], reason: 'Handoff differs at $key');
      }
      expect(
        summary['selectionSource'],
        withWorld3 ? 'repair_intent_mapped' : 'repair_intent_exact_replay',
      );
      final back = find.byKey(const Key('act0_shell_runner_back'));
      if (back.evaluate().isNotEmpty) {
        await tester.tap(back);
        await tester.pumpAndSettle();
      }
      final homeTab = find.descendant(
        of: find.byKey(const Key('act0_shell_bottom_nav')),
        matching: find.text('Home'),
      );
      await tester.ensureVisible(homeTab);
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
      final shell = tester.widget<Act0HomeShellV1>(
        find.byType(Act0HomeShellV1),
      );
      shell.onStartRepair!();
      await tester.pumpAndSettle();
      expect(root.debugSelectedWorldIdV1(), worldId);
      expect(root.debugSelectedLessonIdV1(), summary['targetLessonId']);
      expect(root.debugSelectedTaskIdV1(), taskId);
      expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
      if (withWorld3) expect(sample.worldById('world_3').isLocked, isTrue);
    });
  }
  testWidgets(
    'root shares the exact Home source task, target and reason with Summary',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final sample = Act0ShellStateV1.sample;
      final baseWorld = sample.worldById('world_1');
      final baseLesson = baseWorld.lessons.firstWhere(
        (lesson) => lesson.lessonId == 'fold_check_call_raise',
      );
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: [
          baseLesson.taskList.firstWhere(
            (task) => task.taskId == 'actions_legal_context',
          ),
          baseLesson.taskList.firstWhere(
            (task) => task.taskId == 'actions_check_drill',
          ),
        ],
      );
      final world = baseWorld.copyWith(
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
        selectedWorldId: 'world_1',
        worlds: [world],
        lessons: [lesson],
        review: sample.review,
        profile: sample.profile,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: state,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_legal_context',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      final shell =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final home =
          shell.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>;
      final summary =
          shell.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      expect(summary['sourceTaskId'], home['sourceTaskId']);
      expect(summary['targetTaskId'], home['targetTaskId']);
      expect(summary['targetLessonId'], home['targetLessonId']);
      expect(summary['targetWorldId'], home['targetWorldId']);
      expect(summary['reasonCode'], home['reasonCode']);
      expect(summary['selectionSource'], home['selectionSource']);
      expect(summary['copyLine'], shell.debugHomeNextUsefulHandReasonLineV1());
      expect(summary['sourceTaskId'], 'actions_legal_context');
      expect(summary['targetTaskId'], 'actions_check_drill');
    },
  );

  for (final historyOwner in [
    'none',
    'same_lesson_prior_run',
    'other_lesson',
  ]) {
    testWidgets(
      'production root selects first independent current lesson proof; '
      'historical=$historyOwner',
      (tester) async {
        final historicallyEarned = historyOwner != 'none';
        final world = Act0ShellStateV1.sample.worldById('world_1');
        const lessonId = 'fold_check_call_raise';
        SharedPreferences.setMockInitialValues(<String, Object>{
          'act0_welcome_completed_v1': true,
          'intake_completed_v1': true,
          'act0_shell_progress_v1': jsonEncode(<String, Object?>{
            'schemaVersion': 17,
            'completedTaskIds': <String>[
              for (final lesson in world.lessons.takeWhile(
                (item) => item.lessonId != lessonId,
              ))
                for (final task in lesson.taskList) task.taskId,
              'actions_theory',
            ],
            'completedLessonIds': <String>[
              for (final lesson in world.lessons.takeWhile(
                (item) => item.lessonId != lessonId,
              ))
                lesson.lessonId,
            ],
            'selectedWorldId': 'world_1',
            'selectedLessonId': lessonId,
            'selectedTaskId': 'actions_legal_context',
            'learningEvidenceHistory': <Object>[
              if (historicallyEarned)
                <String, Object?>{
                  'schemaVersion': 1,
                  'recordId': 'previous_lesson_run|1',
                  'createdOrder': 1,
                  'worldId': 'world_1',
                  'lessonId': historyOwner == 'same_lesson_prior_run'
                      ? lessonId
                      : 'what_poker_is',
                  'taskId': historyOwner == 'same_lesson_prior_run'
                      ? 'actions_call_drill'
                      : 'what_poker_is_find_hero',
                  'choiceId': 'call',
                  'expectedChoiceId': 'call',
                  'isCorrect': true,
                  'errorType': 'none',
                  'skillAtomId': 'table_read',
                  'decisionTimeBucket': '3_to_10s',
                  'resultKind': 'correct',
                  'assistanceKind': 'none',
                },
            ],
            'lessonRunEvidenceBoundaries': <String, Object?>{
              lessonId: historicallyEarned ? 1 : 0,
            },
            'lessonRunEvidenceLessonId': lessonId,
            'lessonRunEvidenceStartOrder': historicallyEarned ? 1 : 0,
          }),
        });
        await _completeAssistedThenIndependentLesson(tester);
        final preferences = await SharedPreferences.getInstance();
        final progress =
            jsonDecode(preferences.getString('act0_shell_progress_v1')!)
                as Map<String, dynamic>;
        final history = (progress['learningEvidenceHistory'] as List)
            .cast<Map<String, dynamic>>();
        final current = history
            .where(
              (record) =>
                  record['taskId'] == 'actions_legal_context' ||
                  record['taskId'] == 'actions_check_drill',
            )
            .toList();
        expect(current.map((record) => record['assistanceKind']).toList(), [
          'quickHint',
          'none',
        ]);
        expect(current.every((record) => record['isCorrect'] == true), isTrue);
        expect(current[0]['createdOrder'], historicallyEarned ? 2 : 1);
        expect(current[1]['createdOrder'], historicallyEarned ? 3 : 2);
        final summary = tester.widget<Act0BlockCompletionShellV1>(
          find.byType(Act0BlockCompletionShellV1),
        );
        expect(summary.firstCorrectEarnedThisRun, !historicallyEarned);
        expect(
          find.text('Collected read'),
          historicallyEarned ? findsNothing : findsOneWidget,
        );
        expect(
          find.text('Saved earlier'),
          historicallyEarned ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
          historicallyEarned ? findsNothing : findsOneWidget,
        );
      },
    );
  }

  testWidgets('old saved first read is not presented as freshly earned', (
    tester,
  ) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: false);
    expect(
      find.byKey(const Key('act0_shell_block_summary_earned_moment')),
      findsOneWidget,
    );
    expect(find.text('Saved earlier'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
      findsNothing,
    );
  });

  testWidgets('current independently earned first read retains source payoff', (
    tester,
  ) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: true);
    expect(find.text('Collected read'), findsOneWidget);
    expect(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
      findsOneWidget,
    );
  });

  testWidgets('RU assisted result keeps original wrong and separate help', (
    tester,
  ) async {
    await _pump(tester, summary: _assistedSummary, earnedNow: false, ru: true);
    final outcome = find.byKey(const Key('act0_b2_summary_ru_assessed_truth'));
    expect(outcome, findsOneWidget);
    final line = tester.widget<Text>(outcome).data!;
    expect(
      line,
      contains(
        '\u043d\u0435 \u0434\u043e\u043a\u0430\u0437\u044b\u0432\u0430\u0435\u0442 \u0441\u0430\u043c\u043e\u0441\u0442\u043e\u044f\u0442\u0435\u043b\u044c\u043d\u043e\u0435 \u0440\u0435\u0448\u0435\u043d\u0438\u0435',
      ),
    );
    expect(
      find.text(
        '\u0421\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u043e \u0440\u0430\u043d\u0435\u0435',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('act0_shell_session_summary_hero_payoff')),
      findsNothing,
    );
    expect(find.text('1 with help'), findsNothing);
    final title = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_habit_reward_label')),
        )
        .data!;
    expect(
      title,
      '\u0427\u0442\u043e \u0442\u0440\u0435\u043d\u0438\u0440\u043e\u0432\u0430\u043b\u0438',
    );
    final detail = tester
        .widget<Text>(
          find.byKey(const Key('act0_shell_block_summary_habit_reward_detail')),
        )
        .data!;
    expect(detail, contains('\u041e\u0448\u0438\u0431\u043a'));
    expect(detail, isNot(contains('This read will help')));
  });

  testWidgets('RU primary and secondary Summary CTA labels are native', (
    tester,
  ) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: true, ru: true);
    expect(find.text('Replay for perfect'), findsNothing);
    expect(find.text('Back to map'), findsNothing);
    expect(find.text('What improved'), findsNothing);
    if (_cleanSummary.secondaryCtaLabel != null) {
      expect(find.text('Replay for perfect'), findsNothing);
    }
    expect(
      find.text(
        '\u041a \u043a\u0430\u0440\u0442\u0435 \u0443\u0440\u043e\u043a\u043e\u0432',
      ),
      findsOneWidget,
    );
  });

  testWidgets('RU unknown independent evidence never invents a clean result', (
    tester,
  ) async {
    const uncertain = Act0BlockCompletionSummaryV1(
      lessonTitle: 'First table',
      xpEarned: 0,
      errorCount: 0,
      assistedCount: 1,
      independentProvenanceKnown: false,
      taskCount: 2,
      correctCount: 2,
      startLevel: 1,
      endLevel: 1,
      startXp: 0,
      endXp: 0,
      xpTarget: 100,
    );
    await _pump(tester, summary: uncertain, earnedNow: false, ru: true);
    final line = tester
        .widget<Text>(
          find.byKey(const Key('act0_b2_summary_ru_assessed_truth')),
        )
        .data!;
    expect(
      line,
      contains(
        '\u043d\u0435 \u043f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0451\u043d',
      ),
    );
    expect(
      line,
      isNot(
        contains(
          '\u0432\u0435\u0440\u043d\u043e \u0441 \u043f\u0435\u0440\u0432\u043e\u0439',
        ),
      ),
    );
  });

  testWidgets('source task, target and reason survive Summary CTA unchanged', (
    tester,
  ) async {
    var invoked = 0;
    await _pump(
      tester,
      summary: _assistedSummary,
      earnedNow: false,
      next: _sourceHandoff,
      onNext: () => invoked++,
    );
    expect(find.text(_sourceHandoff.copyLine), findsOneWidget);
    expect(_sourceHandoff.toPayload(), {
      'sourceTaskId': 'what_poker_is_find_hero',
      'targetWorldId': 'world_1',
      'targetLessonId': 'what_poker_is',
      'targetTaskId': 'what_poker_is_find_hero',
      'reasonCode': 'exact_replay_hero_identity',
      'selectionSource': 'repair_intent_exact_replay',
      'copyLine': 'Repeat the same hero clue before your next decision.',
    });
    final action = tester.widget<FilledButton>(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    action.onPressed!();
    expect(invoked, 1);
  });

  testWidgets(
    'one real wrong answer generates identical Summary/Home receipt IDs',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final sample = Act0ShellStateV1.sample;
      final baseWorld = sample.worldById('world_1');
      final baseLesson = baseWorld.lessons.firstWhere(
        (lesson) => lesson.lessonId == 'fold_check_call_raise',
      );
      final taskIds = ['actions_legal_context', 'actions_check_drill'];
      final lesson = baseLesson.copyWith(
        state: Act0LessonStateV1.current,
        isSelectable: true,
        isLocked: false,
        primaryCtaLabel: 'Open lesson',
        tasks: [
          for (final id in taskIds)
            baseLesson.taskList.firstWhere((task) => task.taskId == id),
        ],
      );
      final world = baseWorld.copyWith(
        status: Act0WorldStateV1.current,
        isSelectable: true,
        isLocked: false,
        lessons: [lesson],
      );
      final host = Act0ShellStateV1(
        courseTitle: sample.courseTitle,
        courseSubtitle: sample.courseSubtitle,
        levelLabel: sample.levelLabel,
        xp: sample.xp,
        xpTarget: sample.xpTarget,
        streakDays: sample.streakDays,
        dailyGoalLabel: sample.dailyGoalLabel,
        dailyGoalValue: sample.dailyGoalValue,
        pathProgressLabel: sample.pathProgressLabel,
        selectedWorldId: 'world_1',
        worlds: [world],
        lessons: [lesson],
        review: sample.review,
        profile: sample.profile,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.play,
            initialPhase: Act0LessonPhaseV1.drill,
            showPlacementOnStart: false,
            state: host,
            debugHarnessEntry: const Act0ShellDebugHarnessEntryV1(
              mode: Act0ControlledDemoCaptureModeV1.directState,
              surface: Act0ControlledDemoCaptureSurfaceV1.runnerDrill,
              worldId: 'world_1',
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_legal_context',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
      await tester.pumpAndSettle();
      final root =
          tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
      final legacy =
          root.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>?;
      final b2 = root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
      final copy =
          root.debugNextUsefulHandCopyBridgePayloadV1() as Map<String, Object?>;
      expect(legacy, isNotNull);
      for (final key in [
        'sourceTaskId',
        'targetWorldId',
        'targetLessonId',
        'targetTaskId',
        'selectionSource',
        'reasonCode',
      ]) {
        expect(
          b2[key],
          legacy![key],
          reason: 'Summary and Home divergent at $key',
        );
      }
      expect(b2['sourceTaskId'], 'actions_legal_context');
      expect(b2['targetTaskId'], 'actions_check_drill');
      expect(b2['copyLine'], root.debugHomeNextUsefulHandReasonLineV1());
      expect(b2['reasonCode'], copy['reasonCode']);
    },
  );

  testWidgets('fallback without source repair cannot hijack continuation', (
    tester,
  ) async {
    const fallback = Act0SummaryNextHandoffV1(
      sourceTaskId: '',
      targetWorldId: 'world_1',
      targetLessonId: 'what_poker_is',
      targetTaskId: 'what_poker_is_find_hero',
      reasonCode: '',
      selectionSource: 'existing_fallback',
      copyLine: 'Should not replace forward plan.',
    );
    var invoked = 0;
    await _pump(
      tester,
      summary: _cleanSummary,
      earnedNow: false,
      next: fallback,
      onNext: () => invoked++,
    );
    expect(fallback.isActionableRepair, false);
    expect(find.text('Should not replace forward plan.'), findsNothing);
    final action = tester.widget<FilledButton>(
      find.byKey(const Key('act0_shell_block_summary_continue_cta')),
    );
    action.onPressed!();
    expect(invoked, 0);
  });
}
