import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// SYNTHETIC UNIT FIXTURES ONLY. Not an earned main history or native receipt.
void main() {
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final lesson = world.lessons.singleWhere(
    (lesson) => lesson.lessonId == 'fold_check_call_raise',
  );
  final cohort = lesson.taskList
      .where((task) => act0IsUnresolvedHistoricalW1TaskV1(task.taskId))
      .toList();
  test('quarantined historical cohort has five tasks', () {
    expect(cohort, hasLength(5));
  });
  for (final task in cohort) {
    for (final choice in task.runner.options) {
      for (final resultKind in ['incorrect', 'suboptimal', 'correct']) {
        final correct = resultKind == 'correct';
        test(
          '${task.taskId}/${choice.id}/legacy-grade-$resultKind stays historical',
          () {
            final record = Act0LearningEvidenceRecordV1(
              recordId: 'synthetic-old-${task.taskId}-${choice.id}-$resultKind',
              createdOrder: 1,
              worldId: world.worldId,
              lessonId: lesson.lessonId,
              taskId: task.taskId,
              sourceTaskId: task.taskId,
              choiceId: choice.id,
              expectedChoiceId: 'raise',
              isCorrect: correct,
              errorType: correct ? 'none' : 'historical_hand_error',
              conceptFamilyId: 'historical_hand',
              repairFocusId: 'historical_hand',
              skillAtomId: 'historical_hand',
              decisionTimeBucket: 'under_3s',
              resultKind: resultKind,
              assistanceKind: Act0DecisionAssistanceV1.none,
              authoredSourceFingerprint: 'synthetic-noncurrent-source',
            );
            final bytes = Act0LearningEvidenceHistoryV1(
              records: [record],
            ).toStorageString();
            final restored =
                Act0LearningEvidenceHistoryV1.tryParseStorageString(bytes);
            expect(restored, isNotNull);
            final saved = restored!.records.single;
            expect(saved.toPayload(), record.toPayload());
            expect(act0CurrentAuthoredSourceProofV1(saved), isNull);
            expect(restored.toStorageString(), bytes);
          },
        );
      }
    }
    test(
      '${task.taskId}: quarantined historical task is not current poker proof',
      () {
        final correct = task.runner.options.singleWhere((o) => o.isCorrect);
        final record = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic-current-${task.taskId}',
          createdOrder: 1,
          worldId: world.worldId,
          lessonId: lesson.lessonId,
          taskId: task.taskId,
          sourceTaskId: task.taskId,
          choiceId: correct.id,
          expectedChoiceId: correct.id,
          isCorrect: true,
          errorType: 'none',
          repairFocusId: 'action_word',
          skillAtomId: 'action_word',
          decisionTimeBucket: 'under_3s',
          resultKind: 'correct',
          assistanceKind: Act0DecisionAssistanceV1.none,
          authoredSourceFingerprint: act0AuthoredSourceFingerprintV1(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            task: task,
          )!,
        );
        expect(act0CurrentAuthoredSourceProofV1(record), isNull);
      },
    );
  }
}
