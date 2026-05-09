class AuditApexCrownV2 {
  const AuditApexCrownV2();

  static Map<String, Object> build({
    required Map<String, Object> apexCapsuleV2,
  }) {
    return {
      "audit_apex_crown_v2": {"apex_capsule_v2": apexCapsuleV2},
    };
  }
}
