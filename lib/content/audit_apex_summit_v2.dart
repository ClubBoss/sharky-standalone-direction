class AuditApexSummitV2 {
  const AuditApexSummitV2();

  static Map<String, Object> build({
    required Map<String, Object> apexThroneV2,
  }) {
    return {
      "audit_apex_summit_v2": {"apex_throne_v2": apexThroneV2},
    };
  }
}
