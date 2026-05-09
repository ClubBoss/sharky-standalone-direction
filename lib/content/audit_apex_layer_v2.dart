class AuditApexLayerV2 {
  static Map<String, Object> build({required Map auditApexFrameV2}) {
    return <String, Object>{
      'audit_apex_layer_v2': <String, Object>{
        'audit_apex_frame_v2': auditApexFrameV2,
      },
    };
  }
}
