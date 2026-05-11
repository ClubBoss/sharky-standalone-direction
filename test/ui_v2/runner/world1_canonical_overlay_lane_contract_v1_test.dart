import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_overlay_lane_contract_v1.dart';

void main() {
  test(
    'world1 canonical overlay lane contract resolves caption coexistence',
    () {
      final resolved = resolveWorld1CanonicalOverlayLaneContractV1(
        World1CanonicalOverlayLaneContractInputV1(
          canvasSize: const Size(390, 320),
          stadiumRect: const Rect.fromLTWH(40, 30, 310, 240),
          boardRect: const Rect.fromLTWH(120, 95, 150, 46),
          potRect: const Rect.fromLTWH(155, 70, 80, 30),
          heroCardsRect: const Rect.fromLTWH(145, 225, 100, 40),
          seatAvoidRects: const <Rect>[
            Rect.fromLTWH(55, 45, 56, 56),
            Rect.fromLTWH(280, 45, 56, 56),
          ],
          boardVisible: true,
          seatQuizVisualMode: false,
          handLoopVisualMode: true,
          demoHandLoopVisualStep: false,
          compactPortrait: true,
          seatVisualRadius: 24,
          cueRadius: 8.5,
          dealerCueCenter: const Offset(190, 230),
          sbCueCenter: const Offset(110, 200),
          bbCueCenter: const Offset(110, 120),
          demoPromptToHeroGap: 18,
          rotatingHeroSeatId: 'sb',
          promptAffectedStateFamily: true,
          promptUsesFeltCaptionHost: true,
        ),
      );

      expect(resolved.overlayLaneRect.height, greaterThan(0));
      expect(
        resolved.feltCaptionTop,
        greaterThanOrEqualTo(resolved.overlayLaneRect.top),
      );
      expect(resolved.handLoopPromptTopBand, isNotNull);
      expect(resolved.feltCaptionLeft, lessThan(resolved.feltCaptionRight));
    },
  );

  test(
    'world1 canonical overlay lane contract clamps demo caption above hero cards',
    () {
      final resolved = resolveWorld1CanonicalOverlayLaneContractV1(
        World1CanonicalOverlayLaneContractInputV1(
          canvasSize: const Size(420, 340),
          stadiumRect: const Rect.fromLTWH(50, 28, 320, 250),
          boardRect: const Rect.fromLTWH(130, 110, 160, 48),
          potRect: const Rect.fromLTWH(170, 82, 80, 28),
          heroCardsRect: const Rect.fromLTWH(150, 245, 120, 42),
          seatAvoidRects: const <Rect>[],
          boardVisible: true,
          seatQuizVisualMode: false,
          handLoopVisualMode: true,
          demoHandLoopVisualStep: true,
          compactPortrait: false,
          seatVisualRadius: 28,
          cueRadius: 8.5,
          dealerCueCenter: const Offset(210, 235),
          sbCueCenter: const Offset(120, 210),
          bbCueCenter: const Offset(120, 120),
          demoPromptToHeroGap: 20,
          rotatingHeroSeatId: 'bb',
          promptAffectedStateFamily: false,
          promptUsesFeltCaptionHost: false,
        ),
      );

      expect(
        resolved.feltCaptionTop + resolved.feltCaptionMaxHeightAllowance,
        lessThanOrEqualTo(245 - 20),
      );
    },
  );
}
