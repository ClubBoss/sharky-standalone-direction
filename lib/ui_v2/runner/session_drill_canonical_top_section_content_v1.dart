import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_surface_family_v1.dart';

class SessionDrillCanonicalTopSectionContentPolicyV1 {
  const SessionDrillCanonicalTopSectionContentPolicyV1({
    required this.showHandoffStatusLine,
    required this.showCompletedState,
    required this.statusLetterSpacing,
    required this.statusSpacingAfter,
    required this.showPromptAsEmbeddedTitle,
    required this.showFeedbackAboveTable,
    required this.showBetSizingIntroCard,
    required this.showWorld2ShowdownIntroCard,
    required this.showWorld3PreflopBridgeIntroCard,
    required this.showWorld10TrackRootIntroCard,
    required this.showWorld2PositionIntroCard,
    required this.showWorld2InitiativeIntroCard,
    required this.showWorld2BoardTextureIntroCard,
    required this.showWorld2ReviewIntroCard,
    required this.showWorld2OutsIntroCard,
    required this.showWorld2ShowdownScenarioMeta,
    required this.showWorld2PositionScenarioMeta,
    required this.showWorld2InitiativeScenarioMeta,
    required this.showWorld2OutsScenarioMeta,
    required this.showWorld2TextureScenarioMeta,
    required this.showHandChainScenarioMeta,
    required this.showBetSizingRecapCard,
    required this.showWorld2ShowdownRecapCard,
    required this.showWorld2PositionRecapCard,
    required this.showWorld2InitiativeRecapCard,
    required this.showWorld2BoardTextureRecapCard,
    required this.showWorld2ReviewRecapCard,
    required this.showWorld2OutsRecapCard,
    required this.showWorld2CapstoneRecapCard,
    required this.showWorld2BlockCompletionReviewCard,
    required this.showWorld3BlockCompletionReviewCard,
    required this.showWorld4BlockCompletionReviewCard,
    required this.showTextLedReviewModeCohesion,
  });

  final bool showHandoffStatusLine;
  final bool showCompletedState;
  final double statusLetterSpacing;
  final double statusSpacingAfter;
  final bool showPromptAsEmbeddedTitle;
  final bool showFeedbackAboveTable;
  final bool showBetSizingIntroCard;
  final bool showWorld2ShowdownIntroCard;
  final bool showWorld3PreflopBridgeIntroCard;
  final bool showWorld10TrackRootIntroCard;
  final bool showWorld2PositionIntroCard;
  final bool showWorld2InitiativeIntroCard;
  final bool showWorld2BoardTextureIntroCard;
  final bool showWorld2ReviewIntroCard;
  final bool showWorld2OutsIntroCard;
  final bool showWorld2ShowdownScenarioMeta;
  final bool showWorld2PositionScenarioMeta;
  final bool showWorld2InitiativeScenarioMeta;
  final bool showWorld2OutsScenarioMeta;
  final bool showWorld2TextureScenarioMeta;
  final bool showHandChainScenarioMeta;
  final bool showBetSizingRecapCard;
  final bool showWorld2ShowdownRecapCard;
  final bool showWorld2PositionRecapCard;
  final bool showWorld2InitiativeRecapCard;
  final bool showWorld2BoardTextureRecapCard;
  final bool showWorld2ReviewRecapCard;
  final bool showWorld2OutsRecapCard;
  final bool showWorld2CapstoneRecapCard;
  final bool showWorld2BlockCompletionReviewCard;
  final bool showWorld3BlockCompletionReviewCard;
  final bool showWorld4BlockCompletionReviewCard;
  final bool showTextLedReviewModeCohesion;
}

SessionDrillCanonicalTopSectionContentPolicyV1
buildSessionDrillCanonicalTopSectionContentPolicyV1({
  required SessionDrillCanonicalRenderSurfaceFamilyV1 renderSurfaceFamily,
  required bool handoffContextPresent,
  required bool isCompleted,
  required bool showsEmbeddedScenarioTable,
  required bool showsEmbeddedFeedbackBelowTable,
  required DrillKindV1 specKind,
  required bool showBetSizingIntroCard,
  required bool showWorld2ShowdownIntroCard,
  required bool showWorld3PreflopBridgeIntroCard,
  required bool showWorld10TrackRootIntroCard,
  required bool showWorld2PositionIntroCard,
  required bool showWorld2InitiativeIntroCard,
  required bool showWorld2BoardTextureIntroCard,
  required bool showWorld2ReviewIntroCard,
  required bool showWorld2OutsIntroCard,
  required bool showWorld2ShowdownScenarioMeta,
  required bool showWorld2PositionScenarioMeta,
  required bool showWorld2InitiativeScenarioMeta,
  required bool showWorld2OutsScenarioMeta,
  required bool showWorld2TextureScenarioMeta,
  required bool showBetSizingRecapCard,
  required bool showWorld2ShowdownRecapCard,
  required bool showWorld2PositionRecapCard,
  required bool showWorld2InitiativeRecapCard,
  required bool showWorld2BoardTextureRecapCard,
  required bool showWorld2ReviewRecapCard,
  required bool showWorld2OutsRecapCard,
  required bool showWorld2CapstoneRecapCard,
  required bool showWorld2BlockCompletionReviewCard,
  required bool showWorld3BlockCompletionReviewCard,
  required bool showWorld4BlockCompletionReviewCard,
}) {
  final hidesGenericSupplements =
      renderSurfaceFamily ==
      SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced;
  final showTextLedReviewModeCohesion =
      !hidesGenericSupplements &&
      !showsEmbeddedScenarioTable &&
      (showWorld2ReviewIntroCard || showWorld2ReviewRecapCard);
  return SessionDrillCanonicalTopSectionContentPolicyV1(
    showHandoffStatusLine: handoffContextPresent && !isCompleted,
    showCompletedState: isCompleted,
    statusLetterSpacing: hidesGenericSupplements ? 0.12 : 0.22,
    statusSpacingAfter: hidesGenericSupplements ? 3 : 4,
    showPromptAsEmbeddedTitle: showsEmbeddedScenarioTable,
    showFeedbackAboveTable: !showsEmbeddedFeedbackBelowTable,
    showBetSizingIntroCard: !hidesGenericSupplements && showBetSizingIntroCard,
    showWorld2ShowdownIntroCard:
        !hidesGenericSupplements && showWorld2ShowdownIntroCard,
    showWorld3PreflopBridgeIntroCard:
        !hidesGenericSupplements && showWorld3PreflopBridgeIntroCard,
    showWorld10TrackRootIntroCard:
        !hidesGenericSupplements && showWorld10TrackRootIntroCard,
    showWorld2PositionIntroCard:
        !hidesGenericSupplements && showWorld2PositionIntroCard,
    showWorld2InitiativeIntroCard:
        !hidesGenericSupplements && showWorld2InitiativeIntroCard,
    showWorld2BoardTextureIntroCard:
        !hidesGenericSupplements && showWorld2BoardTextureIntroCard,
    showWorld2ReviewIntroCard:
        !hidesGenericSupplements && showWorld2ReviewIntroCard,
    showWorld2OutsIntroCard:
        !hidesGenericSupplements && showWorld2OutsIntroCard,
    showWorld2ShowdownScenarioMeta:
        !hidesGenericSupplements && showWorld2ShowdownScenarioMeta,
    showWorld2PositionScenarioMeta:
        !hidesGenericSupplements && showWorld2PositionScenarioMeta,
    showWorld2InitiativeScenarioMeta:
        !hidesGenericSupplements && showWorld2InitiativeScenarioMeta,
    showWorld2OutsScenarioMeta:
        !hidesGenericSupplements && showWorld2OutsScenarioMeta,
    showWorld2TextureScenarioMeta:
        !hidesGenericSupplements && showWorld2TextureScenarioMeta,
    showHandChainScenarioMeta:
        !hidesGenericSupplements &&
        !isCompleted &&
        specKind == DrillKindV1.handChain,
    showBetSizingRecapCard: !hidesGenericSupplements && showBetSizingRecapCard,
    showWorld2ShowdownRecapCard:
        !hidesGenericSupplements && showWorld2ShowdownRecapCard,
    showWorld2PositionRecapCard:
        !hidesGenericSupplements && showWorld2PositionRecapCard,
    showWorld2InitiativeRecapCard:
        !hidesGenericSupplements && showWorld2InitiativeRecapCard,
    showWorld2BoardTextureRecapCard:
        !hidesGenericSupplements && showWorld2BoardTextureRecapCard,
    showWorld2ReviewRecapCard:
        !hidesGenericSupplements && !isCompleted && showWorld2ReviewRecapCard,
    showWorld2OutsRecapCard:
        !hidesGenericSupplements && showWorld2OutsRecapCard,
    showWorld2CapstoneRecapCard:
        !hidesGenericSupplements && showWorld2CapstoneRecapCard,
    showWorld2BlockCompletionReviewCard:
        !hidesGenericSupplements && showWorld2BlockCompletionReviewCard,
    showWorld3BlockCompletionReviewCard:
        !hidesGenericSupplements && showWorld3BlockCompletionReviewCard,
    showWorld4BlockCompletionReviewCard:
        !hidesGenericSupplements && showWorld4BlockCompletionReviewCard,
    showTextLedReviewModeCohesion: showTextLedReviewModeCohesion,
  );
}
