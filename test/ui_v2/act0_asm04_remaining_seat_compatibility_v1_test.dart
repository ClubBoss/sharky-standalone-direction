import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_authored_source_proof_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

// Captured from unchanged published-tree 2842c020 before three task-local overrides.
// These are synthetic compatibility receipts, not historical user saves.
const _before = {
  'blinds_first_actor':
      '52bda958e7c00bbab92dedecb8c892110050c0d187a7088603f28fff4fb3178a',
  'positions_early_late':
      '9db6fb64dce38403a79001c843db06bb314ddf38ce7a5d71eece8a0d83e1cfb7',
  'early_vs_late_w2_early_position':
      'b3d64fa4c80353458288cea2e08af6efbc5a7f818404c239cad6124529a032bb',
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
        expect(task.runner.options.map((o) => o.id).toList(), ['utg', 'btn']);
        expect(correct.id, 'utg');
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
              recordId: 'synthetic_asm04_remaining_seat|${task.taskId}|1',
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
      'authored teaching retains exact original seat focus and copy: ${entry.key}',
      (tester) async {
        expect(
          task.runner.teachingSteps.first.focusSeatIds,
          contains(correct.seatId),
        );
        tester.view.physicalSize = const Size(393, 852);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final decisions = <Act0CompletedDecisionV1>[];
        final assistance = <Act0DecisionAssistanceV1>[];
        Future<Map<String, Object?>> teachingSnapshot(
          Act0RunnerStateV1 runner, {
          Act0LessonPhaseV1 phase = Act0LessonPhaseV1.theory,
          bool reset = true,
        }) async {
          if (reset) await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Act0LessonRunnerShellV1(
                  runner: runner.copyWith(
                    phase: phase,
                    teachingStepIndex: phase == Act0LessonPhaseV1.theory
                        ? 0
                        : runner.teachingSteps.length,
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
                  onCompletedDecision: decisions.add,
                  onChoiceAssistance: assistance.add,
                  onContinueReview: () {},
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final node = find.byWidgetPredicate(
            (w) =>
                w.runtimeType.toString() == '_SeatNodeV1' &&
                (w as dynamic).seat.seatId == 'utg',
          );
          final dynamic seat = tester.widget(node);
          final ring =
              tester
                      .widget<DecoratedBox>(
                        find.descendant(
                          of: node,
                          matching: find.byKey(
                            const Key('act0_shell_active_seat_ring'),
                          ),
                        ),
                      )
                      .decoration
                  as BoxDecoration;
          if (phase == Act0LessonPhaseV1.theory)
            expect(
              find.textContaining(task.runner.teachingSteps.first.body),
              findsWidgets,
            );
          expect(tester.takeException(), isNull);
          return {
            'allSeats': [
              for (final w in tester.widgetList(
                find.byWidgetPredicate(
                  (w) => w.runtimeType.toString() == '_SeatNodeV1',
                ),
              ))
                () {
                  final dynamic n = w;
                  final f = find.byWidget(w);
                  final rings = find.descendant(
                    of: f,
                    matching: find.byKey(
                      const Key('act0_shell_active_seat_ring'),
                    ),
                  );
                  final d = rings.evaluate().isEmpty
                      ? null
                      : tester.widget<DecoratedBox>(rings).decoration
                            as BoxDecoration;
                  return {
                    'id': n.seat.seatId,
                    'state': (n.visualState as Enum).name,
                    'color': d == null
                        ? null
                        : (d.border! as Border).top.color.toARGB32(),
                    'width': d == null ? null : (d.border! as Border).top.width,
                  };
                }(),
            ],
            'state': (seat.visualState as Enum).name,
            'ringColor': (ring.border! as Border).top.color.toARGB32(),
            'text': tester
                .widgetList<Text>(find.byType(Text))
                .map((t) => t.data ?? '')
                .where((s) => s.isNotEmpty)
                .toList(),
          };
        }

        // Exact old source table differs only in the two fields changed by this packet.
        final original = await teachingSnapshot(
          task.runner.copyWith(
            table: task.runner.table.copyWith(
              activeSeatId: 'utg',
              highlightedSeatIds: const ['utg'],
            ),
          ),
        );
        expect(original['state'], 'activeFocus');
        final current = await teachingSnapshot(task.runner);
        expect(current, original);
        final assessment = await teachingSnapshot(
          task.runner,
          phase: Act0LessonPhaseV1.drill,
          reset: false,
        );
        expect(assessment['state'], 'selectable');
        expect(assessment['text'] as List, isNot(contains('To act')));
        final tap = find.byKey(const Key('act0_shell_seat_tap_utg'));
        await tester.ensureVisible(tap);
        await tester.tap(tap);
        await tester.pumpAndSettle();
        expect(decisions.single.selectedId, 'utg');
        expect(decisions.single.isCorrect, isTrue);
        expect(decisions.single.assistanceKind, Act0DecisionAssistanceV1.none);
        expect(assistance, [Act0DecisionAssistanceV1.none]);
        for (final selected in ['utg', 'btn']) {
          final reviewed = task.runner.copyWith(selectedOptionId: selected);
          final oldReview = await teachingSnapshot(
            reviewed.copyWith(
              table: reviewed.table.copyWith(
                activeSeatId: 'utg',
                highlightedSeatIds: const ['utg'],
              ),
            ),
            phase: Act0LessonPhaseV1.review,
          );
          final newReview = await teachingSnapshot(
            reviewed,
            phase: Act0LessonPhaseV1.review,
          );
          expect(
            newReview,
            oldReview,
            reason:
                'Correct and wrong review feedback must remain source-equivalent',
          );
        }
      },
    );
  }
}
