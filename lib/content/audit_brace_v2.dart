class AuditBraceV2 {
  static Map<String, Object> build({required Map auditBeamV2}) {
    return <String, Object>{
      'audit_brace_v2': <String, Object>{'audit_beam_v2': auditBeamV2},
    };
  }
}
