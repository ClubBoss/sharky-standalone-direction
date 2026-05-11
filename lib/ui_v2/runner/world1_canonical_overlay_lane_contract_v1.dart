import 'dart:math' as math;

import 'package:flutter/material.dart';

class World1CanonicalFeltCaptionBandV1 {
  const World1CanonicalFeltCaptionBandV1({
    required this.captionTop,
    required this.captionLeft,
    required this.captionRight,
    required this.maxCaptionWidth,
  });

  final double captionTop;
  final double captionLeft;
  final double captionRight;
  final double maxCaptionWidth;
}

class World1CanonicalOverlayLaneContractInputV1 {
  const World1CanonicalOverlayLaneContractInputV1({
    required this.canvasSize,
    required this.stadiumRect,
    required this.boardRect,
    required this.potRect,
    required this.heroCardsRect,
    required this.seatAvoidRects,
    required this.boardVisible,
    required this.seatQuizVisualMode,
    required this.handLoopVisualMode,
    required this.demoHandLoopVisualStep,
    required this.compactPortrait,
    required this.seatVisualRadius,
    required this.cueRadius,
    required this.dealerCueCenter,
    required this.sbCueCenter,
    required this.bbCueCenter,
    required this.demoPromptToHeroGap,
    required this.rotatingHeroSeatId,
    required this.promptAffectedStateFamily,
    required this.promptUsesFeltCaptionHost,
  });

  final Size canvasSize;
  final Rect stadiumRect;
  final Rect boardRect;
  final Rect potRect;
  final Rect? heroCardsRect;
  final List<Rect> seatAvoidRects;
  final bool boardVisible;
  final bool seatQuizVisualMode;
  final bool handLoopVisualMode;
  final bool demoHandLoopVisualStep;
  final bool compactPortrait;
  final double seatVisualRadius;
  final double cueRadius;
  final Offset dealerCueCenter;
  final Offset sbCueCenter;
  final Offset bbCueCenter;
  final double demoPromptToHeroGap;
  final String? rotatingHeroSeatId;
  final bool promptAffectedStateFamily;
  final bool promptUsesFeltCaptionHost;
}

class World1CanonicalOverlayLaneContractResolvedV1 {
  const World1CanonicalOverlayLaneContractResolvedV1({
    required this.overlayLaneRect,
    required this.feltCaptionTopInset,
    required this.feltCaptionTop,
    required this.feltCaptionLeft,
    required this.feltCaptionRight,
    required this.feltCaptionMaxWidth,
    required this.feltCaptionMaxHeightAllowance,
    required this.handLoopPromptTopBand,
  });

  final Rect overlayLaneRect;
  final double feltCaptionTopInset;
  final double feltCaptionTop;
  final double feltCaptionLeft;
  final double feltCaptionRight;
  final double feltCaptionMaxWidth;
  final double feltCaptionMaxHeightAllowance;
  final World1CanonicalFeltCaptionBandV1? handLoopPromptTopBand;
}

World1CanonicalOverlayLaneContractResolvedV1
resolveWorld1CanonicalOverlayLaneContractV1(
  World1CanonicalOverlayLaneContractInputV1 input,
) {
  const boardLaneTopInsetPx = 18.0;
  const heroLaneBottomInsetPx = 62.0;
  final overlayLaneTop = math.max(
    input.stadiumRect.top + boardLaneTopInsetPx,
    6.0,
  );
  final overlayLaneBottom = math.min(
    input.stadiumRect.bottom - heroLaneBottomInsetPx,
    input.canvasSize.height - 6.0,
  );
  final overlayLaneRect = Rect.fromLTRB(
    input.stadiumRect.left + 10,
    overlayLaneTop,
    input.stadiumRect.right - 10,
    math.max(overlayLaneTop + 28, overlayLaneBottom),
  );
  final feltCaptionTopInset = input.compactPortrait ? 20.0 : 22.0;
  var feltCaptionDesiredTop = math.max(
    overlayLaneRect.top + feltCaptionTopInset,
    input.stadiumRect.top + 22,
  );
  final demoSeatBandInset =
      input.seatVisualRadius + (input.compactPortrait ? 58.0 : 50.0);
  final demoRotatedPromptWidthFactor =
      input.demoHandLoopVisualStep &&
          input.rotatingHeroSeatId != null &&
          input.rotatingHeroSeatId != 'co'
      ? 0.80
      : 1.0;
  final feltCaptionMaxWidth = input.demoHandLoopVisualStep
      ? math.max(
          180.0,
          math.min(
            (input.stadiumRect.width - (demoSeatBandInset * 2)) *
                demoRotatedPromptWidthFactor,
            input.canvasSize.width - 28,
          ),
        )
      : input.handLoopVisualMode
      ? math.min(input.stadiumRect.width * 0.62, input.canvasSize.width - 32)
      : math.min(input.stadiumRect.width * 0.80, input.canvasSize.width - 28);
  final feltCaptionMaxHeightAllowance = input.compactPortrait ? 52.0 : 56.0;
  final feltCaptionHorizontalInset = math.max(
    0.0,
    (overlayLaneRect.width - feltCaptionMaxWidth) / 2,
  );
  final feltCaptionLeft = overlayLaneRect.left + feltCaptionHorizontalInset;
  final feltCaptionRight = math.min(
    overlayLaneRect.right,
    feltCaptionLeft + feltCaptionMaxWidth,
  );
  final topSeatCircleBottoms =
      input.seatAvoidRects.map((rect) => rect.bottom).toList(growable: false)
        ..sort();
  final topArcBottomPx = topSeatCircleBottoms.isEmpty
      ? overlayLaneRect.top
      : topSeatCircleBottoms
            .take(math.min(3, topSeatCircleBottoms.length))
            .reduce(math.max);
  final captionZonePadPx = input.handLoopVisualMode
      ? (input.compactPortrait ? 24.0 : 20.0)
      : (input.compactPortrait ? 10.0 : 8.0);
  final boardAvoidMarginPx = input.compactPortrait ? 8.0 : 6.0;
  final heroAvoidMarginPx = input.compactPortrait ? 8.0 : 6.0;
  final potAvoidMarginPx = input.compactPortrait ? 6.0 : 5.0;
  final cueAvoidInflatePx = input.handLoopVisualMode
      ? (input.compactPortrait ? 12.0 : 10.0)
      : (input.compactPortrait ? 6.0 : 5.0);

  Rect cueBadgeAvoidRect({
    required Offset center,
    required double markerSize,
    required bool isDealer,
  }) {
    final width = markerSize * (isDealer ? 4.4 : 5.7);
    final height = markerSize * (input.compactPortrait ? 1.95 : 1.85);
    return Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    ).inflate(cueAvoidInflatePx);
  }

  final captionAvoidRects = <Rect>[
    ...input.seatAvoidRects,
    if (input.boardVisible) input.boardRect.inflate(boardAvoidMarginPx),
    if (input.heroCardsRect != null)
      input.heroCardsRect!.inflate(heroAvoidMarginPx),
    if (input.handLoopVisualMode) input.potRect.inflate(potAvoidMarginPx),
    if (input.seatQuizVisualMode)
      cueBadgeAvoidRect(
        center: input.dealerCueCenter,
        markerSize: input.cueRadius * 3.0,
        isDealer: true,
      ),
    if (input.seatQuizVisualMode || input.handLoopVisualMode)
      cueBadgeAvoidRect(
        center: input.sbCueCenter,
        markerSize: input.cueRadius * 3.2,
        isDealer: false,
      ),
    if (input.seatQuizVisualMode || input.handLoopVisualMode)
      cueBadgeAvoidRect(
        center: input.bbCueCenter,
        markerSize: input.cueRadius * 3.2,
        isDealer: false,
      ),
  ];

  double overlapAreaWithAvoidRects(Rect rect) {
    var area = 0.0;
    for (final avoid in captionAvoidRects) {
      if (!rect.overlaps(avoid)) {
        continue;
      }
      final overlap = Rect.fromLTRB(
        math.max(rect.left, avoid.left),
        math.max(rect.top, avoid.top),
        math.min(rect.right, avoid.right),
        math.min(rect.bottom, avoid.bottom),
      );
      if (!overlap.isEmpty) {
        area += overlap.width * overlap.height;
      }
    }
    return area;
  }

  Rect makeCaptionRectForTop(double top) => Rect.fromLTRB(
    feltCaptionLeft,
    top,
    feltCaptionRight,
    top + feltCaptionMaxHeightAllowance,
  );

  final boardAvoidBottom = input.boardVisible
      ? input.boardRect.bottom + captionZonePadPx
      : overlayLaneRect.top + 4;
  final heroAvoidTop = input.heroCardsRect != null
      ? input.heroCardsRect!.top - captionZonePadPx
      : overlayLaneRect.bottom - 4;
  final midZoneTop = math.max(overlayLaneRect.top + 4, boardAvoidBottom);
  final midZoneBottom = math.max(
    midZoneTop,
    math.min(
      overlayLaneRect.bottom - feltCaptionMaxHeightAllowance,
      heroAvoidTop - feltCaptionMaxHeightAllowance,
    ),
  );
  final topSeatBandAvoidBottom = math.max(
    overlayLaneRect.top + 4,
    topArcBottomPx + (input.compactPortrait ? 18.0 : 16.0),
  );
  final demoPromptLaneRect = Rect.fromLTRB(
    feltCaptionLeft,
    math.max(
      math.max(
        overlayLaneRect.top + 4,
        input.boardRect.bottom + captionZonePadPx,
      ),
      topSeatBandAvoidBottom,
    ),
    feltCaptionRight,
    math.max(
      math.max(
        math.max(
          overlayLaneRect.top + 4,
          input.boardRect.bottom + captionZonePadPx,
        ),
        topSeatBandAvoidBottom,
      ),
      (input.heroCardsRect?.top ?? overlayLaneRect.bottom) -
          input.demoPromptToHeroGap,
    ),
  );
  final bottomAnchorTop = input.heroCardsRect != null
      ? input.heroCardsRect!.top -
            captionZonePadPx -
            feltCaptionMaxHeightAllowance
      : overlayLaneRect.bottom - feltCaptionMaxHeightAllowance - 4;
  final bottomZoneTop = math.max(overlayLaneRect.top + 4, bottomAnchorTop);
  final bottomZoneBottom = math.max(
    bottomZoneTop,
    overlayLaneRect.bottom - feltCaptionMaxHeightAllowance,
  );

  final handLoopPromptTopBand =
      input.promptAffectedStateFamily && input.promptUsesFeltCaptionHost
      ? () {
          final renderedCueAvoidRects = <Rect>[
            cueBadgeAvoidRect(
              center: input.sbCueCenter,
              markerSize: input.cueRadius * 3.2,
              isDealer: false,
            ),
            cueBadgeAvoidRect(
              center: input.bbCueCenter,
              markerSize: input.cueRadius * 3.2,
              isDealer: false,
            ),
          ];
          final topBandOccupiedBottom = <double>[
            topArcBottomPx,
            for (final rect in renderedCueAvoidRects) rect.bottom,
          ].reduce(math.max);
          final minCaptionTop = math.max(
            overlayLaneRect.top + 4,
            topBandOccupiedBottom + (input.compactPortrait ? 12.0 : 10.0),
          );
          final maxCaptionTop = math.max(
            minCaptionTop,
            math.min(
              overlayLaneRect.bottom - feltCaptionMaxHeightAllowance,
              math.min(
                input.boardRect.top -
                    feltCaptionMaxHeightAllowance -
                    (input.compactPortrait ? 16.0 : 12.0),
                input.potRect.top -
                    feltCaptionMaxHeightAllowance -
                    (input.compactPortrait ? 12.0 : 10.0),
              ),
            ),
          );
          return World1CanonicalFeltCaptionBandV1(
            captionTop: maxCaptionTop
                .clamp(minCaptionTop, maxCaptionTop)
                .toDouble(),
            captionLeft: feltCaptionLeft,
            captionRight: feltCaptionRight,
            maxCaptionWidth: feltCaptionMaxWidth,
          );
        }()
      : null;

  final captionZoneCandidates = input.demoHandLoopVisualStep
      ? <({double top, double bottom})>[
          (top: bottomZoneTop, bottom: bottomZoneBottom),
        ]
      : handLoopPromptTopBand != null
      ? <({double top, double bottom})>[
          (
            top: handLoopPromptTopBand.captionTop,
            bottom: handLoopPromptTopBand.captionTop,
          ),
        ]
      : <({double top, double bottom})>[
          (top: midZoneTop, bottom: midZoneBottom),
        ];

  var bestCaptionRect = makeCaptionRectForTop(feltCaptionDesiredTop);
  var bestCaptionOverlapArea = double.infinity;
  var bestCaptionZoneTop = overlayLaneRect.top + 4;
  var firstZeroOverlapFound = false;
  for (final zone in captionZoneCandidates) {
    final zoneTop = zone.top;
    final zoneBottom = math.max(zone.top, zone.bottom);
    final clampedTop = feltCaptionDesiredTop.clamp(zoneTop, zoneBottom);
    var candidateRect = makeCaptionRectForTop(clampedTop);
    var overlapArea = overlapAreaWithAvoidRects(candidateRect);
    if (overlapArea > 0) {
      final pushedTop =
          (candidateRect.top + (input.compactPortrait ? 10.0 : 8.0)).clamp(
            zoneTop,
            zoneBottom,
          );
      final pushedRect = makeCaptionRectForTop(pushedTop);
      final pushedOverlapArea = overlapAreaWithAvoidRects(pushedRect);
      if (pushedOverlapArea <= overlapArea) {
        candidateRect = pushedRect;
        overlapArea = pushedOverlapArea;
      }
    }
    if (overlapArea <= 0) {
      bestCaptionRect = candidateRect;
      bestCaptionOverlapArea = 0;
      bestCaptionZoneTop = zoneTop;
      firstZeroOverlapFound = true;
      break;
    }
    if (overlapArea < bestCaptionOverlapArea) {
      bestCaptionRect = candidateRect;
      bestCaptionOverlapArea = overlapArea;
      bestCaptionZoneTop = zoneTop;
    }
  }

  var feltCaptionTop = handLoopPromptTopBand != null
      ? handLoopPromptTopBand.captionTop
      : input.demoHandLoopVisualStep
      ? (math.min(
                  math.max(
                    demoPromptLaneRect.top,
                    input.boardRect.bottom + captionZonePadPx,
                  ),
                  math.max(
                    demoPromptLaneRect.top,
                    (input.heroCardsRect?.top ?? overlayLaneRect.bottom) -
                        input.demoPromptToHeroGap -
                        feltCaptionMaxHeightAllowance,
                  ),
                ) -
                (input.compactPortrait ? 4.0 : 3.0))
            .toDouble()
      : bestCaptionRect.top;
  if (!input.demoHandLoopVisualStep &&
      handLoopPromptTopBand == null &&
      !firstZeroOverlapFound &&
      bestCaptionOverlapArea > 0) {
    final bestCaptionZoneMaxTop = math.max(
      bestCaptionZoneTop,
      overlayLaneRect.bottom - feltCaptionMaxHeightAllowance,
    );
    feltCaptionTop = (feltCaptionTop + (input.compactPortrait ? 8.0 : 6.0))
        .clamp(bestCaptionZoneTop, bestCaptionZoneMaxTop)
        .toDouble();
  }
  final feltCaptionMaxTop = math.max(
    overlayLaneRect.top + 4,
    overlayLaneRect.bottom - feltCaptionMaxHeightAllowance,
  );
  feltCaptionTop = feltCaptionTop
      .clamp(overlayLaneRect.top + 4, feltCaptionMaxTop)
      .toDouble();
  if (input.demoHandLoopVisualStep && input.heroCardsRect != null) {
    final demoMaxTopByHero =
        input.heroCardsRect!.top -
        input.demoPromptToHeroGap -
        feltCaptionMaxHeightAllowance;
    feltCaptionTop = math
        .min(feltCaptionTop, demoMaxTopByHero)
        .clamp(overlayLaneRect.top + 4, feltCaptionMaxTop)
        .toDouble();
  }
  if (!input.demoHandLoopVisualStep &&
      input.handLoopVisualMode &&
      handLoopPromptTopBand == null) {
    final handLoopMaxTop = math.max(
      overlayLaneRect.top + 4,
      input.boardRect.top -
          feltCaptionMaxHeightAllowance -
          (input.compactPortrait ? 14.0 : 10.0),
    );
    feltCaptionTop = math.min(feltCaptionTop, handLoopMaxTop);
  }

  return World1CanonicalOverlayLaneContractResolvedV1(
    overlayLaneRect: overlayLaneRect,
    feltCaptionTopInset: feltCaptionTopInset,
    feltCaptionTop: feltCaptionTop,
    feltCaptionLeft: feltCaptionLeft,
    feltCaptionRight: feltCaptionRight,
    feltCaptionMaxWidth: feltCaptionMaxWidth,
    feltCaptionMaxHeightAllowance: feltCaptionMaxHeightAllowance,
    handLoopPromptTopBand: handLoopPromptTopBand,
  );
}
