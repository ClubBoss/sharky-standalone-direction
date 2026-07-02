import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_outcome_projection_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_resolution_contract_v1.dart';

void main() {
  test('successful exact repair creates one banked fix', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 4, queueItemId: 'queue_a', sessionId: 'session_2'),
      ]),
      reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 4),
      ]),
    );

    expect(projection.proofs, hasLength(1));
    expect(
      projection.proofs.single.proofState,
      act0FixProofStateRepairCompletedV1,
    );
    expect(projection.proofs.single.fixProofId, 'fix_proof_v1|queue_a');
    expect(projection.proofs.single.repairSessionId, 'session_2');
    expect(projection.aggregate.completedFixCount, 1);
    expect(projection.aggregate.reinforcedFixCount, 0);
    expect(projection.aggregate.distinctConceptFamilyCount, 1);
    expect(
      projection.aggregate.windowDescriptor,
      act0FixProofRecentSessionWindowV1,
    );
  });

  test('failed repair creates no banked fix', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(
          sequence: 1,
          queueItemId: 'queue_a',
          isCorrect: false,
          state: act0RepairOutcomeStateStillNeedsRepV1,
        ),
      ]),
      reviewResolutionReceiptHistory:
          const Act0ReviewResolutionReceiptHistoryV1(),
    );

    expect(projection.proofs, isEmpty);
    expect(projection.aggregate.completedFixCount, 0);
  });

  test('duplicate successful reads remain idempotent by exact identity', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 1, queueItemId: 'queue_a', sessionId: 'session_1'),
        _outcome(sequence: 3, queueItemId: 'queue_a', sessionId: 'session_3'),
      ]),
      reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 1),
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 3),
      ]),
    );

    expect(projection.proofs, hasLength(1));
    expect(projection.proofs.single.bankedAtOrder, 3);
    expect(projection.proofs.single.repairSessionId, 'session_3');
  });

  test(
    'unrelated repair success without resolved receipt does not create proof',
    () {
      final projection = Act0FixProofProjectionV1.fromSources(
        repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
          _outcome(sequence: 1, queueItemId: 'queue_a'),
        ]),
        reviewResolutionReceiptHistory: _receipts(
          <Act0ReviewResolutionReceiptV1>[
            _receipt(queueItemId: 'queue_b', resolvedAtOrder: 1),
          ],
        ),
      );

      expect(projection.proofs, isEmpty);
    },
  );

  test('malformed identity fails closed', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 1, queueItemId: 'queue_a'),
      ]),
      reviewResolutionReceiptHistory:
          const Act0ReviewResolutionReceiptHistoryV1(
            receipts: <Act0ReviewResolutionReceiptV1>[
              Act0ReviewResolutionReceiptV1(
                reviewItemId: 'review_a',
                conceptFamilyId: 'no_bet_yet',
                reviewState: act0ReviewResolutionStateResolvedV1,
                resolutionReason: act0ReviewResolutionReasonRepairSucceededV1,
                repairOutcomeId: 'malformed',
                resolvedAtOrder: 1,
              ),
            ],
          ),
    );

    expect(projection.proofs, isEmpty);
  });

  test('later eligible transfer upgrades completed to reinforced', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _learningRecord(
          order: 1,
          taskId: 'actions_legal_context',
          sessionId: 'session_1',
        ),
        _learningRecord(
          order: 5,
          taskId: 'actions_check_drill',
          sessionId: 'session_3',
          isCorrect: true,
        ),
      ],
    );
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 2, queueItemId: 'queue_a', sessionId: 'session_2'),
      ]),
      reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 2),
      ]),
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(history),
    );

    expect(
      projection.proofs.single.proofState,
      act0FixProofStateReinforcedByLaterEvidenceV1,
    );
    expect(projection.proofs.single.laterEvidenceSessionId, 'session_3');
    expect(
      projection.proofs.single.transferVerdict,
      act0LearningTransferImprovedV1,
    );
    expect(projection.aggregate.reinforcedFixCount, 1);
    expect(
      projection.aggregate.lines,
      contains('1 completed repair now has later supporting evidence'),
    );
  });

  test('same-task repeat does not create reinforced status', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _learningRecord(
          order: 1,
          taskId: 'actions_legal_context',
          sessionId: 'session_1',
        ),
        _learningRecord(
          order: 5,
          taskId: 'actions_legal_context',
          sessionId: 'session_3',
          isCorrect: true,
        ),
      ],
    );
    final projection = _singleProofProjection(
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(history),
    );

    expect(
      projection.proofs.single.proofState,
      act0FixProofStateRepairCompletedV1,
    );
    expect(projection.aggregate.reinforcedFixCount, 0);
  });

  test('same-session evidence does not reinforce', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _learningRecord(
          order: 1,
          taskId: 'actions_legal_context',
          sessionId: 'session_2',
        ),
        _learningRecord(
          order: 5,
          taskId: 'actions_check_drill',
          sessionId: 'session_2',
          isCorrect: true,
        ),
      ],
    );
    final projection = _singleProofProjection(
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(history),
    );

    expect(
      projection.proofs.single.proofState,
      act0FixProofStateRepairCompletedV1,
    );
  });

  test('different family does not reinforce', () {
    final history = Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        _learningRecord(
          order: 1,
          conceptFamilyId: 'open_pot',
          sessionId: 'session_1',
        ),
        _learningRecord(
          order: 5,
          conceptFamilyId: 'open_pot',
          taskId: 'open_raise_drill',
          sessionId: 'session_3',
          isCorrect: true,
        ),
      ],
    );
    final projection = _singleProofProjection(
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(history),
    );

    expect(
      projection.proofs.single.proofState,
      act0FixProofStateRepairCompletedV1,
    );
  });

  test('one proof counts once in aggregate', () {
    final projection = _singleProofProjection();

    expect(projection.aggregate.completedFixCount, 1);
    expect(projection.aggregate.recentProofItems, hasLength(1));
  });

  test('multiple exact fixes in one family count separately', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 1, queueItemId: 'queue_a'),
        _outcome(sequence: 2, queueItemId: 'queue_b'),
      ]),
      reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 1),
        _receipt(queueItemId: 'queue_b', resolvedAtOrder: 2),
      ]),
    );

    expect(projection.aggregate.completedFixCount, 2);
    expect(projection.aggregate.distinctConceptFamilyCount, 1);
  });

  test('distinct-family count deduplicates by family', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 1, queueItemId: 'queue_a'),
        _outcome(
          sequence: 2,
          queueItemId: 'queue_b',
          repairFocusKey: 'open_pot',
        ),
      ]),
      reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 1),
        _receipt(
          queueItemId: 'queue_b',
          conceptFamilyId: 'open_pot',
          resolvedAtOrder: 2,
        ),
      ]),
    );

    expect(projection.aggregate.completedFixCount, 2);
    expect(projection.aggregate.distinctConceptFamilyCount, 2);
  });

  test('recent session window excludes old proof deterministically', () {
    final outcomes = <Act0RepairOutcomeV1>[];
    final receipts = <Act0ReviewResolutionReceiptV1>[];
    for (var index = 1; index <= 8; index += 1) {
      outcomes.add(
        _outcome(
          sequence: index,
          queueItemId: 'queue_$index',
          sessionId: 'session_v1|$index',
        ),
      );
      receipts.add(
        _receipt(queueItemId: 'queue_$index', resolvedAtOrder: index),
      );
    }
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(outcomes),
      reviewResolutionReceiptHistory: _receipts(receipts),
      recentSessionLimit: 7,
    );

    expect(projection.aggregate.completedFixCount, 7);
    expect(
      projection.aggregate.recentProofItems.map((proof) => proof.queueItemId),
      isNot(contains('queue_1')),
    );
  });

  test('ordering is deterministic', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 2, queueItemId: 'queue_b'),
        _outcome(sequence: 5, queueItemId: 'queue_a'),
      ]),
      reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
        _receipt(queueItemId: 'queue_b', resolvedAtOrder: 2),
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 5),
      ]),
    );

    expect(
      projection.aggregate.recentProofItems.map((proof) => proof.queueItemId),
      <String>['queue_a', 'queue_b'],
    );
  });

  test('resolved historical proof survives reload', () {
    final first = _singleProofProjection();
    final second = Act0FixProofProjectionV1.tryParse(first.toPayload());

    expect(second.toPayload(), first.toPayload());
  });

  test('old state loads safely', () {
    final parsed = Act0FixProofProjectionV1.tryParse(<String, Object?>{
      'schemaVersion': 1,
      'proofs': <Object?>[
        <String, Object?>{
          'schemaVersion': 1,
          'fixProofId': 'fix_proof_v1|queue_a',
          'queueItemId': 'queue_a',
          'conceptFamilyId': 'no_bet_yet',
          'repairSessionId': 'session_2',
          'repairOutcomeRef': 'repair_outcome_v1|2|queue_a',
          'proofState': act0FixProofStateRepairCompletedV1,
          'bankedAtOrder': 2,
          'messageKey': 'fix_proof_repair_completed_v1',
        },
        <String, Object?>{'bad': true},
      ],
    });

    expect(parsed.proofs, hasLength(1));
    expect(parsed.aggregate.completedFixCount, 1);
  });

  test('failed later attempt does not erase completed proof', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: _repairOutcomes(<Act0RepairOutcomeV1>[
        _outcome(sequence: 1, queueItemId: 'queue_a'),
        _outcome(
          sequence: 3,
          queueItemId: 'queue_a',
          isCorrect: false,
          state: act0RepairOutcomeStateStillNeedsRepV1,
        ),
      ]),
      reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
        _receipt(queueItemId: 'queue_a', resolvedAtOrder: 1),
      ]),
    );

    expect(
      projection.proofs.single.proofState,
      act0FixProofStateRepairCompletedV1,
    );
    expect(projection.aggregate.completedFixCount, 1);
  });

  test('Review resolved item does not reappear', () {
    final projection = _singleProofProjection();

    expect(
      projection.proofs.single.proofState,
      isNot(act0FixProofStateInsufficientEvidenceV1),
    );
    expect(projection.toPayload().toString(), isNot(contains('unresolved')));
  });

  test('queue ordering and contents remain unchanged by derivation', () {
    final repairOutcomes = _repairOutcomes(<Act0RepairOutcomeV1>[
      _outcome(sequence: 1, queueItemId: 'queue_a'),
    ]);
    final before = repairOutcomes.toPayload();

    _singleProofProjection(repairOutcomeProjection: repairOutcomes);

    expect(repairOutcomes.toPayload(), before);
  });

  test('copy is claim safe', () {
    final projection = _singleProofProjection();
    final text = projection.toPayload().toString();

    for (final forbidden in <String>[
      'master',
      'score',
      '%',
      'weakest',
      'AI',
      'leak',
      'level',
      'rating',
      'fixed forever',
    ]) {
      expect(text, isNot(contains(forbidden)));
    }
  });

  test('fallback remains when no proof exists', () {
    final projection = Act0FixProofProjectionV1.fromSources(
      repairOutcomeProjection: const Act0RepairOutcomeProjectionV1(),
      reviewResolutionReceiptHistory:
          const Act0ReviewResolutionReceiptHistoryV1(),
    );

    expect(projection.aggregate.lines, isEmpty);
    expect(projection.aggregate.recentProofItems, isEmpty);
  });

  test('rendering does not mutate proof state', () {
    final projection = _singleProofProjection();
    final before = projection.toPayload();

    projection.aggregate.lines.join(' ');
    projection.aggregate.recentProofItems.toList(growable: false);

    expect(projection.toPayload(), before);
  });

  test('source owns no telemetry persistence or dashboard', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_fix_proof_projection_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('telemetry')));
    expect(source, isNot(contains('dashboard')));
    expect(source, isNot(contains('percentage')));
  });
}

Act0FixProofProjectionV1 _singleProofProjection({
  Act0RepairOutcomeProjectionV1? repairOutcomeProjection,
  Act0LearningTransferMeasurementV1? transferMeasurement,
}) {
  return Act0FixProofProjectionV1.fromSources(
    repairOutcomeProjection:
        repairOutcomeProjection ??
        _repairOutcomes(<Act0RepairOutcomeV1>[
          _outcome(sequence: 2, queueItemId: 'queue_a', sessionId: 'session_2'),
        ]),
    reviewResolutionReceiptHistory: _receipts(<Act0ReviewResolutionReceiptV1>[
      _receipt(queueItemId: 'queue_a', resolvedAtOrder: 2),
    ]),
    transferMeasurement: transferMeasurement,
  );
}

Act0RepairOutcomeProjectionV1 _repairOutcomes(
  List<Act0RepairOutcomeV1> outcomes,
) => Act0RepairOutcomeProjectionV1(outcomes: outcomes);

Act0ReviewResolutionReceiptHistoryV1 _receipts(
  List<Act0ReviewResolutionReceiptV1> receipts,
) => Act0ReviewResolutionReceiptHistoryV1(receipts: receipts);

Act0ReviewResolutionReceiptV1 _receipt({
  required String queueItemId,
  int resolvedAtOrder = 2,
  String conceptFamilyId = 'no_bet_yet',
}) {
  return Act0ReviewResolutionReceiptV1(
    reviewItemId: 'review_$queueItemId',
    conceptFamilyId: conceptFamilyId,
    sourceTaskId: 'actions_legal_context',
    sourceSessionId: 'session_1',
    reviewState: act0ReviewResolutionStateResolvedV1,
    resolutionReason: act0ReviewResolutionReasonRepairSucceededV1,
    repairOutcomeId: 'repair_outcome_v1|$resolvedAtOrder|$queueItemId',
    resolvedAtOrder: resolvedAtOrder,
  );
}

Act0RepairOutcomeV1 _outcome({
  required int sequence,
  required String queueItemId,
  String sessionId = 'session_2',
  String repairFocusKey = 'no_bet_yet',
  bool? isCorrect = true,
  String state = act0RepairOutcomeStateCorrectV1,
}) {
  return Act0RepairOutcomeV1(
    sourceTaskId: 'actions_legal_context',
    repairTaskId: 'actions_check_drill',
    repairFocusKey: repairFocusKey,
    queueItemId: queueItemId,
    targetWorldId: 'world_1',
    targetLessonId: 'fold_check_call_raise',
    targetTaskId: 'actions_check_drill',
    selectedChoiceId: isCorrect == true ? 'check' : 'fold',
    correctChoiceId: 'check',
    isCorrect: isCorrect,
    outcomeState: state,
    sequence: sequence,
    sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
    sessionId: sessionId,
  );
}

Act0LearningEvidenceRecordV1 _learningRecord({
  required int order,
  required String sessionId,
  String conceptFamilyId = 'no_bet_yet',
  String taskId = 'actions_legal_context',
  bool isCorrect = false,
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'record_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: taskId,
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: isCorrect ? 'none' : 'missed_action_read',
    conceptFamilyId: conceptFamilyId,
    repairFocusId: conceptFamilyId,
    skillAtomId: 'action_read',
    decisionTimeBucket: 'under_3s',
    resultKind: isCorrect ? 'correct' : 'incorrect',
    sessionId: sessionId,
  );
}
