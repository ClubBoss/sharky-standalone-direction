class V4AnimationSpecProviderV1 {
  const V4AnimationSpecProviderV1(
    this.tableStateMap,
    this.seatStateMap,
    this.potStateMap,
  );

  final Map<String, Object> tableStateMap;
  final Map<String, Object> seatStateMap;
  final Map<String, Object> potStateMap;

  Map<String, Object> asReadOnlyMap() {
    final bool hasPot = _valueToDouble(potStateMap['amount']) > 0;
    final bool seatChanged = seatStateMap['changed'] == true;
    final bool ready = tableStateMap.isNotEmpty || seatStateMap.isNotEmpty;
    final String mode = hasPot ? 'glow' : (seatChanged ? 'fade' : 'scale');
    final int duration = _clampInt(
      (tableStateMap['duration_ms'] as int?) ?? 300,
      100,
      2000,
    );
    final double intensity = _clampDouble(
      _valueToDouble(seatStateMap['intensity']),
      0.0,
      1.0,
    );
    return <String, Object>{
      'active': ready,
      'mode': mode,
      'duration_ms': duration,
      'intensity': intensity,
    };
  }

  static double _valueToDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _clampInt(int value, int min, int max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  static double _clampDouble(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }
}
