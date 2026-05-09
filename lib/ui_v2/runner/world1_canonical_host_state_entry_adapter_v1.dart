import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/canonical_launch_state_policy_contract_v1.dart';

class World1CanonicalHostStateEntryInputV1 {
  const World1CanonicalHostStateEntryInputV1({
    required this.moduleId,
    required this.explicitMode,
    required this.isCheckpoint,
    required this.isDailyRun,
    required this.isTablePractice,
    required this.startHandIndex,
    required this.isGlobalCheckpointPack,
    required this.checkpointSteps,
    required this.packSteps,
    required this.fallbackSteps,
    required this.campaignSpineModeId,
    required this.reviewQueueModeId,
    required this.checkpointModeId,
    required this.dailyRunModeId,
    required this.tablePracticeModeId,
    required this.defaultModeId,
  });

  final String moduleId;
  final String? explicitMode;
  final bool isCheckpoint;
  final bool isDailyRun;
  final bool isTablePractice;
  final int? startHandIndex;
  final bool isGlobalCheckpointPack;
  final List<MicroTaskStep> checkpointSteps;
  final List<MicroTaskStep> packSteps;
  final List<MicroTaskStep> fallbackSteps;
  final String campaignSpineModeId;
  final String reviewQueueModeId;
  final String checkpointModeId;
  final String dailyRunModeId;
  final String tablePracticeModeId;
  final String defaultModeId;
}

class World1CanonicalHostStateEntryResolvedV1 {
  const World1CanonicalHostStateEntryResolvedV1({
    required this.mode,
    required this.steps,
    required this.initialStepIndex,
    required this.shouldApplyCheckpointSeed,
    required this.shouldBootstrapCampaignState,
    required this.shouldBootstrapIntroPreludes,
    required this.shouldBootstrapReviewQueue,
  });

  final String mode;
  final List<MicroTaskStep> steps;
  final int initialStepIndex;
  final bool shouldApplyCheckpointSeed;
  final bool shouldBootstrapCampaignState;
  final bool shouldBootstrapIntroPreludes;
  final bool shouldBootstrapReviewQueue;
}

class World1CanonicalResolvedHostLaunchV1 {
  const World1CanonicalResolvedHostLaunchV1({
    required this.mode,
    required this.learningEffectSliceMarker,
    required this.steps,
    required this.initialStepIndex,
    required this.shouldApplyCheckpointSeed,
    required this.shouldBootstrapCampaignState,
    required this.shouldBootstrapIntroPreludes,
    required this.shouldBootstrapReviewQueue,
  });

  final String mode;
  final String learningEffectSliceMarker;
  final List<MicroTaskStep> steps;
  final int initialStepIndex;
  final bool shouldApplyCheckpointSeed;
  final bool shouldBootstrapCampaignState;
  final bool shouldBootstrapIntroPreludes;
  final bool shouldBootstrapReviewQueue;
}

World1CanonicalHostStateEntryResolvedV1 resolveWorld1CanonicalHostStateEntryV1(
  World1CanonicalHostStateEntryInputV1 input,
) {
  final resolvedSteps = input.isCheckpoint
      ? input.checkpointSteps
      : input.packSteps;
  final steps = resolvedSteps.isEmpty ? input.fallbackSteps : resolvedSteps;
  final launchPolicyV1 = resolveCanonicalLaunchStatePolicyV1(
    CanonicalLaunchStatePolicyInputV1(
      explicitMode: input.explicitMode,
      isCheckpoint: input.isCheckpoint,
      isDailyRun: input.isDailyRun,
      isTablePractice: input.isTablePractice,
      startItemIndex: input.startHandIndex,
      resolvedItemCount: steps.length,
      shouldApplyCheckpointSeed: input.isGlobalCheckpointPack,
      campaignSpineModeId: input.campaignSpineModeId,
      reviewQueueModeId: input.reviewQueueModeId,
      checkpointModeId: input.checkpointModeId,
      dailyRunModeId: input.dailyRunModeId,
      tablePracticeModeId: input.tablePracticeModeId,
      defaultModeId: input.defaultModeId,
    ),
  );

  return World1CanonicalHostStateEntryResolvedV1(
    mode: launchPolicyV1.mode,
    steps: steps,
    initialStepIndex: launchPolicyV1.initialItemIndex,
    shouldApplyCheckpointSeed: launchPolicyV1.shouldApplyCheckpointSeed,
    shouldBootstrapCampaignState: launchPolicyV1.shouldBootstrapCampaignState,
    shouldBootstrapIntroPreludes: launchPolicyV1.shouldBootstrapIntroPreludes,
    shouldBootstrapReviewQueue: launchPolicyV1.shouldBootstrapReviewQueue,
  );
}

World1CanonicalResolvedHostLaunchV1 resolveWorld1CanonicalResolvedHostLaunchV1({
  required World1CanonicalHostStateEntryInputV1 entryInput,
  required String learningEffectSliceMarker,
}) {
  final entryStateV1 = resolveWorld1CanonicalHostStateEntryV1(entryInput);
  return World1CanonicalResolvedHostLaunchV1(
    mode: entryStateV1.mode,
    learningEffectSliceMarker: learningEffectSliceMarker,
    steps: entryStateV1.steps,
    initialStepIndex: entryStateV1.initialStepIndex,
    shouldApplyCheckpointSeed: entryStateV1.shouldApplyCheckpointSeed,
    shouldBootstrapCampaignState: entryStateV1.shouldBootstrapCampaignState,
    shouldBootstrapIntroPreludes: entryStateV1.shouldBootstrapIntroPreludes,
    shouldBootstrapReviewQueue: entryStateV1.shouldBootstrapReviewQueue,
  );
}
