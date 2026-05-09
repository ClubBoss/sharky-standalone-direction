import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/models/card_model.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_action_token_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_felt_caption_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_hand_visual_cluster_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_overlay_lane_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_spatial_scaffold_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_runtime_feed_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_surfaced_support_action_runtime_v1.dart';

class World1SurfacedTableSceneRuntimeInputV1 {
  const World1SurfacedTableSceneRuntimeInputV1({
    required this.canvasSize,
    required this.portraitLayout,
    required this.compactPortrait,
    required this.seatIds,
    required this.selectedVisualSeatId,
    required this.targetSeatId,
    required this.demoHandLoopVisualStep,
    required this.heroSeatId,
    required this.normalizedHeroSeatId,
    required this.forceHandLoopSurfaceForTest,
    required this.seatQuizVisualMode,
    required this.handLoopVisualMode,
    required this.outcomeSurfaceVisible,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.reviewQueuePrefix,
    required this.debugCaptionOverridePresent,
    required this.handLoopPromptSurfaceV1,
    required this.handLoopActionState,
    required this.heroCards,
    required this.boardCards,
    required this.fallbackFeltCaptionText,
    required this.selectedSeatId,
    required this.coachSeatGlowId,
  });

  final Size canvasSize;
  final bool portraitLayout;
  final bool compactPortrait;
  final List<String> seatIds;
  final String? selectedVisualSeatId;
  final String? targetSeatId;
  final bool demoHandLoopVisualStep;
  final String? heroSeatId;
  final String? normalizedHeroSeatId;
  final bool forceHandLoopSurfaceForTest;
  final bool seatQuizVisualMode;
  final bool handLoopVisualMode;
  final bool outcomeSurfaceVisible;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final bool reviewQueuePrefix;
  final bool debugCaptionOverridePresent;
  final World1SurfacedHandLoopPromptSurfaceV1 handLoopPromptSurfaceV1;
  final World1SurfacedActionStateV1? handLoopActionState;
  final List<CardModel> heroCards;
  final List<CardModel> boardCards;
  final String fallbackFeltCaptionText;
  final String? selectedSeatId;
  final String? coachSeatGlowId;
}

class World1SurfacedTableSceneRuntimeStateV1 {
  const World1SurfacedTableSceneRuntimeStateV1({
    required this.spatialScaffoldV1,
    required this.showCampaignHandVisuals,
    required this.heroCardScale,
    required this.boardCardScale,
    required this.heroCardsRect,
    required this.handLoopActionRequiredV1,
    required this.handLoopOutcomeFocusDeemphasisV1,
    required this.handLoopActingSeatCenterV1,
    required this.heroSeatGlowIdV1,
    required this.activeSeatGlowIdV1,
    required this.boardRect,
    required this.potRect,
    required this.overlayLaneContractV1,
    required this.handLoopPromptTopBandCoexistenceV1,
    required this.feltCaptionContractV1,
    required this.dealerCueCenter,
    required this.sbCueCenter,
    required this.bbCueCenter,
    required this.handVisualClusterV1,
    required this.actionTokenContractV1,
  });

  final World1CanonicalTableSpatialScaffoldResolvedV1 spatialScaffoldV1;
  final bool showCampaignHandVisuals;
  final double heroCardScale;
  final double boardCardScale;
  final Rect? heroCardsRect;
  final bool handLoopActionRequiredV1;
  final bool handLoopOutcomeFocusDeemphasisV1;
  final Offset? handLoopActingSeatCenterV1;
  final String? heroSeatGlowIdV1;
  final String? activeSeatGlowIdV1;
  final Rect boardRect;
  final Rect potRect;
  final World1CanonicalOverlayLaneContractResolvedV1 overlayLaneContractV1;
  final World1CanonicalFeltCaptionBandV1? handLoopPromptTopBandCoexistenceV1;
  final World1CanonicalFeltCaptionContractResolvedV1 feltCaptionContractV1;
  final Offset dealerCueCenter;
  final Offset sbCueCenter;
  final Offset bbCueCenter;
  final World1CanonicalHandVisualClusterContractV1 handVisualClusterV1;
  final World1CanonicalActionTokenContractResolvedV1 actionTokenContractV1;
}

World1SurfacedTableSceneRuntimeStateV1 resolveWorld1SurfacedTableSceneRuntimeV1(
  World1SurfacedTableSceneRuntimeInputV1 input,
) {
  final spatialScaffoldV1 = resolveWorld1CanonicalTableSpatialScaffoldV1(
    World1CanonicalTableSpatialScaffoldInputV1(
      canvasSize: input.canvasSize,
      portraitLayout: input.portraitLayout,
      seatIds: input.seatIds,
      selectedVisualSeatId: input.selectedVisualSeatId,
      targetSeatId: input.targetSeatId,
      demoHandLoopVisualStep: input.demoHandLoopVisualStep,
      heroSeatId: input.heroSeatId,
    ),
  );
  final compactPhone = spatialScaffoldV1.compactPhone;
  final ultraCompactPortrait = spatialScaffoldV1.ultraCompactPortrait;
  final tableCenter = spatialScaffoldV1.tableCenter;
  final tableShellRectV1 = spatialScaffoldV1.tableShellRect;
  final stadiumRect = spatialScaffoldV1.stadiumRect;
  final targetSeatCenter = spatialScaffoldV1.targetSeatCenter;
  final rotatingHeroSeatIdV1 = spatialScaffoldV1.rotatingHeroSeatId;
  final seatVisualRadius = spatialScaffoldV1.seatVisualRadius;
  const cueRadius = 8.5;
  final dealerMarkerRadius = cueRadius * 1.5;
  final blindMarkerRadius = input.handLoopVisualMode
      ? cueRadius * 3.0
      : cueRadius * 1.6;
  final showCampaignHandVisuals = input.handLoopVisualMode;
  final heroCenterPointBase = spatialScaffoldV1.resolvePointOnStadium(
    normalized: _World1SurfacedTableSceneGeometrySpecV1.heroCardsCenter,
    safeInset: 0,
  );
  final heroCenterPoint = Offset(
    heroCenterPointBase.dx,
    heroCenterPointBase.dy +
        (input.demoHandLoopVisualStep
            ? (compactPhone ? 18 : 20)
            : (compactPhone ? 3 : 5)),
  );
  final heroCardsRect = showCampaignHandVisuals && input.heroCards.length == 2
      ? Rect.fromCenter(
          center: heroCenterPoint,
          width: compactPhone ? 128 : 146,
          height: compactPhone ? 46 : 54,
        )
      : null;
  final heroCardScale = ultraCompactPortrait
      ? 1.85
      : (compactPhone ? 2.15 : 2.42);
  final boardCardScale = ultraCompactPortrait
      ? 1.35
      : (compactPhone ? 1.52 : 1.72);
  final handLoopActionRequiredV1 =
      input.handLoopVisualMode &&
      input.handLoopActionState != null &&
      !input.outcomeSurfaceVisible;
  final handLoopOutcomeFocusDeemphasisV1 =
      input.handLoopVisualMode && input.outcomeSurfaceVisible;
  final handLoopActingSeatCenterV1 = input.handLoopActionState == null
      ? null
      : spatialScaffoldV1.resolveSeatCenter(
          spatialScaffoldV1.displaySeatIdForLogical(
            input.handLoopActionState!.actingSeatId,
          ),
        );
  final heroSeatGlowIdV1 =
      input.normalizedHeroSeatId ??
      (input.handLoopActionState == null
          ? null
          : input.handLoopActionState!.actingSeatId);
  final activeSeatGlowIdV1 = input.handLoopVisualMode
      ? (heroSeatGlowIdV1 ?? input.selectedSeatId)
      : (input.coachSeatGlowId ?? input.selectedSeatId ?? input.targetSeatId);
  final rotatedSbBbDensityRefineV1 =
      input.demoHandLoopVisualStep &&
      (rotatingHeroSeatIdV1 == 'sb' || rotatingHeroSeatIdV1 == 'bb');
  final demoPromptToHeroGapV1 = rotatedSbBbDensityRefineV1
      ? (input.compactPortrait ? 21.0 : 23.0)
      : (input.compactPortrait ? 18.0 : 20.0);
  final demoHeroToTokenGapV1 = rotatedSbBbDensityRefineV1
      ? (input.compactPortrait ? 17.0 : 19.0)
      : (input.compactPortrait ? 12.0 : 14.0);
  final boardAnchorV1 = input.demoHandLoopVisualStep
      ? _World1SurfacedTableSceneGeometrySpecV1.boardCenter
      : _World1SurfacedTableSceneGeometrySpecV1.boardCenterLower;
  final boardCenterPointBase = spatialScaffoldV1.resolvePointOnStadium(
    normalized: boardAnchorV1,
    safeInset: 0,
  );
  final boardCenterPoint = input.forceHandLoopSurfaceForTest
      ? Offset(
          boardCenterPointBase.dx,
          boardCenterPointBase.dy + (input.compactPortrait ? 24.0 : 22.0),
        )
      : boardCenterPointBase;
  final boardStripWidth = (24 * boardCardScale * 5) + 32;
  final boardStripHeight = (34 * boardCardScale) + 12;
  const boardStripSafetyInsetY = 16.0;
  final boardStripHalfHeight = (boardStripHeight / 2) + boardStripSafetyInsetY;
  final boardCenterMinY = tableShellRectV1.top + boardStripHalfHeight + 1.0;
  final boardCenterMaxY = tableShellRectV1.bottom - boardStripHalfHeight - 1.0;
  final rawSafeBoardCenterPoint =
      input.handLoopVisualMode && !input.demoHandLoopVisualStep
      ? Offset(
          boardCenterPoint.dx,
          boardCenterPoint.dy - (input.portraitLayout ? 12.0 : 30.0),
        )
      : boardCenterPoint;
  final boundedBoardCenterY = boardCenterMaxY >= boardCenterMinY
      ? rawSafeBoardCenterPoint.dy
            .clamp(boardCenterMinY, boardCenterMaxY)
            .toDouble()
      : ((boardCenterMinY + boardCenterMaxY) / 2).toDouble();
  final safeBoardCenterPoint = Offset(
    rawSafeBoardCenterPoint.dx,
    boundedBoardCenterY,
  );
  final boardAlignmentInShellV1 = Alignment(
    ((((safeBoardCenterPoint.dx - tableShellRectV1.left) /
                        tableShellRectV1.width)
                    .clamp(0.0, 1.0)
                as double) *
            2) -
        1,
    ((((safeBoardCenterPoint.dy - tableShellRectV1.top) /
                        tableShellRectV1.height)
                    .clamp(0.0, 1.0)
                as double) *
            2) -
        1,
  );
  final basePotCenterPoint = spatialScaffoldV1.resolvePointOnStadium(
    normalized: _World1SurfacedTableSceneGeometrySpecV1.potCenter,
    safeInset: 0,
  );
  final potCenterPoint = input.demoHandLoopVisualStep
      ? Offset.lerp(safeBoardCenterPoint, basePotCenterPoint, 0.68)!
      : basePotCenterPoint;
  final handVisualClusterV1 = resolveWorld1CanonicalHandVisualClusterContractV1(
    showCampaignHandVisuals: showCampaignHandVisuals,
    boardVisible: input.boardCards.isNotEmpty,
    heroVisible: input.heroCards.length == 2,
    boardAlignment: boardAlignmentInShellV1,
    potAlignment: spatialScaffoldV1.alignmentForPoint(potCenterPoint),
    heroAlignment: spatialScaffoldV1.alignmentForPoint(heroCenterPoint),
  );
  final boardRect = Rect.fromCenter(
    center: safeBoardCenterPoint,
    width: boardStripWidth,
    height: boardStripHeight,
  );
  final potRect = Rect.fromCenter(
    center: potCenterPoint,
    width: compactPhone ? 86 : 94,
    height: compactPhone ? 30 : 34,
  );
  final markerAvoidRects = <Rect>[
    if (heroCardsRect != null) heroCardsRect,
    if (input.handLoopVisualMode)
      boardRect.inflate(input.compactPortrait ? 34.0 : 30.0),
    if (input.handLoopVisualMode)
      potRect.inflate(input.compactPortrait ? 14.0 : 12.0),
  ];
  final markerSafeRect = stadiumRect.deflate(2.0);
  final dealerCueCenterForOverlayAvoidV1 = _resolveMarkerCenterNoOverlapV1(
    seatCenter: spatialScaffoldV1.btnCenter,
    tableCenter: tableCenter,
    seatVisualRadiusPx: seatVisualRadius,
    markerRadiusPx: dealerMarkerRadius,
    stadiumSafeRect: markerSafeRect,
    avoidRects: markerAvoidRects,
  );
  final sbCueCenterForOverlayAvoidV1 = _resolveMarkerCenterNoOverlapV1(
    seatCenter: spatialScaffoldV1.sbCenter,
    tableCenter: tableCenter,
    seatVisualRadiusPx: seatVisualRadius,
    markerRadiusPx: blindMarkerRadius,
    stadiumSafeRect: markerSafeRect,
    avoidRects: markerAvoidRects,
  );
  final bbCueCenterForOverlayAvoidV1 = _resolveMarkerCenterNoOverlapV1(
    seatCenter: spatialScaffoldV1.bbCenter,
    tableCenter: tableCenter,
    seatVisualRadiusPx: seatVisualRadius,
    markerRadiusPx: blindMarkerRadius,
    stadiumSafeRect: markerSafeRect,
    avoidRects: markerAvoidRects,
  );
  final seatAvoidRectsV1 = input.seatIds
      .map(spatialScaffoldV1.resolveSeatCenter)
      .map(
        (center) => Rect.fromCircle(
          center: center,
          radius:
              seatVisualRadius +
              (input.handLoopVisualMode
                  ? (input.compactPortrait ? 30.0 : 28.0)
                  : (input.compactPortrait ? 20.0 : 18.0)),
        ),
      )
      .toList(growable: false);
  final overlayLaneContractV1 = resolveWorld1CanonicalOverlayLaneContractV1(
    World1CanonicalOverlayLaneContractInputV1(
      canvasSize: input.canvasSize,
      stadiumRect: stadiumRect,
      boardRect: boardRect,
      potRect: potRect,
      heroCardsRect: heroCardsRect,
      seatAvoidRects: seatAvoidRectsV1,
      boardVisible: input.boardCards.isNotEmpty,
      seatQuizVisualMode: input.seatQuizVisualMode,
      handLoopVisualMode: input.handLoopVisualMode,
      demoHandLoopVisualStep: input.demoHandLoopVisualStep,
      compactPortrait: input.compactPortrait,
      seatVisualRadius: seatVisualRadius,
      cueRadius: cueRadius,
      dealerCueCenter: dealerCueCenterForOverlayAvoidV1,
      sbCueCenter: sbCueCenterForOverlayAvoidV1,
      bbCueCenter: bbCueCenterForOverlayAvoidV1,
      demoPromptToHeroGap: demoPromptToHeroGapV1,
      rotatingHeroSeatId: rotatingHeroSeatIdV1,
      promptAffectedStateFamily:
          input.handLoopPromptSurfaceV1.isAffectedStateFamily,
      promptUsesFeltCaptionHost:
          input.handLoopPromptSurfaceV1.usesFeltCaptionHost,
    ),
  );
  final handLoopPromptTopBandCoexistenceV1 =
      overlayLaneContractV1.handLoopPromptTopBand == null
      ? null
      : World1CanonicalFeltCaptionBandV1(
          captionTop: overlayLaneContractV1.handLoopPromptTopBand!.captionTop,
          captionLeft: overlayLaneContractV1.handLoopPromptTopBand!.captionLeft,
          captionRight:
              overlayLaneContractV1.handLoopPromptTopBand!.captionRight,
          maxCaptionWidth:
              overlayLaneContractV1.handLoopPromptTopBand!.maxCaptionWidth,
        );
  final availableFeltCaptionWidthV1 = math.min(
    stadiumRect.width - 20,
    input.canvasSize.width - 24,
  );
  final feltCaptionContractV1 = resolveWorld1CanonicalFeltCaptionContractV1(
    World1CanonicalFeltCaptionContractInputV1(
      portraitLayout: input.portraitLayout,
      affectedStateFamily: input.handLoopPromptSurfaceV1.isAffectedStateFamily,
      usesFeltCaptionHost: input.handLoopPromptSurfaceV1.usesFeltCaptionHost,
      isMounted: input.handLoopPromptSurfaceV1.isMounted,
      showSeatQuizPrelude: input.showSeatQuizPrelude,
      showIntroSequence: input.showIntroSequence,
      handLoopVisualMode: input.handLoopVisualMode,
      outcomeSurfaceVisible: input.outcomeSurfaceVisible,
      debugCaptionOverridePresent: input.debugCaptionOverridePresent,
      isDemoHandLoopVisualStep: input.demoHandLoopVisualStep,
      reviewQueuePrefix: input.reviewQueuePrefix,
      compactPortrait: input.compactPortrait,
      rotatedSbBbDensityRefine: rotatedSbBbDensityRefineV1,
      mountedPromptText: input.handLoopPromptSurfaceV1.promptText,
      fallbackPromptText: input.fallbackFeltCaptionText,
      mountedMaxWidth: math.min(
        handLoopPromptTopBandCoexistenceV1?.maxCaptionWidth ??
            overlayLaneContractV1.feltCaptionMaxWidth,
        availableFeltCaptionWidthV1,
      ),
      fallbackMaxWidth: math.min(
        overlayLaneContractV1.feltCaptionMaxWidth,
        availableFeltCaptionWidthV1,
      ),
    ),
  );
  final dealerCueCenter = _resolveMarkerCenterNoOverlapV1(
    seatCenter: spatialScaffoldV1.btnCenter,
    tableCenter: tableCenter,
    seatVisualRadiusPx: seatVisualRadius,
    markerRadiusPx: dealerMarkerRadius,
    stadiumSafeRect: markerSafeRect,
    avoidRects: markerAvoidRects,
  );
  final sbCueCenter = _resolveMarkerCenterNoOverlapV1(
    seatCenter: spatialScaffoldV1.sbCenter,
    tableCenter: tableCenter,
    seatVisualRadiusPx: seatVisualRadius,
    markerRadiusPx: blindMarkerRadius,
    stadiumSafeRect: markerSafeRect,
    avoidRects: markerAvoidRects,
  );
  final bbCueCenter = _resolveMarkerCenterNoOverlapV1(
    seatCenter: spatialScaffoldV1.bbCenter,
    tableCenter: tableCenter,
    seatVisualRadiusPx: seatVisualRadius,
    markerRadiusPx: blindMarkerRadius,
    stadiumSafeRect: markerSafeRect,
    avoidRects: markerAvoidRects,
  );
  final actionTokenContractV1 =
      input.handLoopVisualMode && input.handLoopActionState != null
      ? (() {
          final actingSeatCenter = spatialScaffoldV1.resolveSeatCenter(
            spatialScaffoldV1.displaySeatIdForLogical(
              input.handLoopActionState!.actingSeatId,
            ),
          );
          final betOwnerSeatId = input.handLoopActionState!.betOwnerSeatId;
          final betOwnerSeatCenter = spatialScaffoldV1.resolveSeatCenter(
            spatialScaffoldV1.displaySeatIdForLogical(
              betOwnerSeatId ?? input.handLoopActionState!.actingSeatId,
            ),
          );
          return resolveWorld1CanonicalActionTokenContractV1(
            World1CanonicalActionTokenContractInputV1(
              handLoopVisualMode: input.handLoopVisualMode,
              demoHandLoopVisualStep: input.demoHandLoopVisualStep,
              compactPhone: compactPhone,
              tableCenter: tableCenter,
              stadiumSafeRect: markerSafeRect,
              actingSeatCenter: actingSeatCenter,
              betOwnerSeatCenter: betOwnerSeatCenter,
              boardRect: boardRect,
              potRect: potRect,
              heroCardsRect: heroCardsRect,
              heroCenterPoint: heroCenterPoint,
              overlayLaneBottom: overlayLaneContractV1.overlayLaneRect.bottom,
              demoHeroToTokenGap: demoHeroToTokenGapV1,
              currentBet: input.handLoopActionState!.currentBet,
            ),
          );
        })()
      : const World1CanonicalActionTokenContractResolvedV1(
          bodyKind: World1CanonicalActionTokenBodyKindV1.hidden,
          glowCenter: null,
          glowRadius: 0,
          betCenter: null,
          demoRowLeft: 0,
          demoRowTop: 0,
          markerContract: null,
          demoChipSize: 0,
          demoRowKey: Key('microtask_demo_token_row_v1'),
        );
  return World1SurfacedTableSceneRuntimeStateV1(
    spatialScaffoldV1: spatialScaffoldV1,
    showCampaignHandVisuals: showCampaignHandVisuals,
    heroCardScale: heroCardScale,
    boardCardScale: boardCardScale,
    heroCardsRect: heroCardsRect,
    handLoopActionRequiredV1: handLoopActionRequiredV1,
    handLoopOutcomeFocusDeemphasisV1: handLoopOutcomeFocusDeemphasisV1,
    handLoopActingSeatCenterV1: handLoopActingSeatCenterV1,
    heroSeatGlowIdV1: heroSeatGlowIdV1,
    activeSeatGlowIdV1: activeSeatGlowIdV1,
    boardRect: boardRect,
    potRect: potRect,
    overlayLaneContractV1: overlayLaneContractV1,
    handLoopPromptTopBandCoexistenceV1: handLoopPromptTopBandCoexistenceV1,
    feltCaptionContractV1: feltCaptionContractV1,
    dealerCueCenter: dealerCueCenter,
    sbCueCenter: sbCueCenter,
    bbCueCenter: bbCueCenter,
    handVisualClusterV1: handVisualClusterV1,
    actionTokenContractV1: actionTokenContractV1,
  );
}

Offset _resolveMarkerCenterNoOverlapV1({
  required Offset seatCenter,
  required Offset tableCenter,
  required double seatVisualRadiusPx,
  required double markerRadiusPx,
  required Rect stadiumSafeRect,
  required List<Rect> avoidRects,
}) {
  const gapPx = 5.0;
  const towardCenterFactor = 0.14;
  final minDistance = seatVisualRadiusPx + markerRadiusPx + gapPx;
  final toward = tableCenter - seatCenter;
  final towardMagnitude = toward.distance;
  final direction = towardMagnitude <= 0.001
      ? const Offset(0, -1)
      : toward / towardMagnitude;
  final safeRectInset = markerRadiusPx + 1.0;
  final insetSafeRect = stadiumSafeRect.deflate(safeRectInset);
  final effectiveSafeRect = insetSafeRect.width > 0 && insetSafeRect.height > 0
      ? insetSafeRect
      : stadiumSafeRect;

  Offset clampToSafeRect(Offset point) {
    if (effectiveSafeRect.width <= 0 || effectiveSafeRect.height <= 0) {
      return tableCenter;
    }
    final minX = math.min(effectiveSafeRect.left, effectiveSafeRect.right);
    final maxX = math.max(effectiveSafeRect.left, effectiveSafeRect.right);
    final minY = math.min(effectiveSafeRect.top, effectiveSafeRect.bottom);
    final maxY = math.max(effectiveSafeRect.top, effectiveSafeRect.bottom);
    return Offset(
      point.dx.clamp(minX, maxX).toDouble(),
      point.dy.clamp(minY, maxY).toDouble(),
    );
  }

  bool overlapsSeat(Offset center) {
    return (center - seatCenter).distance < minDistance;
  }

  bool overlapsAvoidRects(Offset center) {
    for (final rect in avoidRects) {
      if (_markerCircleIntersectsRectV1(center, markerRadiusPx + 1.0, rect)) {
        return true;
      }
    }
    return false;
  }

  final projectedDistance = towardMagnitude <= 0.001
      ? minDistance
      : math.max(towardMagnitude * towardCenterFactor, minDistance);
  var candidate = clampToSafeRect(seatCenter + (direction * projectedDistance));
  if (overlapsSeat(candidate)) {
    candidate = clampToSafeRect(seatCenter + (direction * minDistance));
  }
  if (!overlapsSeat(candidate) && !overlapsAvoidRects(candidate)) {
    return candidate;
  }

  final tangent = Offset(-direction.dy, direction.dx);
  final shiftPx = markerRadiusPx + 6.0;
  for (final sign in <double>[1, -1, 1.5, -1.5, 2, -2]) {
    final shifted = clampToSafeRect(candidate + (tangent * shiftPx * sign));
    if (!overlapsSeat(shifted) && !overlapsAvoidRects(shifted)) {
      return shifted;
    }
  }

  final outwardCandidate = clampToSafeRect(
    seatCenter + (direction * (minDistance + markerRadiusPx + 6.0)),
  );
  if (!overlapsSeat(outwardCandidate) &&
      !overlapsAvoidRects(outwardCandidate)) {
    return outwardCandidate;
  }
  final fallback = clampToSafeRect(seatCenter + (direction * minDistance));
  if (!overlapsSeat(fallback) && !overlapsAvoidRects(fallback)) {
    return fallback;
  }
  return candidate;
}

bool _markerCircleIntersectsRectV1(Offset center, double radius, Rect rect) {
  final nearestX = center.dx.clamp(rect.left, rect.right).toDouble();
  final nearestY = center.dy.clamp(rect.top, rect.bottom).toDouble();
  final dx = center.dx - nearestX;
  final dy = center.dy - nearestY;
  return (dx * dx + dy * dy) <= (radius * radius);
}

class _World1SurfacedTableSceneGeometrySpecV1 {
  static const Offset boardCenter = Offset(0.50, 0.46);
  static const Offset boardCenterLower = Offset(0.50, 0.57);
  static const Offset potCenter = Offset(0.50, 0.32);
  static const Offset heroCardsCenter = Offset(0.50, 0.72);
}
