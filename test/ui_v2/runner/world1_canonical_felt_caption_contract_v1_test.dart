import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_felt_caption_contract_v1.dart';

void main() {
  test('world1 canonical felt caption resolves review prompt container', () {
    final resolved = resolveWorld1CanonicalFeltCaptionContractV1(
      const World1CanonicalFeltCaptionContractInputV1(
        portraitLayout: true,
        affectedStateFamily: true,
        usesFeltCaptionHost: true,
        isMounted: true,
        showSeatQuizPrelude: false,
        showIntroSequence: false,
        handLoopVisualMode: true,
        outcomeSurfaceVisible: false,
        debugCaptionOverridePresent: false,
        isDemoHandLoopVisualStep: false,
        reviewQueuePrefix: true,
        compactPortrait: true,
        rotatedSbBbDensityRefine: false,
        mountedPromptText: 'Choose the best action.',
        fallbackPromptText: 'Fallback',
        mountedMaxWidth: 220,
        fallbackMaxWidth: 180,
      ),
    );

    expect(resolved.showsPositionedCaption, isTrue);
    expect(
      resolved.bodyKind,
      World1CanonicalFeltCaptionBodyKindV1.promptContainer,
    );
    expect(resolved.useReviewPrefix, isTrue);
    expect(resolved.promptText, 'Choose the best action.');
    expect(resolved.maxWidth, 220);
  });

  testWidgets('world1 canonical felt caption builds zero opacity placeholder', (
    tester,
  ) async {
    final resolved = resolveWorld1CanonicalFeltCaptionContractV1(
      const World1CanonicalFeltCaptionContractInputV1(
        portraitLayout: true,
        affectedStateFamily: false,
        usesFeltCaptionHost: false,
        isMounted: false,
        showSeatQuizPrelude: false,
        showIntroSequence: false,
        handLoopVisualMode: true,
        outcomeSurfaceVisible: true,
        debugCaptionOverridePresent: false,
        isDemoHandLoopVisualStep: false,
        reviewQueuePrefix: false,
        compactPortrait: false,
        rotatedSbBbDensityRefine: false,
        mountedPromptText: '',
        fallbackPromptText: 'Fallback',
        mountedMaxWidth: 0,
        fallbackMaxWidth: 180,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: buildWorld1CanonicalFeltCaptionBodyV1(resolved)),
      ),
    );

    expect(
      resolved.bodyKind,
      World1CanonicalFeltCaptionBodyKindV1.zeroOpacityPlaceholder,
    );
    expect(find.byKey(const Key('microtask_step_prompt')), findsOneWidget);
  });
}
