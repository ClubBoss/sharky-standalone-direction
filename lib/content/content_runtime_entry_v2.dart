class ContentRuntimeEntryV2 {
  static Map<String, Object> build({required Map finalIntegratorV2}) {
    return <String, Object>{
      'content_runtime_entry_v2': <String, Object>{
        'final_integrator_v2': finalIntegratorV2,
      },
    };
  }
}
