class AuditChainV2 {
  static Map<String, Object> build({required Map auditLinkV2}) {
    return <String, Object>{
      'audit_chain_v2': <String, Object>{'audit_link_v2': auditLinkV2},
    };
  }
}
