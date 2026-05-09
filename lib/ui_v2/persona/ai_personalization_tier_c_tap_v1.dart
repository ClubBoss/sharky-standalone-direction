class AIPersonalizationTierCTapV1 {
  const AIPersonalizationTierCTapV1({
    required this.finalToneMap,
    required this.finalTierMap,
    required this.finalBlendProxy,
    required this.personaContext,
  });

  final Object finalToneMap;
  final Object finalTierMap;
  final Object finalBlendProxy;
  final Object personaContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'tone': finalToneMap.toString(),
    'tier': finalTierMap.toString(),
    'blend': finalBlendProxy.toString(),
    'persona_ctx': personaContext.toString(),
  });
}
