import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample
    .lessonById('decision_over_outcome')
    .taskList
    .singleWhere((task) => task.taskId == id);

void main() {
  final losingFold = _task('w12_good_fold_bad_result');
  final luckyCall = _task('w12_bad_call_good_result');

  test(
    'source-owned opposite outcome stories preserve process-first grading',
    () {
      expect(
        losingFold.runner.caption,
        contains('villain later showed a bluff'),
      );
      expect(luckyCall.runner.caption, contains('got lucky on river'));
      expect(losingFold.runner.question, contains('losing fold'));
      expect(luckyCall.runner.question, contains('mindset response'));

      for (final pair in <(Act0LessonTaskV1, String, String)>[
        (losingFold, 'process_review', 'instant_regret'),
        (luckyCall, 'flag_leak', 'celebrate_only'),
      ]) {
        final (task, processChoice, outcomeBiasChoice) = pair;
        final options = task.runner.options;
        final process = options.singleWhere((o) => o.id == processChoice);
        final biased = options.singleWhere((o) => o.id == outcomeBiasChoice);
        expect(process.isCorrect, isTrue, reason: task.taskId);
        expect(process.quality, Act0FeedbackQualityV1.correct);
        expect(biased.isCorrect, isFalse, reason: task.taskId);
        expect(biased.quality, Act0FeedbackQualityV1.wrong);
        expect(biased.feedbackReason, isNotEmpty);
        expect(process.feedbackReason, isNotEmpty);
        expect(options.where((o) => o.isCorrect), hasLength(1));
      }
    },
  );

  Future<Act0CompletedDecisionV1> choose(
    WidgetTester tester, {
    required Act0LessonTaskV1 task,
    required String choiceId,
    String? alternateSourceOutcomeCaption,
  }) async {
    final completions = <Act0CompletedDecisionV1>[];
    final chosen = <Act0RunnerOptionV1>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Act0LessonRunnerShellV1(
          // These drills inherit one source-owned teaching step from the W12
          // intro. Exercise the decision stage after that actual teaching
          // step is completed; do not remove teaching from production.
          runner: task.runner.copyWith(
            teachingStepIndex: task.runner.teachingSteps.length,
            caption: alternateSourceOutcomeCaption ?? task.runner.caption,
          ),
          selectedWorldId: 'world_12',
          selectedLessonId: 'decision_over_outcome',
          selectedTaskId: task.taskId,
          selectedTaskFamily: task.resolvedTaskFamily,
          onBack: () {},
          onContinueTheory: () {},
          onChooseOption: chosen.add,
          onCompletedDecision: completions.add,
          onContinueReview: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    final control = find.byKey(Key('act0_shell_option_$choiceId'));
    expect(control, findsOneWidget, reason: task.taskId);
    await tester.ensureVisible(control);
    await tester.tap(control);
    await tester.pump();
    expect(chosen, hasLength(1), reason: task.taskId);
    expect(completions, hasLength(1), reason: task.taskId);
    final result = completions.single;
    expect(result.taskId, task.taskId);
    expect(result.selectedId, choiceId);
    expect(
      result.expectedId,
      task.runner.options.singleWhere((o) => o.isCorrect).id,
    );
    expect(result.isCorrect, chosen.single.isCorrect);
    return result;
  }

  testWidgets('real W12 runner and evidence keep wins separate from grading', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final pair in <(Act0LessonTaskV1, String, bool)>[
      (losingFold, 'process_review', true),
      (losingFold, 'instant_regret', false),
      (luckyCall, 'flag_leak', true),
      (luckyCall, 'celebrate_only', false),
    ]) {
      final (task, choiceId, correct) = pair;
      final result = await choose(tester, task: task, choiceId: choiceId);
      expect(result.isCorrect, correct, reason: task.taskId);
      expect(result.resultKind, correct ? 'correct' : 'incorrect');
      expect(result.errorType, correct ? 'none' : isNot('none'));
      final evidence = act0LearningEvidenceRecordFromCompletedDecisionV1(
        result,
        createdOrder: 1,
      );
      expect(evidence, isNotNull, reason: task.taskId);
      expect(evidence!.isCorrect, correct);
      expect(evidence.resultKind, correct ? 'correct' : 'incorrect');
      expect(evidence.taskId, task.taskId);
      expect(evidence.choiceId, choiceId);
      expect(
        Act0LearningEvidenceRecordV1.tryParse(evidence.toPayload()),
        evidence,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets(
    'synthetic result-only caption swap never reverses decision grade',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(393, 852));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      // This deliberately swaps only two existing source captions to falsify a
      // result-driven grading dependency. It is NOT a coherent poker hand or
      // production content and must not be counted as gameplay truth.
      final before = await choose(
        tester,
        task: losingFold,
        choiceId: 'process_review',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      final after = await choose(
        tester,
        task: losingFold,
        choiceId: 'process_review',
        alternateSourceOutcomeCaption: luckyCall.runner.caption,
      );
      expect(after.isCorrect, before.isCorrect);
      expect(after.resultKind, before.resultKind);
      expect(after.expectedId, before.expectedId);
      await tester.pumpWidget(const SizedBox.shrink());
      final badBefore = await choose(
        tester,
        task: luckyCall,
        choiceId: 'celebrate_only',
      );
      await tester.pumpWidget(const SizedBox.shrink());
      final badAfter = await choose(
        tester,
        task: luckyCall,
        choiceId: 'celebrate_only',
        alternateSourceOutcomeCaption: losingFold.runner.caption,
      );
      expect(badAfter.isCorrect, isFalse);
      expect(badAfter.isCorrect, badBefore.isCorrect);
      expect(badAfter.resultKind, badBefore.resultKind);
    },
  );
}
