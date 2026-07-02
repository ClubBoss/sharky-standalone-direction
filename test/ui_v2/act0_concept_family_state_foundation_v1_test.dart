import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';

void main() {
  test('first source-backed miss creates family state', () {
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(_record(order: 1, conceptFamilyId: 'action'));

    final family = history.familyById('action');

    expect(family, isNotNull);
    expect(family!.schemaVersion, 1);
    expect(family.conceptFamilyId, 'action');
    expect(family.worldId, 'world_1');
    expect(family.lastSeenAt, 1);
    expect(family.lastAttemptAt, isNull);
    expect(family.lastProofAt, isNull);
    expect(family.missCount, 1);
    expect(family.repairAttemptCount, 0);
    expect(family.successfulRepairCount, 0);
    expect(family.lastOutcome, act0ConceptFamilyOutcomeMissedV1);
    expect(family.lastTaskId, 'actions_legal_context');
  });

  test('repeated miss aggregates without creating duplicate family', () {
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(_record(order: 1, conceptFamilyId: 'action'))
        .appendLearningEvidence(
          _record(
            order: 2,
            conceptFamilyId: 'action',
            taskId: 'actions_raise_drill',
          ),
        );

    final family = history.familyById('action');

    expect(history.families, hasLength(1));
    expect(family!.missCount, 2);
    expect(family.lastSeenAt, 2);
    expect(family.lastTaskId, 'actions_raise_drill');
  });

  test('repair attempt increments from repair run evidence only', () {
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(_record(order: 1, conceptFamilyId: 'action'))
        .appendLearningEvidence(
          _record(
            order: 2,
            conceptFamilyId: 'action',
            runKind: 'repair',
            isCorrect: false,
          ),
        );

    final family = history.familyById('action');

    expect(family!.missCount, 2);
    expect(family.repairAttemptCount, 1);
    expect(family.successfulRepairCount, 0);
    expect(family.lastAttemptAt, 2);
    expect(family.lastProofAt, isNull);
    expect(family.lastOutcome, act0ConceptFamilyOutcomeRepairNotYetSucceededV1);
  });

  test('successful repair increments success and proof timestamp', () {
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(_record(order: 1, conceptFamilyId: 'action'))
        .appendRepairOutcome(
          _repairOutcome(isCorrect: true, sequence: 2),
          sourceOrder: 2,
        );

    final family = history.familyById('action');

    expect(family!.repairAttemptCount, 1);
    expect(family.successfulRepairCount, 1);
    expect(family.lastAttemptAt, 2);
    expect(family.lastProofAt, 2);
    expect(family.lastOutcome, act0ConceptFamilyOutcomeRepairSucceededV1);
  });

  test('unsuccessful repair does not increment success', () {
    final history = const Act0ConceptFamilyStateHistoryV1().appendRepairOutcome(
      _repairOutcome(isCorrect: false, sequence: 3),
      sourceOrder: 3,
    );

    final family = history.familyById('action');

    expect(family!.repairAttemptCount, 1);
    expect(family.successfulRepairCount, 0);
    expect(family.lastAttemptAt, 3);
    expect(family.lastProofAt, isNull);
    expect(family.lastOutcome, act0ConceptFamilyOutcomeRepairNotYetSucceededV1);
  });

  test('attempted repair with unknown correctness uses attempted outcome', () {
    final history = const Act0ConceptFamilyStateHistoryV1().appendRepairOutcome(
      _repairOutcome(isCorrect: null, sequence: 4),
      sourceOrder: 4,
    );

    final family = history.familyById('action');

    expect(family!.repairAttemptCount, 1);
    expect(family.successfulRepairCount, 0);
    expect(family.lastOutcome, act0ConceptFamilyOutcomeRepairAttemptedV1);
  });

  test('serialization round trip preserves raw evidence fields', () {
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(_record(order: 1, conceptFamilyId: 'action'))
        .appendRepairOutcome(
          _repairOutcome(isCorrect: true, sequence: 2),
          sourceOrder: 2,
        );

    final decoded = Act0ConceptFamilyStateHistoryV1.tryParse(
      jsonDecode(history.toStorageString()),
    );

    expect(decoded, history);
  });

  test('missing and malformed optional state fail safely', () {
    expect(
      Act0ConceptFamilyStateHistoryV1.tryParse(null),
      const Act0ConceptFamilyStateHistoryV1(),
    );
    expect(
      Act0ConceptFamilyStateHistoryV1.tryParse(<Object?>[
        <String, Object?>{
          'schemaVersion': 1,
          'conceptFamilyId': '',
          'worldId': 'world_1',
          'missCount': 'bad',
        },
      ]),
      const Act0ConceptFamilyStateHistoryV1(),
    );
  });

  test('mapping uses stable ids before copy-like fallbacks', () {
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(
          _record(
            order: 1,
            conceptFamilyId: 'stable_family',
            repairFocusId: 'copy label should not win',
            skillAtomId: 'skill_atom',
          ),
        )
        .appendLearningEvidence(
          _record(
            order: 2,
            conceptFamilyId: '',
            repairFocusId: 'repair_focus_id',
            skillAtomId: 'skill_atom',
          ),
        );

    expect(history.familyById('stable_family'), isNotNull);
    expect(history.familyById('repair_focus_id'), isNotNull);
    expect(history.familyById('copy label should not win'), isNull);
  });

  test(
    'different tasks in same family aggregate and different families split',
    () {
      final history = const Act0ConceptFamilyStateHistoryV1()
          .appendLearningEvidence(
            _record(
              order: 1,
              conceptFamilyId: 'action',
              taskId: 'actions_legal_context',
            ),
          )
          .appendLearningEvidence(
            _record(
              order: 2,
              conceptFamilyId: 'action',
              taskId: 'actions_raise_drill',
            ),
          )
          .appendLearningEvidence(
            _record(
              order: 3,
              conceptFamilyId: 'position',
              taskId: 'positions_early_late',
            ),
          );

      expect(history.familyById('action')!.missCount, 2);
      expect(history.familyById('position')!.missCount, 1);
      expect(history.families, hasLength(2));
    },
  );

  test('duplicate source record does not write from repeated rendering', () {
    final record = _record(order: 1, conceptFamilyId: 'action');
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(record)
        .appendLearningEvidence(record);

    expect(history.familyById('action')!.missCount, 1);
  });

  test('read model exposes known families and recent active family only', () {
    final history = const Act0ConceptFamilyStateHistoryV1()
        .appendLearningEvidence(_record(order: 1, conceptFamilyId: 'action'))
        .appendLearningEvidence(_record(order: 3, conceptFamilyId: 'position'));

    expect(history.knownFamilyIds, <String>['action', 'position']);
    expect(history.mostRecentActiveFamily?.conceptFamilyId, 'position');
  });

  test(
    'source has no UI, telemetry owner, scoring, or scheduling dependency',
    () {
      final source = File(
        'lib/ui_v2/act0_shell/act0_concept_family_state_foundation_v1.dart',
      ).readAsStringSync();

      expect(source, isNot(contains('package:flutter/')));
      expect(source, isNot(contains('Telemetry')));
      expect(source, isNot(contains('mastery')));
      expect(source, isNot(contains('score')));
      expect(source, isNot(contains('schedule')));
    },
  );
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String worldId = 'world_1',
  String taskId = 'actions_legal_context',
  String conceptFamilyId = 'action',
  String repairFocusId = 'action',
  String skillAtomId = 'action_read',
  String runKind = '',
  bool isCorrect = false,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'record_$order',
    createdOrder: order,
    worldId: worldId,
    lessonId: 'fold_check_call_raise',
    taskId: taskId,
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: isCorrect ? 'none' : 'missed_action_read',
    conceptFamilyId: conceptFamilyId,
    repairFocusId: repairFocusId,
    skillAtomId: skillAtomId,
    decisionTimeBucket: 'under_3s',
    resultKind: isCorrect ? 'correct' : 'incorrect',
    runKind: runKind,
  );
}

Act0RepairOutcomeV1 _repairOutcome({
  required bool? isCorrect,
  required int sequence,
}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_raise_drill',
    repairFocusKey: 'action',
    queueItemId: 'queue_action',
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_raise_drill',
    selectedChoiceId: isCorrect == true ? 'raise' : 'fold',
    correctChoiceId: 'raise',
    isCorrect: isCorrect,
    outcomeState: isCorrect == true
        ? act0RepairOutcomeStateCorrectV1
        : isCorrect == false
        ? act0RepairOutcomeStateStillNeedsRepV1
        : act0RepairOutcomeStateAttemptedV1,
    sequence: sequence,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
  );
}
