import 'package:poker_analyzer/engine_v2/model/action_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';

String resolveWorld1HandLoopMismatchFixLineV1({
  required ActionKindV1? expectedActionKind,
  required String expectedLabel,
  int? toCallMilliBb,
}) {
  switch (expectedActionKind) {
    case ActionKindV1.fold:
      return 'Fix: Facing a bet here, fold instead of continuing.';
    case ActionKindV1.check:
      return 'Fix: No bet is on you, so check instead of putting chips in.';
    case ActionKindV1.call:
      if ((toCallMilliBb ?? 0) > 0) {
        return 'Fix: Facing a bet here, call before adding extra chips.';
      }
      return 'Fix: Match the current price before you continue.';
    case ActionKindV1.bet:
      return 'Fix: No bet is on you, so take initiative with a bet.';
    case ActionKindV1.raise:
      if ((toCallMilliBb ?? 0) > 0) {
        return 'Fix: Facing a bet here, raise instead of taking the passive line.';
      }
      return 'Fix: Use the aggressive raise line the spot calls for.';
    case null:
      if (expectedLabel.startsWith('RAISE')) {
        return 'Fix: Choose the raise line instead of the passive option.';
      }
      if (expectedLabel.startsWith('CALL')) {
        return 'Fix: Match the current price before you continue.';
      }
      if (expectedLabel.startsWith('CHECK')) {
        return 'Fix: No bet is on you, so check instead of putting chips in.';
      }
      if (expectedLabel.startsWith('BET')) {
        return 'Fix: No bet is on you, so take initiative with a bet.';
      }
      if (expectedLabel.startsWith('FOLD')) {
        return 'Fix: Fold instead of continuing with the weaker line.';
      }
      return 'Fix: Pick the stronger move before you continue.';
  }
}

String buildWorld1HandLoopExpectedChosenFeedbackLineV1({
  required String expectedLabel,
  required String chosenLabel,
  String? factualContextLine,
  required String fixLine,
}) {
  return buildSharedLearnerFeedbackExplanationV1(
    verdict: SharedLearnerFeedbackVerdictV1.fail,
    comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
    expectedLabel: expectedLabel,
    chosenLabel: chosenLabel,
    teachingText: factualContextLine,
    guidanceText: fixLine,
  ).composeInlineText();
}
