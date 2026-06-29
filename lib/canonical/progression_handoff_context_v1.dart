import 'package:poker_analyzer/canonical/progression_route_story_v1.dart';

class ProgressionHandoffContextV1 {
  const ProgressionHandoffContextV1({
    required this.statusLine,
    this.continuationHeadline,
    this.continuationReasonLine,
    this.continuationTargetEntryId,
    this.continuationFocusId,
    this.continuationReasonCode,
    this.continuationWeaknessLabel,
    this.continuationReviewGoal,
  });

  final String statusLine;
  final String? continuationHeadline;
  final String? continuationReasonLine;
  final String? continuationTargetEntryId;
  final String? continuationFocusId;
  final String? continuationReasonCode;
  final String? continuationWeaknessLabel;
  final String? continuationReviewGoal;
}

ProgressionHandoffContextV1? buildProgressionHandoffContextForPackV1(
  String packId,
) {
  final target = resolveProgressionRouteTargetForPackIdV1(packId);
  if (!target.isCrossFamilyRoute) {
    return null;
  }
  final routeStory = resolveProgressionRouteStoryForPackV1(
    nextPackId: packId,
    reviewRequired: false,
    activePackId: '',
    nextHandIndex: 0,
    rhythmReason: '',
  );
  final statusLine = progressionRouteStatusLineForTargetV1(target);
  final shouldCarryRouteCue =
      progressionRouteStageShiftHeadlineForTargetV1(target) != null;
  return ProgressionHandoffContextV1(
    statusLine: statusLine,
    continuationHeadline: shouldCarryRouteCue
        ? progressionRouteStageShiftHeadlineForTargetV1(target)
        : null,
    continuationReasonLine: shouldCarryRouteCue ? routeStory.reasonLine : null,
  );
}
