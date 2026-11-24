import '../support/act0_source_choreography_test_wait_v1.dart';
import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import '../support/act0_authored_repair_goal_fixture_v1.dart';
import '../support/act0_shell_presentation_finders_v1.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
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
  await tester.binding.setSurfaceSize(const Size(393, 852));
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
    'actions_call_chip_cost',
    'actions_fold_drill',
    'actions_call_drill',
    'actions_raise_drill',
    'actions_review',
  ]) {
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, taskId);
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
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    final decisionRunner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    await pumpSourceChoreographyToDecisionV1(
      tester,
      decisionRunner.runner.table,
    );
    if (seat.evaluate().isNotEmpty) {
      await tester.tap(seat);
    } else {
      expect(option, findsOneWidget);
      await tester.tap(option);
    }
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
          .runner
          .selectedOptionId,
      answer.id,
      reason: 'Count only the real submitted decision.',
    );
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

// SIMULATED canonical historical W24 miss. It grants no curriculum progress.
Future<void> _pumpLockedW24DebtV1(WidgetTester tester) async {
  final fixture = Act0AuthoredRepairGoalFixtureV1.w24();
  final history = act0AuthoredRepairFixtureHistoryV1(intents: [fixture.intent]);
  SharedPreferences.setMockInitialValues({
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    'act0_shell_progress_v1': jsonEncode({
      'schemaVersion': 20,
      'pendingDecisionAssistance': <Object>[],
      'completedTaskIds': <String>[],
      'completedLessonIds': <String>[],
      'skippedTaskIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': 'what_poker_is',
      'selectedTaskId': 'what_poker_is_find_hero',
      'earnedXp': 17,
      'openRepairIntents': [fixture.intent.toPayload()],
      'learningEvidenceHistory': history.toPayload(),
      'learningEvidenceLineage': history.lineagePayload(),
    }),
  });
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.home,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(Act0ShellStateV1.sample.worldById('world_3').isLocked, isTrue);
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

Future<void> _triggerReviewRepairV1(WidgetTester tester) async {
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
  final review = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Review'),
  );
  await tester.ensureVisible(review);
  await tester.tap(review);
  await tester.pumpAndSettle();
  final repair = find
      .byKey(const Key('act0_academy_review_leaf_repair_cta'))
      .first;
  expect(repair, findsOneWidget);
  await tester.ensureVisible(repair);
  await tester.tap(repair);
  await tester.pumpAndSettle();
}

// Both calls resolve a fresh ordinary visible entry after the same saved
// historical miss, including after the existing cold-before-answer remount.
Future<void> _launchLockedW24RepairV1(
  WidgetTester tester, {
  required bool fromPracticeQueue,
}) async {
  if (!fromPracticeQueue) {
    await _triggerReviewRepairV1(tester);
    return;
  }
  final practice = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('Practice'),
  );
  expect(practice, findsOneWidget);
  await tester.ensureVisible(practice);
  await tester.tap(practice);
  await tester.pumpAndSettle();
  final launch = act0ShellPresentationFinderV1(
    'act0_shell_play_repair_queue_item_cta',
  );
  expect(launch, findsOneWidget);
  await tester.ensureVisible(launch);
  expect(launch.hitTestable(), findsOneWidget);
  await tester.tap(launch);
  await tester.pumpAndSettle();
}

Future<void> _launchVisibleHomeRepairV1(WidgetTester tester) async {
  final context = tester.element(find.byType(Act0ShellPreviewScreenV1));
  if (act0AcademyRuntimeEnabledV1(context, Act0ShellTabV1.home)) {
    // The Academy Home has one source-resolved next action. Exercise its
    // visible CTA; the caller still checks exact source/target and rewards.
    final cta = find.descendant(
      of: find.byKey(const Key('act0_academy_home_leaf')),
      matching: find.byKey(const Key('act0_academy_home_leaf_cta')),
    );
    expect(cta, findsOneWidget);
    await tester.ensureVisible(cta);
    await tester.tap(cta);
  } else {
    final home = tester.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
    home.onStartRepair!();
  }
}

bool _academyYouActiveV1(WidgetTester tester) => act0AcademyRuntimeEnabledV1(
  tester.element(find.byType(Act0ShellPreviewScreenV1)),
  Act0ShellTabV1.profile,
);

Finder _persistedTaskCountFinderV1(WidgetTester tester, int count) {
  if (_academyYouActiveV1(tester)) {
    return find.descendant(
      of: find.byKey(const Key('act0_academy_you_leaf_tasks')),
      matching: find.text('$count ${count == 1 ? 'task' : 'tasks'} completed'),
      matchRoot: true,
    );
  }
  return find.text('$count tasks complete');
}

Future<void> _restartPersistedRootV1(
  WidgetTester tester, {
  bool cold = false,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  if (cold) {
    await tester.runAsync(
      () => Act0ProgressStoreV1(
        key: 'act0_shell_progress_v1',
        isValidPayload: (_) => false,
      ).flush(),
    );
    // Same durable backend; discard only the public preferences read cache.
    SharedPreferences.resetStatic();
  }
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

Future<void> _openProfileTabV1(WidgetTester tester) async {
  final profileTab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text('You'),
  );
  expect(profileTab, findsOneWidget);
  await tester.ensureVisible(profileTab);
  await tester.tap(profileTab);
  await tester.pumpAndSettle();
  expect(
    find.byKey(
      Key(
        _academyYouActiveV1(tester)
            ? 'act0_academy_you_leaf'
            : 'act0_shell_profile_screen',
      ),
    ),
    findsOneWidget,
  );
}

void main() {
  testWidgets('Summary does not mark an assisted, mistaken run clean', (
    tester,
  ) async {
    await _pump(
      tester,
      summary: const Act0BlockCompletionSummaryV1(
        lessonTitle: 'First table',
        xpEarned: 5,
        errorCount: 1,
        assistedCount: 1,
        independentProvenanceKnown: true,
        taskCount: 2,
        correctCount: 1,
        startLevel: 1,
        endLevel: 1,
        startXp: 10,
        endXp: 15,
        xpTarget: 100,
      ),
      earnedNow: false,
    );
    expect(find.text('One clean read'), findsNothing);
    expect(find.text('Practice recorded'), findsOneWidget);
    expect(find.text('Assessed accuracy'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('act0_shell_block_summary_xp_progress')),
    );
    expect(bar.value, closeTo(0.5, 0.001));
  });

  testWidgets('Summary keeps clean-read copy for independent full success', (
    tester,
  ) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: true);
    expect(find.text('One clean read'), findsOneWidget);
    final bar = tester.widget<LinearProgressIndicator>(
      find.byKey(const Key('act0_shell_block_summary_xp_progress')),
    );
    expect(bar.value, 1.0);
  });

  for (final fromPracticeQueue in [false, true]) {
    testWidgets(
      fromPracticeQueue
          ? 'persisted locked W3 directed repair via Practice Queue does not grant curriculum or XP'
          : 'persisted locked W3 directed repair does not grant curriculum or XP',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await _pumpLockedW24DebtV1(tester);
        final root =
            tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
        final receipt =
            root.debugSummaryHomeHandoffPayloadV1() as Map<String, String>;
        const targetTask = 'same_hand_different_seat_w3_same_hand_recap';
        expect(
          receipt['sourceTaskId'],
          'same_hand_different_seat_w3_same_hand_recap',
        );
        expect(receipt['targetWorldId'], 'world_3');
        expect(receipt['targetTaskId'], targetTask);
        var prefs = await SharedPreferences.getInstance();
        final before = _persistedLearningSnapshotV1(prefs);
        expect(before['completedTaskIds'], isEmpty);
        expect(before['completedLessonIds'], isEmpty);
        expect(before['skippedTaskIds'], isEmpty);
        final originalSource = (before['learningEvidenceHistory'] as List)
            .cast<Map<String, dynamic>>()
            .singleWhere((record) => record['taskId'] == targetTask);
        expect(originalSource['choiceId'], 'one_answer');
        expect(originalSource['isCorrect'], isFalse);
        expect(originalSource['assistanceKind'], 'none');
        await _launchLockedW24RepairV1(
          tester,
          fromPracticeQueue: fromPracticeQueue,
        );
        expect(root.debugSelectedWorldIdV1(), 'world_3');
        expect(root.debugSelectedTaskIdV1(), targetTask);
        expect(
          root.debugActiveRepairContextPayloadV1()['sourceTaskId'],
          'same_hand_different_seat_w3_same_hand_recap',
        );
        await _restartPersistedRootV1(tester, cold: true);
        expect(find.byType(Act0LessonRunnerShellV1), findsNothing);
        prefs = await SharedPreferences.getInstance();
        final coldBeforeAnswer = _persistedLearningSnapshotV1(prefs);
        expect(coldBeforeAnswer['earnedXp'], before['earnedXp']);
        expect(
          coldBeforeAnswer['completedTaskIds'],
          before['completedTaskIds'],
        );
        expect(
          coldBeforeAnswer['completedLessonIds'],
          before['completedLessonIds'],
        );
        await _launchLockedW24RepairV1(
          tester,
          fromPracticeQueue: fromPracticeQueue,
        );
        final restoredRoot =
            tester.state(find.byType(Act0ShellPreviewScreenV1)) as dynamic;
        expect(restoredRoot.debugSelectedWorldIdV1(), 'world_3');
        expect(restoredRoot.debugSelectedTaskIdV1(), targetTask);
        expect(
          restoredRoot.debugActiveRepairContextPayloadV1()['sourceTaskId'],
          targetTask,
        );
        final current = tester.widget<Act0LessonRunnerShellV1>(
          find.byType(Act0LessonRunnerShellV1),
        );
        expect(current.selectedTaskId, targetTask);
        expect(current.runner.phase, Act0LessonPhaseV1.drill);
        expect(current.runner.selectedOptionId, isNull);
        expect(current.runner.options.map((option) => option.id), [
          'one_answer',
          'framework',
          'seat_blind_only',
        ]);
        expect(
          current.runner.options.singleWhere((option) => option.isCorrect).id,
          'framework',
        );
        await _answerCurrentRunnerV1(tester, correct: true);
        expect(
          tester
              .widget<Act0LessonRunnerShellV1>(
                find.byType(Act0LessonRunnerShellV1),
              )
              .runner
              .selectedOptionId,
          'framework',
        );
        final repairContinue = find.byKey(
          const Key('act0_shell_feedback_continue_cta'),
        );
        await tester.ensureVisible(repairContinue);
        await tester.pumpAndSettle();
        await tester.tap(repairContinue);
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
        final currentRecords = evidence
            .where((record) => record['taskId'] == targetTask)
            .toList();
        expect(currentRecords, hasLength(2));
        expect(currentRecords.first, originalSource);
        final firstCanonicalRepair = currentRecords.last;
        expect(firstCanonicalRepair['choiceId'], 'framework');
        expect(firstCanonicalRepair['expectedChoiceId'], 'framework');
        expect(firstCanonicalRepair['isCorrect'], isTrue);
        expect(firstCanonicalRepair['assistanceKind'], 'none');
        expect(firstCanonicalRepair['runKind'], 'repair');
        expect(firstCanonicalRepair['reviewKind'], 'exactReplay');
        expect(
          firstCanonicalRepair['authoredSourceFingerprint'],
          originalSource['authoredSourceFingerprint'],
        );
        final outcomes = (after['repairOutcomeProjection'] as List)
            .cast<Map<String, dynamic>>();
        expect(outcomes, hasLength(1));
        expect(outcomes.single['sourceTaskId'], targetTask);
        expect(outcomes.single['targetTaskId'], targetTask);
        expect(
          outcomes.single['repairOccurrenceId'],
          originalSource['recordId'],
        );
        expect(
          outcomes.single['repairAttemptId'],
          firstCanonicalRepair['recordId'],
        );
        expect(outcomes.single['selectedChoiceId'], 'framework');
        expect(outcomes.single['isCorrect'], isTrue);
        expect(restoredRoot.debugOpenRepairIntentCountV1(), 0);
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
          restored['repairOutcomeProjection'],
          after['repairOutcomeProjection'],
        );
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
        await _openProfileTabV1(tester);
        expect(
          _persistedTaskCountFinderV1(
            tester,
            (restored['completedTaskIds'] as List).length,
          ),
          findsOneWidget,
          reason:
              'Repair-only correction must not inflate visible completed-task count on Profile/You after restart',
        );
      },
    );
  }

  testWidgets('ordinarily available W1 task still earns curriculum and XP', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
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
    await _openProfileTabV1(tester);
    expect(
      _persistedTaskCountFinderV1(
        tester,
        (restored['completedTaskIds'] as List).length,
      ),
      findsOneWidget,
      reason:
          'Profile/You must show the actual persisted completed-task count after restart',
    );
    final afterProfileView = _persistedLearningSnapshotV1(prefs);
    expect(
      afterProfileView['earnedXp'],
      restored['earnedXp'],
      reason: 'Viewing Profile/You must not itself mint new XP',
    );
  });

  for (final withWorld3 in [true, false]) {
    testWidgets('W1 admitted no-bet repair route (W3 present: $withWorld3)', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.binding.setSurfaceSize(const Size(393, 852));
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
              lessonId: 'fold_check_call_raise',
              taskId: 'actions_legal_context',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, 'actions_legal_context');
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
      const worldId = 'world_1';
      const taskId = 'actions_check_drill';
      expect(home['sourceTaskId'], 'actions_legal_context');
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
      expect(summary['selectionSource'], 'repair_intent_mapped');
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
      await _launchVisibleHomeRepairV1(tester);
      await tester.pumpAndSettle();
      expect(root.debugSelectedWorldIdV1(), worldId);
      expect(root.debugSelectedLessonIdV1(), summary['targetLessonId']);
      expect(root.debugSelectedTaskIdV1(), taskId);
      expect(find.byType(Act0LessonRunnerShellV1), findsOneWidget);
      if (withWorld3) expect(sample.worldById('world_3').isLocked, isTrue);
    });
  }
  testWidgets(
    'Hero partial relation keeps debt and never launches a BTN repair',
    (tester) async {
      await _pumpPersistedW1Learner(tester);
      await _answerCurrentRunnerV1(tester, correct: false);
      final dynamic root = tester.state(find.byType(Act0ShellPreviewScreenV1));
      final prefs = await SharedPreferences.getInstance();
      final before = _persistedLearningSnapshotV1(prefs);
      final home =
          root.debugNextUsefulHandTargetPayloadV1() as Map<String, Object?>;
      expect(home['selectionSource'], 'existing_fallback');
      expect(
        home['targetTaskId'],
        isNot('position_six_seats_position_repair_seat_id_btn'),
      );
      expect(root.debugActiveRepairContextPayloadV1(), isEmpty);
      expect(root.debugOpenRepairIntentCountV1(), 1);
      expect((before['repairOutcomeProjection'] as List), isEmpty);
      await _restartPersistedRootV1(tester);
      final after = _persistedLearningSnapshotV1(prefs);
      expect(after['earnedXp'], before['earnedXp']);
      expect(after['openRepairIntents'], before['openRepairIntents']);
      expect(
        after['learningEvidenceHistory'],
        before['learningEvidenceHistory'],
      );
      expect(
        (after['learningEvidenceHistory'] as List)
            .cast<Map<String, dynamic>>()
            .where(
              (record) =>
                  record['taskId'] ==
                  'position_six_seats_position_repair_seat_id_btn',
            ),
        isEmpty,
      );
    },
  );

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

  testWidgets('RU Result offers one localized forward CTA', (tester) async {
    await _pump(tester, summary: _cleanSummary, earnedNow: true, ru: true);
    final primary = find.byKey(
      const Key('act0_shell_block_summary_continue_cta'),
    );
    expect(primary, findsOneWidget);
    expect(
      find.descendant(of: primary, matching: find.text('Продолжить обучение')),
      findsOneWidget,
    );
    expect(find.text('К карте уроков'), findsNothing);
    expect(find.text('Step 2 of 9'), findsNothing);
    expect(find.text('Replay for perfect'), findsNothing);
    expect(find.text('Back to map'), findsNothing);
    expect(find.text('What improved'), findsNothing);
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
