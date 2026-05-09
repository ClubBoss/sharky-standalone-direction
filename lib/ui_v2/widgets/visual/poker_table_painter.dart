import 'package:flutter/material.dart';

/// Premium CustomPainter that renders a GGPoker-style poker table with:
/// - RadialGradient felt (spotlight effect)
/// - Leather/mahogany rail with sweep gradient
/// - Betting line for visual depth
/// - Drop shadows and 3D effects
class PokerTablePainter extends CustomPainter {
  PokerTablePainter({
    this.feltCenterColor = const Color(0xFF4B8B6E),
    this.feltEdgeColor = const Color(0xFF2D5743),
    this.railDarkColor = const Color(0xFF1A0F0A),
    this.railHighlightColor = const Color(0xFF3D2817),
    this.railBorderColor = const Color(0xFF6B4423),
    this.showBettingLine = true,
  });

  final Color feltCenterColor;
  final Color feltEdgeColor;
  final Color railDarkColor;
  final Color railHighlightColor;
  final Color railBorderColor;
  final bool showBettingLine;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final borderRadius = size.width / 2; // Full semicircles at top/bottom

    // Draw outer drop shadow
    _drawDropShadow(canvas, rect, borderRadius);

    // Draw rail (outer border with leather texture)
    _drawRail(canvas, rect, borderRadius);

    // Draw felt (inner playing surface)
    _drawFelt(canvas, rect, borderRadius);

    // Draw betting line
    if (showBettingLine) {
      _drawBettingLine(canvas, rect, borderRadius);
    }
  }

  void _drawDropShadow(Canvas canvas, Rect rect, double borderRadius) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

    final shadowRect = rect.inflate(5).shift(const Offset(0, 12));
    final shadowRRect = RRect.fromRectAndRadius(
      shadowRect,
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(shadowRRect, shadowPaint);
  }

  void _drawRail(Canvas canvas, Rect rect, double borderRadius) {
    final railWidth = rect.width * 0.08; // 8% of width

    // Outer stadium shape
    final outerRRect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    // Inner stadium shape
    final innerRect = rect.deflate(railWidth);
    final innerBorderRadius = (borderRadius - railWidth).clamp(
      0.0,
      double.infinity,
    );
    final innerRRect = RRect.fromRectAndRadius(
      innerRect,
      Radius.circular(innerBorderRadius),
    );

    // Draw mahogany/leather rail with gradient for 3D effect
    final railGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        railDarkColor,
        railHighlightColor,
        railDarkColor,
        railHighlightColor.withOpacity(0.7),
      ],
      stops: const [0.0, 0.35, 0.65, 1.0],
    );

    final railPaint = Paint()
      ..shader = railGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw rail as ring (outer RRect minus inner RRect)
    final railPath = Path()
      ..addRRect(outerRRect)
      ..addRRect(innerRRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(railPath, railPaint);

    // Draw rail border (outer edge)
    final borderPaint = Paint()
      ..color = railBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRRect(outerRRect, borderPaint);

    // Draw rail inner highlight (for 3D beveled look)
    final innerHighlightPaint = Paint()
      ..color = railHighlightColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(innerRRect, innerHighlightPaint);
  }

  void _drawFelt(Canvas canvas, Rect rect, double borderRadius) {
    final railWidth = rect.width * 0.08;
    final feltRect = rect.deflate(railWidth + 4); // 4px padding inside rail
    final feltBorderRadius = (borderRadius - railWidth - 4).clamp(
      0.0,
      double.infinity,
    );
    final feltRRect = RRect.fromRectAndRadius(
      feltRect,
      Radius.circular(feltBorderRadius),
    );

    // Spotlight effect: brighter in center, darker at edges (stretched vertically)
    final feltGradient = RadialGradient(
      center: const Alignment(0, -0.2), // Shift center up for vertical stadium
      radius: 0.8,
      colors: [
        feltCenterColor.withOpacity(0.95),
        feltCenterColor,
        feltEdgeColor,
        feltEdgeColor.withOpacity(0.85),
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );

    final feltPaint = Paint()
      ..shader = feltGradient.createShader(rect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(feltRRect, feltPaint);

    // Add subtle texture lines - simulates fabric weave
    _drawFabricTexture(canvas, rect, feltRect);

    // Inner shadow for depth
    final innerShadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final innerShadowRect = feltRect.deflate(3);
    final innerShadowRRect = RRect.fromRectAndRadius(
      innerShadowRect,
      Radius.circular((feltBorderRadius - 3).clamp(0.0, double.infinity)),
    );

    canvas.drawRRect(innerShadowRRect, innerShadowPaint);
  }

  void _drawFabricTexture(Canvas canvas, Rect outerRect, Rect feltRect) {
    // Draw very subtle vertical and horizontal lines to simulate felt fabric
    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Vertical lines
    const verticalLineCount = 20;
    for (var i = 0; i < verticalLineCount; i++) {
      final x = feltRect.left + (feltRect.width * i / verticalLineCount);
      canvas.drawLine(
        Offset(x, feltRect.top),
        Offset(x, feltRect.bottom),
        texturePaint,
      );
    }

    // Horizontal lines
    const horizontalLineCount = 30;
    for (var i = 0; i < horizontalLineCount; i++) {
      final y = feltRect.top + (feltRect.height * i / horizontalLineCount);
      canvas.drawLine(
        Offset(feltRect.left, y),
        Offset(feltRect.right, y),
        texturePaint,
      );
    }
  }

  void _drawBettingLine(Canvas canvas, Rect rect, double borderRadius) {
    final railWidth = rect.width * 0.08;
    final bettingLineRect = rect.deflate(railWidth + 15); // Inside felt area
    final bettingLineBorderRadius = (borderRadius - railWidth - 15).clamp(
      0.0,
      double.infinity,
    );

    final bettingLineRRect = RRect.fromRectAndRadius(
      bettingLineRect,
      Radius.circular(bettingLineBorderRadius),
    );

    final bettingLinePaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw dashed rounded rectangle for betting line
    _drawDashedRRect(
      canvas,
      bettingLineRRect,
      bettingLinePaint,
      dashLength: 10,
      gapLength: 8,
    );
  }

  void _drawDashedRRect(
    Canvas canvas,
    RRect rrect,
    Paint paint, {
    double dashLength = 5,
    double gapLength = 3,
  }) {
    final path = Path()..addRRect(rrect);
    final metric = path.computeMetrics().first;
    final totalLength = metric.length;

    var distance = 0.0;
    while (distance < totalLength) {
      final dashPath = metric.extractPath(
        distance,
        distance + dashLength.clamp(0.0, totalLength - distance),
      );
      canvas.drawPath(dashPath, paint);
      distance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant PokerTablePainter oldDelegate) {
    return feltCenterColor != oldDelegate.feltCenterColor ||
        feltEdgeColor != oldDelegate.feltEdgeColor ||
        railDarkColor != oldDelegate.railDarkColor ||
        railHighlightColor != oldDelegate.railHighlightColor ||
        showBettingLine != oldDelegate.showBettingLine;
  }
}
