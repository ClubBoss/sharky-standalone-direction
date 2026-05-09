class TableV4ContrastAuditV1 {
  const TableV4ContrastAuditV1();

  Map<String, Object> analyze({
    required Map<String, Object?> typographyMap,
    required Map<String, Object?> spacingMap,
    required Map<String, Object?> glowSpecMap,
    required Map<String, Object?> cardSpecMap,
  }) {
    final List<String> issues = <String>[];
    final bool typographyOk = _checkTypography(typographyMap, issues);
    final bool spacingOk = _checkSpacing(spacingMap, issues);
    final bool glowOk = _checkGlow(glowSpecMap, issues);
    final bool cardOk = _checkCard(cardSpecMap, issues);
    issues.sort();
    return <String, Object>{
      'v4_contrast_audit_v1': <String, Object>{
        'typography_ok': typographyOk,
        'spacing_ok': spacingOk,
        'glow_ok': glowOk,
        'card_ok': cardOk,
        'issues': issues,
        'ready': false,
      },
    };
  }

  static bool _checkTypography(
    Map<String, Object?> typography,
    List<String> issues,
  ) {
    final Object? injector =
        typography['typography_v4_injector_v1'] ?? typography['typography'];
    if (injector is Map<String, Object?>) {
      final Object? style =
          injector['style'] ?? typography['style'] ?? typography['color'];
      if (style is Map<String, Object?>) {
        final Object? color = style['color'];
        final int alpha = _extractAlpha(color);
        if (alpha < 96 || alpha > 255) {
          issues.add('typography_alpha_out_of_range');
          return false;
        }
        return true;
      }
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

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return 0.0;
  }

  static int _extractAlpha(Object? color) {
    if (color is int) {
      return ((color >> 24) & 0xff);
    }
    return 0;
  }
}
