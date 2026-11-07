// Synthetic persistence receipts over actual authored task identities.
// These are contract witnesses, never historical learner or native evidence.
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_preview_screen_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';

const _ids = [
  'w6_turn_shift_bucket',
  'w6_wet_board_repair',
  'w12_bad_call_good_result',
  'w6_turn_pressure_shift_transfer',
  'turn_river_changes_w5_turn_texture_shift_transfer',
  'w12_checkpoint_process_line',
];
const _before = <String, String>{
  'w6_turn_shift_bucket':
      'f840ec5dc1ef3a48fa61c0e6cfac9ffd10b951ff33b15d416ac4e791dfa915db',
  'w6_wet_board_repair':
      '08009b7691362c0016370d6522bb6fb6f0baa4053981c6380b494a10ad0fbc08',
  'w12_bad_call_good_result':
      '6f5d158b1c68a8c95bd196a61f18aefee811050c152d145aa063e39567906970',
  'w6_turn_pressure_shift_transfer':
      '15f63fedc98ed61fdbc8dc0ed659c25e218509f75aa8c20f959a34ee667a62fb',
  'turn_river_changes_w5_turn_texture_shift_transfer':
      '9ae48cd931dad51787b83a30b1776996ecd1dd4983d36bf4c91faba782508d06',
  'w12_checkpoint_process_line':
      '8cd0b3fa0f59a8736dbe2a311cb687b94b9df5afc7f15a2d8825b1236b120f3f',
};

const _counterpart = {
  'w6_turn_shift_bucket': 'w6_turn_pressure_shift_transfer',
  'w6_turn_pressure_shift_transfer': 'w6_turn_shift_bucket',
  'w6_wet_board_repair': 'turn_river_changes_w5_turn_texture_shift_transfer',
  'turn_river_changes_w5_turn_texture_shift_transfer': 'w6_wet_board_repair',
  'w12_bad_call_good_result': 'w12_checkpoint_process_line',
  'w12_checkpoint_process_line': 'w12_bad_call_good_result',
};
void main() {
  test('W5 concept binding retains its unique authored runner identity', () {
    final world = Act0ShellStateV1.sample.worldById('world_5');
    final lesson = world.lessons.singleWhere(
      (l) => l.lessonId == 'turn_river_changes',
    );
    final task = lesson.taskList.singleWhere(
      (t) => t.taskId == 'turn_river_changes_w5_turn_texture_shift_transfer',
    );
    expect(task.runner.feedbackSignalId, 'board_texture_change');
    expect(task.runner.lessonId, 'w5_turn_texture_shift_transfer');
    expect(lesson.lessonId, 'turn_river_changes');
    expect(task.taskId, 'turn_river_changes_w5_turn_texture_shift_transfer');
    final adjacent = lesson.taskList.singleWhere(
      (t) => t.taskId == 'turn_river_changes_w5_river_draw_story_transfer',
    );
    expect(adjacent.runner.lessonId, 'turn_river_changes');
    final correct = adjacent.runner.options.singleWhere((o) => o.isCorrect);
    expect(
      act0FirstValueSkillReceiptForRunnerV1(
        runner: adjacent.runner.copyWith(
          feedbackSignalId: 'board_texture_change',
        ),
        option: correct,
        taskFamily: adjacent.resolvedTaskFamily,
      ),
      isNull,
      reason:
          'Neighboring tasks cannot acquire the admitted leaf concept signal',
    );
  });
  _registerMetadataFalsifiers();
  for (final id in _ids) {
    final row = [
      for (final w in Act0ShellStateV1.sample.worlds)
        for (final l in w.lessons)
          for (final t in l.taskList)
            if (t.taskId == id) (world: w, lesson: l, task: t),
    ].single;
    test(
      '$id retains real concept proof and a different same-concept repair',
      () {
        final t = row.task;
        final fingerprint = act0AuthoredSourceFingerprintV1(
          worldId: row.world.worldId,
          lessonId: row.lesson.lessonId,
          task: t,
        )!;
        final correct = t.runner.options.singleWhere((o) => o.isCorrect);
        for (final option in t.runner.options) {
          final receipt = act0FirstValueSkillReceiptForRunnerV1(
            runner: t.runner,
            option: option,
            taskFamily: t.resolvedTaskFamily,
          );
          expect(
            receipt,
            isNotNull,
            reason:
                'A concept answer must not lose current proof when unrelated cards are removed',
          );
          expect(receipt!.sourceSignalId, isNot('hero_cards_board_pot'));
          final record = Act0LearningEvidenceRecordV1(
            recordId: 'synthetic_pkr03|$id|${option.id}',
            createdOrder: 1,
            worldId: row.world.worldId,
            lessonId: row.lesson.lessonId,
            taskId: id,
            sourceTaskId: id,
            choiceId: option.id,
            expectedChoiceId: correct.id,
            isCorrect: option.isCorrect,
            errorType: option.isCorrect ? 'none' : 'synthetic_source_error',
            repairFocusId: '',
            skillAtomId: receipt.skillAtomId,
            decisionTimeBucket: '3_to_10s',
            resultKind: option.isCorrect
                ? 'correct'
                : option.quality == Act0FeedbackQualityV1.suboptimal
                ? 'suboptimal'
                : 'incorrect',
            assistanceKind: Act0DecisionAssistanceV1.none,
            authoredSourceFingerprint: fingerprint,
          );
          final old = Act0LearningEvidenceRecordV1.tryParse({
            ...record.toPayload(),
            'authoredSourceFingerprint': _before[id],
          })!;
          expect(act0CurrentAuthoredSourceProofV1(old), isNull);
          final oldRestored = Act0LearningEvidenceHistoryV1.tryParse(
            jsonDecode(
              Act0LearningEvidenceHistoryV1(records: [old]).toStorageString(),
            ),
          )!;
          expect(oldRestored.records.single.toPayload(), old.toPayload());
          final proof = act0CurrentAuthoredSourceProofV1(record);
          expect(proof, isNotNull);
          expect(proof!.isCurrentlyCorrect, option.isCorrect);
          expect(proof.skillAtomId, receipt.skillAtomId);
          if (option.isCorrect) continue;
          final intent = buildAct0RepairIntentV1(
            sourceWorldId: row.world.worldId,
            sourceLessonId: row.lesson.lessonId,
            sourceTaskId: id,
            runner: t.runner,
            selectedOption: option,
            mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
          );
          expect(intent, isNotNull);
          expect(intent!.targetTaskId, isNot(id));
          expect(intent.targetTaskId, _counterpart[id]);
          expect(intent.mappingType, isNot('exact'));
          final target = Act0ShellStateV1.sample
              .worldById(intent.targetWorldId)
              .lessons
              .singleWhere((l) => l.lessonId == intent.targetLessonId)
              .taskList
              .singleWhere((t) => t.taskId == intent.targetTaskId);
          final targetReceipt = act0FirstValueSkillReceiptForRunnerV1(
            runner: target.runner,
            option: target.runner.options.singleWhere((o) => o.isCorrect),
            taskFamily: target.resolvedTaskFamily,
          );
          expect(targetReceipt, isNotNull);
          expect(targetReceipt!.sourceSignalId, receipt.sourceSignalId);
          expect(targetReceipt.skillAtomId, receipt.skillAtomId);
        }
        final hintRecord = Act0LearningEvidenceRecordV1(
          recordId: 'synthetic_pkr03_hint|$id',
          createdOrder: 1,
          worldId: row.world.worldId,
          lessonId: row.lesson.lessonId,
          taskId: id,
          sourceTaskId: id,
          choiceId: correct.id,
          expectedChoiceId: correct.id,
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
          skillAtomId: 'synthetic_stored_skill',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          assistanceKind: Act0DecisionAssistanceV1.quickHint,
          authoredSourceFingerprint: fingerprint,
        );
        final restored = Act0LearningEvidenceHistoryV1.tryParse(
          jsonDecode(
            Act0LearningEvidenceHistoryV1(
              records: [hintRecord],
            ).toStorageString(),
          ),
        )!;
        expect(restored.records.single.toPayload(), hintRecord.toPayload());
        expect(restored.records.single.isIndependentCorrect, isFalse);
        expect(restored.records.single.isAssistedCorrect, isTrue);
      },
    );
  }
}

void _registerMetadataFalsifiers() {
  test('explicit premise metadata fails closed before generic card proof', () {
    for (final id in const [..._ids]) {
      final task = Act0ShellStateV1.sample.worlds
          .expand((w) => w.lessons)
          .expand((l) => l.taskList)
          .singleWhere((t) => t.taskId == id);
      final runner = task.runner;
      final correct = runner.options.singleWhere((o) => o.isCorrect);
      final receipt = act0FirstValueSkillReceiptForRunnerV1(
        runner: runner,
        option: correct,
        taskFamily: task.resolvedTaskFamily,
      )!;
      for (final forged in [
        runner.copyWith(lessonId: 'unowned_pkr03_runner'),
        runner.copyWith(feedbackSignalId: 'unowned_pkr03_signal'),
        runner.copyWith(
          feedbackSignalId: runner.feedbackSignalId == 'process_over_outcome'
              ? 'range_bucket_shift'
              : 'process_over_outcome',
        ),
      ]) {
        expect(
          act0FirstValueSkillReceiptForRunnerV1(
            runner: forged,
            option: correct,
            taskFamily: task.resolvedTaskFamily,
          ),
          isNull,
        );
      }
      for (final invalid in [
        (next: 'unregistered_next_rep', skill: receipt.skillAtomId),
        (next: receipt.nextRepId, skill: 'unregistered_skill'),
      ]) {
        expect(
          act0FirstValueSameSignalRepMappingV1(
            nextRepId: invalid.next,
            skillAtomId: invalid.skill,
            sourceSignalId: receipt.sourceSignalId,
            sourceTaskId: id,
            receiptOutcome: 'repair_started',
          ),
          isNull,
        );
      }
      final without = act0FirstValueSkillReceiptForRunnerV1(
        runner: runner.copyWith(feedbackSignalId: ''),
        option: correct,
        taskFamily: task.resolvedTaskFamily,
      );
      expect(without?.sourceSignalId, isNot(receipt.sourceSignalId));
      expect(
        act0FirstValueSameSignalRepMappingV1(
          nextRepId: receipt.nextRepId,
          skillAtomId: receipt.skillAtomId,
          sourceSignalId: receipt.sourceSignalId,
          sourceTaskId: 'unowned_pkr03_task',
          receiptOutcome: 'repair_started',
        ),
        isNull,
      );
      expect(
        act0FirstValueSameSignalRepMappingV1(
          nextRepId: receipt.nextRepId,
          skillAtomId: receipt.skillAtomId,
          sourceSignalId: 'unowned_pkr03_signal',
          sourceTaskId: id,
          receiptOutcome: 'repair_started',
        ),
        isNull,
      );
    }
  });
}
