class ContentSystemFinalAccessPointV1 {
  static Map<String, Object> build({
    required Map contentSystemFinalMasterEnvelopeV1,
  }) {
    return <String, Object>{
      'content_system_final_access_point_v1': <String, Object>{
        'content_system_final_master_envelope_v1':
            contentSystemFinalMasterEnvelopeV1,
      },
    };
  }
}
