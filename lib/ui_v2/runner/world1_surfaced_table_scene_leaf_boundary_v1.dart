import 'package:flutter/material.dart';
import 'package:poker_analyzer/engine_v2/model/money_state_v1.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_board_pot_body_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_marker_contract_v1.dart';

class World1SurfacedSeatQuizCueInputV1 {
  const World1SurfacedSeatQuizCueInputV1({
    required this.seatQuizVisualMode,
    required this.dealerCueCenter,
    required this.sbCueCenter,
    required this.bbCueCenter,
    required this.targetSeatId,
    required this.targetSeatCenter,
    required this.cueRadius,
    required this.nonOverlappingSeatSize,
  });

  final bool seatQuizVisualMode;
  final Offset dealerCueCenter;
  final Offset sbCueCenter;
  final Offset bbCueCenter;
  final String? targetSeatId;
  final Offset? targetSeatCenter;
  final double cueRadius;
  final double nonOverlappingSeatSize;
}

class World1SurfacedHandLoopChipCueInputV1 {
  const World1SurfacedHandLoopChipCueInputV1({
    required this.handLoopVisualMode,
    required this.demoActionDecisionStateV1,
    required this.sbCueCenter,
    required this.bbCueCenter,
    required this.cueRadius,
    required this.sbDisplaySeatId,
    required this.bbDisplaySeatId,
  });

  final bool handLoopVisualMode;
  final bool demoActionDecisionStateV1;
  final Offset sbCueCenter;
  final Offset bbCueCenter;
  final double cueRadius;
  final String sbDisplaySeatId;
  final String bbDisplaySeatId;
}

class World1SurfacedBoardPotLeafInputV1 {
  const World1SurfacedBoardPotLeafInputV1({
    required this.effectiveStreet,
    required this.boardCardsCount,
    required this.demoHandLoopVisualStep,
    required this.demoHandLoopSession,
    required this.displayedPotChips,
    required this.compactPotBadge,
    required this.inlinePotBadge,
    required this.potPulse,
  });

  final StreetV1 effectiveStreet;
  final int boardCardsCount;
  final bool demoHandLoopVisualStep;
  final bool demoHandLoopSession;
  final int displayedPotChips;
  final bool compactPotBadge;
  final bool inlinePotBadge;
  final bool potPulse;
}

List<Widget> buildWorld1SurfacedSeatQuizCueBodiesV1({
  required World1SurfacedSeatQuizCueInputV1 input,
}) {
  final markerContracts = resolveWorld1CanonicalSeatQuizCueContractsV1(
    seatQuizVisualMode: input.seatQuizVisualMode,
    cueRadius: input.cueRadius,
  );
  final cues = <Widget>[
    for (final contract in markerContracts)
      buildWorld1CanonicalTableMarkerBodyV1(
        center: switch (contract.kind) {
          World1CanonicalTableMarkerKindV1.dealer => input.dealerCueCenter,
          World1CanonicalTableMarkerKindV1.sb => input.sbCueCenter,
          World1CanonicalTableMarkerKindV1.bb => input.bbCueCenter,
        },
        contract: contract,
      ),
  ];
  final targetRingContract = resolveWorld1CanonicalTargetRingContractV1(
    targetSeatCenter: input.targetSeatCenter,
    targetSeatId: input.targetSeatId,
    nonOverlappingSeatSize: input.nonOverlappingSeatSize,
  );
  if (targetRingContract != null && input.targetSeatCenter != null) {
    cues.add(
      buildWorld1CanonicalTargetRingBodyV1(
        center: input.targetSeatCenter!,
        contract: targetRingContract,
      ),
    );
  }
  return cues;
}

List<Widget> buildWorld1SurfacedHandLoopChipCueBodiesV1({
  required World1SurfacedHandLoopChipCueInputV1 input,
}) {
  return <Widget>[
    for (final contract in resolveWorld1CanonicalHandLoopCueContractsV1(
      handLoopVisualMode: input.handLoopVisualMode,
      demoActionDecisionState: input.demoActionDecisionStateV1,
      cueRadius: input.cueRadius,
      sbDisplaySeatId: input.sbDisplaySeatId,
      bbDisplaySeatId: input.bbDisplaySeatId,
    ))
      buildWorld1CanonicalTableMarkerBodyV1(
        center: contract.kind == World1CanonicalTableMarkerKindV1.sb
            ? input.sbCueCenter
            : input.bbCueCenter,
        contract: contract,
      ),
  ];
}

Widget buildWorld1SurfacedPotBadgeBodyV1({
  required World1SurfacedBoardPotLeafInputV1 input,
}) {
  final contract = resolveWorld1CanonicalBoardPotBodyContractV1(
    effectiveStreet: input.effectiveStreet,
    boardCardsCount: input.boardCardsCount,
    demoHandLoopVisualStep: input.demoHandLoopVisualStep,
    demoHandLoopSession: input.demoHandLoopSession,
    displayedPotChips: input.displayedPotChips,
    compactPotBadge: input.compactPotBadge,
    inlinePotBadge: input.inlinePotBadge,
    potPulse: input.potPulse,
  );
  return buildWorld1CanonicalPotBadgeBodyV1(
    contract: contract,
    chipBadgeChild: buildWorld1CanonicalChipStackBadgeV1(
      label: 'POT',
      amount: contract.displayedPotChips,
      chipSize: contract.compactPotBadge ? 7.2 : 7.8,
      backgroundOpacity: 0.0,
    ),
  );
}

Widget buildWorld1SurfacedBoardRevealBodyV1({
  required World1SurfacedBoardPotLeafInputV1 input,
  required List<CardModel> boardCards,
  required double cardScale,
}) {
  final contract = resolveWorld1CanonicalBoardPotBodyContractV1(
    effectiveStreet: input.effectiveStreet,
    boardCardsCount: input.boardCardsCount,
    demoHandLoopVisualStep: input.demoHandLoopVisualStep,
    demoHandLoopSession: input.demoHandLoopSession,
    displayedPotChips: input.displayedPotChips,
    compactPotBadge: input.compactPotBadge,
    inlinePotBadge: input.inlinePotBadge,
    potPulse: input.potPulse,
  );
  return buildWorld1CanonicalBoardRevealBodyV1(
    contract: contract,
    boardCards: boardCards,
    cardScale: cardScale,
    buildFaceDownCard: buildWorld1SurfacedFaceDownCardV1,
  );
}

Widget buildWorld1SurfacedFaceDownCardV1(double scale) {
  final width = (18 * scale).roundToDouble();
  final height = (26 * scale).roundToDouble();
  final radius = (4.5 * scale).clamp(7.0, 12.0).toDouble();
  final borderWidth = (0.8 * scale).clamp(0.8, 1.2).toDouble();
  return Container(
    margin: EdgeInsets.symmetric(horizontal: (2 * scale).roundToDouble()),
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: SharkyTokensV1.slate600.withOpacity(0.46),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: SharkyTokensV1.slate500.withOpacity(0.78),
        width: borderWidth,
      ),
    ),
  );
}
