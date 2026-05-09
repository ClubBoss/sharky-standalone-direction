import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_seat_quiz_feedback_copy_v1.dart';

void main() {
  group('world1 seat quiz feedback copy', () {
    test(
      'builds factual expected/chosen correction line for concept-first bb',
      () {
        final fixLine = resolveWorld1SeatQuizMismatchFixLineV1(
          slice: World1SeatQuizFeedbackSliceV1.conceptFirstSeat,
          stepIndex: 0,
          expectedSeatId: 'bb',
        );
        final feedbackLine = buildWorld1SeatQuizExpectedChosenFeedbackLineV1(
          expectedLabel: 'BB',
          chosenLabel: 'SB',
          fixLine: fixLine,
        );

        expect(fixLine, 'Fix: Big Blind comes right after Small Blind.');
        expect(
          feedbackLine,
          'Better answer: BB. SB misses this scene. '
          'Next time: Big Blind comes right after Small Blind.',
        );
      },
    );

    test('builds action-literacy correction from seat-order step', () {
      final fixLine = resolveWorld1SeatQuizMismatchFixLineV1(
        slice: World1SeatQuizFeedbackSliceV1.actionLiteracy,
        stepIndex: 1,
      );

      expect(fixLine, 'Fix: Button comes after Cutoff.');
    });

    test('builds street-flow correction from blind-pair anchor step', () {
      final fixLine = resolveWorld1SeatQuizMismatchFixLineV1(
        slice: World1SeatQuizFeedbackSliceV1.streetFlow,
        stepIndex: 1,
      );

      expect(fixLine, 'Fix: Big Blind closes the blind pair.');
    });

    test('falls back to generic correction for uncategorized seat quiz', () {
      final fixLine = resolveWorld1SeatQuizMismatchFixLineV1(
        slice: World1SeatQuizFeedbackSliceV1.generic,
        stepIndex: 9,
      );

      expect(
        fixLine,
        'Fix: Start from the seat anchor, then follow seat order.',
      );
    });
  });
}
