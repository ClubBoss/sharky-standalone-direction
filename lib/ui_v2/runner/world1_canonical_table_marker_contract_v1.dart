import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/theme/app_typography.dart';
import 'package:poker_analyzer/ui_v2/runner/runner_seat_state_badge_v1.dart';

enum World1CanonicalTableMarkerKindV1 { dealer, sb, bb }

class World1CanonicalTableMarkerContractV1 {
  const World1CanonicalTableMarkerContractV1({
    required this.kind,
    required this.label,
    required this.amount,
    required this.size,
    this.compactStack = false,
    this.backgroundOpacity = 0.9,
    this.stackLayers = 3,
    this.semanticKey,
  });

  final World1CanonicalTableMarkerKindV1 kind;
  final String label;
  final int amount;
  final double size;
  final bool compactStack;
  final double backgroundOpacity;
  final int stackLayers;
  final Key? semanticKey;
}

class World1CanonicalTargetRingContractV1 {
  const World1CanonicalTargetRingContractV1({
    required this.seatId,
    required this.diameter,
  });

  final String? seatId;
  final double diameter;
}

List<World1CanonicalTableMarkerContractV1>
resolveWorld1CanonicalSeatQuizCueContractsV1({
  required bool seatQuizVisualMode,
  required double cueRadius,
}) {
  if (!seatQuizVisualMode) {
    return const <World1CanonicalTableMarkerContractV1>[];
  }
  return <World1CanonicalTableMarkerContractV1>[
    World1CanonicalTableMarkerContractV1(
      kind: World1CanonicalTableMarkerKindV1.dealer,
      label: 'D',
      amount: 0,
      size: cueRadius * 3.0,
    ),
    World1CanonicalTableMarkerContractV1(
      kind: World1CanonicalTableMarkerKindV1.sb,
      label: 'SB',
      amount: 1,
      size: cueRadius * 3.2,
    ),
    World1CanonicalTableMarkerContractV1(
      kind: World1CanonicalTableMarkerKindV1.bb,
      label: 'BB',
      amount: 2,
      size: cueRadius * 3.2,
    ),
  ];
}

List<World1CanonicalTableMarkerContractV1>
resolveWorld1CanonicalHandLoopCueContractsV1({
  required bool handLoopVisualMode,
  required bool demoActionDecisionState,
  required double cueRadius,
  required String sbDisplaySeatId,
  required String bbDisplaySeatId,
}) {
  if (!handLoopVisualMode) {
    return const <World1CanonicalTableMarkerContractV1>[];
  }
  final markerSize = cueRadius * (demoActionDecisionState ? 2.5 : 3.2);
  return <World1CanonicalTableMarkerContractV1>[
    World1CanonicalTableMarkerContractV1(
      kind: World1CanonicalTableMarkerKindV1.sb,
      label: 'SB',
      amount: 1,
      size: markerSize,
      compactStack: demoActionDecisionState,
      backgroundOpacity: demoActionDecisionState ? 0.48 : 0.9,
      stackLayers: demoActionDecisionState ? 1 : 3,
      semanticKey: Key('microtask_blind_sb_display_${sbDisplaySeatId}_v1'),
    ),
    World1CanonicalTableMarkerContractV1(
      kind: World1CanonicalTableMarkerKindV1.bb,
      label: 'BB',
      amount: 2,
      size: markerSize,
      compactStack: demoActionDecisionState,
      backgroundOpacity: demoActionDecisionState ? 0.48 : 0.9,
      stackLayers: demoActionDecisionState ? 1 : 3,
      semanticKey: Key('microtask_blind_bb_display_${bbDisplaySeatId}_v1'),
    ),
  ];
}

World1CanonicalTargetRingContractV1?
resolveWorld1CanonicalTargetRingContractV1({
  required Offset? targetSeatCenter,
  required String? targetSeatId,
  required double nonOverlappingSeatSize,
}) {
  if (targetSeatCenter == null) {
    return null;
  }
  return World1CanonicalTargetRingContractV1(
    seatId: targetSeatId,
    diameter: nonOverlappingSeatSize + 8,
  );
}

Widget buildWorld1CanonicalTargetRingBodyV1({
  required Offset center,
  required World1CanonicalTargetRingContractV1 contract,
}) {
  return Positioned(
    left: center.dx - (contract.diameter / 2),
    top: center.dy - (contract.diameter / 2),
    child: IgnorePointer(
      child: Container(
        key: contract.seatId == null
            ? const Key('microtask_seat_quiz_target_ring_v1')
            : Key('microtask_seat_quiz_target_ring_${contract.seatId}_v1'),
        width: contract.diameter,
        height: contract.diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: SharkyTokensV1.brandGlow.withOpacity(0.86),
            width: 2.8,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: SharkyTokensV1.brandGlow.withOpacity(0.2),
              blurRadius: 9,
              spreadRadius: 0.8,
            ),
            BoxShadow(
              color: SharkyTokensV1.brandPrimary.withOpacity(0.16),
              blurRadius: 5,
              spreadRadius: 0.3,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildWorld1CanonicalTableMarkerBodyV1({
  required Offset center,
  required World1CanonicalTableMarkerContractV1 contract,
}) {
  return Positioned(
    left: center.dx - (contract.size / 2),
    top: center.dy - (contract.size / 2),
    child: IgnorePointer(
      child: KeyedSubtree(
        key: contract.semanticKey,
        child: buildWorld1CanonicalChipStackBadgeV1(
          label: contract.label,
          amount: contract.amount,
          chipSize: contract.size * 0.34,
          compact: true,
          backgroundOpacity: contract.backgroundOpacity,
          stackLayers: contract.compactStack ? 1 : contract.stackLayers,
        ),
      ),
    ),
  );
}

Widget buildWorld1CanonicalChipStackBadgeV1({
  required String label,
  required int amount,
  required double chipSize,
  bool compact = false,
  double backgroundOpacity = 0.74,
  int stackLayers = 3,
  Key? amountValueKey,
}) {
  final displayAmount = _formatBlindDisplayAmountV1(
    label: label,
    amount: amount,
  );
  final captionStyle = AppTypography.caption.copyWith(
    color: SharkyTokensV1.textPrimary,
    fontWeight: FontWeight.w800,
    fontSize: compact ? 7.1 : 8.6,
    letterSpacing: 0.12,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
  final amountStyle = AppTypography.caption.copyWith(
    color: SharkyTokensV1.textSecondary.withOpacity(0.94),
    fontWeight: FontWeight.w700,
    fontSize: compact ? 7.0 : 8.4,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
  final tone = switch (label.trim().toUpperCase()) {
    'SB' || 'BB' => RunnerSeatStateBadgeToneV1.forcedBet,
    _ => RunnerSeatStateBadgeToneV1.neutral,
  };
  return RepaintBoundary(
    child: RunnerSeatStateBadgeShellV1(
      tone: tone,
      visualPriorityV1: RunnerSeatStateBadgePriorityV1.secondary,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 5.5 : 7.0,
          vertical: compact ? 2.6 : 3.2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            stackLayers == 3
                ? _buildChipStackGlyphV1(chipSize: chipSize)
                : _buildChipStackGlyphLayersV1(
                    chipSize: chipSize,
                    layers: stackLayers,
                  ),
            SizedBox(width: compact ? 3.5 : 5.0),
            Text(label, style: captionStyle),
            if (displayAmount != null || amountValueKey != null) ...<Widget>[
              SizedBox(width: compact ? 2.8 : 4.2),
              Text(
                displayAmount ?? amount.toString(),
                key: amountValueKey,
                style: amountStyle,
              ),
            ],
          ],
        ),
      ),
      padding: EdgeInsets.zero,
    ),
  );
}

String? _formatBlindDisplayAmountV1({
  required String label,
  required int amount,
}) {
  if (amount <= 0) return null;
  final normalizedLabel = label.trim().toUpperCase();
  if (normalizedLabel.isEmpty) return null;
  return _unitsToBbDisplayV1(amount);
}

String _unitsToBbDisplayV1(int units) {
  final negative = units < 0;
  final absUnits = units.abs();
  final whole = absUnits ~/ 2;
  final hasHalf = absUnits.isOdd;
  final bb = hasHalf ? '$whole.5' : '$whole';
  return negative ? '-$bb' : bb;
}

Widget _buildChipStackGlyphV1({required double chipSize}) {
  final effectiveSize = chipSize.clamp(4.0, 18.0);
  return _buildChipStackGlyphLayersV1(chipSize: effectiveSize, layers: 3);
}

Widget _buildChipStackGlyphLayersV1({
  required double chipSize,
  required int layers,
}) {
  final effectiveSize = chipSize.clamp(4.0, 18.0);
  final safeLayers = layers.clamp(1, 3);
  return SizedBox(
    width: effectiveSize * 1.35,
    height: effectiveSize * 1.3,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: <Widget>[
        if (safeLayers >= 3)
          _buildSingleChipDotV1(
            size: effectiveSize,
            top: effectiveSize * 0.24,
            opacity: 0.84,
          ),
        if (safeLayers >= 2)
          _buildSingleChipDotV1(
            size: effectiveSize,
            top: safeLayers >= 3 ? effectiveSize * 0.12 : effectiveSize * 0.1,
            opacity: safeLayers >= 3 ? 0.92 : 0.94,
          ),
        _buildSingleChipDotV1(size: effectiveSize, top: 0, opacity: 1.0),
      ],
    ),
  );
}

Widget _buildSingleChipDotV1({
  required double size,
  required double top,
  required double opacity,
}) {
  return Positioned(
    top: top,
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            SharkyTokensV1.brandPrimary.withOpacity(0.95 * opacity),
            SharkyTokensV1.brandGlow.withOpacity(0.82 * opacity),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: SharkyTokensV1.surfaceApp.withOpacity(0.86),
          width: 0.72,
        ),
      ),
    ),
  );
}
