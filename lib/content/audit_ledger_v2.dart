class AuditLedgerV2 {
  static Map<String, Object> build({required Map auditCertificateV2}) {
    return <String, Object>{
      'audit_ledger_v2': <String, Object>{
        'audit_certificate_v2': auditCertificateV2,
      },
    };
  }
}
