part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewPlacementV1 on _Act0ShellPreviewScreenV1State {
  void _startPlacementDiagnostic(List<Act0WorldCardV1> worlds) {
    _placementDiagnosticIndex = 0;
    _placementDiagnosticCorrect = 0;
    _placementDiagnosticScore = 0;
    _placementDiagnosticHitSignals.clear();
    _placementDiagnosticMissSignals.clear();
    _placementIntroVisible = false;
    _beginPlacementAssessmentRunV1();
    _startPlacementDiagnosticAt(worlds, _placementDiagnosticIndex);
  }

  /// The Placement diagnostic is a real assessment: its three answers get one
  /// source-owned `placement` run and the active learner session before the
  /// first decision, so no assessed record is saved without provenance.
  void _beginPlacementAssessmentRunV1() {
    final spot = _placementDiagnosticSpotsV1.first;
    final session = _ensureActiveSessionIdentityV1(
      worldId: spot.worldId,
      lessonId: spot.lessonId,
    );
    if (session.startedNewSession) {
      _recordTelemetryEventV1('session_start', <String, Object?>{
        'schemaVersion': 1,
        'worldId': spot.worldId,
        'world_id': spot.worldId,
        'lessonId': spot.lessonId,
        'lesson_id': spot.lessonId,
        'taskId': spot.taskId,
        'task_id': spot.taskId,
        'source_surface': 'act0_placement',
      });
    }
    _startLearningEvidenceRunV1(
      worldId: spot.worldId,
      lessonId: spot.lessonId,
      runKind: act0PlacementAssessmentRunKindV1,
      startedBy: 'placement_diagnostic',
    );
  }

  void _endPlacementAssessmentRunV1() {
    if (_activeLearningEvidenceRunKeyV1?.runKind ==
        act0PlacementAssessmentRunKindV1) {
      _activeLearningEvidenceRunKeyV1 = null;
    }
  }

  /// The recommended first lesson opens its own lesson run (and resumes the
  /// active session) at the moment the runner is actually entered.
  void _beginPlacementRecommendedLessonRunV1() {
    if (_selectedLessonId.isEmpty || _selectedTaskId.isEmpty) {
      return;
    }
    _emitLessonStartedTelemetryV1(
      lessonId: _selectedLessonId,
      taskId: _selectedTaskId,
    );
    _startLearningEvidenceRunV1(
      worldId: _selectedWorldId,
      lessonId: _selectedLessonId,
      runKind: 'lesson',
      startedBy: 'placement_recommendation',
    );
  }

  bool _startNextPlacementDiagnostic(List<Act0WorldCardV1> worlds) {
    final nextIndex = _placementDiagnosticIndex + 1;
    if (nextIndex >= _placementDiagnosticSpotsV1.length) {
      return false;
    }
    _placementDiagnosticIndex = nextIndex;
    _startPlacementDiagnosticAt(worlds, _placementDiagnosticIndex);
    return true;
  }

  void _startPlacementDiagnosticAt(
    List<Act0WorldCardV1> worlds,
    int diagnosticIndex,
  ) {
    final spot = _placementDiagnosticSpotsV1[diagnosticIndex];
    final world = _worldById(worlds, spot.worldId);
    final lesson = _lessonById(world.lessons, spot.lessonId);
    final task = _taskById(lesson, spot.taskId);
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    _tab = Act0ShellTabV1.play;
    _showPlacement = false;
    _placementDiagnosticActive = true;
    _placementIntroVisible = false;
    _showPlayHub = false;
    _returnToPlayHubOnBack = false;
    _phase = Act0LessonPhaseV1.drill;
    _selectedOptionId = null;
    // Placement diagnostic is assessment-only. Skip lesson teaching copy here;
    // the same task still teaches normally when launched from the learning path.
    _teachingStepIndex = task.runner.teachingSteps.length;
    // Selecting the diagnostic spot is not a lesson replay: per-run metrics
    // reset, but historical lesson-run boundaries must not move.
    final boundaries = Map<String, int?>.from(_lessonRunEvidenceBoundariesV1);
    final boundaryLessonId = _lessonRunEvidenceLessonIdV1;
    final boundaryStartOrder = _lessonRunEvidenceStartOrderV1;
    _resetLessonRunMetrics();
    _lessonRunEvidenceBoundariesV1
      ..clear()
      ..addAll(boundaries);
    _lessonRunEvidenceLessonIdV1 = boundaryLessonId;
    _lessonRunEvidenceStartOrderV1 = boundaryStartOrder;
  }

  Future<void> _persistPlacementCompletionV1(
    Act0PlacementResultV1 result,
  ) async {
    final epoch = _recoveryEpochV1;
    final score = _placementDiagnosticScore;
    await ProgressService.saveIntakeProfile(<String, Object?>{
      'version': 'act0_placement_v1',
      'completedAt': DateTime.now().toUtc().toIso8601String(),
      'diagnosticCorrect': result.diagnosticCorrect,
      'diagnosticTotal': result.diagnosticTotal,
      'placementLevel': result.level.name,
      'recommendedLessonId': result.recommendedLessonId,
      'recommendedTaskId': result.recommendedTaskId,
      'focusLabel': result.level.name,
    });
    if (!mounted || epoch != _recoveryEpochV1) return;
    await ProgressService.setPlacementScoreV1(score);
  }

  String _firstValueReceiptLineV1(Act0LessonTaskV1? task) {
    return 'First read logged. Next: use it once more.';
  }

  String? _repairReasonLineForFeedbackV1(Act0LessonTaskV1? selectedTask) {
    if (selectedTask == null) {
      return null;
    }
    final sourceTaskId = _activeRepairTaskId == selectedTask.taskId
        ? (_activeRepairSourceTaskId ?? selectedTask.taskId)
        : selectedTask.taskId;
    final target = _openRepairIntentTargetForSourceTaskV1(sourceTaskId);
    if (target == null) {
      return null;
    }
    final receipt = _Act0NextUsefulHandReasonReceiptV1.forRepairIntent(
      sourceTaskId: sourceTaskId,
      target: target,
      practiceGroupId: _activePracticeGroupId,
      repeatedMissCount: _mistakeRecords[sourceTaskId]?.attempts ?? 1,
    );
    final bridge = _Act0NextUsefulHandCopyBridgeV1.fromReceipt(receipt);
    final line = bridge.renderedCopyLine.trim();
    return line.isEmpty ? null : line;
  }

  String? _repairResultReceiptLineForOptionV1({
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerOptionV1 option,
  }) {
    return _repairReceiptForOptionV1(
      selectedTask: selectedTask,
      option: option,
    )?.visibleCopy;
  }

  Act0LearningReceiptV1? _repairReceiptForOptionV1({
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerOptionV1 option,
  }) {
    // The base feedback can still teach the correct action, but a
    // hint-assisted answer must not generate an independent repair receipt.
    if (_activeRepairTaskId != selectedTask.taskId ||
        !_choiceHasIndependentProvenanceV1) {
      return null;
    }
    final sourceTaskId = _activeRepairSourceTaskId ?? selectedTask.taskId;
    final intent =
        _activeRepairObligationV1 ??
        _openRepairIntentBySourceTaskId[sourceTaskId];
    if (intent == null || !_hasValidatedRepairTargetV1(intent)) return null;
    // Positive feedback is immediate teaching. A repair claim waits for the
    // actual canonical target attempt; a synthetic display outcome is no proof.
    if (!_repairOutcomeProjectionV1.outcomes.any(
      (outcome) =>
          outcome.repairOccurrenceId == intent.repairOccurrenceId &&
          outcome.sourceTaskId == sourceTaskId &&
          outcome.targetTaskId == selectedTask.taskId &&
          outcome.selectedChoiceId == option.id &&
          outcome.isCorrect == option.isCorrect &&
          act0RepairGoalOutcomeIsEligibleV1(
            intent: intent,
            outcome: outcome,
            learningEvidence: _learningEvidenceHistoryV1,
            currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
          ),
    ))
      return null;
    final clueLabel = intent.missedSignalLabel;
    return Act0LearningReceiptV1.fromEvidence(
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      repairIntents: [intent],
      focusLabel: clueLabel,
      sourceTaskId: sourceTaskId,
      repairOutcomes: _repairOutcomeProjectionV1.outcomes,
      learningEvidence: _learningEvidenceHistoryV1,
      conceptFamilyId: intent.missedSignalId,
      isExactReplay:
          sourceTaskId == selectedTask.taskId ||
          act0IsExactRepairMappingTypeV1(intent.mappingType),
    );
  }

  List<String> _repairSessionSummaryLinesForOptionV1({
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerOptionV1 option,
  }) {
    return _repairReceiptForOptionV1(
          selectedTask: selectedTask,
          option: option,
        )?.sessionSummaryLines ??
        const <String>[];
  }

  void _captureFirstValueReceiptCarryV1({
    required Act0RunnerStateV1 runner,
    required String sourceWorldId,
    required String sourceLessonId,
    required Act0LessonTaskV1 task,
    required Act0RunnerOptionV1 option,
  }) {
    if (_diagnosticLearningEntryV1 != null) return;
    if (!_placementHandoffActive || _placementDiagnosticActive) {
      return;
    }
    final receipt = act0FirstValueSkillReceiptForRunnerV1(
      runner: runner,
      option: option,
      taskFamily: task.resolvedTaskFamily,
    );
    if (receipt == null) {
      return;
    }
    _firstValueReceiptCarry = _Act0FirstValueReceiptCarryV1(
      skillReceiptId: receipt.receiptId,
      skillAtomId: receipt.skillAtomId,
      skillLabel: receipt.skillLabel,
      sourceSignalId: receipt.sourceSignalId,
      sourceSignalLabel: receipt.sourceSignalLabel,
      outcomeId: receipt.outcomeId,
      nextRepId: receipt.nextRepId,
      nextRepLabel: receipt.nextRepLabel,
      sourceWorldId: sourceWorldId,
      sourceLessonId: sourceLessonId,
      sourceTaskId: task.taskId,
    );
    _firstValueTodayShownTelemetryKey = '';
    _persistProgress();
  }

  Future<void> _startPlacementRecommendation(
    List<Act0WorldCardV1> worlds, {
    required bool fromZero,
    bool directRunner = false,
  }) async {
    final world = _worldById(worlds, 'world_1');
    final result = _placementResult;
    final guideLesson = _lessonById(world.lessons, 'what_poker_is');
    final guideTask = guideLesson.taskList.first;
    final recommendedLessonId = fromZero || result == null
        ? guideLesson.lessonId
        : result.recommendedLessonId;
    final recommendedLesson = _lessonById(world.lessons, recommendedLessonId);
    final recommendedTaskId = fromZero || result == null
        ? guideTask.taskId
        : result.recommendedTaskId;
    final recommendedTask = _taskByIdWithTaskIds(
      recommendedLesson,
      recommendedTaskId,
      _pathClosedTaskIds,
    );
    // Retake (opened from Profile) keeps every earned completion; only first
    // install starts from an empty path.
    final retake = _placementRetakeV1;
    _placementRetakeV1 = false;
    if (!retake) {
      _completedTaskIds.clear();
      _completedLessonIds.clear();
    }
    if (fromZero) {
      _skippedTaskIds.clear();
      _visibleSkippedTaskIds.clear();
    }
    if (!fromZero && result != null) {
      final skipPlan = _buildPlacementSkipPlan(
        world: world,
        recommendedLessonId: recommendedLesson.lessonId,
        recommendedTaskId: recommendedTask.taskId,
      );
      // A retake re-measures skills and picks a focus; it never records new
      // placement skips (a skip is restored as completion on relaunch).
      final skipTaskIds = retake ? const <String>{} : skipPlan.taskIds;
      final skipOrdered = retake ? const <String>[] : skipPlan.orderedTaskIds;
      _skippedTaskIds.addAll(skipTaskIds);
      if (directRunner) {
        _visibleSkippedTaskIds.addAll(skipTaskIds);
      } else {
        _visibleSkippedTaskIds.removeAll(skipTaskIds);
        unawaited(_animatePlacementSkipReveal(skipOrdered));
      }
    }
    var focusLesson = directRunner ? recommendedLesson : guideLesson;
    var focusTask = directRunner ? recommendedTask : guideTask;
    if (retake) {
      // Never relaunch earned work, or a lesson that is still locked without
      // the skips a first-install placement would have recorded.
      final refreshed = _progressWorlds(
        widget.state ?? Act0ShellStateV1.sample,
      );
      final refreshedWorld = _worldById(refreshed, world.worldId);
      final refreshedFocus = _lessonById(
        refreshedWorld.lessons,
        focusLesson.lessonId,
      );
      if (_completedTaskIds.contains(focusTask.taskId) ||
          refreshedFocus.state == Act0LessonStateV1.locked) {
        focusLesson = _firstPlayableLesson(refreshedWorld);
        focusTask = _firstIncompleteTask(focusLesson);
      }
    }
    _selectedWorldId = world.worldId;
    _selectedLessonId = focusLesson.lessonId;
    _selectedTaskId = focusTask.taskId;
    final showWelcome = !_welcomeCompletedV1 && !_introductionSkippedV1;
    _showPlacement = false;
    _showWelcome = showWelcome;
    _welcomeHandoffStartsRecommendedTaskV1 = directRunner;
    _placementDiagnosticActive = false;
    _placementIntroVisible = false;
    _placementHandoffActive = true;
    _tab = directRunner && !showWelcome
        ? Act0ShellTabV1.play
        : Act0ShellTabV1.home;
    _showPlayHub = !(directRunner && !showWelcome);
    _returnToPlayHubOnBack = false;
    _showWorldMenu = false;
    _learnDetailWorldId = null;
    _learnDetailLessonId = null;
    _learnPopupTaskId = null;
    _firstValueReceiptCarry = null;
    _firstValueTodayShownTelemetryKey = '';
    _phase = focusTask.entryPhase;
    _selectedOptionId = null;
    _teachingStepIndex =
        directRunner && focusTask.phase == Act0LessonPhaseV1.drill
        ? focusTask.runner.teachingSteps.length
        : 0;
    _resetLessonRunMetrics();
    if (directRunner && !showWelcome) {
      _beginPlacementRecommendedLessonRunV1();
    }
    _persistProgress();
    await _persistPlacementCompletionV1(result ?? _buildPlacementResult());
  }

  Future<void> _skipIntroductionV1() async {
    if (_skipIntroductionSavingV1) return;
    final epoch = _recoveryEpochV1;
    _setStateV1(() => _skipIntroductionSavingV1 = true);
    try {
      await Act0FirstStartPreferencesV1.setIntroductionSkipped();
      if (!mounted || epoch != _recoveryEpochV1) return;
      _setStateV1(() {
        _introductionSkippedV1 = true;
        _showPlacement = false;
        _showWelcome = false;
        _tab = Act0ShellTabV1.home;
        // Home reuses the saved mission without grading or resetting work.
      });
      _persistProgress();
    } catch (_) {
      if (mounted && epoch == _recoveryEpochV1) {
        _showFirstStartSaveFailureV1();
      }
    } finally {
      if (mounted && epoch == _recoveryEpochV1) {
        _setStateV1(() => _skipIntroductionSavingV1 = false);
      }
    }
  }

  void _showFirstStartSaveFailureV1({bool aboveWelcomeActions = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        // Keep the 52-point onboarding CTA and its 12/16-point footer padding
        // reachable while the error is visible, with an 8-point gap.
        behavior: aboveWelcomeActions ? SnackBarBehavior.floating : null,
        margin: aboveWelcomeActions
            ? EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.paddingOf(context).bottom + 52 + 12 + 16 + 8,
              )
            : null,
        content: Text(
          Localizations.localeOf(context).languageCode == 'ru'
              ? '\u041d\u0435 \u0443\u0434\u0430\u043b\u043e\u0441\u044c \u0441\u043e\u0445\u0440\u0430\u043d\u0438\u0442\u044c. \u041f\u043e\u043f\u0440\u043e\u0431\u0443\u0439 \u0435\u0449\u0451 \u0440\u0430\u0437.'
              : 'Could not save. Please try again.',
        ),
      ),
    );
  }

  Future<void> _completeWelcomeV1() async {
    if (_welcomeCompletionSavingV1 || !_showWelcome) return;
    final epoch = _recoveryEpochV1;
    final completionEpoch = ++_welcomeCompletionEpochV1;
    final returnTab = _welcomeReturnTabV1;
    _setStateV1(() => _welcomeCompletionSavingV1 = true);
    bool isCurrent() =>
        mounted &&
        epoch == _recoveryEpochV1 &&
        completionEpoch == _welcomeCompletionEpochV1 &&
        _showWelcome &&
        returnTab == _welcomeReturnTabV1;
    try {
      await Act0FirstStartPreferencesV1.setWelcomeCompleted();
      if (!isCurrent()) return;
      final replayMode = _welcomeReturnTabV1 != null;
      _setStateV1(() {
        _welcomeCompletedV1 = true;
        _showWelcome = false;
        if (replayMode) {
          _tab = _welcomeReturnTabV1 ?? Act0ShellTabV1.profile;
        } else if (_welcomeHandoffStartsRecommendedTaskV1) {
          _tab = Act0ShellTabV1.play;
          _showPlayHub = false;
          _beginPlacementRecommendedLessonRunV1();
        } else {
          _tab = Act0ShellTabV1.home;
          final baseState = widget.state ?? Act0ShellStateV1.sample;
          final worlds = _progressWorlds(baseState);
          final selectedWorld = _worldById(worlds, _selectedWorldId);
          final firstLesson = _firstPlayableLesson(selectedWorld);
          final firstTask = _firstIncompleteTask(firstLesson);
          _seedLearnRouteFocusV1(
            lessonId: firstLesson.lessonId,
            taskId: firstTask.taskId,
          );
        }
        _welcomeReturnTabV1 = null;
      });
    } catch (_) {
      if (isCurrent()) {
        _showFirstStartSaveFailureV1(aboveWelcomeActions: true);
      }
    } finally {
      if (mounted &&
          epoch == _recoveryEpochV1 &&
          completionEpoch == _welcomeCompletionEpochV1) {
        _setStateV1(() => _welcomeCompletionSavingV1 = false);
      }
    }
  }

  _Act0PlacementSkipPlanV1 _buildPlacementSkipPlan({
    required Act0WorldCardV1 world,
    required String recommendedLessonId,
    required String recommendedTaskId,
  }) {
    final orderedTaskIds = <String>[];
    final guideLessonId = 'what_poker_is';
    final lessonIndex = world.lessons.indexWhere(
      (lesson) => lesson.lessonId == recommendedLessonId,
    );
    if (lessonIndex < 0) {
      return const _Act0PlacementSkipPlanV1(
        taskIds: <String>{},
        orderedTaskIds: <String>[],
      );
    }

    for (var i = 0; i < lessonIndex; i++) {
      final lesson = world.lessons[i];
      if (lesson.lessonId == guideLessonId) {
        continue;
      }
      for (final task in lesson.taskList) {
        orderedTaskIds.add(task.taskId);
      }
    }

    final recommendedLesson = world.lessons[lessonIndex];
    final recommendedTaskIndex = recommendedLesson.taskList.indexWhere(
      (task) => task.taskId == recommendedTaskId,
    );
    if (recommendedTaskIndex > 0) {
      for (var i = 0; i < recommendedTaskIndex; i++) {
        orderedTaskIds.add(recommendedLesson.taskList[i].taskId);
      }
    }

    return _Act0PlacementSkipPlanV1(
      taskIds: orderedTaskIds.toSet(),
      orderedTaskIds: orderedTaskIds,
    );
  }

  Future<void> _animatePlacementSkipReveal(List<String> orderedTaskIds) async {
    final epoch = _recoveryEpochV1;
    for (final taskId in orderedTaskIds) {
      await Future<void>.delayed(const Duration(milliseconds: 140));
      if (!mounted || epoch != _recoveryEpochV1) {
        return;
      }
      if (!_skippedTaskIds.contains(taskId) ||
          _visibleSkippedTaskIds.contains(taskId)) {
        continue;
      }
      _setStateV1(() {
        _visibleSkippedTaskIds.add(taskId);
      });
    }
  }

  /// Legacy saves written before `what_poker_is_content` was split out: a
  /// learner with a GENUINELY completed task beyond the guide had the content
  /// lesson auto-completed. Only completed tasks count; Placement skips do not.
  Set<String> _legacyCompatAutoCompletedLessonIdsV1({
    required _Act0PersistedProgressV1 parsed,
    required Act0ShellStateV1 state,
  }) {
    if (!_legacyCompatAppliesV1(parsed)) {
      return const <String>{};
    }
    final guideTaskIds = _guideTaskIdsV1(state);
    final hasCompletedBeyondGuide = parsed.completedTaskIds.any(
      (taskId) => !guideTaskIds.contains(taskId),
    );
    // Only a save that has NEVER seen the content lesson is a pre-split legacy
    // save. A modern save (e.g. after Placement) already lists its tasks as
    // skipped; a later genuine completion elsewhere must not earn them.
    return hasCompletedBeyondGuide &&
            !_contentLessonKnownToSaveV1(parsed, state)
        ? const <String>{'what_poker_is_content'}
        : const <String>{};
  }

  /// Skip-only progress beyond the guide (a Placement clearance): the content
  /// lesson is closed for routing as a skip, never as an earned completion.
  Set<String> _legacyCompatSkipClearedLessonIdsV1({
    required _Act0PersistedProgressV1 parsed,
    required Act0ShellStateV1 state,
  }) {
    if (!_legacyCompatAppliesV1(parsed)) {
      return const <String>{};
    }
    final guideTaskIds = _guideTaskIdsV1(state);
    final hasCompletedBeyondGuide = parsed.completedTaskIds.any(
      (taskId) => !guideTaskIds.contains(taskId),
    );
    final hasSkippedBeyondGuide = parsed.skippedTaskIds.any(
      (taskId) => !guideTaskIds.contains(taskId),
    );
    return !hasCompletedBeyondGuide && hasSkippedBeyondGuide
        ? const <String>{'what_poker_is_content'}
        : const <String>{};
  }

  bool _contentLessonKnownToSaveV1(
    _Act0PersistedProgressV1 parsed,
    Act0ShellStateV1 state,
  ) {
    final contentTaskIds = state
        .lessonById('what_poker_is_content')
        .taskList
        .map((task) => task.taskId);
    return contentTaskIds.any(
      (taskId) =>
          parsed.skippedTaskIds.contains(taskId) ||
          parsed.completedTaskIds.contains(taskId),
    );
  }

  bool _legacyCompatAppliesV1(_Act0PersistedProgressV1 parsed) {
    // The content lesson was first written with schema 8. Its later position
    // in Foundation does not make an earlier completion a pre-split save.
    if (parsed.schemaVersion >= 8 || parsed.selectedWorldId != 'world_1') {
      return false;
    }
    return parsed.selectedLessonId != 'what_poker_is' &&
        parsed.selectedLessonId != 'what_poker_is_content';
  }

  Set<String> _guideTaskIdsV1(Act0ShellStateV1 state) => <String>{
    for (final task in state.worldById('world_1').lessons.first.taskList)
      task.taskId,
  };

  Act0PlacementResultV1 _buildPlacementResult() {
    final diagnosticTotal = _placementDiagnosticSpotsV1.length;
    final foundationTotal = _placementDiagnosticSpotsV1
        .where((spot) => spot.isFoundation)
        .length;
    final foundationCorrect = _placementDiagnosticSpotsV1
        .where((spot) => spot.isFoundation)
        .where((spot) => _placementDiagnosticHitSignals.contains(spot.signalId))
        .length;
    final foundationMisses = _placementDiagnosticSpotsV1
        .where((spot) => spot.isFoundation)
        .where(
          (spot) => _placementDiagnosticMissSignals.contains(spot.signalId),
        )
        .length;
    final advancedCorrect = _placementDiagnosticSpotsV1
        .where((spot) => !spot.isFoundation)
        .where((spot) => _placementDiagnosticHitSignals.contains(spot.signalId))
        .length;
    final foundationPerfect = foundationCorrect == foundationTotal;
    final diagnosticMostlyClean =
        foundationMisses <= 1 && _placementDiagnosticCorrect >= 2;

    if (foundationPerfect &&
        advancedCorrect >= 1 &&
        _placementDiagnosticCorrect >= diagnosticTotal) {
      return Act0PlacementResultV1(
        level: Act0PlacementResultLevelV1.readyForBasics,
        levelLabel: 'Ready for action basics',
        summary:
            'You already track the table well enough to start on real decisions.',
        reportHeadline: _placementReportHeadline(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        reportBody: _placementReportBody(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        coachTitle: _placementCoachTitle(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        coachLine: _placementCoachLine(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        profileSummary: _placementProfileSummary(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        diagnosticCorrect: _placementDiagnosticCorrect,
        diagnosticTotal: _placementDiagnosticSpotsV1.length,
        profileSignals: _placementProfileSignals(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        analysisHighlights: _placementAnalysisHighlights(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        firstSessionPlan: _placementFirstSessionPlan(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        skillStats: _placementSkillStats(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        strengths: _placementStrengthsFor(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        weakSpots: _placementWeakSpotsFor(
          Act0PlacementResultLevelV1.readyForBasics,
        ),
        recommendedLessonId: 'fold_check_call_raise',
        recommendedTaskId: 'actions_legal_context',
        recommendedTitle: 'Fold, check, call, raise',
        recommendedReason:
            'The live check stayed clean, so we can begin with action words instead of resetting the table.',
        routeTrustLine: "We'll keep the next step beginner-safe.",
        premiumPitch:
            'Premium is optional later: more table-clue practice after the free foundation.',
        trialValuePoints: <String>[
          'Extra action reps after the first hand',
          'More table-clue practice when you are ready',
          'Deeper review of the same reads',
        ],
      );
    }
    if (diagnosticMostlyClean) {
      return Act0PlacementResultV1(
        level: Act0PlacementResultLevelV1.rustyBeginner,
        levelLabel: 'Rusty beginner',
        summary:
            'You have a base. The hand flow is there, but it still needs settling before faster decisions.',
        reportHeadline: _placementReportHeadline(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        reportBody: _placementReportBody(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        coachTitle: _placementCoachTitle(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        coachLine: _placementCoachLine(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        profileSummary: _placementProfileSummary(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        diagnosticCorrect: _placementDiagnosticCorrect,
        diagnosticTotal: _placementDiagnosticSpotsV1.length,
        profileSignals: _placementProfileSignals(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        analysisHighlights: _placementAnalysisHighlights(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        firstSessionPlan: _placementFirstSessionPlan(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        skillStats: _placementSkillStats(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        strengths: _placementStrengthsFor(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        weakSpots: _placementWeakSpotsFor(
          Act0PlacementResultLevelV1.rustyBeginner,
        ),
        recommendedLessonId: 'your_first_hand',
        recommendedTaskId: 'your_first_hand_preflop',
        recommendedTitle: 'Your first hand, dealt',
        recommendedReason:
            'The live check says we should steady the hand before we speed you up.',
        routeTrustLine: "We'll keep the hand flow visible before adding speed.",
        premiumPitch:
            'Premium is optional later: more practice with the table clues you have already seen.',
        trialValuePoints: <String>[
          'Extra street-order practice after the free route',
          'More table-clue reps when you are ready',
          'Deeper review of the same missed reads',
        ],
      );
    }
    return Act0PlacementResultV1(
      level: Act0PlacementResultLevelV1.newPlayer,
      levelLabel: 'New player',
      summary:
          'Start from zero. We will build the table, pot, blinds, cards, and goal one step at a time.',
      reportHeadline: _placementReportHeadline(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      reportBody: _placementReportBody(Act0PlacementResultLevelV1.newPlayer),
      coachTitle: _placementCoachTitle(Act0PlacementResultLevelV1.newPlayer),
      coachLine: _placementCoachLine(Act0PlacementResultLevelV1.newPlayer),
      profileSummary: _placementProfileSummary(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      diagnosticCorrect: _placementDiagnosticCorrect,
      diagnosticTotal: _placementDiagnosticSpotsV1.length,
      profileSignals: _placementProfileSignals(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      analysisHighlights: _placementAnalysisHighlights(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      firstSessionPlan: _placementFirstSessionPlan(
        Act0PlacementResultLevelV1.newPlayer,
      ),
      skillStats: _placementSkillStats(Act0PlacementResultLevelV1.newPlayer),
      strengths: _placementStrengthsFor(Act0PlacementResultLevelV1.newPlayer),
      weakSpots: _placementWeakSpotsFor(Act0PlacementResultLevelV1.newPlayer),
      recommendedLessonId: 'what_poker_is',
      recommendedTaskId: 'what_poker_is_theory',
      recommendedTitle: 'First Table Guide',
      recommendedReason:
          'The live check says the route should teach the Sharky loop first, then move into the poker foundations.',
      routeTrustLine:
          "We'll start with the table first, so the first hand stays clear.",
      premiumPitch:
          'Premium is optional later: more table-clue practice after this foundation.',
      trialValuePoints: <String>[
        'Step-by-step practice after the first hand',
        'Extra table-clue reps when you are ready',
        'Deeper review of the same foundation reads',
      ],
    );
  }

  void _togglePlacementOption(
    Act0PlacementQuestionV1 question,
    String optionId,
  ) {
    final selectedIds = Set<String>.from(
      _placementAnswerIds[question.questionId] ?? const <String>{},
    );
    if (!question.allowsMultiple) {
      _placementAnswerIds[question.questionId] = <String>{optionId};
      return;
    }
    if (selectedIds.contains(optionId)) {
      selectedIds.remove(optionId);
    } else {
      selectedIds.add(optionId);
    }
    if (selectedIds.isEmpty) {
      _placementAnswerIds.remove(question.questionId);
      return;
    }
    _placementAnswerIds[question.questionId] = selectedIds;
  }

  Act0PlacementQuestionV1? _placementQuestionById(String questionId) {
    for (final question in _placementQuestionBankV1) {
      if (question.questionId == questionId) {
        return question;
      }
    }
    return null;
  }

  List<Act0PlacementOptionV1> _selectedPlacementOptions(String questionId) {
    final question = _placementQuestionById(questionId);
    final selectedIds = _placementAnswerIds[questionId];
    if (question == null || selectedIds == null || selectedIds.isEmpty) {
      return const <Act0PlacementOptionV1>[];
    }
    return <Act0PlacementOptionV1>[
      for (final option in question.options)
        if (selectedIds.contains(option.optionId)) option,
    ];
  }

  bool _placementHasSelection(String questionId, String optionId) {
    final selectedIds = _placementAnswerIds[questionId];
    if (selectedIds == null || selectedIds.isEmpty) {
      return false;
    }
    return selectedIds.contains(optionId);
  }

  String _placementPrimaryLabel(String questionId, String fallback) {
    final options = _selectedPlacementOptions(questionId);
    if (options.isEmpty) {
      return fallback;
    }
    return options.first.label;
  }

  bool _placementHasAnySelection(String questionId) {
    final selectedIds = _placementAnswerIds[questionId];
    return selectedIds != null && selectedIds.isNotEmpty;
  }

  String _placementJoinedLabels(String questionId, String fallback) {
    final labels = <String>[
      for (final option in _selectedPlacementOptions(questionId))
        option.label.toLowerCase(),
    ];
    if (labels.isEmpty) {
      return fallback;
    }
    if (labels.length == 1) {
      return labels.first;
    }
    if (labels.length == 2) {
      return '${labels.first} + ${labels.last}';
    }
    return '${labels.sublist(0, labels.length - 1).join(', ')}, and ${labels.last}';
  }

  String _placementCoachingRead() {
    if (_placementHasSelection('goal', 'guided') &&
        _placementHasSelection('goal', 'daily_plan')) {
      return 'a guided path with one clear daily step';
    }
    if (_placementHasSelection('goal', 'guided')) {
      return 'a guided start before heavier drills';
    }
    if (_placementHasSelection('goal', 'diagnose')) {
      return 'fast weak-spot finding with close repairs';
    }
    if (_placementHasSelection('goal', 'practice')) {
      return 'tight repetitions once the concept is visible';
    }
    return 'a calm, progressive beginner path';
  }

  String _placementConfusionRead() {
    return _placementJoinedLabels('confidence', 'rules, blinds, and turns');
  }

  String _placementFormatRead() {
    return _placementJoinedLabels('format', 'learn the game from scratch');
  }

  String _placementExperienceRead() {
    if (_placementHasSelection('experience', 'new')) {
      return 'fresh start with little table repetition';
    }
    if (_placementHasSelection('experience', 'friends')) {
      return 'light real-world exposure that still needs structure';
    }
    if (_placementHasSelection('experience', 'online')) {
      return 'real table exposure and enough comfort to move faster';
    }
    return 'an early-stage poker profile';
  }

  String _placementReportHeadline(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 'Foundation before decisions',
      Act0PlacementResultLevelV1.rustyBeginner => 'Lock hand flow before speed',
      Act0PlacementResultLevelV1.readyForBasics =>
        'Move into actions, keep structure close',
    };
  }

  String _placementReportBody(Act0PlacementResultLevelV1 level) {
    final confusion = _placementConfusionRead();
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'The first gap is table clarity, not strategy. Sharky should make $confusion feel obvious before real decisions start.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'You can skip a full reset, but the hand still gets blurry around $confusion. Sharky should steady that first, then speed up.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'You have enough comfort to start on actions. The goal now is to make $confusion feel automatic while structure stays visible.',
    };
  }

  String _placementCoachTitle(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 'Sharky',
      Act0PlacementResultLevelV1.rustyBeginner => 'Sharky',
      Act0PlacementResultLevelV1.readyForBasics => 'Sharky',
    };
  }

  String _placementCoachLine(Act0PlacementResultLevelV1 level) {
    final confusion = _placementConfusionRead();
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'No hard strategy yet. First I want $confusion to feel calm and obvious.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'You have enough exposure. Now I want to stop the hand from blurring before decisions speed up.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'You are ready for action language. I will keep structure visible while your reads settle.',
    };
  }

  String _placementProfileSummary(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer =>
        'Base stats seeded from placement. More traits unlock as you play real spots.',
      Act0PlacementResultLevelV1.rustyBeginner =>
        'This is an early read, not a final judgment. The profile will tighten as your runs grow.',
      Act0PlacementResultLevelV1.readyForBasics =>
        'Core stats are seeded now. More specific reads like 3-bet and blind defense will calibrate later.',
    };
  }

  List<String> _placementProfileSignals(Act0PlacementResultLevelV1 level) {
    final signals = <String>[
      switch (level) {
        Act0PlacementResultLevelV1.newPlayer => 'Foundation start',
        Act0PlacementResultLevelV1.rustyBeginner => 'Bridge to action',
        Act0PlacementResultLevelV1.readyForBasics => 'Action-ready entry',
      },
      _placementPrimaryLabel('experience', 'New'),
      if (_placementHasSelection('format', 'home_games'))
        'Home-game confidence',
      if (_placementHasSelection('format', 'cash')) 'Cash-game examples',
      if (_placementHasSelection('format', 'tournaments'))
        'Tournament examples',
      if (_placementHasSelection('goal', 'daily_plan')) 'Daily plan friendly',
      if (_placementHasSelection('goal', 'diagnose')) 'Weak-spot bias',
      if (_placementHasSelection('goal', 'guided')) 'Guided coaching',
    ];
    return signals;
  }

  List<String> _placementStrengthsFor(Act0PlacementResultLevelV1 level) {
    final strengths = <String>[];
    for (final signalId in _placementDiagnosticHitSignals) {
      final label = _placementSignalLabel(signalId);
      if (!strengths.contains(label)) {
        strengths.add(label);
      }
    }
    if (strengths.isNotEmpty) {
      return strengths.take(3).toList(growable: false);
    }
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => <String>[
        'Fresh start',
        'Clear path',
      ],
      Act0PlacementResultLevelV1.rustyBeginner => <String>[
        'Motivation',
        'Some table language',
      ],
      Act0PlacementResultLevelV1.readyForBasics => <String>[
        'Experience',
        'Decision comfort',
      ],
    };
  }

  List<String> _placementWeakSpotsFor(Act0PlacementResultLevelV1 level) {
    final weakSpots = <String>[];
    for (final signalId in _placementDiagnosticMissSignals) {
      final label = _placementSignalLabel(signalId);
      if (!weakSpots.contains(label)) {
        weakSpots.add(label);
      }
    }
    if (weakSpots.isNotEmpty) {
      return weakSpots.take(3).toList(growable: false);
    }
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => <String>[
        'Table',
        'Pot',
        'Blinds',
      ],
      Act0PlacementResultLevelV1.rustyBeginner => <String>['Blinds', 'Streets'],
      Act0PlacementResultLevelV1.readyForBasics => <String>[
        'Actions',
        'Positions',
      ],
    };
  }

  String _placementSignalLabel(String signalId) {
    switch (signalId) {
      case 'table_read':
        return 'Table read';
      case 'board_read':
        return 'Board read';
      case 'action_order':
        return 'Action order';
      case 'action_menu':
        return 'Legal action';
      case 'position_pressure':
        return 'Position value';
      default:
        return 'Placement read';
    }
  }

  List<String> _placementAnalysisHighlights(Act0PlacementResultLevelV1 level) {
    final liveCheckRead = _placementDiagnosticMissSignals.isEmpty
        ? 'Live check stayed clean across table, board, and action flow.'
        : 'Live check flagged ${_placementWeakSpotsFor(level).join(', ').toLowerCase()} as the first friction points.';
    return <String>[
      'Experience read: ${_placementExperienceRead()}.',
      'Main friction area: ${_placementConfusionRead()}.',
      if (_placementHasAnySelection('format'))
        'Preferred use case: ${_placementFormatRead()}.',
      if (_placementHasAnySelection('goal'))
        'Best coaching fit: ${_placementCoachingRead()}.',
      liveCheckRead,
      if (level == Act0PlacementResultLevelV1.readyForBasics)
        'Diagnostic confirms enough table comfort to begin with action vocabulary.',
      if (level == Act0PlacementResultLevelV1.rustyBeginner)
        'Diagnostic says the foundation exists, but the hand still needs a cleaner mental map.',
      if (level == Act0PlacementResultLevelV1.newPlayer)
        'Diagnostic says the app should teach the table itself before faster decision reps.',
    ];
  }

  List<Act0PlacementSkillStatV1> _placementSkillStats(
    Act0PlacementResultLevelV1 level,
  ) {
    var tableFlow = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 24,
      Act0PlacementResultLevelV1.rustyBeginner => 46,
      Act0PlacementResultLevelV1.readyForBasics => 62,
    };
    var handReading = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 18,
      Act0PlacementResultLevelV1.rustyBeginner => 40,
      Act0PlacementResultLevelV1.readyForBasics => 56,
    };
    var actionDecisions = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 10,
      Act0PlacementResultLevelV1.rustyBeginner => 30,
      Act0PlacementResultLevelV1.readyForBasics => 68,
    };
    var pressureControl = switch (level) {
      Act0PlacementResultLevelV1.newPlayer => 8,
      Act0PlacementResultLevelV1.rustyBeginner => 24,
      Act0PlacementResultLevelV1.readyForBasics => 38,
    };

    if (_placementHasSelection('confidence', 'rules')) {
      tableFlow -= 10;
    }
    if (_placementHasSelection('confidence', 'cards')) {
      handReading -= 8;
    }
    if (_placementHasSelection('confidence', 'board')) {
      handReading -= 6;
    }
    if (_placementHasSelection('confidence', 'decisions')) {
      actionDecisions -= 10;
    }
    if (_placementHasSelection('confidence', 'pressure')) {
      pressureControl -= 10;
    }
    if (_placementHasSelection('experience', 'online')) {
      actionDecisions += 6;
      tableFlow += 4;
    }
    if (_placementHasSelection('experience', 'friends') ||
        _placementHasSelection('experience', 'watching')) {
      handReading += 4;
    }
    if (_placementDiagnosticHitSignals.contains('position_pressure')) {
      actionDecisions += 4;
      tableFlow += 4;
    }
    if (_placementDiagnosticMissSignals.contains('position_pressure')) {
      actionDecisions -= 4;
      tableFlow -= 4;
    }

    int clampStat(int value) => value.clamp(8, 82);

    final tableSense = tableFlow + 2;
    final boardReading = handReading - 6;
    final handReadingScore = handReading;
    final bettingDecisions = actionDecisions + (pressureControl ~/ 2);
    final positionPlay = tableFlow - 12;
    final blindPlay = ((tableFlow + pressureControl) ~/ 2) - 10;

    return <Act0PlacementSkillStatV1>[
      Act0PlacementSkillStatV1.core(
        label: 'Table sense',
        value: clampStat(tableSense),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Board reading',
        value: clampStat(boardReading),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Hand reading',
        value: clampStat(handReadingScore),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Betting decisions',
        value: clampStat(bettingDecisions),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Position play',
        value: clampStat(positionPlay),
      ),
      Act0PlacementSkillStatV1.core(
        label: 'Blind play',
        value: clampStat(blindPlay),
      ),
    ];
  }

  List<String> _placementFirstSessionPlan(Act0PlacementResultLevelV1 level) {
    return switch (level) {
      Act0PlacementResultLevelV1.newPlayer => <String>[
        'Session 1: meet the table, seats, chips, and the goal of a hand.',
        'Session 2: walk through one full beginner hand without pressure.',
        'Session 3: confirm blinds, turns, and simple table cues in a short check.',
      ],
      Act0PlacementResultLevelV1.rustyBeginner => <String>[
        'Session 1: rebuild preflop-to-river flow so the hand stops feeling fuzzy.',
        'Session 2: reinforce streets and what changes after the flop.',
        'Session 3: hand off into action basics once the flow stays stable.',
      ],
      Act0PlacementResultLevelV1.readyForBasics => <String>[
        'Session 1: anchor legal actions and when each option is available.',
        'Session 2: connect action words to seat order and pressure.',
        'Session 3: turn misses into repair reps instead of replaying the whole intro.',
      ],
    };
  }
}
