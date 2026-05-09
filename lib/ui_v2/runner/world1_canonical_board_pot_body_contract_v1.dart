import 'package:flutter/material.dart';
import 'package:poker_analyzer/engine_v2/model/money_state_v1.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/widgets/playing_card_widget.dart';

class World1CanonicalBoardPotBodyContractV1 {
  const World1CanonicalBoardPotBodyContractV1({
    required this.visibleBoardCount,
    required this.renderedBoardCount,
    required this.renderHiddenBoardPlaceholders,
    required this.displayedPotChips,
    required this.compactPotBadge,
    required this.inlinePotBadge,
    required this.potPulse,
  });

  final int visibleBoardCount;
  final int renderedBoardCount;
  final bool renderHiddenBoardPlaceholders;
  final int displayedPotChips;
  final bool compactPotBadge;
  final bool inlinePotBadge;
  final bool potPulse;
}

World1CanonicalBoardPotBodyContractV1
resolveWorld1CanonicalBoardPotBodyContractV1({
  required StreetV1 effectiveStreet,
  required int boardCardsCount,
  required bool demoHandLoopVisualStep,
  required bool demoHandLoopSession,
  required int displayedPotChips,
  required bool compactPotBadge,
  required bool inlinePotBadge,
  required bool potPulse,
}) {
  final visibleBoardCount = switch (effectiveStreet) {
    StreetV1.preflop => 0,
    StreetV1.flop => 3,
    StreetV1.turn => 4,
    StreetV1.river => 5,
  };
  final renderHiddenBoardPlaceholders =
      demoHandLoopVisualStep || demoHandLoopSession;
  final renderedBoardCount = renderHiddenBoardPlaceholders
      ? boardCardsCount
      : visibleBoardCount.clamp(0, boardCardsCount);
  return World1CanonicalBoardPotBodyContractV1(
    visibleBoardCount: visibleBoardCount,
    renderedBoardCount: renderedBoardCount,
    renderHiddenBoardPlaceholders: renderHiddenBoardPlaceholders,
    displayedPotChips: displayedPotChips,
    compactPotBadge: compactPotBadge,
    inlinePotBadge: inlinePotBadge,
    potPulse: potPulse,
  );
}

Widget buildWorld1CanonicalBoardRevealBodyV1({
  required World1CanonicalBoardPotBodyContractV1 contract,
  required List<CardModel> boardCards,
  required double cardScale,
  required Widget Function(double scale) buildFaceDownCard,
}) {
  return Container(
    key: const Key('microtask_engine_board_strip'),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: SharkyTokensV1.surfaceCard.withOpacity(0.34),
      borderRadius: BorderRadius.circular(SharkyTokensV1.radiusFull),
      border: Border.all(color: SharkyTokensV1.slate500.withOpacity(0.28)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < contract.renderedBoardCount; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 4),
          if (contract.renderHiddenBoardPlaceholders &&
              i >= contract.visibleBoardCount)
            buildFaceDownCard(cardScale),
          if (!contract.renderHiddenBoardPlaceholders ||
              i < contract.visibleBoardCount)
            PlayingCardWidget(card: boardCards[i], scale: cardScale),
        ],
      ],
    ),
  );
}

Widget buildWorld1CanonicalPotBadgeBodyV1({
  required World1CanonicalBoardPotBodyContractV1 contract,
  required Widget chipBadgeChild,
}) {
  final potBadge = Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: <Widget>[
      Container(
        key: const Key('microtask_engine_pot_feedback'),
        padding: EdgeInsets.symmetric(
          horizontal: contract.compactPotBadge ? 6.0 : 7.0,
          vertical: contract.compactPotBadge ? 2.2 : 2.6,
        ),
        decoration: BoxDecoration(
          color: SharkyTokensV1.surfaceCard.withOpacity(
            contract.inlinePotBadge ? 0.14 : 0.12,
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: contract.potPulse
                ? SharkyTokensV1.brandGlow.withOpacity(0.58)
                : SharkyTokensV1.slate600.withOpacity(0.3),
            width: contract.potPulse ? 1.0 : 0.9,
          ),
        ),
        child: chipBadgeChild,
      ),
      Positioned(
        left: 0,
        top: 0,
        child: IgnorePointer(
          child: Text(
            '${contract.displayedPotChips}',
            key: const Key('microtask_pot_value_v1'),
            style: const TextStyle(
              color: Colors.transparent,
              fontSize: 0.1,
              height: 0.1,
            ),
          ),
        ),
      ),
    ],
  );
  final wrapped = Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: potBadge,
  );
  if (contract.inlinePotBadge) {
    return wrapped;
  }
  return Align(alignment: Alignment.centerLeft, child: wrapped);
}
