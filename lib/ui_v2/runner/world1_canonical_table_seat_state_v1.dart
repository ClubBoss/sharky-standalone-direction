enum World1CanonicalSeatAvailabilityV1 { normal, folded, outOfHand }

enum World1CanonicalSeatVisualRoleV1 { idle, activeGlow, target, acting }

class World1CanonicalTableSeatStateV1 {
  const World1CanonicalTableSeatStateV1({
    required this.seatTapEnabled,
    required this.availability,
    required this.visualRole,
    required this.isSeatQuizTargetHighlightActive,
    required this.isSeatQuizNonTargetSeat,
    required this.showHeroBadge,
    required this.showActBadge,
    required this.showFoldBadge,
    required this.showOutBadge,
    required this.seatOpacity,
  });

  final bool seatTapEnabled;
  final World1CanonicalSeatAvailabilityV1 availability;
  final World1CanonicalSeatVisualRoleV1 visualRole;
  final bool isSeatQuizTargetHighlightActive;
  final bool isSeatQuizNonTargetSeat;
  final bool showHeroBadge;
  final bool showActBadge;
  final bool showFoldBadge;
  final bool showOutBadge;
  final double seatOpacity;

  bool get isDecisionActingSeat =>
      visualRole == World1CanonicalSeatVisualRoleV1.acting;

  bool get isSeatQuizTargetSeat =>
      visualRole == World1CanonicalSeatVisualRoleV1.target;

  bool get isActiveSeatGlow =>
      visualRole == World1CanonicalSeatVisualRoleV1.target ||
      visualRole == World1CanonicalSeatVisualRoleV1.activeGlow ||
      visualRole == World1CanonicalSeatVisualRoleV1.acting;
}

World1CanonicalTableSeatStateV1 buildWorld1CanonicalTableSeatStateV1({
  required bool seatIsInteractable,
  required bool seatQuizVisualMode,
  required bool handLoopVisualMode,
  required bool seatInHand,
  required bool foldedBySeatId,
  required bool handLoopActionRequired,
  required String logicalSeatId,
  required String? targetSeatId,
  required String? activeSeatGlowId,
  required String? actingSeatId,
  required String? rotatingHeroSeatId,
}) {
  final seatTapEnabled =
      seatIsInteractable && seatQuizVisualMode && !handLoopVisualMode;
  final seatIsFolded = handLoopVisualMode && foldedBySeatId;
  final seatIsOutOfHand = handLoopVisualMode && !seatInHand && !seatIsFolded;
  final availability = seatIsFolded
      ? World1CanonicalSeatAvailabilityV1.folded
      : (seatIsOutOfHand
            ? World1CanonicalSeatAvailabilityV1.outOfHand
            : World1CanonicalSeatAvailabilityV1.normal);
  final isSeatQuizTargetHighlightActive =
      seatQuizVisualMode && !handLoopVisualMode && targetSeatId != null;
  final isSeatQuizTargetSeat =
      isSeatQuizTargetHighlightActive && logicalSeatId == targetSeatId;
  final isSeatQuizNonTargetSeat =
      isSeatQuizTargetHighlightActive && !isSeatQuizTargetSeat;
  final isDecisionActingSeat =
      handLoopActionRequired &&
      actingSeatId != null &&
      actingSeatId == logicalSeatId &&
      seatInHand;
  final isActiveSeatGlow =
      isSeatQuizTargetSeat ||
      (!isSeatQuizTargetHighlightActive && activeSeatGlowId == logicalSeatId);
  final visualRole = isDecisionActingSeat
      ? World1CanonicalSeatVisualRoleV1.acting
      : (isSeatQuizTargetSeat
            ? World1CanonicalSeatVisualRoleV1.target
            : (isActiveSeatGlow
                  ? World1CanonicalSeatVisualRoleV1.activeGlow
                  : World1CanonicalSeatVisualRoleV1.idle));
  final seatBaseOpacity =
      availability == World1CanonicalSeatAvailabilityV1.folded
      ? 0.5
      : (availability == World1CanonicalSeatAvailabilityV1.outOfHand
            ? 0.33
            : 1.0);
  final seatOpacity = isSeatQuizNonTargetSeat
      ? (seatBaseOpacity * 0.88).clamp(0.0, 1.0).toDouble()
      : seatBaseOpacity;
  final showHeroBadge = rotatingHeroSeatId == logicalSeatId;
  return World1CanonicalTableSeatStateV1(
    seatTapEnabled: seatTapEnabled,
    availability: availability,
    visualRole: visualRole,
    isSeatQuizTargetHighlightActive: isSeatQuizTargetHighlightActive,
    isSeatQuizNonTargetSeat: isSeatQuizNonTargetSeat,
    showHeroBadge: showHeroBadge,
    showActBadge: isDecisionActingSeat,
    showFoldBadge: availability == World1CanonicalSeatAvailabilityV1.folded,
    showOutBadge: availability == World1CanonicalSeatAvailabilityV1.outOfHand,
    seatOpacity: seatOpacity,
  );
}
