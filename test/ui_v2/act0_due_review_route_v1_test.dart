import '../support/act0_shell_presentation_finders_v1.dart';
import '../support/act0_source_choreography_test_wait_v1.dart';
import '../support/act0_day7_coverage_v1.dart';
import '../support/act0_table_truth_v1.dart'
    show actorFlagsConsistent, cardIdentity;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'World 1 review-only check hands have distinct valid checkpoints and unique grades',
    () {
      final lesson = Act0ShellStateV1.sample.worlds
          .singleWhere((world) => world.worldId == 'world_1')
          .lessons
          .singleWhere((lesson) => lesson.lessonId == 'fold_check_call_raise');
      final courseIds = lesson.taskList.map((task) => task.taskId).toSet();
      final reviewIds = <String>{};
      final seenBoards = <String>{};
      for (final entry in act0NewReviewTasksV1.where(
        (entry) =>
            entry.worldId == 'world_1' &&
            entry.lessonId == 'fold_check_call_raise' &&
            entry.conceptFamilyId == 'no_bet_yet',
      )) {
        final task = entry.task;
        final table = task.runner.table;
        expect(courseIds, isNot(contains(task.taskId)));
        expect(reviewIds.add(task.taskId), isTrue);
        expect(task.rewardXp, 0);
        expect(task.runner.hint, isEmpty);
        expect(task.runner.teachingSteps, isEmpty);
        expect(
          task.runner.options.singleWhere((option) => option.isCorrect).id,
          'check',
        );
        expect(actorFlagsConsistent(table), isTrue);
        expect(table.decisionSeatId, 'btn');
        expect(table.actionTrail.last.label, '${table.streetLabel}: BB checks');
        expect(table.toCallLabel, isEmpty);
        expect(table.potLabel, 'Pot 4.5 BB');
        expect(table.boardCards.length, table.streetLabel == 'Turn' ? 4 : 5);
        final cards = [
          ...table.heroCards,
          ...table.boardCards,
        ].map(cardIdentity);
        expect(cards.toSet(), hasLength(cards.length));
        expect(
          seenBoards.add(table.boardCards.map(cardIdentity).join(',')),
          isTrue,
        );
        expect(
          act0CurrentAuthoredSourceFingerprintForIdentityV1(
            worldId: entry.worldId,
            lessonId: entry.lessonId,
            taskId: task.taskId,
          ),
          isNotNull,
        );
      }
      expect(reviewIds, hasLength(2));
    },
  );

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
    Future<Act0LessonRunnerShellV1> start({
      String taskId = 'actions_check_drill',
      bool unseen = false,
    }) async {
      expect(dueCard, findsOneWidget);
      expect(
        find.text(unseen ? 'New situation' : 'Familiar situation'),
        findsOneWidget,
      );
      await tester.ensureVisible(startReview);
      await tester.tap(startReview);
      await tester.pumpAndSettle();
      final runner = tester.widget<Act0LessonRunnerShellV1>(
        find.byType(Act0LessonRunnerShellV1),
      );
      expect(runner.selectedTaskId, taskId);
      expect(runner.reviewKindId, unseen ? 'unseenTransfer' : 'spacedReview');
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
    const turnVariant = 'spaced_review_check_turn_v1';
    const riverVariant = 'spaced_review_check_river_v1';
    final turn = await start(taskId: turnVariant, unseen: true);
    expect(turn.runner.table.streetLabel, 'Turn');
    expect((await saved())['openedSpacedReviewTaskIds'], [turnVariant]);

    // Simulate termination before answering. The seen turn cannot return as new.
    await mountReview(day7.add(oneSecond));
    final day7Runner = await start(taskId: riverVariant, unseen: true);
    expect(day7Runner.runner.table.streetLabel, 'River');
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
    expect(day7Family['lastReviewKind'], 'unseenTransfer');
    expect(day7Family['retentionState'], 'lapsed');
    expect(
      day7Family['nextDueAtUtc'],
      day7.add(const Duration(days: 1, seconds: 1)).toIso8601String(),
    );
    expect(day7Saved['resumeInRunner'], isFalse);
    expect(day7Saved['earnedXp'], 0);
    expect(day7Saved['completedTaskIds'], isEmpty);

    await mountReview(day7.add(const Duration(days: 1, seconds: 1)));
    await start(taskId: riverVariant);
  });

  for (final (entry, savedFamily) in [
    for (final entry in act0Day7MissSourcesV1.entries.where(
      (entry) => day7MustBeCoveredV1(entry.key),
    )) ...[
      (entry, entry.key.$3),
      if (entry.key.$1 == 'world_6' &&
          entry.key.$3 == 'starting_hand_combinations')
        (entry, 'pot_to_call'),
    ],
  ]) {
    final (world, lesson, family) = entry.key;
    final fixture = savedFamily == family
        ? ''
        : ' from a saved $savedFamily review';
    testWidgets(
      'Day 7 opens a new task after Day 2 for $world/$lesson/$family$fixture',
      (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final source = entry.value.task;
        final correct = source.runner.options.singleWhere(
          (option) => option.isCorrect,
        );
        final day2 = DateTime.utc(2026, 11, 21, 12);
        final day7 = day2.add(const Duration(days: 5));

        Act0LearningEvidenceRecordV1 attempt(
          int order,
          Act0RunnerOptionV1 option,
          DateTime time,
        ) => Act0LearningEvidenceRecordV1(
          recordId: 'day7_fixture|${source.taskId}|$order',
          createdOrder: order,
          worldId: world,
          lessonId: lesson,
          taskId: source.taskId,
          sourceTaskId: source.taskId,
          choiceId: option.id,
          expectedChoiceId: correct.id,
          isCorrect: option.isCorrect,
          errorType: option.isCorrect ? 'none' : 'misread_table',
          conceptFamilyId: savedFamily,
          repairFocusId: savedFamily,
          skillAtomId: 'table_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: option.isCorrect ? 'correct' : 'incorrect',
          runId:
              'run_v1|$world|$lesson|${option.isCorrect ? 'repair' : 'lesson'}|$order',
          runKind: option.isCorrect ? 'repair' : 'lesson',
          runOrdinal: order,
          startedBy: option.isCorrect ? 'review_repair' : 'learn_route',
          sessionId: 'session_v1|1',
          recordedAtUtc: time,
          reviewKind: option.isCorrect
              ? Act0ReviewKindV1.immediateRepair
              : Act0ReviewKindV1.initialAssessment,
          assistanceKind: Act0DecisionAssistanceV1.none,
        );

        const progressKey = 'act0_shell_progress_v1';
        SharedPreferences.setMockInitialValues({
          progressKey: jsonEncode({
            'schemaVersion': 17,
            'completedTaskIds': <String>[],
            'skippedTaskIds': <String>[],
            'completedLessonIds': <String>[],
            'selectedWorldId': 'world_1',
            'selectedLessonId': 'what_poker_is_content',
            'selectedTaskId': 'what_poker_is_pot_stack',
            'earnedXp': 0,
            'learningEvidenceHistory': [
              attempt(
                1,
                entry.value.miss,
                day2.subtract(const Duration(days: 2)),
              ).toPayload(),
              attempt(
                2,
                correct,
                day2.subtract(const Duration(days: 1)),
              ).toPayload(),
            ],
          }),
        });

        Future<Act0LessonRunnerShellV1> openDue(
          DateTime time,
          String label,
        ) async {
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey(time),
              home: Act0ShellPreviewScreenV1(
                initialTab: Act0ShellTabV1.review,
                showPlacementOnStart: false,
                clock: Act0FixedUtcClockV1(time),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(label), findsOneWidget);
          final button = act0ShellPresentationFinderV1(
            'act0_shell_review_start_due_spaced_item',
          );
          await tester.ensureVisible(button);
          await tester.tap(button);
          await tester.pumpAndSettle();
          return tester.widget<Act0LessonRunnerShellV1>(
            find.byType(Act0LessonRunnerShellV1),
          );
        }

        Future<void> answer(
          Act0LessonRunnerShellV1 shell,
          Act0RunnerOptionV1 option,
        ) async {
          await pumpSourceChoreographyToDecisionV1(tester, shell.runner.table);
          final candidates = [
            if (shell.runner.sizingConfig.isEnabled)
              find.byKey(Key('act0_shell_sizing_preset_${option.id}')),
            find.byKey(Key('act0_shell_option_${option.id}')),
            if (option.seatId != null)
              find.byKey(Key('act0_shell_seat_tap_${option.seatId}')),
          ];
          final button = candidates.firstWhere(
            (candidate) => candidate.evaluate().isNotEmpty,
          );
          await tester.ensureVisible(button.first);
          await tester.tap(button.first);
          await tester.pumpAndSettle();
          if (shell.runner.sizingConfig.isEnabled) {
            final confirm = find.byKey(
              const Key('act0_shell_sizing_confirm_cta'),
            );
            await tester.ensureVisible(confirm);
            await tester.tap(confirm);
            await tester.pumpAndSettle();
          }
          final continueButton = find.byKey(
            const Key('act0_shell_feedback_continue_cta'),
          );
          if (continueButton.evaluate().isNotEmpty) {
            await tester.ensureVisible(continueButton);
            await tester.tap(continueButton);
            await tester.pumpAndSettle();
          }
        }

        final familiar = await openDue(day2, 'Familiar situation');
        expect(familiar.selectedTaskId, source.taskId);
        expect(familiar.reviewKindId, 'spacedReview');
        await answer(familiar, correct);

        final unseen = await openDue(day7, 'New situation');
        expect(unseen.selectedTaskId, isNot(source.taskId));
        expect(unseen.reviewKindId, 'unseenTransfer');
        expect(
          act0NewReviewConceptFamilyV1(world, lesson, unseen.selectedTaskId!),
          family,
        );
        await answer(
          unseen,
          unseen.runner.options.singleWhere((option) => option.isCorrect),
        );
        final prefs = await SharedPreferences.getInstance();
        final saved =
            jsonDecode(prefs.getString(progressKey)!) as Map<String, dynamic>;
        final evidence = (saved['learningEvidenceHistory'] as List).last as Map;
        expect(evidence['taskId'], unseen.selectedTaskId);
        expect(evidence['conceptFamilyId'], family);
        expect(evidence['reviewKind'], 'unseenTransfer');
        expect(evidence['assistanceKind'], 'none');
        expect(evidence['isCorrect'], isTrue);
        expect(saved['earnedXp'], 0);
        expect(saved['completedTaskIds'], isEmpty);
      },
    );
  }
}
