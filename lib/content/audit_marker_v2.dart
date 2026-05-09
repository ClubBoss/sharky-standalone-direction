class AuditMarkerV2 {
  static Map<String, Object> build({required Map auditPointV2}) {
    return <String, Object>{
      'audit_marker_v2': <String, Object>{'audit_point_v2': auditPointV2},
    };
  }
}
