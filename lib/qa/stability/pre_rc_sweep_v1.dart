class PreRCSweepV1 {
  PreRCSweepV1._({
    required this.stability,
    required this.personaThemeAlignment,
    required this.v4ToV3Fallback,
    required this.microUxEngine,
    required this.tableAdaptiveContext,
  });

  factory PreRCSweepV1.build({
    Map<String, Object>? stability,
    Map<String, Object>? personaThemeAlignment,
    Map<String, Object>? v4ToV3Fallback,
    Map<String, Object>? microUxEngine,
    Map<String, Object>? tableAdaptiveContext,
  }) => PreRCSweepV1._(
    stability: _sanitize(stability),
    personaThemeAlignment: _sanitize(personaThemeAlignment),
    v4ToV3Fallback: _sanitize(v4ToV3Fallback),
    microUxEngine: _sanitize(microUxEngine),
    tableAdaptiveContext: _sanitize(tableAdaptiveContext),
  );

  final Map<String, Object> stability;
  final Map<String, Object> personaThemeAlignment;
  final Map<String, Object> v4ToV3Fallback;
  final Map<String, Object> microUxEngine;
  final Map<String, Object> tableAdaptiveContext;

  Map<String, Object> build() {
    final String stabilityTag = _extractString(stability, 'tag');
    final double stabilityMapped = _mapStability(stabilityTag);
    final double alignmentScore = _extractDouble(
      personaThemeAlignment,
      'alignment_score',
    );
    final double fallbackScore = _extractDouble(
      v4ToV3Fallback,
      'fallback_ready_score',
    );
    final double microUxStrength = _extractDouble(
      microUxEngine,
      'engine_strength',
    );
    final double tableStrength = _extractDouble(
      tableAdaptiveContext,
      'surface_strength',
    );

    final double sweepScore =
        ((stabilityMapped +
                    alignmentScore +
                    fallbackScore +
                    microUxStrength +
                    tableStrength) /
                5)
            .clamp(0.0, 1.0);
    final String sweepTag = sweepScore >= 0.8
        ? 'rc-ready'
        : sweepScore >= 0.55
        ? 'rc-check'
        : 'rc-blocked';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'pre_rc_sweep_v1': Map<String, Object>.unmodifiable(<String, Object>{
        'sweep_score': sweepScore,
        'sweep_tag': _ascii(sweepTag),
        'ready': true,
      }),
    });
  }

  static double _mapStability(String tag) {
    switch (tag) {
      case 'ok':
        return 1.0;
      case 'warn':
        return 0.6;
      case 'critical':
        return 0.2;
      default:
        return 0.0;
    }
  }

  static double _extractDouble(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is num) return value.toDouble().clamp(0.0, 1.0);
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed.clamp(0.0, 1.0);
    }
    return 0.0;
  }

  static String _extractString(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static Map<String, Object> _sanitize(Map<String, Object>? map) {
    if (map == null) return const <String, Object>{};
    final Map<String, Object> clean = <String, Object>{};
    for (final MapEntry<String, Object> entry in map.entries) {
      clean[_ascii(entry.key)] = entry.value;
    }
    return clean;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
