class ContentRuntimeCapsuleV2 {
  static Map<String, Object> build({required Map runtimeShellV2}) {
    return <String, Object>{
      'content_runtime_capsule_v2': <String, Object>{
        'runtime_shell_v2': runtimeShellV2,
      },
    };
  }
}
