import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';

String buildBoardTextureIncorrectFeedbackV1({
  required String expectedActionId,
  required String chosenActionId,
  required String? boardTexture,
  required String? whyText,
}) {
  final expectedLabel = _actionLabel(expectedActionId);
  final chosenLabel = _actionLabel(chosenActionId);
  final whyLine = _normalizeWhy(whyText, boardTexture: boardTexture);
  final fixLine = _fixLineFor(
    expectedActionId: expectedActionId,
    boardTexture: boardTexture,
  );
  return buildSharedLearnerFeedbackExplanationV1(
    verdict: SharedLearnerFeedbackVerdictV1.fail,
    comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
    expectedLabel: expectedLabel,
    chosenLabel: chosenLabel,
    teachingText: whyLine,
    guidanceText: fixLine,
  ).composeInlineText();
}

String _normalizeWhy(String? whyText, {required String? boardTexture}) {
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

  switch (_normalizedTexture(boardTexture)) {
    case 'dry':
    case 'paired':
      return 'This board stays calmer and does not create much immediate draw pressure';
    case 'connected':
    case 'wet':
    case 'two_tone':
      return 'This board creates more draw pressure and asks for the stronger pressure response';
    default:
      return 'This spot calls for a different response once you read the board texture first';
  }
}

String _fixLineFor({
  required String expectedActionId,
  required String? boardTexture,
}) {
  final texture = _normalizedTexture(boardTexture);
  switch (expectedActionId.trim().toLowerCase()) {
    case 'raise':
      if (texture == 'connected' || texture == 'wet' || texture == 'two_tone') {
        return 'Fix: Start from the draw-heavy texture, then choose the aggressive raise line.';
      }
      return 'Fix: Read the texture first, then take the aggressive line when the spot calls for pressure.';
    case 'call':
      if (texture == 'dry' || texture == 'paired') {
        return 'Fix: On calmer textures, prefer the controlled call instead of forcing extra chips in.';
      }
      return 'Fix: Let the texture guide you to the calmer continue line before you escalate.';
    case 'fold':
      return 'Fix: When the texture does not justify continuing, release the hand instead of adding chips.';
    default:
      return 'Fix: Read the texture first, then choose the expected action before continuing.';
  }
}

String _actionLabel(String actionId) => actionId.trim().toUpperCase();

String _normalizedTexture(String? boardTexture) {
  return (boardTexture ?? '').trim().toLowerCase();
}
