import 'package:flutter/material.dart';

class V4RoutingThemeInjectionV1 {
  const V4RoutingThemeInjectionV1();

  static ThemeData inject({
    required ThemeData base,
    required Map<String, Object?>? synthesis,
  }) {
    if (synthesis == null || synthesis["present"] == false) {
      return base;
    }

    final colors = synthesis["synthesis_colors"] as Map<String, Object?>?;
    if (colors == null) return base;

    final primary = colors["primary"];
    final secondary = colors["secondary"];

    if (primary is Color && secondary is Color) {
      return base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: primary,
          secondary: secondary,
        ),
        primaryColor: primary,
      );
    }

    return base;
  }
}
