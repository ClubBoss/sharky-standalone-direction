import 'package:flutter/foundation.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/shared_learner_feedback_explanation_v1.dart';

@immutable
class SessionDrillCanonicalCorrectiveFeedbackV1 {
  const SessionDrillCanonicalCorrectiveFeedbackV1({
    required this.detailText,
    this.whyText,
  });

  final String detailText;
  final String? whyText;
}

SessionDrillCanonicalCorrectiveFeedbackV1?
resolveSessionDrillCanonicalCorrectiveFeedbackV1({
  required String sessionId,
  required DrillSpecV1 spec,
  required bool isFail,
  DrillChainStepV1? currentHandChainStepV1,
  String? currentHandChainWhyV1,
  String? chosenActionIdV1,
  DrillUserEventV1? chosenEventV1,
}) {
  if (!isFail) {
    return null;
  }

  final normalizedSessionId = sessionId.trim().toLowerCase();
  switch (spec.kind) {
    case DrillKindV1.outsCountChoice:
      if (!normalizedSessionId.startsWith('w2.')) {
        return null;
      }
      final expectedOuts = spec.expected.actionId?.trim();
      if (_isMissing(expectedOuts)) {
        return null;
      }
      final explanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: '$expectedOuts outs',
        chosenLabel: chosenActionIdV1,
        teachingText: spec.whyV1,
        guidanceText:
            'Count the live improving cards before you answer.',
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: explanation.headlineText,
        whyText: explanation.composeSupportingText(),
      );
    case DrillKindV1.showdownWinnerChoice:
      if (!normalizedSessionId.startsWith('w2.')) {
        return null;
      }
      final expectedWinner = spec.expected.actionId?.trim();
      if (_isMissing(expectedWinner)) {
        return null;
      }
      final explanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: _winnerLabelV1(expectedWinner!),
        chosenLabel: _winnerLabelOrNullV1(chosenActionIdV1),
        teachingText: spec.whyV1,
        guidanceText:
            'Compare the made hands first, then choose the winner.',
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: explanation.headlineText,
        whyText: explanation.composeSupportingText(),
      );
    case DrillKindV1.positionThinkingChoice:
      if (!normalizedSessionId.startsWith('w2.')) {
        return null;
      }
      final expectedActor = spec.expected.actionId?.trim();
      if (_isMissing(expectedActor)) {
        return null;
      }
      final positionExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: _actorLabelV1(expectedActor!),
        chosenLabel: _actorLabelOrNullV1(chosenActionIdV1),
        teachingText: _positionWhyLineV1(spec),
        guidanceText: _positionFixLineV1(spec, expectedActor),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: positionExplanation.headlineText,
        whyText: positionExplanation.composeSupportingText(),
      );
    case DrillKindV1.initiativeAggressorChoice:
      if (!normalizedSessionId.startsWith('w2.')) {
        return null;
      }
      final expectedAggressor = spec.expected.actionId?.trim();
      if (_isMissing(expectedAggressor)) {
        return null;
      }
      final initiativeExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: _actorLabelV1(expectedAggressor!),
        chosenLabel: _actorLabelOrNullV1(chosenActionIdV1),
        teachingText: _initiativeWhyLineV1(spec),
        guidanceText: _initiativeFixLineV1(spec, expectedAggressor),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: initiativeExplanation.headlineText,
        whyText: initiativeExplanation.composeSupportingText(),
      );
    case DrillKindV1.boardTextureClassifier:
      final expectedAction = spec.expectedActionV1?.trim();
      if (_isMissing(expectedAction)) {
        return null;
      }
      final boardTextureExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
        expectedLabel: expectedAction!.toUpperCase(),
        chosenLabel: _humanizeTokenOrNullV1(chosenActionIdV1)?.toUpperCase(),
        teachingText: _boardTextureWhyLineV1(spec),
        guidanceText: _boardTextureFixLineV1(spec, expectedAction),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: boardTextureExplanation.headlineText,
        whyText: boardTextureExplanation.composeSupportingText(),
      );
    case DrillKindV1.handChain:
      if (!_supportsCanonicalHandChainCorrectiveFeedbackV1(normalizedSessionId)) {
        return null;
      }
      final step = currentHandChainStepV1;
      if (step == null) {
        return null;
      }
      final expectedLabel = _handChainExpectedLabelV1(step);
      if (expectedLabel == null) {
        return null;
      }
      final comparisonStyle = _handChainComparisonStyleV1(step);
      final explanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: comparisonStyle,
        expectedLabel: expectedLabel,
        chosenLabel: _handChainChosenLabelV1(step, chosenActionIdV1),
        teachingText: currentHandChainWhyV1 ?? step.whyV1,
        guidanceText: _handChainGuidanceLineV1(step),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: explanation.headlineText,
        whyText: explanation.composeSupportingText(),
      );
    case DrillKindV1.seatTap:
      final expectedSeat = _expectedSeatTapLabelV1(spec);
      if (_isMissing(expectedSeat)) {
        return null;
      }
      final seatExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: expectedSeat!,
        chosenLabel: _chosenSeatTapLabelOrNullV1(chosenEventV1),
        teachingText: _preferredTeachingTextV1(spec),
        guidanceText: _seatTapGuidanceLineV1(spec),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: seatExplanation.headlineText,
        whyText: seatExplanation.composeSupportingText(),
      );
    case DrillKindV1.actionChoice:
      final expectedAction = spec.expected.actionId?.trim();
      if (_isMissing(expectedAction)) {
        return null;
      }
      final actionChoiceExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
        expectedLabel: _humanizeTokenV1(expectedAction!).toUpperCase(),
        chosenLabel: _humanizeTokenOrNullV1(chosenActionIdV1)?.toUpperCase(),
        teachingText: _preferredTeachingTextV1(
          spec,
          chosenActionIdV1: chosenActionIdV1,
        ),
        guidanceText: _actionChoiceGuidanceLineV1(expectedAction),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: actionChoiceExplanation.headlineText,
        whyText: actionChoiceExplanation.composeSupportingText(),
      );
    case DrillKindV1.boardTap:
      final expectedBoardSlot = spec.expected.boardSlot?.trim();
      if (_isMissing(expectedBoardSlot)) {
        return null;
      }
      final boardTapExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: _boardSlotLabelV1(expectedBoardSlot!),
        chosenLabel: _chosenBoardSlotLabelOrNullV1(chosenEventV1),
        teachingText: _preferredTeachingTextV1(spec),
        guidanceText: _boardTapGuidanceLineV1(expectedBoardSlot),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: boardTapExplanation.headlineText,
        whyText: boardTapExplanation.composeSupportingText(),
      );
    case DrillKindV1.holeCardsTap:
      final expectedCardSlot = spec.expected.cardSlot?.trim();
      if (_isMissing(expectedCardSlot)) {
        return null;
      }
      final holeCardsExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.correctAnswer,
        expectedLabel: _holeCardTargetLabelV1(
          cardSlot: expectedCardSlot!,
          cardId: spec.expected.cardId,
        ),
        chosenLabel: _chosenHoleCardLabelOrNullV1(chosenEventV1),
        teachingText: _preferredTeachingTextV1(spec),
        guidanceText: _holeCardsTapGuidanceLineV1(spec),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: holeCardsExplanation.headlineText,
        whyText: holeCardsExplanation.composeSupportingText(),
      );
    case DrillKindV1.betSizingChoice:
      final expectedPresetId = spec.expected.presetId?.trim();
      if (_isMissing(expectedPresetId)) {
        return null;
      }
      final betSizingExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
        expectedLabel: _presetLabelV1(expectedPresetId!),
        chosenLabel: _presetLabelOrNullV1(chosenActionIdV1),
        teachingText: _preferredTeachingTextV1(spec),
        guidanceText: _betSizingGuidanceLineV1(expectedPresetId),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: betSizingExplanation.headlineText,
        whyText: betSizingExplanation.composeSupportingText(),
      );
    case DrillKindV1.rangeBucketClassifier:
      final expectedAction = spec.expectedActionV1?.trim();
      if (_isMissing(expectedAction)) {
        return null;
      }
      final rangeBucketExplanation = buildSharedLearnerFeedbackExplanationV1(
        verdict: SharedLearnerFeedbackVerdictV1.fail,
        comparisonStyle: SharedLearnerFeedbackComparisonStyleV1.strongerLine,
        expectedLabel: _humanizeTokenV1(expectedAction!).toUpperCase(),
        chosenLabel: _humanizeTokenOrNullV1(chosenActionIdV1)?.toUpperCase(),
        teachingText: _preferredTeachingTextV1(
          spec,
          chosenActionIdV1: chosenActionIdV1,
        ),
        guidanceText: _rangeBucketGuidanceLineV1(spec, expectedAction),
      );
      return SessionDrillCanonicalCorrectiveFeedbackV1(
        detailText: rangeBucketExplanation.headlineText,
        whyText: rangeBucketExplanation.composeSupportingText(),
      );
  }
}

bool _isMissing(String? value) => value == null || value.trim().isEmpty;

String _winnerLabelV1(String winnerId) {
  switch (winnerId.trim().toLowerCase()) {
    case 'hero':
      return 'Hero';
    case 'villain':
      return 'Villain';
    case 'board_plays':
      return 'The board';
    default:
      return _humanizeTokenV1(winnerId);
  }
}

bool _supportsCanonicalHandChainCorrectiveFeedbackV1(String normalizedSessionId) {
  return normalizedSessionId.startsWith('w1.') ||
      normalizedSessionId.startsWith('w3.') ||
      normalizedSessionId.startsWith('w6.');
}

String? _handChainExpectedLabelV1(DrillChainStepV1 step) {
  final expectedAction = step.expectedActionV1?.trim();
  if (!_isMissing(expectedAction)) {
    return _humanizeTokenV1(expectedAction!);
  }
  final expectedPresetId = step.expectedPresetIdV1?.trim();
  if (!_isMissing(expectedPresetId)) {
    return _presetLabelV1(expectedPresetId!);
  }
  final rangeBucket = step.rangeBucketV1?.trim();
  if (!_isMissing(rangeBucket)) {
    return _humanizeTokenV1(rangeBucket!);
  }
  return null;
}

SharedLearnerFeedbackComparisonStyleV1 _handChainComparisonStyleV1(
  DrillChainStepV1 step,
) {
  if (!_isMissing(step.expectedActionV1) || !_isMissing(step.expectedPresetIdV1)) {
    return SharedLearnerFeedbackComparisonStyleV1.strongerLine;
  }
  return SharedLearnerFeedbackComparisonStyleV1.correctAnswer;
}

String? _handChainChosenLabelV1(DrillChainStepV1 step, String? chosenActionIdV1) {
  if (!_isMissing(step.expectedPresetIdV1)) {
    return _presetLabelOrNullV1(chosenActionIdV1);
  }
  return _humanizeTokenOrNullV1(chosenActionIdV1);
}

String _handChainGuidanceLineV1(DrillChainStepV1 step) {
  if (!_isMissing(step.expectedPresetIdV1)) {
    return 'Read the frame first, then choose the size that matches the expected line.';
  }
  if (!_isMissing(step.rangeBucketV1)) {
    return 'Read the range picture first, then choose the bucket that fits the scene.';
  }
  return 'Read the frame first, then choose the expected line.';
}

String? _winnerLabelOrNullV1(String? winnerId) {
  if (_isMissing(winnerId)) {
    return null;
  }
  return _winnerLabelV1(winnerId!.trim());
}

String? _actorLabelOrNullV1(String? actorId) {
  if (_isMissing(actorId)) {
    return null;
  }
  return _actorLabelV1(actorId!.trim());
}

String? _humanizeTokenOrNullV1(String? token) {
  if (_isMissing(token)) {
    return null;
  }
  return _humanizeTokenV1(token!);
}

String? _presetLabelOrNullV1(String? presetId) {
  if (_isMissing(presetId)) {
    return null;
  }
  return _presetLabelV1(presetId!);
}

String _actorLabelV1(String actorId) {
  switch (actorId.trim().toLowerCase()) {
    case 'hero':
      return 'HERO';
    case 'villain':
      return 'VILLAIN';
    default:
      return _humanizeTokenV1(actorId).toUpperCase();
  }
}

String _positionWhyLineV1(DrillSpecV1 spec) {
  final authored = spec.whyV1?.trim();
  if (!_isMissing(authored)) {
    return authored!;
  }
  final question = spec.prompt.trim().toLowerCase();
  final expectedActor = _actorLabelV1(spec.expected.actionId ?? '');
  final expectedSeat = (spec.expected.actionId?.trim().toLowerCase() == 'hero'
          ? spec.heroSeatV1
          : spec.villainSeatV1)
      ?.toUpperCase();
  if (question.contains('out of position')) {
    return '$expectedActor is out of position here because ${expectedSeat ?? 'that seat'} must act earlier after the flop.';
  }
  if (question.contains('acts later')) {
    return '$expectedActor acts later here because ${expectedSeat ?? 'that seat'} comes after the other live seat postflop.';
  }
  return '$expectedActor is in position here because ${expectedSeat ?? 'that seat'} acts later after the flop.';
}

String _positionFixLineV1(DrillSpecV1 spec, String expectedActor) {
  final actor = _actorLabelV1(expectedActor);
  final expectedSeat = (expectedActor.trim().toLowerCase() == 'hero'
          ? spec.heroSeatV1
          : spec.villainSeatV1)
      ?.toUpperCase();
  final question = spec.prompt.trim().toLowerCase();
  if (question.contains('out of position')) {
    return 'Find the seat that must act first after the flop, then choose $actor as out of position.';
  }
  if (question.contains('acts later')) {
    return 'Read the postflop order first, then pick $actor because ${expectedSeat ?? 'that seat'} acts later.';
  }
  return 'Compare the live seats after the flop, then mark $actor because ${expectedSeat ?? 'that seat'} acts later.';
}

String _initiativeWhyLineV1(DrillSpecV1 spec) {
  final authored = spec.whyV1?.trim();
  if (!_isMissing(authored)) {
    return authored!;
  }
  final question = spec.prompt.trim().toLowerCase();
  if (question.contains('last aggressor')) {
    final actor = _actorLabelV1(spec.lastAggressorV1 ?? '');
    return '$actor made the last raise, so $actor is still the aggressor in this spot.';
  }
  final actor = _actorLabelV1(spec.initiativeOwnerV1 ?? '');
  return '$actor keeps initiative here because the last aggressor still owns the betting lead.';
}

String _initiativeFixLineV1(DrillSpecV1 spec, String expectedActor) {
  final actor = _actorLabelV1(expectedActor);
  final question = spec.prompt.trim().toLowerCase();
  if (question.contains('last aggressor')) {
    return 'Track who made the last raise, then label $actor as the aggressor before you answer.';
  }
  return 'Start from the last raise, then carry initiative forward to $actor before you choose.';
}

String _boardTextureWhyLineV1(DrillSpecV1 spec) {
  final authored = spec.whyV1?.trim();
  if (!_isMissing(authored)) {
    return authored!;
  }
  switch ((spec.boardTextureV1 ?? '').trim().toLowerCase()) {
    case 'dry':
    case 'paired':
      return 'This board stays calmer and does not create much immediate draw pressure.';
    case 'connected':
    case 'wet':
    case 'two_tone':
      return 'This board creates more draw pressure and asks for the stronger pressure response.';
    default:
      return 'This spot calls for a different response once you read the board texture first.';
  }
}

String _boardTextureFixLineV1(DrillSpecV1 spec, String expectedAction) {
  final texture = (spec.boardTextureV1 ?? '').trim().toLowerCase();
  switch (expectedAction.trim().toLowerCase()) {
    case 'raise':
      if (texture == 'connected' || texture == 'wet' || texture == 'two_tone') {
        return 'Start from the draw-heavy texture, then choose the aggressive raise line.';
      }
      return 'Read the texture first, then take the aggressive line when the spot calls for pressure.';
    case 'call':
      if (texture == 'dry' || texture == 'paired') {
        return 'On calmer textures, prefer the controlled call instead of forcing extra chips in.';
      }
      return 'Let the texture guide you to the calmer continue line before you escalate.';
    case 'fold':
      return 'When the texture does not justify continuing, release the hand instead of adding chips.';
    default:
      return 'Read the texture first, then choose the expected action before continuing.';
  }
}

String? _preferredTeachingTextV1(
  DrillSpecV1 spec, {
  String? chosenActionIdV1,
}) {
  final normalizedActionId = chosenActionIdV1?.trim().toLowerCase();
  final actionSpecific = normalizedActionId == null
      ? null
      : spec.scenarioCoreV1.feedbackIncorrectByActionV1?[normalizedActionId]
          ?.trim();
  if (!_isMissing(actionSpecific)) {
    return actionSpecific!;
  }
  final why = spec.whyV1?.trim();
  if (!_isMissing(why)) {
    return why!;
  }
  final incorrect = spec.scenarioCoreV1.feedbackIncorrectV1?.trim();
  if (!_isMissing(incorrect)) {
    return incorrect!;
  }
  return null;
}

String? _expectedSeatTapLabelV1(DrillSpecV1 spec) {
  final role = spec.expected.role?.trim();
  if (!_isMissing(role)) {
    return role!.toUpperCase();
  }
  final seatId = spec.expected.seatId?.trim();
  if (!_isMissing(seatId)) {
    return seatId!.toUpperCase();
  }
  return null;
}

String? _chosenSeatTapLabelOrNullV1(DrillUserEventV1? event) {
  if (event == null) {
    return null;
  }
  final role = event.role?.trim();
  if (!_isMissing(role)) {
    return role!.toUpperCase();
  }
  final seatId = event.seatId?.trim();
  if (!_isMissing(seatId)) {
    return seatId!.toUpperCase();
  }
  return null;
}

String _seatTapGuidanceLineV1(DrillSpecV1 spec) {
  final role = spec.expected.role?.trim();
  if (!_isMissing(role)) {
    return 'Anchor the ${role!.toUpperCase()} seat first, then continue with the next decision.';
  }
  return 'Match the target seat on the table before you continue.';
}

String _boardSlotLabelV1(String boardSlot) {
  switch (boardSlot.trim().toLowerCase()) {
    case 'flop_left':
      return 'FLOP LEFT';
    case 'flop_mid':
      return 'FLOP MIDDLE';
    case 'flop_right':
      return 'FLOP RIGHT';
    case 'turn':
      return 'TURN';
    case 'river':
      return 'RIVER';
    default:
      return _humanizeTokenV1(boardSlot).toUpperCase();
  }
}

String? _chosenBoardSlotLabelOrNullV1(DrillUserEventV1? event) {
  final boardSlot = event?.boardSlot?.trim();
  if (_isMissing(boardSlot)) {
    return null;
  }
  return _boardSlotLabelV1(boardSlot!);
}

String _boardTapGuidanceLineV1(String expectedBoardSlot) {
  return 'Lock the ${_boardSlotLabelV1(expectedBoardSlot)} card first so the board context is complete before you decide.';
}

String _holeCardTargetLabelV1({
  required String cardSlot,
  String? cardId,
}) {
  if (!_isMissing(cardId)) {
    return _humanizeCardIdV1(cardId!);
  }
  return switch (cardSlot.trim().toLowerCase()) {
    'p0' => 'LEFT HOLE CARD',
    'p1' => 'RIGHT HOLE CARD',
    _ => _humanizeTokenV1(cardSlot).toUpperCase(),
  };
}

String? _chosenHoleCardLabelOrNullV1(DrillUserEventV1? event) {
  if (event == null) {
    return null;
  }
  final cardId = event.cardId?.trim();
  final cardSlot = event.cardSlot?.trim();
  if (_isMissing(cardId) && _isMissing(cardSlot)) {
    return null;
  }
  return _holeCardTargetLabelV1(
    cardSlot: cardSlot ?? '',
    cardId: cardId,
  );
}

String _holeCardsTapGuidanceLineV1(DrillSpecV1 spec) {
  return 'Use the target hole card as the hand anchor before you continue.';
}

String _actionChoiceGuidanceLineV1(String expectedAction) {
  switch (expectedAction.trim().toLowerCase()) {
    case 'fold':
      return 'When the spot loses value or leverage, release the hand instead of stretching it.';
    case 'call':
      return 'When the price and showdown value still fit, continue with the cleaner call.';
    case 'raise':
      return 'When the spot wants initiative or pressure, choose the stronger raise line.';
    default:
      return 'Read the scene first, then choose the stronger line.';
  }
}

String _betSizingGuidanceLineV1(String expectedPresetId) {
  switch (expectedPresetId.trim().toLowerCase()) {
    case 'half_pot':
      return 'Start from the value goal, then choose the size that still keeps worse hands in.';
    case 'one_third_pot':
      return 'When the goal is a comfortable price, choose the smaller sizing.';
    case 'pot':
      return 'When the goal is maximum pressure, choose the full-pot sizing.';
    case 'min_raise':
      return 'When you only need to reopen, choose the smallest legal raise.';
    default:
      return 'Start from the goal of the sizing, then choose the preset that matches it.';
  }
}

String _rangeBucketGuidanceLineV1(DrillSpecV1 spec, String expectedAction) {
  final bucket = spec.rangeBucketV1?.trim().toLowerCase();
  switch (expectedAction.trim().toLowerCase()) {
    case 'fold':
      if (bucket == 'missed' || bucket == 'weak') {
        return 'When the $bucket bucket lacks clean equity, preserve chips with the fold.';
      }
      return 'When the bucket loses clean equity, release it instead of forcing a continue.';
    case 'call':
      if (bucket == 'medium' || bucket == 'draw') {
        return 'When the $bucket bucket can continue but not press, keep the line controlled with a call.';
      }
      return 'When the bucket has enough equity to continue but not enough edge to push harder, use the cleaner call.';
    case 'raise':
      if (bucket == 'strong' || bucket == 'draw') {
        return 'When the $bucket bucket supports value or pressure, choose the stronger raise line.';
      }
      return 'When the bucket owns the clearer edge, press it with the raise instead of staying passive.';
    default:
      return 'Read the bucket first, then choose the action that matches its real edge.';
  }
}

String _presetLabelV1(String presetId) {
  switch (presetId.trim().toLowerCase()) {
    case 'one_third_pot':
      return 'BET 1/3';
    case 'half_pot':
      return 'BET 1/2';
    case 'pot':
      return 'BET POT';
    case 'min_raise':
      return 'RAISE MIN';
    default:
      return _humanizeTokenV1(presetId).toUpperCase();
  }
}

String _humanizeCardIdV1(String cardId) {
  final value = cardId.trim().toUpperCase();
  if (value.length < 2) {
    return value;
  }
  final rank = switch (value[0]) {
    'A' => 'ACE',
    'K' => 'KING',
    'Q' => 'QUEEN',
    'J' => 'JACK',
    'T' => 'TEN',
    _ => value[0],
  };
  final suit = switch (value[value.length - 1]) {
    'S' => 'SPADES',
    'H' => 'HEARTS',
    'D' => 'DIAMONDS',
    'C' => 'CLUBS',
    _ => '',
  };
  if (suit.isEmpty) {
    return rank;
  }
  return '$rank OF $suit';
}

String _humanizeTokenV1(String token) {
  final normalized = token.trim().replaceAll('_', ' ');
  if (normalized.isEmpty) {
    return token;
  }
  return normalized;
}
