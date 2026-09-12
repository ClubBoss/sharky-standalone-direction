import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('due Review item launches the existing canonical runner', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 7, 18, 12);
    SharedPreferences.setMockInitialValues(<String, Object>{
      'act0_shell_progress_v1': jsonEncode(<String, Object>{
        'schemaVersion': 17,
        'completedTaskIds': <String>[],
        'skippedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'selectedWorldId': 'world_1',
        'selectedLessonId': 'fold_check_call_raise',
        'selectedTaskId': 'actions_check_drill',
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
          },
        ],
        'durableRetentionHistory': <Object>[
          <String, Object>{
            'schemaVersion': 1,
            'conceptFamilyId': 'no_bet_yet',
            'worldId': 'world_1',
            'sourceLessonId': 'fold_check_call_raise',
            'sourceTaskId': 'actions_check_drill',
            'retentionState': 'recoveredPendingSpacedReview',
            'nextDueAtUtc': now
                .subtract(const Duration(minutes: 1))
                .toIso8601String(),
            'spacedSuccessStage': 0,
            'lapseCount': 0,
            'incorrectCount': 1,
            'correctCount': 1,
            'lastRecordedAtUtc': now
                .subtract(const Duration(days: 1))
                .toIso8601String(),
            'lastCreatedOrder': 2,
            'lastSessionId': 'session_v1|1',
            'lastReviewKind': 'immediateRepair',
            'hasLegacyUnspacedEvidence': false,
          },
        ],
      }),
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.review,
          showPlacementOnStart: false,
          clock: Act0FixedUtcClockV1(now),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const Key('act0_shell_review_due_spaced_item')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const Key('act0_shell_review_start_due_spaced_item')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('act0_shell_runner_screen')), findsOneWidget);
    final runner = tester.widget<Act0LessonRunnerShellV1>(
      find.byType(Act0LessonRunnerShellV1),
    );
    expect(runner.selectedTaskId, 'actions_check_drill');
    expect(runner.reviewKindId, 'spacedReview');
    expect(
      runner.evidenceRunId,
      startsWith(
        'run_v1|world_1|fold_check_call_raise|spaced_review|',
      ),
    );

    await tester.tap(find.byKey(const Key('act0_shell_option_fold')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final prefs = await SharedPreferences.getInstance();
    final stored =
        jsonDecode(prefs.getString('act0_shell_progress_v1')!)
            as Map<String, dynamic>;
    final evidence = stored['learningEvidenceHistory'] as List<dynamic>;
    final recordIds = evidence
        .map((record) => (record as Map<String, dynamic>)['recordId'] as String)
        .toList(growable: false);

    expect(evidence, hasLength(3));
    expect(
      recordIds.first,
      'v1|world_1|fold_check_call_raise|actions_check_drill|actionList|fold|1',
    );
    expect(
      recordIds.last,
      startsWith('v2|${runner.evidenceRunId}|'),
    );
    expect(recordIds.last, endsWith('|actionList|fold|1'));
    expect(recordIds.toSet(), hasLength(3));

    final retention =
        (stored['durableRetentionHistory'] as List<dynamic>).single
            as Map<String, dynamic>;
    expect(retention['incorrectCount'], 2);
    expect(retention['lastReviewKind'], 'spacedReview');
  });
}
