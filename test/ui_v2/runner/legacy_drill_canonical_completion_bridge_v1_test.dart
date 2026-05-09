import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/legacy_drill_canonical_completion_bridge_v1.dart';

void main() {
  test('quiz result sheet plan resolves title, feedback, label, and scoring', () {
    final passPlan =
        LegacyDrillCanonicalCompletionBridgeV1.resolveQuizResultSheetPlan(
          isCorrect: true,
          isFinalItem: false,
          correctFeedback: 'Correct feedback',
          incorrectFeedback: 'Incorrect feedback',
        );
    expect(passPlan.titleText, 'Correct!');
    expect(passPlan.feedbackText, 'Correct feedback');
    expect(passPlan.primaryLabel, 'NEXT DRILL');
    expect(passPlan.primaryCountsAsCorrect, isTrue);

    final failFinalPlan =
        LegacyDrillCanonicalCompletionBridgeV1.resolveQuizResultSheetPlan(
          isCorrect: false,
          isFinalItem: true,
          correctFeedback: 'Correct feedback',
          incorrectFeedback: 'Incorrect feedback',
        );
    expect(failFinalPlan.titleText, 'Incorrect');
    expect(failFinalPlan.feedbackText, 'Incorrect feedback');
    expect(failFinalPlan.primaryLabel, 'FINISH');
    expect(failFinalPlan.primaryCountsAsCorrect, isFalse);
  });

  test('reveal completion plan resolves CTA semantics and success effects', () {
    final inRunPlan =
        LegacyDrillCanonicalCompletionBridgeV1.resolveRevealCompletionPlan(
          isFinalItem: false,
        );
    expect(inRunPlan.primaryLabel, 'Got it');
    expect(inRunPlan.secondaryLabel, 'Missed it');
    expect(inRunPlan.primaryCountsAsCorrect, isTrue);
    expect(inRunPlan.showsSecondaryAction, isTrue);
    expect(inRunPlan.firesSuccessEffectsOnPrimary, isTrue);

    final finalPlan =
        LegacyDrillCanonicalCompletionBridgeV1.resolveRevealCompletionPlan(
          isFinalItem: true,
        );
    expect(finalPlan.primaryLabel, 'FINISH');
    expect(finalPlan.secondaryLabel, isNull);
    expect(finalPlan.showsSecondaryAction, isFalse);
  });
}
