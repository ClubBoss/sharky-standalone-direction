class AuditSpineV2 {
  static Map<String, Object> build({required Map auditNexusV2}) {
    return <String, Object>{
      'audit_spine_v2': <String, Object>{'audit_nexus_v2': auditNexusV2},
    };
  }
}
