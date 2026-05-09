import 'package:flutter/material.dart';
import '../models/card_model.dart';

class PlayingCardWidget extends StatelessWidget {
  final CardModel card;
  final double scale;
  const PlayingCardWidget({Key? key, required this.card, this.scale = 1.0})
    : super(key: key);

  double _snapToDevicePixel(BuildContext context, double value) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    if (dpr <= 0) return value;
    return (value * dpr).roundToDouble() / dpr;
  }

  @override
  Widget build(BuildContext context) {
    final isRed = card.suit == '♥' || card.suit == '♦';
    final rankSuit = '${card.rank}${card.suit}';
    final textColor = isRed ? const Color(0xFFC62828) : const Color(0xFF10131A);
    final horizontalMargin = _snapToDevicePixel(context, 2 * scale);
    final cardWidth = _snapToDevicePixel(context, 18 * scale);
    final cardHeight = _snapToDevicePixel(context, 26 * scale);
    final cornerRadius = _snapToDevicePixel(context, 4.5);
    final borderWidth = _snapToDevicePixel(context, 0.8).clamp(0.8, 1.2);
    final topInset = _snapToDevicePixel(context, 1.5 * scale);
    final sideInset = _snapToDevicePixel(context, 1.6 * scale);
    final bottomInset = _snapToDevicePixel(context, 1.4 * scale);
    final rankFontSize = _snapToDevicePixel(context, 4.25 * scale);
    final suitFontSize = _snapToDevicePixel(context, 8.3 * scale);
    final cardRadius = BorderRadius.circular(cornerRadius);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: cardRadius,
        border: Border.all(color: const Color(0xFFD5DBE6), width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 5,
            offset: const Offset(1, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 1.4,
            offset: const Offset(0, 0.8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: cardRadius,
        child: Stack(
          children: [
            Positioned(
              top: topInset,
              left: sideInset,
              child: Text(
                rankSuit,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: rankFontSize,
                  height: 1.0,
                ),
              ),
            ),
            Center(
              child: Text(
                card.suit,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: suitFontSize,
                  height: 1.0,
                ),
              ),
            ),
            Positioned(
              right: sideInset,
              bottom: bottomInset,
              child: Transform.rotate(
                angle: 3.1415926535,
                child: Text(
                  rankSuit,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: rankFontSize,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
