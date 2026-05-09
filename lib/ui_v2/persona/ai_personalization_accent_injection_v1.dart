/// Passive accent injection layer for personalization (Phi-37).
class AIPersonalizationAccentInjectionV1 {
  const AIPersonalizationAccentInjectionV1(this.accentDeltaMap, this.tokenMap);

  final Map<String, Object> accentDeltaMap;
  final Map<String, Object> tokenMap;

  Map<String, Object> run() {
    final bool hasAccentDelta = accentDeltaMap.isNotEmpty;
    final bool hasTokenMap = tokenMap.isNotEmpty;
    final List<String> accentInjectionMissing = <String>[];
    if (!hasAccentDelta) accentInjectionMissing.add('accent_delta');
    if (!hasTokenMap) accentInjectionMissing.add('token_map');

    final Map<String, Object> accentInjectionMap = <String, Object>{}
      ..addAll(tokenMap);
    accentDeltaMap.forEach((key, value) {
      accentInjectionMap['ai_inj_$key'] = value;
    });
    accentInjectionMap['ai_inj_factor'] = accentDeltaMap['ad_factor'] ?? 0.0;

    final bool accentInjectionReady =
        hasAccentDelta && hasTokenMap && accentInjectionMissing.isEmpty;

    return <String, Object>{
      'has_accent_delta': hasAccentDelta,
      'has_token_map': hasTokenMap,
      'accent_injection_missing': accentInjectionMissing,
      'accent_injection_ready': accentInjectionReady,
      'accent_injection_map': accentInjectionMap,
    };
  }
}
