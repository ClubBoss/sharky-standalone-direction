class AuditFrameV2 {
  static Map<String, Object> build({required Map auditLayerV2}) {
    return <String, Object>{
      'audit_frame_v2': <String, Object>{'audit_layer_v2': auditLayerV2},
    };
  }
}
