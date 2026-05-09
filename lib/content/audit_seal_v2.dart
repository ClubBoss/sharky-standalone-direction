class AuditSealV2 {
  static Map<String, Object> build({required Map auditTokenV2}) {
    return <String, Object>{
      'audit_seal_v2': <String, Object>{'audit_token_v2': auditTokenV2},
    };
  }
}
