class AuditStampV2 {
  static Map<String, Object> build({required Map auditSealV2}) {
    return <String, Object>{
      'audit_stamp_v2': <String, Object>{'audit_seal_v2': auditSealV2},
    };
  }
}
