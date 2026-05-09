class ContentSystemFinalGatewayV1 {
  static Map<String, Object> build({required Map consolidatedFinalExportV2}) {
    return <String, Object>{
      'content_system_final_gateway_v1': <String, Object>{
        'consolidated_final_export_v2': consolidatedFinalExportV2,
      },
    };
  }
}
