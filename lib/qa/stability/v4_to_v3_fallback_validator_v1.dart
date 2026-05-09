class V4ToV3FallbackValidatorV1 {
  V4ToV3FallbackValidatorV1._({
    required this.personaGlobal,
    required this.lambdaFusionSurface,
    required this.tableAdaptiveContext,
    required this.microUXEngine,
  });

  factory V4ToV3FallbackValidatorV1.build({
    Map<String, Object>? personaGlobal,
    Map<String, Object>? lambdaFusionSurface,
    Map<String, Object>? tableAdaptiveContext,
    Map<String, Object>? microUXEngine,
  }) => V4ToV3FallbackValidatorV1._(
    personaGlobal: _sanitize(personaGlobal),
    lambdaFusionSurface: _sanitize(lambdaFusionSurface),
    tableAdaptiveContext: _sanitize(tableAdaptiveContext),
    microUXEngine: _sanitize(microUXEngine),
  );

  final Map<String, Object> personaGlobal;
  final Map<String, Object> lambdaFusionSurface;
  final Map<String, Object> tableAdaptiveContext;
  final Map<String, Object> microUXEngine;

  Map<String, Object> build() {
    final String personaTag = _extractString(personaGlobal, 'global_tag');
    final String fusionTag = _extractString(lambdaFusionSurface, 'fusion_tag');
    final double microStrength = _extractDouble(
      microUXEngine,
      'engine_strength',
    );
    final double tableStrength = _extractDouble(
      tableAdaptiveContext,
      'surface_strength',
    );

    final double score =
        ((personaTag == fusionTag ? 1.0 : 0.0) +
            microStrength +
            tableStrength) /
        3.0;
    final String tag = score >= 0.75
        ? 'ready'
        : score >= 0.4
        ? 'degraded'
        : 'fallback';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'v4_to_v3_fallback_validator_v1':
          Map<String, Object>.unmodifiable(<String, Object>{
            'fallback_ready_score': score.clamp(0.0, 1.0),
            'fallback_tag': _ascii(tag),
            'ready': true,
          }),
    });
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
    final Map<String, Object> sanitized = <String, Object>{};
    for (final MapEntry<String, Object> entry in map.entries) {
      sanitized[_ascii(entry.key)] = entry.value;
    }
    return sanitized;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
