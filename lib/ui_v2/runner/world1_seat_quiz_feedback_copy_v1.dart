import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';

enum World1SeatQuizFeedbackSliceV1 {
  conceptFirstSeat,
  actionLiteracy,
  streetFlow,
}

String resolveWorld1SeatQuizMismatchFixLineV1({
  required World1SeatQuizFeedbackSliceV1 slice,
  required int stepIndex,
  String? expectedSeatId,
}) {
  switch (slice) {
    case World1SeatQuizFeedbackSliceV1.conceptFirstSeat:
      switch (expectedSeatId?.trim().toLowerCase()) {
        case 'btn':
          return 'Fix: Start from Button, then read clockwise.';
        case 'sb':
          return 'Fix: Small Blind is first after Button.';
        case 'bb':
          return 'Fix: Big Blind comes right after Small Blind.';
        default:
          return 'Fix: Start from the marked seat, then read clockwise.';
      }
    case World1SeatQuizFeedbackSliceV1.actionLiteracy:
      switch (stepIndex) {
        case 0:
          return 'Fix: Move one seat clockwise from Button.';
        case 1:
          return 'Fix: Button comes right after Cutoff.';
        case 2:
          return 'Fix: Small Blind is first after Button.';
        default:
          return 'Fix: Follow seat order to the next player.';
      }
    case World1SeatQuizFeedbackSliceV1.streetFlow:
      switch (stepIndex) {
        case 0:
          return 'Fix: Find Button before the street changes.';
        case 1:
          return 'Fix: Big Blind finishes the blind pair.';
        case 2:
          return 'Fix: After the blinds, move to the next live seat.';
        default:
          return 'Fix: Keep the same seat map as the street changes.';
      }
  }
}

String buildWorld1SeatQuizExpectedChosenFeedbackLineV1({
  required String expectedLabel,
  required String chosenLabel,
  String? fixLine,
}) {
  return buildSharedLearnerFeedbackExplanationV1(
    verdict: SharedLearnerFeedbackVerdictV1.fail,
    comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
    expectedLabel: expectedLabel,
    chosenLabel: chosenLabel,
    guidanceText: fixLine,
  ).composeInlineText();
}
