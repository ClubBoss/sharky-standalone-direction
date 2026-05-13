Map<String, dynamic> evaluateTierBGate(Map<String, double> aggregated) {
  const keys = ['stability', 'clarity', 'conflict'];
  final frame = <String, double>{};

  for (final key in keys) {
    final raw = aggregated[key];
    final value = _clamp(_finiteValue(raw));
    frame[key] = value;
  }

  final ready =
      frame['stability']! >= 0.20 &&
      frame['clarity']! >= 0.20 &&
      frame['conflict']! <= 0.70;

  final reasons = <String>[];
  if (!ready) {
    if (frame['stability']! < 0.20) reasons.add('low_stability');
    if (frame['clarity']! < 0.20) reasons.add('low_clarity');
    if (frame['conflict']! > 0.70) reasons.add('high_conflict');
  }

  final reason = reasons.isEmpty ? 'ok' : reasons.join('_');

  return {'frame': frame, 'ready': ready, 'reason': reason};
}

double _finiteValue(Object? value) {
  if (value is double) return value.isFinite ? value : 0.0;
  if (value is num) {
    final d = value.toDouble();
    return d.isFinite ? d : 0.0;
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed.isFinite) {
      return parsed;
    }
  }
  return 0.0;
}

double _clamp(double value) => value.clamp(0.0, 1.0);
