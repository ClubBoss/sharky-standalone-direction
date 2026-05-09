import 'package:flutter/material.dart';

class V4RoutingThemeInjectionV2 {
  const V4RoutingThemeInjectionV2();

  static ThemeData inject({
    required ThemeData base,
    required Map<String, Object?>? synthesis,
  }) {
    if (synthesis == null || synthesis["present"] == false) {
      return base;
    }

    final colors = synthesis["synthesis_colors"] as Map<String, Object?>?;
    final primary = colors?["primary"];
    final secondary = colors?["secondary"];

    final typo = synthesis["synthesis_typography"] as Map<String, Object?>?;
    final bodyScale = typo?["body"];
    final titleScale = typo?["title"];

    ThemeData out = base;

    if (primary is Color && secondary is Color) {
      out = out.copyWith(
        colorScheme: out.colorScheme.copyWith(
          primary: primary,
          secondary: secondary,
        ),
        primaryColor: primary,
      );
    }

    if (bodyScale is num || titleScale is num) {
      final text = out.textTheme;
      out = out.copyWith(
        textTheme: text.copyWith(
          bodyMedium: bodyScale is num
              ? text.bodyMedium?.copyWith(
                  fontSize: (text.bodyMedium?.fontSize ?? 14) * bodyScale,
                )
              : text.bodyMedium,
          titleMedium: titleScale is num
              ? text.titleMedium?.copyWith(
                  fontSize: (text.titleMedium?.fontSize ?? 16) * titleScale,
                )
              : text.titleMedium,
        ),
      );
    }

    return out;
  }
}
