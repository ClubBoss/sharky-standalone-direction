import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_w7_visible_ace_hidden_runtime_session_owner_v1.dart';

void main() {
  const fixturePath =
      'test/fixtures/content_factory_mvp/'
      'w7_visible_ace_combo_reduction_intro_v1.json';

  Map<String, Object?> loadFixtureTask() {
    final decoded = jsonDecode(File(fixturePath).readAsStringSync());
    final fixture = (decoded as Map).cast<String, Object?>();
    final tasks = (fixture['tasks']! as List).cast<Map<String, Object?>>();
    return tasks.single;
  }

  group('Act0W7VisibleAceHiddenRuntimeSessionOwnerV1', () {
    const owner = Act0W7VisibleAceHiddenRuntimeSessionOwnerV1();

    test('supports exactly the visible ace task', () {
      expect(
        owner.supports(
          worldId: 'world_7',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'visible_ace_combo_reduction_intro',
        ),
        isTrue,
      );
      expect(
        owner.supports(
          worldId: 'world_7',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'other_w7_task',
        ),
        isFalse,
      );
      expect(
        owner.supports(
          worldId: 'world_6',
          lessonId: 'range_thinking_lite_combo_density',
          taskId: 'visible_ace_combo_reduction_intro',
        ),
        isFalse,
      );
      expect(
        owner.supports(
          worldId: 'world_7',
          lessonId: 'wrong_module',
          taskId: 'visible_ace_combo_reduction_intro',
        ),
        isFalse,
      );
    });

    test(
      'const task spec matches source fixture ids choices and safe copy',
      () {
        final task = loadFixtureTask();
        final spec = owner.taskSpec;

        expect(spec.worldId, task['world_id']);
        expect(spec.lessonId, task['lesson_id']);
        expect(spec.taskId, task['task_id']);
        expect(spec.sourceTaskId, task['source_task_id']);
        expect(spec.conceptFamilyId, task['concept_family_id']);
        expect(spec.repairFocusId, task['repair_focus_id']);
        expect(spec.skillAtomId, task['skill_atom_id']);
        expect(spec.errorType, task['error_type']);
        expect(spec.boardContext, task['board_context']);
        expect(spec.expectedChoiceId, task['expected_choice']);
        expect(spec.practiceCtaAllowed, task['practice_cta_allowed']);
        expect(spec.mapperNoTargetReason, task['mapper_no_target_reason']);

        final fixtureChoices = (task['choices']! as List)
            .cast<Map<String, Object?>>()
            .map((choice) => choice['id'])
            .toList();
        expect(spec.choiceIds, fixtureChoices);

        final encodedSpec = jsonEncode(spec.copySafetyPayload).toLowerCase();
        for (final forbidden in <String>[
          'gto',
          'solver',
          'optimal',
          'perfect',
          'mastered',
          'fixed',
          'guaranteed improvement',
          'ai leak',
        ]) {
          expect(encodedSpec, isNot(contains(forbidden)));
        }
      },
    );

    test('correct choice appends correct ordered local evidence', () {
      final history = owner.appendChoiceEvidence(
        history: const Act0LearningEvidenceHistoryV1(),
        selectedChoiceId: 'ace_combos_reduced',
        attemptKey: 'w7_visible_ace_attempt_1',
        decisionTimeBucket: 'under_3s',
      );

      expect(history.records, hasLength(1));
      final record = history.records.single;
      expect(record.worldId, 'world_7');
      expect(record.lessonId, 'range_thinking_lite_combo_density');
      expect(record.taskId, 'visible_ace_combo_reduction_intro');
      expect(record.choiceId, 'ace_combos_reduced');
      expect(record.expectedChoiceId, 'ace_combos_reduced');
      expect(record.isCorrect, isTrue);
      expect(record.resultKind, 'correct');
      expect(record.errorType, 'none');
      expect(record.conceptFamilyId, 'w7_combo_density_visible_card_removal');
      expect(record.repairFocusId, 'w7_visible_card_combo_reduction');
      expect(record.skillAtomId, 'w7_combo_density_card_removal');
      expect(record.decisionTimeBucket, 'under_3s');
      expect(record.runKind, 'w7_hidden_runtime_session_owner_v1');
      expect(record.startedBy, 'Act0W7VisibleAceHiddenRuntimeSessionOwnerV1');
    });

    test('incorrect choices append incorrect evidence without duplicates', () {
      var history = const Act0LearningEvidenceHistoryV1();
      for (final choiceId in <String>[
        'ace_combos_unchanged',
        'ace_combos_guaranteed',
        'ace_combos_impossible',
      ]) {
        history = owner.appendChoiceEvidence(
          history: history,
          selectedChoiceId: choiceId,
          attemptKey: 'attempt_$choiceId',
          decisionTimeBucket: '3_to_10s',
        );
      }
      final duplicate = owner.appendChoiceEvidence(
        history: history,
        selectedChoiceId: 'ace_combos_unchanged',
        attemptKey: 'attempt_ace_combos_unchanged',
        decisionTimeBucket: '3_to_10s',
      );

      expect(duplicate.records, hasLength(3));
      for (final record in duplicate.records) {
        expect(record.isCorrect, isFalse);
        expect(record.resultKind, 'incorrect');
        expect(record.errorType, 'missed_visible_card_combo_reduction');
        expect(record.conceptFamilyId, 'w7_combo_density_visible_card_removal');
        expect(record.repairFocusId, 'w7_visible_card_combo_reduction');
        expect(record.skillAtomId, 'w7_combo_density_card_removal');
      }
    });

    test('rejects unsupported choice ids', () {
      expect(
        () => owner.appendChoiceEvidence(
          history: const Act0LearningEvidenceHistoryV1(),
          selectedChoiceId: 'unknown_choice',
          attemptKey: 'attempt_unknown',
          decisionTimeBucket: 'under_3s',
        ),
        throwsArgumentError,
      );
    });

    test('keeps Practice CTA and mapper target forbidden', () {
      expect(owner.taskSpec.practiceCtaAllowed, isFalse);
      expect(
        owner.taskSpec.mapperNoTargetReason,
        'w7_route_locked_no_safe_practice_target_v1',
      );
      expect(owner.practiceLaunchRequest, isNull);
    });
  });
}
