class AuditTokenV2 {
  static Map<String, Object> build({required Map auditFlagV2}) {
    return <String, Object>{
      'audit_token_v2': <String, Object>{'audit_flag_v2': auditFlagV2},
    };
  }
}
