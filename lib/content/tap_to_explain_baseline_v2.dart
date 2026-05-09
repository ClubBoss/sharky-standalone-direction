class TapToExplainBaselineV2 {
  final Map<String, Object> data;

  TapToExplainBaselineV2(this.data);

  Map<String, Object> asMap() => data;

  static Map<String, Object> build({required List<String> terms}) {
    return <String, Object>{
      'tap_to_explain_baseline_v2': <String, Object>{
        'terms': terms,
        'explanations': <String, String>{
          for (final t in terms) t: 'placeholder_explanation_for_$t',
        },
        'cross_pack_presence': <String, String>{
          for (final t in terms) t: 'placeholder_cross_pack_presence_$t',
        },
        'metadata': 'placeholder_tap_to_explain_baseline_v2',
      },
    };
  }
}
