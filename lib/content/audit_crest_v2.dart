class AuditCrestV2 {
  static Map<String, Object> build({required Map auditPeakV2}) {
    return <String, Object>{
      'audit_crest_v2': <String, Object>{'audit_peak_v2': auditPeakV2},
    };
  }
}
