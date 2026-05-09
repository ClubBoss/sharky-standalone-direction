class ContentRuntimeMasterFrameV2 {
  static Map<String, Object> build({required Map runtimeLayerFrameV2}) {
    return <String, Object>{
      'content_runtime_master_frame_v2': <String, Object>{
        'runtime_layer_frame_v2': runtimeLayerFrameV2,
      },
    };
  }
}
