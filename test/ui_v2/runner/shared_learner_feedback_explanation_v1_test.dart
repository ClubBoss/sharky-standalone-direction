import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';

void main() {
  group('shared learner feedback explanation', () {
    test('formats stronger-line fail feedback in learner-facing grammar', () {
      final explanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
        expectedLabel: 'RAISE TO',
        chosenLabel: 'CALL',
        teachingText: 'Why: Facing the bet, aggression keeps initiative.',
        guidanceText:
            'Fix: Facing a bet here, raise instead of taking the passive line.',
      );

      expect(
        explanation.headlineText,
        'Better line: RAISE TO. CALL is weaker here.',
      );
      expect(
        explanation.teachingText,
        'Notice: Facing the bet, aggression keeps initiative.',
      );
      expect(
        explanation.guidanceText,
        'Next time: Facing a bet here, raise instead of taking the passive line.',
      );
    });

    test('formats correct-answer fail feedback without raw system labels', () {
      final explanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: 'BB',
        chosenLabel: 'SB',
        guidanceText: 'Fix: Big Blind comes right after Small Blind.',
      );

      expect(
        explanation.headlineText,
        'Better answer: BB. SB misses this scene.',
      );
      expect(
        explanation.guidanceText,
        'Next time: Big Blind comes right after Small Blind.',
      );
    });

    test('formats soft-pass feedback without placeholder wording', () {
      final explanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.softPass,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
        expectedLabel: 'HALF POT',
        chosenLabel: 'ONE THIRD POT',
      );

      expect(
        explanation.headlineText,
        'ONE THIRD POT works, but HALF POT is the stronger line here.',
      );
    });

    test('parses inline learner-facing explanation back into structured lines', () {
      final parsed = tryParseSharedLearnerFeedbackExplanationV1(
        'Better line: RAISE TO. CALL is weaker here. '
        'Notice: Facing the bet, aggression keeps initiative. '
        'Next time: Facing a bet here, raise instead of taking the passive line.',
      );

      expect(parsed, isNotNull);
      expect(
        parsed!.headlineText,
        'Better line: RAISE TO. CALL is weaker here.',
      );
      expect(
        parsed.teachingText,
        'Notice: Facing the bet, aggression keeps initiative.',
      );
      expect(
        parsed.guidanceText,
        'Next time: Facing a bet here, raise instead of taking the passive line.',
      );
    });
  });
}
