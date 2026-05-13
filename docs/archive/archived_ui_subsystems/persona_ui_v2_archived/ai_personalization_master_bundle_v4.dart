class AIPersonalizationMasterBundleV4 {
  const AIPersonalizationMasterBundleV4({
    required this.tierAContext,
    required this.tierBContext,
    required this.tierCContext,
    required this.personaContext,
  });

  final Object tierAContext;
  final Object tierBContext;
  final Object tierCContext;
  final Object personaContext;

  Map<String, Object> asReadOnlyMap() => Map<String, Object>.unmodifiable({
    'tier_a': tierAContext.toString(),
    'tier_b': tierBContext.toString(),
    'tier_c': tierCContext.toString(),
    'persona_ctx': personaContext.toString(),
  });
}
