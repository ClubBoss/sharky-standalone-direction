class ContentRuntimeMaestroV2 {
  static Map<String, Object> build({required Map runtimeConductorV2}) {
    return <String, Object>{
      'content_runtime_maestro_v2': <String, Object>{
        'runtime_conductor_v2': runtimeConductorV2,
      },
    };
  }
}
