import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart';

void main() {
  test(
    'same concept miss then later correct creates a later-correct signal',
    () {
      final projection = Act0RepairTransferProjectionV1.fromLearningEvidence(
        Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _record(order: 1),
            _record(
              order: 3,
              isCorrect: true,
              errorType: 'none',
              resultKind: 'correct',
            ),
          ],
        ),
      );

      final signal = projection.signalForConcept('no_bet_yet');

      expect(signal.state, act0RepairTransferLaterCorrectSignalV1);
      expect(signal.priorMissOrder, 1);
      expect(signal.laterCorrectOrder, 3);
      expect(signal.incorrectCount, 1);
      expect(signal.correctCount, 1);
    },
  );

  test('unrelated correct evidence does not count for missed concept', () {
    final projection = Act0RepairTransferProjectionV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'no_bet_yet'),
          _record(
            order: 2,
            repairFocusId: 'position_clue',
            skillAtomId: 'position_read',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    expect(
      projection.signalForConcept('no_bet_yet').state,
      act0RepairTransferMissStillActiveV1,
    );
    expect(
      projection.signalForConcept('position_clue').state,
      act0RepairTransferNoPriorMissV1,
    );
  });

  test('negative ordering marks concept as insufficient ordering', () {
    final projection = Act0RepairTransferProjectionV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: -1),
          _record(
            order: 2,
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    expect(
      projection.signalForConcept('no_bet_yet').state,
      act0RepairTransferInsufficientOrderingV1,
    );
  });

  test('correct before latest miss does not create later-correct signal', () {
    final projection = Act0RepairTransferProjectionV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
          _record(order: 3),
        ],
      ),
    );

    final signal = projection.signalForConcept('no_bet_yet');

    expect(signal.state, act0RepairTransferMissStillActiveV1);
    expect(signal.priorMissOrder, 3);
    expect(signal.laterCorrectOrder, isNull);
  });

  test(
    'signals are sorted by concept id for deterministic projection order',
    () {
      final projection = Act0RepairTransferProjectionV1.fromLearningEvidence(
        Act0LearningEvidenceHistoryV1(
          records: <Act0LearningEvidenceRecordV1>[
            _record(order: 1, repairFocusId: 'z_focus'),
            _record(order: 2, repairFocusId: 'a_focus'),
          ],
        ),
      );

      expect(
        projection.signals.map((signal) => signal.conceptFamilyId),
        <String>['a_focus', 'z_focus'],
      );
    },
  );

  test('unknown or blank concept lookup returns unmapped concept state', () {
    final projection = Act0RepairTransferProjectionV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[_record(order: 1)],
      ),
    );

    expect(
      projection.signalForConcept('').state,
      act0RepairTransferUnmappedConceptV1,
    );
    expect(
      projection.signalForConcept('missing_focus').state,
      act0RepairTransferUnmappedConceptV1,
    );
  });

  test('projection stays engine-only and claim-safe', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_repair_transfer_projection_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('Navigator')));
    expect(source, isNot(contains('mastered')));
    expect(source, isNot(contains('fixed')));
    expect(source, isNot(contains('solver')));
    expect(source, isNot(contains('GTO')));
  });
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String repairFocusId = 'no_bet_yet',
  String skillAtomId = 'action_read',
  String errorType = 'missed_action_read',
  String decisionTimeBucket = 'under_3s',
  bool isCorrect = false,
  String resultKind = 'incorrect',
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'record_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: errorType,
    repairFocusId: repairFocusId,
    skillAtomId: skillAtomId,
    decisionTimeBucket: decisionTimeBucket,
    resultKind: resultKind,
  );
}
