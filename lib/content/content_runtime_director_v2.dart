class ContentRuntimeDirectorV2 {
  static Map<String, Object> build({required Map runtimeSupervisorV2}) {
    return <String, Object>{
      'content_runtime_director_v2': <String, Object>{
        'runtime_supervisor_v2': runtimeSupervisorV2,
      },
    };
  }
}
