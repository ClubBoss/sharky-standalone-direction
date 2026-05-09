class StabilityQACrestV2 {
  const StabilityQACrestV2();

  static Map<String, Object> build({required Map<String, Object> peakV2}) {
    return {
      "stability_qa_crest_v2": {"peak_v2": peakV2},
    };
  }
}
