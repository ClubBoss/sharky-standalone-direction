class StabilityQALayerV1 {
  const StabilityQALayerV1();

  static Map<String, Object> build({
    required Map<String, Object> stabilityQAFrameV1,
  }) {
    return {
      "stability_qa_layer_v1": {"stability_qa_frame_v1": stabilityQAFrameV1},
    };
  }
}
