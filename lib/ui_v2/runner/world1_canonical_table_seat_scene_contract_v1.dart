import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_seat_body_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_seat_state_v1.dart';

class World1CanonicalTableSeatSceneInputV1 {
  const World1CanonicalTableSeatSceneInputV1({
    required this.displaySeatId,
    required this.logicalSeatId,
    required this.seatLabel,
    required this.displayLabelText,
    required this.canonicalOrderBadgeText,
    required this.seatCenter,
    required this.seatSize,
    required this.seatColor,
    required this.textColor,
    required this.defaultBorderColor,
    required this.seatIsInteractable,
    required this.seatQuizVisualMode,
    required this.handLoopVisualMode,
    required this.seatInHand,
    required this.foldedBySeatId,
    required this.handLoopActionRequired,
    required this.targetSeatId,
    required this.activeSeatGlowId,
    required this.actingSeatId,
    required this.rotatingHeroSeatId,
    required this.canRotateSeatDisplay,
    required this.tablePracticeSession,
    required this.compactPortrait,
    required this.handLoopOutcomeFocusDeemphasis,
    required this.selectionActive,
  });

  final String displaySeatId;
  final String logicalSeatId;
  final String seatLabel;
  final String displayLabelText;
  final String? canonicalOrderBadgeText;
  final Offset seatCenter;
  final double seatSize;
  final Color seatColor;
  final Color textColor;
  final Color defaultBorderColor;
  final bool seatIsInteractable;
  final bool seatQuizVisualMode;
  final bool handLoopVisualMode;
  final bool seatInHand;
  final bool foldedBySeatId;
  final bool handLoopActionRequired;
  final String? targetSeatId;
  final String? activeSeatGlowId;
  final String? actingSeatId;
  final String? rotatingHeroSeatId;
  final bool canRotateSeatDisplay;
  final bool tablePracticeSession;
  final bool compactPortrait;
  final bool handLoopOutcomeFocusDeemphasis;
  final bool selectionActive;
}

class World1CanonicalTableSeatSceneResolvedV1 {
  const World1CanonicalTableSeatSceneResolvedV1({
    required this.left,
    required this.top,
    required this.semanticLabel,
    required this.semanticHint,
    required this.semanticButton,
    required this.semanticEnabled,
    required this.semanticValue,
    required this.seatTapEnabled,
    required this.bodyContract,
  });

  final double left;
  final double top;
  final String semanticLabel;
  final String semanticHint;
  final bool semanticButton;
  final bool semanticEnabled;
  final String semanticValue;
  final bool seatTapEnabled;
  final World1CanonicalSeatBodyContractV1 bodyContract;
}

World1CanonicalTableSeatSceneResolvedV1 resolveWorld1CanonicalTableSeatSceneV1(
  World1CanonicalTableSeatSceneInputV1 input,
) {
  final seatStateV1 = buildWorld1CanonicalTableSeatStateV1(
    seatIsInteractable: input.seatIsInteractable,
    seatQuizVisualMode: input.seatQuizVisualMode,
    handLoopVisualMode: input.handLoopVisualMode,
    seatInHand: input.seatInHand,
    foldedBySeatId: input.foldedBySeatId,
    handLoopActionRequired: input.handLoopActionRequired,
    logicalSeatId: input.logicalSeatId,
    targetSeatId: input.targetSeatId,
    activeSeatGlowId: input.activeSeatGlowId,
    actingSeatId: input.actingSeatId,
    rotatingHeroSeatId: input.rotatingHeroSeatId,
  );

  const actingSeatRingWidthV1 = 1.35;
  final isSeatQuizTargetSeatV1 = seatStateV1.isSeatQuizTargetSeat;
  final isActiveSeatGlow = seatStateV1.isActiveSeatGlow;
  final isDecisionActingSeatV1 = seatStateV1.isDecisionActingSeat;
  final activeSeatBorderWidthV1 = isDecisionActingSeatV1
      ? actingSeatRingWidthV1
      : (isSeatQuizTargetSeatV1
            ? (input.compactPortrait ? 2.6 : 2.8)
            : (isActiveSeatGlow && input.handLoopOutcomeFocusDeemphasis
                  ? 1.45
                  : 1.6));
  final activeSeatGlowShadowsV1 = isActiveSeatGlow
      ? <BoxShadow>[
          if (isDecisionActingSeatV1)
            BoxShadow(
              color: SharkyTokensV1.brandGlow.withOpacity(
                input.compactPortrait ? 0.18 : 0.16,
              ),
              blurRadius: input.compactPortrait ? 8 : 10,
              spreadRadius: input.compactPortrait ? 0.8 : 1.0,
            )
          else if (isSeatQuizTargetSeatV1)
            BoxShadow(
              color: SharkyTokensV1.brandGlow.withOpacity(
                input.compactPortrait ? 0.26 : 0.24,
              ),
              blurRadius: input.compactPortrait ? 11 : 13,
              spreadRadius: input.compactPortrait ? 1.4 : 1.6,
            )
          else
            BoxShadow(
              color: SharkyTokensV1.brandGlow.withOpacity(
                input.handLoopOutcomeFocusDeemphasis
                    ? 0.09
                    : (input.seatQuizVisualMode ? 0.18 : 0.16),
              ),
              blurRadius: input.compactPortrait ? 10 : 12,
              spreadRadius: input.compactPortrait ? 1.4 : 1.8,
            ),
          BoxShadow(
            color: SharkyTokensV1.brandPrimary.withOpacity(
              isDecisionActingSeatV1
                  ? 0.24
                  : (input.handLoopOutcomeFocusDeemphasis
                        ? 0.10
                        : (input.seatQuizVisualMode ? 0.2 : 0.17)),
            ),
            blurRadius: input.compactPortrait
                ? (isDecisionActingSeatV1 ? 5 : 5)
                : (isDecisionActingSeatV1 ? 6 : 6),
            spreadRadius: input.compactPortrait
                ? (isDecisionActingSeatV1 ? 0.4 : 0.6)
                : (isDecisionActingSeatV1 ? 0.5 : 0.8),
          ),
          if (isSeatQuizTargetSeatV1)
            BoxShadow(
              color: SharkyTokensV1.brandPrimary.withOpacity(
                input.compactPortrait ? 0.2 : 0.18,
              ),
              blurRadius: input.compactPortrait ? 6 : 7,
              spreadRadius: input.compactPortrait ? 0.4 : 0.5,
            ),
        ]
      : null;
  final activeSeatBorderColorV1 = isDecisionActingSeatV1
      ? SharkyTokensV1.brandGlow.withOpacity(0.92)
      : (isSeatQuizTargetSeatV1
            ? SharkyTokensV1.brandGlow.withOpacity(0.95)
            : input.defaultBorderColor);

  return World1CanonicalTableSeatSceneResolvedV1(
    left: input.seatCenter.dx - (input.seatSize / 2),
    top: input.seatCenter.dy - (input.seatSize / 2),
    semanticLabel: 'Seat ${input.seatLabel}',
    semanticHint: seatStateV1.seatTapEnabled
        ? 'double tap to select'
        : 'empty seat',
    semanticButton: seatStateV1.seatTapEnabled,
    semanticEnabled: seatStateV1.seatTapEnabled,
    semanticValue: input.selectionActive ? 'selected' : 'idle',
    seatTapEnabled: seatStateV1.seatTapEnabled,
    bodyContract: World1CanonicalSeatBodyContractV1(
      displaySeatId: input.displaySeatId,
      logicalSeatId: input.logicalSeatId,
      labelText: input.displayLabelText,
      canonicalOrderBadgeText: input.canonicalOrderBadgeText,
      seatSize: input.seatSize,
      seatColor: input.seatColor,
      textColor: input.textColor,
      borderColor: activeSeatBorderColorV1,
      borderWidth: activeSeatBorderWidthV1,
      opacity: seatStateV1.seatOpacity,
      glowShadows: activeSeatGlowShadowsV1,
      canRotateSeatDisplay: input.canRotateSeatDisplay,
      rotatingHeroSeatId: input.rotatingHeroSeatId,
      showHeroBadge: seatStateV1.showHeroBadge,
      showActBadge: seatStateV1.showActBadge,
      showFoldBadge: seatStateV1.showFoldBadge,
      showOutBadge: seatStateV1.showOutBadge,
      tablePracticeSession: input.tablePracticeSession,
    ),
  );
}

Widget buildWorld1CanonicalTableSeatSceneBodyV1({
  required World1CanonicalTableSeatSceneResolvedV1 contract,
  required VoidCallback? onTap,
}) {
  return Positioned(
    left: contract.left,
    top: contract.top,
    child: Semantics(
      label: contract.semanticLabel,
      hint: contract.semanticHint,
      button: contract.semanticButton,
      enabled: contract.semanticEnabled,
      value: contract.semanticValue,
      child: GestureDetector(
        onTap: contract.seatTapEnabled ? onTap : null,
        child: buildWorld1CanonicalSeatBodyV1(contract.bodyContract),
      ),
    ),
  );
}
