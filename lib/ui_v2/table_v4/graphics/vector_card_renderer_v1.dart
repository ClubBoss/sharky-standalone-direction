import 'dart:ui' as ui;
import 'package:flutter/painting.dart'
    show TextPainter, TextSpan, TextStyle, FontWeight, TextDirection;

class VectorCardRendererV1 {
  const VectorCardRendererV1();

  static const List<String> _validRanks = <String>[
    'A',
    'K',
    'Q',
    'J',
    'T',
    '9',
    '8',
    '7',
    '6',
    '5',
    '4',
    '3',
    '2',
  ];

  static const List<String> _validSuits = <String>['s', 'h', 'd', 'c'];

  ui.Picture drawCard({
    required String rank,
    required String suit,
    required double scale,
  }) {
    final String safeRank = _ascii(
      _validRanks.contains(rank.toUpperCase()) ? rank.toUpperCase() : '?',
    );
    final String safeSuit = _ascii(
      _validSuits.contains(suit.toLowerCase()) ? suit : '?',
    );
    final double cardWidth = 200.0 * scale;
    final double cardHeight = cardWidth * 1.4;
    final double cornerRadius = 24.0 * scale;
    final ui.Rect bounds = ui.Rect.fromLTWH(0, 0, cardWidth, cardHeight);
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder, bounds);
    final ui.Paint fillPaint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    final ui.RRect outer = ui.RRect.fromRectAndRadius(
      bounds,
      ui.Radius.circular(cornerRadius),
    );
    canvas.drawRRect(outer, fillPaint);
    final ui.Paint borderPaint = ui.Paint()
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 4.0 * scale
      ..color = const ui.Color(0xFF1F1F1F);
    canvas.drawRRect(outer, borderPaint);
    final ui.Color suitColor = (safeSuit == 'h' || safeSuit == 'd')
        ? const ui.Color(0xFFB71C1C)
        : const ui.Color(0xFF111111);
    final double padding = 16.0 * scale;
    final TextPainter rankPainter = TextPainter(
      text: TextSpan(
        text: safeRank,
        style: TextStyle(
          color: suitColor,
          fontSize: 48.0 * scale,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    rankPainter.paint(canvas, ui.Offset(padding, padding));
    final TextPainter suitPainter = TextPainter(
      text: TextSpan(
        text: _suitGlyph(safeSuit),
        style: TextStyle(color: suitColor, fontSize: 64.0 * scale),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final ui.Offset centerOffset = ui.Offset(
      cardWidth / 2 - suitPainter.width / 2,
      cardHeight / 2 - suitPainter.height / 2,
    );
    suitPainter.paint(canvas, centerOffset);
    return recorder.endRecording();
  }

  static String _suitGlyph(String suit) {
    switch (suit) {
      case 's':
        return '♠';
      case 'h':
        return '♥';
      case 'd':
        return '♦';
      case 'c':
        return '♣';
      default:
        return '?';
    }
  }

  static String _ascii(String input) => String.fromCharCodes(
    input.codeUnits.where((unit) => unit >= 0 && unit < 128),
  );
}
