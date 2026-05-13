Map<String, double> applyEmotionStability({
  required Map<String, double> active,
  required Map<String, Object?>? lastFrame,
}) {
  final calm = active['calm'] ?? 0.0;
  final focus = active['focus'] ?? 0.0;
  final tension = active['tension'] ?? 0.0;

  if (lastFrame == null) {
    return {
      'calm': _clamp(calm),
      'focus': _clamp(focus),
      'tension': _clamp(tension),
    };
  }

  final previousCalm = _toDouble(lastFrame['calm']);
  final previousFocus = _toDouble(lastFrame['focus']);
  final previousTension = _toDouble(lastFrame['tension']);

  return {
    'calm': _clamp(previousCalm * 0.7 + calm * 0.3),
    'focus': _clamp(previousFocus * 0.7 + focus * 0.3),
    'tension': _clamp(previousTension * 0.7 + tension * 0.3),
  };
}

double _toDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double _clamp(double value) => value.clamp(0.0, 1.0);
