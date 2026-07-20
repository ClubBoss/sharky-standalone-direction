/// One explicit, bounded Action learning sequence.
///
/// This is intentionally a registry, not a task-name convention. The Act0
/// preview shell retains routing and progression ownership; runners remain
/// task-owned leaves.
enum Act0ActionSequenceStageV1 { theory, decision, repair, recheck, complete }

class Act0ActionLearningSequenceV1 {
  const Act0ActionLearningSequenceV1({
    required this.sequenceId,
    required this.theoryTaskId,
    required this.practiceTaskId,
    required this.repairTaskId,
    required this.recheckTaskId,
    required this.repairErrorType,
    required this.tableContextKey,
    required this.tableContextRelation,
    required this.geometryPolicyId,
  });

  final String sequenceId;
  final String theoryTaskId;
  final String practiceTaskId;
  final String repairTaskId;
  final String recheckTaskId;
  final String repairErrorType;
  final String tableContextKey;

  /// `related_read` is deliberately not a same-hand claim.
  final String tableContextRelation;
  final String geometryPolicyId;

  bool containsTask(String taskId) =>
      taskId == theoryTaskId || taskId == practiceTaskId;

  Act0ActionSequenceStageV1 stageForTask(String taskId) {
    if (taskId == theoryTaskId) return Act0ActionSequenceStageV1.theory;
    if (taskId == practiceTaskId) return Act0ActionSequenceStageV1.decision;
    throw ArgumentError.value(taskId, 'taskId', 'not in this sequence');
  }

  String? repairTargetForErrorType(String errorType) {
    return errorType == repairErrorType ? repairTaskId : null;
  }
}

const act0ActionLearningSequenceV1 = Act0ActionLearningSequenceV1(
  sequenceId: 'w1_action_words_check_v1',
  theoryTaskId: 'actions_theory',
  practiceTaskId: 'actions_check_drill',
  repairTaskId: 'actions_check_drill',
  recheckTaskId: 'actions_check_drill',
  repairErrorType: 'misread_action_legality',
  tableContextKey: 'w1_action_words_no_bet_read_v1',
  tableContextRelation: 'related_read',
  geometryPolicyId: 'w1_action_sequence_compact_v1',
);

Act0ActionLearningSequenceV1? act0ActionLearningSequenceForTaskV1(
  String taskId,
) {
  return act0ActionLearningSequenceV1.containsTask(taskId)
      ? act0ActionLearningSequenceV1
      : null;
}
