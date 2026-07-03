import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_coach_phrase_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_sharky_improvement_observation_v1.dart';

void main() {
  test(
    'prior repair plus later eligible correct evidence creates observation',
    () {
      final projection =
          Act0SharkyImprovementObservationProjectionV1.fromFixProof(
            _reinforcedFixProof(),
            completedSessionId: 'session_later',
          );

      expect(projection.observations, hasLength(1));
      final observation = projection.observations.single;
      expect(observation.observationState, act0SharkyImprovementEligibleV1);
      expect(observation.conceptFamilyId, 'no_bet_yet');
      expect(observation.sourceRepairId, 'repair_outcome_v1|2|queue_a');
      expect(observation.sourceSessionId, 'session_repair');
      expect(
        observation.laterEvidenceId,
        'later_evidence_v1|session_later|task_later',
      );
      expect(observation.laterSessionId, 'session_later');
      expect(observation.observedOrder, 5);
      expect(
        observation.phraseContext.momentType,
        Act0SharkyCoachMomentTypeV1.laterImprovementObserved,
      );
    },
  );

  test('same-task evidence does not qualify', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          _fixProofFromHistory(
            laterTaskId: 'task_source',
            laterSessionId: 'session_later',
          ),
        );

    expect(projection.observations, isEmpty);
  });

  test('same-session evidence does not qualify', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          _fixProofFromHistory(laterSessionId: 'session_repair'),
        );

    expect(projection.observations, isEmpty);
  });

  test('unrelated concept family does not qualify', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          _fixProofFromHistory(
            baselineConceptFamilyId: 'position_read',
            laterConceptFamilyId: 'position_read',
          ),
        );

    expect(projection.observations, isEmpty);
  });

  test('failed repair does not qualify', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          _fixProofFromHistory(repairCorrect: false),
        );

    expect(projection.observations, isEmpty);
  });

  test('malformed evidence fails closed', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          const Act0FixProofProjectionV1(
            proofs: <Act0FixProofItemV1>[
              Act0FixProofItemV1(
                fixProofId: 'fix_proof_v1|queue_a',
                queueItemId: 'queue_a',
                conceptFamilyId: 'no_bet_yet',
                repairSessionId: 'session_repair',
                repairOutcomeRef: 'repair_outcome_v1|2|queue_a',
                proofState: act0FixProofStateReinforcedByLaterEvidenceV1,
                laterEvidenceSessionId: 'session_later',
                laterEvidenceTaskId: '',
                transferVerdict: act0LearningTransferImprovedV1,
                laterEvidenceOrder: 5,
                bankedAtOrder: 2,
                messageKey: 'fix_proof_reinforced_v1',
              ),
            ],
          ),
        );

    expect(projection.observations, isEmpty);
  });

  test('later evidence must occur after repair', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          _fixProofFromHistory(laterOrder: 2, repairOrder: 5),
        );

    expect(projection.observations, isEmpty);
  });

  test('duplicate later evidence does not duplicate observation', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          Act0FixProofProjectionV1(
            proofs: <Act0FixProofItemV1>[
              ..._reinforcedFixProof().proofs,
              ..._reinforcedFixProof().proofs,
            ],
          ),
        );

    expect(projection.observations, hasLength(1));
  });

  test('one repair yields at most one acknowledgement', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          _fixProofFromHistory(laterOrder: 8, laterTaskId: 'task_even_later'),
        );

    expect(projection.observations, hasLength(1));
    expect(
      projection.latestObservation?.sourceRepairId,
      'repair_outcome_v1|2|queue_a',
    );
  });

  test('a second distinct repair may yield a second observation', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          Act0FixProofProjectionV1(
            proofs: <Act0FixProofItemV1>[
              ..._reinforcedFixProof().proofs,
              ..._reinforcedFixProof(
                queueItemId: 'queue_b',
                repairOutcomeRef: 'repair_outcome_v1|3|queue_b',
                repairOrder: 3,
                laterTaskId: 'task_later_b',
                laterOrder: 7,
              ).proofs,
            ],
          ),
        );

    expect(projection.observations, hasLength(2));
    expect(
      projection.latestObservation?.sourceRepairId,
      'repair_outcome_v1|3|queue_b',
    );
  });

  test('projection is deterministic and claim safe', () {
    final source = _reinforcedFixProof();
    final first = Act0SharkyImprovementObservationProjectionV1.fromFixProof(
      source,
    );
    final second = Act0SharkyImprovementObservationProjectionV1.fromFixProof(
      source,
    );

    expect(first.observations, second.observations);
    final text = File(
      'lib/ui_v2/act0_shell/act0_sharky_improvement_observation_v1.dart',
    ).readAsStringSync();
    expect(text, isNot(contains('master')));
    expect(text, isNot(contains('percentage')));
    expect(text, isNot(contains('weakest')));
    expect(text, isNot(contains('AI')));
    expect(text, isNot(contains('score')));
  });

  test('completed session filter only emits matching later session', () {
    final projection =
        Act0SharkyImprovementObservationProjectionV1.fromFixProof(
          _reinforcedFixProof(),
          completedSessionId: 'another_session',
        );

    expect(projection.observations, isEmpty);
  });
}

Act0FixProofProjectionV1 _reinforcedFixProof({
  String queueItemId = 'queue_a',
  String repairOutcomeRef = 'repair_outcome_v1|2|queue_a',
  int repairOrder = 2,
  String laterTaskId = 'task_later',
  int laterOrder = 5,
}) {
  return Act0FixProofProjectionV1(
    proofs: <Act0FixProofItemV1>[
      Act0FixProofItemV1(
        fixProofId: 'fix_proof_v1|$queueItemId',
        queueItemId: queueItemId,
        conceptFamilyId: 'no_bet_yet',
        repairFocusId: 'no_bet_yet',
        sourceTaskId: 'task_source',
        repairSessionId: 'session_repair',
        repairOutcomeRef: repairOutcomeRef,
        proofState: act0FixProofStateReinforcedByLaterEvidenceV1,
        laterEvidenceSessionId: 'session_later',
        laterEvidenceTaskId: laterTaskId,
        transferVerdict: act0LearningTransferImprovedV1,
        laterEvidenceOrder: laterOrder,
        bankedAtOrder: repairOrder,
        messageKey: 'fix_proof_reinforced_v1',
      ),
    ],
  );
}

Act0FixProofProjectionV1 _fixProofFromHistory({
  String baselineConceptFamilyId = 'no_bet_yet',
  String laterConceptFamilyId = 'no_bet_yet',
  String laterTaskId = 'task_later',
  String laterSessionId = 'session_later',
  int repairOrder = 2,
  int laterOrder = 5,
  bool repairCorrect = true,
}) {
  final history = Act0LearningEvidenceHistoryV1(
    records: <Act0LearningEvidenceRecordV1>[
      _learningRecord(
        order: 1,
        conceptFamilyId: baselineConceptFamilyId,
        taskId: 'task_source',
        sessionId: 'session_before',
        isCorrect: false,
      ),
      _learningRecord(
        order: laterOrder,
        conceptFamilyId: laterConceptFamilyId,
        taskId: laterTaskId,
        sessionId: laterSessionId,
        isCorrect: true,
      ),
    ],
  );
  return Act0FixProofProjectionV1.fromSources(
    repairOutcomeProjection: Act0RepairOutcomeProjectionV1(
      outcomes: <Act0RepairOutcomeV1>[
        _outcome(sequence: repairOrder, isCorrect: repairCorrect),
      ],
    ),
    reviewResolutionReceiptHistory: Act0ReviewResolutionReceiptHistoryV1(
      receipts: <Act0ReviewResolutionReceiptV1>[
        _receipt(resolvedAtOrder: repairOrder),
      ],
    ),
    transferMeasurement: Act0LearningTransferMeasurementV1.fromLearningEvidence(
      history,
    ),
  );
}

Act0LearningEvidenceRecordV1 _learningRecord({
  required int order,
  required String conceptFamilyId,
  required String taskId,
  required String sessionId,
  required bool isCorrect,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'record_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'lesson_1',
    taskId: taskId,
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: isCorrect ? 'none' : 'missed_action_read',
    conceptFamilyId: conceptFamilyId,
    repairFocusId: conceptFamilyId,
    skillAtomId: 'action_read',
    decisionTimeBucket: '3_to_10s',
    resultKind: isCorrect ? 'correct' : 'incorrect',
    sessionId: sessionId,
  );
}

Act0RepairOutcomeV1 _outcome({required int sequence, bool isCorrect = true}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'task_source',
    repairTaskId: 'repair_task',
    repairFocusKey: 'no_bet_yet',
    queueItemId: 'queue_a',
    targetWorldId: 'world_1',
    targetLessonId: 'lesson_1',
    targetTaskId: 'repair_task',
    selectedChoiceId: isCorrect ? 'check' : 'fold',
    correctChoiceId: 'check',
    isCorrect: isCorrect,
    outcomeState: isCorrect
        ? act0RepairOutcomeStateCorrectV1
        : act0RepairOutcomeStateStillNeedsRepV1,
    sequence: sequence,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
    sessionId: 'session_repair',
  );
}

Act0ReviewResolutionReceiptV1 _receipt({required int resolvedAtOrder}) {
  return Act0ReviewResolutionReceiptV1(
    reviewItemId: 'review_a',
    conceptFamilyId: 'no_bet_yet',
    sourceTaskId: 'task_source',
    sourceSessionId: 'session_before',
    reviewState: act0ReviewResolutionStateResolvedV1,
    resolutionReason: act0ReviewResolutionReasonRepairSucceededV1,
    repairOutcomeId: 'repair_outcome_v1|$resolvedAtOrder|queue_a',
    resolvedAtOrder: resolvedAtOrder,
  );
}
