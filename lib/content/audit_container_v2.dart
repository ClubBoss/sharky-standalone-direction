class AuditContainerV2 {
  static Map<String, Object> build({required Map auditCapsuleV2}) {
    return <String, Object>{
      'audit_container_v2': <String, Object>{
        'audit_capsule_v2': auditCapsuleV2,
      },
    };
  }
}
