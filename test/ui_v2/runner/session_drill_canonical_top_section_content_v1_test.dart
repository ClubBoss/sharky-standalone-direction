import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_surface_family_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/session_drill_canonical_top_section_content_v1.dart';

void main() {
  test(
    'session drill generic top-section policy keeps generic supplements',
    () {
      final policy = buildSessionDrillCanonicalTopSectionContentPolicyV1(
        renderSurfaceFamily: SessionDrillCanonicalRenderSurfaceFamilyV1.generic,
        handoffContextPresent: true,
        isCompleted: false,
        showsEmbeddedScenarioTable: true,
        showsEmbeddedFeedbackBelowTable: false,
        specKind: DrillKindV1.handChain,
        showBetSizingIntroCard: true,
        showWorld2ShowdownIntroCard: true,
        showWorld3PreflopBridgeIntroCard: false,
        showWorld10TrackRootIntroCard: true,
        showWorld2PositionIntroCard: false,
        showWorld2InitiativeIntroCard: false,
        showWorld2BoardTextureIntroCard: false,
        showWorld2ReviewIntroCard: false,
        showWorld2OutsIntroCard: false,
        showWorld2ShowdownScenarioMeta: true,
        showWorld2PositionScenarioMeta: false,
        showWorld2InitiativeScenarioMeta: false,
        showWorld2OutsScenarioMeta: false,
        showWorld2TextureScenarioMeta: false,
        showBetSizingRecapCard: true,
        showWorld2ShowdownRecapCard: false,
        showWorld2PositionRecapCard: false,
        showWorld2InitiativeRecapCard: false,
        showWorld2BoardTextureRecapCard: false,
        showWorld2ReviewRecapCard: false,
        showWorld2OutsRecapCard: false,
        showWorld2CapstoneRecapCard: false,
        showWorld2BlockCompletionReviewCard: false,
        showWorld3BlockCompletionReviewCard: false,
        showWorld4BlockCompletionReviewCard: false,
      );

      expect(policy.showHandoffStatusLine, isTrue);
      expect(policy.showBetSizingIntroCard, isTrue);
      expect(policy.showWorld10TrackRootIntroCard, isTrue);
      expect(policy.showWorld2ShowdownScenarioMeta, isTrue);
      expect(policy.showHandChainScenarioMeta, isTrue);
      expect(policy.showFeedbackAboveTable, isTrue);
      expect(policy.statusLetterSpacing, 0.22);
      expect(policy.statusSpacingAfter, 4);
    },
  );

  test('session drill world2 surfaced policy hides generic supplements', () {
    final policy = buildSessionDrillCanonicalTopSectionContentPolicyV1(
      renderSurfaceFamily:
          SessionDrillCanonicalRenderSurfaceFamilyV1.world2Surfaced,
      handoffContextPresent: true,
      isCompleted: false,
      showsEmbeddedScenarioTable: true,
      showsEmbeddedFeedbackBelowTable: true,
      specKind: DrillKindV1.handChain,
      showBetSizingIntroCard: true,
      showWorld2ShowdownIntroCard: true,
      showWorld3PreflopBridgeIntroCard: true,
      showWorld10TrackRootIntroCard: true,
      showWorld2PositionIntroCard: true,
      showWorld2InitiativeIntroCard: true,
      showWorld2BoardTextureIntroCard: true,
      showWorld2ReviewIntroCard: true,
      showWorld2OutsIntroCard: true,
      showWorld2ShowdownScenarioMeta: true,
      showWorld2PositionScenarioMeta: true,
      showWorld2InitiativeScenarioMeta: true,
      showWorld2OutsScenarioMeta: true,
      showWorld2TextureScenarioMeta: true,
      showBetSizingRecapCard: true,
      showWorld2ShowdownRecapCard: true,
      showWorld2PositionRecapCard: true,
      showWorld2InitiativeRecapCard: true,
      showWorld2BoardTextureRecapCard: true,
      showWorld2ReviewRecapCard: true,
      showWorld2OutsRecapCard: true,
      showWorld2CapstoneRecapCard: true,
      showWorld2BlockCompletionReviewCard: true,
      showWorld3BlockCompletionReviewCard: true,
      showWorld4BlockCompletionReviewCard: true,
    );

    expect(policy.showBetSizingIntroCard, isFalse);
    expect(policy.showWorld2ShowdownIntroCard, isFalse);
    expect(policy.showWorld10TrackRootIntroCard, isFalse);
    expect(policy.showWorld2ShowdownScenarioMeta, isFalse);
    expect(policy.showHandChainScenarioMeta, isFalse);
    expect(policy.showBetSizingRecapCard, isFalse);
    expect(policy.showFeedbackAboveTable, isFalse);
    expect(policy.statusLetterSpacing, 0.12);
    expect(policy.statusSpacingAfter, 3);
  });
}
