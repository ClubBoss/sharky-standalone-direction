import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_learning_evidence_contract_v1.dart';

/// A Learn replay of an already answered task is an exact replay, never a
/// second "initial assessment" (found natively on the 14 Pro replay route).
Act0LearningEvidenceRecordV1 _record({
  required String recordId,
  required String taskId,
  required String runKind,
}) => Act0LearningEvidenceRecordV1.tryParse({
  'schemaVersion': 1,
  'recordId': recordId,
  'createdOrder': 1,
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
  'skillAtomId': 'board_read',
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
}
