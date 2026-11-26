import 'act0_shell_state_v1.dart';

/// Logic for an explicitly timed decision. The caller supplies elapsed time
/// from a monotonic clock; ordinary lesson decisions remain untimed.
class Act0TimedDecisionV1 {
  Act0TimedDecisionV1({required this.task, required this.timeLimit}) {
    if (timeLimit <= Duration.zero) {
      throw ArgumentError.value(timeLimit, 'timeLimit', 'Must be positive');
    }
  }

  final Act0LessonTaskV1 task;
  final Duration timeLimit;
  Act0FeedbackQualityV1? _grade;

  /// Null means no submission yet. Expiry is a miss, even if a correct
  /// answer arrives at the deadline. The first terminal result is final.
  Act0FeedbackQualityV1? resolve({
    required Duration elapsed,
    String? optionId,
  }) {
    if (elapsed < Duration.zero) {
      throw ArgumentError.value(elapsed, 'elapsed', 'Must not be negative');
    }
    if (_grade != null) return _grade;
    if (elapsed >= timeLimit) return _grade = Act0FeedbackQualityV1.wrong;
    if (optionId == null) return null;
    final option = task.runner.options.singleWhere((o) => o.id == optionId);
    return _grade = option.quality;
  }
}
