import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_asm05_authored_decision_truth_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// OUTPUT-ONLY ADMISSION PROPOSAL, NOT_RUN. Uses actual user-choice callbacks.
// This harness does not certify canonical Preview entry, native clipping,
// accessibility non-disclosure, or durable restart behavior.
void main() {
  final lesson = Act0ShellStateV1.sample.worldById('world_12').lessons
      .singleWhere((l) => l.lessonId == 'decision_over_outcome');

  test('two new cases occupy their exact existing lesson slots', () {
    expect(lesson.taskList.map((t) => t.taskId), [
      'w12_decision_quality_intro', 'w12_good_fold_bad_result',
      'w12_bad_call_good_result', 'asm05_new_known_holes_turn_call_10',
      'asm05_new_known_holes_turn_call_40', 'w12_decision_quality_recap',
    ]);
    expect(lesson.rewardXp, 45);
    for (final task in lesson.taskList.skip(3).take(2)) {
      expect(task.rewardXp, 0);
      expect(task.resolvedTaskFamily, Act0TaskFamilyV1.decision);
      expect(task.runner.lessonId, 'decision_over_outcome');
      expect(task.runner.beatIndex, task.taskId.endsWith('_10') ? 4 : 5);
      expect(task.runner.beatCount, 6);
      for (final option in task.runner.options) {
        final receipt = act0FirstValueSkillReceiptForRunnerV1(
          runner: task.runner, option: option, taskFamily: task.resolvedTaskFamily,
        );
        expect(receipt, isNotNull);
        expect(receipt!.sourceSignalId, 'process_over_outcome');
        expect(receipt.skillAtomId, 'mindset_process_discipline');
        expect(act0FirstValueSkillReceiptForRunnerV1(
          runner: task.runner.copyWith(lessonId: 'unadmitted_lesson'),
          option: option, taskFamily: task.resolvedTaskFamily,
        ), isNull);
      }
    }
  });

  for (final price in [10, 40]) {
    for (final choice in ['call_Td', 'call_5h', 'fold_5h']) {
      testWidgets('actual callback $price $choice preserves decision truth', (tester) async {
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final action = choice.split('_').first;
        final river = choice.split('_').last;
        final canonical = lesson.taskList.singleWhere(
          (t) => t.taskId == 'asm05_new_known_holes_turn_call_$price',
        );
        final isCanonicalRunout = price == 10 ? river == 'Td' : river == '5h';
        // Counterfactuals use the SAME real source factory and actual poker
        // evaluator. They do not flip captions or mutate grades.
        final task = isCanonicalRunout ? canonical : act0Asm05AuthoredDecisionTaskV1(
          exercise: Act0Asm05AuthoredExerciseV1(
            preDecision: price == 10 ? const Act0Asm05TurnSnapshotV1.call10()
                : const Act0Asm05TurnSnapshotV1.call40(),
            realizedRiver: river,
          ),
          lessonId: lesson.lessonId, lessonTitle: lesson.title,
          beatIndex: price == 10 ? 4 : 5, beatCount: 6, rewardXp: 0,
          returnTarget: 'learn', nextLessonId: 'tilt_reset_protocol',
        );
        var runner = task.runner;
        final completions = <Act0CompletedDecisionV1>[];
        var choices = 0;
        await tester.pumpWidget(MaterialApp(home: StatefulBuilder(
          builder: (context, setState) => Act0LessonRunnerShellV1(
            runner: runner, worldNumber: 12, selectedWorldId: 'world_12',
            selectedLessonId: lesson.lessonId, selectedTaskId: task.taskId,
            selectedTaskFamily: task.resolvedTaskFamily,
            tablePresentation: task.tablePresentation,
            evidenceRunId: 'asm05_machine_${price}_$choice',
            onBack: () {}, onContinueTheory: () {}, onContinueReview: () {},
            onChooseOption: (option) {
              choices++;
              // Public user-choice callback drives feedback, as Preview does.
              setState(() => runner = runner.copyWith(
                phase: Act0LessonPhaseV1.review, selectedOptionId: option.id,
              ));
            },
            onCompletedDecision: completions.add,
          ),
        )));
        // Advance genuine choreography timers, never force readiness/state.
        for (var i = 0; i < 80; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(completions, isEmpty);
        expect(find.textContaining('River Td:'), findsNothing);
        expect(find.textContaining('River 5h:'), findsNothing);
        expect(find.textContaining('Call EV '), findsNothing);
        final button = find.byKey(Key('act0_shell_option_$action'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pump();
        expect(choices, 1);
        expect(completions, hasLength(1));
        final completed = completions.single;
        final correct = price == 10 ? action == 'call' : action == 'fold';
        expect(completed.selectedId, action);
        expect(completed.expectedId, price == 10 ? 'call' : 'fold');
        expect(completed.isCorrect, correct);
        expect(completed.resultKind, correct ? 'correct' : 'incorrect');
        expect(completed.skillAtomId, 'mindset_process_discipline');
        expect(completed.sourceTaskId, task.taskId);
        final prefix = action == 'fold' ? 'Fold: SB gets $price BB back'
            : 'River $river: ${river == '5h' ? 'You receive' : 'SB receives'} '
                '${price == 10 ? 60 : 120} BB.';
        expect(find.textContaining(prefix), findsWidgets);
        if (action == 'fold') {
          expect(find.textContaining('River 5h:'), findsNothing);
          expect(runner.reviewReason, contains('No river is played.'));
        }
        final fingerprint = act0AuthoredSourceFingerprintV1(
          worldId: 'world_12', lessonId: lesson.lessonId, task: task,
        )!;
        final history = const Act0LearningEvidenceHistoryV1().appendCompletedDecision(
          completed, authoredSourceFingerprint: fingerprint,
          sessionId: 'asm05_machine_callback',
          recordedAtUtc: DateTime.utc(2026, 11, 8),
          reviewKind: Act0ReviewKindV1.initialAssessment,
        );
        expect(history.records, hasLength(1));
        final record = history.records.single;
        final proof = act0CurrentAuthoredSourceProofForTaskV1(
          record: record, worldId: 'world_12', lessonId: lesson.lessonId, task: task,
        );
        expect(proof, isNotNull);
        expect(proof!.isCurrentlyCorrect, correct);
        if (isCanonicalRunout) {
          expect(act0CurrentAuthoredSourceProofV1(record), isNotNull);
        } else {
          expect(act0CurrentAuthoredSourceProofV1(record), isNull);
        }
        // Whole-source fingerprints include actual outcome feedback; comparing
        // their equality is NOT the winner-independence requirement.
        await tester.pump();
        expect(completions, hasLength(1));
      });
    }
  }
}
