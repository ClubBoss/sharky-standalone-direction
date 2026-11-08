import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  final world = Act0ShellStateV1.sample.worldById('world_1');
  final lesson = world.lessons.singleWhere(
    (l) => l.lessonId == 'hand_rankings_table',
  );
  final task = lesson.taskList.singleWhere(
    (t) => t.taskId == 'hand_rankings_pair_drill',
  );
  const prior =
      '6e10adfaa8b261630442d1e36f28df0bb9543d70705c1166016b7f5af34564ef';
  final current = act0AuthoredSourceFingerprintV1(
    worldId: world.worldId,
    lessonId: lesson.lessonId,
    task: task,
  )!;
  final pair = task.runner.options.singleWhere((o) => o.id == 'pair');
  final skill = act0FirstValueSkillReceiptForRunnerV1(
    runner: task.runner,
    option: pair,
    taskFamily: task.resolvedTaskFamily,
  )!.skillAtomId;
  Act0LearningEvidenceRecordV1 record(
    String fingerprint, {
    String choice = 'pair',
    Act0DecisionAssistanceV1 assistance = Act0DecisionAssistanceV1.none,
  }) => Act0LearningEvidenceRecordV1(
    recordId: 'synthetic_asm04_card_focus|1',
    createdOrder: 1,
    worldId: world.worldId,
    lessonId: lesson.lessonId,
    taskId: task.taskId,
    sourceTaskId: task.taskId,
    choiceId: choice,
    expectedChoiceId: choice,
    isCorrect: true,
    errorType: 'none',
    conceptFamilyId: lesson.lessonId,
    repairFocusId: '',
    skillAtomId: skill,
    decisionTimeBucket: '3_to_10s',
    resultKind: 'correct',
    assistanceKind: assistance,
    authoredSourceFingerprint: fingerprint,
  );

  test(
    'pre-fix focused answer stays historical and cannot prove the neutral assessment',
    () {
      expect(current, isNot(prior));
      final old = record(prior);
      final history = Act0LearningEvidenceHistoryV1(records: [old]);
      final restored = Act0LearningEvidenceHistoryV1.tryParse(
        jsonDecode(history.toStorageString()),
      )!;
      expect(restored.records.single.toPayload(), old.toPayload());
      expect(restored.records.single.isCorrect, isTrue);
      expect(act0CurrentAuthoredSourceProofV1(restored.records.single), isNull);
      expect(
        act0CurrentAuthoredSourceProofV1(record(current))!.isCurrentlyCorrect,
        isTrue,
      );
    },
  );

  test(
    'self-consistent forged grade does not override actual source choice',
    () {
      final wrong = task.runner.options.singleWhere((o) => o.id != 'pair');
      final forged = record(current, choice: wrong.id);
      expect(forged.isCorrect, isTrue);
      expect(forged.expectedChoiceId, forged.choiceId);
      final proof = act0CurrentAuthoredSourceProofV1(forged)!;
      expect(proof.isCurrentlyCorrect, isFalse);
      expect(
        act0IndependentRepairProofV1(
          isCorrect: proof.isCurrentlyCorrect,
          assistanceKind: forged.assistanceKind,
        ),
        isFalse,
      );
    },
  );

  test('current correct source with requested help is still assisted', () {
    for (final assistance in [
      Act0DecisionAssistanceV1.quickHint,
      Act0DecisionAssistanceV1.theoryRecall,
      Act0DecisionAssistanceV1.legacyUnknown,
    ]) {
      final assisted = record(current, assistance: assistance);
      final restored = Act0LearningEvidenceRecordV1.tryParse(
        assisted.toPayload(),
      )!;
      expect(restored.assistanceKind, assistance);
      final proof = act0CurrentAuthoredSourceProofV1(restored)!;
      expect(proof.isCurrentlyCorrect, isTrue);
      expect(
        act0IndependentRepairProofV1(
          isCorrect: proof.isCurrentlyCorrect,
          assistanceKind: restored.assistanceKind,
        ),
        isFalse,
      );
    }
  });
}
