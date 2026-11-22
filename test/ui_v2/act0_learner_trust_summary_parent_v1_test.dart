import '../support/act0_route_practice_runner_test_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';
import '../support/act0_authored_repair_goal_fixture_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'dart:convert';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_progress_store_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_academy_runtime_adapter_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/academy_leaves/act0_academy_home_leaf_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learn_path_shell_v1.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_home_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _progressKey = 'act0_shell_progress_v1';
const _guideLessonId = 'fold_check_call_raise';

final _guideLesson = Act0ShellStateV1.sample
    .worldById('world_1')
    .lessons
    .firstWhere((lesson) => lesson.lessonId == _guideLessonId);
// SIMULATED persisted guided history; the real producer is covered by JRN-06.
Map<String, Object?> _priorGuidedCheck({bool stale = false}) {
  final fixture = Act0AuthoredRepairGoalFixtureV1.noBet();
  final outcome = fixture.outcome(
    attemptId: 'prior-guided-check',
    sessionId: 'prior-guided-session',
  );
  return {
    ...act0AuthoredRepairFixtureAttemptV1(outcome, order: 1).toPayload(),
    'runKind': act0DiagnosticLearningEntryRunKindV1,
    'startedBy': 'placement_learning_entry',
    'reviewKind': 'initialAssessment',
    if (stale) 'authoredSourceFingerprint': '0' * 64,
  };
}

Future<void> _pumpGuide(
  WidgetTester tester, {
  List<String> completedTaskIds = const <String>[],
  List<Map<String, Object?>> history = const <Map<String, Object?>>[],
}) async {
  tester.view.physicalSize = const Size(393, 852);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  SharedPreferences.setMockInitialValues(<String, Object>{
    'act0_welcome_completed_v1': true,
    'intake_completed_v1': true,
    _progressKey: jsonEncode(<String, Object?>{
      'schemaVersion': 18,
      'completedTaskIds': completedTaskIds,
      // Prerequisite-only fixture, never earned progress or XP.
      'skippedTaskIds': [
        for (final lesson
            in Act0ShellStateV1.sample
                .worldById('world_1')
                .lessons
                .takeWhile((lesson) => lesson.lessonId != _guideLessonId))
          for (final task in lesson.taskList) task.taskId,
      ],
      'completedLessonIds': <String>[],
      'selectedWorldId': 'world_1',
      'selectedLessonId': _guideLessonId,
      'selectedTaskId': _guideLesson.taskList.first.taskId,
      'earnedXp': 0,
      if (history.isNotEmpty) 'learningEvidenceHistory': history,
      if (history.isNotEmpty)
        'learningEvidenceLineage': Act0LearningEvidenceHistoryV1(
          records: [
            for (final row in history)
              Act0LearningEvidenceRecordV1.tryParse(row)!,
          ],
        ).lineagePayload(),
    }),
  });
  await _mountRoot(tester);
  await _openTab(tester, 'Learn');
  final start = find.byKey(const Key('act0_shell_current_mission_cta'));
  expect(start, findsOneWidget);
  await tester.ensureVisible(start);
  await tester.tap(start);
  await tester.pumpAndSettle();
}

Future<void> _mountRoot(WidgetTester tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: Act0ShellPreviewScreenV1(
        initialTab: Act0ShellTabV1.home,
        initialPhase: Act0LessonPhaseV1.theory,
        showPlacementOnStart: false,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Plays the ordinary Action lesson with one authored no-bet miss, followed by
/// unassisted familiar repair/recheck. The initial wrong remains assessment truth.
Future<List<String>> _answerGuideToSummary(WidgetTester tester) async {
  final answered = <String>[];
  for (var step = 0; step < 80; step++) {
    if (find
        .byKey(const Key('act0_shell_block_summary_title'))
        .evaluate()
        .isNotEmpty) {
      final summary = tester
          .widget<Act0BlockCompletionShellV1>(
            find.byType(Act0BlockCompletionShellV1),
          )
          .summary;
      if (summary.curriculumCompleted) return answered;
      // An earned-read payoff can precede full lesson completion. Follow its
      // real next action rather than treating its headline as the final result.
      final next = find.byKey(
        const Key('act0_shell_block_summary_continue_cta'),
      );
      expect(next, findsOneWidget);
      await tester.ensureVisible(next);
      await tester.tap(next);
      await tester.pumpAndSettle();
      continue;
    }
    final runners = find.byType(Act0LessonRunnerShellV1);
    if (runners.evaluate().isNotEmpty) {
      final runner = tester.widget<Act0LessonRunnerShellV1>(runners);
      final correct = runner.runner.options.where(
        (o) =>
            runner.selectedTaskId == 'actions_check_drill' &&
                !answered.contains('actions_check_drill')
            ? !o.isCorrect
            : o.isCorrect,
      );
      if (correct.isNotEmpty &&
          runner.runner.phase == Act0LessonPhaseV1.drill &&
          runner.runner.selectedOptionId == null) {
        final choice = correct.first;
        final seat = find.byKey(Key('act0_shell_seat_tap_${choice.seatId}'));
        final option = find.byKey(Key('act0_shell_option_${choice.id}'));
        final target = seat.evaluate().isNotEmpty ? seat : option;
        if (target.evaluate().isNotEmpty) {
          await tester.ensureVisible(target.first);
          await pumpSourceChoreographyToDecisionV1(tester, runner.runner.table);
          expect(target.hitTestable(), findsOneWidget);
          await tester.tap(target.first);
          await tester.pumpAndSettle();
          final submitted = tester.widget<Act0LessonRunnerShellV1>(runners);
          expect(
            submitted.runner.selectedOptionId,
            choice.id,
            reason: 'Count only the real submitted decision.',
          );
          answered.add(runner.selectedTaskId ?? '');
          if (runner.selectedTaskId == 'actions_check_drill' &&
              !choice.isCorrect) {
            await tester.runAsync(
              () => Act0ProgressStoreV1(
                key: _progressKey,
                isValidPayload: (_) => false,
              ).flush(),
            );
            final saved = await _persisted();
            final miss = (saved['learningEvidenceHistory'] as List)
                .cast<Map>()
                .singleWhere(
                  (record) =>
                      record['taskId'] == 'actions_check_drill' &&
                      record['isCorrect'] == false,
                );
            expect(miss['runId'], isNotEmpty);
            expect(miss['sessionId'], isNotEmpty);
            expect(miss['runOrdinal'], greaterThan(0));
            final intent = (saved['openRepairIntents'] as List)
                .cast<Map>()
                .singleWhere(
                  (intent) => intent['sourceTaskId'] == 'actions_check_drill',
                );
            expect(intent['repairOccurrenceId'], miss['recordId']);
            expect(intent['targetTaskId'], 'actions_legal_context');
          }
          continue;
        }
      }
    }
    final forward = <String>[
      'act0_shell_theory_continue_cta',
      'act0_shell_continue_cta',
      'act0_shell_feedback_continue_cta',
    ].map((key) => find.byKey(Key(key))).where((f) => f.evaluate().isNotEmpty);
    expect(forward, isNotEmpty, reason: 'no forward route at step $step');
    await tester.ensureVisible(forward.first.first);
    await tester.tap(forward.first.first);
    await tester.pumpAndSettle();
  }
  final runner = tester.widget<Act0LessonRunnerShellV1>(
    find.byType(Act0LessonRunnerShellV1),
  );
  fail(
    'Session Summary not reached: ${runner.selectedTaskId} ${runner.runner.phase} selected=${runner.runner.selectedOptionId} answered=$answered',
  );
}

Future<Map<String, dynamic>> _persisted() async {
  final prefs = await SharedPreferences.getInstance();
  return jsonDecode(prefs.getString(_progressKey)!) as Map<String, dynamic>;
}

Future<void> _openTab(WidgetTester tester, String label) async {
  final tab = find.descendant(
    of: find.byKey(const Key('act0_shell_bottom_nav')),
    matching: find.text(label),
  );
  await tester.ensureVisible(tab);
  await tester.tap(tab);
  await tester.pumpAndSettle();
}

Future<void> _leaveSummary(WidgetTester tester) async {
  final home = find.byKey(const Key('act0_shell_block_summary_home_cta'));
  final map = home.evaluate().isNotEmpty
      ? home
      : find.byKey(const Key('act0_shell_block_summary_map_cta'));
  if (map.evaluate().isNotEmpty) {
    await tester.ensureVisible(map);
    await tester.tap(map);
    await tester.pumpAndSettle();
  }
  final back = find.byKey(const Key('act0_shell_runner_back'));
  if (back.evaluate().isNotEmpty) {
    await tester.tap(back);
    await tester.pumpAndSettle();
  }
}

void main() {
  for (final priorGuided in ['none', 'current', 'stale']) {
    testWidgets(
      'real no-bet lesson completion preserves first assessment (prior guided: $priorGuided)',

      (t) async {
        await _pumpGuide(
          t,
          history: priorGuided == 'none'
              ? []
              : [_priorGuidedCheck(stale: priorGuided == 'stale')],
        );
        await _answerGuideToSummary(t);
        // The payoff headline can name an earned read. The source-owned
        // completion and first-assessment counts carry the curriculum claim.
        final summary = t
            .widget<Act0BlockCompletionShellV1>(
              find.byType(Act0BlockCompletionShellV1),
            )
            .summary;
        expect(summary.curriculumCompleted, isTrue);
        expect(summary.errorCount, 1);
        expect(summary.correctCount, summary.taskCount - 1);
        expect(summary.independentProvenanceKnown, isTrue);
        expect(find.text('All correct'), findsNothing);
        expect(find.text('Replay before next lesson'), findsNothing);
        final saved = await _persisted();
        expect(
          saved['completedTaskIds'],
          containsAll(_guideLesson.taskList.map((task) => task.taskId)),
        );
        expect(saved['completedLessonIds'], contains(_guideLessonId));
        final history = (saved['learningEvidenceHistory'] as List)
            .cast<Map<String, dynamic>>();
        final source = history.firstWhere(
          (record) =>
              record['taskId'] == 'actions_check_drill' &&
              record['runKind'] != act0DiagnosticLearningEntryRunKindV1,
        );
        expect(source['isCorrect'], isFalse);
        expect(source['choiceId'], 'fold');
        if (priorGuided == 'current') {
          expect(source['reviewKind'], 'exactReplay');
        } else if (priorGuided == 'stale') {
          expect(source['reviewKind'], isNot('exactReplay'));
          expect(source['reviewKind'], isNot('unseenTransfer'));
        }
        expect(
          history.any(
            (record) =>
                record['taskId'] == 'actions_legal_context' &&
                record['runKind'] == 'repair' &&
                record['isCorrect'] == true &&
                record['assistanceKind'] == 'none',
          ),
          isTrue,
        );
        final earnedXp = saved['earnedXp'];
        await _leaveSummary(t);
        await _openTab(t, 'Home');
        if (act0AcademyRuntimeEnabledV1(
          t.element(find.byType(Act0ShellPreviewScreenV1)),
          Act0ShellTabV1.home,
        )) {
          final home = t.widget<Act0AcademyHomeLeafV1>(
            find.byType(Act0AcademyHomeLeafV1),
          );
          final completed = (saved['completedLessonIds'] as List)
              .cast<String>()
              .toSet();
          expect(
            home.input.earnedLessonCount,
            Act0ShellStateV1.sample
                .worldById('world_1')
                .lessons
                .where((lesson) => completed.contains(lesson.lessonId))
                .length,
          );
          // The actual curriculum advances beyond the completed Guide.
          await _openTab(t, 'Learn');
          Act0LearnPathShellV1 learn() =>
              t.widget<Act0LearnPathShellV1>(find.byType(Act0LearnPathShellV1));
          if (learn().requiredPractice != null) {
            await tapAct0RoutePracticeKeyV1(
              t,
              'act0_shell_current_mission_cta',
            );
            await finishAct0RoutePracticeV1(t, correct: true);
          }
          final current = learn().lessons.firstWhere(
            (lesson) =>
                lesson.isSelectable &&
                lesson.state == Act0LessonStateV1.current,
          );
          expect(current.lessonId, isNot(_guideLessonId));
        } else {
          final home = t.widget<Act0HomeShellV1>(find.byType(Act0HomeShellV1));
          expect(home.currentLesson!.lessonId, isNot(_guideLessonId));
        }
        expect((await _persisted())['earnedXp'], earnedXp);
      },
    );
  }
}
