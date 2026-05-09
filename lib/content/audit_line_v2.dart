class AuditLineV2 {
  static Map<String, Object> build({required Map auditPathV2}) {
    return <String, Object>{
      'audit_line_v2': <String, Object>{'audit_path_v2': auditPathV2},
    };
  }
}
