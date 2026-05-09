class AuditHubV2 {
  static Map<String, Object> build({required Map auditCoreV2}) {
    return <String, Object>{
      'audit_hub_v2': <String, Object>{'audit_core_v2': auditCoreV2},
    };
  }
}
