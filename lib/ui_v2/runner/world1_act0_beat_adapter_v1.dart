import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_beat_contract_v1.dart';

/// Seat label lookup for the 6-max canonical seat set.
const Map<String, String> _kSeatLabels = <String, String>{
  'btn': 'Button',
  'sb': 'Small Blind',
  'bb': 'Big Blind',
  'utg': 'UTG',
  'hj': 'Hijack',
  'co': 'Cutoff',
};

/// The 3 seat options presented in table-literacy beat chips.
const List<String> _kAct0TableSeatOptions = <String>['btn', 'sb', 'bb'];

String _seatLabel(String seatId) =>
    _kSeatLabels[seatId.toLowerCase()] ?? seatId.toUpperCase();

String _feedbackCorrectForSeat(String seatId) =>
    'Correct. That is the ${_seatLabel(seatId)} seat.';

String _feedbackIncorrectForSeat(String seatId) =>
    'Not quite. Look for the ${_seatLabel(seatId)} in the clockwise order.';

/// Splits the authored "Correct: X. Incorrect: Y." convention.
/// Returns the correct portion only, falling back to [fallback].
String _feedbackCorrectFromConsequence(
  MicroTaskStep step, {
  String fallback = 'Good read.',
}) {
  final raw = (step.consequenceText ?? '').trim();
  if (raw.isEmpty) return fallback;
  if (raw.contains('Incorrect:')) {
    return raw.split('Incorrect:').first.replaceFirst('Correct:', '').trim();
  }
  return raw.replaceFirst('Correct:', '').trim();
}

/// Returns the incorrect portion from the authored consequence text,
/// falling back to the first sentence of [tradeoffText] or [fallback].
String _feedbackIncorrectFromConsequence(
  MicroTaskStep step, {
  String fallback = 'Try the other action.',
}) {
  final raw = (step.consequenceText ?? '').trim();
  if (raw.contains('Incorrect:')) {
    return raw.split('Incorrect:').last.trim();
  }
  final tradeoff = (step.tradeoffText ?? '').trim();
  if (tradeoff.isNotEmpty) {
    return tradeoff.split('.').first.trim();
  }
  return fallback;
}

BeatPhaseV1 _phaseForIndex(int index, int total) {
  if (index == 0) return BeatPhaseV1.theory;
  if (index == total - 1) return BeatPhaseV1.review;
  return BeatPhaseV1.drill;
}

BeatV1 _stepToBeat(String packId, MicroTaskStep step, int index, int total) {
  final phase = _phaseForIndex(index, total);
  final beatId = '${packId}_$index';

  final isSeatQuiz =
      (step.allowedActions == null || step.allowedActions!.isEmpty) &&
      step.expectedSeatIds.isNotEmpty;

  if (isSeatQuiz) {
    final expectedSeat = step.expectedSeatIds.first.toLowerCase();
    return BeatV1(
      beatId: beatId,
      phase: phase,
      caption: step.instructionText,
      hint: step.hint,
      heroPosition: step.heroSeatId,
      toCall: step.toCall,
      questionPrompt: step.prompt,
      options: _kAct0TableSeatOptions,
      expectedAnswer: expectedSeat,
      explanation: step.contextText,
      feedbackCorrect: _feedbackCorrectForSeat(expectedSeat),
      feedbackIncorrect: _feedbackIncorrectForSeat(expectedSeat),
    );
  }

  // Action-choice beat.
  return BeatV1(
    beatId: beatId,
    phase: phase,
    caption: step.instructionText,
    hint: step.hint,
    heroPosition: step.heroSeatId,
    street: step.street,
    potSize: step.pot,
    toCall: step.toCall,
    heroCards: step.heroCards?.isNotEmpty == true ? step.heroCards : null,
    board: step.boardCards?.isNotEmpty == true ? step.boardCards : null,
    questionPrompt: step.prompt,
    options: step.allowedActions,
    expectedAction: step.expectedActionKind,
    explanation: step.contextText,
    feedbackCorrect: _feedbackCorrectFromConsequence(step),
    feedbackIncorrect: _feedbackIncorrectFromConsequence(step),
  );
}

/// Converts a list of [MicroTaskStep]s from an Act0 pack into an ordered
/// [BeatV1] sequence (theory -> drill -> review).
///
/// Only accepts pack IDs that start with `'world1_act0_'`.
List<BeatV1> world1Act0PackToBeatSequenceV1(
  String packId,
  List<MicroTaskStep> steps,
) {
  assert(
    packId.trim().toLowerCase().startsWith('world1_act0_'),
    'world1Act0PackToBeatSequenceV1: packId must start with world1_act0_, got $packId',
  );
  if (steps.isEmpty) return const <BeatV1>[];
  return <BeatV1>[
    for (var i = 0; i < steps.length; i++)
      _stepToBeat(packId.trim().toLowerCase(), steps[i], i, steps.length),
  ];
}
