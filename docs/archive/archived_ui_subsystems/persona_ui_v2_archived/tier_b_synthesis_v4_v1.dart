Map<String, dynamic> buildTierBSynthesisV4({
  required Map<String, dynamic> preflight,
}) {
  const keys = ['stability', 'clarity', 'conflict'];

  final aggregated = _extractFrame(preflight['aggregated'], _Range.zeroOne);
  final delta = _extractFrame(preflight['delta'], _Range.negOneOne);
  final gate = preflight['gate'];

  final ready = (gate is Map && gate['ready'] is bool)
      ? gate['ready'] as bool
      : false;
  final reason = _sanitizeReason(gate is Map ? gate['reason'] : null);

  return {
    'stability': aggregated['stability'],
    'clarity': aggregated['clarity'],
    'conflict': aggregated['conflict'],
    'delta_stability': delta['stability'],
    'delta_clarity': delta['clarity'],
    'delta_conflict': delta['conflict'],
    'ready': ready,
    'reason': reason,
  };
}

Map<String, double> _extractFrame(Object? raw, _Range range) {
  const keys = ['stability', 'clarity', 'conflict'];
  final frame = <String, double>{};
  if (raw is Map) {
    for (final key in keys) {
      frame[key] = range.clamp(_finite(raw[key]));
    }
  } else {
    for (final key in keys) {
      frame[key] = range.clamp(0.0);
    }
  }
  return frame;
}

double _finite(Object? value) {
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

String _sanitizeReason(Object? value) {
  if (value is String && value.isNotEmpty && _isAscii(value)) {
    return value;
  }
  return 'invalid';
}

bool _isAscii(String value) => value.codeUnits.every((unit) => unit <= 127);

class _Range {
  const _Range(this.min, this.max);

  static const _Range zeroOne = _Range(0.0, 1.0);
  static const _Range negOneOne = _Range(-1.0, 1.0);

  double clamp(double value) => value.clamp(min, max);

  final double min;
  final double max;
}
