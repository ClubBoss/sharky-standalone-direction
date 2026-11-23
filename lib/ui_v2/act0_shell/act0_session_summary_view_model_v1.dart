enum Act0SessionSummaryPrimaryActionV1 {
  fixMissedSpots,
  practiceClue,
  milestone,
}

/// Presentation choices shared by the summary's labels and action callbacks.
class Act0SessionSummaryViewModelV1 {
  const Act0SessionSummaryViewModelV1({
    required this.worldDone,
    required this.cleanPass,
    required this.quickFixCount,
    required this.assistedCount,
    required this.independentProvenanceKnown,
    required this.firstCorrectEarnedThisRun,
    required this.openMissedSpots,
    required this.canReturnHome,
    required this.hasSourceNext,
    required this.hasUnlockLabel,
    required this.hasGrowthLabel,
    this.hasReminderAction = false,
    this.canShareResult = false,
    this.curriculumCompleted = false,
  });

  final bool worldDone;
  final bool cleanPass;
  final int quickFixCount;
  final int assistedCount;
  final bool independentProvenanceKnown;
  final bool? firstCorrectEarnedThisRun;
  final int openMissedSpots;
  final bool canReturnHome;
  final bool hasSourceNext;
  final bool hasUnlockLabel;
  final bool hasGrowthLabel;
  final bool hasReminderAction;
  final bool canShareResult;
  final bool curriculumCompleted;

  bool get showShare => canShareResult && curriculumCompleted;

  bool get lessonDoneClean => !worldDone && cleanPass;
  bool get doneWithRepairs => quickFixCount > 0;
  bool get showRepairReceipt =>
      firstCorrectEarnedThisRun == null ||
      (independentProvenanceKnown && doneWithRepairs && assistedCount == 0);
  bool get showCurrentRunMoments => firstCorrectEarnedThisRun ?? true;
  bool get foldUnlockIntoMilestonePanel => worldDone && hasUnlockLabel;
  bool get showHabitReward => !worldDone || !hasGrowthLabel;

  Act0SessionSummaryPrimaryActionV1 get primaryAction {
    if (canReturnHome && openMissedSpots > 0) {
      return Act0SessionSummaryPrimaryActionV1.fixMissedSpots;
    }
    if (hasSourceNext) return Act0SessionSummaryPrimaryActionV1.practiceClue;
    return Act0SessionSummaryPrimaryActionV1.milestone;
  }
}
