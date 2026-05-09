class TableV4CohesionPassV1 {
  const TableV4CohesionPassV1();

  Map<String, Object> analyze({
    required Map<String, Object?> typographyMap,
    required Map<String, Object?> spacingMap,
    required Map<String, Object?> glowSpecMap,
    required Map<String, Object?> cardSpecMap,
    required Map<String, Object?> animationSpecMap,
  }) {
    final List<String> issues = <String>[];
    final bool typographyOk = _checkTypography(typographyMap, issues);
    final bool spacingOk = _checkSpacing(spacingMap, issues);
    final bool glowOk = _checkGlow(glowSpecMap, issues);
    final bool cardOk = _checkCard(cardSpecMap, issues);
    final bool animationOk = _checkAnimation(animationSpecMap, issues);
    issues.sort();
    return <String, Object>{
      'visual_cohesion_v1': <String, Object>{
        'typography_ok': typographyOk,
        'spacing_ok': spacingOk,
        'glow_ok': glowOk,
        'card_ok': cardOk,
        'animation_ok': animationOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static bool _checkTypography(
    Map<String, Object?> typography,
    List<String> issues,
  ) {
    final Object? body =
        typography['typography_v4_injector_v1'] ?? typography['typography'];
    if (body is Map<String, Object?>) {
      final Map<String, Object?>? style =
          body['style'] as Map<String, Object?>? ??
          typography['style'] as Map<String, Object?>?;
      final int alpha = _extractAlpha(style?['color']);
      if (alpha < 96 || alpha > 255) {
        issues.add('typography_alpha_out_of_range');
        return false;
      }
      return true;
    }
    issues.add('typography_missing_style');
    return false;
  }

  static bool _checkSpacing(Map<String, Object?> spacing, List<String> issues) {
    for (final Object? value in spacing.values) {
      final double offset = _toDouble(value);
      if (offset < -24.0 || offset > 24.0) {
        issues.add('spacing_offset_out_of_range');
        return false;
      }
    }
    return true;
  }

  static bool _checkGlow(Map<String, Object?> glow, List<String> issues) {
    final double radius = _toDouble(glow['radius']);
    final double sigma = _toDouble(glow['sigma']) != 0.0
        ? _toDouble(glow['sigma'])
        : _toDouble(glow['blur']);
    var ok = true;
    if (radius < 0.0 || radius > 24.0) {
      issues.add('glow_radius_out_of_range');
      ok = false;
    }
    if (sigma < 0.0 || sigma > 14.0) {
      issues.add('glow_sigma_out_of_range');
      ok = false;
    }
    return ok;
  }

  static bool _checkCard(Map<String, Object?> card, List<String> issues) {
    final double dx = _toDouble(card['shadow_dx']);
    final double dy = _toDouble(card['shadow_dy']);
    if (dx < -12.0 || dx > 12.0 || dy < -12.0 || dy > 12.0) {
      issues.add('card_shadow_offset_out_of_range');
      return false;
    }
    return true;
  }

  static bool _checkAnimation(
    Map<String, Object?> animation,
    List<String> issues,
  ) {
    final double scale = _toDouble(animation['scale']);
    final double opacity = _toDouble(animation['opacity']);
    final double duration = _toDouble(animation['duration_ms']);
    var ok = true;
    if (scale < 0.85 || scale > 1.15) {
      issues.add('animation_scale_out_of_range');
      ok = false;
    }
    if (opacity < 0.0 || opacity > 1.0) {
      issues.add('animation_opacity_out_of_range');
      ok = false;
    }
    if (duration < 0.0 || duration > 3000.0) {
      issues.add('animation_duration_out_of_range');
      ok = false;
    }
    return ok;
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static int _extractAlpha(Object? input) {
    if (input is int) {
      return (input >> 24) & 0xff;
    }
    return 0;
  }
}
