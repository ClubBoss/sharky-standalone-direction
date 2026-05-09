import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';

String buildPositionIncorrectFeedbackV1({
  required String expectedActionId,
  required String chosenActionId,
  required String prompt,
  required String? whyText,
  required String heroSeat,
  required String villainSeat,
}) {
  final expectedLabel = _actorLabel(expectedActionId);
  final chosenLabel = _actorLabel(chosenActionId);
  final question = _questionKind(prompt);
  final whyLine = _normalizeWhy(
    whyText,
    question: question,
    heroSeat: heroSeat,
    villainSeat: villainSeat,
    expectedActionId: expectedActionId,
  );
  final fixLine = _fixLineFor(
    question: question,
    expectedActionId: expectedActionId,
    heroSeat: heroSeat,
    villainSeat: villainSeat,
  );
  return buildSharedLearnerFeedbackExplanationV1(
    verdict: SharedLearnerFeedbackVerdictV1.fail,
    comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
    expectedLabel: expectedLabel,
    chosenLabel: chosenLabel,
    teachingText: whyLine,
    guidanceText: fixLine,
  ).composeInlineText();
}

enum _PositionQuestionKindV1 { inPosition, outOfPosition, actsLater }

_PositionQuestionKindV1 _questionKind(String prompt) {
  final lower = prompt.trim().toLowerCase();
  if (lower.contains('out of position')) {
    return _PositionQuestionKindV1.outOfPosition;
  }
  if (lower.contains('acts later')) {
    return _PositionQuestionKindV1.actsLater;
  }
  return _PositionQuestionKindV1.inPosition;
}

String _normalizeWhy(
  String? whyText, {
  required _PositionQuestionKindV1 question,
  required String heroSeat,
  required String villainSeat,
  required String expectedActionId,
}) {
  final trimmed = (whyText ?? '').trim();
  if (trimmed.isNotEmpty) {
    final withoutIncorrect = trimmed.replaceFirst(
      RegExp(r'^Incorrect\.\s*', caseSensitive: false),
      '',
    );
    final normalized = withoutIncorrect.trim();
    if (normalized.isNotEmpty) {
      return normalized.endsWith('.')
          ? normalized.substring(0, normalized.length - 1)
          : normalized;
    }
  }

  final expectedActor = _actorLabel(expectedActionId);
  final expectedSeat = expectedActionId.trim().toLowerCase() == 'hero'
      ? heroSeat.toUpperCase()
      : villainSeat.toUpperCase();
  switch (question) {
    case _PositionQuestionKindV1.inPosition:
      return '$expectedActor is in position here because $expectedSeat acts later after the flop';
    case _PositionQuestionKindV1.outOfPosition:
      return '$expectedActor is out of position here because $expectedSeat must act earlier after the flop';
    case _PositionQuestionKindV1.actsLater:
      return '$expectedActor acts later here because $expectedSeat comes after the other live seat postflop';
  }
}

String _fixLineFor({
  required _PositionQuestionKindV1 question,
  required String expectedActionId,
  required String heroSeat,
  required String villainSeat,
}) {
  final expectedActor = _actorLabel(expectedActionId);
  final expectedSeat = expectedActionId.trim().toLowerCase() == 'hero'
      ? heroSeat.toUpperCase()
      : villainSeat.toUpperCase();
  switch (question) {
    case _PositionQuestionKindV1.inPosition:
      return 'Fix: Compare the live seats after the flop, then mark $expectedActor because $expectedSeat acts later.';
    case _PositionQuestionKindV1.outOfPosition:
      return 'Fix: Find the seat that must act first after the flop, then choose $expectedActor as out of position.';
    case _PositionQuestionKindV1.actsLater:
      return 'Fix: Read the postflop order first, then pick $expectedActor because $expectedSeat acts later.';
  }
}

String _actorLabel(String actionId) {
  switch (actionId.trim().toLowerCase()) {
    case 'hero':
      return 'HERO';
    case 'villain':
      return 'VILLAIN';
    default:
      final normalized = actionId.trim().toUpperCase();
      return normalized.isEmpty ? 'UNKNOWN' : normalized;
  }
}
