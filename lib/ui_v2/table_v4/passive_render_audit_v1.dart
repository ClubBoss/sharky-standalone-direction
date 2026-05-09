class PassiveRenderAuditV1 {
  const PassiveRenderAuditV1(Object? fusion, Object? seal, Object? bundle)
    : _fusion = fusion,
      _seal = seal,
      _bundle = bundle;

  final Object? _fusion;
  final Object? _seal;
  final Object? _bundle;

  Map<String, Object> asReadOnlyMap() {
    final Map sections = {};
    final List missing = [];
    bool auditReady = true;

    void record(String key, Object? value) {
      final bool exists = value != null;
      final bool isMap = value is Map;
      bool nonEmpty = false;
      bool ready = false;
      if (value is Map) {
        nonEmpty = value.isNotEmpty;
        ready = value['readiness'] == true;
      }
      sections[key] = {
        'exists': exists,
        'is_map': isMap,
        'non_empty': nonEmpty,
        'ready': ready,
      };
      if (!exists || !isMap || !nonEmpty) {
        auditReady = false;
        missing.add(key);
      }
    }

    record('final_render_envelope_fusion_v4', _fusion);
    record('table_render_stability_seal_v1', _seal);
    record('unified_render_bundle_v1', _bundle);

    return {
      'passive_render_audit_v1': {
        'sections': sections,
        'missing': missing,
        'audit_ready': auditReady,
      },
      'readiness': auditReady,
    };
  }
}
