class AuditRecordV2 {
  static Map<String, Object> build({required Map auditProofV2}) {
    return <String, Object>{
      'audit_record_v2': <String, Object>{'audit_proof_v2': auditProofV2},
    };
  }
}
