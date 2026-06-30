import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_action_transfer_join_projection_v1.dart';

void main() {
  test('later correct without repair run evidence stays non-causal', () {
    final projection = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
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

    expect(
      signal.state,
      act0PracticeActionTransferLaterCorrectWithoutPracticeEvidenceV1,
    );
    expect(signal.priorMissOrder, 1);
    expect(signal.laterCorrectOrder, 3);
    expect(signal.practiceEvidenceOrder, isNull);
  });

  test('repair run evidence before later correct joins same concept', () {
    final projection = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1),
          _record(order: 2, runKind: 'repair'),
          _record(
            order: 4,
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    final signal = projection.signalForConcept('no_bet_yet');

    expect(signal.state, act0PracticeActionTransferPracticeBeforeCorrectV1);
    expect(signal.practiceEvidenceOrder, 2);
    expect(signal.laterCorrectOrder, 4);
  });

  test('repair run evidence after later correct does not count as prior', () {
    final projection = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1),
          _record(
            order: 3,
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
          _record(
            order: 5,
            runKind: 'repair',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    final signal = projection.signalForConcept('no_bet_yet');

    expect(signal.state, act0PracticeActionTransferPracticeAfterCorrectV1);
    expect(signal.practiceEvidenceOrder, 5);
    expect(signal.laterCorrectOrder, 3);
  });

  test('unrelated repair target does not count for later-correct concept', () {
    final projection = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, repairFocusId: 'no_bet_yet'),
          _record(
            order: 2,
            repairFocusId: 'position_clue',
            skillAtomId: 'position_read',
            runKind: 'repair',
          ),
          _record(
            order: 4,
            repairFocusId: 'no_bet_yet',
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    expect(
      projection.signalForConcept('no_bet_yet').state,
      act0PracticeActionTransferUnrelatedPracticeTargetV1,
    );
  });

  test('missing later correct remains insufficient evidence', () {
    final projection = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1),
          _record(order: 2, runKind: 'repair'),
        ],
      ),
    );

    expect(
      projection.signalForConcept('no_bet_yet').state,
      act0PracticeActionTransferInsufficientEvidenceV1,
    );
  });

  test('negative repair run ordering is unordered practice evidence', () {
    final projection = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1),
          _record(order: -1, runKind: 'repair'),
          _record(
            order: 4,
            isCorrect: true,
            errorType: 'none',
            resultKind: 'correct',
          ),
        ],
      ),
    );

    expect(
      projection.signalForConcept('no_bet_yet').state,
      act0PracticeActionTransferPracticeEvidenceUnorderedV1,
    );
  });

  test('unknown concept lookup is insufficient evidence', () {
    final projection = Act0PracticeActionTransferJoinProjectionV1.fromEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[_record(order: 1)],
      ),
    );

    expect(
      projection.signalForConcept('missing_focus').state,
      act0PracticeActionTransferInsufficientEvidenceV1,
    );
  });

  test('join projection stays engine-only and claim-safe', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_practice_action_transfer_join_projection_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('Navigator')));
    expect(source, isNot(contains('caused')));
    expect(source, isNot(contains('proven')));
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
  String runKind = 'lesson',
  bool isCorrect = false,
  String resultKind = 'incorrect',
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: 'record_$order',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: runKind == 'repair'
        ? 'actions_check_drill'
        : 'actions_legal_context',
    choiceId: isCorrect ? 'check' : 'fold',
    expectedChoiceId: 'check',
    isCorrect: isCorrect,
    errorType: errorType,
    repairFocusId: repairFocusId,
    skillAtomId: skillAtomId,
    decisionTimeBucket: 'under_3s',
    resultKind: resultKind,
    runId: 'run_$order',
    runKind: runKind,
    runOrdinal: order < 0 ? null : order,
  );
}
