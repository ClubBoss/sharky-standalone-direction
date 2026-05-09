import 'package:flutter/material.dart';

class V4ReadinessGate {
  const V4ReadinessGate();

  static Map<String, Object?> check({
    required Map<String, Object?>? activationBundle,
    required Map<String, Object?>? colorDelta,
    required Map<String, Object?> structMap,
    required ThemeData? theme,
  }) {
    return {
      "activation_bundle": activationBundle != null,
      "color_delta": colorDelta != null,
      "struct_colors": structMap["colors"] != null,
      "struct_typography": structMap["typography"] != null,
      "struct_spacing": structMap["spacing"] != null,
      "theme_present": theme != null,
    };
  }
}
