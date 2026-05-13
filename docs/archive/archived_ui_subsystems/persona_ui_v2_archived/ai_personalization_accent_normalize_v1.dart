/// Passive accent normalization layer for personalization (Phi-38).
class AIPersonalizationAccentNormalizeV1 {
  const AIPersonalizationAccentNormalizeV1(this.accentInjectionMap);

  final Map<String, Object> accentInjectionMap;

  Map<String, Object> run() {
    final List<String> accentNormMissing = <String>[];
    if (accentInjectionMap.isEmpty)
      accentNormMissing.add('accent_injection_map');

    final double accentNormFactor = accentInjectionMap['ai_inj_factor'] is num
        ? (accentInjectionMap['ai_inj_factor'] as num).toDouble()
        : 0.0;

    final Map<String, Object> accentNormMap = <String, Object>{};
    accentInjectionMap.forEach((key, value) {
      if (key.startsWith('ai_inj_') && value is num) {
        final double normalized = (value.toDouble() * accentNormFactor).clamp(
          0.0,
          1.0,
        );
        accentNormMap[key] = normalized;
      } else {
        accentNormMap[key] = value;
      }
    });

    final bool accentNormReady = accentNormMissing.isEmpty;

    return <String, Object>{
      'accent_norm_missing': accentNormMissing,
      'accent_norm_ready': accentNormReady,
      'accent_norm_factor': accentNormFactor,
      'accent_norm_map': accentNormMap,
    };
  }
}
