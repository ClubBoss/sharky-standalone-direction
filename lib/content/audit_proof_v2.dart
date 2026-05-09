class AuditProofV2 {
  static Map<String, Object> build({required Map auditStampV2}) {
    return <String, Object>{
      'audit_proof_v2': <String, Object>{'audit_stamp_v2': auditStampV2},
    };
  }
}
