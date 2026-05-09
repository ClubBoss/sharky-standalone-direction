class AuditNodeV2 {
  static Map<String, Object> build({required Map auditJointV2}) {
    return <String, Object>{
      'audit_node_v2': <String, Object>{'audit_joint_v2': auditJointV2},
    };
  }
}
