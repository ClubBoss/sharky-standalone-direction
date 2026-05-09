Map<String, double> computeActiveEmotions({
  required Map<String, double> passive,
  required Map<String, Object?> synthesis,
}) {
  double calm = passive['calm'] ?? 0.0;
  double focus = passive['focus'] ?? 0.0;
  double tension = passive['tension'] ?? 0.0;

  final stability = _asDouble(synthesis['stability']);
  final clarity = _asDouble(synthesis['clarity']);
  final conflict = _asDouble(synthesis['conflict']);

  if (stability >= 0.6) {
    calm += 0.15;
  }
  if (clarity >= 0.6) {
    focus += 0.20;
  }
  if (conflict >= 0.4) {
    tension += 0.25;
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
