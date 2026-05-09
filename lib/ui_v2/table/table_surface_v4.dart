import 'package:flutter/material.dart';

import '../app_root.dart';
import '../theme/v4_token_registry.dart';
import 'hole_cards_widget_v3.dart';

class TableSurfaceV4 extends StatelessWidget {
  const TableSurfaceV4({required this.child, super.key});

  final Widget child;

  Widget placeholderHoleCardsV3() => HoleCardsWidgetV3(
    cards: [
      CardModel(rank: 'A', suit: 'S'),
      CardModel(rank: 'K', suit: 'D'),
    ],
    isFaceUp: false,
  );

  @override
  Widget build(BuildContext context) {
    const tokens = V4TokenRegistry();
    const cardWidth = 80.0;
    final baseSurface = Container(
      decoration: BoxDecoration(
        color: tokens.tableSurfaceColor,
        borderRadius: BorderRadius.circular(tokens.v4RadiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(tokens.v4ShadowOpacity),
            blurRadius: tokens.v4ShadowBlur,
            offset: Offset(0, tokens.v4ShadowOffset),
          ),
        ],
      ),
      child: child,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final left = (constraints.maxWidth - cardWidth) / 2;
        return Stack(
          children: [
            baseSurface,
            Positioned(
              bottom: tokens.v4SpacingL,
              left: left,
              child: placeholderHoleCardsV3(),
            ),
            Positioned(
              top: tokens.v4SpacingS,
              right: tokens.v4SpacingS,
              child: appRoot.provideV4HelpInfoIcon('table_surface_v4'),
            ),
          ],
        );
      },
    );
  }
}
