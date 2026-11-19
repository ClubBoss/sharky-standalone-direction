part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewDebugSurfacesV1 on _Act0ShellPreviewScreenV1State {
  void _applyDebugHarnessEntry(
    Act0ShellDebugHarnessEntryV1 entry,
    Act0ShellStateV1 state,
  ) {
    _bootSurfaceReady = true;
    switch (entry.surface) {
      case Act0ControlledDemoCaptureSurfaceV1.placement:
        _applyDebugPlacementSurface();
      case Act0ControlledDemoCaptureSurfaceV1.welcome:
        _applyDebugWelcomeSurface();
      case Act0ControlledDemoCaptureSurfaceV1.home:
        _applyDebugHomeSurface();
      case Act0ControlledDemoCaptureSurfaceV1.learn:
        _applyDebugLearnSurface();
      case Act0ControlledDemoCaptureSurfaceV1.runnerTheory:
        _applyDebugRunnerSurface(state, phase: Act0LessonPhaseV1.theory);
      case Act0ControlledDemoCaptureSurfaceV1.runnerDrill:
        _applyDebugRunnerSurface(state, phase: Act0LessonPhaseV1.drill);
      case Act0ControlledDemoCaptureSurfaceV1.runnerFeedback:
        _applyDebugRunnerSurface(state, phase: Act0LessonPhaseV1.review);
      case Act0ControlledDemoCaptureSurfaceV1.review:
        _applyDebugReviewSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.practice:
        _applyDebugPracticeSurface();
      case Act0ControlledDemoCaptureSurfaceV1.profile:
        _applyDebugProfileSurface();
      case Act0ControlledDemoCaptureSurfaceV1.worldCompletion:
        _applyDebugWorldCompletionSurface();
      case Act0ControlledDemoCaptureSurfaceV1.w12Terminal:
        _applyDebugW12TerminalSurface();
      case Act0ControlledDemoCaptureSurfaceV1.sessionSummary:
        _applyDebugSessionSummarySurface();
      case Act0ControlledDemoCaptureSurfaceV1.runnerFirstCorrectFeedback:
        _applyDebugFirstCorrectFeedbackSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.firstWeekHome:
        _applyDebugFirstWeekHomeSurface();
      case Act0ControlledDemoCaptureSurfaceV1.reviewEmpty:
        _applyDebugReviewEmptySurface();
      case Act0ControlledDemoCaptureSurfaceV1.firstWeekReview:
        _applyDebugReviewSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.firstWeekLearn:
        _applyDebugLearnSurface();
      case Act0ControlledDemoCaptureSurfaceV1.firstWeekProfile:
        _applyDebugProfileSurface();
      case Act0ControlledDemoCaptureSurfaceV1.runnerFirstWrongFeedback:
        _applyDebugFirstWrongFeedbackSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.repairFocus:
        _applyDebugRepairProofSurface(
          state,
          outcome: _Act0DebugRepairProofOutcomeV1.wrong,
        );
      case Act0ControlledDemoCaptureSurfaceV1.repairResult:
        _applyDebugRepairProofSurface(
          state,
          outcome: _Act0DebugRepairProofOutcomeV1.correct,
        );
      case Act0ControlledDemoCaptureSurfaceV1.sessionRepair:
        _applyDebugRepairProofSurface(
          state,
          outcome: _Act0DebugRepairProofOutcomeV1.wrong,
        );
      case Act0ControlledDemoCaptureSurfaceV1.day2ReturnHome:
        _applyDebugDay2ReturnHomeSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.day2PracticeRepairTarget:
        _applyDebugDay2PracticeRepairTargetSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.day2ReviewContinuation:
        _applyDebugDay2ReviewContinuationSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.day2ProfileActiveRepair:
        _applyDebugDay2ProfileActiveRepairSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.profileEvidence:
        _applyDebugProfileEvidenceSurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2HomeFresh:
        _applyDebugWave2HomeFreshSurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2HomeProgressed:
        _applyDebugWave2HomeProgressedSurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2HomeRepairReturn:
        _applyDebugDay2ReturnHomeSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.wave2LearnFresh:
        _applyDebugWave2LearnFreshSurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2LearnProgressed:
        _applyDebugWave2LearnProgressedSurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2PracticeNoRepair:
        _applyDebugWave2PracticeNoRepairSurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2PracticeActiveRepairHub:
        _applyDebugWave2PracticeActiveRepairHubSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.wave2ReviewEmpty:
        _applyDebugWave2ReviewEmptySurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2ReviewMiss:
        _applyDebugReviewSurface(state);
      case Act0ControlledDemoCaptureSurfaceV1.wave2ProfileFresh:
        _applyDebugWave2ProfileFreshSurface();
      case Act0ControlledDemoCaptureSurfaceV1.wave2ProfileProgressed:
        _applyDebugWave2ProfileProgressedSurface();
    }
  }

  void _resetDebugSurfaceChrome() {
    _debugFreshLearnerV1 = false;
    _showPlacement = false;
    _showWelcome = false;
    _welcomeHandoffStartsRecommendedTaskV1 = false;
    _showPlayHub = true;
    _returnToPlayHubOnBack = false;
    _showWorldMenu = false;
    _learnDetailWorldId = null;
    _learnDetailLessonId = null;
    _learnPopupTaskId = null;
    _selectedOptionId = null;
    _teachingStepIndex = 0;
    _blockCompletionSummary = null;
    _activePracticeGroupId = null;
    _clearActiveRepairLaunchV1();
    _activeRepairSourceTaskId = null;
    _activePracticeRepairQueueRequestV1 = null;
    _activeRepairResultReceiptLine = null;
    _debugReviewEmptyV1 = false;
    _activeRepairSessionSummaryLines = const <String>[];
    _practiceCompletionTitle = null;
    _practiceCompletionBody = null;
    _mistakeRecords.clear();
    _openRepairIntentBySourceTaskId.clear();
    _resolvedMistakeTaskIds.clear();
    _cleanTaskIds.clear();
    _retentionMemoryByTaskId.clear();
    _endPlacementAssessmentRunV1();
    _placementDiagnosticActive = false;
    _placementIntroVisible = true;
    _placementQuestionIndex = 0;
    _placementDiagnosticIndex = 0;
    _placementDiagnosticCorrect = 0;
    _placementDiagnosticScore = 0;
    _placementHandoffActive = false;
    _placementAnswerIds.clear();
    _placementDiagnosticHitSignals.clear();
    _placementDiagnosticMissSignals.clear();
    _resetLessonRunMetrics();
  }

  void _applyDebugPlacementSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.home;
    _showPlacement = true;
    _welcomeCompletedV1 = false;
  }

  void _applyDebugWelcomeSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.home;
    _showWelcome = true;
    _welcomeCompletedV1 = false;
  }

  void _applyDebugHomeSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.home;
  }

  void _applyDebugFirstWeekHomeSurface() {
    _applyDebugHomeSurface();
    _completedTaskIds.add('actions_terms_intro');
  }

  void _applyDebugLearnSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.learn;
    _seedLearnRouteFocusV1(
      lessonId: _selectedLessonId,
      taskId: _selectedTaskId,
    );
  }

  void _seedLearnRouteFocusV1({
    required String lessonId,
    required String taskId,
  }) {
    _selectedLessonId = lessonId;
    _selectedTaskId = taskId;
    _learnDetailLessonId = null;
    _learnPopupTaskId = null;
  }

  void _applyDebugPracticeSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.play;
    _showPlayHub = true;
  }

  void _applyDebugProfileSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.profile;
  }

  void _applyDebugWave2FreshLearnerStateV1() {
    _resetDebugSurfaceChrome();
    final state = widget.state ?? Act0ShellStateV1.sample;
    final world = state.worldById('world_1');
    final lesson = world.lessons.first;
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = lesson.taskList.first.taskId;
    _debugFreshLearnerV1 = true;
    _completedLessonIds.clear();
    _completedTaskIds.clear();
    _skippedTaskIds.clear();
    _visibleSkippedTaskIds.clear();
    _cleanTaskIds.clear();
    _earnedXp = 0;
    _persistedStreakDays = 0;
    _lastDailyDate = '';
    _dailyCompletedRepCount = 0;
    _dailyCompletedTaskIds.clear();
    _dailyPracticeQueue = const Act0DailyPracticeQueueV1();
    _profileSkillValues.clear();
    _recentSkillGains.clear();
    _mistakeRecords.clear();
    _resolvedMistakeTaskIds.clear();
    _learningEvidenceHistoryV1 = const Act0LearningEvidenceHistoryV1();
    _studyObservationsV1 = const [];
    _conceptFamilyStateHistoryV1 = const Act0ConceptFamilyStateHistoryV1();
    _reviewMistakeHistoryV1 = const Act0ReviewMistakeHistoryV1();
    _reviewResolutionReceiptHistoryV1 =
        const Act0ReviewResolutionReceiptHistoryV1();
  }

  void _applyDebugWave2ProgressedLearnerStateV1() {
    _applyDebugWave2FreshLearnerStateV1();
    _debugFreshLearnerV1 = false;
    final state = widget.state ?? Act0ShellStateV1.sample;
    final world = state.worldById('world_1');
    final completedLesson = world.lessons.first;
    final nextLesson = world.lessons[1];
    final completedTaskIds = completedLesson.taskList
        .map((task) => task.taskId)
        .toSet();
    _selectedWorldId = world.worldId;
    _completedLessonIds.add(completedLesson.lessonId);
    _completedTaskIds.addAll(completedTaskIds);
    _cleanTaskIds.addAll(completedTaskIds);
    _selectedLessonId = nextLesson.lessonId;
    _selectedTaskId = nextLesson.taskList.first.taskId;
    _persistedStreakDays = 3;
  }

  void _applyDebugWave2HomeFreshSurface() {
    _applyDebugWave2FreshLearnerStateV1();
    _tab = Act0ShellTabV1.home;
  }

  void _applyDebugWave2HomeProgressedSurface() {
    _applyDebugWave2ProgressedLearnerStateV1();
    _tab = Act0ShellTabV1.home;
  }

  void _applyDebugWave2LearnFreshSurface() {
    _applyDebugWave2FreshLearnerStateV1();
    _tab = Act0ShellTabV1.learn;
    _seedLearnRouteFocusV1(
      lessonId: _selectedLessonId,
      taskId: _selectedTaskId,
    );
  }

  void _applyDebugWave2LearnProgressedSurface() {
    _applyDebugWave2ProgressedLearnerStateV1();
    _tab = Act0ShellTabV1.learn;
    _seedLearnRouteFocusV1(
      lessonId: _selectedLessonId,
      taskId: _selectedTaskId,
    );
  }

  void _applyDebugWave2PracticeNoRepairSurface() {
    _applyDebugWave2ProgressedLearnerStateV1();
    _tab = Act0ShellTabV1.play;
    _showPlayHub = true;
  }

  void _applyDebugWave2PracticeActiveRepairHubSurface(Act0ShellStateV1 state) {
    if (_seedDebugDay2OpenRepairStateV1(state) == null) {
      _applyDebugWave2PracticeNoRepairSurface();
      return;
    }
    _tab = Act0ShellTabV1.play;
    _showPlayHub = true;
    _returnToPlayHubOnBack = false;
  }

  void _applyDebugWave2ReviewEmptySurface() {
    _applyDebugWave2FreshLearnerStateV1();
    _tab = Act0ShellTabV1.review;
    _debugReviewEmptyV1 = true;
    _mistakeRecords.clear();
    _resolvedMistakeTaskIds.clear();
  }

  void _applyDebugWave2ProfileFreshSurface() {
    _applyDebugWave2FreshLearnerStateV1();
    _tab = Act0ShellTabV1.profile;
  }

  void _applyDebugWave2ProfileProgressedSurface() {
    _applyDebugWave2ProgressedLearnerStateV1();
    _applyDebugProfileEvidenceSurface();
    _completedTaskIds.add('actions_check_drill');
    _cleanTaskIds.add('actions_check_drill');
    _persistedStreakDays = 3;
  }

  void _applyDebugRunnerSurface(
    Act0ShellStateV1 state, {
    required Act0LessonPhaseV1 phase,
  }) {
    _resetDebugSurfaceChrome();
    final targetWorldId = widget.debugHarnessEntry?.worldId ?? 'world_1';
    final targetLessonId =
        widget.debugHarnessEntry?.lessonId ?? 'what_poker_is';
    final targetTaskId =
        widget.debugHarnessEntry?.taskId ?? 'what_poker_is_theory';
    if (!state.worlds.any((candidate) => candidate.worldId == targetWorldId)) {
      _applyDebugHomeSurface();
      return;
    }
    final world = _worldById(state.worlds, targetWorldId);
    if (!world.lessons.any((lesson) => lesson.lessonId == targetLessonId)) {
      _applyDebugHomeSurface();
      return;
    }
    final lesson = _lessonById(world.lessons, targetLessonId);
    if (!lesson.taskList.any((task) => task.taskId == targetTaskId)) {
      _applyDebugHomeSurface();
      return;
    }
    _startTaskByIds(
      world,
      lesson.lessonId,
      targetTaskId,
      allowDrillBypass: phase != Act0LessonPhaseV1.theory,
    );
    _returnToPlayHubOnBack = false;
    _phase = phase;
    final task = _taskById(lesson, targetTaskId);
    if (phase == Act0LessonPhaseV1.drill) {
      _teachingStepIndex = task.runner.teachingSteps.length;
    } else if (phase == Act0LessonPhaseV1.review) {
      _teachingStepIndex = task.runner.teachingSteps.length;
      final selectedOption = task.runner.options
          .cast<Act0RunnerOptionV1?>()
          .firstWhere(
            (option) =>
                option != null &&
                (widget.debugHarnessEntry?.feedbackCorrect == true
                    ? option.isCorrect
                    : !option.isCorrect),
            orElse: () =>
                task.runner.options.isEmpty ? null : task.runner.options.first,
          );
      _selectedOptionId = selectedOption?.id;
    }
  }

  void _applyDebugFirstCorrectFeedbackSurface(Act0ShellStateV1 state) {
    _resetDebugSurfaceChrome();
    final world = state.worldById('world_1');
    final lesson = _lessonById(world.lessons, 'fold_check_call_raise');
    final task = _taskById(lesson, 'actions_check_drill');
    _startTaskByIds(
      world,
      lesson.lessonId,
      task.taskId,
      allowDrillBypass: true,
    );
    _returnToPlayHubOnBack = false;
    _placementHandoffActive = true;
    _placementDiagnosticActive = false;
    _phase = Act0LessonPhaseV1.review;
    _teachingStepIndex = task.runner.teachingSteps.length;
    final correctOption = task.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) => option != null && option.isCorrect,
          orElse: () =>
              task.runner.options.isEmpty ? null : task.runner.options.first,
        );
    _selectedOptionId = correctOption?.id;
  }

  void _applyDebugFirstWrongFeedbackSurface(Act0ShellStateV1 state) {
    _resetDebugSurfaceChrome();
    final world = state.worldById('world_1');
    final lesson = _lessonById(world.lessons, 'fold_check_call_raise');
    final task = _taskById(lesson, 'actions_check_drill');
    _startTaskByIds(
      world,
      lesson.lessonId,
      task.taskId,
      allowDrillBypass: true,
    );
    _returnToPlayHubOnBack = false;
    _placementHandoffActive = true;
    _placementDiagnosticActive = false;
    _phase = Act0LessonPhaseV1.review;
    _teachingStepIndex = task.runner.teachingSteps.length;
    final wrongOption = task.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) =>
              option != null && option.quality == Act0FeedbackQualityV1.wrong,
          orElse: () =>
              task.runner.options.isEmpty ? null : task.runner.options.first,
        );
    _selectedOptionId = wrongOption?.id;
  }

  void _applyDebugRepairProofSurface(
    Act0ShellStateV1 state, {
    required _Act0DebugRepairProofOutcomeV1 outcome,
  }) {
    _resetDebugSurfaceChrome();
    final world = state.worldById('world_1');
    final sourceLesson = _lessonById(world.lessons, 'fold_check_call_raise');
    final sourceTask = _taskById(sourceLesson, 'actions_legal_context');
    final missedOption = sourceTask.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) =>
              option != null && option.quality == Act0FeedbackQualityV1.wrong,
          orElse: () => sourceTask.runner.options.isEmpty
              ? null
              : sourceTask.runner.options.first,
        );
    final betterOption = sourceTask.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) => option != null && option.isCorrect,
          orElse: () => missedOption,
        );
    if (missedOption == null || betterOption == null) {
      _applyDebugHomeSurface();
      return;
    }
    _storeOpenRepairIntentForMissV1(
      sourceWorldId: world.worldId,
      sourceLessonId: sourceLesson.lessonId,
      sourceTaskId: sourceTask.taskId,
      runner: sourceTask.runner,
      option: missedOption,
    );
    final mistake = Act0MistakeCardV1(
      taskId: sourceTask.taskId,
      lessonId: sourceLesson.lessonId,
      worldId: world.worldId,
      title: _localizedTaskTitleV1(sourceTask),
      weaknessLabel: _categoryForLesson(sourceLesson.lessonId),
      selectedOptionId: missedOption.id,
      selectedLabel: missedOption.label,
      betterLabel: betterOption.betterAnswerLabel,
      reason: missedOption.feedbackReason,
      attempts: 1,
      contextLabels: _repairContextLabels(sourceTask.runner, missedOption),
      repairActionLabel: _repairActionLabel(sourceTask),
    );
    _startMistakeRepair(
      world,
      mistake,
      returnToPlayHub: false,
      practiceGroupId: 'weak_spots',
      skipTeaching: true,
      allowDrillBypass: true,
    );
    final repairLesson = _lessonById(world.lessons, _selectedLessonId);
    final repairTask = _taskById(repairLesson, _selectedTaskId);
    _phase = Act0LessonPhaseV1.review;
    _teachingStepIndex = repairTask.runner.teachingSteps.length;
    final selectedOption = repairTask.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) => outcome == _Act0DebugRepairProofOutcomeV1.correct
              ? option != null && option.isCorrect
              : option != null && option.quality == Act0FeedbackQualityV1.wrong,
          orElse: () => repairTask.runner.options.isEmpty
              ? null
              : repairTask.runner.options.first,
        );
    if (selectedOption == null) {
      _applyDebugHomeSurface();
      return;
    }
    _activeRepairResultReceiptLine = _repairResultReceiptLineForOptionV1(
      selectedTask: repairTask,
      option: selectedOption,
    );
    _activeRepairSessionSummaryLines = _repairSessionSummaryLinesForOptionV1(
      selectedTask: repairTask,
      option: selectedOption,
    );
    _selectedOptionId = selectedOption.id;
  }

  Act0MistakeCardV1? _seedDebugDay2OpenRepairStateV1(Act0ShellStateV1 state) {
    _resetDebugSurfaceChrome();
    final world = state.worldById('world_1');
    final sourceLesson = _lessonById(world.lessons, 'fold_check_call_raise');
    final sourceTask = _taskById(sourceLesson, 'actions_legal_context');
    final missedOption = sourceTask.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) =>
              option != null && option.quality == Act0FeedbackQualityV1.wrong,
          orElse: () => sourceTask.runner.options.isEmpty
              ? null
              : sourceTask.runner.options.first,
        );
    final betterOption = sourceTask.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) => option != null && option.isCorrect,
          orElse: () => missedOption,
        );
    if (missedOption == null || betterOption == null) {
      return null;
    }
    _selectedWorldId = world.worldId;
    _selectedLessonId = sourceLesson.lessonId;
    _selectedTaskId = sourceTask.taskId;
    _completedTaskIds.add('actions_terms_intro');
    _storeOpenRepairIntentForMissV1(
      sourceWorldId: world.worldId,
      sourceLessonId: sourceLesson.lessonId,
      sourceTaskId: sourceTask.taskId,
      runner: sourceTask.runner,
      option: missedOption,
    );
    final record = _Act0MistakeRecordV1(
      taskId: sourceTask.taskId,
      lessonId: sourceLesson.lessonId,
      worldId: world.worldId,
      title: _localizedTaskTitleV1(sourceTask),
      weaknessLabel: _categoryForLesson(sourceLesson.lessonId),
      selectedOptionId: missedOption.id,
      selectedLabel: missedOption.label,
      betterLabel: betterOption.betterAnswerLabel,
      reason: missedOption.feedbackReason,
      contextLabels: _repairContextLabels(sourceTask.runner, missedOption),
      repairActionLabel: _repairActionLabel(sourceTask),
      attempts: 1,
    );
    _mistakeRecords[sourceTask.taskId] = record;
    _retentionMemoryByTaskId[sourceTask.taskId] = _Act0RetentionMemoryEntryV1(
      taskId: sourceTask.taskId,
      lessonId: sourceLesson.lessonId,
      worldId: world.worldId,
      status: _Act0RetentionMemoryStatusV1.openRepair,
      attempts: 1,
      fixedAtSequence: 0,
      lastRecheckSequence: 0,
      successfulRecheckCount: 0,
    );
    return record.toCard(
      repairActionLabelOverride: _repairIntentSurfaceCopyLineV1(
        sourceTask.taskId,
      ),
    );
  }

  void _applyDebugDay2ReturnHomeSurface(Act0ShellStateV1 state) {
    if (_seedDebugDay2OpenRepairStateV1(state) == null) {
      _applyDebugHomeSurface();
      return;
    }
    _tab = Act0ShellTabV1.home;
    if (_lastSessionLearnerStateV1 case final lastSession?) {
      _emitDay2ReturnTelemetryV1(lastSession);
    } else {
      _recordTelemetryEventV1('day2_return', <String, Object?>{
        'schemaVersion': 1,
        'worldId': _selectedWorldId,
        'world_id': _selectedWorldId,
        'source_surface': 'act0_home',
      });
    }
  }

  void _applyDebugDay2PracticeRepairTargetSurface(Act0ShellStateV1 state) {
    final mistake = _seedDebugDay2OpenRepairStateV1(state);
    if (mistake == null) {
      _applyDebugPracticeSurface();
      return;
    }
    final world = state.worldById('world_1');
    _startMistakeRepair(
      world,
      mistake,
      returnToPlayHub: false,
      practiceGroupId: 'weak_spots',
      skipTeaching: true,
      allowDrillBypass: true,
    );
  }

  void _applyDebugDay2ReviewContinuationSurface(Act0ShellStateV1 state) {
    if (_seedDebugDay2OpenRepairStateV1(state) == null) {
      _applyDebugReviewSurface(state);
      return;
    }
    _tab = Act0ShellTabV1.review;
  }

  void _applyDebugDay2ProfileActiveRepairSurface(Act0ShellStateV1 state) {
    if (_seedDebugDay2OpenRepairStateV1(state) == null) {
      _applyDebugProfileSurface();
      return;
    }
    _tab = Act0ShellTabV1.profile;
  }

  void _applyDebugReviewSurface(Act0ShellStateV1 state) {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.review;
    final world = state.worldById('world_1');
    final lesson = _lessonById(world.lessons, 'what_poker_is');
    final task = _taskById(lesson, 'what_poker_is_theory');
    final wrongOption = task.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) => option != null && !option.isCorrect,
          orElse: () =>
              task.runner.options.isEmpty ? null : task.runner.options.first,
        );
    final betterOption = task.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere(
          (option) => option != null && option.isCorrect,
          orElse: () => wrongOption,
        );
    if (wrongOption == null || betterOption == null) {
      return;
    }
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _mistakeRecords[task.taskId] = _Act0MistakeRecordV1(
      taskId: task.taskId,
      lessonId: lesson.lessonId,
      worldId: world.worldId,
      title: task.title,
      weaknessLabel: _categoryForLesson(lesson.lessonId),
      selectedOptionId: wrongOption.id,
      selectedLabel: wrongOption.label,
      betterLabel: betterOption.betterAnswerLabel,
      reason: wrongOption.feedbackReason,
      contextLabels: _repairContextLabels(task.runner, wrongOption),
      repairActionLabel: _repairActionLabel(task),
      attempts: 1,
    );
  }

  void _applyDebugReviewEmptySurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.review;
    _debugReviewEmptyV1 = true;
    _mistakeRecords.clear();
    _resolvedMistakeTaskIds.clear();
    _reviewMistakeHistoryV1 = const Act0ReviewMistakeHistoryV1();
    _reviewResolutionReceiptHistoryV1 =
        const Act0ReviewResolutionReceiptHistoryV1();
  }

  void _applyDebugWorldCompletionSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.play;
    _showPlayHub = true;
    _blockCompletionSummary = const Act0BlockCompletionSummaryV1(
      lessonTitle: 'Showdown winning',
      xpEarned: 24,
      errorCount: 0,
      taskCount: 4,
      correctCount: 4,
      startLevel: 1,
      endLevel: 2,
      startXp: 188,
      endXp: 12,
      xpTarget: 200,
      sharkyLine: 'You closed the first world cleanly.',
      skillGains: <Act0SkillGainV1>[
        Act0SkillGainV1(
          label: 'Hand reading',
          gain: 8,
          source: 'Poker from Zero',
        ),
        Act0SkillGainV1(
          label: 'Table sense',
          gain: 5,
          source: 'Poker from Zero',
        ),
      ],
      milestoneTier: Act0ProgressMilestoneTierV1.world,
      worldNumber: 1,
      worldTitle: 'Poker from Zero',
      nextWorldNumber: 2,
      nextWorldTitle: 'Hand Discipline',
      perfectClearCount: 12,
      completedClearCount: 12,
      futureRecheckCount: 2,
    );
    _recordTelemetryEventV1('world_complete', <String, Object?>{
      'schemaVersion': 1,
      'worldId': 'world_1',
      'world_id': 'world_1',
      'completedClearCount': 12,
      'completed_clear_count': 12,
      'perfectClearCount': 12,
      'perfect_clear_count': 12,
      'source_surface': 'act0_completion',
    });
  }

  void _applyDebugW12TerminalSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.play;
    _showPlayHub = true;
    _blockCompletionSummary = const Act0BlockCompletionSummaryV1(
      lessonTitle: 'Mindset Bridge',
      xpEarned: 24,
      errorCount: 0,
      taskCount: 4,
      correctCount: 4,
      startLevel: 11,
      endLevel: 12,
      startXp: 176,
      endXp: 0,
      xpTarget: 200,
      sharkyLine:
          'Volume I review brings the route together while later worlds stay locked.',
      skillGains: <Act0SkillGainV1>[
        Act0SkillGainV1(
          label: 'Process discipline',
          gain: 7,
          source: 'Mindset Bridge',
        ),
        Act0SkillGainV1(
          label: 'Reset quality',
          gain: 5,
          source: 'Mindset Bridge',
        ),
      ],
      milestoneTier: Act0ProgressMilestoneTierV1.world,
      worldNumber: 12,
      worldTitle: 'Mindset Bridge',
      nextWorldTitle: 'Volume I review',
      perfectClearCount: 12,
      completedClearCount: 12,
      futureRecheckCount: 0,
      futureProveCount: 0,
    );
    _recordTelemetryEventV1('world_complete', <String, Object?>{
      'schemaVersion': 1,
      'worldId': 'world_12',
      'world_id': 'world_12',
      'completedClearCount': 12,
      'completed_clear_count': 12,
      'perfectClearCount': 12,
      'perfect_clear_count': 12,
      'source_surface': 'act0_completion',
    });
  }

  void _applyDebugSessionSummarySurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.play;
    _showPlayHub = true;
    const runId = 'run_v1|world_1|fold_check_call_raise|lesson|1';
    _learningEvidenceHistoryV1 = const Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        Act0LearningEvidenceRecordV1(
          recordId:
              'v1|world_1|fold_check_call_raise|actions_check_drill|actionList|check|1',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_check_drill',
          choiceId: 'check',
          expectedChoiceId: 'check',
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
          runId: runId,
          runKind: 'lesson',
          runOrdinal: 1,
          sourceWorldId: 'world_1',
          sourceLessonId: 'fold_check_call_raise',
        ),
        Act0LearningEvidenceRecordV1(
          recordId:
              'v1|world_1|fold_check_call_raise|actions_check_drill|actionList|fold|2',
          createdOrder: 2,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_check_drill',
          choiceId: 'fold',
          expectedChoiceId: 'check',
          isCorrect: false,
          errorType: 'missed_action_read',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'incorrect',
          runId: runId,
          runKind: 'lesson',
          runOrdinal: 1,
          sourceWorldId: 'world_1',
          sourceLessonId: 'fold_check_call_raise',
        ),
      ],
    );
    _conceptFamilyStateHistoryV1 =
        Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(
          _learningEvidenceHistoryV1,
        );
    _blockCompletionSummary = const Act0BlockCompletionSummaryV1(
      lessonTitle: 'Fold, check, call, raise',
      xpEarned: 20,
      errorCount: 1,
      taskCount: 2,
      correctCount: 1,
      startLevel: 1,
      endLevel: 1,
      startXp: 80,
      endXp: 100,
      xpTarget: 200,
      nextLessonTitle: 'Blinds and action order',
      sharkyLine: 'Good read. Keep the table clue in view.',
      perfectClearCount: 1,
      completedClearCount: 2,
    );
  }

  void _applyDebugProfileEvidenceSurface() {
    _resetDebugSurfaceChrome();
    _tab = Act0ShellTabV1.profile;
    _learningEvidenceHistoryV1 = const Act0LearningEvidenceHistoryV1(
      records: <Act0LearningEvidenceRecordV1>[
        Act0LearningEvidenceRecordV1(
          recordId: 'profile_evidence_fixture|action_read|1',
          createdOrder: 1,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_check_drill',
          choiceId: 'check',
          expectedChoiceId: 'check',
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
        ),
        Act0LearningEvidenceRecordV1(
          recordId: 'profile_evidence_fixture|action_read|2',
          createdOrder: 2,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_check_drill',
          choiceId: 'check',
          expectedChoiceId: 'check',
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
        ),
        Act0LearningEvidenceRecordV1(
          recordId: 'profile_evidence_fixture|action_read|3',
          createdOrder: 3,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_check_drill',
          choiceId: 'check',
          expectedChoiceId: 'check',
          isCorrect: true,
          errorType: 'none',
          repairFocusId: '',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'correct',
        ),
        Act0LearningEvidenceRecordV1(
          recordId: 'profile_evidence_fixture|action_read|4',
          createdOrder: 4,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_check_drill',
          choiceId: 'fold',
          expectedChoiceId: 'check',
          isCorrect: false,
          errorType: 'missed_action_read',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'incorrect',
        ),
        Act0LearningEvidenceRecordV1(
          recordId: 'profile_evidence_fixture|action_read|5',
          createdOrder: 5,
          worldId: 'world_1',
          lessonId: 'fold_check_call_raise',
          taskId: 'actions_check_drill',
          choiceId: 'fold',
          expectedChoiceId: 'check',
          isCorrect: false,
          errorType: 'missed_action_read',
          repairFocusId: 'no_bet_yet',
          skillAtomId: 'action_read',
          decisionTimeBucket: '3_to_10s',
          resultKind: 'incorrect',
        ),
      ],
    );
    _conceptFamilyStateHistoryV1 =
        Act0ConceptFamilyStateHistoryV1.fromLearningEvidence(
          _learningEvidenceHistoryV1,
        );
  }
}
