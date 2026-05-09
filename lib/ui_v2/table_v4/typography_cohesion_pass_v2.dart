class TypographyCohesionPassV2 {
  const TypographyCohesionPassV2();

  static Map<String, Object> build({
    required Map<String, Object?> injectorMap,
    required Map<String, Object?> fineTuneMap,
    required Map<String, Object?> compensationMap,
    required Map<String, Object?> responsiveScalingMap,
  }) {
    final List<String> issues = <String>[];
    final Map<String, bool> okFlags = <String, bool>{
      'ok_injector': _validateMap(injectorMap, issues, 'injector'),
      'ok_finetune': _validateMap(fineTuneMap, issues, 'finetune'),
      'ok_compensation': _validateMap(compensationMap, issues, 'compensation'),
      'ok_responsive': _validateMap(responsiveScalingMap, issues, 'responsive'),
    };
    _checkDrift(injectorMap, compensationMap, responsiveScalingMap, issues);
    issues.sort();
    return <String, Object>{
      'typography_cohesion_pass_v2': <String, Object>{
        'issues': issues,
        'ok_injector': okFlags['ok_injector'] ?? false,
        'ok_finetune': okFlags['ok_finetune'] ?? false,
        'ok_compensation': okFlags['ok_compensation'] ?? false,
        'ok_responsive': okFlags['ok_responsive'] ?? false,
        'ready': false,
      },
    };
  }

  static bool _validateMap(
    Map<String, Object?> map,
    List<String> issues,
    String prefix,
  ) {
    if (map.isEmpty) {
      issues.add('$prefix:missing_fields');
      return false;
    }
    for (final MapEntry<String, Object?> entry in map.entries) {
      final Object? value = entry.value;
      if (value is! num) {
        issues.add('$prefix:invalid_type_${entry.key}');
        return false;
      }
    }
    return true;
  }

  static void _checkDrift(
    Map<String, Object?> injectorMap,
    Map<String, Object?> compensationMap,
    Map<String, Object?> responsiveMap,
    List<String> issues,
  ) {
    final double injectorScale = _extractDouble(injectorMap, 'font_scale');
    final double compensationScale = _extractDouble(
      compensationMap,
      'scale_bias',
    );
    final double responsiveScale = _extractDouble(
      responsiveMap,
      'scale_factor_normdpi',
    );
    if ((injectorScale + compensationScale - responsiveScale).abs() > 0.2) {
      issues.add('drift:scale_mismatch');
    }
    final int injectorAlpha = _extractInt(injectorMap, 'alpha');
    final int compensationAlpha = _extractInt(compensationMap, 'alpha_bias');
    final int responsiveAdjust = _extractInt(
      responsiveMap,
      'alpha_adjust_normdpi',
    );
    if ((injectorAlpha + compensationAlpha + responsiveAdjust).abs() > 255) {
      issues.add('drift:alpha_overflow');
    }
  }

  static double _extractDouble(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is num) return value.toDouble();
    return 0.0;
  }

  static int _extractInt(Map<String, Object?> map, String key) {
    final Object? value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }
}
