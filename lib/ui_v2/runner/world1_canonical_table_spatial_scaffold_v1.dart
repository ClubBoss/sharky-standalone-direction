import 'dart:math' as math;

import 'package:flutter/material.dart';

class World1CanonicalTableSpatialScaffoldInputV1 {
  const World1CanonicalTableSpatialScaffoldInputV1({
    required this.canvasSize,
    required this.portraitLayout,
    required this.seatIds,
    required this.selectedVisualSeatId,
    required this.targetSeatId,
    required this.demoHandLoopVisualStep,
    required this.heroSeatId,
  });

  final Size canvasSize;
  final bool portraitLayout;
  final List<String> seatIds;
  final String? selectedVisualSeatId;
  final String? targetSeatId;
  final bool demoHandLoopVisualStep;
  final String? heroSeatId;
}

class World1CanonicalTableSpatialGeomV1 {
  const World1CanonicalTableSpatialGeomV1({
    required this.center,
    required this.clusterWidth,
    required this.clusterHeight,
    required this.xRadius,
    required this.yRadius,
    required this.seatRadiusX,
    required this.seatRadiusY,
    required this.rimThickness,
    required this.innerInset,
  });

  factory World1CanonicalTableSpatialGeomV1.fromLayout({
    required Size canvasSize,
    required Size clusterSize,
    required double rimThickness,
    required double innerInset,
    required double seatEdgeInset,
  }) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final resolvedClusterWidth = clusterSize.width.clamp(0.0, canvasSize.width);
    final resolvedClusterHeight = clusterSize.height.clamp(
      0.0,
      canvasSize.height,
    );
    final xRadius = (resolvedClusterWidth / 2).clamp(0.0, canvasSize.width / 2);
    final ovalYRadius = (resolvedClusterHeight / 2).clamp(
      0.0,
      canvasSize.height / 2,
    );
    final seatRadiusX = (xRadius - seatEdgeInset - 2).clamp(0.0, xRadius);
    final seatRadiusY = (ovalYRadius - seatEdgeInset - 2).clamp(
      0.0,
      ovalYRadius,
    );
    return World1CanonicalTableSpatialGeomV1(
      center: center,
      clusterWidth: resolvedClusterWidth,
      clusterHeight: resolvedClusterHeight,
      xRadius: xRadius,
      yRadius: ovalYRadius,
      seatRadiusX: seatRadiusX,
      seatRadiusY: seatRadiusY,
      rimThickness: rimThickness,
      innerInset: innerInset,
    );
  }

  final Offset center;
  final double clusterWidth;
  final double clusterHeight;
  final double xRadius;
  final double yRadius;
  final double seatRadiusX;
  final double seatRadiusY;
  final double rimThickness;
  final double innerInset;
}

class World1CanonicalTableSpatialScaffoldResolvedV1 {
  const World1CanonicalTableSpatialScaffoldResolvedV1({
    required this.compactPhone,
    required this.ultraCompactPortrait,
    required this.seatSize,
    required this.tableViewportWidthFactor,
    required this.tableViewportHeightFactor,
    required this.portraitCenterDyFactor,
    required this.tableCenter,
    required this.geometry,
    required this.tableShellRect,
    required this.stadiumRect,
    required this.nonOverlappingSeatSize,
    required this.seatEdgeInset,
    required this.seatRingOrder,
    required this.seatRenderOrderIds,
    required this.seatCentersById,
    required this.rotatingHeroSeatId,
    required this.targetSeatCenter,
    required this.btnCenter,
    required this.sbCenter,
    required this.bbCenter,
  });

  final bool compactPhone;
  final bool ultraCompactPortrait;
  final double seatSize;
  final double tableViewportWidthFactor;
  final double tableViewportHeightFactor;
  final double portraitCenterDyFactor;
  final Offset tableCenter;
  final World1CanonicalTableSpatialGeomV1 geometry;
  final Rect tableShellRect;
  final Rect stadiumRect;
  final double nonOverlappingSeatSize;
  final double seatEdgeInset;
  final List<String> seatRingOrder;
  final List<String> seatRenderOrderIds;
  final Map<String, Offset> seatCentersById;
  final String? rotatingHeroSeatId;
  final Offset? targetSeatCenter;
  final Offset btnCenter;
  final Offset sbCenter;
  final Offset bbCenter;

  bool get canRotateSeatDisplay =>
      rotatingHeroSeatId != null && seatRingOrder.contains(rotatingHeroSeatId);

  double get seatVisualRadius => nonOverlappingSeatSize / 2;

  Offset resolvePointOnStadium({
    required Offset normalized,
    required double safeInset,
  }) {
    final rawX = stadiumRect.left + (stadiumRect.width * normalized.dx);
    final rawY = stadiumRect.top + (stadiumRect.height * normalized.dy);
    final minX = math.max(safeInset, stadiumRect.left + safeInset);
    final maxX = math.min(
      geometry.center.dx * 2 - safeInset,
      stadiumRect.right - safeInset,
    );
    final minY = math.max(safeInset, stadiumRect.top + safeInset);
    final maxY = math.min(
      geometry.center.dy * 2 - safeInset,
      stadiumRect.bottom - safeInset,
    );
    final resolvedX = maxX < minX
        ? tableCenter.dx
        : rawX.clamp(minX, maxX).toDouble();
    final resolvedY = maxY < minY
        ? tableCenter.dy
        : rawY.clamp(minY, maxY).toDouble();
    return Offset(resolvedX, resolvedY);
  }

  Alignment alignmentForPoint(Offset point) {
    final width = geometry.center.dx * 2;
    final height = geometry.center.dy * 2;
    if (width <= 0 || height <= 0) {
      return Alignment.center;
    }
    final normalizedX = point.dx / width;
    final normalizedY = point.dy / height;
    return Alignment((normalizedX * 2) - 1, (normalizedY * 2) - 1);
  }

  Offset resolveSeatCenter(String seatId) =>
      seatCentersById[seatId] ?? tableCenter;

  String displaySeatIdForLogical(String logicalSeatId) {
    if (!canRotateSeatDisplay) {
      return logicalSeatId;
    }
    return _rotateSeatIdForDisplayV1(
      logicalSeatId: logicalSeatId,
      heroSeatId: rotatingHeroSeatId,
      bottomAnchorSeatId: 'btn',
      ring: seatRingOrder,
    );
  }

  String logicalSeatIdForDisplay(String displaySeatId) {
    if (!canRotateSeatDisplay) {
      return displaySeatId;
    }
    return _rotateSeatIdForLogicalFromDisplayV1(
      displaySeatId: displaySeatId,
      heroSeatId: rotatingHeroSeatId,
      bottomAnchorSeatId: 'btn',
      ring: seatRingOrder,
    );
  }
}

List<String> resolveWorld1CanonicalSeatRingOrderV1(Iterable<String> seatIds) {
  final normalizedSeatIds = seatIds
      .map(_normalizeSeatIdV1)
      .whereType<String>()
      .toSet();
  final ordered = _canonicalSeatRenderOrderV1
      .where(normalizedSeatIds.contains)
      .toList(growable: true);
  final extras =
      normalizedSeatIds
          .where((seatId) => !ordered.contains(seatId))
          .toList(growable: false)
        ..sort();
  ordered.addAll(extras);
  return ordered;
}

String describeWorld1CanonicalSeatForLearnerV1(
  String seatId, {
  bool includeDealerSuffix = false,
}) {
  final normalized = seatId.trim().toLowerCase();
  return switch (normalized) {
    'btn' => includeDealerSuffix ? 'Button (Dealer)' : 'Button',
    'sb' => 'Small Blind',
    'bb' => 'Big Blind',
    'utg' => 'UTG',
    'utg1' => 'UTG+1',
    'mp' => 'Middle Position',
    'mp1' => 'MP+1',
    'hj' => 'Hijack',
    'co' => 'Cutoff',
    'lj' => 'Lojack',
    _ => normalized.toUpperCase(),
  };
}

String buildWorld1CanonicalSeatOrderHintV1(Iterable<String> seatIds) {
  final orderedLabels = resolveWorld1CanonicalSeatRingOrderV1(
    seatIds,
  ).map(describeWorld1CanonicalSeatForLearnerV1).toList(growable: false);
  return 'Order: ${orderedLabels.join(' -> ')}.';
}

String? resolveWorld1CanonicalSeatOrderBadgeTextV1(
  String seatId,
  Iterable<String> seatIds,
) {
  final normalizedSeatId = _normalizeSeatIdV1(seatId);
  if (normalizedSeatId == null) {
    return null;
  }
  final orderedSeatIds = resolveWorld1CanonicalSeatRingOrderV1(seatIds);
  final seatIndex = orderedSeatIds.indexOf(normalizedSeatId);
  if (seatIndex == -1) {
    return null;
  }
  final learnerLabel = describeWorld1CanonicalSeatForLearnerV1(
    normalizedSeatId,
  );
  return '${seatIndex + 1} $learnerLabel';
}

World1CanonicalTableSpatialScaffoldResolvedV1
resolveWorld1CanonicalTableSpatialScaffoldV1(
  World1CanonicalTableSpatialScaffoldInputV1 input,
) {
  final compactPhone =
      input.canvasSize.width < 430 || input.canvasSize.height < 340;
  final ultraCompactPortrait =
      input.canvasSize.width <= 380 && input.canvasSize.height <= 320;
  final seatSize = compactPhone
      ? (ultraCompactPortrait ? 44.0 : 48.0)
      : (input.canvasSize.width < 480 ? 56.0 : 64.0);
  const portraitStadiumWidthScaleV1 = 1.22;
  const portraitStadiumHeightScaleV1 = 1.36;
  final tableViewportWidthFactor = input.portraitLayout
      ? 0.98
      : (ultraCompactPortrait ? 0.8 : 0.76);
  final tableViewportHeightFactor = input.portraitLayout
      ? (ultraCompactPortrait ? 0.78 : 0.86)
      : (ultraCompactPortrait ? 0.52 : 0.56);
  final portraitCenterDyFactor = input.portraitLayout
      ? (ultraCompactPortrait ? 0.49 : 0.48)
      : 0.50;
  final tableClusterSize = Size(
    input.canvasSize.width *
        _World1CanonicalTableSpatialSpecV1.stadiumWidth *
        (input.portraitLayout ? portraitStadiumWidthScaleV1 : 1.0),
    input.canvasSize.height *
        _World1CanonicalTableSpatialSpecV1.stadiumHeight *
        (input.portraitLayout ? portraitStadiumHeightScaleV1 : 1.0),
  );
  final tableCenter = Offset(
    input.canvasSize.width / 2,
    input.canvasSize.height * portraitCenterDyFactor,
  );
  final geometry = World1CanonicalTableSpatialGeomV1.fromLayout(
    canvasSize: input.canvasSize,
    clusterSize: tableClusterSize,
    rimThickness: compactPhone ? 6.0 : 7.0,
    innerInset: compactPhone ? 6.0 : 7.0,
    seatEdgeInset: (seatSize / 2) + 2.0,
  );
  final tableShellRect = Rect.fromCenter(
    center: tableCenter,
    width: geometry.clusterWidth,
    height: geometry.clusterHeight,
  );
  final stadiumRect = Rect.fromCenter(
    center: Offset(
      input.canvasSize.width *
          _World1CanonicalTableSpatialSpecV1.stadiumCenter.dx,
      input.canvasSize.height * portraitCenterDyFactor,
    ),
    width: geometry.clusterWidth,
    height: geometry.clusterHeight,
  );

  Offset resolvePointOnStadium({
    required Offset normalized,
    required double safeInset,
  }) {
    final rawX = stadiumRect.left + (stadiumRect.width * normalized.dx);
    final rawY = stadiumRect.top + (stadiumRect.height * normalized.dy);
    final minX = math.max(safeInset, stadiumRect.left + safeInset);
    final maxX = math.min(
      input.canvasSize.width - safeInset,
      stadiumRect.right - safeInset,
    );
    final minY = math.max(safeInset, stadiumRect.top + safeInset);
    final maxY = math.min(
      input.canvasSize.height - safeInset,
      stadiumRect.bottom - safeInset,
    );
    final resolvedX = maxX < minX
        ? tableCenter.dx
        : rawX.clamp(minX, maxX).toDouble();
    final resolvedY = maxY < minY
        ? tableCenter.dy
        : rawY.clamp(minY, maxY).toDouble();
    return Offset(resolvedX, resolvedY);
  }

  final provisionalEdgeInset = (seatSize / 2) + 2.0;
  final provisionalAnchorMap =
      _World1CanonicalTableSpatialSpecV1.seatAnchorByIdForCountV1(
        input.seatIds.length,
      );
  final provisionalSeatCenters = input.seatIds
      .map(
        (seatId) => resolvePointOnStadium(
          normalized:
              provisionalAnchorMap[seatId] ??
              _World1CanonicalTableSpatialSpecV1.stadiumCenter,
          safeInset: provisionalEdgeInset,
        ),
      )
      .toList(growable: false);
  var minCenterDistance = double.infinity;
  for (var i = 0; i < provisionalSeatCenters.length; i++) {
    for (var j = i + 1; j < provisionalSeatCenters.length; j++) {
      final distance =
          (provisionalSeatCenters[i] - provisionalSeatCenters[j]).distance;
      if (distance < minCenterDistance) {
        minCenterDistance = distance;
      }
    }
  }
  final nonOverlappingSeatSize =
      (minCenterDistance.isFinite ? (minCenterDistance - 1.0) : seatSize).clamp(
        44.0,
        seatSize,
      );
  final seatEdgeInset = (nonOverlappingSeatSize / 2) + 2.0;
  final anchorMap = _World1CanonicalTableSpatialSpecV1.seatAnchorByIdForCountV1(
    input.seatIds.length,
  );
  final seatCentersById = <String, Offset>{
    for (final seatId in input.seatIds)
      seatId: resolvePointOnStadium(
        normalized:
            anchorMap[seatId] ??
            _World1CanonicalTableSpatialSpecV1.stadiumCenter,
        safeInset: seatEdgeInset,
      ),
  };
  final seatRingOrder = resolveWorld1CanonicalSeatRingOrderV1(input.seatIds);
  final canonicalSeatRenderIndexV1 = <String, int>{
    for (var i = 0; i < seatRingOrder.length; i++) seatRingOrder[i]: i,
  };
  final seatRenderOrderIds = List<String>.from(input.seatIds)
    ..sort((a, b) {
      final aSelected = input.selectedVisualSeatId == a;
      final bSelected = input.selectedVisualSeatId == b;
      if (aSelected != bSelected) {
        return aSelected ? 1 : -1;
      }
      final aIndex = canonicalSeatRenderIndexV1[a] ?? 1 << 20;
      final bIndex = canonicalSeatRenderIndexV1[b] ?? 1 << 20;
      final byIndex = aIndex.compareTo(bIndex);
      if (byIndex != 0) {
        return byIndex;
      }
      return a.compareTo(b);
    });
  final rotatingHeroSeatId = input.demoHandLoopVisualStep
      ? _normalizeSeatIdV1(input.heroSeatId)
      : null;

  String displaySeatIdForLogical(String logicalSeatId) {
    if (rotatingHeroSeatId == null ||
        !seatRingOrder.contains(rotatingHeroSeatId)) {
      return logicalSeatId;
    }
    return _rotateSeatIdForDisplayV1(
      logicalSeatId: logicalSeatId,
      heroSeatId: rotatingHeroSeatId,
      bottomAnchorSeatId: 'btn',
      ring: seatRingOrder,
    );
  }

  final targetSeatCenter = input.targetSeatId == null
      ? null
      : seatCentersById[input.targetSeatId!];

  return World1CanonicalTableSpatialScaffoldResolvedV1(
    compactPhone: compactPhone,
    ultraCompactPortrait: ultraCompactPortrait,
    seatSize: seatSize,
    tableViewportWidthFactor: tableViewportWidthFactor,
    tableViewportHeightFactor: tableViewportHeightFactor,
    portraitCenterDyFactor: portraitCenterDyFactor,
    tableCenter: tableCenter,
    geometry: geometry,
    tableShellRect: tableShellRect,
    stadiumRect: stadiumRect,
    nonOverlappingSeatSize: nonOverlappingSeatSize,
    seatEdgeInset: seatEdgeInset,
    seatRingOrder: seatRingOrder,
    seatRenderOrderIds: seatRenderOrderIds,
    seatCentersById: seatCentersById,
    rotatingHeroSeatId: rotatingHeroSeatId,
    targetSeatCenter: targetSeatCenter,
    btnCenter: seatCentersById[displaySeatIdForLogical('btn')] ?? tableCenter,
    sbCenter: seatCentersById[displaySeatIdForLogical('sb')] ?? tableCenter,
    bbCenter: seatCentersById[displaySeatIdForLogical('bb')] ?? tableCenter,
  );
}

const List<String> _canonicalSeatRenderOrderV1 = <String>[
  'btn',
  'sb',
  'bb',
  'utg',
  'utg1',
  'mp',
  'mp1',
  'lj',
  'hj',
  'co',
];

String? _normalizeSeatIdV1(String? raw) {
  if (raw == null) {
    return null;
  }
  final normalized = raw.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }
  if (_World1CanonicalTableSpatialSpecV1.seatAnchorById.containsKey(
    normalized,
  )) {
    return normalized;
  }
  return null;
}

String _rotateSeatIdForDisplayV1({
  required String logicalSeatId,
  required String? heroSeatId,
  required String bottomAnchorSeatId,
  required List<String> ring,
}) {
  if (heroSeatId == null) {
    return logicalSeatId;
  }
  final logicalIndex = ring.indexOf(logicalSeatId);
  final heroIndex = ring.indexOf(heroSeatId);
  final bottomIndex = ring.indexOf(bottomAnchorSeatId);
  if (logicalIndex == -1 || heroIndex == -1 || bottomIndex == -1) {
    return logicalSeatId;
  }
  final delta = (bottomIndex - heroIndex) % ring.length;
  return ring[(logicalIndex + delta) % ring.length];
}

String _rotateSeatIdForLogicalFromDisplayV1({
  required String displaySeatId,
  required String? heroSeatId,
  required String bottomAnchorSeatId,
  required List<String> ring,
}) {
  if (heroSeatId == null) {
    return displaySeatId;
  }
  final displayIndex = ring.indexOf(displaySeatId);
  final heroIndex = ring.indexOf(heroSeatId);
  final bottomIndex = ring.indexOf(bottomAnchorSeatId);
  if (displayIndex == -1 || heroIndex == -1 || bottomIndex == -1) {
    return displaySeatId;
  }
  final delta = (bottomIndex - heroIndex) % ring.length;
  return ring[(displayIndex - delta + ring.length) % ring.length];
}

class _World1CanonicalTableSpatialSpecV1 {
  static const Offset stadiumCenter = Offset(0.50, 0.50);
  static const double stadiumWidth = 0.68;
  static const double stadiumHeight = 0.86;
  static const Map<String, Offset> seatAnchorById = <String, Offset>{
    'btn': Offset(0.50, 0.93),
    'sb': Offset(0.84, 0.70),
    'bb': Offset(0.84, 0.30),
    'utg': Offset(0.50, 0.07),
    'hj': Offset(0.16, 0.30),
    'co': Offset(0.16, 0.70),
    'utg1': Offset(0.28, 0.16),
    'mp': Offset(0.12, 0.42),
    'mp1': Offset(0.28, 0.84),
    'lj': Offset(0.72, 0.16),
  };

  static Map<String, Offset> seatAnchorByIdForCountV1(int seatCount) {
    if (seatCount >= 9) {
      return const <String, Offset>{
        'btn': Offset(0.50, 0.93),
        'sb': Offset(0.84, 0.70),
        'bb': Offset(0.84, 0.30),
        'utg': Offset(0.72, 0.16),
        'utg1': Offset(0.50, 0.07),
        'mp': Offset(0.28, 0.16),
        'mp1': Offset(0.16, 0.30),
        'lj': Offset(0.12, 0.42),
        'hj': Offset(0.16, 0.70),
        'co': Offset(0.28, 0.84),
      };
    }
    return seatAnchorById;
  }
}
