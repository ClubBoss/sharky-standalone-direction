class AuditBridgeV2 {
  static Map<String, Object> build({required Map auditBinderV2}) {
    return <String, Object>{
      'audit_bridge_v2': <String, Object>{'audit_binder_v2': auditBinderV2},
    };
  }
}
