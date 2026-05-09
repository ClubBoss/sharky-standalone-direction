import 'package:flutter/material.dart';

/// Deterministic layer that paints a rounded-rect glow for Table V4.
class HighlightGlowV4PainterV1 extends CustomPainter {
  const HighlightGlowV4PainterV1({required this.highlightSpec});

  final Map<String, Object> highlightSpec;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect glowRect = _readRect(highlightSpec['rect']);
    if (glowRect.isEmpty) {
      return;
    }
    final double baseRadius = _readDouble(highlightSpec, 'radius', 0.0);
    final double clampedRadius = _microClampRadius(baseRadius);
    final double cornerRadius = clampedRadius < 0 ? 0 : clampedRadius;
    final double sigma = _clamp(clampedRadius * 0.7, 1.0, 14.0);
    final double alpha = _clamp(
      _readDouble(highlightSpec, 'alpha', 1.0),
      0.0,
      1.0,
    );
    final Color baseColor = _readColor(highlightSpec['color']);
    int alphaInt = (alpha * 255).round();
    if (alphaInt < 0) {
      alphaInt = 0;
    } else if (alphaInt > 255) {
      alphaInt = 255;
    }
    final Color color = baseColor.withAlpha(alphaInt);
    final int colorAlpha = color.toARGB32() >> 24;
    if (colorAlpha == 0) {
      return;
    }

    final Paint glowPaint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    final RRect glowRRect = RRect.fromRectAndRadius(
      glowRect,
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(glowRRect, glowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  static Rect _readRect(Object? source) {
    if (source is Map<Object?, Object?>) {
      final double x = _toDouble(source['x'], 0.0);
      final double y = _toDouble(source['y'], 0.0);
      final double width = _toDouble(source['w'], 0.0);
      final double height = _toDouble(source['h'], 0.0);
      return Rect.fromLTWH(
        x,
        y,
        width < 0 ? 0 : width,
        height < 0 ? 0 : height,
      );
    }
    return Rect.zero;
  }

  static double _readDouble(
    Map<String, Object> source,
    String key,
    double fallback,
  ) => source.containsKey(key) ? _toDouble(source[key], fallback) : fallback;

  static double _toDouble(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    return fallback;
  }

  static Color _readColor(Object? input) {
    if (input is Color) {
      return input;
    }
    if (input is int) {
      return Color(input);
    }
    return const Color(0xFF000000);
  }

  static double _clamp(double value, double min, double max) {
    if (value < min) {
      return min;
    }
    if (value > max) {
      return max;
    }
    return value;
  }

  static double _microClampRadius(double value) => value.clamp(-2.0, 28.0);
}
