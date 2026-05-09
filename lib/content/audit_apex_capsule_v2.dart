class AuditApexCapsuleV2 {
  static Map<String, Object> build({required Map auditApexShellV2}) {
    return <String, Object>{
      'audit_apex_capsule_v2': <String, Object>{
        'audit_apex_shell_v2': auditApexShellV2,
      },
    };
  }
}
