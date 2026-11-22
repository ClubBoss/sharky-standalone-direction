import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_beta_metrics_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_route_practice_runner_test_v1.dart';

const _progressKey = 'act0_shell_progress_v1';

Act0LessonRunnerShellV1 _runner(WidgetTester tester) => tester
    .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1));

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget, reason: key);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _mount(
  WidgetTester tester, {
  bool fresh = false,
  bool resumeRunner = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Act0ShellPreviewScreenV1(
        debugLegacyPlacementOnStart: true,
        key: UniqueKey(),
        initialTab: resumeRunner ? Act0ShellTabV1.play : Act0ShellTabV1.home,
        showPlacementOnStart: fresh,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<Map<String, dynamic>> _saved() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _advanceTask(WidgetTester tester) async {
  final taskId = _runner(tester).selectedTaskId;
  for (var i = 0; i < 12; i++) {
    if (_runner(tester).selectedTaskId != taskId) return;
    final runner = _runner(tester).runner;
    if (runner.phase == Act0LessonPhaseV1.review) {
      await _tap(tester, 'act0_shell_feedback_continue_cta');
      return;
    }
    final answers = runner.options.where((o) => o.isCorrect);
    if (runner.phase != Act0LessonPhaseV1.theory && answers.isNotEmpty) {
      final answer = answers.first;
      final seatKey = 'act0_shell_seat_tap_${answer.seatId}';
      final optionKey = 'act0_shell_option_${answer.id}';
      if (find.byKey(Key(seatKey)).evaluate().isNotEmpty ||
          find.byKey(Key(optionKey)).evaluate().isNotEmpty) {
        await _tap(
          tester,
          find.byKey(Key(seatKey)).evaluate().isNotEmpty ? seatKey : optionKey,
        );
        continue;
      }
    }
    // Respect the authored theory dwell timer before using its real CTA.
    await tester.pump(const Duration(seconds: 3));
    final theory = find.byKey(const Key('act0_shell_theory_continue_cta'));
    await _tap(
      tester,
      theory.evaluate().isNotEmpty
          ? 'act0_shell_theory_continue_cta'
          : 'act0_shell_continue_cta',
    );
  }
  fail('Task did not advance: $taskId');
}

Future<void> _startLearnMission(WidgetTester tester) async {
  await tester.tap(find.text('Learn').last);
  await tester.pumpAndSettle();
  await _tap(tester, 'act0_shell_current_mission_cta');
}

void main() {
  testWidgets(
    'genuine Learn starts own distinct runs and sessions across restart',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      await _mount(tester, fresh: true);
      for (final key in [
        'act0_shell_placement_intro_cta',
        'act0_shell_placement_option_new',
        'act0_shell_placement_next_cta',
        'act0_shell_welcome_primary_cta',
      ]) {
        await _tap(tester, key);
      }
      final welcome = _runner(
        tester,
      ).runner.options.firstWhere((o) => o.isCorrect);
      await _tap(tester, 'act0_shell_option_${welcome.id}');
      await _tap(tester, 'act0_shell_welcome_primary_cta');
      await _startLearnMission(tester);
      final lesson = Act0ShellStateV1.sample
          .worldById('world_1')
          .lessons
          .firstWhere((l) => l.lessonId == 'what_poker_is');
      for (final task in lesson.courseTaskList) {
        expect(_runner(tester).selectedTaskId, task.taskId);
        await _advanceTask(tester);
        final records = (await _saved())['learningEvidenceHistory'] as List;
        for (final record in records) {
          expect(
            record['runId'],
            isNotEmpty,
            reason: 'Learn-start must initialize the source-owned run key',
          );
          expect(record['runKind'], 'lesson');
          expect(record['startedBy'], 'learn_route');
          expect(record['sourceWorldId'], 'world_1');
          expect(record['sourceLessonId'], lesson.lessonId);
          expect(record['sessionId'], isNotEmpty);
          expect(record['isCorrect'], true);
          expect(record['assistanceKind'], 'none');
          expect(record['choiceId'], record['expectedChoiceId']);
        }
      }
      expect(find.byType(Act0BlockCompletionShellV1), findsOneWidget);
      final completed = await _saved();
      final firstRecords = completed['learningEvidenceHistory'] as List;
      expect(firstRecords, hasLength(3));
      expect(
        firstRecords.map((record) => record['taskId']),
        contains('w1_shared_card_access'),
      );
      final evidence = [
        for (final raw in firstRecords)
          Act0LearningEvidenceRecordV1.tryParse(raw)!,
      ];
      final scores = Act0BetaLearningMetricsV1.fromProgress(
        firstWorld: Act0ShellStateV1.sample.worldById('world_1'),
        completedTaskIds: (completed['completedTaskIds'] as List)
            .cast<String>()
            .toSet(),
        correctedMistakes: 0,
        history: Act0LearningEvidenceHistoryV1(records: evidence),
      ).decisionsSince(evidence.first.recordedAtUtc!);
      expect(scores.withHelp, (correct: 0, total: 0));
      expect(scores.onYourOwn, (correct: 3, total: 3));
      final firstRun = firstRecords.first['runId'];
      final firstOrdinal = firstRecords.first['runOrdinal'] as int;
      final firstSession = firstRecords.first['sessionId'];
      expect(firstRecords.map((r) => r['runId']).toSet(), {firstRun});
      expect(firstRecords.map((r) => r['sessionId']).toSet(), {firstSession});
      expect(completed['earnedXp'], 20);
      expect(completed['completedTaskIds'], hasLength(4));
      expect(completed['completedLessonIds'], contains(lesson.lessonId));

      // Restart from app-produced preferences: no seeded IDs or historical backfill.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await _mount(tester);
      final restored = await _saved();
      expect(restored['learningEvidenceHistory'], firstRecords);
      expect(restored['earnedXp'], completed['earnedXp']);
      expect(restored['completedTaskIds'], completed['completedTaskIds']);
      expect(restored['completedLessonIds'], completed['completedLessonIds']);
      await _startLearnMission(tester);
      final nextLesson = Act0ShellStateV1.sample.lessonById(
        'chips_in_the_middle',
      );
      expect(_runner(tester).selectedTaskId, nextLesson.taskList.first.taskId);
      await _advanceTask(tester);
      final task = nextLesson.taskList[1];
      expect(_runner(tester).selectedTaskId, task.taskId);
      await _advanceTask(tester);
      final next = await _saved();
      final nextRecords = next['learningEvidenceHistory'] as List;
      expect(nextRecords.take(firstRecords.length).toList(), firstRecords);
      expect(nextRecords, hasLength(5));
      final newRecord = nextRecords.last;
      expect(newRecord['taskId'], task.taskId);
      expect(newRecord['runId'], isNotEmpty);
      expect(newRecord['runId'], isNot(firstRun));
      expect(newRecord['runOrdinal'], greaterThan(firstOrdinal));
      expect(newRecord['runKind'], 'lesson');
      expect(newRecord['startedBy'], 'learn_route');
      expect(newRecord['sourceWorldId'], 'world_1');
      expect(newRecord['sourceLessonId'], nextLesson.lessonId);
      expect(newRecord['sessionId'], isNotEmpty);
      expect(newRecord['sessionId'], isNot(firstSession));
      expect(newRecord['isCorrect'], true);
      expect(newRecord['assistanceKind'], 'none');
      const independentId = 'cards_ranks_suits_premium_decision';
      for (var step = 0; step < 18; step++) {
        if (act0RoutePracticeFinder.evaluate().isNotEmpty) {
          await finishAct0RoutePracticeV1(tester, correct: true);
        } else if (find
            .byType(Act0BlockCompletionShellV1)
            .evaluate()
            .isNotEmpty) {
          await _tap(tester, 'act0_shell_block_summary_continue_cta');
        } else if (find.byType(Act0LessonRunnerShellV1).evaluate().isEmpty) {
          await _startLearnMission(tester);
        } else {
          if (_runner(tester).selectedTaskId == independentId) break;
          await _advanceTask(tester);
        }
      }
      expect(_runner(tester).selectedTaskId, independentId);
      await _advanceTask(tester);
      final afterKings = (await _saved())['learningEvidenceHistory'] as List;
      final independent = Act0LearningEvidenceRecordV1.tryParse(
        afterKings.last,
      )!;
      expect(independent.taskId, independentId);
      expect(independent.isIndependentCorrect, isTrue);
      final coached = afterKings.singleWhere(
        (record) => record['taskId'] == 'first_table_guide_first_decision',
      );
      expect(coached['lessonId'], 'first_table_guide');
      expect(coached['assistanceKind'], 'theoryRecall');
    },
  );
}
