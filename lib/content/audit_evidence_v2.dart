class AuditEvidenceV2 {
  static Map<String, Object> build({required Map auditRecordV2}) {
    return <String, Object>{
      'audit_evidence_v2': <String, Object>{'audit_record_v2': auditRecordV2},
    };
  }
}
