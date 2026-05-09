class AuditCertificateV2 {
  static Map<String, Object> build({required Map auditEvidenceV2}) {
    return <String, Object>{
      'audit_certificate_v2': <String, Object>{
        'audit_evidence_v2': auditEvidenceV2,
      },
    };
  }
}
