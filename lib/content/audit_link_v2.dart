class AuditLinkV2 {
  static Map<String, Object> build({required Map auditBridgeV2}) {
    return <String, Object>{
      'audit_link_v2': <String, Object>{'audit_bridge_v2': auditBridgeV2},
    };
  }
}
