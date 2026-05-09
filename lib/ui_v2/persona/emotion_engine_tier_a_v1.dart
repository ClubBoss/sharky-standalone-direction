Map<String, double> computeTierAEmotionFrame({
  required Map<String, double> passive,
  required Map<String, double> active,
  required Map<String, double> stable,
}) {
  const keys = ['calm', 'focus', 'tension'];
  final frame = <String, double>{};

  for (final key in keys) {
    final base = passive[key];
    final act = active[key];
    final sta = stable[key];
    if (base == null || act == null || sta == null) {
      throw ArgumentError('Missing emotion dimension: $key');
    }
    final value = base * 0.2 + act * 0.3 + sta * 0.5;
    frame[key] = _clamp(value);
  }

  return frame;
}

double _clamp(double value) => value.clamp(0.0, 1.0);
