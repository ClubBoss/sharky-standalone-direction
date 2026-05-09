class ContentRuntimeFinalizerV2 {
  static Map<String, Object> build({required Map runtimeMasterFrameV2}) {
    return <String, Object>{
      'content_runtime_finalizer_v2': <String, Object>{
        'runtime_master_frame_v2': runtimeMasterFrameV2,
      },
    };
  }
}
