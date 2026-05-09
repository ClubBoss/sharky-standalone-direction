import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class World1CanonicalTopPanelContractInputV1 {
  const World1CanonicalTopPanelContractInputV1({
    required this.isCheckpointSession,
    required this.isTablePracticeSession,
    required this.useFeltOverlayAsPromptSource,
    required this.showCompactInstructionOverlay,
    required this.introCaptionActive,
    required this.compactPortrait,
    required this.campaignHudDetailsExpanded,
    required this.progressionStatusText,
    required this.showGoldLearningSlicePreludeCard,
    required this.showConceptFirstSeatPreludeCard,
    required this.isCampaignSpineSession,
    required this.hasContextText,
    required this.hasTradeoffText,
    required this.hasConsequenceText,
    required this.showExtendedHudDetails,
    required this.pulseBust,
    required this.successBadgeText,
  });

  final bool isCheckpointSession;
  final bool isTablePracticeSession;
  final bool useFeltOverlayAsPromptSource;
  final bool showCompactInstructionOverlay;
  final bool introCaptionActive;
  final bool compactPortrait;
  final bool campaignHudDetailsExpanded;
  final String? progressionStatusText;
  final bool showGoldLearningSlicePreludeCard;
  final bool showConceptFirstSeatPreludeCard;
  final bool isCampaignSpineSession;
  final bool hasContextText;
  final bool hasTradeoffText;
  final bool hasConsequenceText;
  final bool showExtendedHudDetails;
  final bool pulseBust;
  final String? successBadgeText;
}

@immutable
class World1CanonicalTopPanelContractResolvedV1 {
  const World1CanonicalTopPanelContractResolvedV1({
    required this.showInstructionOverlay,
    required this.showOverlayGoalText,
    required this.showProgressionStatus,
    required this.stepHeaderKey,
    required this.showGoldLearningSlicePreludeCard,
    required this.showConceptFirstSeatPreludeCard,
    required this.showHeaderPrompt,
    required this.showCampaignContext,
    required this.showCampaignTradeoff,
    required this.showCampaignConsequence,
    required this.showCampaignHud,
    required this.showExtendedHudDetails,
    required this.showBustBanner,
    required this.showSuccessBadge,
  });

  final bool showInstructionOverlay;
  final bool showOverlayGoalText;
  final bool showProgressionStatus;
  final Key stepHeaderKey;
  final bool showGoldLearningSlicePreludeCard;
  final bool showConceptFirstSeatPreludeCard;
  final bool showHeaderPrompt;
  final bool showCampaignContext;
  final bool showCampaignTradeoff;
  final bool showCampaignConsequence;
  final bool showCampaignHud;
  final bool showExtendedHudDetails;
  final bool showBustBanner;
  final bool showSuccessBadge;
}

World1CanonicalTopPanelContractResolvedV1
resolveWorld1CanonicalTopPanelContractV1(
  World1CanonicalTopPanelContractInputV1 input,
) {
  return World1CanonicalTopPanelContractResolvedV1(
    showInstructionOverlay:
        input.showCompactInstructionOverlay &&
        !input.useFeltOverlayAsPromptSource &&
        !input.introCaptionActive,
    showOverlayGoalText:
        !input.compactPortrait || input.campaignHudDetailsExpanded,
    showProgressionStatus: input.progressionStatusText != null,
    stepHeaderKey: input.isCheckpointSession
        ? const Key('checkpoint_step_header')
        : (input.isTablePracticeSession
              ? const Key('table_practice_step_header')
              : const Key('microtask_step_header')),
    showGoldLearningSlicePreludeCard: input.showGoldLearningSlicePreludeCard,
    showConceptFirstSeatPreludeCard: input.showConceptFirstSeatPreludeCard,
    showHeaderPrompt: !input.useFeltOverlayAsPromptSource,
    showCampaignContext:
        input.isCampaignSpineSession &&
        input.hasContextText &&
        (!input.compactPortrait || input.campaignHudDetailsExpanded),
    showCampaignTradeoff:
        input.isCampaignSpineSession &&
        input.hasTradeoffText &&
        (!input.compactPortrait || input.campaignHudDetailsExpanded),
    showCampaignConsequence:
        input.isCampaignSpineSession &&
        input.hasConsequenceText &&
        (!input.compactPortrait || input.campaignHudDetailsExpanded),
    showCampaignHud: input.isCampaignSpineSession,
    showExtendedHudDetails:
        input.isCampaignSpineSession && input.showExtendedHudDetails,
    showBustBanner: input.pulseBust,
    showSuccessBadge: input.successBadgeText != null,
  );
}
