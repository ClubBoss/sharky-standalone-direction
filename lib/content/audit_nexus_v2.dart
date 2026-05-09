class AuditNexusV2 {
  static Map<String, Object> build({required Map auditHubV2}) {
    return <String, Object>{
      'audit_nexus_v2': <String, Object>{'audit_hub_v2': auditHubV2},
    };
  }
}
