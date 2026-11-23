part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewLeaksV1 on _Act0ShellPreviewScreenV1State {
  Act0LeakDashboardV1 _leakDashboardForReviewV1(
    Act0ShellStateV1 state,
    Act0ReviewStateV1 review,
    Act0ReviewPatternCoachingProjectionV1 coaching,
  ) {
    final openMistakes = review.mistakes
        .map((mistake) => mistake.taskId)
        .toSet();
    return act0LeakDashboardFromArchiveV1(
      archive: _attemptArchiveV1,
      history: _learningEvidenceHistoryV1,
      worlds: state.worlds,
      nowUtc: widget.clock.nowUtc(),
      reviewRepairsForMiss: (miss) sync* {
        if (openMistakes.contains(miss.taskId)) {
          for (final pattern in coaching.patterns) {
            if (!pattern.isRepeatedIndependentMiss ||
                pattern.patternState != act0ReviewPatternStateActiveV1 ||
                pattern.errorType != miss.errorType ||
                !pattern.sourceTaskIds.contains(miss.taskId)) {
              continue;
            }
            final repair = _repeatedMistakeTargetV1(pattern, miss.taskId);
            if (repair == null) continue;
            yield (
              kind: Act0LeakPracticeKindV1.reviewRepair,
              worldId: repair.target.worldId,
              lessonId: repair.target.lessonId,
              taskId: repair.target.taskId,
              sourceTaskId: miss.taskId,
            );
          }
        }
      },
      dailyPracticeTargets: () => [
        for (final entry in _dailyDeckEntries(state))
          (
            kind: Act0LeakPracticeKindV1.dailyPractice,
            worldId: entry.worldId,
            lessonId: entry.lessonId,
            taskId: entry.taskId,
            sourceTaskId:
                act0DailyDealRecipeV1(entry.taskId)?.sourceTaskId ??
                entry.taskId,
          ),
      ],
    );
  }
}
