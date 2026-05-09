Map<String, dynamic> buildTierBMasterBundleV4({
  required Map<String, dynamic> finalBundle,
  required Map<String, dynamic> telemetryMap,
  required Map<String, dynamic> telemetryEnvelope,
  required Map<String, dynamic> telemetryUnified,
  required Map<String, dynamic> telemetryRelay,
}) {
  final sanitizedFinal = _sanitizeMap(finalBundle);
  final sanitizedTelemetryMap = _sanitizeMap(telemetryMap);
  final sanitizedEnvelope = _sanitizeMap(telemetryEnvelope);
  final sanitizedUnified = _sanitizeMap(telemetryUnified);
  final sanitizedRelay = _sanitizeMap(telemetryRelay);

  final ready = _boolValue(sanitizedFinal['ready']);
  final reason = _sanitizeReason(sanitizedFinal['reason']);

  return {
    'final_bundle': sanitizedFinal,
    'telemetry_map': sanitizedTelemetryMap,
    'telemetry_envelope': sanitizedEnvelope,
    'telemetry_unified': sanitizedUnified,
    'telemetry_relay': sanitizedRelay,
    'ready': ready,
    'reason': reason,
  };
}

Map<String, dynamic> _sanitizeMap(Map<String, dynamic> source) {
  final result = <String, dynamic>{};
  source.forEach((key, value) {
    result[key] = _sanitizeValue(key, value);
  });
  return result;
}

dynamic _sanitizeValue(String key, Object? value) {
  if (value is Map<String, dynamic>) {
    return _sanitizeMap(value);
  }
  if (value is List) {
    return value.map((entry) => _sanitizeValue(key, entry)).toList();
  }

  if (value is bool) {
    return value;
  }

  if (value is String) {
    if (key == 'reason') {
      return _sanitizeReason(value);
    }
    return value;
  }

  if (value is num) {
    return _normalizeNumeric(key, value.toDouble());
  }

  return _defaultNumeric(key);
}

double _normalizeNumeric(String key, double value) {
  final range = key.contains('delta') ? _Range.negOneOne : _Range.zeroOne;
  final finite = value.isFinite ? value : 0.0;
  return range.clamp(finite);
}

double _defaultNumeric(String key) =>
    (key.contains('delta') ? _Range.negOneOne : _Range.zeroOne).clamp(0.0);

bool _boolValue(Object? value) => value is bool ? value : false;

String _sanitizeReason(Object? value) {
  if (value is String && value.isNotEmpty && _isAscii(value)) {
    return value;
  }
  return 'invalid';
}

bool _isAscii(String value) =>
    value.codeUnits.every((unit) => unit >= 32 && unit <= 127);

class _Range {
  const _Range(this.min, this.max);

  static const _Range zeroOne = _Range(0.0, 1.0);
  static const _Range negOneOne = _Range(-1.0, 1.0);

  double clamp(double value) => value < min ? min : (value > max ? max : value);

  final double min;
  final double max;
}
