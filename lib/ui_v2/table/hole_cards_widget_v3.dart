import 'package:flutter/material.dart';

import '../theme/v4_token_registry.dart';

class HoleCardsWidgetV3 extends StatelessWidget {
  const HoleCardsWidgetV3({
    required this.cards,
    required this.isFaceUp,
    this.onHover,
    this.onTap,
    this.isLifted = false,
    super.key,
  });

  final List<CardModel> cards;
  final bool isFaceUp;
  final VoidCallback? onHover;
  final VoidCallback? onTap;
  final bool isLifted;

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: cards.map((card) {
        final content = isFaceUp
            ? Text(
                '${card.rank}${card.suit}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const Text(
                'card_back',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              );
        return MouseRegion(
          onEnter: (_) => onHover?.call(),
          onExit: (_) {},
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedSlide(
              offset: isLifted
                  ? Offset(0, -tokens.v4MotionLiftOffset)
                  : Offset.zero,
              duration: tokens.v4MotionDurationS,
              curve: tokens.v4MotionCurve,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: tokens.v4SpacingS),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(tokens.v4ShadowOpacity),
                      blurRadius: tokens.v4ShadowBlur,
                      offset: Offset(0, tokens.v4ShadowOffset),
                    ),
                  ],
                ),
                child: Container(
                  width: 56,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(tokens.v4RadiusS),
                    border: Border.all(color: Colors.white24),
                  ),
                  alignment: Alignment.center,
                  child: content,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// Hotfix: Missing model definition
class CardModel {
  final String rank;
  final String suit;
  const CardModel({required this.rank, required this.suit});
}
