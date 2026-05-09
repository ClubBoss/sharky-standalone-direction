class AuditPinnacleV2 {
  static Map<String, Object> build({required Map auditCrestV2}) {
    return <String, Object>{
      'audit_pinnacle_v2': <String, Object>{'audit_crest_v2': auditCrestV2},
    };
  }
}
