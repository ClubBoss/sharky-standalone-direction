class AuditAnchorV2 {
  static Map<String, Object> build({required Map miniAuditV2}) {
    return <String, Object>{
      'audit_anchor_v2': <String, Object>{'mini_audit_v2': miniAuditV2},
    };
  }
}
