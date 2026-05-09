class ContentSystemExportEnvelopeV1 {
  static Map<String, Object> build({required Map finalGatewayV1}) {
    return <String, Object>{
      'content_system_export_envelope_v1': <String, Object>{
        'final_gateway_v1': finalGatewayV1,
      },
    };
  }
}
