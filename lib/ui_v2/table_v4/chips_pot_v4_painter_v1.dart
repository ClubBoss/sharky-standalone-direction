import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Canvas painter for V4 chips and pot layer (Phi-44.2).
class ChipsPotV4PainterV1 extends CustomPainter {
  const ChipsPotV4PainterV1({
    required this.chipsGeometryMap,
    required this.potGeometryMap,
    required this.renderParamsMap,
  });

  final Map<String, Object> chipsGeometryMap;
  final Map<String, Object> potGeometryMap;
  final Map<String, Object> renderParamsMap;

  @override
  void paint(Canvas canvas, Size size) {
    final List<_ChipSpec> chips = _readChips();
    final Color chipColor = _readColor(
      renderParamsMap['chip_color'],
      const Color(0xFF3C9A3C),
    );
    final Color chipHighlightColor = _readColor(
      renderParamsMap['chip_highlight_color'],
      const Color(0x33FFFFFF),
    );

    final Paint chipPaint = Paint()
      ..color = chipColor
      ..isAntiAlias = true;
    final Paint chipHighlightPaint = Paint()
      ..color = chipHighlightColor
      ..isAntiAlias = true;

    for (final _ChipSpec chip in chips) {
      if (chip.radius <= 0) {
        continue;
      }
      canvas.drawCircle(chip.center, chip.radius, chipPaint);
      final double highlightRadius = chip.radius * 0.55;
      if (highlightRadius > 0 && chipHighlightColor.a > 0) {
        final Offset highlightOffset = chip.center.translate(
          -chip.radius * 0.35,
          -chip.radius * 0.35,
        );
        canvas.drawCircle(highlightOffset, highlightRadius, chipHighlightPaint);
      }
    }

    final Offset potCenter = _readPotCenter(size);
    final double potRadius = math.max(
      0,
      _readDouble(
        potGeometryMap,
        'radius',
        math.min(
              size.width == 0 ? 120 : size.width,
              size.height == 0 ? 120 : size.height,
            ) *
            0.18,
      ),
    );

    if (potRadius > 0) {
      final Color potColor = _readColor(
        renderParamsMap['pot_color'],
        const Color(0xFF4B4B4B),
      );
      final Paint potPaint = Paint()
        ..color = potColor
        ..isAntiAlias = true;
      canvas.drawCircle(potCenter, potRadius, potPaint);

      final double outlineWidth = _readDouble(
        renderParamsMap,
        'pot_outline_width',
        2.0,
      );
      final Color potOutlineColor = _readColor(
        renderParamsMap['pot_outline_color'],
        const Color(0xAA000000),
      );
      if (outlineWidth > 0 && potOutlineColor.a > 0) {
        final Paint potOutlinePaint = Paint()
          ..color = potOutlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = outlineWidth
          ..isAntiAlias = true;
        canvas.drawCircle(potCenter, potRadius, potOutlinePaint);
      }

      final Color potHighlightColor = _readColor(
        renderParamsMap['pot_highlight_color'],
        const Color(0x28FFFFFF),
      );
      if (potHighlightColor.a > 0) {
        final Paint potHighlightPaint = Paint()
          ..color = potHighlightColor
          ..isAntiAlias = true;
        canvas.drawCircle(
          potCenter.translate(-potRadius * 0.18, -potRadius * 0.18),
          potRadius * 0.6,
          potHighlightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  List<_ChipSpec> _readChips() {
    final Object? chipsRaw =
        chipsGeometryMap['chips'] ?? chipsGeometryMap['stacks'];
    if (chipsRaw is! List) {
      return <_ChipSpec>[];
    }
    final List<_ChipSpec> chips = <_ChipSpec>[];
    for (final Object entry in chipsRaw) {
      if (entry is Map) {
        final double x = _toDouble(
          entry['x'] ?? entry['dx'],
          _toDouble(entry['0'], 0),
        );
        final double y = _toDouble(
          entry['y'] ?? entry['dy'],
          _toDouble(entry['1'], 0),
        );
        final double r = _toDouble(
          entry['r'] ?? entry['radius'],
          _toDouble(entry['2'], 0),
        );
        chips.add(_ChipSpec(Offset(x, y), r.abs()));
        continue;
      }
      if (entry is List && entry.length >= 3) {
        final double x = _toDouble(entry[0], 0);
        final double y = _toDouble(entry[1], 0);
        final double r = _toDouble(entry[2], 0);
        chips.add(_ChipSpec(Offset(x, y), r.abs()));
      }
    }
    return chips;
  }

  Offset _readPotCenter(Size size) {
    final Object? centerRaw = potGeometryMap['center'];
    if (centerRaw is Map) {
      final double x = _toDouble(
        centerRaw['x'] ?? centerRaw['dx'],
        _toDouble(centerRaw['0'], size.width / 2),
      );
      final double y = _toDouble(
        centerRaw['y'] ?? centerRaw['dy'],
        _toDouble(centerRaw['1'], size.height / 2),
      );
      return Offset(x, y);
    }
    if (centerRaw is List && centerRaw.length >= 2) {
      final double x = _toDouble(centerRaw[0], size.width / 2);
      final double y = _toDouble(centerRaw[1], size.height / 2);
      return Offset(x, y);
    }
    final double fallbackX = _readDouble(
      potGeometryMap,
      'center_x',
      size.width / 2,
    );
    final double fallbackY = _readDouble(
      potGeometryMap,
      'center_y',
      size.height / 2,
    );
    return Offset(fallbackX, fallbackY);
  }

  double _readDouble(Map<String, Object> source, String key, double fallback) =>
      source.containsKey(key) ? _toDouble(source[key], fallback) : fallback;

  double _toDouble(Object? value, double fallback) {
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

  Color _readColor(Object? input, Color fallback) {
    if (input is Color) {
      return input;
    }
    if (input is int) {
      return Color(input);
    }
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
      if (named != null) {
        return named;
      }
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
      case 'gray':
      case 'grey':
        return Colors.grey;
      default:
        return null;
    }
  }
}

class _ChipSpec {
  const _ChipSpec(this.center, this.radius);

  final Offset center;
  final double radius;
}
