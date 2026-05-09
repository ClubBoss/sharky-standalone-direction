import 'package:flutter/material.dart';

class V4RoutingFusionInjectionV4 {
  const V4RoutingFusionInjectionV4();

  static ThemeData inject({
    required ThemeData base,
    required Map<String, Object?>? fusionSynthesis,
  }) {
    if (fusionSynthesis == null || fusionSynthesis["present"] == false) {
      return base;
    }

    ThemeData out = base;

    final colors =
        fusionSynthesis["fusion_synthesis_colors"] as Map<String, Object?>?;
    final primary = colors?["primary"];
    final secondary = colors?["secondary"];
    if (primary is Color && secondary is Color) {
      out = out.copyWith(
        colorScheme: out.colorScheme.copyWith(
          primary: primary,
          secondary: secondary,
        ),
        primaryColor: primary,
      );
    }

    final typo =
        fusionSynthesis["fusion_synthesis_typography"] as Map<String, Object?>?;
    final bodyScale = typo?["body"];
    final titleScale = typo?["title"];
    if (bodyScale is num || titleScale is num) {
      final t = out.textTheme;
      out = out.copyWith(
        textTheme: t.copyWith(
          bodyMedium: bodyScale is num
              ? t.bodyMedium?.copyWith(
                  fontSize: (t.bodyMedium?.fontSize ?? 14) * bodyScale,
                )
              : t.bodyMedium,
          titleMedium: titleScale is num
              ? t.titleMedium?.copyWith(
                  fontSize: (t.titleMedium?.fontSize ?? 16) * titleScale,
                )
              : t.titleMedium,
        ),
      );
    }

    return out;
  }
}
