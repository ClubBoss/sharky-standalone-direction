class ContentSystemOmegaV2 {
  const ContentSystemOmegaV2();

  static Map<String, Object> build({
    required Map<String, Object> contentSystemFinalV2,
  }) {
    return {
      "content_system_omega_v2": {
        "content_system_final_v2": contentSystemFinalV2,
      },
    };
  }
}
