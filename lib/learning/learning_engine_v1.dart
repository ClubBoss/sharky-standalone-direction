class EngineTelemetryV1 {
  const EngineTelemetryV1({
    required this.userChoice,
    required this.isCorrect,
    required this.errorClass,
    required this.timeToDecisionMs,
  });

  final String userChoice;
  final bool isCorrect;
  final String errorClass;
  final int timeToDecisionMs;
}

class LearningAttemptV1 {
  LearningAttemptV1.start(DateTime startedAt) : _startedAt = startedAt;

  final DateTime _startedAt;
  DateTime? _completedAt;
  String? _userChoice;

  void recordChoice(String choice, DateTime now) {
    _userChoice = choice;
    _completedAt = now;
  }

  EngineTelemetryV1 finalize({
    required String expectedBestAction,
    required String errorClass,
  }) {
    final choice = _userChoice;
    final completedAt = _completedAt;
    if (choice == null || completedAt == null) {
      throw StateError('LearningAttemptV1 missing choice or completion time');
    }
    final durationMs = completedAt.difference(_startedAt).inMilliseconds;
    final isCorrect = _normalize(choice) == _normalize(expectedBestAction);
    return EngineTelemetryV1(
      userChoice: choice,
      isCorrect: isCorrect,
      errorClass: errorClass,
      timeToDecisionMs: durationMs,
    );
  }
}

class LearningEngineV1 {
  LearningAttemptV1? _currentAttempt;

  void startAttempt(DateTime now) {
    _currentAttempt = LearningAttemptV1.start(now);
  }

  EngineTelemetryV1 submitChoice({
    required String userChoice,
    required DateTime now,
    required String expectedBestAction,
    required String errorClass,
  }) {
    final attempt = _currentAttempt;
    if (attempt == null) {
      throw StateError('LearningEngineV1 has no active attempt');
    }
    attempt.recordChoice(userChoice, now);
    final telemetry = attempt.finalize(
      expectedBestAction: expectedBestAction,
      errorClass: errorClass,
    );
    _currentAttempt = null;
    return telemetry;
  }
}

String _normalize(String value) => value.trim().toLowerCase();
