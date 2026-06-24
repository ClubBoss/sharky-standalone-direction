import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

void main() {
  test('serializes a deterministic learning evidence record', () {
    const record = Act0LearningEvidenceRecordV1(
      recordId: '1:world_1:actions_legal_context:fold',
      createdOrder: 1,
      worldId: 'world_1',
      lessonId: 'fold_check_call_raise',
      taskId: 'actions_legal_context',
      choiceId: 'fold',
      expectedChoiceId: 'check',
      isCorrect: false,
      errorType: 'missed_action_read',
      repairFocusId: 'no_bet_yet',
      skillAtomId: 'action_read',
      decisionTimeBucket: '3_to_10s',
      resultKind: 'incorrect',
    );

    expect(Act0LearningEvidenceRecordV1.tryParse(record.toPayload()), record);
    expect(record.toPayload(), isNot(containsPair('mastery', anything)));
    expect(record.toPayload(), isNot(containsPair('leak', anything)));
  });

  test(
    'history keeps latest records in deterministic order and answers queries',
    () {
      var history = const Act0LearningEvidenceHistoryV1();
      history = history.append(_record(order: 1, skillAtomId: 'action_read'));
      history = history.append(
        _record(
          order: 2,
          skillAtomId: 'action_read',
          repairFocusId: 'no_bet_yet',
        ),
      );
      history = history.append(
        _record(
          order: 3,
          skillAtomId: 'position_read',
          resultKind: 'correct',
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
        ),
      );

      expect(history.lastN(2).map((record) => record.createdOrder), <int>[
        2,
        3,
      ]);
      expect(history.bySkillAtom('action_read'), hasLength(2));
      expect(history.byRepairFocus('no_bet_yet'), hasLength(2));
      expect(history.mistakes(), hasLength(2));
    },
  );

  test('history ignores malformed records and bounds retained evidence', () {
    final records = <Map<String, Object?>>[
      _record(order: 1).toPayload(),
      <String, Object?>{'schemaVersion': 1},
    ];
    final decoded = Act0LearningEvidenceHistoryV1.tryParse(records);

    expect(decoded?.records, hasLength(1));

    var history = const Act0LearningEvidenceHistoryV1();
    for (
      var order = 1;
      order <= Act0LearningEvidenceHistoryV1.maxRecords + 1;
      order++
    ) {
      history = history.append(_record(order: order));
    }
    expect(
      history.records,
      hasLength(Act0LearningEvidenceHistoryV1.maxRecords),
    );
    expect(history.records.first.createdOrder, 2);
  });
}

Act0LearningEvidenceRecordV1 _record({
  required int order,
  String skillAtomId = 'action_read',
  String repairFocusId = 'no_bet_yet',
  String resultKind = 'incorrect',
  bool isCorrect = false,
  String errorType = 'missed_action_read',
}) {
  return Act0LearningEvidenceRecordV1(
    recordId: '$order:world_1:actions_legal_context:fold',
    createdOrder: order,
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: 'actions_legal_context',
    choiceId: 'fold',
    expectedChoiceId: isCorrect ? 'fold' : 'check',
    isCorrect: isCorrect,
    errorType: errorType,
    repairFocusId: repairFocusId,
    skillAtomId: skillAtomId,
    decisionTimeBucket: 'under_3s',
    resultKind: resultKind,
  );
}
