Map<String, double> normalizeTierBConsistency(Map<String, double> raw) {
  const keys = ['stability', 'clarity', 'conflict'];
  final normalized = <String, double>{};

  for (final key in keys) {
    var value = raw[key] ?? 0.0;
    if (!value.isFinite) {
      value = 0.0;
    }
    value = value.clamp(0.0, 1.0);
    normalized[key] = value;
  }

  return normalized;
}
