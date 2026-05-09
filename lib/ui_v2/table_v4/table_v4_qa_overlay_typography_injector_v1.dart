import 'package:flutter/widgets.dart';

class TableV4QAOverlayTypographyInjectorV1 {
  const TableV4QAOverlayTypographyInjectorV1();

  static Map<String, Object> build() {
    return <String, Object>{
      'min_font_size': 11.0,
      'scale_factor': 1.0,
      'alpha_min': 200,
      'alpha_max': 255,
      'weight_delta': 100,
    };
  }

  static TextStyle styleFromQAOverlayMap(
    Map<String, Object?> injectorMap,
    TextStyle baseStyle,
  ) {
    final double minFontSize = _toDouble(injectorMap['min_font_size'], 11.0);
    final double scaleFactor = _toDouble(injectorMap['scale_factor'], 1.0);
    final int alphaMin = _toInt(injectorMap['alpha_min'], 200);
    final int alphaMax = _toInt(injectorMap['alpha_max'], 255);
    final int weightDelta = _toInt(injectorMap['weight_delta'], 100);
    final double scaledSize = (baseStyle.fontSize ?? 11.0) * scaleFactor;
    final double fontSize = scaledSize < minFontSize ? minFontSize : scaledSize;
    final Color? color = baseStyle.color;
    final int alpha = color == null
        ? alphaMax
        : ((color.toARGB32() >> 24) & 0xff).clamp(alphaMin, alphaMax);
    final FontWeight adjustedWeight = _lerpWeight(
      baseStyle.fontWeight,
      weightDelta,
    );
    final Color finalColor = (color ?? const Color(0xffffffff)).withAlpha(
      alpha,
    );
    return baseStyle.copyWith(
      fontSize: fontSize,
      color: finalColor,
      fontWeight: adjustedWeight,
    );
  }

  static double _toDouble(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static int _toInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static FontWeight _lerpWeight(FontWeight? base, int delta) {
    final FontWeight target = delta >= 0 ? FontWeight.w900 : FontWeight.w100;
    return FontWeight.lerp(base ?? FontWeight.normal, target, 1.0) ??
        (base ?? FontWeight.normal);
  }
}
