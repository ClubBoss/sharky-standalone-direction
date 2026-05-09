class StabilityQAEnvelopeV1 {
  const StabilityQAEnvelopeV1();

  static Map<String, Object> build({
    required Map<String, Object> stabilityQALayerV1,
  }) {
    return {
      "stability_qa_envelope_v1": {"stability_qa_layer_v1": stabilityQALayerV1},
    };
  }
}
