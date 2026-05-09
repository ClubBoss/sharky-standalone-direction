class V4ThemeBlendingProxyV1 {
  const V4ThemeBlendingProxyV1({
    required this.baseTheme,
    required this.personaThemeOverrides,
    required this.toneMap,
    required this.tierMap,
  });

  final Object baseTheme;
  final Object personaThemeOverrides;
  final Object toneMap;
  final Object tierMap;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'base': baseTheme.toString(),
    'persona_overrides': personaThemeOverrides.toString(),
    'tone': toneMap.toString(),
    'tier': tierMap.toString(),
  });
}
