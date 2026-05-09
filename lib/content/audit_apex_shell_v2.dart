class AuditApexShellV2 {
  static Map<String, Object> build({required Map auditApexLayerV2}) {
    return <String, Object>{
      'audit_apex_shell_v2': <String, Object>{
        'audit_apex_layer_v2': auditApexLayerV2,
      },
    };
  }
}
