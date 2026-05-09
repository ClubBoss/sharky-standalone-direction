import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../motion/card_lift_hover_v1.dart';

class HoleCardsWidgetV1 extends StatelessWidget {
  const HoleCardsWidgetV1({
    required this.seatState,
    required this.card1,
    required this.card2,
    required this.isFaceUp,
    this.visualStyleBundle = const <String, Object?>{},
    super.key,
  });

  final Object? seatState;
  final String card1;
  final String card2;
  final bool isFaceUp;
  final Map<String, Object?> visualStyleBundle;

  String _rank(String card) {
    if (card.length <= 1) return '?';
    return card.substring(0, card.length - 1);
  }

  String _suit(String card) {
    if (card.isEmpty) return '?';
    return card.substring(card.length - 1);
  }

  Color _suitColor(String suit) {
    switch (suit) {
      case 'H':
      case 'D':
        return const Color(0xFFE53935);
      case 'S':
      case 'C':
      default:
        return const Color(0xFF0F2436);
    }
  }

  Widget _cardFace(String card) {
    final rank = _rank(card);
    final suit = _suit(card);
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [VisualThemeV3.shadowLight],
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rank,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F2436),
            ),
          ),
          Text(
            suit,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _suitColor(suit),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardBack() {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [VisualThemeV3.shadowLight],
        border: Border.all(color: const Color(0xF2FFFFFF), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ = seatState;
    final overlap = VisualThemeV3.spacingS;
    final firstCard = cardLiftHoverV1(
      cardWidget: isFaceUp ? _cardFace(card1) : _cardBack(),
      isFaceUp: isFaceUp,
      visualStyleBundle: visualStyleBundle,
    );
    final secondCard = cardLiftHoverV1(
      cardWidget: isFaceUp ? _cardFace(card2) : _cardBack(),
      isFaceUp: isFaceUp,
      visualStyleBundle: visualStyleBundle,
    );

    return SizedBox(
      width: 56 + overlap,
      height: 80,
      child: Stack(
        children: [
          Positioned(left: 0, child: firstCard),
          Positioned(left: overlap, child: secondCard),
        ],
      ),
    );
  }
}
