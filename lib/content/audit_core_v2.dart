class AuditCoreV2 {
  static Map<String, Object> build({required Map auditChainV2}) {
    return <String, Object>{
      'audit_core_v2': <String, Object>{'audit_chain_v2': auditChainV2},
    };
  }
}
