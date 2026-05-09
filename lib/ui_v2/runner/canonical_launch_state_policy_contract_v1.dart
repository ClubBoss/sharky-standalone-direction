class CanonicalLaunchStatePolicyInputV1 {
  const CanonicalLaunchStatePolicyInputV1({
    required this.explicitMode,
    required this.isCheckpoint,
    required this.isDailyRun,
    required this.isTablePractice,
    required this.startItemIndex,
    required this.resolvedItemCount,
    required this.shouldApplyCheckpointSeed,
    required this.campaignSpineModeId,
    required this.reviewQueueModeId,
    required this.checkpointModeId,
    required this.dailyRunModeId,
    required this.tablePracticeModeId,
    required this.defaultModeId,
  });

  final String? explicitMode;
  final bool isCheckpoint;
  final bool isDailyRun;
  final bool isTablePractice;
  final int? startItemIndex;
  final int resolvedItemCount;
  final bool shouldApplyCheckpointSeed;
  final String campaignSpineModeId;
  final String reviewQueueModeId;
  final String checkpointModeId;
  final String dailyRunModeId;
  final String tablePracticeModeId;
  final String defaultModeId;
}

class CanonicalLaunchStatePolicyResolvedV1 {
  const CanonicalLaunchStatePolicyResolvedV1({
    required this.mode,
    required this.initialItemIndex,
    required this.shouldApplyCheckpointSeed,
    required this.shouldBootstrapCampaignState,
    required this.shouldBootstrapIntroPreludes,
    required this.shouldBootstrapReviewQueue,
  });

  final String mode;
  final int initialItemIndex;
  final bool shouldApplyCheckpointSeed;
  final bool shouldBootstrapCampaignState;
  final bool shouldBootstrapIntroPreludes;
  final bool shouldBootstrapReviewQueue;
}

CanonicalLaunchStatePolicyResolvedV1 resolveCanonicalLaunchStatePolicyV1(
  CanonicalLaunchStatePolicyInputV1 input,
) {
  final mode = _resolveCanonicalLaunchModeV1(input);
  final isCampaignSpineSession = mode == input.campaignSpineModeId;
  final isReviewQueueSession = mode == input.reviewQueueModeId;
  final hasStartIndex =
      isCampaignSpineSession &&
      input.startItemIndex != null &&
      input.startItemIndex! > 0 &&
      input.resolvedItemCount > 0;
  final initialItemIndex = hasStartIndex
      ? input.startItemIndex!.clamp(0, input.resolvedItemCount - 1)
      : 0;

  return CanonicalLaunchStatePolicyResolvedV1(
    mode: mode,
    initialItemIndex: initialItemIndex,
    shouldApplyCheckpointSeed: input.shouldApplyCheckpointSeed,
    shouldBootstrapCampaignState: isCampaignSpineSession,
    shouldBootstrapIntroPreludes: isCampaignSpineSession,
    shouldBootstrapReviewQueue: isReviewQueueSession,
  );
}

String _resolveCanonicalLaunchModeV1(CanonicalLaunchStatePolicyInputV1 input) {
  final explicitMode = input.explicitMode;
  if (explicitMode != null && explicitMode.isNotEmpty) {
    return explicitMode;
  }
  if (input.isCheckpoint) {
    return input.checkpointModeId;
  }
  if (input.isDailyRun) {
    return input.dailyRunModeId;
  }
  if (input.isTablePractice) {
    return input.tablePracticeModeId;
  }
  return input.defaultModeId;
}
