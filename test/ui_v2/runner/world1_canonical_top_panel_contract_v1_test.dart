import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_top_panel_contract_v1.dart';

void main() {
  test('world1 canonical top panel contract resolves campaign slots', () {
    final resolved = resolveWorld1CanonicalTopPanelContractV1(
      const World1CanonicalTopPanelContractInputV1(
        isCheckpointSession: false,
        isTablePracticeSession: true,
        useFeltOverlayAsPromptSource: false,
        showCompactInstructionOverlay: true,
        introCaptionActive: false,
        compactPortrait: false,
        campaignHudDetailsExpanded: false,
        progressionStatusText: 'Progression live',
        showGoldLearningSlicePreludeCard: true,
        showConceptFirstSeatPreludeCard: false,
        isCampaignSpineSession: true,
        hasContextText: true,
        hasTradeoffText: true,
        hasConsequenceText: true,
        showExtendedHudDetails: true,
        pulseBust: true,
        successBadgeText: 'Clean rep',
      ),
    );

    expect(resolved.showInstructionOverlay, isTrue);
    expect(resolved.showOverlayGoalText, isTrue);
    expect(resolved.showProgressionStatus, isTrue);
    expect(resolved.stepHeaderKey, const Key('table_practice_step_header'));
    expect(resolved.showGoldLearningSlicePreludeCard, isTrue);
    expect(resolved.showConceptFirstSeatPreludeCard, isFalse);
    expect(resolved.showHeaderPrompt, isTrue);
    expect(resolved.showCampaignContext, isTrue);
    expect(resolved.showCampaignTradeoff, isTrue);
    expect(resolved.showCampaignConsequence, isTrue);
    expect(resolved.showCampaignHud, isTrue);
    expect(resolved.showExtendedHudDetails, isTrue);
    expect(resolved.showBustBanner, isTrue);
    expect(resolved.showSuccessBadge, isTrue);
  });

  test(
    'world1 canonical top panel contract hides compact campaign details',
    () {
      final resolved = resolveWorld1CanonicalTopPanelContractV1(
        const World1CanonicalTopPanelContractInputV1(
          isCheckpointSession: true,
          isTablePracticeSession: false,
          useFeltOverlayAsPromptSource: true,
          showCompactInstructionOverlay: true,
          introCaptionActive: false,
          compactPortrait: true,
          campaignHudDetailsExpanded: false,
          progressionStatusText: null,
          showGoldLearningSlicePreludeCard: false,
          showConceptFirstSeatPreludeCard: true,
          isCampaignSpineSession: true,
          hasContextText: true,
          hasTradeoffText: true,
          hasConsequenceText: true,
          showExtendedHudDetails: false,
          pulseBust: false,
          successBadgeText: null,
        ),
      );

      expect(resolved.showInstructionOverlay, isFalse);
      expect(resolved.showProgressionStatus, isFalse);
      expect(resolved.stepHeaderKey, const Key('checkpoint_step_header'));
      expect(resolved.showGoldLearningSlicePreludeCard, isFalse);
      expect(resolved.showConceptFirstSeatPreludeCard, isTrue);
      expect(resolved.showHeaderPrompt, isFalse);
      expect(resolved.showCampaignContext, isFalse);
      expect(resolved.showCampaignTradeoff, isFalse);
      expect(resolved.showCampaignConsequence, isFalse);
      expect(resolved.showExtendedHudDetails, isFalse);
      expect(resolved.showBustBanner, isFalse);
      expect(resolved.showSuccessBadge, isFalse);
    },
  );
}
