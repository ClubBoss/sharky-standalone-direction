Map<String, dynamic> buildTierBFinalBundleV4({
  required Map<String, dynamic> preflight,
  required Map<String, dynamic> synthesis,
}) {
  final sanitizedAggregated = _extractFrame(
    preflight['aggregated'],
    _Range.zeroOne,
  );
  final sanitizedDelta = _extractFrame(preflight['delta'], _Range.negOneOne);
  final sanitizedConsistency = _extractFrame(
    preflight['consistency'],
    _Range.zeroOne,
  );
  final sanitizedGateConsistency = _extractFrame(
    preflight['gate_consistency'],
    _Range.zeroOne,
  );

  final gate = preflight['gate'];
  final gateReady = gate is Map && gate['ready'] is bool
      ? gate['ready'] as bool
      : false;
  final gateReason = _sanitizeReason(gate is Map ? gate['reason'] : null);
  final gateFrame = gate is Map
      ? _extractFrame(gate['frame'], _Range.zeroOne)
      : _extractFrame(null, _Range.zeroOne);

  final sanitizedPreflight = {
    'consistency': sanitizedConsistency,
    'delta': sanitizedDelta,
    'aggregated': sanitizedAggregated,
    'gate': {'frame': gateFrame, 'ready': gateReady, 'reason': gateReason},
    'gate_consistency': sanitizedGateConsistency,
    'ready': gateReady,
    'reason': gateReason,
  };

  final sanitizedSynthesis = {
    'stability': sanitizedAggregated['stability'],
    'clarity': sanitizedAggregated['clarity'],
    'conflict': sanitizedAggregated['conflict'],
    'delta_stability': sanitizedDelta['stability'],
    'delta_clarity': sanitizedDelta['clarity'],
    'delta_conflict': sanitizedDelta['conflict'],
    'ready': gateReady,
    'reason': gateReason,
  };

  return {
    'synthesis_v4': sanitizedSynthesis,
    'preflight': sanitizedPreflight,
    'ready': gateReady,
    'reason': gateReason,
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
