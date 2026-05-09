class AuditColumnV2 {
  static Map<String, Object> build({required Map auditSpineV2}) {
    return <String, Object>{
      'audit_column_v2': <String, Object>{'audit_spine_v2': auditSpineV2},
    };
  }
}
