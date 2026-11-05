import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

Act0LessonTaskV1 _task(String id) => Act0ShellStateV1.sample.worlds
    .expand((world) => world.lessons)
    .expand((lesson) => lesson.taskList)
    .singleWhere((task) => task.taskId == id);

void main() {
  test('checked-through W4 flop has no active actor', () {
    final task = _task('w4_protection_check');
    final table = task.runner.table;
    expect(table.potLabel, 'Pot 6 BB');
    expect(table.actionTrail.map((item) => item.label).toList().sublist(
      table.actionTrail.length - 2,
    ), ['Flop: BB checks', 'BTN checks']);
    expect(table.activeSeatId, anyOf(isNull, isEmpty));
    expect(task.rewardXp, 8);
    final correct = task.runner.options.singleWhere((option) => option.isCorrect);
    expect(correct.id, 'free_card');
    expect(correct.feedbackReason, contains('without paying'));
  });

  test('open W4 protection decision still belongs to BTN', () {
    final table = _task('w4_protection_bet').runner.table;
    expect(table.potLabel, 'Pot 6 BB');
    expect(table.activeSeatId, 'btn');
    expect(table.actionTrail.last.label, 'Flop: BB checks');
  });

  test('changed source preserves old records while current proof is rechecked', () {
    // Synthetic compatibility fixtures; hashes are from the unchanged source.
    const oldFingerprints = {
      'w4_protection_check': 'b46b87659691ac46d0dbca215fa63e4de3365b21e5a3c08e6f36b5fd2982ea97',
      'early_vs_late_late_info_choice': '73bc9f4f1a37e8c423eb1c86ae75d3f6f3d55726e4e540b75d58dd84e938afc9',
      'w6_board_pair_strength_compare': 'a328c73b9c59e2f6213dc0cc64a1f5b91e9261c009675cf1385340c4a13af353',
    };
    for (final entry in oldFingerprints.entries) {
      final row = [
        for (final world in Act0ShellStateV1.sample.worlds)
          for (final lesson in world.lessons)
            for (final task in lesson.taskList)
              if (task.taskId == entry.key)
                (world: world, lesson: lesson, task: task),
      ].single;
      final task = row.task;
      final option = task.runner.options.singleWhere((o) => o.isCorrect);
      final current = act0AuthoredSourceFingerprintV1(
        worldId: row.world.worldId,
        lessonId: row.lesson.lessonId,
        task: task,
      )!;
      final skill = act0FirstValueSkillReceiptForRunnerV1(
        runner: task.runner,
        option: option,
        taskFamily: task.resolvedTaskFamily,
      )!.skillAtomId;
      Act0LearningEvidenceRecordV1 record(String fingerprint) =>
          Act0LearningEvidenceRecordV1(
            recordId: 'synthetic_poker_compat|${task.taskId}|1',
            createdOrder: 1,
            worldId: row.world.worldId,
            lessonId: row.lesson.lessonId,
            taskId: task.taskId,
            sourceTaskId: task.taskId,
            choiceId: option.id,
            expectedChoiceId: option.id,
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
      final restored = Act0LearningEvidenceHistoryV1.tryParse(
        jsonDecode(Act0LearningEvidenceHistoryV1(records: [old]).toStorageString()),
      )!;
      expect(restored.records.single.toPayload(), old.toPayload());
      expect(current, isNot(entry.value), reason: task.taskId);
      expect(act0CurrentAuthoredSourceProofV1(restored.records.single), isNull);
      final fresh = act0CurrentAuthoredSourceProofV1(record(current));
      expect(fresh, isNotNull, reason: task.taskId);
      expect(fresh!.isCurrentlyCorrect, isTrue);
      // ignore: avoid_print
      print('POKER-SOURCE ${task.taskId} old=${entry.value} current=$current');
    }
  });
}
