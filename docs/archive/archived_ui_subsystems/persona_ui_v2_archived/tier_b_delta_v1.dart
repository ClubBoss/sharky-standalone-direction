Map<String, double> computeTierBDelta(
  Map<String, double> prev,
  Map<String, double> curr,
) {
  const keys = ['stability', 'clarity', 'conflict'];
  final deltas = <String, double>{};

  for (final key in keys) {
    final base = _finiteValue(prev[key]);
    final next = _finiteValue(curr[key]);
    final value = (next - base).clamp(-1.0, 1.0);
    deltas[key] = value;
  }

  return deltas;
}

double _finiteValue(Object? value) {
  if (value is double) {
    return value.isFinite ? value : 0.0;
  }
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
