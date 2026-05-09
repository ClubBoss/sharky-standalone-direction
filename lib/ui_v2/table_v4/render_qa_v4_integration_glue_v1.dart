class RenderQAV4IntegrationGlueV1 {
  const RenderQAV4IntegrationGlueV1(
    Object? renderQAV4FinalVerdictV1Map,
    Object? tableV4FinalReadinessGateV1Map,
    Object? tableV4RuntimeBundleConsolidatorV1Map,
    Object? tableV4ViewportIntegrityGuardV1Map,
    Object? tableV4DeviceFusionValidatorV1Map,
    Object? tableFinalVisualFusionV4Map,
    Object? tableFinalRenderEnvelopeFusionV4Map,
  ) : _renderQAV4FinalVerdictV1Map = renderQAV4FinalVerdictV1Map,
      _tableV4FinalReadinessGateV1Map = tableV4FinalReadinessGateV1Map,
      _tableV4RuntimeBundleConsolidatorV1Map =
          tableV4RuntimeBundleConsolidatorV1Map,
      _tableV4ViewportIntegrityGuardV1Map = tableV4ViewportIntegrityGuardV1Map,
      _tableV4DeviceFusionValidatorV1Map = tableV4DeviceFusionValidatorV1Map,
      _tableFinalVisualFusionV4Map = tableFinalVisualFusionV4Map,
      _tableFinalRenderEnvelopeFusionV4Map =
          tableFinalRenderEnvelopeFusionV4Map;

  final Object? _renderQAV4FinalVerdictV1Map;
  final Object? _tableV4FinalReadinessGateV1Map;
  final Object? _tableV4RuntimeBundleConsolidatorV1Map;
  final Object? _tableV4ViewportIntegrityGuardV1Map;
  final Object? _tableV4DeviceFusionValidatorV1Map;
  final Object? _tableFinalVisualFusionV4Map;
  final Object? _tableFinalRenderEnvelopeFusionV4Map;

  Map<String, Object> asReadOnlyMap() {
    final Map<String, Object?> domains = <String, Object?>{
      'device_fusion_validator': _tableV4DeviceFusionValidatorV1Map,
      'final_render_envelope_fusion': _tableFinalRenderEnvelopeFusionV4Map,
      'final_readiness_gate': _tableV4FinalReadinessGateV1Map,
      'final_verdict': _renderQAV4FinalVerdictV1Map,
      'final_visual_fusion': _tableFinalVisualFusionV4Map,
      'runtime_bundle_consolidator': _tableV4RuntimeBundleConsolidatorV1Map,
      'viewport_integrity_guard': _tableV4ViewportIntegrityGuardV1Map,
    };
    final List<String> keys = domains.keys.toList()..sort();
    final Map<String, Object> domainData = <String, Object>{};
    final List<String> missing = <String>[];
    bool integrationReady = true;

    for (final String key in keys) {
      final Object? value = domains[key];
      final bool exists = value != null;
      final bool isMap = value is Map;
      final bool nonEmpty = isMap && value.isNotEmpty;
      final bool ready = isMap && value['readiness'] == true;
      if (!exists || !isMap || !nonEmpty || !ready) {
        integrationReady = false;
        missing.add(key);
      }
      domainData[key] = <String, Object>{
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
    }

    return <String, Object>{
      'render_qa_v4_integration_glue_v1': <String, Object>{
        'domains': domainData,
        'missing': missing,
        'integration_ready': integrationReady,
      },
      'readiness': integrationReady,
    };
  }
}
