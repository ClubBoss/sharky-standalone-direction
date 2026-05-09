class AuditChronicleV2 {
  static Map<String, Object> build({required Map auditArchiveV2}) {
    return <String, Object>{
      'audit_chronicle_v2': <String, Object>{
        'audit_archive_v2': auditArchiveV2,
      },
    };
  }
}
