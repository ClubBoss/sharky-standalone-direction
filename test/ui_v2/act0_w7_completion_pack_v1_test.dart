import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_candidate_practice_mapper_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_repair_memory_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_evidence_harness_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  group('W7 completion pack', () {
    const owner = Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();
    const harness = Act0W7VisibleAceHiddenEvidenceHarnessV1();

    test('contains a coherent four-task hidden learning arc', () {
      expect(owner.taskSpecs, hasLength(4));
      expect(owner.taskSpecs.map((task) => task.taskId), <String>[
        'visible_ace_combo_reduction_intro',
        'visible_king_combo_reduction_intro',
        'paired_board_texture_lite_intro',
        'visible_card_combo_density_transfer_check',
      ]);

      final purposes = owner.taskSpecs
          .map((task) => task.learningPurpose)
          .toSet();
      expect(purposes, hasLength(4));
      for (final task in owner.taskSpecs) {
        expect(task.worldId, 'world_7');
        expect(task.lessonId, 'range_thinking_lite_combo_density');
        expect(task.conceptFamilyId, 'w7_combo_density_visible_card_removal');
        expect(task.practiceCtaAllowed, isFalse);
        expect(
          task.mapperNoTargetReason,
          'w7_route_locked_no_safe_practice_target_v1',
        );
      }
    });

    test('supports only admitted W7 completion-pack tasks', () {
      for (final task in owner.taskSpecs) {
        expect(
          owner.supports(
            worldId: task.worldId,
            lessonId: task.lessonId,
            taskId: task.taskId,
          ),
          isTrue,
        );
      }
      expect(
        owner.supports(
          worldId: 'world_7',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'unowned_w7_task',
        ),
        isFalse,
      );
      expect(
        owner.supports(
          worldId: 'world_8',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: owner.taskSpecs.first.taskId,
        ),
        isFalse,
      );
    });

    test('each task writes correct and incorrect consumable evidence', () {
      var history = const Act0LearningEvidenceHistoryV1();
      for (final task in owner.taskSpecs) {
        final wrongChoice = task.choiceIds.firstWhere(
          (choiceId) => choiceId != task.expectedChoiceId,
        );
        history = harness.submitChoice(
          history: history,
          worldId: task.worldId,
          lessonId: task.lessonId,
          taskId: task.taskId,
          selectedChoiceId: wrongChoice,
          attemptKey: '${task.taskId}_miss',
          decisionTimeBucket: '3_to_10s',
        );
        history = harness.submitChoice(
          history: history,
          worldId: task.worldId,
          lessonId: task.lessonId,
          taskId: task.taskId,
          selectedChoiceId: task.expectedChoiceId,
          attemptKey: '${task.taskId}_correct',
          decisionTimeBucket: 'under_3s',
        );
      }

      expect(history.records, hasLength(owner.taskSpecs.length * 2));
      for (final task in owner.taskSpecs) {
        final records = history.records
            .where((record) => record.taskId == task.taskId)
            .toList();
        expect(records, hasLength(2));
        expect(records.first.isCorrect, isFalse);
        expect(records.first.errorType, task.errorType);
        expect(records.last.isCorrect, isTrue);
        expect(records.last.errorType, 'none');
        for (final record in records) {
          expect(record.conceptFamilyId, task.conceptFamilyId);
          expect(record.repairFocusId, task.repairFocusId);
          expect(record.skillAtomId, task.skillAtomId);
          expect(record.expectedChoiceId, task.expectedChoiceId);
        }
      }

      final memory = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        history,
      );
      expect(
        memory.families.single.conceptFamilyId,
        owner.taskSpecs.first.conceptFamilyId,
      );
      expect(
        memory.families.single.resolutionState,
        act0RepairCandidateResolutionClearedV1,
      );

      final transfer = Act0RepairTransferProjectionV1.fromLearningEvidence(
        history,
      );
      expect(
        transfer.signalForConcept(owner.taskSpecs.first.conceptFamilyId).state,
        act0RepairTransferLaterCorrectSignalV1,
      );
    });

    test('rejects unknown choices and exposes no Practice launch request', () {
      expect(
        () => harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_7',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'visible_king_combo_reduction_intro',
          selectedChoiceId: 'unknown_choice',
          attemptKey: 'unknown_choice_attempt',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
      expect(harness.practiceLaunchRequest, isNull);

      final candidate = Act0ConceptFamilyRepairMemoryV1.fromLearningEvidence(
        harness.submitChoice(
          history: const Act0LearningEvidenceHistoryV1(),
          worldId: 'world_7',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'visible_king_combo_reduction_intro',
          selectedChoiceId: 'king_combos_unchanged',
          attemptKey: 'king_miss',
          decisionTimeBucket: 'under_3s',
        ),
      ).nextRepairCandidate;
      final mapped = mapAct0ConceptCandidateToPracticeLaunchRequestV1(
        candidate,
      );
      expect(mapped.isMapped, isFalse);
      expect(mapped.request, isNull);
    });

    test('learning arc copy is beginner readable and claim safe', () {
      final encoded = jsonEncode(
        owner.taskSpecs
            .map(
              (task) => <String>[
                task.learnerPrompt,
                ...task.choiceLabels.values,
                task.feedbackReason,
                ...task.incorrectFeedback.values,
                task.boardContext,
                task.learningPurpose,
              ],
            )
            .toList(),
      ).toLowerCase();
      for (final forbidden in <String>[
        'gto',
        'solver',
        'optimal',
        'perfect',
        'mastered',
        'fixed',
        'guaranteed improvement',
        'proven improvement',
        'ai leak',
        'win-rate',
        'public',
        'playable',
        'lite',
        'combo density',
        'card removal',
        'gutshot',
        'thin value',
        'fold pressure',
        'suited texture pressure',
        'put it all together',
        'build winning habits',
        'develop your reads',
        'now you know',
        'you mastered',
      ]) {
        expect(encoded, isNot(contains(forbidden)));
      }
      for (final task in owner.taskSpecs) {
        expect(task.learnerPrompt, isNot(contains(task.taskId)));
        expect(task.feedbackReason, isNot(contains(task.taskId)));
      }
    });
  });
}
