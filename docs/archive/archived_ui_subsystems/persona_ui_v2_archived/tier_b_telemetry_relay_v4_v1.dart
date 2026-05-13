Map<String, dynamic> buildTierBTelemetryRelayV4({
  required Map<String, dynamic> unified,
}) {
  const keys = [
    'stability',
    'clarity',
    'conflict',
    'delta_stability',
    'delta_clarity',
    'delta_conflict',
  ];

  final result = <String, dynamic>{
    'relay': <String, double>{},
    'ready': unified['ready'] is bool ? unified['ready'] as bool : false,
    'reason': _sanitizeReason(unified['reason']),
  };

  final relay = result['relay'] as Map<String, double>;

  for (final key in keys) {
    final value = unified[key];
    final range = key.startsWith('delta') ? _Range.negOneOne : _Range.zeroOne;
    relay[key] = range.clamp(_toDouble(value));
  }

  return result;
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
