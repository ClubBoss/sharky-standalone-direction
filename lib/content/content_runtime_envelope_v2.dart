class ContentRuntimeEnvelopeV2 {
  const ContentRuntimeEnvelopeV2();

  static Map<String, Object> build({
    required Map<String, Object> contentSystemAssemblyV2,
  }) {
    return {
      "content_runtime_envelope_v2": {
        "content_system_assembly_v2": contentSystemAssemblyV2,
      },
    };
  }
}
