import 'act0_shell_state_v1.dart';

/// Learner-facing interpretation of a completed decision.
///
/// This deliberately projects only authored feedback and structured table
/// signals supplied by the runner. It never reads intent from learner input or
/// derives poker logic from prose.
class Act0CausalFeedbackV1 {
  const Act0CausalFeedbackV1({
    required this.classification,
    required this.chosenAction,
    required this.betterAction,
    required this.clue,
    required this.whyChosen,
    required this.whyBetter,
    required this.nextHandInstruction,
    required this.counterfactual,
  });

  final String classification;
  final String chosenAction;
  final String betterAction;
  final String clue;
  final String whyChosen;
  final String whyBetter;
  final String nextHandInstruction;
  final String? counterfactual;

  bool get hasCounterfactual => counterfactual != null;

  factory Act0CausalFeedbackV1.fromStructured({
    required Act0FeedbackQualityV1 quality,
    required String authoredReason,
    required String chosenAction,
    required String preferredAction,
    required String betterAction,
    String structuredClue = '',
    String? structuredCounterfactual,
  }) {
    final reason = authoredReason.trim();
    final clue = structuredClue.trim();
    final isCorrect = quality == Act0FeedbackQualityV1.correct;
    final better =
        (betterAction.trim().isNotEmpty ? betterAction : preferredAction)
            .trim();
    final safeCounterfactual = structuredCounterfactual?.trim();
    return Act0CausalFeedbackV1(
      classification: switch (quality) {
        Act0FeedbackQualityV1.correct => 'correct',
        Act0FeedbackQualityV1.wrong => 'incorrect',
        Act0FeedbackQualityV1.suboptimal => 'suboptimal',
      },
      chosenAction: chosenAction.trim(),
      betterAction: isCorrect ? '' : better,
      clue: clue,
      // Authored option feedback is the only causal source. When it is absent,
      // the fallback names only the supplied structured clue.
      whyChosen: reason.isNotEmpty
          ? reason
          : clue.isEmpty
          ? 'Check the visible spot before choosing.'
          : 'The visible clue here is $clue.',
      whyBetter: isCorrect || better.isEmpty
          ? ''
          : clue.isEmpty
          ? 'That is the supported action for this spot.'
          : '$better fits the visible clue: $clue.',
      nextHandInstruction: clue.isEmpty
          ? 'On the next hand, read the visible spot before choosing.'
          : 'On the next hand, notice $clue before choosing.',
      counterfactual: safeCounterfactual == null || safeCounterfactual.isEmpty
          ? null
          : safeCounterfactual,
    );
  }

  Map<String, Object?> toTelemetryPayload() => <String, Object?>{
    'feedback_classification': classification,
    'counterfactual_available': hasCounterfactual,
  };
}
