import 'package:flutter/widgets.dart';

import '../theme/v4_token_registry.dart';

class TypographyV4InjectorV1 {
  const TypographyV4InjectorV1({
    required this.tokensMap,
    required this.baseStyle,
  });

  final Map<String, Object?> tokensMap;
  final TextStyle baseStyle;

  static const V4TokenRegistry _registry = V4TokenRegistry();

  TextStyle apply() {
    if (_isInactive) {
      return baseStyle;
    }
    final String role = _roleName;
    final double scale = _fontScale(role);
    final int weightDelta = _fontWeightDelta(role);
    final double letterDelta = _registry.v4LetterSpacingDelta;
    final double? scaledFontSize = _applyFontSize(
      baseStyle.fontSize,
      scale,
      baseStyle.fontSize,
    );
    final double letterSpacing = _clampLetterSpacing(
      (baseStyle.letterSpacing ?? 0.0) + letterDelta,
    );
    final FontWeight weight = _lerpWeight(baseStyle.fontWeight, weightDelta);
    return baseStyle.copyWith(
      fontSize: scaledFontSize,
      letterSpacing: letterSpacing,
      fontWeight: weight,
    );
  }

  Map<String, Object> asReadOnlyMap() {
    final TextStyle style = apply();
    return <String, Object>{
      'typography_v4_injector_v1': <String, Object>{
        'role': _roleName,
        'v4_active': !_isInactive,
        'style': <String, Object>{
          'font_size': style.fontSize ?? 0,
          'letter_spacing': style.letterSpacing ?? 0,
          'font_weight': _fontWeightValue(style.fontWeight),
        },
      },
      'readiness': !_isInactive,
    };
  }

  bool get _isInactive => tokensMap['v4_active'] != true;

  String get _roleName {
    final Object? roleValue =
        tokensMap['typography_role'] ??
        tokensMap['role'] ??
        tokensMap['typography'];
    if (roleValue is String) {
      final String normalized = roleValue.toLowerCase();
      if (normalized.contains('title') || normalized.contains('headline')) {
        return 'title';
      }
    }
    return 'body';
  }

  double _fontScale(String role) =>
      role == 'title' ? _registry.v4FontScaleTitle : _registry.v4FontScaleBody;

  int _fontWeightDelta(String role) => role == 'title'
      ? _registry.v4FontWeightTitle
      : _registry.v4FontWeightBody;

  double? _applyFontSize(double? baseSize, double scale, double? fallback) {
    if (baseSize == null) {
      return null;
    }
    final double candidate = baseSize * scale;
    if (candidate > 0) {
      return candidate;
    }
    if (baseSize > 0) {
      return baseSize;
    }
    return fallback;
  }

  double _clampLetterSpacing(double value) => value.clamp(-1.0, 2.0).toDouble();

  FontWeight _lerpWeight(FontWeight? base, int delta) {
    if (delta == 0) {
      return base ?? FontWeight.normal;
    }
    final FontWeight target = delta > 0 ? FontWeight.w900 : FontWeight.w100;
    final double ratio = (delta.abs() / 3.0).clamp(0.0, 1.0);
    return FontWeight.lerp(base ?? FontWeight.normal, target, ratio) ??
        (base ?? FontWeight.normal);
  }

  int _fontWeightValue(FontWeight? weight) {
    final FontWeight resolved = weight ?? FontWeight.normal;
    if (resolved == FontWeight.w100) return 100;
    if (resolved == FontWeight.w200) return 200;
    if (resolved == FontWeight.w300) return 300;
    if (resolved == FontWeight.w400) return 400;
    if (resolved == FontWeight.w500) return 500;
    if (resolved == FontWeight.w600) return 600;
    if (resolved == FontWeight.w700) return 700;
    if (resolved == FontWeight.w800) return 800;
    if (resolved == FontWeight.w900) return 900;
    return 400;
  }

  static TextStyle styleFromReadOnlyMap(
    Map<String, Object?> injectorMap,
    TextStyle baseStyle,
  ) {
    final bool ready = injectorMap['readiness'] == true;
    final Map<String, Object?>? body =
        injectorMap['typography_v4_injector_v1'] as Map<String, Object?>?;
    if (!ready || body == null || body['v4_active'] != true) {
      return baseStyle;
    }
    final Map<String, Object?>? styleData =
        body['style'] as Map<String, Object?>?;
    if (styleData == null) {
      return baseStyle;
    }
    final double? fontSize = _toDouble(styleData['font_size']);
    final double? letterSpacing = _toDouble(styleData['letter_spacing']);
    final int? fontWeightValue = _toInt(styleData['font_weight']);
    final FontWeight fontWeight = fontWeightValue != null
        ? _fontWeightFromValue(fontWeightValue)
        : baseStyle.fontWeight ?? FontWeight.normal;
    final Color? safeColor = _safeTextColor(baseStyle.color);
    return baseStyle.copyWith(
      color: safeColor,
      fontSize: fontSize ?? baseStyle.fontSize,
      letterSpacing: letterSpacing ?? baseStyle.letterSpacing,
      fontWeight: fontWeight,
    );
  }

  static double? _toDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  static int? _toInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static FontWeight _fontWeightFromValue(int value) {
    final int normalized = ((value + 50) ~/ 100 * 100).clamp(100, 900);
    switch (normalized) {
      case 100:
        return FontWeight.w100;
      case 200:
        return FontWeight.w200;
      case 300:
        return FontWeight.w300;
      case 400:
        return FontWeight.w400;
      case 500:
        return FontWeight.w500;
      case 600:
        return FontWeight.w600;
      case 700:
        return FontWeight.w700;
      case 800:
        return FontWeight.w800;
      case 900:
        return FontWeight.w900;
    }
    return FontWeight.normal;
  }

  static Color? _safeTextColor(Color? color) {
    if (color == null) {
      return null;
    }
    final int alpha = (color.toARGB32() >> 24) & 0xff;
    final int clampedAlpha = alpha.clamp(96, 255);
    return color.withAlpha(clampedAlpha);
  }
}
