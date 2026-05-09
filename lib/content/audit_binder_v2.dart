class AuditBinderV2 {
  static Map<String, Object> build({required Map auditWrapperV2}) {
    return <String, Object>{
      'audit_binder_v2': <String, Object>{'audit_wrapper_v2': auditWrapperV2},
    };
  }
}
