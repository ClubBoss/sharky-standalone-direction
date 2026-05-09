import 'dart:ui' as ui;
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, FontWeight, TextDirection;

class ChipsPotPainterV1 {
  const ChipsPotPainterV1();

  ui.Picture drawChipsAndPot({
    required double potValue,
    required List<double> chipStacks,
    required double scale,
  }) {
    final double safePot = potValue.isFinite
        ? potValue.clamp(0.0, double.infinity)
        : 0.0;
    final List<double> safeChips = chipStacks
        .map(
          (value) => value.isFinite ? value.clamp(0.0, double.infinity) : 0.0,
        )
        .toList(growable: false);
    final double width = 340.0 * scale;
    final double height = 220.0 * scale;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, width, height),
    );
    final ui.Paint background = ui.Paint()..color = const ui.Color(0xFF121212);
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, width, height), background);
    final ui.Rect potRect = ui.Rect.fromCenter(
      center: ui.Offset(width / 2, height * 0.3),
      width: 180.0 * scale,
      height: 90.0 * scale,
    );
    final ui.RRect potOutline = ui.RRect.fromRectAndRadius(
      potRect,
      ui.Radius.circular(18.0 * scale),
    );
    final ui.Paint potPaint = ui.Paint()
      ..color = const ui.Color(0xFF636363)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 6.0 * scale;
    canvas.drawRRect(potOutline, potPaint);
    final String potLabel = _ascii('Pot: ${safePot.toStringAsFixed(0)}');
    final TextPainter potText = TextPainter(
      text: TextSpan(
        text: potLabel,
        style: TextStyle(
          color: const ui.Color(0xFFFFFFFF),
          fontSize: 22.0 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    potText.paint(
      canvas,
      ui.Offset(width / 2 - potText.width / 2, height * 0.25),
    );
    const double chipRadius = 16.0;
    final double chipSpacing =
        width / (safeChips.isEmpty ? 1 : safeChips.length + 1);
    for (int i = 0; i < safeChips.length; i++) {
      final double x = chipSpacing * (i + 1);
      final double y = height * 0.7;
      final ui.Paint chipPaint = ui.Paint()
        ..color = const ui.Color(0xFFE0A800)
        ..style = ui.PaintingStyle.fill;
      canvas.drawCircle(ui.Offset(x, y), chipRadius * scale, chipPaint);
      final ui.Paint edgePaint = ui.Paint()
        ..color = const ui.Color(0xFF8F6E00)
        ..style = ui.PaintingStyle.stroke
        ..strokeWidth = 3.0 * scale;
      canvas.drawCircle(ui.Offset(x, y), chipRadius * scale, edgePaint);
      final String valueLabel = _ascii(safeChips[i].toStringAsFixed(0));
      final TextPainter labelPainter = TextPainter(
        text: TextSpan(
          text: valueLabel,
          style: TextStyle(
            color: const ui.Color(0xFF050505),
            fontSize: 12.0 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        ui.Offset(x - labelPainter.width / 2, y - labelPainter.height / 2),
      );
    }
    return recorder.endRecording();
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
