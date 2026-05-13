Map<String, dynamic> buildTierBTelemetryEnvelopeV4({
  required Map<String, dynamic> telemetryMap,
}) {
  final sanitized = _sanitizeTelemetry(telemetryMap);
  return {
    'envelope': {
      'stability': sanitized['stability'],
      'clarity': sanitized['clarity'],
      'conflict': sanitized['conflict'],
      'delta_stability': sanitized['delta_stability'],
      'delta_clarity': sanitized['delta_clarity'],
      'delta_conflict': sanitized['delta_conflict'],
    },
    'ready': sanitized['ready'],
    'reason': _sanitizeReason(sanitized['reason']),
  };
}

Map<String, dynamic> _sanitizeTelemetry(Map<String, dynamic> data) {
  const deltaKeys = {'delta_stability', 'delta_clarity', 'delta_conflict'};
  final result = <String, dynamic>{};
  data.forEach((key, value) {
    if (deltaKeys.contains(key)) {
      result[key] = _clampRange(value, -1.0, 1.0);
    } else if (key == 'ready') {
      result[key] = value is bool ? value : false;
    } else if (key == 'reason') {
      result[key] = value;
    } else {
      result[key] = _clampRange(value, 0.0, 1.0);
    }
  });
  for (final key in [
    'stability',
    'clarity',
    'conflict',
    'delta_stability',
    'delta_clarity',
    'delta_conflict',
  ]) {
    result.putIfAbsent(key, () => 0.0);
  }
  result.putIfAbsent('ready', () => false);
  result.putIfAbsent('reason', () => 'invalid');
  return result;
}

double _clampRange(Object? value, double min, double max) {
  final numeric = _asDouble(value);
  return numeric < min ? min : (numeric > max ? max : numeric);
}

double _asDouble(Object? value) {
  if (value is double) return value.isFinite ? value : 0.0;
  if (value is num) {
    final d = value.toDouble();
    return d.isFinite ? d : 0.0;
  }
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed.isFinite) return parsed;
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
