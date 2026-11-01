import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_learning_time_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_durable_retention_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

/// A Learn replay of an already answered task is an exact replay, never a
/// second "initial assessment" (found natively on the 14 Pro replay route).
Act0LearningEvidenceRecordV1 _record({
  required String recordId,
  required String taskId,
  required String runKind,
  int createdOrder = 1,
  String skillAtomId = 'board_read',
}) => Act0LearningEvidenceRecordV1.tryParse({
  'schemaVersion': 1,
  'recordId': recordId,
  'createdOrder': createdOrder,
  'worldId': 'world_1',
  'lessonId': 'your_first_hand',
  'taskId': taskId,
  'sourceTaskId': taskId,
  'choiceId': 'three',
  'expectedChoiceId': 'three',
  'isCorrect': true,
  'errorType': 'none',
  'conceptFamilyId': '',
  'repairFocusId': '',
  'skillAtomId': skillAtomId,
  'decisionTimeBucket': 'under_3s',
  'resultKind': 'correct',
  'assistanceKind': 'none',
  'runId': 'run_v1|world_1|your_first_hand|$runKind|1',
  'runKind': runKind,
  'runOrdinal': 1,
  'sourceWorldId': 'world_1',
  'sourceLessonId': 'your_first_hand',
  'startedBy': runKind == 'placement' ? 'placement_diagnostic' : 'learn_route',
  'sessionId': 'session_v1|1',
  'recordedAtUtc': '2026-11-01T00:00:00.000Z',
  'reviewKind': 'initialAssessment',
})!;

void main() {
  test('a task answered before in a lesson is an exact replay', () {
    final earlier = _record(
      recordId: 'a',
      taskId: 'your_first_hand_flop',
      runKind: 'lesson',
    );
    expect(
      act0IsExactTaskReplayV1(
        [earlier],
        taskId: 'your_first_hand_flop',
        attemptKey: 'b',
      ),
      isTrue,
    );
  });

  test('the first answer, another task, or placement-only history is not', () {
    final earlier = _record(
      recordId: 'a',
      taskId: 'your_first_hand_flop',
      runKind: 'lesson',
    );
    final placement = _record(
      recordId: 'p',
      taskId: 'what_poker_is_table_read_transfer',
      runKind: 'placement',
    );
    expect(
      act0IsExactTaskReplayV1(
        const [],
        taskId: 'your_first_hand_flop',
        attemptKey: 'a',
      ),
      isFalse,
    );
    expect(
      act0IsExactTaskReplayV1(
        [earlier],
        taskId: 'your_first_hand_flop',
        attemptKey: 'a',
      ),
      isFalse,
      reason: 'the decision itself is not a prior answer',
    );
    expect(
      act0IsExactTaskReplayV1(
        [earlier],
        taskId: 'your_first_hand_turn',
        attemptKey: 'b',
      ),
      isFalse,
    );
    expect(
      act0IsExactTaskReplayV1(
        [placement],
        taskId: 'what_poker_is_table_read_transfer',
        attemptKey: 'b',
      ),
      isFalse,
      reason: 'placement is assessment, not earlier lesson learning',
    );
  });

  group('durable exact-replay provenance', () {
    const taskId = 'your_first_hand_flop';
    Act0ReviewKindV1 kind(
      Iterable<Act0LearningEvidenceRecordV1> records, {
      Set<String> completed = const <String>{},
      String task = taskId,
      String family = 'board_read',
    }) => act0UnroutedReviewKindV1(
      records: records,
      completedTaskIds: completed,
      taskId: task,
      attemptKey: 'replay_attempt',
      conceptFamilyId: family,
    );

    test('a completed task stays exactReplay after 200+ later records', () {
      var history = const Act0LearningEvidenceHistoryV1().append(
        _record(recordId: 'original', taskId: taskId, runKind: 'lesson'),
      );
      for (var i = 0; i < Act0LearningEvidenceHistoryV1.maxRecords + 1; i++) {
        history = history.append(
          _record(
            recordId: 'later_$i',
            taskId: 'other_task',
            runKind: 'lesson',
            createdOrder: i + 2,
          ),
        );
      }
      expect(
        history.records.any((record) => record.taskId == taskId),
        isFalse,
        reason: 'the original answer was evicted',
      );
      // Without the durable completion set the eviction erases provenance:
      // the replay would masquerade as an unseen transfer.
      expect(kind(history.records), Act0ReviewKindV1.unseenTransfer);
      expect(
        kind(history.records, completed: const {taskId}),
        Act0ReviewKindV1.exactReplay,
      );
    });

    test('a first genuine answer is the initial assessment', () {
      expect(kind(const []), Act0ReviewKindV1.initialAssessment);
      final placement = _record(
        recordId: 'p',
        taskId: taskId,
        runKind: 'placement',
      );
      expect(
        kind([placement]),
        Act0ReviewKindV1.initialAssessment,
        reason: 'placement is assessment, not earlier learning',
      );
    });

    test(
      'a distinct, never-answered task in a practised family is transfer',
      () {
        final sibling = _record(
          recordId: 's',
          taskId: 'your_first_hand_turn',
          runKind: 'lesson',
        );
        expect(
          kind([sibling], completed: const {'your_first_hand_turn'}),
          Act0ReviewKindV1.unseenTransfer,
        );
        expect(
          kind([sibling], family: 'another_family'),
          Act0ReviewKindV1.initialAssessment,
        );
      },
    );

    test('unknown evidence for a completed task never becomes proof', () {
      // Completed on a legacy save with no surviving record: exactReplay
      // earns no due, spaced or transfer credit.
      expect(
        kind(const [], completed: const {taskId}),
        Act0ReviewKindV1.exactReplay,
      );
      final replay = Act0LearningEvidenceRecordV1.tryParse({
        ..._record(
          recordId: 'r',
          taskId: taskId,
          runKind: 'lesson',
        ).toPayload(),
        'reviewKind': 'exactReplay',
        'recordedAtUtc': '2026-12-01T00:00:00.000Z',
      })!;
      final family = const Act0DurableRetentionHistoryV1()
          .applyEvidence(replay)
          .families
          .single;
      expect(family.spacedSuccessStage, 0);
      expect(family.lastSpacedReviewAtUtc, isNull);
    });
  });
}
