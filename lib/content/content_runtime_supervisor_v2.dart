class ContentRuntimeSupervisorV2 {
  static Map<String, Object> build({required Map runtimeOverseerV2}) {
    return <String, Object>{
      'content_runtime_supervisor_v2': <String, Object>{
        'runtime_overseer_v2': runtimeOverseerV2,
      },
    };
  }
}
