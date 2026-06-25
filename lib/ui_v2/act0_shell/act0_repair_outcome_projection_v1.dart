import 'package:poker_analyzer/ui_v2/act0_shell/act0_practice_repair_queue_projection_v1.dart';

const String act0RepairOutcomeStateAttemptedV1 = 'repair_attempted_v1';
const String act0RepairOutcomeStateCorrectV1 = 'repair_correct_v1';
const String act0RepairOutcomeStateStillNeedsRepV1 =
    'repair_still_needs_rep_v1';

class Act0RepairOutcomeProjectionV1 {
  const Act0RepairOutcomeProjectionV1({
    this.outcomes = const <Act0RepairOutcomeV1>[],
  });

  final List<Act0RepairOutcomeV1> outcomes;

  bool get hasOutcomes => outcomes.isNotEmpty;

  Act0RepairOutcomeProjectionV1 appendAnsweredTask({
    required Act0PracticeRepairQueueLaunchRequestV1? launchRequest,
    required String selectedChoiceId,
    required String correctChoiceId,
    required bool? isCorrect,
    required int sequence,
  }) {
    final request = launchRequest;
    if (request == null || !request.isLaunchable) {
      return this;
    }
    if (request.sourceType != act0PracticeRepairQueueSourceActiveRepairV1 ||
        request.targetType != act0PracticeRepairQueueTargetTypeActiveRepairV1) {
      return this;
    }
    final sourceTaskId = request.sourceTaskId.trim();
    final repairTaskId = request.repairTaskId.trim();
    final targetWorldId = request.targetWorldId.trim();
    final targetLessonId = request.targetLessonId.trim();
    final targetTaskId = request.targetTaskId.trim();
    final queueItemId = request.queueItemId.trim();
    if (sourceTaskId.isEmpty ||
        repairTaskId.isEmpty ||
        targetWorldId.isEmpty ||
        targetLessonId.isEmpty ||
        targetTaskId.isEmpty ||
        queueItemId.isEmpty) {
      return this;
    }
    final outcome = Act0RepairOutcomeV1(
      sourceTaskId: sourceTaskId,
      repairTaskId: repairTaskId,
      repairFocusKey: request.repairFocusKey.trim(),
      queueItemId: queueItemId,
      targetWorldId: targetWorldId,
      targetLessonId: targetLessonId,
      targetTaskId: targetTaskId,
      selectedChoiceId: selectedChoiceId.trim(),
      correctChoiceId: correctChoiceId.trim(),
      isCorrect: isCorrect,
      outcomeState: _outcomeStateForCorrectnessV1(isCorrect),
      sequence: sequence < 0 ? 0 : sequence,
      sourceType: request.sourceType,
    );
    final next = <Act0RepairOutcomeV1>[...outcomes, outcome]
      ..sort((a, b) {
        final sequenceCompare = a.sequence.compareTo(b.sequence);
        if (sequenceCompare != 0) {
          return sequenceCompare;
        }
        return a.queueItemId.compareTo(b.queueItemId);
      });
    return Act0RepairOutcomeProjectionV1(
      outcomes: List<Act0RepairOutcomeV1>.unmodifiable(next),
    );
  }

  List<Map<String, Object?>> toPayload() =>
      outcomes.map((outcome) => outcome.toPayload()).toList(growable: false);
}

class Act0RepairOutcomeV1 {
  const Act0RepairOutcomeV1({
    this.schemaVersion = 1,
    required this.sourceTaskId,
    required this.repairTaskId,
    required this.repairFocusKey,
    required this.queueItemId,
    required this.targetWorldId,
    required this.targetLessonId,
    required this.targetTaskId,
    required this.selectedChoiceId,
    required this.correctChoiceId,
    required this.isCorrect,
    required this.outcomeState,
    required this.sequence,
    required this.sourceType,
  });

  final int schemaVersion;
  final String sourceTaskId;
  final String repairTaskId;
  final String repairFocusKey;
  final String queueItemId;
  final String targetWorldId;
  final String targetLessonId;
  final String targetTaskId;
  final String selectedChoiceId;
  final String correctChoiceId;
  final bool? isCorrect;
  final String outcomeState;
  final int sequence;
  final String sourceType;

  Map<String, Object?> toPayload() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'sourceTaskId': sourceTaskId,
    'repairTaskId': repairTaskId,
    'repairFocusKey': repairFocusKey,
    'queueItemId': queueItemId,
    'targetWorldId': targetWorldId,
    'targetLessonId': targetLessonId,
    'targetTaskId': targetTaskId,
    'selectedChoiceId': selectedChoiceId,
    'correctChoiceId': correctChoiceId,
    'isCorrect': isCorrect,
    'outcomeState': outcomeState,
    'sequence': sequence,
    'sourceType': sourceType,
  };
}

String _outcomeStateForCorrectnessV1(bool? isCorrect) {
  if (isCorrect == true) {
    return act0RepairOutcomeStateCorrectV1;
  }
  if (isCorrect == false) {
    return act0RepairOutcomeStateStillNeedsRepV1;
  }
  return act0RepairOutcomeStateAttemptedV1;
}
