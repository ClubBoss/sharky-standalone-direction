class TableV4MicroBrushV1 {
  static Map<String, Object> build({
    Map<String, Object?>? spacingPolishMap,
    Map<String, Object?>? emotionMap,
    Map<String, Object?>? typographyMap,
  }) {
    final double accentBias = _extractAccentBias(emotionMap);
    final double glowBias = _extractGlowBias(spacingPolishMap);
    final double fontStretchBias = _extractFontStretchBias(typographyMap);
    return <String, Object>{
      'micro_brush_v1': <String, Object>{
        'accent_bias': accentBias,
        'glow_bias': glowBias,
        'font_stretch_bias': fontStretchBias,
        'ready': true,
      },
    };
  }

  static double _extractAccentBias(Map<String, Object?>? emotionMap) {
    final Object? intensity = emotionMap?['intensity'];
    if (intensity is num) return intensity.toDouble() * 0.1;
    if (intensity is String) {
      final double? parsed = double.tryParse(intensity);
      if (parsed != null) return parsed * 0.1;
    }
    return 0.0;
  }

  static double _extractGlowBias(Map<String, Object?>? spacingPolishMap) {
    final Map<String, Object?> baselineShift =
        spacingPolishMap?['spacing_polish_v1'] as Map<String, Object?>? ??
        <String, Object?>{};
    final double value =
        (baselineShift['baseline_shift'] as num?)?.toDouble() ?? 0.0;
    return value.clamp(0.0, double.infinity);
  }

  static double _extractFontStretchBias(Map<String, Object?>? typographyMap) {
    final Object? scale = typographyMap?['scale'];
    if (scale is num) return scale.toDouble();
    if (scale is String) {
      final double? parsed = double.tryParse(scale);
      if (parsed != null) return parsed;
    }
    return 1.0;
  }
}
