class AuditContinuumV2 {
  static Map<String, Object> build({required Map auditChronicleV2}) {
    return <String, Object>{
      'audit_continuum_v2': <String, Object>{
        'audit_chronicle_v2': auditChronicleV2,
      },
    };
  }
}
