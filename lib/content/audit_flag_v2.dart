class AuditFlagV2 {
  static Map<String, Object> build({required Map auditMarkerV2}) {
    return <String, Object>{
      'audit_flag_v2': <String, Object>{'audit_marker_v2': auditMarkerV2},
    };
  }
}
