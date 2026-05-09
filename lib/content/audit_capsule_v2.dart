class AuditCapsuleV2 {
  static Map<String, Object> build({required Map auditShellV2}) {
    return <String, Object>{
      'audit_capsule_v2': <String, Object>{'audit_shell_v2': auditShellV2},
    };
  }
}
