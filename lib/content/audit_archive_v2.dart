class AuditArchiveV2 {
  static Map<String, Object> build({required Map auditLedgerV2}) {
    return <String, Object>{
      'audit_archive_v2': <String, Object>{'audit_ledger_v2': auditLedgerV2},
    };
  }
}
