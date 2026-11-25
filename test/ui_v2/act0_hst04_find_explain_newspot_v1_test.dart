import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_action_reason_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_archive_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_attempt_replay_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/act0_shell_presentation_finders_v1.dart';

void main() {
  testWidgets('Review finds a finished attempt and opens its recorded replay', (
    tester,
  ) async {
    const worldId = 'world_4';
    const lessonId = 'call_price';
    const taskId = 'w4_good_price_call';
    final lesson = Act0ShellStateV1.sample
        .worldById(worldId)
        .lessons
        .singleWhere((lesson) => lesson.lessonId == lessonId);
    final task = lesson.taskList.singleWhere((task) => task.taskId == taskId);

    // Simulate a finished decision in a saved archive so the scenario starts at
    // Review. Assert the app's rendered copy separately from these inputs.
    const reason = '25% beats the 11.1% needed to call.';
    final evidence = Act0LearningEvidenceRecordV1(
      recordId: 'hst04-finished-call',
      createdOrder: 1,
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
      choiceId: 'call',
      expectedChoiceId: 'call',
      isCorrect: true,
      errorType: 'none',
      repairFocusId: 'pot',
      skillAtomId: 'call_price',
      decisionTimeBucket: 'under_3s',
      resultKind: 'correct',
      authoredSourceFingerprint: act0AuthoredSourceFingerprintV1(
        worldId: worldId,
        lessonId: lessonId,
        task: task,
      )!,
      recordedAtUtc: DateTime.utc(2026, 11, 24, 10),
      assistanceKind: Act0DecisionAssistanceV1.none,
    );
    final attempt = Act0ArchivedAttemptV1.fromRecordedDecision(
      evidence,
      taskLabel: task.runner.question,
      choiceLabel: 'Call',
      recordedTrail: [
        ...task.runner.table.actionTrail,
        const Act0ActionTrailItemV1.note(label: 'Your choice: Call'),
      ],
      actionReason: const Act0ActionReasonResultV1(
        true,
        Act0ReasonV1(
          reason,
          Act0ReasonGradeV1.sound,
          Act0MisconceptionTagV1.price,
        ),
      ),
    )!;
    final history = Act0LearningEvidenceHistoryV1(records: [evidence]);
    final archive = const Act0AttemptArchiveV1.empty().add(attempt);
    final firstWorld = Act0ShellStateV1.sample.worlds.first;
    final firstLesson = firstWorld.lessons.first;
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      'act0_shell_progress_v1': jsonEncode({
        'schemaVersion': 20,
        'completedTaskIds': <String>[],
        'completedLessonIds': <String>[],
        'skippedTaskIds': <String>[],
        'earnedXp': 0,
        'selectedWorldId': firstWorld.worldId,
        'selectedLessonId': firstLesson.lessonId,
        'selectedTaskId': firstLesson.courseTaskList.first.taskId,
        'pendingDecisionAssistance': <Object>[],
        'durableRetentionHistory': <Object>[],
        'learningEvidenceHistory': history.toPayload(),
        'learningEvidenceLineage': history.lineagePayload(),
        'attemptArchive': archive.toPayload(snapshotRecords: history.records),
      }),
    });

    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        locale: const Locale('en'),
        home: const Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.review,
          showPlacementOnStart: false,
          enableBetaMetrics: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tap(String key) async {
      final target = act0ShellPresentationFinderV1(key);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      expect(target.hitTestable(), findsOneWidget, reason: 'Tap $key');
      await tester.tap(target.hitTestable());
      await tester.pumpAndSettle();
    }

    await tap('act0_review_open_attempts');
    final search = find.byKey(const Key('act0_attempt_archive_search'));
    final rowKey = 'act0_attempt_archive_entry_${attempt.id}';
    await tester.enterText(search, 'no matching attempt');
    await tester.pumpAndSettle();
    expect(find.text('No matching attempts.'), findsOneWidget);
    expect(find.byKey(Key(rowKey)), findsNothing);

    await tester.enterText(search, '  GOOD_PRICE_CALL  ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tap(rowKey);

    // The archive row renders the recorded reason. With no completed drill
    // in the pool, the replay must not promise same-skill practice.
    final recordedReason = find.text(
      'Reason: 25% beats the 11.1% needed to call. · Call price',
    );
    await tester.ensureVisible(recordedReason);
    await tester.pumpAndSettle();
    expect(recordedReason.hitTestable(), findsOneWidget);

    await tap('act0_attempt_archive_open_replay');
    final replay = find.byType(Act0AttemptReplayScreenV1);
    final replayed = tester.widget<Act0AttemptReplayScreenV1>(replay).attempt!;
    expect(replayed.id, attempt.id);
    expect(find.text('Practise this spot'), findsNothing);
    expect(
      replayed.actionReason?.toPayload(),
      attempt.actionReason!.toPayload(),
    );
    final steps = attempt.events.length;
    expect(find.text('Start · 1 of $steps'), findsOneWidget);
    expect(
      steps,
      inInclusiveRange(1, 40),
      reason: 'Replay scenario is capped at 40 taps.',
    );
    for (var step = 0; step < steps; step++) {
      await tap('act0_attempt_replay_next');
    }
    final decision = find.descendant(
      of: replay,
      matching: find.byKey(const Key('act0_attempt_replay_current_event')),
    );
    await tester.ensureVisible(decision);
    await tester.pumpAndSettle();
    expect(decision.hitTestable(), findsOneWidget);
    expect(tester.widget<Text>(decision).data, 'Your choice: Call');
  });

  testWidgets('Replay miss launches its resolved drill and returns to replay', (
    tester,
  ) async {
    const worldId = 'world_1';
    const lessonId = 'what_poker_is';
    const sourceId = 'what_poker_is_find_hero';
    const targetId = 'first_table_guide_one_clear_choice';
    const progressKey = 'act0_shell_progress_v1';
    final lesson = Act0ShellStateV1.sample.lessonById(lessonId);
    final source = lesson.taskList.singleWhere(
      (task) => task.taskId == sourceId,
    );
    final evidence = Act0LearningEvidenceRecordV1(
      recordId: 'hst04-replayed-miss',
      createdOrder: 1,
      worldId: worldId,
      lessonId: lessonId,
      taskId: sourceId,
      choiceId: 'top',
      expectedChoiceId: 'bottom',
      isCorrect: false,
      errorType: 'confused_table_identity',
      repairFocusId: 'hero_button',
      skillAtomId: 'table_position_read',
      decisionTimeBucket: 'under_3s',
      resultKind: 'incorrect',
      authoredSourceFingerprint: act0AuthoredSourceFingerprintV1(
        worldId: worldId,
        lessonId: lessonId,
        task: source,
      )!,
      recordedAtUtc: DateTime.utc(2026, 11, 24, 10),
      assistanceKind: Act0DecisionAssistanceV1.none,
    );
    final attempt = Act0ArchivedAttemptV1.fromRecordedDecision(
      evidence,
      recordedTrail: const [
        Act0ActionTrailItemV1.note(label: 'Your choice: Top'),
      ],
    )!;
    final history = Act0LearningEvidenceHistoryV1(records: [evidence]);
    final archive = const Act0AttemptArchiveV1.empty().add(attempt);
    SharedPreferences.setMockInitialValues({
      'act0_welcome_completed_v1': true,
      'intake_completed_v1': true,
      progressKey: jsonEncode({
        'schemaVersion': 20,
        // Only the other completed drill is eligible; the miss is a replay of
        // an already-completed source and must not resolve to itself.
        'completedTaskIds': ['what_poker_is_theory', sourceId, targetId],
        'completedLessonIds': <String>[],
        'skippedTaskIds': <String>[],
        'earnedXp': 15,
        'selectedWorldId': worldId,
        'selectedLessonId': lessonId,
        'selectedTaskId': targetId,
        'pendingDecisionAssistance': <Object>[],
        'learningEvidenceHistory': history.toPayload(),
        'learningEvidenceLineage': history.lineagePayload(),
        'attemptArchive': archive.toPayload(snapshotRecords: history.records),
      }),
    });
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        locale: const Locale('en'),
        home: const Act0ShellPreviewScreenV1(
          initialTab: Act0ShellTabV1.review,
          showPlacementOnStart: false,
          enableBetaMetrics: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    Future<void> tap(String key) async {
      final target = act0ShellPresentationFinderV1(key);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      expect(target.hitTestable(), findsOneWidget, reason: 'Tap $key');
      await tester.tap(target.hitTestable());
      await tester.pumpAndSettle();
    }

    await tap('act0_review_open_attempts');
    await tap('act0_attempt_archive_entry_${attempt.id}');
    await tap('act0_attempt_archive_open_replay');
    await tap('act0_attempt_replay_next');
    expect(find.text('Practise this spot'), findsOneWidget);
    final replay = find.byType(Act0AttemptReplayScreenV1);
    final runner = find.byType(Act0LessonRunnerShellV1);
    const practiceKey = 'act0_attempt_replay_practise_spot';
    await tap(practiceKey);
    expect(
      tester.widget<Act0LessonRunnerShellV1>(runner).selectedTaskId,
      targetId,
    );
    expect(
      tester.widget<Act0LessonRunnerShellV1>(runner).isRepairAttempt,
      isTrue,
    );
    await tap('act0_shell_runner_back');
    expect(
      tester.widget<Act0AttemptReplayScreenV1>(replay).attempt!.id,
      attempt.id,
    );

    // Completing the drill also returns to its originating replay, without
    // credit for a first-try answer or moving to a different lesson task.
    await tap(practiceKey);
    await tap('act0_shell_option_hero_btn_preflop_setup');
    await tap('act0_shell_feedback_continue_cta');
    expect(
      tester.widget<Act0AttemptReplayScreenV1>(replay).attempt!.id,
      attempt.id,
    );
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString(progressKey)!) as Map;
    final records = (saved['learningEvidenceHistory'] as List)
        .map(Act0LearningEvidenceRecordV1.tryParse)
        .whereType<Act0LearningEvidenceRecordV1>();
    final result = records.singleWhere((record) => record.taskId == targetId);
    expect(result.isCorrect, isTrue);
    expect(result.isRepaired, isTrue);
    expect(result.isIndependentCorrect, isFalse);
    expect(result.resultKind, act0RepairedResultKindV1);
    expect(saved['earnedXp'], 15);
  });
}
