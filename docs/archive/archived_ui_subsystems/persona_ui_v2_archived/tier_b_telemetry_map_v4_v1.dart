Map<String, dynamic> buildTierBTelemetryMapV4({
  required Map<String, dynamic> finalBundle,
}) {
  final synthesis = finalBundle['synthesis_v4'];
  final map = _extractFrame(synthesis);
  final ready = _boolValue(finalBundle['ready']);
  final reason = _sanitizeReason(finalBundle['reason']);

  return {
    'stability': map['stability'],
    'clarity': map['clarity'],
    'conflict': map['conflict'],
    'delta_stability': map['delta_stability'],
    'delta_clarity': map['delta_clarity'],
    'delta_conflict': map['delta_conflict'],
    'ready': ready,
    'reason': reason,
  };
}

Map<String, double> _extractFrame(Object? value) {
  const keys = [
    'stability',
    'clarity',
    'conflict',
    'delta_stability',
    'delta_clarity',
    'delta_conflict',
  ];
  final frame = <String, double>{};
  if (value is Map) {
    for (final key in keys) {
      final clampRange = key.startsWith('delta')
          ? _Range.negOneOne
          : _Range.zeroOne;
      frame[key] = clampRange.clamp(_finite(value[key]));
    }
  } else {
    for (final key in keys) {
      frame[key] = _Range.zeroOne.clamp(0.0);
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

bool _boolValue(Object? value) {
  if (value is bool) return value;
  return false;
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
