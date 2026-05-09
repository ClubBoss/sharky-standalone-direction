class AuditPointV2 {
  static Map<String, Object> build({required Map auditVertexV2}) {
    return <String, Object>{
      'audit_point_v2': <String, Object>{'audit_vertex_v2': auditVertexV2},
    };
  }
}
