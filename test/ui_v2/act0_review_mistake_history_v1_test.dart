import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_completed_decision_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_repair_intent_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_review_mistake_history_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

void main() {
  test('projection includes only completed non-correct decisions', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(_decision(attempt: 1))
        .appendCompletedDecision(
          _decision(
            attempt: 2,
            isCorrect: true,
            resultKind: 'correct',
            errorType: 'none',
          ),
        )
        .appendCompletedDecision(_decision(attempt: 3, expectedId: null));

    expect(history.records, hasLength(1));
    expect(history.records.single.sourceDecisionId, contains('|fold|1'));
    expect(history.records.single.resultKind, 'incorrect');
  });

  test('repeated source mistake coalesces deterministically', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(_decision(attempt: 1))
        .appendCompletedDecision(
          _decision(attempt: 2, selectedId: 'bet', resultKind: 'suboptimal'),
        );

    expect(history.records, hasLength(1));
    final record = history.records.single;
    expect(record.sourceDecisionId, contains('|bet|2'));
    expect(record.selectedId, 'bet');
    expect(record.resultKind, 'suboptimal');
    expect(record.attemptRecordIds, hasLength(2));
    expect(record.createdOrder, 1);
    expect(record.updatedOrder, 2);

    final duplicate = history.appendCompletedDecision(
      _decision(attempt: 2, selectedId: 'bet', resultKind: 'suboptimal'),
    );
    expect(duplicate, same(history));
  });

  test('fallback dedup key stays stable when concept fields are absent', () {
    final first = _decision(
      attempt: 1,
      errorType: null,
      skillAtomId: null,
      repairFocusId: null,
      missedSignalId: null,
    );
    final second = _decision(
      attempt: 2,
      errorType: null,
      skillAtomId: null,
      repairFocusId: null,
      missedSignalId: null,
    );

    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(first)
        .appendCompletedDecision(second);

    expect(history.records, hasLength(1));
    expect(history.records.single.sourceTaskId, first.sourceTaskId);
    expect(history.records.single.dedupUsesFallback, isTrue);
  });

  test('history retains the latest 200 deduplicated records newest first', () {
    var history = const Act0ReviewMistakeHistoryV1();
    for (
      var index = 1;
      index <= Act0ReviewMistakeHistoryV1.maxRecords + 1;
      index++
    ) {
      history = history.appendCompletedDecision(
        _decision(
          attempt: index,
          taskId: 'task_$index',
          sourceTaskId: 'source_$index',
          repairFocusId: 'focus_$index',
        ),
      );
    }

    expect(history.records, hasLength(Act0ReviewMistakeHistoryV1.maxRecords));
    expect(history.records.first.updatedOrder, 201);
    expect(history.records.last.updatedOrder, 2);
    expect(
      history.records.any((record) => record.sourceTaskId == 'source_1'),
      isFalse,
    );
  });

  test('all records remain unresolved only', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(_decision(attempt: 1))
        .appendCompletedDecision(
          _decision(
            attempt: 2,
            sourceTaskId: 'other_source',
            taskId: 'other_task',
          ),
        );

    expect(history.records.map((record) => record.state).toSet(), <String>{
      act0ReviewMistakeStateUnresolvedOnlyV1,
    });
    expect(history.toStorageString(), isNot(contains('resolved_by')));
    expect(history.toStorageString(), isNot(contains('fixed')));
    expect(history.toStorageString(), isNot(contains('cleared')));
  });

  test('serializer round-trips and rejects resolved or malformed records', () {
    final history = const Act0ReviewMistakeHistoryV1()
        .appendCompletedDecision(
          _decision(attempt: 1),
          runId: 'run_v1|world_1|lesson|repair|1',
          runKind: 'repair',
          runOrdinal: 1,
        )
        .appendCompletedDecision(
          _decision(
            attempt: 2,
            sourceTaskId: 'other_source',
            taskId: 'other_task',
          ),
        );

    final parsed = Act0ReviewMistakeHistoryV1.tryParseStorageString(
      history.toStorageString(),
    );
    expect(parsed, history);

    final invalid = history.records.first.toPayload()
      ..['state'] = 'resolved_by_repair_v1';
    expect(Act0ReviewMistakeRecordV1.tryParse(invalid), isNull);
    expect(Act0ReviewMistakeRecordV1.tryParse(<String, Object?>{}), isNull);
  });

  test('projection does not mutate or replace active repair ownership', () {
    const intent = Act0RepairIntentV1(
      sourceWorldId: 'world_1',
      sourceLessonId: 'fold_check_call_raise',
      sourceTaskId: 'actions_legal_context',
      choiceId: 'fold',
      result: 'incorrect',
      errorType: 'missed_action_read',
      missedSignalId: 'no_bet_yet',
      missedSignalLabel: 'No bet yet',
      skillAtomId: 'action_read',
      skillLabel: 'Action read',
      targetWorldId: 'world_1',
      targetLessonId: 'fold_check_call_raise',
      targetTaskId: 'actions_check_drill',
      mappingType: 'repair',
      reasonCode: 'same_signal_action_read_no_bet_yet',
    );
    final before = intent.toPayload();

    final history = const Act0ReviewMistakeHistoryV1().appendCompletedDecision(
      _decision(attempt: 1),
    );

    expect(history.records, hasLength(1));
    expect(intent.toPayload(), before);
    expect(history.records.single.sourceTaskId, intent.sourceTaskId);
  });

  test('projection source has no Flutter or Review UI dependency', () {
    final source = File(
      'lib/ui_v2/act0_shell/act0_review_mistake_history_v1.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('package:flutter/')));
    expect(source, isNot(contains('act0_review_shell_v1.dart')));
    expect(source, isNot(contains('Act0ReviewStateV1')));
    expect(source, isNot(contains('Act0MistakeCardV1')));
  });
}

Act0CompletedDecisionV1 _decision({
  required int attempt,
  String taskId = 'actions_legal_context',
  String sourceTaskId = 'actions_legal_context',
  String selectedId = 'fold',
  String? expectedId = 'check',
  bool isCorrect = false,
  String resultKind = 'incorrect',
  String? errorType = 'missed_action_read',
  String? skillAtomId = 'action_read',
  String? repairFocusId = 'no_bet_yet',
  String? missedSignalId = 'no_bet_yet',
}) {
  return Act0CompletedDecisionV1(
    attemptKey:
        'v1|world_1|fold_check_call_raise|$taskId|actionList|$selectedId|$attempt',
    worldId: 'world_1',
    lessonId: 'fold_check_call_raise',
    taskId: taskId,
    sourceTaskId: sourceTaskId,
    decisionKind: Act0CompletedDecisionKindV1.actionList,
    selectedId: selectedId,
    expectedId: expectedId,
    isCorrect: isCorrect,
    decisionTimeBucket: 'under_3s',
    taskFamily: Act0TaskFamilyV1.decision,
    resultKind: resultKind,
    errorType: errorType,
    skillAtomId: skillAtomId,
    repairFocusId: repairFocusId,
    missedSignalId: missedSignalId,
  );
}
