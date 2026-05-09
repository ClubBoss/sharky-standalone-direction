class AuditJointV2 {
  static Map<String, Object> build({required Map auditBraceV2}) {
    return <String, Object>{
      'audit_joint_v2': <String, Object>{'audit_brace_v2': auditBraceV2},
    };
  }
}
