Map<String, double> aggregateTierB(
  Map<String, double> consistency,
  Map<String, double> delta,
) {
  const keys = ['stability', 'clarity', 'conflict'];
  final aggregated = <String, double>{};

  for (final key in keys) {
    final cons = _finiteValue(consistency[key]);
    final diff = _finiteValue(delta[key]);
    final value = cons * 0.7 + diff * 0.3;
    aggregated[key] = value.clamp(0.0, 1.0);
  }

  return aggregated;
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
