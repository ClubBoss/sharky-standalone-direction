class AuditVertexV2 {
  static Map<String, Object> build({required Map auditNodeV2}) {
    return <String, Object>{
      'audit_vertex_v2': <String, Object>{'audit_node_v2': auditNodeV2},
    };
  }
}
