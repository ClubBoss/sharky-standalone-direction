import 'dart:math';
import 'package:flutter/material.dart';

/// A premium GGPoker-style chip stack widget that renders realistic poker chips
/// using CustomPaint with 3D effects, gradients, and stacking physics.
class ChipStackWidget extends StatelessWidget {
  const ChipStackWidget({
    super.key,
    required this.amount,
    this.maxChipsToShow = 12,
  });

  final double amount;
  final int maxChipsToShow;

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) {
      return const SizedBox.shrink();
    }

    final chipBreakdown = _breakdownAmount(amount);

    return RepaintBoundary(
      child: CustomPaint(
        size: const Size(100, 80),
        painter: _ChipStackPainter(
          chipBreakdown: chipBreakdown,
          maxChipsToShow: maxChipsToShow,
        ),
      ),
    );
  }

  /// Greedy algorithm to break down amount into chip denominations
  List<_ChipDenomination> _breakdownAmount(double amount) {
    final result = <_ChipDenomination>[];
    var remaining = amount.toInt();

    // Process denominations from highest to lowest
    for (final denom in _ChipDenomination.denominations) {
      final count = remaining ~/ denom.value;
      if (count > 0) {
        result.add(
          _ChipDenomination(
            value: denom.value,
            color: denom.color,
            accentColor: denom.accentColor,
            count: count,
          ),
        );
        remaining -= count * denom.value;
      }
    }

    return result;
  }
}

class _ChipDenomination {
  const _ChipDenomination({
    required this.value,
    required this.color,
    required this.accentColor,
    required this.count,
  });

  final int value;
  final Color color;
  final Color accentColor;
  final int count;

  static const denominations = [
    _ChipDenomination(
      value: 500,
      color: Color(0xFF6A1B9A), // Purple
      accentColor: Color(0xFFFFD700), // Gold
      count: 0,
    ),
    _ChipDenomination(
      value: 100,
      color: Color(0xFF212121), // Black
      accentColor: Color(0xFF757575), // Grey
      count: 0,
    ),
    _ChipDenomination(
      value: 25,
      color: Color(0xFF2E7D32), // Green
      accentColor: Color(0xFF1B5E20), // Dark Green
      count: 0,
    ),
    _ChipDenomination(
      value: 5,
      color: Color(0xFFC62828), // Red
      accentColor: Color(0xFF8E0000), // Dark Red
      count: 0,
    ),
    _ChipDenomination(
      value: 1,
      color: Color(0xFFEEEEEE), // White
      accentColor: Color(0xFF1976D2), // Blue
      count: 0,
    ),
  ];
}

class _ChipStackPainter extends CustomPainter {
  _ChipStackPainter({required this.chipBreakdown, required this.maxChipsToShow})
    : _random = Random(42); // Fixed seed for consistent layout

  final List<_ChipDenomination> chipBreakdown;
  final int maxChipsToShow;
  final Random _random;

  static const double _chipRadius = 18.0;
  static const double _chipThickness = 4.0;
  static const double _verticalSpacing = 5.0;
  static const int _dashCount = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final startY = size.height - _chipRadius - 5;

    var currentY = startY;
    var totalChipsDrawn = 0;

    // Draw chips from bottom to top
    for (final denom in chipBreakdown.reversed) {
      final chipsToRender = min(denom.count, maxChipsToShow - totalChipsDrawn);

      for (var i = 0; i < chipsToRender; i++) {
        // Add subtle random horizontal offset for realism
        final randomOffset = (_random.nextDouble() - 0.5) * 3;
        final chipX = centerX + randomOffset;

        _drawChip(
          canvas,
          Offset(chipX, currentY),
          denom.color,
          denom.accentColor,
          denom.value,
          isTopChip:
              totalChipsDrawn == maxChipsToShow - 1 ||
              (i == chipsToRender - 1 && denom == chipBreakdown.first),
        );

        currentY -= _verticalSpacing;
        totalChipsDrawn++;

        if (totalChipsDrawn >= maxChipsToShow) break;
      }

      if (totalChipsDrawn >= maxChipsToShow) break;
    }
  }

  void _drawChip(
    Canvas canvas,
    Offset center,
    Color mainColor,
    Color accentColor,
    int value, {
    required bool isTopChip,
  }) {
    // Draw 3D edge/thickness effect
    _draw3DEdge(canvas, center, mainColor);

    // Draw main chip body with radial gradient for plastic texture
    final gradient = RadialGradient(
      colors: [
        mainColor.withOpacity(0.9),
        mainColor,
        mainColor.withOpacity(0.7),
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: _chipRadius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, _chipRadius, paint);

    // Draw outer ring (border)
    final ringPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, _chipRadius - 1, ringPaint);

    // Draw dashed ring (classic casino look)
    _drawDashedRing(canvas, center, accentColor);

    // Draw inner circle
    final innerCirclePaint = Paint()
      ..color = mainColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, _chipRadius * 0.6, innerCirclePaint);

    // Only draw value on top chip for clarity
    if (isTopChip) {
      _drawValue(canvas, center, value, accentColor);
    }

    // Add highlight for glossy effect
    _drawHighlight(canvas, center);
  }

  void _draw3DEdge(Canvas canvas, Offset center, Color baseColor) {
    final edgeColor = baseColor.withOpacity(0.4);
    final edgePaint = Paint()
      ..color = edgeColor
      ..style = PaintingStyle.fill;

    // Draw a thin ellipse below the chip to simulate thickness
    final edgeRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy + _chipThickness / 2),
      width: _chipRadius * 2,
      height: _chipThickness,
    );

    canvas.drawOval(edgeRect, edgePaint);
  }

  void _drawDashedRing(Canvas canvas, Offset center, Color color) {
    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final dashRadius = _chipRadius - 5;
    final angleStep = (2 * pi) / _dashCount;

    for (var i = 0; i < _dashCount; i++) {
      final angle = i * angleStep;
      final dashLength = angleStep * 0.4; // 40% of segment is dash

      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: dashRadius),
        angle,
        dashLength,
      );

      canvas.drawPath(path, dashPaint);
    }
  }

  void _drawValue(Canvas canvas, Offset center, int value, Color accentColor) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: value >= 100 ? 11 : 12,
      fontWeight: FontWeight.bold,
      shadows: const [
        Shadow(color: Colors.black54, offset: Offset(0.5, 0.5), blurRadius: 1),
      ],
    );

    final textSpan = TextSpan(
      text: value >= 100 ? '${value ~/ 100}K' : '$value',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
  }

  void _drawHighlight(Canvas canvas, Offset center) {
    // Add a small glossy highlight at top-left for realism
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final highlightCenter = Offset(
      center.dx - _chipRadius * 0.3,
      center.dy - _chipRadius * 0.3,
    );

    canvas.drawCircle(highlightCenter, _chipRadius * 0.25, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant _ChipStackPainter oldDelegate) {
    return chipBreakdown != oldDelegate.chipBreakdown ||
        maxChipsToShow != oldDelegate.maxChipsToShow;
  }
}
