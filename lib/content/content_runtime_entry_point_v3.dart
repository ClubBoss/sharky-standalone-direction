class ContentRuntimeEntryPointV3 {
  const ContentRuntimeEntryPointV3();

  static Map<String, Object> build({
    required Map<String, Object> contentSystemFinalIntegratorV3,
  }) {
    return {
      "content_runtime_entry_point_v3": {
        "content_system_final_integrator_v3": contentSystemFinalIntegratorV3,
      },
    };
  }
}
