class AuditWrapperV2 {
  static Map<String, Object> build({required Map auditEnvelopeV2}) {
    return <String, Object>{
      'audit_wrapper_v2': <String, Object>{
        'audit_envelope_v2': auditEnvelopeV2,
      },
    };
  }
}
