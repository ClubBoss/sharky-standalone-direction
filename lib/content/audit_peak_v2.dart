class AuditPeakV2 {
  static Map<String, Object> build({required Map auditSummitV2}) {
    return <String, Object>{
      'audit_peak_v2': <String, Object>{'audit_summit_v2': auditSummitV2},
    };
  }
}
