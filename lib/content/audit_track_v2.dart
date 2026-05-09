class AuditTrackV2 {
  static Map<String, Object> build({required Map auditRouteV2}) {
    return <String, Object>{
      'audit_track_v2': <String, Object>{'audit_route_v2': auditRouteV2},
    };
  }
}
