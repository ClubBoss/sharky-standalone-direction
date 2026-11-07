// Source/widget checks only. These do not establish native restart or Human value.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_consumer_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_achievement_seed_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

final _task = Act0ShellStateV1.sample
    .lessonById('fold_check_call_raise')
    .taskList
    .singleWhere((task) => task.taskId == 'actions_check_drill');

Act0CompletedDecisionV1 _decision({
  bool correct = true,
  Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  int order = 1,
}) {
  final option = _task.runner.options.firstWhere((o) => o.isCorrect == correct);
  final expected = _task.runner.options.singleWhere((o) => o.isCorrect);
  final receipt = act0FirstValueSkillReceiptForRunnerV1(
    runner: _task.runner,
    option: option,
    taskFamily: _task.resolvedTaskFamily,
  )!;
  return Act0CompletedDecisionV1(
    attemptKey: 'eng02|$order',
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: _task.taskId,
    sourceTaskId: _task.taskId,
    decisionKind: Act0CompletedDecisionKindV1.actionList,
    selectedId: option.id,
    expectedId: expected.id,
    isCorrect: correct,
    decisionTimeBucket: '3_to_10s',
    taskFamily: _task.resolvedTaskFamily,
    resultKind: correct ? 'correct' : 'incorrect',
    errorType: correct ? 'none' : 'missed_action_read',
    skillAtomId: receipt.skillAtomId,
    repairFocusId: receipt.sourceSignalId,
    assistanceKind: assistance,
  );
}

Act0LearningEvidenceHistoryV1 _history(
  List<Act0CompletedDecisionV1> decisions, {
  bool grouped = false,
}) => Act0LearningEvidenceHistoryV1(
  records: [
    for (var i = 0; i < decisions.length; i++)
      act0LearningEvidenceRecordFromCompletedDecisionV1(
        decisions[i],
        createdOrder: i + 1,
        authoredSourceFingerprint: act0AuthoredSourceFingerprintV1(
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          task: _task,
        )!,
        runKey: grouped
            ? const Act0EvidenceRunKeyV1(
                runId: 'eng02|run|1',
                worldId: 'world_1',
                lessonId: 'fold_check_call_raise',
                runOrdinal: 1,
                runKind: 'lesson',
                startedBy: 'learn',
              )
            : null,
      )!,
  ],
);

Act0AchievementSeedConsumerV1 _consumer({
  Act0LearningEvidenceHistoryV1 history = const Act0LearningEvidenceHistoryV1(),
  Act0ReviewMistakeHistoryV1 mistakes = const Act0ReviewMistakeHistoryV1(),
}) => Act0AchievementSeedConsumerV1.fromProjection(
  Act0AchievementSeedProjectionV1.fromSources(
    learningEvidenceHistory: history,
    reviewMistakeHistory: mistakes,
  ),
);

void main() {
  test('opening without an answer earns no moment', () {
    expect(_consumer().moments, isEmpty);
  });

  for (final assistance in Act0DecisionAssistanceV1.values) {
    test('first correct read preserves ${assistance.name} provenance', () {
      final decision = _decision(assistance: assistance);
      final history = _history([decision]);
      expect(
        act0CurrentAuthoredSourceProofV1(
          history.records.single,
        )?.isCurrentlyCorrect,
        isTrue,
      );
      final labels = _consumer(history: history).moments.map((m) => m.label);
      expect(
        labels.contains('First correct read'),
        assistance == Act0DecisionAssistanceV1.none,
      );
      expect(history.records.single.assistanceKind, assistance);
    });
  }

  test('a source-proven miss stays repair debt and earns no moment', () {
    final decision = _decision(correct: false);
    final history = _history([decision]);
    final mistakes = const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
      decision,
    );
    expect(
      act0CurrentAuthoredSourceProofV1(
        history.records.single,
      )?.isCurrentlyCorrect,
      isFalse,
    );
    expect(mistakes.records, hasLength(1));
    expect(_consumer(history: history, mistakes: mistakes).moments, isEmpty);
    // Filtering presentation must preserve the original wrong action and debt.
    expect(history.records.single.choiceId, decision.selectedId);
    expect(mistakes.records.single.selectedId, decision.selectedId);
  });

  test('a grouped answer proves recorded practice, not session completion', () {
    final history = _history([_decision(correct: false)], grouped: true);
    final labels = _consumer(history: history).moments.map((m) => m.label);
    expect(labels, ['First practice recorded']);
    expect(labels, isNot(contains('First session complete')));
    expect(history.latestRunSummary()!.spotsPlayed, 1);
    expect(history.records.single.isCorrect, isFalse);
  });

  test('open debt cannot consume the cap ahead of factual achievements', () {
    final decision = _decision(correct: false);
    final projection = Act0AchievementSeedProjectionV1.fromSources(
      learningEvidenceHistory: _history([
        decision,
        _decision(order: 2),
      ], grouped: true),
      reviewMistakeHistory: const Act0ReviewMistakeHistoryV1()
          .appendCompletedDecision(decision),
      profileStreakDays: 3,
    );
    expect(
      Act0AchievementSeedConsumerV1.fromProjection(
        projection,
      ).moments.map((m) => m.seedId),
      [
        // Run ordinal 1 sorts before the first correct answer at order 2.
        act0AchievementSeedFirstSessionCompleteV1,
        act0AchievementSeedFirstCorrectReadV1,
        act0AchievementSeedThreeDayStreakV1,
      ],
    );
  });

  for (final helped in [false, true]) {
    testWidgets(
      '${helped ? "helped" : "independent"} answer and repeated taps keep one factual moment',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(393, 852));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final attempts = <Act0CompletedDecisionV1>[];
        await tester.pumpWidget(
          MaterialApp(
            home: Act0LessonRunnerShellV1(
              runner: _task.runner.copyWith(
                phase: Act0LessonPhaseV1.drill,
                teachingSteps: const <Act0TeachingStepV1>[],
              ),
              selectedWorldId: 'world_1',
              selectedLessonId: 'fold_check_call_raise',
              selectedTaskId: _task.taskId,
              selectedTaskFamily: _task.resolvedTaskFamily,
              theoryRecallStep: Act0TeachingStepV1(
                title: 'Action rule',
                body: _task.runner.hint,
              ),
              onBack: () {},
              onContinueTheory: () {},
              onChooseOption: (_) {},
              onContinueReview: () {},
              onCompletedDecision: attempts.add,
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (helped) {
          await tester.tap(
            find.byKey(const Key('act0_shell_theory_recall_cta')),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.byKey(const Key('act0_shell_theory_recall_close_cta')),
          );
          await tester.pumpAndSettle();
        }
        final choice = find.byKey(const Key('act0_shell_option_check'));
        await tester.tap(choice);
        await tester.tap(choice);
        await tester.pumpAndSettle();
        expect(attempts, hasLength(1));
        expect(
          attempts.single.assistanceKind,
          helped
              ? Act0DecisionAssistanceV1.quickHint
              : Act0DecisionAssistanceV1.none,
        );
        final history = _history(attempts);
        expect(
          _consumer(history: history).moments.map((m) => m.label),
          helped ? isEmpty : ['First correct read'],
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Summary never presents an unresolved miss as collected read', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final decision = _decision(correct: false);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Act0BlockCompletionShellV1(
            summary: const Act0BlockCompletionSummaryV1(
              lessonTitle: 'Action words',
              xpEarned: 0,
              errorCount: 1,
              taskCount: 1,
              correctCount: 0,
              startLevel: 1,
              endLevel: 1,
              startXp: 0,
              endXp: 0,
              xpTarget: 200,
            ),
            firstCorrectEarnedThisRun: false,
            earnedMomentConsumer: _consumer(
              history: _history([decision]),
              mistakes: const Act0ReviewMistakeHistoryV1()
                  .appendCompletedDecision(decision),
            ),
            onContinue: () {},
            onReplay: () {},
            onBackToMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('act0_shell_block_summary_earned_moment')),
      findsNothing,
    );
    expect(find.text('Back to the spot'), findsNothing);
    expect(find.text('One miss to fix'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
