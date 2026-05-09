/// Passive full visual pass consolidator (Phi-5).
class V4VisualFullPassV1 {
  const V4VisualFullPassV1(
    this.tokenRegistry,
    this.themeDeltas,
    this.activationFrame,
    this.activationSync,
    this.materialization,
    this.surfacePolish,
    this.visualBindingV1,
    this.personaConsistency,
    this.visualQAPreLift,
  );

  final Map<String, Object> tokenRegistry;
  final Map<String, Object> themeDeltas;
  final Map<String, Object> activationFrame;
  final Map<String, Object> activationSync;
  final Map<String, Object> materialization;
  final Map<String, Object> surfacePolish;
  final Map<String, Object> visualBindingV1;
  final Map<String, Object> personaConsistency;
  final Map<String, Object> visualQAPreLift;

  Map<String, Object> run() {
    final bool hasTokens = tokenRegistry.isNotEmpty;
    final bool hasTheme = themeDeltas.isNotEmpty;
    final bool hasActivation =
        activationFrame.isNotEmpty && activationSync.isNotEmpty;
    final bool hasMaterialization = materialization.isNotEmpty;
    final bool hasSurfacePolish = surfacePolish.isNotEmpty;
    final bool hasVisualBinding = visualBindingV1.isNotEmpty;
    final bool hasPersonaConsistency = personaConsistency.isNotEmpty;
    final bool hasPreLift = visualQAPreLift.isNotEmpty;

    final Map<String, Object> visualFullMap = <String, Object>{};
    void _merge(Map<String, Object> source) {
      source.forEach((key, value) {
        visualFullMap[key] = value;
      });
    }

    _merge(tokenRegistry);
    _merge(themeDeltas);
    _merge(surfacePolish);

    final Map<String, Object> materializationSurface =
        materialization['surface'] is Map<String, Object>
        ? materialization['surface'] as Map<String, Object>
        : <String, Object>{};
    if (materializationSurface.isNotEmpty) {
      _merge(materializationSurface);
    }
    final Map<String, Object> materializationRest = Map<String, Object>.from(
      materialization,
    )..remove('surface');
    _merge(materializationRest);

    _merge(activationFrame);
    _merge(activationSync);
    _merge(visualBindingV1);
    _merge(personaConsistency);
    _merge(visualQAPreLift);

    final bool fullReady =
        hasTokens &&
        hasTheme &&
        hasActivation &&
        hasMaterialization &&
        hasSurfacePolish &&
        hasVisualBinding &&
        hasPersonaConsistency &&
        hasPreLift &&
        visualFullMap.isNotEmpty;

    return <String, Object>{
      'has_tokens': hasTokens,
      'has_theme': hasTheme,
      'has_activation': hasActivation,
      'has_materialization': hasMaterialization,
      'has_surface_polish': hasSurfacePolish,
      'has_visual_binding': hasVisualBinding,
      'has_persona_consistency': hasPersonaConsistency,
      'has_pre_lift': hasPreLift,
      'visual_full_map': visualFullMap,
      'full_ready': fullReady,
    };
  }
}
