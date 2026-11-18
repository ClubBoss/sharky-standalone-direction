import '../support/act0_shell_presentation_finders_v1.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Day 2 and 7 open one saved review without changing XP', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final now = DateTime.utc(2026, 7, 18, 12);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 17,
        'completedTaskIds': <String>[],
        'skippedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'what_poker_is_content',
        'selectedTaskId': 'what_poker_is_pot_stack',
        'earnedXp': 0,
        'learningEvidenceHistory': <Object>[
          <String, Object>{
            'schemaVersion': 1,
            'recordId':
                'v1|world_1|fold_check_call_raise|actions_check_drill|actionList|fold|1',
            'createdOrder': 1,
            'worldId': 'world_1',
            'lessonId': 'fold_check_call_raise',
            'taskId': 'actions_check_drill',
            'sourceTaskId': 'actions_check_drill',
            'choiceId': 'fold',
            'expectedChoiceId': 'check',
            'isCorrect': false,
            'errorType': 'misread_action_legality',
            'conceptFamilyId': 'no_bet_yet',
            'repairFocusId': 'no_bet_yet',
            'skillAtomId': 'action_read',
            'decisionTimeBucket': '3_to_10s',
            'resultKind': 'incorrect',
            'runId': 'run_v1|world_1|fold_check_call_raise|lesson|1',
            'runKind': 'lesson',
            'runOrdinal': 1,
            'startedBy': 'learn_route',
            'sessionId': 'session_v1|1',
            'recordedAtUtc': now
                .subtract(const Duration(days: 2))
                .toIso8601String(),
            'reviewKind': 'initialAssessment',
          },
          <String, Object>{
            'schemaVersion': 1,
            'recordId':
                'v1|world_1|fold_check_call_raise|actions_check_drill|actionList|check|2',
            'createdOrder': 2,
            'worldId': 'world_1',
            'lessonId': 'fold_check_call_raise',
            'taskId': 'actions_check_drill',
            'sourceTaskId': 'actions_check_drill',
            'choiceId': 'check',
            'expectedChoiceId': 'check',
            'isCorrect': true,
            'errorType': 'none',
            'conceptFamilyId': 'no_bet_yet',
            'repairFocusId': 'no_bet_yet',
            'skillAtomId': 'action_read',
            'decisionTimeBucket': 'under_3s',
            'resultKind': 'correct',
            'runId': 'run_v1|world_1|fold_check_call_raise|repair|2',
            'runKind': 'repair',
            'runOrdinal': 2,
            'startedBy': 'review_repair',
            'sessionId': 'session_v1|1',
            'recordedAtUtc': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'reviewKind': 'immediateRepair',
            'assistanceKind': 'none',
          },
        ],
      }),
    });

    Future<void> mountReview(DateTime at) async {
      await tester.pumpWidget(
        MaterialApp(
          key: ValueKey(at),
          home: Act0ShellPreviewScreenV1(
            initialTab: Act0ShellTabV1.review,
            showPlacementOnStart: false,
            clock: Act0FixedUtcClockV1(at),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final dueCard = act0ShellPresentationFinderV1(
      'act0_shell_review_due_spaced_item',
    );
    final startReview = act0ShellPresentationFinderV1(
      'act0_shell_review_start_due_spaced_item',
    );
    Future<Act0LessonRunnerShellV1> start() async {
      expect(dueCard, findsOneWidget);
      await tester.ensureVisible(startReview);
      await tester.tap(startReview);
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, 'actions_check_drill');
      expect(runner.reviewKindId, 'spacedReview');
      expect(
        runner.evidenceRunId,
        startsWith('run_v1|world_1|fold_check_call_raise|spaced_review|'),
      );
      return runner;
    }

    Future<Map<String, dynamic>> saved() async {
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      return jsonDecode(prefs.getString('act0_shell_progress_v1')!)
          as Map<String, dynamic>;
    }

    const oneSecond = Duration(seconds: 1);
    await mountReview(now.subtract(oneSecond));
    expect(dueCard, findsNothing);

    await mountReview(now);
    await start();
    final runnerBack = find.byKey(const Key('act0_shell_runner_back'));
    await tester.tap(
      runnerBack.evaluate().isNotEmpty
          ? runnerBack
          : find.widgetWithText(TextButton, 'Back'),
    );
    await tester.pumpAndSettle();
    expect(dueCard, findsOneWidget);

    final day2Runner = await start();
    await tester.tap(find.byKey(const Key('act0_shell_option_check')));
    await tester.pumpAndSettle();
    final backToReview = find.byKey(
      const Key('act0_shell_feedback_continue_cta'),
    );
    final continueReview = tester
        .widget<Act0LessonRunnerShellV1>(find.byType(Act0LessonRunnerShellV1))
        .onContinueReview;
    await tester.ensureVisible(backToReview);
    await tester.tap(backToReview);
    continueReview(); // A second tap before the next frame cannot complete a lesson task.
    await tester.pumpAndSettle();
    expect(dueCard, findsNothing);

    final day7 = now.add(const Duration(days: 5));
    final day2Saved = await saved();
    final day2Family =
        (day2Saved['durableRetentionHistory'] as List).single as Map;
    expect(day2Family['nextDueAtUtc'], day7.toIso8601String());
    expect(day2Family['spacedSuccessStage'], 1);
    expect(day2Saved['selectedTaskId'], 'what_poker_is_pot_stack');
    expect(day2Saved['earnedXp'], 0);
    expect(day2Saved['completedTaskIds'], isEmpty);

    await mountReview(day7.subtract(oneSecond));
    expect(dueCard, findsNothing);
    await mountReview(day7);
    final day7Runner = await start();
    expect(day7Runner.evidenceRunId, isNot(day2Runner.evidenceRunId));
    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pumpAndSettle();

    final day7Saved = await saved();
    final evidence = day7Saved['learningEvidenceHistory'] as List;
    final recordIds = [for (final record in evidence) record['recordId']];
    expect(recordIds.toSet(), hasLength(4));
    expect(recordIds.last, startsWith('v3|${day7Runner.evidenceRunId}|'));
    expect(recordIds.last, endsWith('|actionList|fold|1'));
    final day7Family =
        (day7Saved['durableRetentionHistory'] as List).single as Map;
    expect(day7Family['lastReviewKind'], 'spacedReview');
    expect(day7Family['retentionState'], 'lapsed');
    expect(
      day7Family['nextDueAtUtc'],
      day7.add(const Duration(days: 1)).toIso8601String(),
    );
    expect(day7Saved['resumeInRunner'], isFalse);
    expect(day7Saved['earnedXp'], 0);
    expect(day7Saved['completedTaskIds'], isEmpty);
  });
}
