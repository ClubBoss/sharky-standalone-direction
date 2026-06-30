import 'act0_learning_evidence_contract_v1.dart';
import 'act0_w12_review_decision_hidden_runtime_session_owner_v1.dart';

class Act0W12ReviewDecisionHiddenEvidenceHarnessV1 {
  const Act0W12ReviewDecisionHiddenEvidenceHarnessV1({
    this.owner = const Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1(),
  });

  final Act0W12ReviewDecisionHiddenRuntimeSessionOwnerV1 owner;

  Object? get practiceLaunchRequest => null;

  Act0LearningEvidenceHistoryV1 submitChoice({
    required Act0LearningEvidenceHistoryV1 history,
    required String worldId,
    required String lessonId,
    required String taskId,
    required String selectedChoiceId,
    required String attemptKey,
    required String decisionTimeBucket,
  }) {
    if (!owner.supports(worldId: worldId, lessonId: lessonId, taskId: taskId)) {
      throw ArgumentError.value(<String, String>{
        'worldId': worldId,
        'lessonId': lessonId,
        'taskId': taskId,
      }, 'task');
    }
    return owner.appendChoiceEvidence(
      history: history,
      taskId: taskId,
      selectedChoiceId: selectedChoiceId,
      attemptKey: attemptKey,
      decisionTimeBucket: decisionTimeBucket,
    );
  }
}
