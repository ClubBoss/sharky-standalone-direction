class SystemRenderAlignmentSealV1 {
  const SystemRenderAlignmentSealV1(
    Object? systemQAStabilityCrownV1Map,
    Object? renderQAV4FinalVerdictV1Map,
    Object? renderQAV4IntegrationGlueV1Map,
    Object? runtimeFinalSealV4GateV1Map,
    Object? runtimeGlobalVerdictV1Map,
    Object? runtimeSystemFusionSurfaceV1Map,
  ) : _systemCrown = systemQAStabilityCrownV1Map,
      _renderFinal = renderQAV4FinalVerdictV1Map,
      _renderGlue = renderQAV4IntegrationGlueV1Map,
      _runtimeSeal = runtimeFinalSealV4GateV1Map,
      _runtimeVerdict = runtimeGlobalVerdictV1Map,
      _runtimeSurface = runtimeSystemFusionSurfaceV1Map;

  final Object? _systemCrown,
      _renderFinal,
      _renderGlue,
      _runtimeSeal,
      _runtimeVerdict,
      _runtimeSurface;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = {
      'render_final_verdict': _renderFinal,
      'render_integration_glue': _renderGlue,
      'runtime_final_seal': _runtimeSeal,
      'runtime_global_verdict': _runtimeVerdict,
      'runtime_system_fusion_surface': _runtimeSurface,
      'system_stability_crown': _systemCrown,
    };
    final List<String> missing = <String>[];
    bool alignmentReady = true;
    final Map<String, Object> status = <String, Object>{};
    for (final String key in (domains.keys.toList()..sort())) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!(exists && isMap && nonEmpty && ready)) {
        missing.add(key);
        alignmentReady = false;
      }
      status[key] = {
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }
    return {
      'system_render_alignment_seal_v1': {
        'domains': status,
        'missing': missing,
        'alignment_ready': alignmentReady,
      },
      'readiness': alignmentReady,
    };
  }
}
