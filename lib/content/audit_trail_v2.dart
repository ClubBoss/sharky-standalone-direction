class AuditTrailV2 {
  static Map<String, Object> build({required Map auditContinuumV2}) {
    return <String, Object>{
      'audit_trail_v2': <String, Object>{
        'audit_continuum_v2': auditContinuumV2,
      },
    };
  }
}
