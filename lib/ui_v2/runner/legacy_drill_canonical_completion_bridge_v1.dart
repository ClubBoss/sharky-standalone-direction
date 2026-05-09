class LegacyDrillCanonicalQuizResultSheetPlanV1 {
  const LegacyDrillCanonicalQuizResultSheetPlanV1({
    required this.titleText,
    required this.feedbackText,
    required this.primaryLabel,
    required this.primaryCountsAsCorrect,
  });

  final String titleText;
  final String feedbackText;
  final String primaryLabel;
  final bool primaryCountsAsCorrect;
}

class LegacyDrillCanonicalRevealCompletionPlanV1 {
  const LegacyDrillCanonicalRevealCompletionPlanV1({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.primaryCountsAsCorrect,
    required this.showsSecondaryAction,
    required this.firesSuccessEffectsOnPrimary,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final bool primaryCountsAsCorrect;
  final bool showsSecondaryAction;
  final bool firesSuccessEffectsOnPrimary;
}

class LegacyDrillCanonicalCompletionBridgeV1 {
  const LegacyDrillCanonicalCompletionBridgeV1._();

  static LegacyDrillCanonicalQuizResultSheetPlanV1 resolveQuizResultSheetPlan({
    required bool isCorrect,
    required bool isFinalItem,
    required String correctFeedback,
    required String incorrectFeedback,
  }) {
    return LegacyDrillCanonicalQuizResultSheetPlanV1(
      titleText: isCorrect ? 'Correct!' : 'Incorrect',
      feedbackText: isCorrect ? correctFeedback : incorrectFeedback,
      primaryLabel: isFinalItem ? 'FINISH' : 'NEXT DRILL',
      primaryCountsAsCorrect: isCorrect,
    );
  }

  static LegacyDrillCanonicalRevealCompletionPlanV1
  resolveRevealCompletionPlan({
    required bool isFinalItem,
  }) {
    return LegacyDrillCanonicalRevealCompletionPlanV1(
      primaryLabel: isFinalItem ? 'FINISH' : 'Got it',
      secondaryLabel: isFinalItem ? null : 'Missed it',
      primaryCountsAsCorrect: true,
      showsSecondaryAction: !isFinalItem,
      firesSuccessEffectsOnPrimary: true,
    );
  }
}
