Map<String, dynamic> normalizeTierBGateConsistency(Map<String, Object?> gate) {
  final rawFrame = gate['frame'];
  final frame = <String, double>{};
  const keys = ['stability', 'clarity', 'conflict'];

  if (rawFrame is Map) {
    for (final key in keys) {
      frame[key] = _clamp(_finiteValue(rawFrame[key]));
    }
  } else {
    for (final key in keys) {
      frame[key] = 0.0;
    }
  }

  final ready = gate['ready'] is bool ? gate['ready'] as bool : false;
  final reason = gate['reason'];
  var normalizedReason = 'invalid';
  if (reason is String && reason.isNotEmpty && _isAscii(reason)) {
    normalizedReason = reason;
  }

  return {
    'ready': ready,
    'frame': frame,
    'reason': normalizedReason,
    'frame_stability': frame['stability'] ?? 0.0,
    'frame_clarity': frame['clarity'] ?? 0.0,
    'frame_conflict': frame['conflict'] ?? 0.0,
  };
}

double _finiteValue(Object? value) {
  if (value is double) return value.isFinite ? value : 0.0;
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

double _clamp(double value) => value.clamp(0.0, 1.0);

bool _isAscii(String value) => value.codeUnits.every((unit) => unit <= 127);
