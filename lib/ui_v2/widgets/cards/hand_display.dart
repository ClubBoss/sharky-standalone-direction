import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/widgets/cards/poker_card.dart';

class HandDisplay extends StatelessWidget {
  final String hand;

  const HandDisplay({super.key, required this.hand});

  @override
  Widget build(BuildContext context) {
    final normalized = hand.toUpperCase().trim();
    final suffix = normalized.length > 2
        ? normalized.substring(normalized.length - 1)
        : '';
    final ranks = suffix == 'S' || suffix == 'O'
        ? normalized.substring(0, normalized.length - 1)
        : normalized;

    final rankA = ranks.isNotEmpty ? ranks[0] : '';
    final rankB = ranks.length > 1 ? ranks[1] : rankA;

    String suit1 = 's';
    String suit2 = 'c';

    if (suffix == 'S') {
      suit2 = 's';
    } else if (suffix == 'O') {
      suit2 = 'd';
    } else if (rankA == rankB) {
      suit2 = 'd';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PokerCard(rank: rankA, suit: suit1),
        const SizedBox(width: 8),
        PokerCard(rank: rankB, suit: suit2),
      ],
    );
  }
}
