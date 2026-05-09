import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

/// Beat phase ordering for Act0 packs.
enum BeatPhaseV1 { theory, drill, review }

/// Immutable beat data model for the Act0 beat surface.
class BeatV1 {
  const BeatV1({
    required this.beatId,
    required this.phase,
    this.caption,
    this.hint,
    this.heroPosition,
    this.street,
    this.potSize,
    this.toCall,
    this.heroCards,
    this.board,
    this.questionPrompt,
    this.options,
    this.expectedAnswer,
    this.expectedAction,
    this.explanation,
    this.feedbackCorrect,
    this.feedbackIncorrect,
  });

  /// Stable identifier for this beat, e.g. 'world1_act0_table_literacy_0'.
  final String beatId;

  /// Phase in the Theory -> Drill -> Review sequence.
  final BeatPhaseV1 phase;

  /// Orientation text shown above the question (from instructionText/goalText).
  final String? caption;

  /// Hint text shown below the question prompt.
  final String? hint;

  /// Hero position label, e.g. 'BTN'.
  final String? heroPosition;

  /// Street context when applicable.
  final MicroTaskStreetV1? street;

  /// Pot size in chips when applicable.
  final int? potSize;

  /// Price to continue when applicable.
  final int? toCall;

  /// Hero hole cards, e.g. ['Kh', 'Ts'].
  final List<String>? heroCards;

  /// Community board cards.
  final List<String>? board;

  /// The question prompt shown to the learner.
  final String? questionPrompt;

  /// Selectable answer options (seat ids for seat-quiz; action labels for action beats).
  final List<String>? options;

  /// Expected answer for seat-quiz beats (matches one value from [options]).
  final String? expectedAnswer;

  /// Expected action kind string for action beats (matches one value from [options]).
  final String? expectedAction;

  /// Explanation text shown after an answer is revealed.
  final String? explanation;

  /// Feedback shown when the learner picks the correct answer.
  final String? feedbackCorrect;

  /// Feedback shown when the learner picks an incorrect answer.
  final String? feedbackIncorrect;
}
