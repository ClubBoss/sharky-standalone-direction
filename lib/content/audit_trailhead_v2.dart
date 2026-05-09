class AuditTrailheadV2 {
  static Map<String, Object> build({required Map auditTrackV2}) {
    return <String, Object>{
      'audit_trailhead_v2': <String, Object>{'audit_track_v2': auditTrackV2},
    };
  }
}
