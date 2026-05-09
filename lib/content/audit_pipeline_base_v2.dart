class AuditPipelineBaseV2 {
  static Map<String, Object> build({required Map auditAnchorV2}) {
    return <String, Object>{
      'audit_pipeline_base_v2': <String, Object>{
        'audit_anchor_v2': auditAnchorV2,
      },
    };
  }
}
