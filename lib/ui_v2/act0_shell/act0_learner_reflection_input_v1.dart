enum Act0DecisionConfidenceV1 { unsure, somewhatSure, verySure }

/// Optional learner statements about a submitted attempt. They carry no
/// answer, hint, grade, or inferred diagnosis.
class Act0LearnerReflectionInputV1 {
  Act0LearnerReflectionInputV1({this.confidence, String? mistakeReason})
    : mistakeReason = _nonBlank(mistakeReason);

  final Act0DecisionConfidenceV1? confidence;
  final String? mistakeReason;

  bool get isEmpty => confidence == null && mistakeReason == null;

  Map<String, Object?> toPayload() => {
    if (confidence case final value?) 'confidence': value.name,
    if (mistakeReason case final value?) 'mistakeReason': value,
  };

  static Act0LearnerReflectionInputV1? fromPayload(Object? raw) {
    if (raw is! Map) return null;
    final input = Act0LearnerReflectionInputV1(
      confidence: Act0DecisionConfidenceV1.values
          .where((value) => value.name == raw['confidence'])
          .firstOrNull,
      mistakeReason: switch (raw['mistakeReason']) {
        final String reason => reason,
        _ => null,
      },
    );
    return input.isEmpty ? null : input;
  }

  static String? _nonBlank(String? text) {
    final trimmed = text?.trim();
    return trimmed == '' ? null : trimmed;
  }
}
