class TableV4MicroSynergyV1 {
  static Map<String, Object> build({
    Map<String, Object?>? emotionMap,
    Map<String, Object?>? textHintMap,
    Map<String, Object?>? spacingPolishMap,
    Map<String, Object?>? microBrushMap,
    Map<String, Object?>? typographyMap,
  }) {
    final double moodStrength = _clamp(
      (emotionMap?['intensity'] as num? ?? 0) * 0.15,
      0.0,
      1.0,
    );
    final Map<String, Object?>? hintPayload =
        textHintMap?['text_hint_refinement_v1'] as Map<String, Object?>?;
    final bool hintReady = (hintPayload?['ready'] as bool?) == true;
    final double hintStrength = hintReady ? 1.0 : 0.0;
    final Map<String, Object?>? spacingPayload =
        spacingPolishMap?['spacing_polish_v1'] as Map<String, Object?>?;
    final double baselineShift =
        (spacingPayload?['baseline_shift'] as num?)?.toDouble() ?? 0.0;
    final double spacingStrength = baselineShift.abs() * 0.1;
    final Map<String, Object?>? microBrushPayload =
        microBrushMap?['micro_brush_v1'] as Map<String, Object?>?;
    final double accentBias =
        (microBrushPayload?['accent_bias'] as num?)?.toDouble() ?? 0.0;
    final double brushStrength = accentBias * 0.5;
    final double typographyScale =
        (typographyMap?['scale'] as num?)?.toDouble() ?? 1.0;
    return <String, Object>{
      'micro_synergy_v1': <String, Object>{
        'mood_strength': moodStrength,
        'hint_strength': hintStrength,
        'spacing_strength': spacingStrength,
        'brush_strength': brushStrength,
        'typography_strength': typographyScale,
        'ready': true,
      },
    };
  }

  static double _clamp(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }
}
