class AuditSummitV2 {
  static Map<String, Object> build({required Map auditTrailheadV2}) {
    return <String, Object>{
      'audit_summit_v2': <String, Object>{
        'audit_trailhead_v2': auditTrailheadV2,
      },
    };
  }
}
