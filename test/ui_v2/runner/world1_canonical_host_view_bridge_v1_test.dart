import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_host_view_bridge_v1.dart';

void main() {
  test(
    'world1 canonical host view bridge suppresses hand-loop mode for world2 seat quiz override',
    () {
      var seatPreludeTriggered = false;
      final resolved = resolveWorld1CanonicalHostViewBridgeV1(
        World1CanonicalHostViewBridgeInputV1(
          moduleId: 'world1_spine_campaign_v1',
          stepIndex: 0,
          totalSteps: 3,
          isWorld2SeatQuizBeat: true,
          stepIndicatesActionDecision: true,
          isCampaignSpineSession: true,
          currentModeIsSeatQuiz: true,
          currentModeIsHandLoop: false,
          rawHandLoopMode: true,
          showHandLoopActionBar: false,
          isDemoHandLoopVisualStep: false,
          introCaptionActive: false,
          showSeatQuizPrelude: true,
          showIntroSequence: false,
          outcomeVisible: false,
          completionInProgress: false,
          enginePlaybackBusy: false,
          selectedSeatId: null,
          introSequenceIndex: 0,
          introCoachRailTotal: 2,
          canonicalPrompt: 'Prompt',
          handLoopPrompt: 'Hand loop prompt',
          seatQuizInstruction: 'Seat quiz instruction',
          activeIntroCoachTitle: null,
          activeIntroCoachSubtitle: null,
          seatQuizPreviewTitle: 'Preview',
          seatQuizPreviewSubtitle: 'Preview subtitle',
          introSequencePrompt: null,
          guidedSeatSubtitle: null,
          seatQuizFallbackGuidanceTitle: 'Fallback',
          onSeatQuizPreludeContinue: () {
            seatPreludeTriggered = true;
          },
          onIntroSequenceContinue: null,
        ),
      );

      expect(resolved.isSeatQuizStep, isTrue);
      expect(resolved.handLoopMode, isFalse);
      expect(resolved.hideAppBarBack, isTrue);
      expect(resolved.teachingFlow.displayedPrompt, 'Prompt');

      resolved.introCaptionContinueOnPressed?.call();
      expect(seatPreludeTriggered, isTrue);
    },
  );

  test(
    'world1 canonical host view bridge selects intro sequence delegate when prelude is inactive',
    () {
      var introContinueTriggered = false;
      final resolved = resolveWorld1CanonicalHostViewBridgeV1(
        World1CanonicalHostViewBridgeInputV1(
          moduleId: 'world1_spine_campaign_v1',
          stepIndex: 1,
          totalSteps: 4,
          isWorld2SeatQuizBeat: false,
          stepIndicatesActionDecision: false,
          isCampaignSpineSession: true,
          currentModeIsSeatQuiz: true,
          currentModeIsHandLoop: false,
          rawHandLoopMode: false,
          showHandLoopActionBar: false,
          isDemoHandLoopVisualStep: false,
          introCaptionActive: false,
          showSeatQuizPrelude: false,
          showIntroSequence: true,
          outcomeVisible: false,
          completionInProgress: false,
          enginePlaybackBusy: false,
          selectedSeatId: null,
          introSequenceIndex: 1,
          introCoachRailTotal: 3,
          canonicalPrompt: 'Prompt',
          handLoopPrompt: null,
          seatQuizInstruction: 'Seat quiz instruction',
          activeIntroCoachTitle: 'Coach',
          activeIntroCoachSubtitle: 'Subtitle',
          seatQuizPreviewTitle: 'Preview',
          seatQuizPreviewSubtitle: 'Preview subtitle',
          introSequencePrompt: 'Intro step',
          guidedSeatSubtitle: 'Guide',
          seatQuizFallbackGuidanceTitle: 'Fallback',
          onSeatQuizPreludeContinue: null,
          onIntroSequenceContinue: () {
            introContinueTriggered = true;
          },
        ),
      );

      expect(resolved.isSeatQuizStep, isTrue);
      expect(resolved.handLoopMode, isFalse);
      expect(resolved.progress, closeTo(0.5, 0.0001));

      resolved.introCaptionContinueOnPressed?.call();
      expect(introContinueTriggered, isTrue);
    },
  );
}
