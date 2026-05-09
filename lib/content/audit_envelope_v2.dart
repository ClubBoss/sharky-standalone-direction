class AuditEnvelopeV2 {
  static Map<String, Object> build({required Map auditContainerV2}) {
    return <String, Object>{
      'audit_envelope_v2': <String, Object>{
        'audit_container_v2': auditContainerV2,
      },
    };
  }
}
