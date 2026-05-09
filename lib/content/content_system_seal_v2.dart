class ContentSystemSealV2 {
  const ContentSystemSealV2();

  static Map<String, Object> build({
    required Map<String, Object> contentSystemOmegaV2,
  }) {
    return {
      "content_system_seal_v2": {
        "content_system_omega_v2": contentSystemOmegaV2,
      },
    };
  }
}
