class ScoringLockInV1 {
  const ScoringLockInV1({
    required this.accuracyMap,
    required this.speedMap,
    required this.errorMap,
  });

  final Map<String, dynamic> accuracyMap;
  final Map<String, dynamic> speedMap;
  final Map<String, dynamic> errorMap;

  Map<String, Object> asReadOnlyMap() {
    final double accuracy = _aggregate(accuracyMap).clamp(0.0, 1.0);
    final double speed = _aggregate(speedMap).clamp(0.0, 1.0);
    final double errorPenalty = (_aggregate(errorMap) * 100).clamp(0.0, 100.0);
    final double finalScore =
        (accuracy * 0.5 + speed * 0.4 - errorPenalty * 0.01).clamp(0.0, 1.0);
    final bool ready =
        accuracyMap.isNotEmpty && speedMap.isNotEmpty && errorMap.isNotEmpty;
    return <String, Object>{
      'score_v': 1,
      'accuracy': accuracy,
      'speed': speed,
      'error_penalty': errorPenalty,
      'final_score': finalScore,
      'ready': ready,
    };
  }

  static double _aggregate(Map<String, dynamic> input) {
    if (input.isEmpty) return 0.0;
    final List<double> values = <double>[];
    for (final Object? raw in input.values) {
      final double? parsed = _toDouble(raw);
      if (parsed != null) {
        values.add(parsed);
      }
    }
    if (values.isEmpty) return 0.0;
    final double sum = values.reduce((a, b) => a + b);
    return sum / values.length;
  }

  static double? _toDouble(Object? raw) {
    if (raw is num) {
      return raw.toDouble();
    }
    if (raw is String) {
      return double.tryParse(raw);
    }
    return null;
  }
}
