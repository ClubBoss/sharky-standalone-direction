part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewFlowV1 on _Act0ShellPreviewScreenV1State {
  void _openPracticeHubV1() {
    _tab = Act0ShellTabV1.play;
    _showPlayHub = true;
    _returnToPlayHubOnBack = false;
    _learnDetailLessonId = null;
    _learnDetailWorldId = null;
    _showWorldMenu = false;
    _blockCompletionSummary = null;
  }

  void _recordCompletedStudyV1(Act0LessonTaskV1 task) {
    if (_diagnosticLearningEntryV1 != null) return;
    final revision = act0AuthoredStudyRevisionV1(
      worldId: _selectedWorldId,
      lessonId: _selectedLessonId,
      task: task,
    );
    if (revision == null) return;
    _ensureActiveSessionIdentityV1(
      worldId: _selectedWorldId,
      lessonId: _selectedLessonId,
    );
    final observation = Act0StudyObservationV1(
      worldId: _selectedWorldId,
      lessonId: _selectedLessonId,
      taskId: task.taskId,
      sourceRevision: revision,
      sessionId: _sessionIdentityStateV1.currentActiveSessionId,
      recordedAtUtc: widget.clock.nowUtc().toUtc(),
    );
    if (_studyObservationsV1.any(
      (r) => r.observationId == observation.observationId,
    ))
      return;
    _studyObservationsV1 = List.unmodifiable([
      ..._studyObservationsV1,
      observation,
    ]);
  }

  void _completeCurrentTask(
    Act0LessonTaskV1 selectedTask, {
    bool awardXp = true,
  }) {
    if (_diagnosticLearningEntryV1 != null ||
        act0DailyDealRecipeV1(selectedTask.taskId) != null)
      return;
    final taskId = _selectedTaskId;
    final alreadyCompleted = !_completedTaskIds.add(taskId);
    _skippedTaskIds.remove(taskId);
    _visibleSkippedTaskIds.remove(taskId);
    if (!alreadyCompleted) {
      _retentionSequence += 1;
      if (!awardXp && selectedTask.rewardXp > 0) {
        _tasksWithDeferredXpV1.add(taskId);
      }
    }
    if (awardXp &&
        (!alreadyCompleted || _tasksWithDeferredXpV1.remove(taskId))) {
      _earnedXp += selectedTask.rewardXp;
      _lessonRunXp += selectedTask.rewardXp;
    }
    _refreshRetentionMemoryStatusesV1();
    final worlds = _progressWorlds(widget.state ?? Act0ShellStateV1.sample);
    final world = _worldById(worlds, _selectedWorldId);
    final lesson = _lessonById(world.lessons, _selectedLessonId);
    if (_markLessonCompletedV1(lesson)) {
      _lastShortSessionDayV1 = _todayDateString();
    }
    if (_lessonResumeV1?.taskId == _selectedTaskId) _lessonResumeV1 = null;
    _persistProgress();
    if (!alreadyCompleted &&
        selectedTask.phase == Act0LessonPhaseV1.drill &&
        Act0PracticeReminderV1.enabled.value) {
      _syncPracticeReminderV1();
    }
  }

  Act0ActionRecommendationV1? _actionRecommendationForActiveSequenceV1() {
    if (_diagnosticLearningEntryV1 != null) return null;
    final practiceId = act0ActionLearningSequenceV1.practiceTaskId;
    final mappedActionRepair =
        _selectedTaskId == 'actions_legal_context' &&
        _activeRepairTaskId == 'actions_legal_context' &&
        _activeRepairSourceTaskId == practiceId &&
        _activeActionSequenceStageV1 == Act0ActionSequenceStageV1.repair;
    if ((_selectedTaskId != practiceId && !mappedActionRepair) ||
        (_activeRepairTaskId == practiceId) ||
        _selectedOptionId == null) {
      return null;
    }
    return Act0ActionSequencePersonalizationPolicyV1.evaluate(
      _actionPersonalizationStateV1,
    );
  }

  Act0ActionSessionPayoffV1? _actionPayoffForActiveSequenceV1() {
    final recommendation = _actionRecommendationForActiveSequenceV1();
    if (recommendation == null) {
      return null;
    }
    return Act0ActionSessionPayoffPolicyV1.evaluate(
      learnerState: _actionPersonalizationStateV1,
      recommendation: recommendation,
    );
  }

  void _deriveActionPersonalizationV1(Act0CompletedDecisionV1 decision) {
    if (_diagnosticLearningEntryV1 != null) return;
    final stage = _activeActionSequenceStageV1;
    if (stage == null) return;
    final previous = _actionPersonalizationStateV1;
    if (previous.outcomes.any(
      (outcome) => outcome.attemptKey == decision.attemptKey,
    ))
      return;
    if (decision.taskId == act0ActionLearningSequenceV1.practiceTaskId) {
      // A Check target borrowed by a different source is not this sequence's
      // initial decision. Assisted/unknown recheck is teaching, not recovery.
      if (_activeRepairTaskId != null ||
          stage == Act0ActionSequenceStageV1.repair ||
          (stage == Act0ActionSequenceStageV1.recheck &&
              _activeSameSignalRecheckTaskId != decision.taskId)) {
        return;
      }
      _actionPersonalizationStateV1 =
          Act0ActionSequencePersonalizationPolicyV1.deriveState(
            current: previous,
            decision: decision,
            stage: stage,
          );
    } else if (stage == Act0ActionSequenceStageV1.repair &&
        _activeRepairSourceTaskId ==
            act0ActionLearningSequenceV1.practiceTaskId &&
        _activeRepairTaskId == decision.taskId) {
      final outcomes = _repairOutcomeProjectionV1.outcomes
          .where((outcome) => outcome.repairAttemptId == decision.attemptKey)
          .toList(growable: false);
      if (outcomes.length > 1) return;
      final outcome = outcomes.isEmpty ? null : outcomes.single;
      final intent = _activeRepairObligationV1 ?? outcome?.repairIntent;
      if (intent == null) return;
      _actionPersonalizationStateV1 =
          Act0ActionSequencePersonalizationPolicyV1.deriveMappedRepairState(
            current: previous,
            decision: decision,
            intent: intent,
            outcome: outcome,
            learningEvidence: _learningEvidenceHistoryV1,
            currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
          );
    } else {
      return;
    }
    if (identical(previous, _actionPersonalizationStateV1)) return;
    final recommendation = Act0ActionSequencePersonalizationPolicyV1.evaluate(
      _actionPersonalizationStateV1,
    );
    final fields = <String, Object?>{
      'schemaVersion': 1,
      'sequence_id': _actionPersonalizationStateV1.sequenceId,
      'source_attempt_key': decision.attemptKey,
      'source_user_choice': decision.selectedId,
      'correct': decision.isCorrect,
      'error_type': decision.isCorrect
          ? 'none'
          : act0ActionLearningSequenceV1.repairErrorType,
      'time_to_decision_bucket': decision.decisionTimeBucket,
      'sequence_stage': stage.name,
      'recommendation_id': recommendation.id,
      'recommendation_reason': recommendation.reason.name,
      'recommendation_target': recommendation.target.name,
      'source_evidence_summary': recommendation.sourceEvidenceSummary,
    };
    _recordTelemetryEventV1('recommendation_generated', fields);
    _recordTelemetryEventV1('recommendation_shown', fields);
    final payoff = Act0ActionSessionPayoffPolicyV1.evaluate(
      learnerState: _actionPersonalizationStateV1,
      recommendation: recommendation,
    );
    final payoffFields = <String, Object?>{
      ...fields,
      'payoff_type': payoff.type.name,
      'proof_source': payoff.errorType == 'none'
          ? 'initial_correct_decision'
          : 'sequence_outcomes',
      'primary_action': recommendation.target.name,
    };
    _recordTelemetryEventV1('action_payoff_generated', payoffFields);
    _recordTelemetryEventV1('action_payoff_shown', payoffFields);
  }

  void _recordActionRecommendationAcceptedV1() {
    final recommendation = _actionRecommendationForActiveSequenceV1();
    final latest = _actionPersonalizationStateV1.latestOutcome;
    if (recommendation == null || latest == null) {
      return;
    }
    _recordTelemetryEventV1('recommendation_accepted', <String, Object?>{
      'schemaVersion': 1,
      'sequence_id': _actionPersonalizationStateV1.sequenceId,
      'source_attempt_key': latest.attemptKey,
      'recommendation_id': recommendation.id,
      'recommendation_reason': recommendation.reason.name,
      'recommendation_target': recommendation.target.name,
    });
    final payoff = _actionPayoffForActiveSequenceV1();
    if (payoff != null) {
      _recordTelemetryEventV1(
        'action_payoff_primary_action_selected',
        <String, Object?>{
          'schemaVersion': 1,
          'sequence_id': payoff.sequenceId,
          'source_attempt_key': latest.attemptKey,
          'payoff_type': payoff.type.name,
          'primary_action': recommendation.target.name,
          'next_target': recommendation.target.name,
          'recommendation_reason': recommendation.reason.name,
        },
      );
    }
  }

  Act0RunnerStateV1 _actionSequenceRunnerForStageV1(
    Act0RunnerStateV1 runner, {
    required String taskId,
  }) => runner;

  bool _advanceTeachingStep(Act0RunnerStateV1 runner) {
    // F07: the old `< length` guard let the index advance to `length` and
    // still return true (stay in theory for one more render), so the
    // "current/total" counter briefly read one past the real authored total
    // (e.g. `3/2`). Advance only while the NEXT index is still a real
    // authored step; once it would land on `length`, set the sentinel and
    // report "done" on this same tap instead of rendering the invalid step.
    // `_teachingStepIndex == length` stays the sentinel every other call site
    // already relies on (e.g. the drill-phase theory-recall affordance), so
    // this only removes the wasted extra tap, not the sentinel value itself.
    if (_teachingStepIndex + 1 < runner.teachingSteps.length) {
      _teachingStepIndex += 1;
      return true;
    }
    _teachingStepIndex = runner.teachingSteps.length;
    return false;
  }

  bool _maybeShowBlockCompletionSummary({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
  }) {
    if (widget.tableVisualVariant !=
        Act0ShellTableVisualVariantV1.refinedDev2) {
      return false;
    }
    if (_nextTask(selectedLesson, _selectedTaskId) != null) {
      return false;
    }
    final progressedWorlds = _progressWorlds(
      widget.state ?? Act0ShellStateV1.sample,
    );
    final progressedWorld = _worldById(progressedWorlds, selectedWorld.worldId);
    final nextLessonId = _nextLessonId(
      selectedWorld.lessons,
      selectedLesson.lessonId,
    );
    final nextWorld = _nextSelectableWorld(
      progressedWorlds,
      selectedWorld.worldId,
    );
    final isWorldComplete =
        selectedWorld.worldId != act0LiveRoomModuleIdV1 &&
        nextLessonId == null &&
        progressedWorld.status == Act0WorldStateV1.completed;
    final worldRetentionSeed = isWorldComplete
        ? _seedWorldCompletionRetentionTargetsV1(progressedWorld)
        : const _Act0WorldRetentionSeedResultV1();
    final lessonPerfectClearCount = _perfectTaskIds()
        .where(
          (taskId) => selectedLesson.courseTaskList.any(
            (task) => task.taskId == taskId,
          ),
        )
        .length;
    final lessonOpenMistakeCount = _openMistakeCountForLessonV1(selectedLesson);
    // Scored drills emit completed evidence; theory and review/navigation
    // stages cannot inflate the lesson assessment denominator.
    final assessedTaskIds = selectedLesson.courseTaskList
        .where((task) => task.phase == Act0LessonPhaseV1.drill)
        .map((task) => task.taskId)
        .toSet();
    final assistedTaskIds = _lessonRunAssistedTaskIds
        .where(assessedTaskIds.contains)
        .toSet();
    final boundary = _lessonRunEvidenceLessonIdV1 == selectedLesson.lessonId
        ? _lessonRunEvidenceStartOrderV1
        : null;
    final recentHistory = _learningEvidenceHistoryV1.records;
    final history = _learningEvidenceHistoryV1.provenanceRecords;
    final firstByTask = <String, Act0LearningEvidenceRecordV1>{};
    final wrongAssessedTaskIds = <String>{};
    final repairedTaskIds = <String>{};
    var evidenceComplete = boundary != null && assessedTaskIds.isNotEmpty;
    if (boundary != null) {
      if (recentHistory.isNotEmpty &&
          recentHistory.first.createdOrder > boundary + 1) {
        evidenceComplete = false; // bounded history was truncated
      }
      for (final record in history) {
        if (record.createdOrder <= boundary ||
            record.isPlacementAssessment ||
            record.isDiagnosticLearningEntry ||
            record.lessonId != selectedLesson.lessonId ||
            !assessedTaskIds.contains(record.taskId)) {
          continue;
        }
        firstByTask.putIfAbsent(record.taskId, () => record);
        if (!record.isCorrect) wrongAssessedTaskIds.add(record.taskId);
        if (record.isRepaired) repairedTaskIds.add(record.taskId);
        switch (record.assistanceKind) {
          case Act0DecisionAssistanceV1.quickHint:
          case Act0DecisionAssistanceV1.theoryRecall:
            assistedTaskIds.add(record.taskId);
          case Act0DecisionAssistanceV1.legacyUnknown:
            evidenceComplete = false;
          case Act0DecisionAssistanceV1.none:
            break;
        }
      }
    }
    if (firstByTask.length != assessedTaskIds.length) {
      evidenceComplete = false;
    }
    // First scored result per task defines assessment accuracy. Later repair
    // may teach the concept, but never overwrites the original mistake.
    final assessedCorrectCount = firstByTask.values
        .where((record) => record.isCorrect)
        .length;
    final assessedErrorCount = wrongAssessedTaskIds.length;
    final lessonAssistedCount = assistedTaskIds.length;
    final worldOpenMistakeCount = _openMistakeCountForWorldV1(progressedWorld);
    _blockCompletionSummary = Act0BlockCompletionSummaryV1(
      curriculumCompleted: _lessonComplete(selectedLesson),
      lessonTitle: _localizedLessonTitleV1(selectedLesson),
      xpEarned: _lessonRunXp,
      errorCount: assessedErrorCount,
      assistedCount: lessonAssistedCount,
      independentCount: firstByTask.values
          .where((record) => record.isIndependentCorrect)
          .length,
      assistedCorrectCount: firstByTask.values
          .where((record) => record.isAssistedCorrect)
          .length,
      repairedCount: repairedTaskIds.length,
      independentProvenanceKnown: evidenceComplete,
      taskCount: assessedTaskIds.length,
      correctCount: assessedCorrectCount,
      startLevel: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp - _lessonRunXp,
      ).level,
      endLevel: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp,
      ).level,
      startXp: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp - _lessonRunXp,
      ).xp,
      endXp: _progressSnapshot(
        widget.state ?? Act0ShellStateV1.sample,
        earnedXpDelta: _earnedXp,
      ).xp,
      xpTarget: (widget.state ?? Act0ShellStateV1.sample).xpTarget,
      sharkyLine: selectedTask.runner.sharky.summaryLine,
      nextLessonTitle: nextLessonId == null
          ? null
          : act0LocalizedLessonTitleAtomByIdV1(
              nextLessonId,
              fallback: _lessonById(
                progressedWorld.lessons,
                nextLessonId,
              ).title,
              isRu: _isRuLocaleV1,
            ),
      quickFixCount: _lessonRunQuickFixTaskIds.length,
      deepLeakCount: _lessonRunDeepLeakTaskIds.length,
      skillGains: isWorldComplete
          ? _skillGainsFromMapV1(
              _aggregateSkillDeltasForWorldV1(progressedWorld),
              source: act0LocalizedWorldTitleV1(context, progressedWorld),
            )
          : _skillGainsFromMapV1(
              _lessonRunSkillGainCounts,
              source: _localizedLessonTitleV1(selectedLesson),
            ),
      milestoneTier: isWorldComplete
          ? Act0ProgressMilestoneTierV1.world
          : Act0ProgressMilestoneTierV1.lesson,
      worldNumber: progressedWorld.worldNumber,
      worldTitle: act0LocalizedWorldTitleV1(context, progressedWorld),
      nextWorldNumber: nextWorld?.worldNumber,
      nextWorldTitle: nextWorld == null
          ? null
          : act0LocalizedWorldTitleV1(context, nextWorld),
      perfectClearCount: isWorldComplete
          ? _perfectTaskCountForWorldV1(progressedWorld)
          : lessonPerfectClearCount,
      completedClearCount: isWorldComplete
          ? _completedTaskCountForWorldV1(progressedWorld)
          : selectedLesson.courseTaskList.length,
      hasSafeReviewTarget: isWorldComplete
          ? worldOpenMistakeCount > 0
          : lessonOpenMistakeCount > 0,
      hasReplayForPerfectTarget:
          !isWorldComplete &&
          lessonOpenMistakeCount == 0 &&
          lessonPerfectClearCount < selectedLesson.courseTaskList.length,
      futureRecheckCount: worldRetentionSeed.recheckCount,
      futureProveCount: worldRetentionSeed.proveCount,
    );
    if (isWorldComplete && worldRetentionSeed.changed) {
      _persistProgress();
    }
    _fireBlockCompletionEffects(_blockCompletionSummary!);
    _queueStoreReviewV1(_blockCompletionSummary!);
    _emitSessionCompleteTelemetryV1(sourceSurface: 'act0_completion');
    if (isWorldComplete) {
      _recordTelemetryEventV1('world_complete', <String, Object?>{
        'schemaVersion': 1,
        'worldId': progressedWorld.worldId,
        'world_id': progressedWorld.worldId,
        'completedClearCount': _completedTaskCountForWorldV1(progressedWorld),
        'completed_clear_count': _completedTaskCountForWorldV1(progressedWorld),
        'perfectClearCount': _perfectTaskCountForWorldV1(progressedWorld),
        'perfect_clear_count': _perfectTaskCountForWorldV1(progressedWorld),
        'source_surface': 'act0_completion',
      });
    }
    return true;
  }

  void _fireAnswerEffects(Act0RunnerOptionV1 option) {
    UiSoundV1.fire(
      option.isCorrect ? UiSoundEventV1.success : UiSoundEventV1.error,
    );
    unawaited(UiHapticsV1.fire(UiHapticEventV1.answer));
  }

  void _fireBlockCompletionEffects(Act0BlockCompletionSummaryV1 summary) {
    if (!summary.qualifiesForNextLesson) {
      UiSoundV1.fire(UiSoundEventV1.error);
      unawaited(UiHapticsV1.fire(UiHapticEventV1.error));
      return;
    }
    UiSoundV1.fire(UiSoundEventV1.success);
    unawaited(UiHapticsV1.fire(UiHapticEventV1.success));
  }

  int _latestEvidenceOrderV1() => _learningEvidenceHistoryV1.records.fold<int>(
    0,
    (latest, record) =>
        record.createdOrder > latest ? record.createdOrder : latest,
  );

  void _resetLessonRunMetrics({bool forceFreshProvenance = false}) {
    if (forceFreshProvenance) {
      _pendingDecisionAssistanceV1.clear();
    }
    // Selection of a different lesson must not destroy an unfinished lesson's
    // durable run boundary. Replays of completed lessons start a new run.
    if (forceFreshProvenance) {
      _lessonRunEvidenceBoundariesV1.clear();
    } else if (_lessonRunEvidenceLessonIdV1.isNotEmpty) {
      _lessonRunEvidenceBoundariesV1[_lessonRunEvidenceLessonIdV1] =
          _lessonRunEvidenceStartOrderV1;
    }
    if (forceFreshProvenance ||
        _lessonRunEvidenceLessonIdV1 != _selectedLessonId ||
        _completedLessonIds.contains(_selectedLessonId)) {
      _lessonRunEvidenceLessonIdV1 = _selectedLessonId;
      if (forceFreshProvenance ||
          _completedLessonIds.contains(_selectedLessonId)) {
        _lessonRunEvidenceStartOrderV1 = _latestEvidenceOrderV1();
      } else if (_lessonRunEvidenceBoundariesV1.containsKey(
        _selectedLessonId,
      )) {
        _lessonRunEvidenceStartOrderV1 =
            _lessonRunEvidenceBoundariesV1[_selectedLessonId];
      } else {
        final taskIds = <String>[
          for (final world in (widget.state ?? Act0ShellStateV1.sample).worlds)
            for (final lesson in world.lessons)
              if (lesson.lessonId == _selectedLessonId)
                for (final task in lesson.taskList) task.taskId,
        ];
        final hasOlderProgress =
            taskIds.any(_completedTaskIds.contains) ||
            _learningEvidenceHistoryV1.records.any(
              (record) =>
                  !record.isPlacementAssessment &&
                  !record.isDiagnosticLearningEntry &&
                  record.lessonId == _selectedLessonId,
            );
        _lessonRunEvidenceStartOrderV1 = hasOlderProgress
            ? null
            : _latestEvidenceOrderV1();
      }
    }
    if (_selectedLessonId.isNotEmpty) {
      _lessonRunEvidenceBoundariesV1[_selectedLessonId] =
          _lessonRunEvidenceStartOrderV1;
    }
    _lessonRunXp = 0;
    _lessonRunMistakeTaskIds.clear();
    _lessonRunAssistedTaskIds.clear();
    _lessonRunPendingRetryTaskIds.clear();
    _lessonRunRetriedTaskIds.clear();
    _lessonRunWrapUpCompletedTaskIds.clear();
    _lessonRunQuickFixTaskIds.clear();
    _lessonRunDeepLeakTaskIds.clear();
    _lessonRunSkillGainCounts.clear();
    _activeLessonWrapUpTaskId = null;
    _lessonRunWrapUpAnchorTaskId = null;
    _blockCompletionSummary = null;
  }

  void _advanceAfterTask(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final nextTask = _nextTask(selectedLesson, _selectedTaskId);
    if (nextTask != null) {
      _selectedTaskId = nextTask.taskId;
      _selectedOptionId = null;
      final actionSequence = act0ActionLearningSequenceForTaskV1(
        nextTask.taskId,
      );
      _activeActionSequenceStageV1 = actionSequence == null
          ? null
          : actionSequence.stageForTask(nextTask.taskId);
      _phase = nextTask.entryPhase;
      _tab = Act0ShellTabV1.play;
      _showPlayHub = false;
      _teachingStepIndex = 0;
      _persistProgress();
      return;
    }

    final progressedWorlds = _progressWorlds(
      widget.state ?? Act0ShellStateV1.sample,
    );
    var nextWorld = _worldById(progressedWorlds, selectedWorld.worldId);
    var nextLesson = _firstPlayableLesson(nextWorld);
    if (nextWorld.status == Act0WorldStateV1.completed) {
      final currentWorldIndex = progressedWorlds.indexWhere(
        (world) => world.worldId == selectedWorld.worldId,
      );
      final nextWorldIndex = currentWorldIndex + 1;
      if (nextWorldIndex < progressedWorlds.length &&
          progressedWorlds[nextWorldIndex].isSelectable &&
          progressedWorlds[nextWorldIndex].worldId != act0LiveRoomModuleIdV1) {
        nextWorld = progressedWorlds[nextWorldIndex];
        nextLesson = _firstPlayableLesson(nextWorld);
        _selectedWorldId = nextWorld.worldId;
      }
    }
    _tab = Act0ShellTabV1.learn;
    _seedLearnRouteFocusV1(
      lessonId: nextLesson.lessonId,
      taskId: _firstIncompleteTask(nextLesson).taskId,
    );
    _learnDetailWorldId = null;
    _showWorldMenu = false;
    _persistProgress();
  }

  /// The admitted Action journey deliberately skips the adjacent broad legal
  /// context node after its theory opener. Its first decision is the explicit
  /// same-signal sequence target, not the generic task-list successor.
  bool _advanceActionTheoryToDecisionV1({
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
  }) {
    final sequence = act0ActionLearningSequenceForTaskV1(selectedTask.taskId);
    if (sequence == null || selectedTask.taskId != sequence.theoryTaskId) {
      return false;
    }
    final decisionTask = _taskById(selectedLesson, sequence.practiceTaskId);
    _selectedTaskId = decisionTask.taskId;
    _activeActionSequenceStageV1 = Act0ActionSequenceStageV1.decision;
    _phase = decisionTask.entryPhase;
    _selectedOptionId = null;
    _teachingStepIndex = 0;
    _persistProgress();
    return true;
  }

  void _normalizeSelection(List<Act0WorldCardV1> worlds) {
    final normalizedWorld = _worldById(worlds, _selectedWorldId);
    if (_selectedWorldId != normalizedWorld.worldId) {
      _selectedWorldId = normalizedWorld.worldId;
      if (_learnDetailWorldId != null &&
          _learnDetailWorldId != _selectedWorldId) {
        _learnDetailWorldId = null;
      }
    }

    final selectedLessonExists = normalizedWorld.lessons.any(
      (lesson) => lesson.lessonId == _selectedLessonId,
    );
    final candidateSelectedLesson = selectedLessonExists
        ? _lessonById(normalizedWorld.lessons, _selectedLessonId)
        : null;
    final enforcePlayableLessonSelection =
        _tab == Act0ShellTabV1.learn && !_placementDiagnosticActive;
    final normalizedLesson =
        candidateSelectedLesson != null &&
            (!enforcePlayableLessonSelection ||
                candidateSelectedLesson.isSelectable)
        ? candidateSelectedLesson
        : _firstPlayableLesson(normalizedWorld);
    final lessonChanged = _selectedLessonId != normalizedLesson.lessonId;
    if (lessonChanged) {
      _selectedLessonId = normalizedLesson.lessonId;
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
    }

    if (_learnDetailLessonId != null) {
      final detailLessonExists = normalizedWorld.lessons.any(
        (lesson) => lesson.lessonId == _learnDetailLessonId,
      );
      final detailLesson = detailLessonExists
          ? _lessonById(normalizedWorld.lessons, _learnDetailLessonId!)
          : null;
      if (detailLesson == null ||
          (enforcePlayableLessonSelection && !detailLesson.isSelectable)) {
        _learnDetailLessonId = null;
        _learnPopupTaskId = null;
      }
    }

    final taskExists = normalizedLesson.taskList.any(
      (task) =>
          task.taskId == _selectedTaskId &&
          !act0RunnerRequiresNineSeatPreviewV1(task.runner),
    );
    final normalizedTask =
        taskExists ||
            _activeSpacedReviewTaskV1?.taskId == _selectedTaskId ||
            (_activePracticeGroupId == 'daily' &&
                _dailyPracticeQueue.taskIds.contains(_selectedTaskId) &&
                _generatedDailyTaskV1(normalizedLesson, _selectedTaskId) !=
                    null)
        ? _taskById(normalizedLesson, _selectedTaskId)
        : _firstIncompleteTask(normalizedLesson);
    if (_selectedTaskId != normalizedTask.taskId) {
      _selectedTaskId = normalizedTask.taskId;
      _selectedOptionId = null;
      _teachingStepIndex = 0;
      _phase = normalizedTask.entryPhase;
    }

    final popupOwnerLesson =
        _learnDetailLessonId != null &&
            normalizedWorld.lessons.any(
              (lesson) => lesson.lessonId == _learnDetailLessonId,
            )
        ? _lessonById(normalizedWorld.lessons, _learnDetailLessonId!)
        : normalizedLesson;
    if (_learnPopupTaskId != null &&
        !popupOwnerLesson.courseTaskList.any(
          (task) => task.taskId == _learnPopupTaskId,
        )) {
      _learnPopupTaskId = null;
    }
  }

  Act0WorldCardV1 _worldById(List<Act0WorldCardV1> worlds, String worldId) {
    return worlds.firstWhere(
      (world) => world.worldId == worldId,
      orElse: () => worlds.first,
    );
  }

  Act0LessonCardV1 _lessonById(
    List<Act0LessonCardV1> lessons,
    String lessonId,
  ) {
    return lessons.firstWhere(
      (lesson) => lesson.lessonId == lessonId,
      orElse: () => lessons.first,
    );
  }

  Act0LessonCardV1 _firstPlayableLesson(Act0WorldCardV1 world) {
    return world.lessons.firstWhere(
      (lesson) =>
          lesson.isSelectable && lesson.state == Act0LessonStateV1.current,
      orElse: () => world.lessons.firstWhere(
        (lesson) => lesson.isSelectable,
        orElse: () => world.lessons.first,
      ),
    );
  }

  Act0LessonTaskV1 _firstIncompleteTask(Act0LessonCardV1 lesson) {
    return _firstIncompleteTaskWithTaskIds(lesson, _pathClosedTaskIds);
  }

  Act0LessonTaskV1 _firstIncompleteTaskWithTaskIds(
    Act0LessonCardV1 lesson,
    Set<String> completedTaskIds,
  ) {
    final eligible = lesson.courseTaskList.where(
      (task) => !act0RunnerRequiresNineSeatPreviewV1(task.runner),
    );
    return eligible.firstWhere(
      (task) => !completedTaskIds.contains(task.taskId),
      orElse: () => eligible.firstOrNull ?? lesson.courseTaskList.first,
    );
  }

  bool _taskAvailable(Act0LessonCardV1 lesson, String taskId) {
    if (!lesson.courseTaskList.any(
      (task) =>
          task.taskId == taskId &&
          !act0RunnerRequiresNineSeatPreviewV1(task.runner),
    )) {
      return false;
    }
    if (_completedTaskIds.contains(taskId)) {
      return true;
    }
    if (_skippedTaskIds.contains(taskId)) {
      return true;
    }
    return _firstIncompleteTask(lesson).taskId == taskId;
  }

  Act0LessonTaskV1 _taskById(Act0LessonCardV1 lesson, String taskId) {
    if (_generatedDailyTaskV1(lesson, taskId) case final generated?
        when _dailyPracticeQueue.taskIds.contains(taskId)) {
      return generated;
    }
    final reviewTask = _activeSpacedReviewTaskV1;
    if (reviewTask != null &&
        taskId == reviewTask.taskId &&
        lesson.lessonId == _selectedLessonId) {
      return reviewTask;
    }
    return _taskByIdWithTaskIds(lesson, taskId, _pathClosedTaskIds);
  }

  Act0LessonTaskV1 _taskByIdWithTaskIds(
    Act0LessonCardV1 lesson,
    String taskId,
    Set<String> completedTaskIds,
  ) {
    return lesson.taskList.firstWhere(
      (task) => task.taskId == taskId,
      orElse: () => _firstIncompleteTaskWithTaskIds(lesson, completedTaskIds),
    );
  }

  int _taskIndex(Act0LessonCardV1 lesson, String taskId) {
    final index = lesson.courseTaskList.indexWhere(
      (task) => task.taskId == taskId,
    );
    return index < 0 ? 0 : index;
  }

  Act0LessonTaskV1? _nextTask(Act0LessonCardV1 lesson, String taskId) {
    final tasks = lesson.courseTaskList
        .where((task) => !act0RunnerRequiresNineSeatPreviewV1(task.runner))
        .toList();
    final index = tasks.indexWhere((task) => task.taskId == taskId);
    if (index >= 0 && index + 1 < tasks.length) {
      return tasks[index + 1];
    }
    // End of the list. A route that jumped over a task (the Action sequence
    // skips its legal-context node) must still visit it before the lesson
    // ends; otherwise the lesson never completes and only "replay" is left.
    for (final task in tasks) {
      if (task.taskId != taskId &&
          !_completedTaskIds.contains(task.taskId) &&
          !_lessonRunMistakeTaskIds.contains(task.taskId)) {
        return task;
      }
    }
    return null;
  }

  bool _lessonComplete(Act0LessonCardV1 lesson) {
    return _lessonCompleteWithTaskIds(lesson, _completedTaskIds);
  }

  bool _lessonCompleteWithTaskIds(
    Act0LessonCardV1 lesson,
    Set<String> completedTaskIds,
  ) => act0LessonCompleteWithTaskIdsV1(lesson, completedTaskIds);

  bool _markLessonCompletedV1(Act0LessonCardV1 lesson) {
    if (!_lessonComplete(lesson) || !_completedLessonIds.add(lesson.lessonId)) {
      return false;
    }
    _ensureDailyCountDayV1();
    _dailyCompletedLessonIds.add(lesson.lessonId);
    _recordBetaActivityV1(
      () => Act0BetaMetricsStoreV1.recordLesson(
        widget.clock.nowUtc(),
        lesson.lessonId,
      ),
    );
    return true;
  }

  void _closeTaskWithoutRewardV1(String taskId) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    for (final world in _progressWorlds(state)) {
      for (final lesson in world.lessons) {
        if (!lesson.taskList.any((task) => task.taskId == taskId)) {
          continue;
        }
        _skippedTaskIds.remove(taskId);
        _visibleSkippedTaskIds.remove(taskId);
        _completedTaskIds.add(taskId);
        _markLessonCompletedV1(lesson);
        _persistProgress();
        return;
      }
    }
  }

  int _lessonIndex(List<Act0LessonCardV1> lessons, String lessonId) {
    final index = lessons.indexWhere((lesson) => lesson.lessonId == lessonId);
    return index < 0 ? 0 : index;
  }

  String? _nextLessonId(List<Act0LessonCardV1> lessons, String lessonId) {
    final index = _lessonIndex(lessons, lessonId);
    if (index < 0 || index + 1 >= lessons.length) {
      return null;
    }
    return lessons[index + 1].lessonId;
  }

  Act0WorldCardV1? _nextSelectableWorld(
    List<Act0WorldCardV1> worlds,
    String worldId,
  ) {
    final currentIndex = worlds.indexWhere((world) => world.worldId == worldId);
    if (currentIndex < 0) {
      return null;
    }
    for (var index = currentIndex + 1; index < worlds.length; index++) {
      final world = worlds[index];
      if (world.isSelectable && world.worldId != act0LiveRoomModuleIdV1) {
        return world;
      }
    }
    return null;
  }

  _Act0ProgressSnapshotV1 _progressSnapshot(
    Act0ShellStateV1 state, {
    int? earnedXpDelta,
  }) {
    final xpTarget = state.xpTarget <= 0 ? 1 : state.xpTarget;
    final baseLevel = _parseLevelNumber(state.levelLabel);
    final totalXp =
        ((_debugFreshLearnerV1 || _usesPersistedProgress) ? 0 : state.xp) +
        (earnedXpDelta ?? _earnedXp);
    return _Act0ProgressSnapshotV1(
      level: baseLevel + (totalXp ~/ xpTarget),
      xp: totalXp % xpTarget,
    );
  }

  int _parseLevelNumber(String label) {
    final match = RegExp(r'(\d+)').firstMatch(label);
    return int.tryParse(match?.group(1) ?? '') ?? 1;
  }

  Act0ShellStateV1 _stateWithProgress(
    Act0ShellStateV1 base,
    _Act0ProgressSnapshotV1 progress,
  ) {
    final levelLabel = 'Level ${progress.level}';
    return Act0ShellStateV1(
      courseTitle: base.courseTitle,
      courseSubtitle: base.courseSubtitle,
      levelLabel: levelLabel,
      xp: progress.xp,
      xpTarget: base.xpTarget,
      streakDays: _effectiveStreakDays(base),
      dailyGoalLabel: base.dailyGoalLabel,
      dailyGoalValue: base.dailyGoalValue,
      pathProgressLabel: base.pathProgressLabel,
      selectedWorldId: base.selectedWorldId,
      worlds: base.worlds,
      lessons: base.lessons,
      review: base.review,
      profile: Act0ProfileStateV1(
        playerName: base.profile.playerName,
        level: levelLabel,
        xpLine: '${progress.xp} / ${base.xpTarget} XP',
        lessonsLine: base.profile.lessonsLine,
        accuracyLine: base.profile.accuracyLine,
        qualityLine: base.profile.qualityLine,
        streakLine: base.profile.streakLine,
        streakDays: base.profile.streakDays,
        consistencyActiveDays: base.profile.consistencyActiveDays,
        achievements: base.profile.achievements,
        strongCategories: base.profile.strongCategories,
        weakCategories: base.profile.weakCategories,
        recentProgress: base.profile.recentProgress,
        recentSkillGains: base.profile.recentSkillGains,
        skillStats: base.profile.skillStats,
        streakLast7: base.profile.streakLast7,
        recommendedFocusTitle: base.profile.recommendedFocusTitle,
        recommendedFocusBody: base.profile.recommendedFocusBody,
        recommendedFocusCtaLabel: base.profile.recommendedFocusCtaLabel,
        worldsClearedCount: base.profile.worldsClearedCount,
        worldsActiveCount: base.profile.worldsActiveCount,
        totalWorldsCount: base.profile.totalWorldsCount,
        mistakesFixedLine: base.profile.mistakesFixedLine,
      ),
    );
  }

  int _practiceDaysLastWeekV1(Act0ProfileStateV1 profile) {
    if (!_usesPersistedProgress) {
      return profile.streakLast7.where((practiced) => practiced).length;
    }
    return _learningEvidenceHistoryV1
        .practiceDayKeysLastWeek(
          widget.clock.nowUtc(),
          savedDays: _savedPracticeDaysV1,
        )
        .length;
  }

  int _effectiveStreakDays(Act0ShellStateV1 base) {
    if (_debugFreshLearnerV1) {
      return 0;
    }
    // Only earned completion dates are eligible for streak continuation.
    // Explicit non-persisted preview/test states retain sample semantics.
    if (_usesPersistedProgress) {
      return _earnedStreakDaysTodayV1(_todayDateString());
    }
    return _dailyCompletedRepCount >= 3
        ? (base.streakDays + 1).clamp(0, 365)
        : base.streakDays;
  }
}
