class PersonaThemeAlignmentV1 {
  PersonaThemeAlignmentV1._({
    required this.personaGlobal,
    required this.lambdaFusionSurface,
    required this.typographyPolish,
    required this.glowHaloSpec,
  });

  factory PersonaThemeAlignmentV1.build({
    Map<String, Object>? personaGlobal,
    Map<String, Object>? lambdaFusionSurface,
    Map<String, Object>? typographyPolish,
    Map<String, Object>? glowHaloSpec,
  }) => PersonaThemeAlignmentV1._(
    personaGlobal: _sanitize(personaGlobal),
    lambdaFusionSurface: _sanitize(lambdaFusionSurface),
    typographyPolish: _sanitize(typographyPolish),
    glowHaloSpec: _sanitize(glowHaloSpec),
  );

  final Map<String, Object> personaGlobal;
  final Map<String, Object> lambdaFusionSurface;
  final Map<String, Object> typographyPolish;
  final Map<String, Object> glowHaloSpec;

  Map<String, Object> build() {
    final String personaTag = _extractString(personaGlobal, 'global_tag');
    final String fusionTag = _extractString(lambdaFusionSurface, 'fusion_tag');
    final double typographyWeight = _extractDouble(
      typographyPolish,
      'resolvedWeight',
    );
    final double glowIntensity = _extractDouble(glowHaloSpec, 'intensity');

    final double alignmentScore =
        ((personaTag == fusionTag ? 1.0 : 0.0) +
            typographyWeight.clamp(0.0, 1.0) +
            glowIntensity.clamp(0.0, 1.0)) /
        3.0;
    final String alignmentTag = alignmentScore >= 0.75
        ? 'strong'
        : alignmentScore >= 0.4
        ? 'medium'
        : 'weak';

    return Map<String, Object>.unmodifiable(<String, Object>{
      'persona_theme_alignment_v1':
          Map<String, Object>.unmodifiable(<String, Object>{
            'alignment_score': alignmentScore.clamp(0.0, 1.0),
            'alignment_tag': _ascii(alignmentTag),
            'ready': true,
          }),
    });
  }

  static Map<String, Object> _sanitize(Map<String, Object>? map) {
    if (map == null) return const <String, Object>{};
    final Map<String, Object> sanitized = <String, Object>{};
    for (final MapEntry<String, Object> entry in map.entries) {
      sanitized[_ascii(entry.key)] = entry.value;
    }
    return sanitized;
  }

  static String _extractString(Map<String, Object> map, String key) =>
      (map[key] as String?)?.trim() ?? '';

  static double _extractDouble(Map<String, Object> map, String key) {
    final Object? value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
