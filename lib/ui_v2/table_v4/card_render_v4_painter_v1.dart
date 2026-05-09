import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'typography_v4_injector_v1.dart';

/// Deterministic canvas painter for V4 card rendering (Phi-44.1).
class CardRenderV4PainterV1 extends CustomPainter {
  const CardRenderV4PainterV1({
    required this.cardGeometryMap,
    required this.cardShapeMap,
    required this.cardParamsMap,
    this.v4SpacingMap = const <String, Object?>{},
    this.typographyInjectorMap = const <String, Object?>{},
  });

  final Map<String, Object> cardGeometryMap;
  final Map<String, Object> cardShapeMap;
  final Map<String, Object> cardParamsMap;
  final Map<String, Object?> v4SpacingMap;
  final Map<String, Object?> typographyInjectorMap;

  @override
  void paint(Canvas canvas, Size size) {
    final Size targetSize = _readSize(cardGeometryMap);
    final double width = size.width == 0.0 ? targetSize.width : size.width;
    final double height = size.height == 0.0 ? targetSize.height : size.height;
    final double cornerRadius = _readDouble(
      cardGeometryMap,
      'corner_radius',
      math.min(width, height) * 0.08,
    );
    final double padding = _readDouble(
      cardGeometryMap,
      'rank_padding',
      width * 0.08,
    );

    final Color backgroundColor = _readColor(
      cardParamsMap['background_color'],
      Colors.white,
    );
    final Color borderColorRaw = _readColor(
      cardParamsMap['border_color'],
      Colors.black12,
    );
    final Color borderColor = _clampBorderAlpha(borderColorRaw);
    final Color suitColor = _readColor(
      cardParamsMap['suit_color'],
      Colors.black87,
    );
    final Color rankColor = _readColor(
      cardParamsMap['rank_color'],
      Colors.black87,
    );

    final Rect cardRect = Offset.zero & Size(width, height);
    final double dx = _clampOffset(_v4Spacing('card_dx'));
    final double dy = _clampOffset(_v4Spacing('card_dy'));
    final RRect cardRRect = RRect.fromRectAndRadius(
      cardRect,
      Radius.circular(cornerRadius),
    );
    final Offset cardOffset = Offset(dx, dy);
    final Color rawShadowColor = _readColor(
      cardParamsMap['shadow_color'],
      Colors.transparent,
    );
    final Color shadowColor = _clampShadowAlpha(rawShadowColor);
    final double shadowDx = _readDouble(cardParamsMap, 'shadow_dx', 0.0);
    final double shadowDy = _readDouble(cardParamsMap, 'shadow_dy', 2.0);

    canvas.save();
    canvas.translate(cardOffset.dx, cardOffset.dy);
    if (shadowColor.a > 0) {
      final Paint shadowPaint = Paint()
        ..color = shadowColor
        ..isAntiAlias = true;
      canvas.save();
      canvas.translate(shadowDx, shadowDy);
      canvas.drawRRect(cardRRect, shadowPaint);
      canvas.restore();
    }

    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..isAntiAlias = true;
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _readDouble(cardGeometryMap, 'border_width', 1.0)
      ..isAntiAlias = true;

    canvas.drawRRect(cardRRect, backgroundPaint);
    if (borderPaint.strokeWidth > 0) {
      canvas.drawRRect(cardRRect, borderPaint);
    }

    final Path? suitPath = _resolveSuitPath(width, height, padding);
    if (suitPath != null) {
      final Paint suitPaint = Paint()
        ..color = suitColor
        ..isAntiAlias = true;
      canvas.drawPath(suitPath, suitPaint);
    }

    final String rankLabel =
        (cardParamsMap['rank_label'] as String?) ??
        (cardParamsMap['rank'] as String?) ??
        'A';
    final double rankFontSize = _readDouble(
      cardParamsMap,
      'rank_font_size',
      width * 0.22,
    );

    final TextStyle baseRankStyle = TextStyle(
      color: rankColor,
      fontWeight: FontWeight.w700,
      fontSize: rankFontSize,
      letterSpacing: _readDouble(cardParamsMap, 'rank_letter_spacing', 0.0),
    );
    final TextStyle renderedRankStyle =
        TypographyV4InjectorV1.styleFromReadOnlyMap(
          typographyInjectorMap,
          baseRankStyle,
        );
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: rankLabel, style: renderedRankStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: width - (padding * 2));

    final Offset rankOffset = Offset(padding, padding);
    textPainter.paint(canvas, rankOffset);

    // Optional mirrored rank in bottom right for readability.
    if (_readBool(cardGeometryMap, 'mirror_rank', true)) {
      canvas.save();
      canvas.translate(width - padding, height - padding);
      canvas.rotate(math.pi);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  Size _readSize(Map<String, Object> geometry) {
    final Object? sizeData = geometry['size'];
    if (sizeData is Map) {
      final Map<Object?, Object?> sizeMap = sizeData;
      final double width = _toDouble(sizeMap['width'], 100.0);
      final double height = _toDouble(sizeMap['height'], 140.0);
      return Size(width, height);
    }
    if (sizeData is List && sizeData.length >= 2) {
      final double width = _toDouble(sizeData[0], 100.0);
      final double height = _toDouble(sizeData[1], 140.0);
      return Size(width, height);
    }
    final double width = _toDouble(geometry['width'], 100.0);
    final double height = _toDouble(geometry['height'], 140.0);
    return Size(width, height);
  }

  double _readDouble(Map<String, Object> source, String key, double fallback) =>
      source.containsKey(key) ? _toDouble(source[key], fallback) : fallback;

  bool _readBool(Map<String, Object> source, String key, bool fallback) {
    if (!source.containsKey(key)) return fallback;
    final Object? value = source[key];
    if (value is bool) return value;
    if (value is String) {
      final String normalized = value.toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }

  Color _readColor(Object? input, Color fallback) {
    if (input is Color) return input;
    if (input is int) return Color(input);
    if (input is String) {
      final String value = input.trim();
      if (value.startsWith('#')) {
        final String hex = value.substring(1);
        if (hex.length == 6 || hex.length == 8) {
          final int parsed = int.parse(
            hex.length == 6 ? 'FF$hex' : hex,
            radix: 16,
          );
          return Color(parsed);
        }
      }
      final Color? named = _namedColor(value);
      if (named != null) return named;
    }
    return fallback;
  }

  Color? _namedColor(String name) {
    switch (name.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return null;
    }
  }

  double _toDouble(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final double? parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  double _v4Spacing(String key) => _toDouble(v4SpacingMap[key], 0.0);

  double _clampOffset(double value) => value.clamp(-12.0, 12.0);

  Color _clampBorderAlpha(Color color) {
    final int alpha = (color.a * 255).round() & 0xff;
    final int clampedAlpha = alpha.clamp(64, 255);
    return color.withAlpha(clampedAlpha);
  }

  Color _clampShadowAlpha(Color color) {
    final int alpha = (color.a * 255).round() & 0xff;
    final int clampedAlpha = alpha.clamp(32, 200);
    return color.withAlpha(clampedAlpha);
  }

  Path? _resolveSuitPath(double width, double height, double padding) {
    final Object? pathSource =
        cardShapeMap['suit_path'] ??
        (cardShapeMap['paths'] is List &&
                (cardShapeMap['paths'] as List).isNotEmpty
            ? (cardShapeMap['paths'] as List).first
            : null);
    if (pathSource is! String || pathSource.isEmpty) {
      return null;
    }

    final Path path = _parsePathData(pathSource);
    if (path.computeMetrics().isEmpty) {
      return null;
    }

    const double suitScale = 0.55;
    final Float64List scaleMatrix = Float64List.fromList(<double>[
      width * suitScale,
      0,
      0,
      0,
      0,
      height * suitScale,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      1,
    ]);
    final Path scaledPath = Path()
      ..addPath(path, Offset.zero, matrix4: scaleMatrix);
    final Rect bounds = scaledPath.getBounds();
    if (bounds.isEmpty) {
      return null;
    }
    final Rect contentRect = Rect.fromLTWH(
      padding,
      padding,
      math.max(0.0, width - (padding * 2)),
      math.max(0.0, height - (padding * 2)),
    );
    final Offset targetCenter = contentRect.center;
    final Offset translation = targetCenter - bounds.center;
    return scaledPath.shift(translation);
  }

  Path _parsePathData(String data) {
    final Path path = Path();
    Offset current = Offset.zero;
    Offset subPathStart = Offset.zero;
    String command = '';
    final String normalized = data.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return path;
    }
    final RegExp tokenExp = RegExp(r'([AaCcHhLlMmQqTtVvZz])');
    final List<String> tokens = normalized
        .split(tokenExp)
        .where((token) => token.isNotEmpty)
        .toList();

    for (int i = 0; i < tokens.length; i++) {
      final String token = tokens[i];
      if (tokenExp.hasMatch(token)) {
        command = token;
        continue;
      }
      if (command.isEmpty) {
        continue;
      }
      final List<double> values = token
          .split(RegExp(r'[ ,]'))
          .where((value) => value.isNotEmpty)
          .map((value) => double.tryParse(value) ?? 0.0)
          .toList();
      switch (command) {
        case 'M':
          for (int j = 0; j + 1 < values.length; j += 2) {
            current = Offset(values[j], values[j + 1]);
            path.moveTo(current.dx, current.dy);
            subPathStart = current;
          }
          break;
        case 'm':
          for (int j = 0; j + 1 < values.length; j += 2) {
            current = Offset(
              current.dx + values[j],
              current.dy + values[j + 1],
            );
            path.moveTo(current.dx, current.dy);
            subPathStart = current;
          }
          break;
        case 'L':
          for (int j = 0; j + 1 < values.length; j += 2) {
            current = Offset(values[j], values[j + 1]);
            path.lineTo(current.dx, current.dy);
          }
          break;
        case 'l':
          for (int j = 0; j + 1 < values.length; j += 2) {
            current = Offset(
              current.dx + values[j],
              current.dy + values[j + 1],
            );
            path.lineTo(current.dx, current.dy);
          }
          break;
        case 'H':
          for (final double value in values) {
            current = Offset(value, current.dy);
            path.lineTo(current.dx, current.dy);
          }
          break;
        case 'h':
          for (final double value in values) {
            current = Offset(current.dx + value, current.dy);
            path.lineTo(current.dx, current.dy);
          }
          break;
        case 'V':
          for (final double value in values) {
            current = Offset(current.dx, value);
            path.lineTo(current.dx, current.dy);
          }
          break;
        case 'v':
          for (final double value in values) {
            current = Offset(current.dx, current.dy + value);
            path.lineTo(current.dx, current.dy);
          }
          break;
        case 'C':
          for (int j = 0; j + 5 < values.length; j += 6) {
            final Offset control1 = Offset(values[j], values[j + 1]);
            final Offset control2 = Offset(values[j + 2], values[j + 3]);
            final Offset destination = Offset(values[j + 4], values[j + 5]);
            path.cubicTo(
              control1.dx,
              control1.dy,
              control2.dx,
              control2.dy,
              destination.dx,
              destination.dy,
            );
            current = destination;
          }
          break;
        case 'c':
          for (int j = 0; j + 5 < values.length; j += 6) {
            final Offset control1 = Offset(
              current.dx + values[j],
              current.dy + values[j + 1],
            );
            final Offset control2 = Offset(
              current.dx + values[j + 2],
              current.dy + values[j + 3],
            );
            final Offset destination = Offset(
              current.dx + values[j + 4],
              current.dy + values[j + 5],
            );
            path.cubicTo(
              control1.dx,
              control1.dy,
              control2.dx,
              control2.dy,
              destination.dx,
              destination.dy,
            );
            current = destination;
          }
          break;
        case 'Q':
          for (int j = 0; j + 3 < values.length; j += 4) {
            final Offset control = Offset(values[j], values[j + 1]);
            final Offset destination = Offset(values[j + 2], values[j + 3]);
            path.quadraticBezierTo(
              control.dx,
              control.dy,
              destination.dx,
              destination.dy,
            );
            current = destination;
          }
          break;
        case 'q':
          for (int j = 0; j + 3 < values.length; j += 4) {
            final Offset control = Offset(
              current.dx + values[j],
              current.dy + values[j + 1],
            );
            final Offset destination = Offset(
              current.dx + values[j + 2],
              current.dy + values[j + 3],
            );
            path.quadraticBezierTo(
              control.dx,
              control.dy,
              destination.dx,
              destination.dy,
            );
            current = destination;
          }
          break;
        case 'Z':
        case 'z':
          path.close();
          current = subPathStart;
          break;
        default:
          break;
      }
    }

    return path;
  }
}
