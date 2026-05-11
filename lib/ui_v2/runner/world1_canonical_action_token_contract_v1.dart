import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_marker_contract_v1.dart';

enum World1CanonicalActionTokenBodyKindV1 { hidden, demoRow, placedMarker }

class World1CanonicalActionTokenContractInputV1 {
  const World1CanonicalActionTokenContractInputV1({
    required this.handLoopVisualMode,
    required this.demoHandLoopVisualStep,
    required this.compactPhone,
    required this.tableCenter,
    required this.stadiumSafeRect,
    required this.actingSeatCenter,
    required this.betOwnerSeatCenter,
    required this.boardRect,
    required this.potRect,
    required this.heroCardsRect,
    required this.heroCenterPoint,
    required this.overlayLaneBottom,
    required this.demoHeroToTokenGap,
    required this.currentBet,
  });

  final bool handLoopVisualMode;
  final bool demoHandLoopVisualStep;
  final bool compactPhone;
  final Rect stadiumSafeRect;
  final Offset tableCenter;
  final Offset actingSeatCenter;
  final Offset betOwnerSeatCenter;
  final Rect boardRect;
  final Rect potRect;
  final Rect? heroCardsRect;
  final Offset heroCenterPoint;
  final double overlayLaneBottom;
  final double demoHeroToTokenGap;
  final int currentBet;
}

class World1CanonicalActionTokenContractResolvedV1 {
  const World1CanonicalActionTokenContractResolvedV1({
    required this.bodyKind,
    required this.glowCenter,
    required this.glowRadius,
    required this.betCenter,
    required this.demoRowLeft,
    required this.demoRowTop,
    required this.markerContract,
    required this.demoChipSize,
    required this.demoRowKey,
  });

  final World1CanonicalActionTokenBodyKindV1 bodyKind;
  final Offset? glowCenter;
  final double glowRadius;
  final Offset? betCenter;
  final double demoRowLeft;
  final double demoRowTop;
  final World1CanonicalTableMarkerContractV1? markerContract;
  final double demoChipSize;
  final Key demoRowKey;

  bool get isVisible => bodyKind != World1CanonicalActionTokenBodyKindV1.hidden;
}

World1CanonicalActionTokenContractResolvedV1
resolveWorld1CanonicalActionTokenContractV1(
  World1CanonicalActionTokenContractInputV1 input,
) {
  if (!input.handLoopVisualMode) {
    return const World1CanonicalActionTokenContractResolvedV1(
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
  }

  final tokenRadius = input.compactPhone ? 11.5 : 13.0;
  final avoidRects = <Rect>[
    input.boardRect,
    input.potRect,
    if (input.heroCardsRect != null) input.heroCardsRect!,
  ];
  final tokenGap = input.compactPhone ? 12.0 : 14.0;
  final demoTokenMarkerSizeV1 = tokenRadius * 2.9;
  final heroLaneTopV1 =
      (input.heroCardsRect?.bottom ?? input.heroCenterPoint.dy) +
      input.demoHeroToTokenGap;
  final heroLaneBottomV1 =
      input.overlayLaneBottom - (input.compactPhone ? 10.0 : 12.0);
  final minDemoTokenCenterYV1 = heroLaneTopV1 + (demoTokenMarkerSizeV1 / 2);
  final maxDemoTokenCenterYV1 = math.max(
    minDemoTokenCenterYV1,
    heroLaneBottomV1 - (demoTokenMarkerSizeV1 / 2),
  );
  final demoTokenYV1 = minDemoTokenCenterYV1
      .clamp(minDemoTokenCenterYV1, maxDemoTokenCenterYV1)
      .toDouble();
  final anchorCenter = input.demoHandLoopVisualStep
      ? Offset(input.heroCenterPoint.dx, demoTokenYV1)
      : _resolveFeltTokenCenterV1(
          seatCenter: input.actingSeatCenter,
          markerRadius: tokenRadius,
          avoidRects: avoidRects,
          tableCenter: input.tableCenter,
          canvasSafeRect: input.stadiumSafeRect,
          compactPhone: input.compactPhone,
        );
  final betAnchorCenter = input.demoHandLoopVisualStep
      ? anchorCenter
      : _resolveFeltTokenCenterV1(
          seatCenter: input.betOwnerSeatCenter,
          markerRadius: tokenRadius,
          avoidRects: avoidRects,
          tableCenter: input.tableCenter,
          canvasSafeRect: input.stadiumSafeRect,
          compactPhone: input.compactPhone,
        );
  final betInward = input.tableCenter - input.betOwnerSeatCenter;
  final betInwardMag = betInward.distance;
  final betTangent = input.demoHandLoopVisualStep
      ? const Offset(1, 0)
      : (betInwardMag <= 0.01
            ? const Offset(1, 0)
            : Offset(
                -(betInward.dy / betInwardMag),
                betInward.dx / betInwardMag,
              ));
  final betCenter = input.demoHandLoopVisualStep
      ? Offset(anchorCenter.dx + tokenGap, anchorCenter.dy)
      : _resolveFeltTokenCenterV1(
          seatCenter: betAnchorCenter + (betTangent * tokenGap),
          markerRadius: tokenRadius,
          avoidRects: avoidRects,
          tableCenter: input.tableCenter,
          canvasSafeRect: input.stadiumSafeRect,
          compactPhone: input.compactPhone,
          towardFactor: 0.06,
        );
  final markerContract = World1CanonicalTableMarkerContractV1(
    kind: World1CanonicalTableMarkerKindV1.bb,
    label: 'BET',
    amount: input.currentBet,
    size: tokenRadius * 3.2,
    compactStack: input.compactPhone,
  );
  final demoRowLeftV1 =
      anchorCenter.dx - (((demoTokenMarkerSizeV1 * 2.4) + tokenGap) / 2);
  final demoRowTopV1 = anchorCenter.dy - (demoTokenMarkerSizeV1 / 2);
  return World1CanonicalActionTokenContractResolvedV1(
    bodyKind: input.demoHandLoopVisualStep
        ? World1CanonicalActionTokenBodyKindV1.demoRow
        : World1CanonicalActionTokenBodyKindV1.placedMarker,
    glowCenter: betCenter,
    glowRadius: tokenRadius * 1.9,
    betCenter: betCenter,
    demoRowLeft: demoRowLeftV1,
    demoRowTop: demoRowTopV1,
    markerContract: markerContract,
    demoChipSize: demoTokenMarkerSizeV1 * 0.34,
    demoRowKey: const Key('microtask_demo_token_row_v1'),
  );
}

List<Widget> buildWorld1CanonicalActionTokenBodiesV1({
  required World1CanonicalActionTokenContractResolvedV1 contract,
}) {
  switch (contract.bodyKind) {
    case World1CanonicalActionTokenBodyKindV1.hidden:
      return const <Widget>[];
    case World1CanonicalActionTokenBodyKindV1.demoRow:
      return <Widget>[
        Positioned(
          left: contract.demoRowLeft,
          top: contract.demoRowTop,
          child: IgnorePointer(
            child: KeyedSubtree(
              key: contract.demoRowKey,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildWorld1CanonicalChipStackBadgeV1(
                    label: 'BET',
                    amount: contract.markerContract?.amount ?? 0,
                    chipSize: contract.demoChipSize,
                    compact: true,
                    backgroundOpacity: 0.9,
                    stackLayers:
                        (contract.markerContract?.compactStack ?? false)
                        ? 1
                        : 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    case World1CanonicalActionTokenBodyKindV1.placedMarker:
      if (contract.betCenter == null || contract.markerContract == null) {
        return const <Widget>[];
      }
      return <Widget>[
        buildWorld1CanonicalTableMarkerBodyV1(
          center: contract.betCenter!,
          contract: contract.markerContract!,
        ),
      ];
  }
}

Offset _resolveFeltTokenCenterV1({
  required Offset seatCenter,
  required double markerRadius,
  required List<Rect> avoidRects,
  required Offset tableCenter,
  required Rect canvasSafeRect,
  required bool compactPhone,
  double towardFactor = 0.24,
}) {
  final toward = tableCenter - seatCenter;
  final towardMag = toward.distance;
  if (towardMag <= 0.01) {
    return _clampMarkerCenterV1(
      center: seatCenter,
      markerRadius: markerRadius,
      canvasSafeRect: canvasSafeRect,
      fallbackCenter: tableCenter,
    );
  }
  final projected = _clampMarkerCenterV1(
    center: seatCenter + (toward / towardMag) * (towardMag * towardFactor),
    markerRadius: markerRadius,
    canvasSafeRect: canvasSafeRect,
    fallbackCenter: tableCenter,
  );
  bool intersectsAny(Offset center) {
    for (final rect in avoidRects) {
      if (_markerCircleIntersectsRectV1(center, markerRadius + 1.2, rect)) {
        return true;
      }
    }
    return false;
  }

  if (!intersectsAny(projected)) {
    return projected;
  }
  final direction = toward / towardMag;
  final tangent = Offset(-direction.dy, direction.dx);
  final shift = (canvasSafeRect.width * (compactPhone ? 0.045 : 0.055))
      .clamp(12.0, 48.0)
      .toDouble();
  for (final sign in <double>[1, -1, 1.5, -1.5]) {
    final candidate = _clampMarkerCenterV1(
      center: projected + tangent * shift * sign,
      markerRadius: markerRadius,
      canvasSafeRect: canvasSafeRect,
      fallbackCenter: tableCenter,
    );
    if (!intersectsAny(candidate)) {
      return candidate;
    }
  }
  return projected;
}

Offset _clampMarkerCenterV1({
  required Offset center,
  required double markerRadius,
  required Rect canvasSafeRect,
  required Offset fallbackCenter,
}) {
  final minX = math.max(canvasSafeRect.left, markerRadius + 1);
  final maxX = math.min(
    canvasSafeRect.right,
    canvasSafeRect.right - markerRadius - 1,
  );
  final minY = math.max(canvasSafeRect.top, markerRadius + 1);
  final maxY = math.min(
    canvasSafeRect.bottom,
    canvasSafeRect.bottom - markerRadius - 1,
  );
  final resolvedX = maxX < minX
      ? fallbackCenter.dx
      : center.dx.clamp(minX, maxX).toDouble();
  final resolvedY = maxY < minY
      ? fallbackCenter.dy
      : center.dy.clamp(minY, maxY).toDouble();
  return Offset(resolvedX, resolvedY);
}

bool _markerCircleIntersectsRectV1(Offset center, double radius, Rect rect) {
  final nearestX = center.dx.clamp(rect.left, rect.right).toDouble();
  final nearestY = center.dy.clamp(rect.top, rect.bottom).toDouble();
  final dx = center.dx - nearestX;
  final dy = center.dy - nearestY;
  return (dx * dx + dy * dy) <= (radius * radius);
}
