import 'package:poker_analyzer/canonical/canonical_truth_map_v1.dart'
    as canonical_truth;
import 'package:poker_analyzer/services/progress_service.dart';

enum CanonicalLandingSourceV1 {
  boot,
  todayStart,
  mapStart,
  mapReview,
  resultContinue,
}

enum CanonicalLandingSurfaceKindV1 {
  intakePlan,
  progressMap,
  campaignReviewQueue,
  campaignSpineLaunch,
  directSessionLaunch,
}

enum CanonicalLandingReasonCodeV1 {
  onboardingOrIntakeRequired,
  campaignCompleteMapLanding,
  canonicalReviewQueueRequired,
  canonicalDirectSessionTarget,
  canonicalCampaignSpineTarget,
  emptyCanonicalEntry,
}

class CanonicalLandingDecisionInputsV1 {
  const CanonicalLandingDecisionInputsV1({
    required this.onboardingCompleted,
    required this.intakeCompleted,
    required this.campaignComplete,
    required this.checkpointPending,
    required this.nextPackId,
    required this.canonicalEntryPackId,
    required this.hasReviewQueueForCanonicalEntryPack,
    required this.activePackId,
    required this.currentPackId,
    required this.nextHandIndex,
    this.source = CanonicalLandingSourceV1.boot,
  });

  final bool onboardingCompleted;
  final bool intakeCompleted;
  final bool campaignComplete;
  final bool checkpointPending;
  final String nextPackId;
  final String canonicalEntryPackId;
  final bool hasReviewQueueForCanonicalEntryPack;
  final String activePackId;
  final String currentPackId;
  final int nextHandIndex;
  final CanonicalLandingSourceV1 source;
}

class CanonicalLandingDecisionV1 {
  const CanonicalLandingDecisionV1({
    required this.surfaceKind,
    required this.entryId,
    required this.runnerMode,
    required this.startHandIndex,
    required this.reviewRequired,
    required this.checkpointRedirected,
    required this.reasonCode,
  });

  final CanonicalLandingSurfaceKindV1 surfaceKind;
  final String entryId;
  final String? runnerMode;
  final int startHandIndex;
  final bool reviewRequired;
  final bool checkpointRedirected;
  final CanonicalLandingReasonCodeV1 reasonCode;
}

const String kCanonicalLandingRunnerModeCampaignSpineV1 = 'campaign_spine';
const String kCanonicalLandingRunnerModeReviewQueueV1 = 'review_queue';

Future<CanonicalLandingDecisionV1> resolveCanonicalLandingDecisionV1(
  CanonicalLandingDecisionInputsV1 inputs,
) async {
  if (!inputs.onboardingCompleted || !inputs.intakeCompleted) {
    return const CanonicalLandingDecisionV1(
      surfaceKind: CanonicalLandingSurfaceKindV1.intakePlan,
      entryId: '',
      runnerMode: null,
      startHandIndex: 0,
      reviewRequired: false,
      checkpointRedirected: false,
      reasonCode: CanonicalLandingReasonCodeV1.onboardingOrIntakeRequired,
    );
  }

  if (inputs.campaignComplete &&
      inputs.source == CanonicalLandingSourceV1.boot) {
    return const CanonicalLandingDecisionV1(
      surfaceKind: CanonicalLandingSurfaceKindV1.progressMap,
      entryId: '',
      runnerMode: null,
      startHandIndex: 0,
      reviewRequired: false,
      checkpointRedirected: false,
      reasonCode: CanonicalLandingReasonCodeV1.campaignCompleteMapLanding,
    );
  }

  final normalizedEntryPackId = inputs.canonicalEntryPackId
      .trim()
      .toLowerCase();
  if (normalizedEntryPackId.isEmpty) {
    return const CanonicalLandingDecisionV1(
      surfaceKind: CanonicalLandingSurfaceKindV1.progressMap,
      entryId: '',
      runnerMode: null,
      startHandIndex: 0,
      reviewRequired: false,
      checkpointRedirected: false,
      reasonCode: CanonicalLandingReasonCodeV1.emptyCanonicalEntry,
    );
  }

  final checkpointRedirected =
      inputs.checkpointPending &&
      normalizedEntryPackId == ProgressService.checkpointPackIdV1;
  if (inputs.hasReviewQueueForCanonicalEntryPack) {
    return CanonicalLandingDecisionV1(
      surfaceKind: CanonicalLandingSurfaceKindV1.campaignReviewQueue,
      entryId: normalizedEntryPackId,
      runnerMode: kCanonicalLandingRunnerModeReviewQueueV1,
      startHandIndex: 0,
      reviewRequired: true,
      checkpointRedirected: checkpointRedirected,
      reasonCode: CanonicalLandingReasonCodeV1.canonicalReviewQueueRequired,
    );
  }

  final resolvedEntryId = await canonical_truth
      .canonicalTruthResolveCampaignLaunchTargetV1(normalizedEntryPackId);
  if (canonical_truth.canonicalTruthIsPlayableSessionEntryIdV1(
    resolvedEntryId,
  )) {
    return CanonicalLandingDecisionV1(
      surfaceKind: CanonicalLandingSurfaceKindV1.directSessionLaunch,
      entryId: resolvedEntryId,
      runnerMode: null,
      startHandIndex: 0,
      reviewRequired: false,
      checkpointRedirected: checkpointRedirected,
      reasonCode: CanonicalLandingReasonCodeV1.canonicalDirectSessionTarget,
    );
  }

  final normalizedActivePackId = inputs.activePackId.trim().toLowerCase();
  final startHandIndex = normalizedActivePackId == normalizedEntryPackId
      ? inputs.nextHandIndex
      : 0;
  return CanonicalLandingDecisionV1(
    surfaceKind: CanonicalLandingSurfaceKindV1.campaignSpineLaunch,
    entryId: resolvedEntryId,
    runnerMode: kCanonicalLandingRunnerModeCampaignSpineV1,
    startHandIndex: startHandIndex,
    reviewRequired: false,
    checkpointRedirected: checkpointRedirected,
    reasonCode: CanonicalLandingReasonCodeV1.canonicalCampaignSpineTarget,
  );
}
