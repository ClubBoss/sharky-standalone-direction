import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart';

void main() {
  test('miss then later correct on different same-family task improves', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, taskId: 'actions_open_intro'),
          _record(
            order: 4,
            taskId: 'actions_check_transfer',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
            sessionId: 'session_v1|2',
            decisionTimeBucket: 'under_3s',
          ),
        ],
      ),
    );

    final signal = measurement.signalForConcept('no_bet_yet');

    expect(signal.relationship, act0LearningTransferSameFamilyTransferV1);
    expect(signal.verdict, act0LearningTransferImprovedV1);
    expect(signal.baselineOrder, 1);
    expect(signal.comparisonOrder, 4);
    expect(signal.baselineTaskId, 'actions_open_intro');
    expect(signal.comparisonTaskId, 'actions_check_transfer');
    expect(signal.baselineSessionId, 'session_v1|1');
    expect(signal.comparisonSessionId, 'session_v1|2');
  });

  test('exact task repeat is classified separately and is not transfer', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, taskId: 'actions_open_intro'),
          _record(
            order: 2,
            taskId: 'actions_open_intro',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
            sessionId: 'session_v1|2',
          ),
        ],
      ),
    );

    final signal = measurement.signalForConcept('no_bet_yet');

    expect(signal.relationship, act0LearningTransferSameTaskRepeatV1);
    expect(signal.verdict, act0LearningTransferInsufficientEvidenceV1);
  });

  test('same-session later correct is insufficient for transfer', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, taskId: 'actions_open_intro'),
          _record(
            order: 2,
            taskId: 'actions_check_transfer',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
          ),
        ],
      ),
    );

    final signal = measurement.signalForConcept('no_bet_yet');

    expect(signal.relationship, act0LearningTransferInsufficientEvidenceV1);
    expect(signal.verdict, act0LearningTransferInsufficientEvidenceV1);
  });

  test('missing session linkage is insufficient for transfer', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, sessionId: ''),
          _record(
            order: 2,
            taskId: 'actions_check_transfer',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
            sessionId: 'session_v1|2',
          ),
        ],
      ),
    );

    final signal = measurement.signalForConcept('no_bet_yet');

    expect(signal.relationship, act0LearningTransferInsufficientEvidenceV1);
    expect(signal.verdict, act0LearningTransferInsufficientEvidenceV1);
  });

  test('later incorrect same-family transfer is not yet improved', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, taskId: 'actions_open_intro'),
          _record(
            order: 3,
            taskId: 'actions_check_transfer',
            sessionId: 'session_v1|2',
          ),
        ],
      ),
    );

    final signal = measurement.signalForConcept('no_bet_yet');

    expect(signal.relationship, act0LearningTransferSameFamilyTransferV1);
    expect(signal.verdict, act0LearningTransferNotYetImprovedV1);
  });

  test('correct baseline then later correct same-family transfer holds', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            taskId: 'actions_open_intro',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
          ),
          _record(
            order: 3,
            taskId: 'actions_check_transfer',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
            sessionId: 'session_v1|2',
          ),
        ],
      ),
    );

    expect(
      measurement.signalForConcept('no_bet_yet').verdict,
      act0LearningTransferHeldV1,
    );
  });

  test('decision-time-only speedup does not create improvement', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(
            order: 1,
            taskId: 'actions_open_intro',
            decisionTimeBucket: 'over_10s',
          ),
          _record(
            order: 3,
            taskId: 'actions_check_transfer',
            decisionTimeBucket: 'under_3s',
            sessionId: 'session_v1|2',
          ),
        ],
      ),
    );

    final signal = measurement.signalForConcept('no_bet_yet');

    expect(signal.verdict, act0LearningTransferNotYetImprovedV1);
    expect(signal.baselineDecisionTimeBucket, 'over_10s');
    expect(signal.comparisonDecisionTimeBucket, 'under_3s');
  });

  test('different concept family cannot improve missed family', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, conceptFamilyId: 'no_bet_yet'),
          _record(
            order: 2,
            conceptFamilyId: 'position_read',
            taskId: 'position_transfer',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
            sessionId: 'session_v1|2',
          ),
        ],
      ),
    );

    expect(
      measurement.signalForConcept('no_bet_yet').verdict,
      act0LearningTransferInsufficientEvidenceV1,
    );
    expect(
      measurement.signalForConcept('position_read').verdict,
      act0LearningTransferInsufficientEvidenceV1,
    );
  });

  test('latest eligible comparison wins deterministically', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, taskId: 'actions_open_intro'),
          _record(
            order: 2,
            taskId: 'actions_check_transfer',
            sessionId: 'session_v1|2',
          ),
          _record(
            order: 5,
            taskId: 'actions_raise_transfer',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
            sessionId: 'session_v1|3',
          ),
        ],
      ),
    );

    final signal = measurement.signalForConcept('no_bet_yet');

    expect(signal.verdict, act0LearningTransferImprovedV1);
    expect(signal.comparisonOrder, 5);
    expect(signal.comparisonTaskId, 'actions_raise_transfer');
  });

  test('negative or tied ordering is insufficient evidence', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, taskId: 'actions_open_intro'),
          _record(
            order: 1,
            taskId: 'actions_check_transfer',
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
            sessionId: 'session_v1|2',
          ),
          _record(order: -1, taskId: 'actions_raise_transfer'),
        ],
      ),
    );

    expect(
      measurement.signalForConcept('no_bet_yet').verdict,
      act0LearningTransferInsufficientEvidenceV1,
    );
  });

  test('signals are sorted by concept id and unmapped lookup is stable', () {
    final measurement = Act0LearningTransferMeasurementV1.fromLearningEvidence(
      Act0LearningEvidenceHistoryV1(
        records: <Act0LearningEvidenceRecordV1>[
          _record(order: 1, conceptFamilyId: 'z_family'),
          _record(order: 2, conceptFamilyId: 'a_family'),
        ],
      ),
    );

    expect(
      measurement.signals.map((signal) => signal.conceptFamilyId),
      <String>['a_family', 'z_family'],
    );
    expect(
      measurement.signalForConcept('missing').verdict,
      act0LearningTransferInsufficientEvidenceV1,
    );
  });

  test('projection is engine-only and claim-safe', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_learning_transfer_measurement_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('Navigator')));
    expect(source, isNot(contains('SharedPreferences')));
    expect(source, isNot(contains('Telemetry')));
    expect(source, isNot(contains('mastered')));
    expect(source, isNot(contains('personalized')));
    expect(source, isNot(contains('GTO')));
    expect(source, isNot(contains('solver')));
  });
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String conceptFamilyId = 'no_bet_yet',
  String taskId = 'actions_legal_context',
  String sessionId = 'session_v1|1',
  String decisionTimeBucket = '3_to_10s',
  bool isCorrect = false,
  String resultKind = 'incorrect',
  String errorType = 'missed_action_read',
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
    errorType: errorType,
    conceptFamilyId: conceptFamilyId,
    repairFocusId: conceptFamilyId,
    skillAtomId: 'action_read',
    decisionTimeBucket: decisionTimeBucket,
    resultKind: resultKind,
    sessionId: sessionId,
  );
}
