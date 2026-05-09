class AuditPathV2 {
  static Map<String, Object> build({required Map auditTraceV2}) {
    return <String, Object>{
      'audit_path_v2': <String, Object>{'audit_trace_v2': auditTraceV2},
    };
  }
}
