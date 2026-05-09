class ContentRuntimeStageV2 {
  static Map<String, Object> build({required Map runtimeFrameV2}) {
    return <String, Object>{
      'content_runtime_stage_v2': <String, Object>{
        'runtime_frame_v2': runtimeFrameV2,
      },
    };
  }
}
