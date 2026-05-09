class ContentRuntimeLayerFrameV2 {
  static Map<String, Object> build({required Map runtimeStageV2}) {
    return <String, Object>{
      'content_runtime_layer_frame_v2': <String, Object>{
        'runtime_stage_v2': runtimeStageV2,
      },
    };
  }
}
