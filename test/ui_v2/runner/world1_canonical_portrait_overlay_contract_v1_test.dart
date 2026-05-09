import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/sharky/design_tokens_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_portrait_overlay_contract_v1.dart';

void main() {
  test('world1 canonical portrait overlay resolves outcome status body', () {
    final resolved = resolveWorld1CanonicalPortraitOverlayContractV1(
      const World1CanonicalPortraitOverlayContractInputV1(
        portraitLayout: true,
        handLoopVisualMode: false,
        showSeatQuizPrelude: false,
        showIntroSequence: false,
        outcomeSurfaceVisible: false,
        showHint: false,
        hasFeedback: false,
        showOutcomeHeaderStatus: true,
        showHintBubble: false,
        pulseFailure: false,
        feedbackText: null,
        hintText: 'Tap the button.',
      ),
    );

    expect(
      resolved.bodyKind,
      World1CanonicalPortraitOverlayBodyKindV1.outcomeStatus,
    );
  });

  test(
    'world1 canonical portrait overlay resolves feedback bubble color on failure',
    () {
      final resolved = resolveWorld1CanonicalPortraitOverlayContractV1(
        const World1CanonicalPortraitOverlayContractInputV1(
          portraitLayout: true,
          handLoopVisualMode: false,
          showSeatQuizPrelude: true,
          showIntroSequence: false,
          outcomeSurfaceVisible: false,
          showHint: false,
          hasFeedback: true,
          showOutcomeHeaderStatus: false,
          showHintBubble: false,
          pulseFailure: true,
          feedbackText: 'No seat selected.',
          hintText: 'Tap the button.',
        ),
      );

      expect(
        resolved.bodyKind,
        World1CanonicalPortraitOverlayBodyKindV1.feedbackBubble,
      );
      expect(resolved.feedbackText, 'No seat selected.');
      expect(resolved.feedbackTextColor, SharkyTokensV1.semanticLoss);
    },
  );

  testWidgets(
    'world1 canonical portrait overlay builds placeholder signals with hint key',
    (tester) async {
      const contract = World1CanonicalPortraitOverlayContractResolvedV1(
        bodyKind: World1CanonicalPortraitOverlayBodyKindV1.placeholderSignals,
        feedbackText: '',
        hintText: '',
        feedbackTextColor: Colors.transparent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: buildWorld1CanonicalPortraitOverlayBodyV1(
              contract: contract,
              maxWidth: 240,
              outcomeStatusChild: const SizedBox.shrink(),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('microtask_hint_bubble')), findsOneWidget);
    },
  );
}
