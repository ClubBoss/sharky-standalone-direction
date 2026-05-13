Map<String, double> computePassiveEmotions({
  required Map<String, Object?> synthesis,
}) {
  double calm = 0.5;
  double focus = 0.5;
  double tension = 0.0;

  final consistency = _asDouble(synthesis['consistency']);
  final patternStrength = _asDouble(synthesis['pattern_strength']);
  final volatility = _asDouble(synthesis['volatility']);

  if (consistency >= 0.7) {
    calm += 0.2;
  }
  if (patternStrength >= 0.6) {
    focus += 0.2;
  }
  if (volatility >= 0.5) {
    tension += 0.1;
  }

  return {
    'calm': _clamp(calm),
    'focus': _clamp(focus),
    'tension': _clamp(tension),
  };
}

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

double _clamp(double value) => value.clamp(0.0, 1.0);
