class AuditPillarV2 {
  static Map<String, Object> build({required Map auditColumnV2}) {
    return <String, Object>{
      'audit_pillar_v2': <String, Object>{'audit_column_v2': auditColumnV2},
    };
  }
}
