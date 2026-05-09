class TableV4SpacingPolishV1 {
  static Map<String, Object> build({
    Map<String, Object?>? typographyMap,
    Map<String, Object?>? emotionMap,
    Map<String, Object?>? textHintMap,
  }) {
    final double moodBias = _extractIntensity(emotionMap);
    final double hintBias = _extractStatusHintLength(textHintMap);
    return <String, Object>{
      'spacing_polish_v1': <String, Object>{
        'padding_scale': 1.08,
        'baseline_shift': -0.5,
        'mood_bias': moodBias,
        'hint_bias': hintBias,
        'ready': true,
      },
    };
  }

  static double _extractIntensity(Map<String, Object?>? emotionMap) {
    final Object? raw = emotionMap?['intensity'];
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final double? value = double.tryParse(raw);
      if (value != null) return value;
    }
    return 0.0;
  }

  static double _extractStatusHintLength(Map<String, Object?>? textHintMap) {
    final Map<String, Object?>? payload =
        textHintMap?['text_hint_refinement_v1'] as Map<String, Object?>?;
    final String hint = (payload?['status_hint'] as String? ?? '');
    return _ascii(hint).length.toDouble();
  }

  static String _ascii(String value) => String.fromCharCodes(
    value.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
