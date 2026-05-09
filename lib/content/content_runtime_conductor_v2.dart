class ContentRuntimeConductorV2 {
  static Map<String, Object> build({required Map runtimeOrchestratorV2}) {
    return <String, Object>{
      'content_runtime_conductor_v2': <String, Object>{
        'runtime_orchestrator_v2': runtimeOrchestratorV2,
      },
    };
  }
}
