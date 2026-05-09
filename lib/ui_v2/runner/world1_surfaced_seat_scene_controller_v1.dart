import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_instruction_surface_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_seat_scene_contract_v1.dart';

class World1SurfacedSeatSceneInstructionControllerInputV1 {
  const World1SurfacedSeatSceneInstructionControllerInputV1({
    required this.seatQuizVisualMode,
    required this.handLoopVisualMode,
    required this.globalTrainingOverlayActive,
    required this.world1IntroOverlayActive,
    required this.world1ActionIntroOverlayActive,
    required this.world1StreetFlowIntroOverlayActive,
    required this.world2HandoffOverlayActive,
    required this.world2IntroOverlayActive,
    required this.trackIntroOverlayActive,
    required this.conceptPreludeInstructionSurfaceActive,
    required this.actionLiteracyPreludeInstructionSurfaceActive,
    required this.streetFlowPreludeInstructionSurfaceActive,
    required this.seatQuizTableInstructionText,
    required this.cashTrackIntroOverlayText,
    required this.tournamentTrackIntroOverlayText,
    required this.mixedTrackIntroOverlayText,
    required this.trackIntroKind,
    required this.conceptPreludePlacementText,
    required this.actionLiteracyPlacementText,
    required this.streetFlowPlacementText,
    required this.stadiumRect,
    required this.availableWidth,
    required this.compactPortrait,
    required this.textDirection,
    required this.seatAvoidRects,
  });

  final bool seatQuizVisualMode;
  final bool handLoopVisualMode;
  final bool globalTrainingOverlayActive;
  final bool world1IntroOverlayActive;
  final bool world1ActionIntroOverlayActive;
  final bool world1StreetFlowIntroOverlayActive;
  final bool world2HandoffOverlayActive;
  final bool world2IntroOverlayActive;
  final bool trackIntroOverlayActive;
  final bool conceptPreludeInstructionSurfaceActive;
  final bool actionLiteracyPreludeInstructionSurfaceActive;
  final bool streetFlowPreludeInstructionSurfaceActive;
  final String seatQuizTableInstructionText;
  final String cashTrackIntroOverlayText;
  final String tournamentTrackIntroOverlayText;
  final String mixedTrackIntroOverlayText;
  final String? trackIntroKind;
  final String conceptPreludePlacementText;
  final String actionLiteracyPlacementText;
  final String streetFlowPlacementText;
  final Rect stadiumRect;
  final double availableWidth;
  final bool compactPortrait;
  final TextDirection textDirection;
  final List<Rect> seatAvoidRects;
}

class World1SurfacedSeatSceneInstructionControllerStateV1 {
  const World1SurfacedSeatSceneInstructionControllerStateV1({
    required this.contract,
    required this.rect,
  });

  final World1CanonicalSeatQuizInstructionSurfaceContractV1 contract;
  final Rect? rect;
}

class World1SurfacedSeatSceneEntryInputV1 {
  const World1SurfacedSeatSceneEntryInputV1({
    required this.seatSceneInput,
    this.onTap,
  });

  final World1CanonicalTableSeatSceneInputV1 seatSceneInput;
  final VoidCallback? onTap;
}

class World1SurfacedSeatSceneEntryV1 {
  const World1SurfacedSeatSceneEntryV1({required this.contract, this.onTap});

  final World1CanonicalTableSeatSceneResolvedV1 contract;
  final VoidCallback? onTap;
}

class World1SurfacedSeatSceneControllerInputV1 {
  const World1SurfacedSeatSceneControllerInputV1({
    required this.instructionInput,
    required this.seatEntries,
  });

  final World1SurfacedSeatSceneInstructionControllerInputV1 instructionInput;
  final List<World1SurfacedSeatSceneEntryInputV1> seatEntries;
}

class World1SurfacedSeatSceneControllerStateV1 {
  const World1SurfacedSeatSceneControllerStateV1({
    required this.instruction,
    required this.seatEntries,
  });

  final World1SurfacedSeatSceneInstructionControllerStateV1 instruction;
  final List<World1SurfacedSeatSceneEntryV1> seatEntries;
}

World1SurfacedSeatSceneControllerStateV1
resolveWorld1SurfacedSeatSceneControllerV1(
  World1SurfacedSeatSceneControllerInputV1 input,
) {
  return World1SurfacedSeatSceneControllerStateV1(
    instruction: resolveWorld1SurfacedSeatSceneInstructionControllerV1(
      input.instructionInput,
    ),
    seatEntries: input.seatEntries
        .map(
          (entry) => World1SurfacedSeatSceneEntryV1(
            contract: resolveWorld1CanonicalTableSeatSceneV1(
              entry.seatSceneInput,
            ),
            onTap: entry.onTap,
          ),
        )
        .toList(growable: false),
  );
}

World1SurfacedSeatSceneInstructionControllerStateV1
resolveWorld1SurfacedSeatSceneInstructionControllerV1(
  World1SurfacedSeatSceneInstructionControllerInputV1 input,
) {
  final contract = resolveWorld1CanonicalSeatQuizInstructionSurfaceV1(
    World1CanonicalSeatQuizInstructionSurfaceInputV1(
      seatQuizVisualMode: input.seatQuizVisualMode,
      handLoopVisualMode: input.handLoopVisualMode,
      globalTrainingOverlayActive: input.globalTrainingOverlayActive,
      world1IntroOverlayActive: input.world1IntroOverlayActive,
      world1ActionIntroOverlayActive: input.world1ActionIntroOverlayActive,
      world1StreetFlowIntroOverlayActive:
          input.world1StreetFlowIntroOverlayActive,
      world2HandoffOverlayActive: input.world2HandoffOverlayActive,
      world2IntroOverlayActive: input.world2IntroOverlayActive,
      trackIntroOverlayActive: input.trackIntroOverlayActive,
      conceptPreludeInstructionSurfaceActive:
          input.conceptPreludeInstructionSurfaceActive,
      actionLiteracyPreludeInstructionSurfaceActive:
          input.actionLiteracyPreludeInstructionSurfaceActive,
      streetFlowPreludeInstructionSurfaceActive:
          input.streetFlowPreludeInstructionSurfaceActive,
      seatQuizTableInstructionText: input.seatQuizTableInstructionText,
      cashTrackIntroOverlayText: input.cashTrackIntroOverlayText,
      tournamentTrackIntroOverlayText: input.tournamentTrackIntroOverlayText,
      mixedTrackIntroOverlayText: input.mixedTrackIntroOverlayText,
      trackIntroKind: input.trackIntroKind,
      conceptPreludePlacementText: input.conceptPreludePlacementText,
      actionLiteracyPlacementText: input.actionLiteracyPlacementText,
      streetFlowPlacementText: input.streetFlowPlacementText,
    ),
  );
  if (!contract.isVisible || contract.placementText.isEmpty) {
    return World1SurfacedSeatSceneInstructionControllerStateV1(
      contract: contract,
      rect: null,
    );
  }

  final worldIntroOverlayActive =
      input.globalTrainingOverlayActive ||
      input.world1IntroOverlayActive ||
      input.world1ActionIntroOverlayActive ||
      input.world1StreetFlowIntroOverlayActive ||
      input.world2HandoffOverlayActive ||
      input.world2IntroOverlayActive ||
      input.trackIntroOverlayActive;
  final textStyle = AppTypography.caption.copyWith(
    color: SharkyTokensV1.textPrimary,
    fontWeight: FontWeight.w800,
    fontSize: input.compactPortrait ? 11.0 : 11.6,
    height: 1.18,
  );
  final plainSeatQuizInstructionCardV1 =
      contract.kind ==
      World1CanonicalSeatQuizInstructionSurfaceKindV1.plainText;
  final preferredCardWidth = contract.usesEmbeddedPreludeCard
      ? math.min(input.stadiumRect.width * 0.82, 316.0)
      : math.min(
          input.stadiumRect.width *
              (plainSeatQuizInstructionCardV1 ? 0.9 : 0.78),
          plainSeatQuizInstructionCardV1 ? 352.0 : 320.0,
        );
  final maxTextWidth = preferredCardWidth
      .clamp(180.0, math.max(180.0, input.availableWidth - 24.0))
      .toDouble();
  final textPainter = TextPainter(
    text: TextSpan(text: contract.placementText, style: textStyle),
    textDirection: input.textDirection,
    maxLines: contract.usesEmbeddedPreludeCard
        ? 4
        : (worldIntroOverlayActive ? 5 : 4),
  )..layout(maxWidth: maxTextWidth);
  final measuredHeight = textPainter.size.height;
  final verticalPadding = input.compactPortrait ? 10.0 : 11.0;
  final containerHeight = math.max(
    34.0,
    math.min(
      measuredHeight + (verticalPadding * 2),
      contract.usesEmbeddedPreludeCard
          ? (input.compactPortrait ? 150.0 : 156.0)
          : (input.compactPortrait ? 152.0 : 158.0),
    ),
  );
  final seatRingAvoidPadding = contract.usesEmbeddedPreludeCard
      ? (input.compactPortrait ? 18.0 : 16.0)
      : (plainSeatQuizInstructionCardV1
            ? (input.compactPortrait ? 14.0 : 12.0)
            : (input.compactPortrait ? 10.0 : 8.0));
  final rect = resolveWorld1SeatQuizTableInstructionRectV1(
    stadiumRect: input.stadiumRect,
    preferredWidth: maxTextWidth,
    containerHeight: containerHeight,
    avoidRects: input.seatAvoidRects
        .map((rect) => rect.inflate(seatRingAvoidPadding))
        .toList(growable: false),
    laneTopFactor: contract.usesEmbeddedPreludeCard
        ? 0.34
        : (plainSeatQuizInstructionCardV1 ? 0.12 : 0.38),
    laneBottomFactor: contract.usesEmbeddedPreludeCard
        ? 0.54
        : (plainSeatQuizInstructionCardV1 ? 0.28 : 0.62),
  );
  return World1SurfacedSeatSceneInstructionControllerStateV1(
    contract: contract,
    rect: rect,
  );
}
