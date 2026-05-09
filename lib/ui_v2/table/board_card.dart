import 'package:flutter/widgets.dart';

import '../design/design_containers.dart';
import '../design/design_tokens.dart';
import '../design/design_typography.dart';

class BoardCard extends StatelessWidget {
  const BoardCard({
    required this.position,
    required this.rank,
    required this.suit,
    this.size = const Size(56, 80),
    super.key,
  });

  final Offset position;
  final String rank;
  final String suit;
  final Size size;

  Color _suitColor() {
    switch (suit) {
      case 'H':
      case 'D':
        return Color(DesignColors.accentStrong);
      case 'S':
      case 'C':
      default:
        return Color(DesignColors.textPrimary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - size.width / 2,
      top: position.dy - size.height / 2,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: DesignContainers.card,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rank,
              style: TextStyle(
                fontSize: DesignTypography.h3,
                fontWeight: FontWeight.bold,
                color: Color(DesignColors.textPrimary),
              ),
            ),
            Text(
              suit,
              style: TextStyle(
                fontSize: DesignTypography.caption,
                color: _suitColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
