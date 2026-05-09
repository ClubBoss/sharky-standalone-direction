import 'package:flutter/material.dart';

import 'package:poker_analyzer/ui_v3/theme/visual_theme_v3.dart';

import '../app_root.dart';
import '../components/help_info_icon_v4.dart';
import 'board_card.dart';
import 'dealer_button.dart';

class BoardCardData {
  const BoardCardData({required this.rank, required this.suit});
  final String rank;
  final String suit;
}

class BoardSurface extends StatelessWidget {
  const BoardSurface({
    required this.position,
    required this.dealerPosition,
    this.cards = const <BoardCardData>[],
    super.key,
  });

  static const double _width = 220;
  static const double _height = 120;
  static const double _cardWidth = 56;
  static const double _cardHeight = 80;

  final Offset position;
  final Offset dealerPosition;
  final List<BoardCardData> cards;

  List<double> get _cardOffsets => const [-1.8, -0.9, 0.0, 0.9, 1.8];

  @override
  Widget build(BuildContext context) {
    final offsetY = _height * 0.01;
    final theme = Theme.of(context);
    return Stack(
      children: [
        Positioned(
          left: position.dx - _width / 2,
          top: position.dy - _height / 2,
          child: Container(
            width: _width,
            height: _height,
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(VisualThemeV3.cardRadius),
              boxShadow: const [
                VisualThemeV3.shadowMedium,
                VisualThemeV3.shadowLight,
              ],
              border: Border.all(
                color: VisualThemeV3.secondaryAccent.withValues(alpha: 0.15),
              ),
            ),
          ),
        ),
        Positioned(
          left: dealerPosition.dx - 19,
          top: dealerPosition.dy - 19,
          child: DealerButton(position: dealerPosition),
        ),
        for (var i = 0; i < _cardOffsets.length; i++)
          BoardCard(
            position: position + Offset(_cardOffsets[i] * _cardWidth, offsetY),
            rank: i < cards.length ? cards[i].rank : ' ',
            suit: i < cards.length ? cards[i].suit : ' ',
            size: const Size(_cardWidth, _cardHeight),
          ),
        Positioned(
          left: position.dx + (_width / 2) - 18,
          top: position.dy - (_height / 2) + 2,
          child: HelpInfoIconV4(
            componentId: 'board_surface_v4',
            binder: appRoot.exportInlineExplanationBinderV4,
            isV4Active: appRoot.isV4Active,
          ),
        ),
      ],
    );
  }
}
