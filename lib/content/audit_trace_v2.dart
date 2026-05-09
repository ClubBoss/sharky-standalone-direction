class AuditTraceV2 {
  static Map<String, Object> build({required Map auditTrailV2}) {
    return <String, Object>{
      'audit_trace_v2': <String, Object>{'audit_trail_v2': auditTrailV2},
    };
  }
}
