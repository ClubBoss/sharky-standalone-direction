import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';

String buildInitiativeIncorrectFeedbackV1({
  required String expectedActionId,
  required String chosenActionId,
  required String prompt,
  required String? whyText,
  required String? lastAggressor,
  required String? initiativeOwner,
}) {
  final expectedLabel = _actorLabel(expectedActionId);
  final chosenLabel = _actorLabel(chosenActionId);
  final question = _questionKind(prompt);
  final whyLine = _normalizeWhy(
    whyText,
    question: question,
    lastAggressor: lastAggressor,
    initiativeOwner: initiativeOwner,
  );
  final fixLine = _fixLineFor(
    question: question,
    expectedActionId: expectedActionId,
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

enum _InitiativeQuestionKindV1 { lastAggressor, hasInitiative }

_InitiativeQuestionKindV1 _questionKind(String prompt) {
  final lower = prompt.trim().toLowerCase();
  if (lower.contains('last aggressor')) {
    return _InitiativeQuestionKindV1.lastAggressor;
  }
  return _InitiativeQuestionKindV1.hasInitiative;
}

String _normalizeWhy(
  String? whyText, {
  required _InitiativeQuestionKindV1 question,
  required String? lastAggressor,
  required String? initiativeOwner,
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

  switch (question) {
    case _InitiativeQuestionKindV1.lastAggressor:
      final actor = _actorLabel(lastAggressor ?? '');
      return '$actor made the last raise, so $actor is still the aggressor in this spot';
    case _InitiativeQuestionKindV1.hasInitiative:
      final actor = _actorLabel(initiativeOwner ?? '');
      return '$actor keeps initiative here because the last aggressor still owns the betting lead';
  }
}

String _fixLineFor({
  required _InitiativeQuestionKindV1 question,
  required String expectedActionId,
}) {
  final actor = _actorLabel(expectedActionId);
  switch (question) {
    case _InitiativeQuestionKindV1.lastAggressor:
      return 'Fix: Track who made the last raise, then label $actor as the aggressor before you answer.';
    case _InitiativeQuestionKindV1.hasInitiative:
      return 'Fix: Start from the last raise, then carry initiative forward to $actor before you choose.';
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
