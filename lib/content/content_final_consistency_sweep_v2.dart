class ContentFinalConsistencySweepV2 {
  static Map<String, Object> build({
    required Map keyConsistencyV2,
    required Map valueConsistencyV2,
    required Map structuralConsistencyV2,
  }) {
    return <String, Object>{
      'content_final_consistency_sweep_v2': <String, Object>{
        'key_consistency': keyConsistencyV2,
        'value_consistency': valueConsistencyV2,
        'structural_consistency': structuralConsistencyV2,
      },
    };
  }
}
