class ContentRuntimeFrameV2 {
  static Map<String, Object> build({required Map runtimeWindowV2}) {
    return <String, Object>{
      'content_runtime_frame_v2': <String, Object>{
        'runtime_window_v2': runtimeWindowV2,
      },
    };
  }
}
