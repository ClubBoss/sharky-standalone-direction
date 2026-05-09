import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_spatial_scaffold_v1.dart';

enum World1CanonicalSeatQuizInstructionSurfaceKindV1 {
  none,
  overlayText,
  plainText,
  conceptPrelude,
  actionLiteracyPrelude,
  streetFlowPrelude,
}

@immutable
class World1CanonicalSeatQuizTaskCopyInputV1 {
  const World1CanonicalSeatQuizTaskCopyInputV1({
    required this.targetSeatId,
    required this.includeConfirmHint,
    required this.seatOrderIds,
  });

  final String? targetSeatId;
  final bool includeConfirmHint;
  final List<String> seatOrderIds;
}

@immutable
class World1CanonicalSeatQuizTaskCopyV1 {
  const World1CanonicalSeatQuizTaskCopyV1({
    required this.primaryLine,
    required this.orderLine,
  });

  final String primaryLine;
  final String orderLine;

  String get promptText => '$primaryLine\n$orderLine';
}

World1CanonicalSeatQuizTaskCopyV1 resolveWorld1CanonicalSeatQuizTaskCopyV1(
  World1CanonicalSeatQuizTaskCopyInputV1 input,
) {
  final targetSeatId = input.targetSeatId?.trim().toLowerCase();
  final actionLine = (targetSeatId == null || targetSeatId.isEmpty)
      ? (input.includeConfirmHint
            ? 'Tap the highlighted seat, then confirm.'
            : 'Tap the highlighted seat.')
      : (() {
          final seatLabel = describeWorld1CanonicalSeatForLearnerV1(
            targetSeatId,
            includeDealerSuffix: true,
          );
          return input.includeConfirmHint
              ? 'Tap $seatLabel, then confirm.'
              : 'Tap $seatLabel.';
        })();
  return World1CanonicalSeatQuizTaskCopyV1(
    primaryLine: actionLine,
    orderLine: buildWorld1CanonicalSeatOrderHintV1(input.seatOrderIds),
  );
}

@immutable
class World1CanonicalSeatQuizInstructionSurfaceContractV1 {
  const World1CanonicalSeatQuizInstructionSurfaceContractV1({
    required this.kind,
    required this.placementText,
    this.overlayPreludeKey,
  });

  final World1CanonicalSeatQuizInstructionSurfaceKindV1 kind;
  final String placementText;
  final Key? overlayPreludeKey;
}

extension World1CanonicalSeatQuizInstructionSurfaceContractX
    on World1CanonicalSeatQuizInstructionSurfaceContractV1 {
  bool get isVisible =>
      kind != World1CanonicalSeatQuizInstructionSurfaceKindV1.none &&
      placementText.trim().isNotEmpty;

  bool get showsOverlayPrelude =>
      kind == World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText;

  bool get usesEmbeddedPreludeCard =>
      kind == World1CanonicalSeatQuizInstructionSurfaceKindV1.conceptPrelude ||
      kind ==
          World1CanonicalSeatQuizInstructionSurfaceKindV1
              .actionLiteracyPrelude ||
      kind == World1CanonicalSeatQuizInstructionSurfaceKindV1.streetFlowPrelude;

  bool get showsTableInstruction =>
      kind == World1CanonicalSeatQuizInstructionSurfaceKindV1.plainText ||
      usesEmbeddedPreludeCard;

  String get tablePromptText => placementText;
}

@immutable
class World1CanonicalSeatQuizInstructionSurfaceInputV1 {
  const World1CanonicalSeatQuizInstructionSurfaceInputV1({
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
}

World1CanonicalSeatQuizInstructionSurfaceContractV1
resolveWorld1CanonicalSeatQuizInstructionSurfaceV1(
  World1CanonicalSeatQuizInstructionSurfaceInputV1 input,
) {
  if (input.globalTrainingOverlayActive) {
    return const World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      placementText:
          'You will make small table decisions.\n'
          'We stay silent until an error, then explain one reason.\n'
          'We teach recommended play for this spot.\n'
          'Some choices are legal but worse.',
      overlayPreludeKey: Key('microtask_global_training_intro_prelude_v1'),
    );
  }
  if (input.world1IntroOverlayActive) {
    return const World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      placementText:
          'This training teaches action order on a real table.\n'
          'Watch the felt, tap the highlighted seat, and keep moving.\n'
          'Focus on the dealer button and who acts next.\n'
          'Short reps with quick correction make the pattern stick.',
      overlayPreludeKey: Key('microtask_world1_intro_prelude_v1'),
    );
  }
  if (input.world1ActionIntroOverlayActive) {
    return const World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      placementText:
          'Next, turn seat order into an action choice.\n'
          'Start from the button, then find who acts first.\n'
          'Why it matters: the right action depends on position.\n'
          'Misses get one quick correction so the pattern sticks.',
      overlayPreludeKey: Key('microtask_world1_action_intro_prelude_v1'),
    );
  }
  if (input.world1StreetFlowIntroOverlayActive) {
    return const World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      placementText:
          'Now connect the action to the street you are on.\n'
          'Focus on what changes from preflop to flop, turn, and river.\n'
          'Why it matters: the board changes who can act and what matters.\n'
          'Misses get one quick correction so the sequence sticks.',
      overlayPreludeKey: Key('microtask_world1_street_flow_intro_prelude_v1'),
    );
  }
  if (input.world2HandoffOverlayActive) {
    return const World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      placementText:
          'Next: use positions to choose call, raise, or fold.\n'
          'If you miss, we explain one key reason.\n'
          'Small steps build speed.',
      overlayPreludeKey: Key('microtask_world2_handoff_prelude_v1'),
    );
  }
  if (input.world2IntroOverlayActive) {
    return const World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      placementText:
          '- You will make small table decisions.\n'
          '- We stay silent until an error, then explain one reason.\n'
          '- Some choices are legal but worse than our recommendation.\n'
          '- Repeat builds speed and confidence.',
      overlayPreludeKey: Key('microtask_world2_intro_prelude_v1'),
    );
  }
  if (input.trackIntroOverlayActive) {
    return World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      placementText: input.trackIntroKind == 'cash'
          ? input.cashTrackIntroOverlayText
          : (input.trackIntroKind == 'tournament'
                ? input.tournamentTrackIntroOverlayText
                : input.mixedTrackIntroOverlayText),
      overlayPreludeKey: input.trackIntroKind == 'cash'
          ? const Key('microtask_cash_track_intro_prelude_v1')
          : (input.trackIntroKind == 'tournament'
                ? const Key('microtask_tournament_track_intro_prelude_v1')
                : const Key('microtask_mixed_track_intro_prelude_v1')),
    );
  }
  if (!(input.seatQuizVisualMode && !input.handLoopVisualMode)) {
    return const World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.none,
      placementText: '',
    );
  }
  if (input.conceptPreludeInstructionSurfaceActive) {
    return World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.conceptPrelude,
      placementText: input.conceptPreludePlacementText,
    );
  }
  if (input.actionLiteracyPreludeInstructionSurfaceActive) {
    return World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind:
          World1CanonicalSeatQuizInstructionSurfaceKindV1.actionLiteracyPrelude,
      placementText: input.actionLiteracyPlacementText,
    );
  }
  if (input.streetFlowPreludeInstructionSurfaceActive) {
    return World1CanonicalSeatQuizInstructionSurfaceContractV1(
      kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.streetFlowPrelude,
      placementText: input.streetFlowPlacementText,
    );
  }
  return World1CanonicalSeatQuizInstructionSurfaceContractV1(
    kind: World1CanonicalSeatQuizInstructionSurfaceKindV1.plainText,
    placementText: input.seatQuizTableInstructionText,
  );
}

@immutable
class World1CanonicalHandLoopPromptSurfaceInputV1 {
  const World1CanonicalHandLoopPromptSurfaceInputV1({
    required this.handLoopMode,
    required this.isDemoHandLoopVisualStep,
    required this.showSeatQuizPrelude,
    required this.showIntroSequence,
    required this.promptText,
    required this.outcomeSurfaceVisible,
    required this.debugCaptionOverrideVisible,
    required this.runnerAuthorityIsReviewPass,
    required this.runnerAuthorityVisibleBoardCount,
    required this.portraitLayout,
    required this.reviewQueueSession,
  });

  final bool handLoopMode;
  final bool isDemoHandLoopVisualStep;
  final bool showSeatQuizPrelude;
  final bool showIntroSequence;
  final String promptText;
  final bool outcomeSurfaceVisible;
  final bool debugCaptionOverrideVisible;
  final bool runnerAuthorityIsReviewPass;
  final int runnerAuthorityVisibleBoardCount;
  final bool portraitLayout;
  final bool reviewQueueSession;
}

@immutable
class World1CanonicalHandLoopPromptSurfaceV1 {
  const World1CanonicalHandLoopPromptSurfaceV1({
    required this.isAffectedStateFamily,
    required this.usesFeltCaptionHost,
    required this.isMounted,
    required this.promptText,
    required this.reviewQueuePrefix,
  });

  final bool isAffectedStateFamily;
  final bool usesFeltCaptionHost;
  final bool isMounted;
  final String promptText;
  final bool reviewQueuePrefix;
}

World1CanonicalHandLoopPromptSurfaceV1
resolveWorld1CanonicalHandLoopPromptSurfaceV1(
  World1CanonicalHandLoopPromptSurfaceInputV1 input,
) {
  final isAffectedStateFamily =
      input.handLoopMode &&
      !input.isDemoHandLoopVisualStep &&
      !input.showSeatQuizPrelude &&
      !input.showIntroSequence &&
      input.promptText.isNotEmpty;
  final isMounted =
      isAffectedStateFamily &&
      (!input.outcomeSurfaceVisible || input.debugCaptionOverrideVisible);
  final usesBoardRevealFeltCaptionHost =
      isAffectedStateFamily &&
      !input.runnerAuthorityIsReviewPass &&
      input.runnerAuthorityVisibleBoardCount > 0;
  return World1CanonicalHandLoopPromptSurfaceV1(
    isAffectedStateFamily: isAffectedStateFamily,
    usesFeltCaptionHost: usesBoardRevealFeltCaptionHost,
    isMounted: isMounted,
    promptText: input.promptText,
    reviewQueuePrefix:
        input.reviewQueueSession && !input.isDemoHandLoopVisualStep,
  );
}

Rect resolveWorld1SeatQuizTableInstructionRectV1({
  required Rect stadiumRect,
  required double preferredWidth,
  required double containerHeight,
  required List<Rect> avoidRects,
  required double laneTopFactor,
  required double laneBottomFactor,
}) {
  const scanStepPxV1 = 6.0;
  const lateralStepPxV1 = 12.0;
  final safeWidth = math.min(preferredWidth, stadiumRect.width).toDouble();
  final laneTop = stadiumRect.top + (stadiumRect.height * laneTopFactor);
  final laneBottom = stadiumRect.top + (stadiumRect.height * laneBottomFactor);
  final maxTop = laneBottom - containerHeight;
  final scanStart = laneTop;
  final scanEnd = math.max(scanStart, maxTop);
  final clampedTop = scanStart.clamp(scanStart, scanEnd).toDouble();
  final centeredLeft = stadiumRect.center.dx - (safeWidth / 2);
  final minLeft = stadiumRect.left;
  final maxLeft = math.max(stadiumRect.left, stadiumRect.right - safeWidth);

  Rect buildRect(double top, double left) {
    final clampedTopValue = top.clamp(scanStart, scanEnd).toDouble();
    final clampedLeftValue = left.clamp(minLeft, maxLeft).toDouble();
    return Rect.fromLTRB(
      clampedLeftValue,
      clampedTopValue,
      clampedLeftValue + safeWidth,
      clampedTopValue + containerHeight,
    );
  }

  final scanSpan = math.max(0.0, scanEnd - scanStart);
  final centerTop = scanStart + (scanSpan / 2);
  final candidateTops = <double>[centerTop];
  for (
    var delta = scanStepPxV1;
    delta <= scanSpan + 0.01;
    delta += scanStepPxV1
  ) {
    final down = centerTop + delta;
    final up = centerTop - delta;
    if (down <= scanEnd + 0.01) {
      candidateTops.add(down);
    }
    if (up >= scanStart - 0.01) {
      candidateTops.add(up);
    }
  }
  final candidateLefts = <double>[centeredLeft];
  final lateralSpan = math.max(0.0, maxLeft - minLeft);
  for (
    var delta = lateralStepPxV1;
    delta <= lateralSpan + 0.01;
    delta += lateralStepPxV1
  ) {
    final right = centeredLeft + delta;
    final left = centeredLeft - delta;
    if (right <= maxLeft + 0.01) {
      candidateLefts.add(right);
    }
    if (left >= minLeft - 0.01) {
      candidateLefts.add(left);
    }
  }

  if (candidateTops.isEmpty || candidateLefts.isEmpty) {
    return buildRect(clampedTop, centeredLeft);
  }

  Rect bestRect = buildRect(centerTop, centeredLeft);
  var bestOverlapArea = double.infinity;
  var bestCenterDistance = double.infinity;
  for (final top in candidateTops) {
    for (final left in candidateLefts) {
      final candidate = buildRect(top, left);
      var overlapArea = 0.0;
      for (final avoidRect in avoidRects) {
        overlapArea += _rectOverlapAreaV1(candidate, avoidRect);
      }
      if (overlapArea <= 0.0) {
        return candidate;
      }
      final centerDistance =
          (candidate.center.dy - centerTop).abs() +
          ((candidate.center.dx - stadiumRect.center.dx).abs() * 0.35);
      if (overlapArea < bestOverlapArea - 0.01 ||
          ((overlapArea - bestOverlapArea).abs() <= 0.01 &&
              centerDistance < bestCenterDistance)) {
        bestRect = candidate;
        bestOverlapArea = overlapArea;
        bestCenterDistance = centerDistance;
      }
    }
  }
  return bestRect;
}

Rect resolveSeatQuizTableInstructionRectV1({
  required Rect stadiumRect,
  required double preferredWidth,
  required double containerHeight,
  required List<Rect> avoidRects,
  required double laneTopFactor,
  required double laneBottomFactor,
}) {
  return resolveWorld1SeatQuizTableInstructionRectV1(
    stadiumRect: stadiumRect,
    preferredWidth: preferredWidth,
    containerHeight: containerHeight,
    avoidRects: avoidRects,
    laneTopFactor: laneTopFactor,
    laneBottomFactor: laneBottomFactor,
  );
}

double _rectOverlapAreaV1(Rect a, Rect b) {
  if (!a.overlaps(b)) {
    return 0;
  }
  final intersection = Rect.fromLTRB(
    math.max(a.left, b.left),
    math.max(a.top, b.top),
    math.min(a.right, b.right),
    math.min(a.bottom, b.bottom),
  );
  return intersection.width * intersection.height;
}
