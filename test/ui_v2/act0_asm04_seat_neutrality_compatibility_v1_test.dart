import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Captured from unchanged 463fb0 source before the two task-local overrides.
// These are synthetic compatibility receipts, not historical user saves.
const _before = {
  'blinds_last_actor':
      '36473fc5f9d3b08575dad475e02e7a31a9a342715013df33e3a72793bd78c20b',
  'positions_utg':
      'caf4c479b52ef50b3590374365e4d05f483943b836dacec8bc50c40a189ef18e',
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
      'changed focus invalidates current proof without rewriting history: ${entry.key}',
      () {
        expect(task.runner.table.highlightedSeatIds, isEmpty);
        expect(task.runner.table.activeSeatId, '');
        expect(
          task.runner.options.map((o) => o.id).toList(),
          entry.key == 'blinds_last_actor' ? ['sb', 'bb'] : ['hj', 'utg'],
        );
        expect(correct.id, entry.key == 'blinds_last_actor' ? 'bb' : 'utg');
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
              recordId: 'synthetic_asm04_seat|${task.taskId}|1',
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
          'ASM04-SEAT-FINGERPRINT ${task.taskId} old=${entry.value} current=$current history-preserved=true old-current-proof=false new-current-proof=true',
        );
      },
    );

    testWidgets(
      'authored teaching still points to the intended seat: ${entry.key}',
      (tester) async {
        expect(
          task.runner.teachingSteps.first.focusSeatIds,
          contains(correct.seatId),
        );
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Act0LessonRunnerShellV1(
                runner: task.runner.copyWith(
                  phase: Act0LessonPhaseV1.theory,
                  teachingStepIndex: 0,
                ),
                worldNumber: row.world.worldNumber,
                selectedWorldId: row.world.worldId,
                selectedLessonId: row.lesson.lessonId,
                selectedTaskId: task.taskId,
                selectedTaskTitle: task.title,
                selectedTaskFamily: task.resolvedTaskFamily,
                compositionFamily: task.resolvedCompositionFamily,
                tablePresentation: task.tablePresentation,
                onBack: () {},
                onContinueTheory: () {},
                onChooseOption: (_) {},
                onContinueReview: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(
            Key('act0_shell_seat_state_${correct.seatId}_targetFocus'),
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(task.runner.teachingSteps.first.body),
          findsWidgets,
        );
      },
    );
  }
}
