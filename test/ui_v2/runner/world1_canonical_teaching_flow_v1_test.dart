import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_teaching_flow_v1.dart';

void main() {
  test('world1 canonical teaching flow resolves hand-loop action teaching', () {
    final resolved = resolveWorld1CanonicalTeachingFlowV1(
      const World1CanonicalTeachingFlowInputV1(
        sourceId: 'world1#step1',
        canonicalPrompt: 'Tap Button.',
        handLoopMode: true,
        currentModeIsHandLoop: true,
        isDemoHandLoopVisualStep: false,
        showHandLoopActionBar: true,
        introCaptionActive: false,
        showSeatQuizPrelude: false,
        showIntroSequence: false,
        isCampaignSpineSession: true,
        isSeatQuizStep: false,
        outcomeVisible: false,
        completionInProgress: false,
        enginePlaybackBusy: false,
        selectedSeatId: null,
        introSequenceIndex: 0,
        introCoachRailTotal: 3,
        handLoopPrompt: 'Bet half pot.',
        seatQuizInstruction: 'Tap Button.',
        seatQuizPreviewTitle: 'Preview',
        seatQuizPreviewSubtitle: '',
        seatQuizFallbackGuidanceTitle: 'Fallback',
      ),
    );

    expect(resolved.displayedPrompt, 'Bet half pot.');
    expect(resolved.detailsPromptOverride, 'Choose the best action.');
    expect(resolved.effectiveTopPrompt, 'Bet half pot.');
    expect(resolved.lockInNeedsSeatSelection, isFalse);
    expect(resolved.allowSeatQuizConfirmPanel, isTrue);
  });

  test('world1 canonical teaching flow resolves seat-quiz intro coaching', () {
    final resolved = resolveWorld1CanonicalTeachingFlowV1(
      const World1CanonicalTeachingFlowInputV1(
        sourceId: 'world1#step2',
        canonicalPrompt: 'Tap Small Blind.',
        handLoopMode: false,
        currentModeIsHandLoop: false,
        isDemoHandLoopVisualStep: false,
        showHandLoopActionBar: false,
        introCaptionActive: true,
        showSeatQuizPrelude: true,
        showIntroSequence: false,
        isCampaignSpineSession: true,
        isSeatQuizStep: true,
        outcomeVisible: false,
        completionInProgress: false,
        enginePlaybackBusy: false,
        selectedSeatId: null,
        introSequenceIndex: 0,
        introCoachRailTotal: 4,
        seatQuizInstruction: 'Tap Small Blind.',
        seatQuizPreviewTitle: 'Find the blind',
        seatQuizPreviewSubtitle: 'Use the anchor seat first.',
        seatQuizFallbackGuidanceTitle: 'Fallback',
      ),
    );

    expect(resolved.detailsPromptOverride, 'Tap Small Blind.');
    expect(resolved.effectiveTopPrompt, 'Follow caption.');
    expect(resolved.introCoachTitle, 'Find the blind');
    expect(resolved.introCoachSubtitleRaw, 'Use the anchor seat first.');
    expect(resolved.showIntroCoachSubtitle, isTrue);
    expect(resolved.introCoachRailActiveIndex, 0);
    expect(resolved.lockInNeedsSeatSelection, isFalse);
    expect(resolved.allowSeatQuizConfirmPanel, isFalse);
  });
}
