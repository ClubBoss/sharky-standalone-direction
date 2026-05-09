/// Passive V4 activation visual binding (Phi-4).
class V4ActivationVisualBindingV1 {
  const V4ActivationVisualBindingV1(
    this.activationFrame,
    this.activationSync,
    this.materialization,
    this.surfacePolish,
    this.tokenRegistry,
  );

  final Map<String, Object> activationFrame;
  final Map<String, Object> activationSync;
  final Map<String, Object> materialization;
  final Map<String, Object> surfacePolish;
  final Map<String, Object> tokenRegistry;

  Map<String, Object> run() {
    final bool hasActivationFrame = activationFrame.isNotEmpty;
    final bool hasSync = activationSync.isNotEmpty;
    final bool hasMaterialization = materialization.isNotEmpty;
    final bool hasSurfacePolish = surfacePolish.isNotEmpty;
    final bool hasTokens = tokenRegistry.isNotEmpty;

    final Map<String, Object> visualContext = <String, Object>{};
    void _merge(Map<String, Object> source) {
      source.forEach((key, value) {
        visualContext[key] = value;
      });
    }

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
    _merge(tokenRegistry);

    final bool bindingReady =
        hasActivationFrame &&
        hasSync &&
        hasMaterialization &&
        hasSurfacePolish &&
        hasTokens &&
        visualContext.isNotEmpty;

    return <String, Object>{
      'has_activation_frame': hasActivationFrame,
      'has_sync': hasSync,
      'has_materialization': hasMaterialization,
      'has_surface_polish': hasSurfacePolish,
      'has_tokens': hasTokens,
      'visual_context': visualContext,
      'binding_ready': bindingReady,
    };
  }
}
