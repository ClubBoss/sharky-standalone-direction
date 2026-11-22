import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_beta_metrics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_route_practice_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_atlas_practice_v1.dart';
import '../support/act0_route_practice_runner_test_v1.dart';

const _progressKey = 'act0_shell_progress_v1';

Future<Map<String, dynamic>> _saved(WidgetTester tester) async {
  Map<String, dynamic>? saved;
  await tester.runAsync(() async {
    await Act0ProgressStoreV1(
      key: _progressKey,
      isValidPayload: (_) => false,
    ).flush().timeout(const Duration(seconds: 3));
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final head = jsonDecode(prefs.getString('${_progressKey}_head')!) as Map;
    saved = jsonDecode(head['payload'] as String) as Map<String, dynamic>;
  });
  return saved!;
}

Future<void> _mount(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      home: Act0ShellPreviewScreenV1(
        key: UniqueKey(),
        showPlacementOnStart: false,
        initialTab: Act0ShellTabV1.learn,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final step = act0RoutePracticeStepsV1(world).first;
  final earlier = world.lessons.take(step.beforeLessonIndex);
  final nextLesson = world.lessons[step.beforeLessonIndex];
  final earlierTasks = [for (final lesson in earlier) ...lesson.courseTaskList];
  final priorXp = earlierTasks.fold(0, (sum, task) => sum + task.rewardXp);

  void seed(int schema, {required bool alreadyInNextLesson}) {
    final current = alreadyInNextLesson ? nextLesson : earlier.last;
    final done = {
      ...earlierTasks.map((task) => task.taskId),
      if (alreadyInNextLesson) nextLesson.courseTaskList.first.taskId,
    };
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      _progressKey: jsonEncode({
        'schemaVersion': schema,
        'completedTaskIds': done.toList(),
        'completedLessonIds': earlier.map((lesson) => lesson.lessonId).toList(),
        'selectedWorldId': world.worldId,
        'selectedLessonId': current.lessonId,
        'selectedTaskId': current.courseTaskList.last.taskId,
        'earnedXp': priorXp,
        if (schema == 20) ...{
          'pendingDecisionAssistance': [],
          'learningEvidenceHistory': [],
          'learningEvidenceLineage': const Act0LearningEvidenceHistoryV1()
              .lineagePayload(),
          'durableRetentionHistory': [],
        },
        if (!alreadyInNextLesson)
          'routePractice': const Act0RoutePracticeProgressV1().toPayload(),
      }),
    });
  }

  test(
    'S4 has a reachable 4–6 rep step at every boundary in all 12 worlds',
    () {
      final worlds = Act0ShellStateV1.sample.worlds.take(12);
      expect(worlds.length, 12);
      for (final world in worlds) {
        final audit = auditAtlasPracticeWorldV1(world);
        expect(audit.gaps, isEmpty, reason: world.worldId);
        expect(audit.steps, greaterThan(0), reason: world.worldId);
      }
    },
  );

  test(
    'practice prioritizes the open skill and weak lessons, then fresh hands',
    () {
      final pool = act0RoutePracticeRepsByIdV1.values;
      final mistake = pool.first;
      final weak = pool.firstWhere(
        (entry) => entry.lessonId != mistake.lessonId,
      );
      final eligible = pool.map((entry) => entry.lessonId).toSet();
      final deck = act0RoutePracticeDeckV1(
        eligibleLessonIds: eligible,
        preferredWorldId: world.worldId,
        openMistakeLessonIds: {mistake.lessonId},
        weakLessonIds: {weak.lessonId},
        openMistakeFamilies: {mistake.conceptFamilyId},
        seenTaskIds: {},
      );
      expect(deck.first.lessonId, mistake.lessonId);
      expect(deck.first.conceptFamilyId, mistake.conceptFamilyId);
      expect(deck.map((rep) => rep.task.taskId).toSet(), hasLength(4));
      final fresh = act0RoutePracticeDeckV1(
        eligibleLessonIds: eligible,
        preferredWorldId: world.worldId,
        openMistakeLessonIds: {},
        weakLessonIds: {},
        seenTaskIds: deck.map((rep) => rep.task.taskId).toSet(),
      );
      expect(
        fresh.map((rep) => rep.task.taskId),
        isNot(contains(deck.first.task.taskId)),
      );
    },
  );

  testWidgets('all wrong still unlocks, resumes feedback and keeps XP', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    seed(20, alreadyInNextLesson: false);
    await _mount(tester);

    Act0LearnPathShellV1 learn() =>
        tester.widget(find.byType(Act0LearnPathShellV1));
    Act0LessonCardV1 upcoming() => learn().lessons.singleWhere(
      (lesson) => lesson.lessonId == nextLesson.lessonId,
    );
    Act0LessonRunnerShellV1 runner() =>
        tester.widget(find.byType(Act0LessonRunnerShellV1));

    expect(upcoming().isLocked, isTrue);
    expect(learn().requiredPractice?.lessonId, step.id);
    await tapAct0RoutePracticeKeyV1(tester, 'act0_shell_current_mission_cta');
    expect(act0RoutePracticeFinder, findsOneWidget);
    final total = runner().runner.beatCount;
    expect(total, inInclusiveRange(4, 6));
    final firstTaskId = runner().selectedTaskId;
    await answerAct0RoutePracticeV1(tester, correct: false);
    final answer = runner().runner.selectedOptionId;
    expect(answer, isNotNull);
    final mid = await _saved(tester);
    expect(mid['earnedXp'], priorXp);

    await _mount(tester);
    expect(act0RoutePracticeFinder, findsOneWidget);
    expect(runner().selectedTaskId, firstTaskId);
    expect(runner().runner.selectedOptionId, answer);
    final used = <String?>{firstTaskId};
    await tapAct0RoutePracticeKeyV1(tester, 'act0_shell_feedback_continue_cta');
    for (var index = 1; index < total; index++) {
      expect(used.add(runner().selectedTaskId), isTrue);
      await answerAct0RoutePracticeV1(tester, correct: false);
      await tapAct0RoutePracticeKeyV1(
        tester,
        'act0_shell_feedback_continue_cta',
      );
    }
    expect(act0RoutePracticeFinder, findsNothing);
    expect(upcoming().isSelectable, isTrue);
    expect(learn().requiredPractice, isNull);
    final done = await _saved(tester);
    expect(done['earnedXp'], priorXp);
    expect(done['completedTaskIds'], mid['completedTaskIds']);
    expect((done['routePractice'] as Map)['finished'], [step.id]);
  });

  for (final version in [17, 20]) {
    testWidgets('v$version preserves an already entered lesson', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      seed(version, alreadyInNextLesson: true);
      await _mount(tester);
      final learn = tester.widget<Act0LearnPathShellV1>(
        find.byType(Act0LearnPathShellV1),
      );
      expect(learn.requiredPractice, isNull);
      expect(
        learn.lessons
            .singleWhere((lesson) => lesson.lessonId == nextLesson.lessonId)
            .isSelectable,
        isTrue,
      );
    });
  }

  test('Copy summary uses the completed mandatory set count', () {
    final metrics = Act0BetaLearningMetricsV1.fromProgress(
      firstWorld: world,
      completedTaskIds: {},
      correctedMistakes: 0,
      completedRoutePracticeSteps: 3,
    );
    final when = DateTime.utc(2026, 11, 22);
    expect(
      metrics
          .summary(
            Act0BetaActivityV1.firstVisit(when),
            when,
            reminderEnabled: null,
          )
          .clipboard,
      contains('Completed route practice steps: 3'),
    );
  });
}
