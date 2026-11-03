import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Captured on unchanged 171f586 before the two representation edits.
// Synthetic compatibility receipts, not historical user saves.
const _before = {
  'w11_trigger_small_price_continue':
      '63ecbd47ac0cdddd9ac8b367afd26b10895cdc6df29d1c57afeeda79e8999b01',
  'w11_trigger_bad_price_fold':
      '6ec4341ea7a606c859f477e50a148747e1d56384707a0dcc097dca0de3072c14',
};
void main() {
  for (final entry in _before.entries) {
    final row = [
      for (final w in Act0ShellStateV1.sample.worlds)
        for (final l in w.lessons)
          for (final t in l.taskList)
            if (t.taskId == entry.key) (world: w, lesson: l, task: t),
    ].single;
    final task = row.task;
    final correct = task.runner.options.singleWhere((o) => o.isCorrect);
    test(
      '${entry.key} projection invalidates current proof but preserves raw history and grades',
      () {
        final turn = entry.key == 'w11_trigger_bad_price_fold';
        expect(
          task.runner.options.map((o) => o.id),
          turn
              ? ['call_top_pair', 'fold_turn', 'jam_turn']
              : ['call_once', 'fold_now', 'raise_now'],
        );
        expect(correct.id, turn ? 'fold_turn' : 'call_once');
        final current = act0AuthoredSourceFingerprintV1(
          worldId: row.world.worldId,
          lessonId: row.lesson.lessonId,
          task: task,
        )!;
        expect(current, isNot(entry.value));
        final skill = act0FirstValueSkillReceiptForRunnerV1(
          runner: task.runner,
          option: correct,
          taskFamily: task.resolvedTaskFamily,
        )!.skillAtomId;
        Act0LearningEvidenceRecordV1 record(String fingerprint) =>
            Act0LearningEvidenceRecordV1(
              recordId: 'synthetic_w11_projection|${task.taskId}|1',
              createdOrder: 1,
              worldId: row.world.worldId,
              lessonId: row.lesson.lessonId,
              taskId: task.taskId,
              sourceTaskId: task.taskId,
              choiceId: correct.id,
              expectedChoiceId: correct.id,
              isCorrect: true,
              errorType: 'none',
              conceptFamilyId: row.lesson.lessonId,
              repairFocusId: '',
              skillAtomId: skill,
              decisionTimeBucket: '3_to_10s',
              resultKind: 'correct',
              assistanceKind: Act0DecisionAssistanceV1.none,
              authoredSourceFingerprint: fingerprint,
            );
        final old = record(entry.value);
        final history = Act0LearningEvidenceHistoryV1(records: [old]);
        final restored = Act0LearningEvidenceHistoryV1.tryParse(
          jsonDecode(history.toStorageString()),
        )!;
        expect(restored.records.single.toPayload(), old.toPayload());
        expect(restored.records.single.isCorrect, isTrue);
        expect(restored.records.single.authoredSourceFingerprint, entry.value);
        expect(
          act0CurrentAuthoredSourceProofV1(restored.records.single),
          isNull,
        );
        final fresh = act0CurrentAuthoredSourceProofV1(record(current));
        expect(fresh, isNotNull);
        expect(fresh!.isCurrentlyCorrect, isTrue);
        print(
          'W11-FINGERPRINT ${task.taskId} old=${entry.value} current=$current history-preserved=true old-current-proof=false new-current-proof=true',
        );
      },
    );
  }
}
