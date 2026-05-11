import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';

class World1CanonicalHandVisualClusterContractV1 {
  const World1CanonicalHandVisualClusterContractV1({
    required this.showBoard,
    required this.showPot,
    required this.showHeroCards,
    required this.boardAlignment,
    required this.potAlignment,
    required this.heroAlignment,
  });

  final bool showBoard;
  final bool showPot;
  final bool showHeroCards;
  final Alignment boardAlignment;
  final Alignment potAlignment;
  final Alignment heroAlignment;
}

World1CanonicalHandVisualClusterContractV1
resolveWorld1CanonicalHandVisualClusterContractV1({
  required bool showCampaignHandVisuals,
  required bool boardVisible,
  required bool heroVisible,
  required Alignment boardAlignment,
  required Alignment potAlignment,
  required Alignment heroAlignment,
}) {
  return World1CanonicalHandVisualClusterContractV1(
    showBoard: showCampaignHandVisuals && boardVisible,
    showPot: showCampaignHandVisuals,
    showHeroCards: showCampaignHandVisuals && heroVisible,
    boardAlignment: boardAlignment,
    potAlignment: potAlignment,
    heroAlignment: heroAlignment,
  );
}

List<Widget> buildWorld1CanonicalHandVisualClusterV1({
  required World1CanonicalHandVisualClusterContractV1 contract,
  required Widget boardChild,
  required Widget potChild,
  required Widget heroCardsChild,
}) {
  return <Widget>[
    if (contract.showBoard)
      Positioned.fill(
        child: Align(alignment: contract.boardAlignment, child: boardChild),
      ),
    if (contract.showPot)
      Positioned.fill(
        child: Align(alignment: contract.potAlignment, child: potChild),
      ),
    Positioned.fill(
      child: Align(
        alignment: contract.heroAlignment,
        child: contract.showHeroCards
            ? heroCardsChild
            : const SizedBox.shrink(),
      ),
    ),
  ];
}

Widget buildWorld1CanonicalHeroCardsBodyV1({required Widget cardsRow}) {
  return KeyedSubtree(
    key: const Key('microtask_demo_hero_cards_box_v1'),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SharkyTokensV1.slate500.withOpacity(0.32)),
      ),
      child: cardsRow,
    ),
  );
}
