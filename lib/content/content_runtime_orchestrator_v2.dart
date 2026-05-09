class ContentRuntimeOrchestratorV2 {
  static Map<String, Object> build({required Map runtimeDirectorV2}) {
    return <String, Object>{
      'content_runtime_orchestrator_v2': <String, Object>{
        'runtime_director_v2': runtimeDirectorV2,
      },
    };
  }
}
