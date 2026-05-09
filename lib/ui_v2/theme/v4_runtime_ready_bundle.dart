import 'package:flutter/material.dart';

class V4RuntimeReadyBundle {
  const V4RuntimeReadyBundle();

  static Map<String, Object?> export({
    required bool isV4Active,
    required Map<String, Object?>? activationBundle,
    required Map<String, Object?>? colorDelta,
    required Map<String, Object?> structMap,
    required ThemeData? theme,
  }) {
    return {
      "is_active": isV4Active,
      "activation_bundle": activationBundle != null,
      "color_delta": colorDelta != null,
      "struct_keys": structMap.keys.toList(),
      "theme_present": theme != null,
    };
  }
}
