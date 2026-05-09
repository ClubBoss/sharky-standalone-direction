import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_table_instruction_surface_v1.dart';

void main() {
  test(
    'world1 canonical seat quiz instruction surface resolves track intro',
    () {
      final resolved = resolveWorld1CanonicalSeatQuizInstructionSurfaceV1(
        const World1CanonicalSeatQuizInstructionSurfaceInputV1(
          seatQuizVisualMode: true,
          handLoopVisualMode: false,
          globalTrainingOverlayActive: false,
          world1IntroOverlayActive: false,
          world1ActionIntroOverlayActive: false,
          world1StreetFlowIntroOverlayActive: false,
          world2HandoffOverlayActive: false,
          world2IntroOverlayActive: false,
          trackIntroOverlayActive: true,
          conceptPreludeInstructionSurfaceActive: false,
          actionLiteracyPreludeInstructionSurfaceActive: false,
          streetFlowPreludeInstructionSurfaceActive: false,
          seatQuizTableInstructionText: 'Tap BTN',
          cashTrackIntroOverlayText: 'Cash text',
          tournamentTrackIntroOverlayText: 'Tournament text',
          mixedTrackIntroOverlayText: 'Mixed text',
          trackIntroKind: 'tournament',
          conceptPreludePlacementText: 'Concept',
          actionLiteracyPlacementText: 'Action',
          streetFlowPlacementText: 'Street',
        ),
      );

      expect(
        resolved.kind,
        World1CanonicalSeatQuizInstructionSurfaceKindV1.overlayText,
      );
      expect(resolved.placementText, 'Tournament text');
      expect(
        resolved.overlayPreludeKey,
        const Key('microtask_tournament_track_intro_prelude_v1'),
      );
    },
  );

  test(
    'world1 canonical hand loop prompt surface resolves board-hosted prompt',
    () {
      final resolved = resolveWorld1CanonicalHandLoopPromptSurfaceV1(
        const World1CanonicalHandLoopPromptSurfaceInputV1(
          handLoopMode: true,
          isDemoHandLoopVisualStep: false,
          showSeatQuizPrelude: false,
          showIntroSequence: false,
          promptText: 'Choose the best action.',
          outcomeSurfaceVisible: false,
          debugCaptionOverrideVisible: false,
          runnerAuthorityIsReviewPass: false,
          runnerAuthorityVisibleBoardCount: 3,
          portraitLayout: false,
          reviewQueueSession: true,
        ),
      );

      expect(resolved.isAffectedStateFamily, isTrue);
      expect(resolved.usesFeltCaptionHost, isTrue);
      expect(resolved.isMounted, isTrue);
      expect(resolved.reviewQueuePrefix, isTrue);
    },
  );

  test(
    'shared instruction rect resolver keeps a visible fallback inside the intended lane',
    () {
      const stadiumRect = Rect.fromLTWH(40, 120, 310, 260);

      final fallbackRect = resolveSeatQuizTableInstructionRectV1(
        stadiumRect: stadiumRect,
        preferredWidth: 280,
        containerHeight: 104,
        avoidRects: const <Rect>[Rect.fromLTWH(30, 180, 330, 140)],
        laneTopFactor: 0.3,
        laneBottomFactor: 0.5,
      );

      expect(fallbackRect.left >= stadiumRect.left, isTrue);
      expect(fallbackRect.right <= stadiumRect.right, isTrue);
      expect(fallbackRect.top >= stadiumRect.top, isTrue);
      expect(fallbackRect.bottom <= stadiumRect.bottom, isTrue);
      expect(
        fallbackRect.top >= stadiumRect.top + (stadiumRect.height * 0.3),
        isTrue,
      );
    },
  );

  test('world1 canonical seat quiz task copy reuses shared order truth', () {
    final resolved = resolveWorld1CanonicalSeatQuizTaskCopyV1(
      const World1CanonicalSeatQuizTaskCopyInputV1(
        targetSeatId: 'btn',
        includeConfirmHint: false,
        seatOrderIds: <String>['btn', 'sb', 'bb', 'utg', 'hj', 'co'],
      ),
    );

    expect(resolved.primaryLine, 'Tap Button (Dealer).');
    expect(
      resolved.orderLine,
      'Order: Button -> Small Blind -> Big Blind -> UTG -> Hijack -> Cutoff.',
    );
    expect(
      resolved.promptText,
      'Tap Button (Dealer).\n'
      'Order: Button -> Small Blind -> Big Blind -> UTG -> Hijack -> Cutoff.',
    );
  });
}
