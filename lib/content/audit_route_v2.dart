class AuditRouteV2 {
  static Map<String, Object> build({required Map auditLineV2}) {
    return <String, Object>{
      'audit_route_v2': <String, Object>{'audit_line_v2': auditLineV2},
    };
  }
}
