class ContentRuntimeSealV3 {
  const ContentRuntimeSealV3();

  static Map<String, Object> build({
    required Map<String, Object> contentRuntimeEntryPointV3,
  }) {
    return {
      "content_runtime_seal_v3": {
        "content_runtime_entry_point_v3": contentRuntimeEntryPointV3,
      },
    };
  }
}
