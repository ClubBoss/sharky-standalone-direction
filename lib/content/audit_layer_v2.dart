class AuditLayerV2 {
  static Map<String, Object> build({required Map auditPipelineBaseV2}) {
    return <String, Object>{
      'audit_layer_v2': <String, Object>{
        'audit_pipeline_base_v2': auditPipelineBaseV2,
      },
    };
  }
}
