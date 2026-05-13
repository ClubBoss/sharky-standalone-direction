class EmotionSynthesisV4 {
  EmotionSynthesisV4({
    required this.preflight,
    required this.consistency,
    required this.delta,
    required this.merged,
    required Map<String, Object?> engineState,
  }) : _engineState = Map.of(engineState);

  final Map<String, Object?> preflight;
  final Map<String, Object?> consistency;
  final Map<String, Object?> delta;
  final Map<String, Object?> merged;

  final Map<String, Object?> _engineState;

  double get _baseMood => _toDouble(_engineState['baseMood']);
  double get _baseTone => _toDouble(_engineState['baseTone']);
  double get _baseArousal => _toDouble(_engineState['baseArousal']);
  double get _baseValence => _toDouble(_engineState['baseValence']);

  double get _synthesizedMood =>
      0.4 * _baseMood +
      0.3 * _baseTone +
      0.2 * _baseArousal +
      0.1 * _baseValence;
  double get _synthesizedTone => _synthesizedMood;
  double get _synthesizedArousal => _synthesizedMood;
  double get _synthesizedValence => _synthesizedMood;

  double _stability(double value) => _clamp(1.0 - value.abs() * 0.35, 0.0, 1.0);

  double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return 0.0;
  }

  bool get _moodStable => _stability(_synthesizedMood) >= 0.7;
  bool get _toneStable => _stability(_synthesizedTone) >= 0.7;
  bool get _arousalStable => _stability(_synthesizedArousal) >= 0.7;
  bool get _valenceStable => _stability(_synthesizedValence) >= 0.7;

  Map<String, Object?> asReadOnlyMap() => {
    'preflight': preflight,
    'consistency': consistency,
    'delta': delta,
    'merged': merged,
    'synthesizedMood': _synthesizedMood,
    'synthesizedTone': _synthesizedTone,
    'synthesizedArousal': _synthesizedArousal,
    'synthesizedValence': _synthesizedValence,
    'moodStabilityScore': _stability(_synthesizedMood),
    'toneStabilityScore': _stability(_synthesizedTone),
    'arousalStabilityScore': _stability(_synthesizedArousal),
    'valenceStabilityScore': _stability(_synthesizedValence),
    'moodStable': _moodStable,
    'toneStable': _toneStable,
    'arousalStable': _arousalStable,
    'valenceStable': _valenceStable,
  };
}
