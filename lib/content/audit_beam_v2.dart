class AuditBeamV2 {
  static Map<String, Object> build({required Map auditPillarV2}) {
    return <String, Object>{
      'audit_beam_v2': <String, Object>{'audit_pillar_v2': auditPillarV2},
    };
  }
}
