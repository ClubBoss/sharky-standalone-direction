Map<String, dynamic> buildTierBTelemetryUnifiedV4({
  required Map<String, dynamic> envelope,
}) {
  final frame = envelope['envelope'];
  const keys = [
    'stability',
    'clarity',
    'conflict',
    'delta_stability',
    'delta_clarity',
    'delta_conflict',
  ];

  final sanitized = <String, double>{};

  if (frame is Map) {
    for (final key in keys) {
      final range = key.startsWith('delta') ? _Range.negOneOne : _Range.zeroOne;
      sanitized[key] = range.clamp(_toDouble(frame[key]));
    }
  } else {
    for (final key in keys) {
      sanitized[key] = _Range.zeroOne.clamp(0.0);
    }
  }

  final ready = envelope['ready'] is bool ? envelope['ready'] as bool : false;
  final reason = _sanitizeReason(envelope['reason']);

  return {
    'stability': sanitized['stability'],
    'clarity': sanitized['clarity'],
    'conflict': sanitized['conflict'],
    'delta_stability': sanitized['delta_stability'],
    'delta_clarity': sanitized['delta_clarity'],
    'delta_conflict': sanitized['delta_conflict'],
    'ready': ready,
    'reason': reason,
  };
}

double _toDouble(Object? value) {
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
