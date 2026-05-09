class AuditShellV2 {
  static Map<String, Object> build({required Map auditFrameV2}) {
    return <String, Object>{
      'audit_shell_v2': <String, Object>{'audit_frame_v2': auditFrameV2},
    };
  }
}
