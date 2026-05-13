Map<String, dynamic> buildTierBPreflightMerged({
  required Map<String, dynamic> consistency,
  required Map<String, dynamic> delta,
  required Map<String, dynamic> aggregated,
  required Map<String, dynamic> gate,
  required Map<String, dynamic> gateConsistency,
}) {
  const keys = ['stability', 'clarity', 'conflict'];

  final normalizedConsistency = _normalizeFrame(
    consistency,
    clampRange: _Range.zeroOne,
  );
  final normalizedDelta = _normalizeFrame(delta, clampRange: _Range.negOneOne);
  final normalizedAggregated = _normalizeFrame(
    aggregated,
    clampRange: _Range.zeroOne,
  );

  final ready = gate['ready'] is bool ? gate['ready'] as bool : false;
  final reasonRaw = gate['reason'];
  final reason = _asciiReason(reasonRaw);

  final normalizedGate = <String, dynamic>{
    'frame': _normalizeFrame(
      (gate['frame'] is Map) ? gate['frame'] as Map : const {},
      clampRange: _Range.zeroOne,
    ),
    'ready': ready,
    'reason': reason,
  };

  final normalizedGateConsistency = _normalizeFrame(
    gateConsistency,
    clampRange: _Range.zeroOne,
  );

  return {
    'consistency': normalizedConsistency,
    'delta': normalizedDelta,
    'aggregated': normalizedAggregated,
    'gate': normalizedGate,
    'gate_consistency': normalizedGateConsistency,
    'ready': ready,
    'reason': reason,
  };
}

Map<String, double> _normalizeFrame(
  Map<Object?, Object?> raw, {
  required _Range clampRange,
}) {
  const keys = ['stability', 'clarity', 'conflict'];
  final frame = <String, double>{};

  for (final key in keys) {
    final value = _finiteValue(raw[key]);
    frame[key] = clampRange.clamp(value);
  }

  return frame;
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

String _asciiReason(Object? value) {
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
