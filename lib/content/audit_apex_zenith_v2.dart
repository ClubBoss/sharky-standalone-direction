class AuditApexZenithV2 {
  const AuditApexZenithV2();

  static Map<String, Object> build({
    required Map<String, Object> apexSummitV2,
  }) {
    return {
      "audit_apex_zenith_v2": {"apex_summit_v2": apexSummitV2},
    };
  }
}
