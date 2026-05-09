class V4ToV3FallbackValidatorV1 {
  const V4ToV3FallbackValidatorV1(
    this.tableVisualSealV4Map,
    this.tableRenderSurfaceV4Map,
    this.tableVisualSurfaceV4Map,
    this.tableRenderEnvelopeV2Map,
    this.tableUIBootEnvelopeV1Map,
    this.tableUIPathVerdictV1Map,
  );

  final Object tableVisualSealV4Map;
  final Object tableRenderSurfaceV4Map;
  final Object tableVisualSurfaceV4Map;
  final Object tableRenderEnvelopeV2Map;
  final Object tableUIBootEnvelopeV1Map;
  final Object tableUIPathVerdictV1Map;

  Map<String, Object> asReadOnlyMap() {
    Map<String, Object> m(Object v) => v is Map && v.isNotEmpty
        ? v.cast<String, Object>()
        : <String, Object>{};
    bool ready(Object v) => v is Map && v['readiness'] == true;
    final Map<String, Object> domains = <String, Object>{
      'visual_seal': m(tableVisualSealV4Map),
      'render_surface': m(tableRenderSurfaceV4Map),
      'visual_surface': m(tableVisualSurfaceV4Map),
      'render_envelope': m(tableRenderEnvelopeV2Map),
      'boot_envelope': m(tableUIBootEnvelopeV1Map),
      'path_verdict': m(tableUIPathVerdictV1Map),
    };
    final List<String> missing = domains.entries
        .where((entry) {
          final value = entry.value;
          final bool empty = value is Map && value.isEmpty;
          return empty || !ready(value);
        })
        .map((entry) => entry.key)
        .toList();
    final bool readyFlag = missing.isEmpty;
    return <String, Object>{
      'v4_to_v3_fallback_validator_v1': <String, Object>{
        'domains': domains,
        'missing': missing,
        'fallback_ready': readyFlag,
      },
      'readiness': readyFlag,
    };
  }
}
