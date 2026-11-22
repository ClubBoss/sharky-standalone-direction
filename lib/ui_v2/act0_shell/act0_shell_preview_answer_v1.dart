part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewAnswerV1 on _Act0ShellPreviewScreenV1State {
  bool _startTaskByIds(
    Act0WorldCardV1 selectedWorld,
    String lessonId,
    String taskId, {
    bool skipTeaching = false,
    bool allowDrillBypass = false,
    bool rapidPracticeLoop = false,
    String evidenceRunKind = 'lesson',
    String evidenceStartedBy = 'learn_route',
    Act0DiagnosticLearningEntryV1? diagnosticLearningEntry,
    Act0RepairIntentV1? repairLaunchIntent,
    bool persist = true,
  }) {
    final lesson = _lessonById(selectedWorld.lessons, lessonId);
    final task = _taskById(lesson, taskId);
    final drillBypass =
        allowDrillBypass && task.phase == Act0LessonPhaseV1.drill;
    final repairBypass =
        repairLaunchIntent != null &&
        repairLaunchIntent.targetWorldId == selectedWorld.worldId &&
        repairLaunchIntent.targetLessonId == lessonId &&
        repairLaunchIntent.targetTaskId == taskId &&
        task.phase != Act0LessonPhaseV1.theory &&
        task.runner.options.isNotEmpty &&
        _hasValidatedRepairTargetV1(repairLaunchIntent);
    final spacedReview = _spacedReviewReturnV1 != null;
    if (task.repairOnly && !repairBypass && !spacedReview) return false;
    final lessonAvailable =
        lesson.isSelectable || drillBypass || repairBypass || spacedReview;
    final taskAvailable =
        _taskAvailable(lesson, taskId) ||
        drillBypass ||
        repairBypass ||
        spacedReview;
    if (!lessonAvailable || !taskAvailable) {
      return false;
    }
    _diagnosticLearningReturnV1 = diagnosticLearningEntry == null
        ? null
        : (
            worldId: _selectedWorldId,
            lessonId: _selectedLessonId,
            taskId: _selectedTaskId,
          );
    _diagnosticLearningEntryV1 = diagnosticLearningEntry;
    _selectedWorldId = selectedWorld.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = task.taskId;
    final actionSequence = act0ActionLearningSequenceForTaskV1(task.taskId);
    _activeActionSequenceStageV1 =
        actionSequence == null ||
            diagnosticLearningEntry != null ||
            spacedReview
        ? null
        : actionSequence.stageForTask(task.taskId);
    _emitLessonStartedTelemetryV1(
      lessonId: lesson.lessonId,
      taskId: task.taskId,
    );
    _startLearningEvidenceRunV1(
      worldId: selectedWorld.worldId,
      lessonId: lesson.lessonId,
      runKind: evidenceRunKind,
      startedBy: evidenceStartedBy,
    );
    _tab = Act0ShellTabV1.play;
    _showPlayHub = false;
    _returnToPlayHubOnBack = true;
    _activePracticeGroupId = null;
    _clearActiveRepairLaunchV1();
    _rapidPracticeLoop = rapidPracticeLoop;
    _phase = task.entryPhase;
    _selectedOptionId = null;
    _teachingStepIndex =
        skipTeaching && (task.phase == Act0LessonPhaseV1.drill || spacedReview)
        ? task.runner.teachingSteps.length
        : 0;
    _blockCompletionSummary = null;
    if (persist) _persistProgress();
    return true;
  }

  Act0WorldCardV1? _dueReviewTargetWorldV1(Act0DueReviewItemV1 item) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    for (final world in state.worlds) {
      if (world.worldId != item.worldId) continue;
      for (final lesson in world.lessons) {
        if (lesson.lessonId != item.lessonId) continue;
        if (act0ReviewOnlyTaskV1(item.worldId, item.lessonId, item.taskId) !=
                null ||
            lesson.taskList.any(
              (task) =>
                  task.taskId == item.taskId &&
                  task.phase != Act0LessonPhaseV1.theory &&
                  task.runner.options.isNotEmpty,
            )) {
          return world;
        }
      }
    }
    return null;
  }

  List<Act0DueReviewItemV1> _dueReviewItemsV1() => [
    for (final item in _durableRetentionHistoryV1.dueItemsAt(
      widget.clock.nowUtc(),
    ))
      if (_dueReviewTargetWorldV1(item) != null)
        item.withUnseenTask(_unseenReviewTaskIdV1(item)),
  ];

  String? _unseenReviewTaskIdV1(Act0DueReviewItemV1 item) {
    final family = _durableRetentionHistoryV1.familyById(item.conceptFamilyId);
    // Day 2 checks retention on familiar material. After a spaced success,
    // offer a new hand only if its review-only source has never been opened.
    if (family == null || family.spacedSuccessStage == 0) return null;
    final reviewFamily = act0Day7FamilyForSourceV1(
      worldId: item.worldId,
      lessonId: item.lessonId,
      taskId: item.taskId,
      family: item.conceptFamilyId,
    );
    for (final entry in act0NewReviewTasksV1) {
      final id = entry.task.taskId;
      if (entry.conceptFamilyId == reviewFamily &&
          entry.worldId == item.worldId &&
          entry.lessonId == item.lessonId &&
          item.taskId != id &&
          !_openedSpacedReviewTaskIdsV1.contains(id) &&
          !_routePracticeV1.seen.contains(id) &&
          !_learningEvidenceHistoryV1.provenanceRecords.any(
            (record) => record.taskId == id,
          )) {
        return id;
      }
    }
    return null;
  }

  bool _isCurrentDueReviewV1(Act0DueReviewItemV1 item) =>
      _durableRetentionHistoryV1
          .dueItemsAt(widget.clock.nowUtc())
          .any(
            (due) =>
                due.conceptFamilyId == item.conceptFamilyId &&
                due.worldId == item.worldId &&
                due.lessonId == item.lessonId &&
                due.taskId == item.taskId &&
                due.nextDueAtUtc == item.nextDueAtUtc,
          );

  void _startDueReviewItemV1(Act0DueReviewItemV1 item) {
    if (_spacedReviewReturnV1 != null ||
        _newSpacedReviewSavePendingV1 ||
        !_isCurrentDueReviewV1(item) ||
        _unseenReviewTaskIdV1(item) != item.unseenTaskId) {
      return;
    }
    final world = _dueReviewTargetWorldV1(item);
    if (world == null) return;
    if (item.unseenTaskId == null) {
      _openSpacedReviewTaskV1(item, world);
    } else {
      unawaited(_openUnseenReviewTaskV1(item, world));
    }
  }

  Future<void> _openUnseenReviewTaskV1(
    Act0DueReviewItemV1 item,
    Act0WorldCardV1 world,
  ) async {
    final taskId = item.unseenTaskId!;
    final task = act0ReviewOnlyTaskV1(item.worldId, item.lessonId, taskId);
    if (task == null) return;
    final epoch = _recoveryEpochV1;
    final returnTab = _tab;
    _newSpacedReviewSavePendingV1 = true;
    _openedSpacedReviewTaskIdsV1.add(taskId);
    final saved = Completer<bool>();
    // Persist exposure before showing the scene, even if the learner leaves
    // without an answer or the app restarts. A failed save never claims novelty.
    _persistProgress(acknowledgement: saved);
    final persisted = await saved.future;
    if (!_acceptRecoveryCallbackV1(epoch)) return;
    _newSpacedReviewSavePendingV1 = false;
    if (!persisted || _tab != returnTab || !_isCurrentDueReviewV1(item)) return;
    _setStateV1(() => _openSpacedReviewTaskV1(item, world, unseen: task));
  }

  void _openSpacedReviewTaskV1(
    Act0DueReviewItemV1 item,
    Act0WorldCardV1 world, {
    Act0LessonTaskV1? unseen,
  }) {
    _spacedReviewReturnTabV1 = _tab == Act0ShellTabV1.home
        ? Act0ShellTabV1.home
        : Act0ShellTabV1.review;
    _spacedReviewReturnV1 = (
      worldId: _selectedWorldId,
      lessonId: _selectedLessonId,
      taskId: _selectedTaskId,
    );
    _activeDueReviewItemV1 = item;
    _activeSpacedReviewTaskV1 =
        unseen ??
        act0ReviewOnlyTaskV1(item.worldId, item.lessonId, item.taskId);
    _pendingReviewKindV1 = unseen == null
        ? Act0ReviewKindV1.spacedReview
        : Act0ReviewKindV1.unseenTransfer;
    _selectedLessonId = item.lessonId;
    _startTaskByIds(
      world,
      item.lessonId,
      unseen?.taskId ?? item.taskId,
      skipTeaching: true,
      evidenceRunKind: 'spaced_review',
      evidenceStartedBy: 'review_due',
    );
  }

  void _returnFromSpacedReviewV1(String? runId) {
    final selection = _spacedReviewReturnV1;
    if (selection == null || _activeLearningEvidenceRunKeyV1?.runId != runId) {
      return;
    }
    _spacedReviewReturnV1 = null;
    _activeSpacedReviewTaskV1 = null;
    _activeDueReviewItemV1 = null;
    _pendingReviewKindV1 = null;
    _activeLearningEvidenceRunKeyV1 = null;
    _activeActionSequenceStageV1 = null;
    _selectedWorldId = selection.worldId;
    _selectedLessonId = selection.lessonId;
    _selectedTaskId = selection.taskId;
    _selectedOptionId = null;
    _phase = Act0LessonPhaseV1.theory;
    _teachingStepIndex = 0;
    _showPlayHub = true;
    _returnToPlayHubOnBack = false;
    _tab = _spacedReviewReturnTabV1;
    _persistProgress();
  }

  void _startLearningEvidenceRunV1({
    required String worldId,
    required String lessonId,
    required String runKind,
    required String startedBy,
  }) {
    final normalizedWorldId = worldId.trim();
    final normalizedLessonId = lessonId.trim();
    final normalizedRunKind = runKind.trim().isEmpty
        ? 'lesson'
        : runKind.trim();
    final normalizedStartedBy = startedBy.trim().isEmpty
        ? 'learn_route'
        : startedBy.trim();
    if (normalizedWorldId.isEmpty || normalizedLessonId.isEmpty) {
      _activeLearningEvidenceRunKeyV1 = null;
      return;
    }
    final latestPersistedOrdinal = _latestLearningEvidenceRunOrdinalV1();
    if (latestPersistedOrdinal > _learningEvidenceRunOrdinalV1) {
      _learningEvidenceRunOrdinalV1 = latestPersistedOrdinal;
    }
    _learningEvidenceRunOrdinalV1 += 1;
    _activeLearningEvidenceRunKeyV1 = Act0EvidenceRunKeyV1(
      runId:
          'run_v1|$normalizedWorldId|$normalizedLessonId|'
          '$normalizedRunKind|$_learningEvidenceRunOrdinalV1',
      worldId: normalizedWorldId,
      lessonId: normalizedLessonId,
      runOrdinal: _learningEvidenceRunOrdinalV1,
      runKind: normalizedRunKind,
      startedBy: normalizedStartedBy,
    );
  }

  Act0SessionIdentityStartResultV1 _ensureActiveSessionIdentityV1({
    required String worldId,
    String lessonId = '',
  }) {
    final result = _sessionIdentityStateV1.startOrResume(
      startedAtOrder: _sessionLifecycleOrderV1(),
      startedWorldId: worldId,
      startedLessonId: lessonId,
    );
    _sessionIdentityStateV1 = result.state;
    return result;
  }

  Act0SessionIdentityCompleteResultV1 _completeActiveSessionIdentityV1({
    required String completionReason,
  }) {
    final result = _sessionIdentityStateV1.complete(
      completedAtOrder: _sessionLifecycleOrderV1(),
      completionReason: completionReason,
    );
    _sessionIdentityStateV1 = result.state;
    return result;
  }

  int _sessionLifecycleOrderV1() {
    final evidenceCount = _latestEvidenceOrderV1();
    final repairCount = _repairOutcomeSequenceV1;
    return evidenceCount + repairCount + 1;
  }

  int _latestLearningEvidenceRunOrdinalV1() {
    var latest = 0;
    for (final record in _learningEvidenceHistoryV1.records) {
      final ordinal = record.runOrdinal;
      if (ordinal != null && ordinal > latest) {
        latest = ordinal;
      }
    }
    return latest;
  }

  Map<String, String> _sessionSummaryRepairFocusLabelsByIdV1() {
    return const <String, String>{
      'board_cards': 'board cards',
      'hero_cards': 'hero cards',
      'hero_cards_board_pot': 'cards and pot',
      'no_bet_yet': 'no-bet-yet clue',
      'pot_to_call': 'price clue',
    };
  }

  void _recordAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
    Act0RunnerOptionV1 option,
  ) {
    if (_diagnosticLearningEntryV1 != null ||
        _activeSpacedReviewTaskV1 != null ||
        _lessonExampleSourceTaskIdV1 != null) {
      return;
    }
    if (_choiceWasAssistedV1) {
      // Record help in this lesson separately from correctness/mistake counts;
      // it cannot earn the learner an independent clean-pass claim.
      _lessonRunAssistedTaskIds.add(selectedTask.taskId);
    }
    final practiceQueueRepairRequest = _practiceQueueRepairRequestForTaskV1(
      selectedTask.taskId,
    );
    final recordingPracticeQueueRepair =
        practiceQueueRepairRequest != null &&
        practiceQueueRepairRequest.repairTaskId == selectedTask.taskId;
    if (recordingPracticeQueueRepair) {
      // The canonical completed decision owns the durable occurrence/attempt
      // join. onChooseOption runs before that decision is emitted.
      return;
    }
    if (_activeSameSignalRecheckTaskId == selectedTask.taskId &&
        _choiceHasIndependentProvenanceV1) {
      final finalized = _recordLearningRunSourceRecheckV1(
        sourceTaskId:
            _activeSameSignalRecheckSourceTaskId ?? selectedTask.taskId,
        recheckCorrect: option.isCorrect,
      );
      if (finalized != null) {
        _emitPersonalizationFamilySourceRecheckTelemetryV1(
          finalized: finalized,
        );
      }
    }
    final repairSourceTaskId = _activeRepairTaskId == selectedTask.taskId
        ? (_activeRepairSourceTaskId ?? selectedTask.taskId)
        : selectedTask.taskId;
    final repairSourceRecord = _mistakeRecords[repairSourceTaskId];
    final repairSourceLessonId =
        repairSourceRecord?.lessonId ?? selectedLesson.lessonId;
    final repairSourceWorldId = repairSourceRecord?.worldId ?? _selectedWorldId;
    if (option.isCorrect && !_choiceHasIndependentProvenanceV1) {
      // Real learning attempt, not independent repair, transfer or retention.
      // Preserve any existing repair intent; subsequent ordinary task
      // completion may still unlock the next teaching step.
      _persistProgress();
      return;
    }
    final category = _categoryForLesson(repairSourceLessonId);
    final contextLabels = _repairContextLabels(selectedTask.runner, option);
    final retentionEntry = _retentionMemoryByTaskId[repairSourceTaskId];
    final completingAgedRecheck =
        retentionEntry?.status == _Act0RetentionMemoryStatusV1.agedRecheck;
    final completingOwnedCandidate =
        retentionEntry?.status == _Act0RetentionMemoryStatusV1.ownedCandidate;
    final nextSuccessfulRecheckCount = option.isCorrect
        ? (retentionEntry?.successfulRecheckCount ?? 0) + 1
        : (retentionEntry?.successfulRecheckCount ?? 0);
    if (completingAgedRecheck) {
      _emitRecheckCompletedTelemetryV1(
        taskId: repairSourceTaskId,
        completedCorrectly: option.isCorrect,
        successfulRecheckCount: nextSuccessfulRecheckCount,
      );
    }
    if (completingOwnedCandidate) {
      _emitProveCompletedTelemetryV1(
        taskId: repairSourceTaskId,
        completedCorrectly: option.isCorrect,
      );
    }
    if (option.isCorrect) {
      _incrementSkillStatsForCorrectAnswer(selectedLesson, selectedTask);
      _cleanTaskIds.add(selectedTask.taskId);
      _lessonRunPendingRetryTaskIds.remove(selectedTask.taskId);
      final sourceIntent =
          _activeRepairObligationV1 ??
          _openRepairIntentBySourceTaskId[repairSourceTaskId];
      final repairClosed =
          sourceIntent != null && _hasValidatedRepairClosureV1(sourceIntent);
      if (repairClosed) {
        _cleanTaskIds.add(repairSourceTaskId);
        _lessonRunPendingRetryTaskIds.remove(repairSourceTaskId);
      }
      if (retentionEntry?.status == _Act0RetentionMemoryStatusV1.agedRecheck ||
          retentionEntry?.status ==
              _Act0RetentionMemoryStatusV1.ownedCandidate) {
        _retentionMemoryByTaskId[repairSourceTaskId] = retentionEntry!.copyWith(
          status: _Act0RetentionMemoryStatusV1.ownedCandidate,
          lastRecheckSequence: _retentionSequence,
          successfulRecheckCount: retentionEntry.successfulRecheckCount + 1,
        );
      } else if (_mistakeRecords.containsKey(repairSourceTaskId) &&
          (sourceIntent == null || repairClosed)) {
        _resolvedMistakeTaskIds.add(repairSourceTaskId);
        _retentionMemoryByTaskId[repairSourceTaskId] = _updatedRetentionEntryV1(
          taskId: repairSourceTaskId,
          lessonId: repairSourceLessonId,
          worldId: repairSourceWorldId,
          status: _Act0RetentionMemoryStatusV1.fixedRecent,
        );
        if (_activeRepairTaskId != selectedTask.taskId &&
            _lessonRunRetriedTaskIds.contains(repairSourceTaskId)) {
          _lessonRunQuickFixTaskIds.add(repairSourceTaskId);
          _lessonRunDeepLeakTaskIds.remove(repairSourceTaskId);
        }
      }
      final completedIntent =
          _openRepairIntentBySourceTaskId[repairSourceTaskId];
      if (completedIntent != null &&
          _hasValidatedRepairClosureV1(completedIntent) &&
          (completedIntent.targetTaskId == selectedTask.taskId ||
              completedIntent.sourceTaskId == selectedTask.taskId)) {
        _recordLastSessionLearnerStateV1(
          repairFocusId: completedIntent.missedSignalId,
          proofResult: act0LastSessionProofFixLandedV1,
          worldId: repairSourceWorldId,
        );
      }
      _clearMatchedOpenRepairIntentV1(
        sourceTaskId: repairSourceTaskId,
        completedTaskId: selectedTask.taskId,
      );
      if (Act0PositionPersonalizationV1.isCanonicalSourceTask(
            selectedTask.taskId,
          ) &&
          _activeSameSignalRecheckTaskId != selectedTask.taskId) {
        const positionCase = Act0PositionPersonalizationCaseV1();
        _recordTelemetryEventV1(
          'position_personalization_payoff',
          positionCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: positionCase.cleanPayoffOutcome,
          ),
        );
      }
      if (Act0PricePersonalizationV1.isCanonicalSourceTask(
            selectedTask.taskId,
          ) &&
          _activeSameSignalRecheckTaskId != selectedTask.taskId) {
        const priceCase = Act0PricePersonalizationCaseV1();
        _recordTelemetryEventV1(
          'price_personalization_payoff',
          priceCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: priceCase.cleanPayoffOutcome,
          ),
        );
      }
      if (Act0StartingHandPersonalizationV1.isCanonicalSourceTask(
            selectedTask.taskId,
          ) &&
          _routeReviewKindForTaskIdV1(selectedTask.taskId) ==
              Act0ReviewKindV1.initialAssessment) {
        const startingHandCase = Act0StartingHandPersonalizationCaseV1();
        _recordTelemetryEventV1(
          'starting_hand_personalization_payoff',
          startingHandCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: startingHandCase.cleanPayoffOutcome,
          ),
        );
      }
      if (Act0BoardTexturePersonalizationV1.isCanonicalSourceTask(
            selectedTask.taskId,
          ) &&
          _routeReviewKindForTaskIdV1(selectedTask.taskId) ==
              Act0ReviewKindV1.initialAssessment) {
        const boardTextureCase = Act0BoardTexturePersonalizationCaseV1();
        _recordTelemetryEventV1(
          'board_texture_personalization_payoff',
          boardTextureCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: boardTextureCase.cleanPayoffOutcome,
          ),
        );
      }
      _refreshRetentionMemoryStatusesV1();
      _persistProgress();
      return;
    }
    _lessonRunMistakeTaskIds.add(repairSourceTaskId);
    if (_activeRepairTaskId != selectedTask.taskId &&
        !_lessonRunRetriedTaskIds.contains(repairSourceTaskId)) {
      _lessonRunPendingRetryTaskIds.add(repairSourceTaskId);
    } else if (_activeRepairTaskId != selectedTask.taskId &&
        _lessonRunRetriedTaskIds.contains(repairSourceTaskId)) {
      _lessonRunDeepLeakTaskIds.add(repairSourceTaskId);
      _lessonRunQuickFixTaskIds.remove(repairSourceTaskId);
    }
    _resolvedMistakeTaskIds.remove(repairSourceTaskId);
    final previous = _mistakeRecords[repairSourceTaskId];
    _mistakeRecords[repairSourceTaskId] = _Act0MistakeRecordV1(
      taskId: repairSourceTaskId,
      lessonId: repairSourceLessonId,
      worldId: repairSourceWorldId,
      title: previous?.title ?? _localizedTaskTitleV1(selectedTask),
      weaknessLabel: category,
      selectedOptionId: option.id,
      selectedLabel: option.label,
      betterLabel: option.betterAnswerLabel,
      reason: _hardenMistakeReason(
        rawReason: option.feedbackReason,
        betterLabel: option.betterAnswerLabel,
        contextLabels: contextLabels,
      ),
      contextLabels: contextLabels,
      repairActionLabel:
          _activeRepairTaskId == selectedTask.taskId &&
              _activeRepairSourceTaskId != null &&
              _activeRepairSourceTaskId != selectedTask.taskId
          ? _copyV1(en: 'Try a similar spot', ru: 'Попробуй похожий спот')
          : _repairActionLabel(selectedTask),
      attempts: (previous?.attempts ?? 0) + 1,
    );
    _storeOpenRepairIntentForMissV1(
      sourceWorldId: repairSourceWorldId,
      sourceLessonId: repairSourceLessonId,
      sourceTaskId: repairSourceTaskId,
      runner: selectedTask.runner,
      option: option,
    );
    final openIntent = _openRepairIntentBySourceTaskId[repairSourceTaskId];
    final positionCase = openIntent == null
        ? null
        : _positionCaseForIntentV1(openIntent);
    if (positionCase != null && _activeRepairTaskId == selectedTask.taskId) {
      _recordTelemetryEventV1(
        'position_personalization_recheck',
        positionCase.telemetryFields(
          attemptPhase: 'recheck',
          finalLearningOutcome: positionCase.failedRecheckOutcome,
        ),
      );
    }
    final priceCase = openIntent == null
        ? null
        : _priceCaseForIntentV1(openIntent);
    if (priceCase != null && _activeRepairTaskId == selectedTask.taskId) {
      _recordTelemetryEventV1(
        'price_personalization_recheck',
        priceCase.telemetryFields(
          attemptPhase: 'recheck',
          finalLearningOutcome: priceCase.failedRecheckOutcome,
        ),
      );
    }
    _recordLastSessionLearnerStateV1(
      repairFocusId: openIntent?.missedSignalId ?? '',
      proofResult: act0LastSessionProofNotYetV1,
      worldId: repairSourceWorldId,
    );
    if (_activeRepairTaskId == selectedTask.taskId &&
        _activeRepairSourceTaskId != null) {
      final retainedTarget = _openRepairIntentTargetForSourceTaskV1(
        repairSourceTaskId,
      );
      if (retainedTarget != null) {
        final receipt = _Act0NextUsefulHandReasonReceiptV1.forRepairIntent(
          sourceTaskId: repairSourceTaskId,
          target: retainedTarget,
          practiceGroupId: _activePracticeGroupId,
        );
        _recordRepairIntentAuditTransitionV1(
          'failed_repair_retained',
          receipt: receipt,
        );
      }
    }
    _retentionMemoryByTaskId[repairSourceTaskId] = _updatedRetentionEntryV1(
      taskId: repairSourceTaskId,
      lessonId: repairSourceLessonId,
      worldId: repairSourceWorldId,
      status: _Act0RetentionMemoryStatusV1.openRepair,
    );
    _refreshRetentionMemoryStatusesV1();
    _persistProgress();
  }

  void _recordLastSessionLearnerStateV1({
    required String repairFocusId,
    required String proofResult,
    required String worldId,
  }) {
    _lastSessionLearnerStateV1 = Act0LastSessionLearnerStateV1(
      lastSessionRepairFocusId: repairFocusId.trim(),
      lastSessionProofResult: proofResult.trim(),
      lastSessionDate: _todayDateString(),
      lastSessionWorldId: worldId.trim().isEmpty ? _selectedWorldId : worldId,
    );
  }

  void _recordCanonicalRepairDecisionV1(
    Act0CompletedDecisionV1 decision, {
    required Act0LessonTaskV1 selectedTask,
  }) {
    if (_learningEvidenceHistoryV1.records.any(
      (record) => record.recordId == decision.attemptKey,
    ))
      return;

    Act0PracticeRepairQueueLaunchRequestV1? request;
    final queueRequest = _practiceQueueRepairRequestForTaskV1(decision.taskId);
    if (queueRequest != null) {
      request = queueRequest;
    } else {
      final launched = _activeRepairTaskId == decision.taskId
          ? _activeRepairObligationV1
          : null;
      final exactRetry = _openRepairIntentBySourceTaskId[decision.taskId];
      final intent =
          launched ??
          (decision.isCorrect &&
                  exactRetry != null &&
                  act0IsExactRepairMappingTypeV1(exactRetry.mappingType)
              ? exactRetry
              : null);
      if (intent != null &&
          _hasValidatedRepairTargetV1(intent) &&
          intent.targetTaskId == decision.taskId) {
        request = Act0PracticeRepairQueueLaunchRequestV1(
          targetWorldId: intent.targetWorldId,
          targetLessonId: intent.targetLessonId,
          targetTaskId: intent.targetTaskId,
          targetType: act0PracticeRepairQueueTargetTypeActiveRepairV1,
          sourceType: act0PracticeRepairQueueSourceActiveRepairV1,
          sourceTaskId: intent.sourceTaskId,
          repairTaskId: intent.targetTaskId,
          repairFocusKey: intent.missedSignalId,
          queueItemId: queueItemIdForAct0RepairIntentV1(intent),
          repairOccurrenceId: intent.repairOccurrenceId,
        );
      }
    }
    if (!decision.isCorrect && request == null) {
      // onChooseOption already created the family. Bind its actual canonical
      // miss now; unrelated queue/outcome counters cannot identify this event.
      _multiRepairQueueV1 = Act0MultiRepairQueueV1(
        entries: List.unmodifiable([
          for (final entry in _multiRepairQueueV1.entries)
            if (entry.repairIntent.sourceTaskId == decision.sourceTaskId &&
                entry.repairIntent.choiceId == decision.selectedId)
              entry.copyWith(
                repairIntent: Act0RepairIntentV1.tryParse({
                  ...entry.repairIntent.toPayload(),
                  'repairOccurrenceId': decision.attemptKey,
                })!,
              )
            else
              entry,
        ]),
      );
      _syncOpenRepairIntentIndexFromQueueV1();
    }
    _appendLearningEvidenceV1(
      decision,
      repairOccurrenceId: request?.repairOccurrenceId ?? '',
    );
    if (request == null ||
        decision.assistanceKind != Act0DecisionAssistanceV1.none)
      return;
    final option = selectedTask.runner.options
        .cast<Act0RunnerOptionV1?>()
        .firstWhere((o) => o?.id == decision.selectedId, orElse: () => null);
    if (option == null || selectedTask.taskId != decision.taskId) return;
    _appendPracticeQueueRepairOutcomeV1(
      request: request,
      selectedTask: selectedTask,
      option: option,
      repairAttemptId: decision.attemptKey,
    );
  }

  void _appendPracticeQueueRepairOutcomeV1({
    required Act0PracticeRepairQueueLaunchRequestV1 request,
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerOptionV1 option,
    required String repairAttemptId,
  }) {
    if (_repairOutcomeProjectionV1.outcomes.any(
      (outcome) => outcome.repairAttemptId == repairAttemptId,
    ))
      return;
    final intentsBeforeOutcome = _activeRepairIntentsV1();
    final obligation = _activeRepairObligationV1;
    final matchingIntents = intentsBeforeOutcome.where(
      (intent) =>
          intent.sourceTaskId == request.sourceTaskId &&
          intent.repairOccurrenceId == request.repairOccurrenceId &&
          queueItemIdForAct0RepairIntentV1(intent) == request.queueItemId,
    );
    final intent =
        obligation != null &&
            obligation.sourceTaskId == request.sourceTaskId &&
            obligation.repairOccurrenceId == request.repairOccurrenceId &&
            queueItemIdForAct0RepairIntentV1(obligation) == request.queueItemId
        ? obligation
        : matchingIntents.isEmpty
        ? null
        : matchingIntents.first;
    if (_sessionIdentityStateV1.currentActiveSessionId.isEmpty) {
      final startResult = _ensureActiveSessionIdentityV1(
        worldId: request.targetWorldId,
        lessonId: request.targetLessonId,
      );
      if (startResult.startedNewSession) {
        _recordTelemetryEventV1('session_start', <String, Object?>{
          'schemaVersion': 1,
          'worldId': request.targetWorldId,
          'world_id': request.targetWorldId,
          'lessonId': request.targetLessonId,
          'lesson_id': request.targetLessonId,
          'taskId': request.targetTaskId,
          'task_id': request.targetTaskId,
          'source_surface': 'act0_review',
        });
      }
    }
    _repairOutcomeSequenceV1 += 1;
    _repairOutcomeProjectionV1 = _repairOutcomeProjectionV1.appendAnsweredTask(
      repairIntent: intent,
      launchRequest: request,
      selectedChoiceId: option.id,
      correctChoiceId: _correctOptionIdV1(selectedTask.runner),
      isCorrect: option.isCorrect,
      sequence: _repairOutcomeSequenceV1,
      sessionId: _sessionIdentityStateV1.currentActiveSessionId,
      repairAttemptId: repairAttemptId,
    );
    final recordedOutcomes = _repairOutcomeProjectionV1.outcomes.where(
      (outcome) => outcome.repairAttemptId == repairAttemptId,
    );
    final recordedOutcome = recordedOutcomes.isEmpty
        ? null
        : recordedOutcomes.single;
    final eligible =
        intent != null &&
        recordedOutcome != null &&
        act0RepairGoalOutcomeIsEligibleV1(
          intent: intent,
          outcome: recordedOutcome,
          learningEvidence: _learningEvidenceHistoryV1,
          currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
        );
    if (_activePracticeRepairQueueRequestV1?.repairTaskId ==
        selectedTask.taskId) {
      _emitRepairCompletedTelemetryV1(
        sourceTaskId: request.sourceTaskId,
        repairTaskId: request.repairTaskId,
        repaired: eligible && option.isCorrect,
      );
    }
    _reviewResolutionReceiptHistoryV1 =
        reviewResolutionReceiptHistoryFromSourcesV1(
          learningEvidenceHistory: _learningEvidenceHistoryV1,
          currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
          reviewMistakeHistory: _reviewMistakeHistoryV1,
          activeRepairIntents: intentsBeforeOutcome,
          repairOutcomeProjection: _repairOutcomeProjectionV1,
          existingReceiptHistory: _reviewResolutionReceiptHistoryV1,
        );
    if (widget.telemetrySink != null) {
      try {
        final outcome = _repairOutcomeProjectionV1.outcomes.singleWhere(
          (outcome) => outcome.repairAttemptId == repairAttemptId,
        );
        final event = act0RepairOutcomeTelemetryEventV1(
          outcome: outcome,
          history: _learningEvidenceHistoryV1,
        );
        _recordTelemetryEventV1(event.name, event.fields);
      } catch (_) {
        // Outcome/receipt ownership remains independent of diagnostics.
      }
    }
    if (eligible) {
      _conceptFamilyStateHistoryV1 = _conceptFamilyStateHistoryV1
          .appendRepairOutcome(
            recordedOutcome,
            sourceOrder:
                _learningEvidenceHistoryV1.records.length +
                _repairOutcomeSequenceV1,
          );
    }
    _lastSessionLearnerStateV1 = Act0LastSessionLearnerStateV1(
      lastSessionRepairFocusId: request.repairFocusKey.trim().isNotEmpty
          ? request.repairFocusKey.trim()
          : request.repairTaskId.trim(),
      lastSessionProofResult: eligible && option.isCorrect
          ? act0LastSessionProofFixLandedV1
          : act0LastSessionProofNotYetV1,
      lastSessionDate: _todayDateString(),
      lastSessionWorldId: request.targetWorldId.trim(),
      lastSessionRepairOutcomeRef: eligible && option.isCorrect
          ? 'repair_outcome_v1|${recordedOutcome.sequence}|${recordedOutcome.queueItemId}'
          : '',
    );
    if (eligible && option.isCorrect) {
      _resolvedMistakeTaskIds.add(request.sourceTaskId);
      _cleanTaskIds.add(request.sourceTaskId);
      _lessonRunPendingRetryTaskIds.remove(request.sourceTaskId);
      _retentionMemoryByTaskId[request.sourceTaskId] = _updatedRetentionEntryV1(
        taskId: request.sourceTaskId,
        lessonId: intent.sourceLessonId,
        worldId: intent.sourceWorldId,
        status: _Act0RetentionMemoryStatusV1.fixedRecent,
      );
      _clearMatchedOpenRepairIntentV1(
        sourceTaskId: request.sourceTaskId,
        completedTaskId: request.repairTaskId,
      );
      _clearOpenRepairIntentsForCompletedTaskV1(
        completedTaskId: request.repairTaskId,
      );
    }
    _pruneMultiRepairQueueWithResolutionV1();
    _syncOpenRepairIntentIndexFromQueueV1();
    _activeRepairResultReceiptLine = _repairResultReceiptLineForOptionV1(
      selectedTask: selectedTask,
      option: option,
    );
    _activeRepairSessionSummaryLines = _repairSessionSummaryLinesForOptionV1(
      selectedTask: selectedTask,
      option: option,
    );
    _persistProgress();
  }

  String? _repairOutcomeProofLineV1() {
    final proof = Act0RepairOutcomeConsumerV1.fromProjection(
      _repairOutcomeProjectionV1,
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      repairIntents: _activeRepairIntentsV1(),
    ).proof;
    return proof?.detail;
  }

  Act0SameSessionLearningDeltaV1? _sameSessionLearningDeltaForTaskV1(
    String? taskId,
  ) {
    if (_diagnosticLearningEntryV1 != null) return null;
    final normalizedTaskId = taskId?.trim() ?? '';
    if (normalizedTaskId.isEmpty) return null;
    final delta = Act0SameSessionLearningDeltaProjectionV1.fromLearningRun(
      _learningRunV1,
    ).primaryDelta;
    if (delta == null || delta.sourceTaskId != normalizedTaskId) return null;
    return delta;
  }

  void _emitSameSessionLearningDeltaViewedV1(
    Act0SameSessionLearningDeltaV1 delta,
  ) {
    if (!_sameSessionLearningDeltaViewedIdsV1.add(delta.deltaId)) return;
    _recordTelemetryEventV1(
      'learning_effect_delta_viewed',
      delta.telemetryFields,
    );
  }

  void _emitSameSessionLearningDeltaCompletedV1(
    Act0SameSessionLearningDeltaV1 delta,
  ) {
    if (!_sameSessionLearningDeltaCompletedIdsV1.add(delta.deltaId)) return;
    _recordTelemetryEventV1(
      'learning_effect_delta_completed',
      delta.telemetryFields,
    );
  }

  void _clearActiveRepairLaunchV1() {
    _activeRepairTaskId = null;
    _activeRepairSourceTaskId = null;
    _activePracticeRepairQueueRequestV1 = null;
    _activeRepairObligationV1 = null;
  }

  Act0PracticeRepairQueueLaunchRequestV1? _practiceQueueRepairRequestForTaskV1(
    String taskId,
  ) {
    final request = _activePracticeRepairQueueRequestV1;
    return request != null &&
            request.repairTaskId == taskId &&
            _activeRepairTaskId == taskId &&
            _activeRepairSourceTaskId == request.sourceTaskId
        ? request
        : null;
  }

  bool _isPracticeQueueRepairAnswerV1(Act0LessonTaskV1 selectedTask) {
    return _practiceQueueRepairRequestForTaskV1(selectedTask.taskId) != null;
  }

  Act0RepairIntentV1 _specializedFamilyCompatibilityIntentV1(
    Act0RepairIntentV1 intent,
  ) {
    final compatibilityErrorType = switch (intent.sourceTaskId) {
      Act0PositionPersonalizationV1.sourceTaskId
          when intent.errorType == 'misread_table_position' =>
        Act0PositionPersonalizationV1.errorType,
      Act0PricePersonalizationV1.sourceTaskId
          when intent.errorType == 'misread_bet_price' =>
        Act0PricePersonalizationV1.errorType,
      _ => '',
    };
    if (compatibilityErrorType.isEmpty) {
      return intent;
    }
    final payload = intent.toPayload();
    payload['errorType'] = compatibilityErrorType;
    return Act0RepairIntentV1.tryParse(payload)!;
  }

  Act0PositionPersonalizationCaseV1? _positionCaseForIntentV1(
    Act0RepairIntentV1 intent,
  ) => Act0PositionPersonalizationV1.fromRepairIntent(
    _specializedFamilyCompatibilityIntentV1(intent),
  );

  Act0PricePersonalizationCaseV1? _priceCaseForIntentV1(
    Act0RepairIntentV1 intent,
  ) => Act0PricePersonalizationV1.fromRepairIntent(
    _specializedFamilyCompatibilityIntentV1(intent),
  );

  Act0BoardTexturePersonalizationCaseV1? _boardTextureCaseForIntentV1(
    Act0RepairIntentV1 intent,
  ) => Act0BoardTexturePersonalizationV1.fromRepairIntent(intent);

  String _correctOptionIdV1(Act0RunnerStateV1 runner) =>
      runner.options.where(act0RunnerOptionIsPreferredV1).firstOrNull?.id ?? '';

  void _storeOpenRepairIntentForMissV1({
    required String sourceWorldId,
    required String sourceLessonId,
    required String sourceTaskId,
    required Act0RunnerStateV1 runner,
    required Act0RunnerOptionV1 option,
    Act0LessonTaskV1? diagnosticSourceTask,
  }) {
    // A failed directed repair is another attempt at the launched obligation,
    // not a newly invented source miss from the target runner's metadata.
    if (_activeRepairTaskId == _selectedTaskId &&
        _activeRepairObligationV1 != null)
      return;
    final intent = buildAct0RepairIntentV1(
      sourceWorldId: sourceWorldId,
      sourceLessonId: sourceLessonId,
      sourceTaskId: sourceTaskId,
      runner: runner,
      selectedOption: option,
      mapSameSignalRep: act0FirstValueSameSignalRepMappingV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      sourceTask: diagnosticSourceTask,
      diagnosticVariantId: diagnosticSourceTask == null
          ? ''
          : _placementDiagnosticSpotsV1[_placementDiagnosticIndex].signalId,
      currentDiagnosticVariantFingerprint:
          _diagnosticVariantFingerprintForIdentityV1,
    );
    if (intent == null) {
      return;
    }
    _multiRepairQueueOrderV1 += 1;
    _multiRepairQueueV1 = _multiRepairQueueV1.upsertIntent(
      intent,
      order: _multiRepairQueueOrderV1,
    );
    _syncOpenRepairIntentIndexFromQueueV1();
    final stored = _activeRepairIntentsV1().any(
      (entry) =>
          queueItemIdForAct0RepairIntentV1(entry) ==
          queueItemIdForAct0RepairIntentV1(intent),
    );
    if (!stored) {
      return;
    }
    final positionCase = _positionCaseForIntentV1(intent);
    if (positionCase != null) {
      _recordTelemetryEventV1(
        'position_personalization_classified',
        <String, Object?>{
          ...positionCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: 'repair_required',
          ),
          'user_choice': intent.choiceId,
          'correctness': false,
        },
      );
    }
    final priceCase = _priceCaseForIntentV1(intent);
    if (priceCase != null) {
      _recordTelemetryEventV1(
        'price_personalization_classified',
        <String, Object?>{
          ...priceCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: 'repair_required',
          ),
          'user_choice': intent.choiceId,
          'correctness': false,
        },
      );
    }
    final startingHandCase = Act0StartingHandPersonalizationV1.fromRepairIntent(
      intent,
    );
    if (startingHandCase != null) {
      _recordTelemetryEventV1(
        'starting_hand_personalization_classified',
        <String, Object?>{
          ...startingHandCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: 'repair_required',
          ),
          'user_choice': intent.choiceId,
          'correctness': false,
        },
      );
    }
    final boardTextureCase = _boardTextureCaseForIntentV1(intent);
    if (boardTextureCase != null) {
      _recordTelemetryEventV1(
        'board_texture_personalization_classified',
        <String, Object?>{
          ...boardTextureCase.telemetryFields(
            attemptPhase: 'decision',
            finalLearningOutcome: 'repair_required',
          ),
          'user_choice': intent.choiceId,
          'correctness': false,
        },
      );
    }
    _appendRepairIntentAuditEntryV1(
      _Act0RepairIntentAuditEntryV1(
        transition: 'intent_created',
        sourceTaskId: intent.sourceTaskId,
        targetTaskId: intent.targetTaskId,
        selectionSource: '',
        reasonCode: intent.reasonCode,
        mappingType: intent.mappingType,
      ),
    );
  }

  void _clearMatchedOpenRepairIntentV1({
    required String sourceTaskId,
    required String completedTaskId,
  }) {
    final intent = _openRepairIntentBySourceTaskId[sourceTaskId];
    if (intent == null) {
      return;
    }
    final resolution = Act0QueueResolutionStateV1.fromSources(
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      activeRepairIntents: [intent],
      repairOutcomeProjection: _repairOutcomeProjectionV1,
    ).resolutionForQueueItemId(queueItemIdForAct0RepairIntentV1(intent));
    if (resolution?.resolutionState != act0QueueResolutionStateResolvedV1) {
      return;
    }
    final completedExactReplay =
        act0IsExactRepairMappingTypeV1(intent.mappingType) &&
        completedTaskId == intent.sourceTaskId;
    final completedMappedTarget = completedTaskId == intent.targetTaskId;
    if (completedExactReplay || completedMappedTarget) {
      _openRepairIntentBySourceTaskId.remove(sourceTaskId);
      _multiRepairQueueV1 = Act0MultiRepairQueueV1(
        entries: List<Act0MultiRepairQueueEntryV1>.unmodifiable(
          _multiRepairQueueV1.entries.where(
            (entry) =>
                entry.queueItemId != queueItemIdForAct0RepairIntentV1(intent),
          ),
        ),
      );
      _syncOpenRepairIntentIndexFromQueueV1();
      _appendRepairIntentAuditEntryV1(
        _Act0RepairIntentAuditEntryV1(
          transition: 'intent_cleared',
          sourceTaskId: intent.sourceTaskId,
          targetTaskId: completedTaskId,
          selectionSource: '',
          reasonCode: intent.reasonCode,
          mappingType: completedExactReplay ? 'exact' : intent.mappingType,
        ),
      );
    }
  }

  void _clearOpenRepairIntentsForCompletedTaskV1({
    required String completedTaskId,
  }) {
    final normalizedCompletedTaskId = completedTaskId.trim();
    if (normalizedCompletedTaskId.isEmpty) {
      return;
    }
    final matchingSourceTaskIds = <String>[
      for (final intent in _openRepairIntentBySourceTaskId.values)
        if (intent.targetTaskId == normalizedCompletedTaskId ||
            (act0IsExactRepairMappingTypeV1(intent.mappingType) &&
                intent.sourceTaskId == normalizedCompletedTaskId))
          intent.sourceTaskId,
    ];
    for (final sourceTaskId in matchingSourceTaskIds) {
      _clearMatchedOpenRepairIntentV1(
        sourceTaskId: sourceTaskId,
        completedTaskId: normalizedCompletedTaskId,
      );
    }
  }

  _Act0RetentionMemoryEntryV1 _updatedRetentionEntryV1({
    required String taskId,
    required String lessonId,
    required String worldId,
    required String status,
  }) {
    final previous = _retentionMemoryByTaskId[taskId];
    final nextAttempts = status == _Act0RetentionMemoryStatusV1.openRepair
        ? (previous?.attempts ?? 0) + 1
        : (previous?.attempts ?? 0);
    final fixedAtSequence = status == _Act0RetentionMemoryStatusV1.fixedRecent
        ? _retentionSequence
        : previous?.fixedAtSequence ?? 0;
    return _Act0RetentionMemoryEntryV1(
      taskId: taskId,
      lessonId: lessonId,
      worldId: worldId,
      status: status,
      attempts: nextAttempts,
      fixedAtSequence: fixedAtSequence,
      lastRecheckSequence: previous?.lastRecheckSequence ?? 0,
      successfulRecheckCount: previous?.successfulRecheckCount ?? 0,
    );
  }

  _Act0RepairTargetV1? _repairVariantTargetForSourceV1(
    String taskId, {
    required String sourceLessonId,
  }) {
    const repairVariantTaskIds = <String, String>{
      'flush_draws_w5_flush_draw_find':
          'flush_draws_w5_flush_draw_recheck_transfer',
      'straight_draws_w5_gutshot_draw':
          'straight_draws_w5_gutshot_contrast_transfer',
      'turn_river_changes_w5_turn_hits':
          'turn_river_changes_w5_turn_texture_shift_transfer',
      'turn_river_changes_w5_street_repair':
          'turn_river_changes_w5_turn_texture_shift_transfer',
      'turn_river_changes_w5_river_misses':
          'turn_river_changes_w5_river_draw_story_transfer',
      'w6_value_range_action': 'w6_table_value_line_transfer',
      'w6_bluff_candidate': 'w6_turn_pressure_shift_transfer',
      'w6_wet_board_repair': 'w6_turn_pressure_shift_transfer',
    };
    final sameLessonTaskId = repairVariantTaskIds[taskId];
    if (sameLessonTaskId != null) {
      return _Act0RepairTargetV1(
        lessonId: sourceLessonId,
        taskId: sameLessonTaskId,
      );
    }
    const seatIdRepairTaskIds = <String, String>{
      'position_six_seats_positions_button':
          'position_six_seats_position_repair_seat_id_btn',
      'button_advantage_find_button':
          'position_six_seats_position_repair_seat_id_btn',
      'position_six_seats_positions_utg':
          'position_six_seats_position_repair_seat_id_utg',
    };
    final seatIdRepairTaskId = seatIdRepairTaskIds[taskId];
    if (seatIdRepairTaskId != null) {
      return _Act0RepairTargetV1(
        lessonId: 'position_six_seats',
        taskId: seatIdRepairTaskId,
      );
    }
    const btnLastPostflopRepairTaskIds = <String, String>{
      'button_advantage_button_last':
          'button_advantage_position_repair_btn_last_postflop',
    };
    final btnLastPostflopRepairTaskId = btnLastPostflopRepairTaskIds[taskId];
    if (btnLastPostflopRepairTaskId != null) {
      return _Act0RepairTargetV1(
        lessonId: 'button_advantage',
        taskId: btnLastPostflopRepairTaskId,
      );
    }
    const utgPlayersBehindRepairTaskIds = <String, String>{
      'early_vs_late_early_pressure_choice':
          'early_vs_late_position_repair_utg_players_behind',
      'position_checkpoint_position_checkpoint_early_fold':
          'early_vs_late_position_repair_utg_players_behind',
      'position_checkpoint_early_fold':
          'early_vs_late_position_repair_utg_players_behind',
      'position_apply_early_fold':
          'early_vs_late_position_repair_utg_players_behind',
    };
    final utgPlayersBehindRepairTaskId = utgPlayersBehindRepairTaskIds[taskId];
    if (utgPlayersBehindRepairTaskId != null) {
      return _Act0RepairTargetV1(
        lessonId: 'early_vs_late',
        taskId: utgPlayersBehindRepairTaskId,
      );
    }
    const earlyLateOrderRepairTaskIds = <String, String>{
      'position_six_seats_positions_late_seat':
          'position_six_seats_position_repair_early_late_order',
      'position_six_seats_positions_early_late':
          'position_six_seats_position_repair_early_late_order',
      'position_six_seats_seat_order_decision':
          'position_six_seats_position_repair_early_late_order',
    };
    final earlyLateOrderRepairTaskId = earlyLateOrderRepairTaskIds[taskId];
    if (earlyLateOrderRepairTaskId != null) {
      return _Act0RepairTargetV1(
        lessonId: 'position_six_seats',
        taskId: earlyLateOrderRepairTaskId,
      );
    }
    const sameHandDifferentSeatRepairTaskIds = <String, String>{
      'same_hand_different_seat_same_hand_early_fold':
          'same_hand_different_seat_position_repair_same_hand_different_seat',
      'same_hand_different_seat_same_hand_late_open':
          'same_hand_different_seat_position_repair_same_hand_different_seat',
    };
    final sameHandDifferentSeatRepairTaskId =
        sameHandDifferentSeatRepairTaskIds[taskId];
    if (sameHandDifferentSeatRepairTaskId != null) {
      return _Act0RepairTargetV1(
        lessonId: 'same_hand_different_seat',
        taskId: sameHandDifferentSeatRepairTaskId,
      );
    }
    const tablePositionSourceTaskIds = <String>{
      'button_advantage_button_open',
      'button_advantage_button_last',
      'button_advantage_button_vs_cutoff',
      'early_vs_late_early_pressure_choice',
      'early_vs_late_late_info_choice',
      'same_hand_different_seat_same_hand_early_fold',
      'same_hand_different_seat_same_hand_late_open',
      'position_apply_btn_open',
      'position_apply_late_open',
      'position_apply_early_fold',
      'position_apply_hj_fold',
      'position_checkpoint_late_open',
      'position_checkpoint_early_fold',
      'position_checkpoint_btn_call',
    };
    if (tablePositionSourceTaskIds.contains(taskId)) {
      return const _Act0RepairTargetV1(
        lessonId: 'position_checkpoint',
        taskId: 'position_checkpoint_position_checkpoint_table_notice',
      );
    }
    return null;
  }

  void _refreshRetentionMemoryStatusesV1() {
    for (final entry in _retentionMemoryByTaskId.values.toList()) {
      if (entry.status != _Act0RetentionMemoryStatusV1.fixedRecent) {
        continue;
      }
      if (!_isEligibleForAgedRecheckV1(entry)) {
        continue;
      }
      _retentionMemoryByTaskId[entry.taskId] = entry.copyWith(
        status: _Act0RetentionMemoryStatusV1.agedRecheck,
      );
    }
  }

  bool _isEligibleForAgedRecheckV1(_Act0RetentionMemoryEntryV1 entry) {
    if (entry.status != _Act0RetentionMemoryStatusV1.fixedRecent) {
      return false;
    }
    return _retentionSequence - entry.fixedAtSequence >=
        _Act0ShellPreviewScreenV1State._agedRecheckSequenceThresholdV1;
  }

  bool _isStableOwnedCandidateV1(_Act0RetentionMemoryEntryV1 entry) {
    return entry.status == _Act0RetentionMemoryStatusV1.ownedCandidate &&
        entry.successfulRecheckCount >= 2;
  }

  _Act0WorldRetentionSeedResultV1 _seedWorldCompletionRetentionTargetsV1(
    Act0WorldCardV1 world,
  ) {
    final candidates = <({String lessonId, String taskId, int weight})>[];
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        if (!_completedTaskIds.contains(task.taskId)) {
          continue;
        }
        final deltas = _skillDeltaForTask(lesson.lessonId, task.taskId);
        final weight = deltas.values.fold<int>(0, (sum, gain) => sum + gain);
        if (weight <= 0) {
          continue;
        }
        candidates.add((
          lessonId: lesson.lessonId,
          taskId: task.taskId,
          weight: weight,
        ));
      }
    }
    candidates.sort((a, b) {
      final weightCompare = b.weight.compareTo(a.weight);
      if (weightCompare != 0) {
        return weightCompare;
      }
      return a.taskId.compareTo(b.taskId);
    });

    var recheckCount = 0;
    var proveCount = 0;
    var emittedCount = 0;
    var changed = false;

    for (final candidate in candidates) {
      if (emittedCount >= 2) {
        break;
      }
      final existing = _retentionMemoryByTaskId[candidate.taskId];
      if (existing?.status == _Act0RetentionMemoryStatusV1.openRepair) {
        continue;
      }
      if (existing?.status == _Act0RetentionMemoryStatusV1.agedRecheck) {
        recheckCount += 1;
        emittedCount += 1;
        continue;
      }
      if (existing?.status == _Act0RetentionMemoryStatusV1.ownedCandidate) {
        proveCount += 1;
        emittedCount += 1;
        continue;
      }
      if (existing?.status == _Act0RetentionMemoryStatusV1.fixedRecent) {
        _retentionMemoryByTaskId[candidate.taskId] = existing!.copyWith(
          status: _Act0RetentionMemoryStatusV1.agedRecheck,
        );
        recheckCount += 1;
        emittedCount += 1;
        changed = true;
        continue;
      }
      _retentionMemoryByTaskId[candidate.taskId] = _Act0RetentionMemoryEntryV1(
        taskId: candidate.taskId,
        lessonId: candidate.lessonId,
        worldId: world.worldId,
        status: _Act0RetentionMemoryStatusV1.agedRecheck,
        attempts: existing?.attempts ?? 0,
        fixedAtSequence:
            (_retentionSequence -
                    _Act0ShellPreviewScreenV1State
                        ._agedRecheckSequenceThresholdV1)
                .clamp(0, _retentionSequence),
        lastRecheckSequence: existing?.lastRecheckSequence ?? 0,
        successfulRecheckCount: existing?.successfulRecheckCount ?? 0,
      );
      recheckCount += 1;
      emittedCount += 1;
      changed = true;
    }

    return _Act0WorldRetentionSeedResultV1(
      recheckCount: recheckCount,
      proveCount: proveCount,
      changed: changed,
    );
  }

  bool _usesSizingPresetControlsV1(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    return selectedLesson.lessonId == 'small_half_pot' &&
        selectedTask.phase == Act0LessonPhaseV1.drill &&
        selectedTask.resolvedTaskFamily == Act0TaskFamilyV1.sizing &&
        _Act0ShellPreviewScreenV1State._w5SizingDrillTaskIds.contains(
          selectedTask.taskId,
        );
  }

  Act0SizingConfigV1 _activeSizingConfigV1(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    if (_phase != Act0LessonPhaseV1.drill) {
      return const Act0SizingConfigV1.disabled();
    }
    final authored = selectedTask.runner.sizingConfig;
    if (authored.isEnabled) return authored;
    if (!_usesSizingPresetControlsV1(selectedLesson, selectedTask)) {
      return const Act0SizingConfigV1.disabled();
    }
    return Act0SizingConfigV1(
      mode: Act0SizingUiModeV1.presetsOnly,
      showGuidance: false,
      presets: selectedTask.runner.options
          .map(
            (option) => Act0SizingPresetV1(
              id: option.id,
              label: option.label,
              potFraction: _potFractionFromSizingLabelV1(option.label),
              displayLabel: _sizingDisplayLabelV1(option.label),
              detailLabel: option.label,
              ctaLabel: 'Lock ${_sizingDisplayLabelV1(option.label)}',
              isPrimary: option.isCorrect,
            ),
          )
          .toList(growable: false),
    );
  }

  String? _activeSelectedPresetIdV1(Act0LessonTaskV1 selectedTask) {
    if (_phase != Act0LessonPhaseV1.drill ||
        _selectedPresetTaskId != selectedTask.taskId) {
      return null;
    }
    return _selectedPresetId;
  }

  double _potFractionFromSizingLabelV1(String label) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(label);
    final amount = double.tryParse(match?.group(1) ?? '');
    if (amount == null || amount <= 0) {
      return 0;
    }
    return amount / 6;
  }

  String _sizingDisplayLabelV1(String label) {
    switch (label) {
      case '2 BB':
        return 'One-third';
      case '3 BB':
        return 'Half-pot';
      case '6 BB':
        return 'Pot-size';
      default:
        return label;
    }
  }

  void _confirmSizingPresetAnswerV1({
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
  }) {
    final presetId = _activeSelectedPresetIdV1(selectedTask);
    if (presetId == null) {
      return;
    }
    final option = _optionById(selectedTask.runner.options, presetId);
    if (option == null) {
      return;
    }
    _fireAnswerEffects(option);
    if (!_placementDiagnosticActive) {
      _recordAnswer(selectedLesson, selectedTask, option);
    }
    _selectedOptionId = option.id;
    _phase = Act0LessonPhaseV1.review;
    _teachingStepIndex = 0;
  }

  void _finishRapidPracticeLoopToHub({
    String? completedLessonId,
    int? completedRepCount,
    int? cleanRepCount,
    String? resultSummary,
  }) {
    final groupId = _activePracticeGroupId;
    if (groupId != null &&
        completedRepCount != null &&
        cleanRepCount != null &&
        resultSummary != null) {
      _emitPracticeCompletedTelemetryV1(
        practiceGroupId: groupId,
        completedRepCount: completedRepCount,
        cleanRepCount: cleanRepCount,
        resultSummary: resultSummary,
      );
    }
    if (groupId == 'daily') {
      _practiceCompletionTitle = _copyV1(
        en: 'Session complete',
        ru: 'Дневная серия закрыта',
      );
      _practiceCompletionBody = _copyV1(
        en: 'Session complete. Good work practicing. Review an open mistake or try one fresh route spot next.',
        ru: 'Три коротких повтора готовы. Сегодняшние чтения остаются в тонусе. Можешь взять ещё одну дорожку или вернуться домой.',
      );
    } else if (completedLessonId != null) {
      final family = _playDrillTitleForLesson(completedLessonId);
      _practiceCompletionTitle = _copyV1(
        en: 'Rep complete',
        ru: 'Повтор готов',
      );
      _practiceCompletionBody = _copyV1(
        en:
            cleanRepCount != null &&
                completedRepCount != null &&
                cleanRepCount == completedRepCount &&
                cleanRepCount > 0
            ? '$family: you answered correctly without help. Try a new hand next.'
            : '$family: practice complete. Review a mistake, then try again without help.',
        ru: '$family остаются в тонусе. Возьми другой пак, когда захочешь ещё один чистый повтор.',
      );
    }
    _showPlayHub = true;
    _returnToPlayHubOnBack = true;
    _selectedOptionId = null;
    _selectedPresetId = null;
    _selectedPresetTaskId = null;
    _phase = Act0LessonPhaseV1.theory;
    _teachingStepIndex = 0;
    _persistProgress();
  }

  String _hardenMistakeReason({
    required String rawReason,
    required String betterLabel,
    required List<String> contextLabels,
  }) {
    final reason = rawReason.trim();
    final lowerReason = reason.toLowerCase();
    if (lowerReason.contains('next cue:')) {
      return reason;
    }
    final focus = contextLabels.firstWhere(
      (label) => label.trim().isNotEmpty,
      orElse: () => '',
    );
    final cue = betterLabel.trim().isEmpty
        ? (focus.isEmpty
              ? 'Next cue: compare seat, pressure, and legal actions before you continue.'
              : 'Next cue: check $focus, then compare seat, pressure, and legal actions.')
        : (focus.isEmpty
              ? 'Next cue: pause on seat and pressure, then choose $betterLabel.'
              : 'Next cue: check $focus, then choose $betterLabel.');
    if (reason.isEmpty) {
      return cue;
    }
    return '$reason $cue';
  }

  String? _secondLessonMissSourceV1(
    Act0LessonTaskV1? task,
    Act0RunnerStateV1? runner,
  ) {
    if (task == null ||
        runner?.selectedOption?.quality != Act0FeedbackQualityV1.wrong ||
        _phase != Act0LessonPhaseV1.review ||
        _placementDiagnosticActive ||
        _diagnosticLearningEntryV1 != null ||
        _spacedReviewReturnV1 != null ||
        _lessonExampleSourceTaskIdV1 != null ||
        _rapidPracticeLoop) {
      return null;
    }
    if (_activeSameSignalFeedbackRepairV1 &&
        _activeRepairTaskId == task.taskId) {
      return _activeRepairSourceTaskId;
    }
    if (_activeRepairTaskId != null) return null;
    if (_lessonRunRetriedTaskIds.contains(task.taskId)) return task.taskId;

    final recent = _learningEvidenceHistoryV1.records.reversed
        .where(
          (record) =>
              record.createdOrder > (_lessonRunEvidenceStartOrderV1 ?? -1) &&
              !record.isDiagnosticLearningEntry &&
              !record.isPlacementAssessment,
        )
        .take(2)
        .toList();
    return recent.length == 2 &&
            recent.every(
              (record) =>
                  record.worldId == _selectedWorldId &&
                  record.lessonId == _selectedLessonId &&
                  record.taskId == task.taskId &&
                  !record.isCorrect,
            )
        ? task.taskId
        : null;
  }

  _Act0FirstValueDailyRepTargetV1? _otherLessonExampleV1({
    required String sourceTaskId,
    required String attemptedTaskId,
    required List<Act0WorldCardV1> worlds,
  }) {
    final example = act0RepairGapAdjudicationForSourceTaskV1(attemptedTaskId);
    if (example == null ||
        example.outcome != Act0RepairGapOutcomeV1.alternateSameSignalTarget ||
        example.leaksOriginalAnswer ||
        example.requiresFutureKnowledge ||
        example.targetTaskId == sourceTaskId ||
        !_completedTaskIds.contains(example.targetTaskId)) {
      return null;
    }
    return _repairIntentTargetByIdsIfLaunchableV1(
      worlds,
      worldId: example.targetWorldId!,
      lessonId: example.targetLessonId!,
      taskId: example.targetTaskId!,
      mappingType: example.mappingType,
      allowSourceTask: false,
      sourceTaskId: attemptedTaskId,
    );
  }

  void _startOtherLessonExampleV1(
    String sourceTaskId,
    _Act0FirstValueDailyRepTargetV1 target,
  ) {
    final source = _mistakeRecords[sourceTaskId];
    if (source == null) return;
    // Retain the lesson cursor and its Review obligation while the learner
    // revisits an already completed example. The optional attempt is unscored.
    _lessonExampleSourceTaskIdV1 = sourceTaskId;
    final world = _worldById(
      _progressWorlds(widget.state ?? Act0ShellStateV1.sample),
      target.worldId,
    );
    if (!_startTaskByIds(
      world,
      target.lessonId,
      target.taskId,
      skipTeaching: true,
      evidenceRunKind: 'practice',
      evidenceStartedBy: 'lesson_extra_example',
    )) {
      _lessonExampleSourceTaskIdV1 = null;
      return;
    }
    _activeActionSequenceStageV1 = null;
  }

  bool _isExactLessonRetryV1(Act0LessonTaskV1 task) {
    if (_lessonRunRetriedTaskIds.contains(task.taskId)) return true;
    final lastAnswer = _learningEvidenceHistoryV1.records.lastOrNull;
    return _phase == Act0LessonPhaseV1.drill &&
        _teachingStepIndex >= task.runner.teachingSteps.length &&
        _activeRepairTaskId == null &&
        !_rapidPracticeLoop &&
        lastAnswer != null &&
        !lastAnswer.isCorrect &&
        !lastAnswer.isPlacementAssessment &&
        !lastAnswer.isDiagnosticLearningEntry &&
        lastAnswer.worldId == _selectedWorldId &&
        lastAnswer.lessonId == _selectedLessonId &&
        lastAnswer.taskId == task.taskId;
  }

  void _continueAfterRepeatedLessonMissV1(String sourceTaskId) {
    final source = _mistakeRecords[sourceTaskId];
    if (source == null) return;
    final world = _worldById(
      _progressWorlds(widget.state ?? Act0ShellStateV1.sample),
      source.worldId,
    );
    final lesson = _lessonById(world.lessons, source.lessonId);
    if (!_completedTaskIds.contains(sourceTaskId)) {
      _skippedTaskIds.add(sourceTaskId);
      _visibleSkippedTaskIds.add(sourceTaskId);
    }
    _lessonExampleSourceTaskIdV1 = null;
    _lessonRunWrapUpCompletedTaskIds.add(sourceTaskId);
    _activeLessonWrapUpTaskId = null;
    _activeSameSignalRecheckTaskId = null;
    _activeSameSignalRecheckSourceTaskId = null;
    _placementHandoffActive = false;
    _clearActiveRepairLaunchV1();
    _selectedWorldId = source.worldId;
    _selectedLessonId = source.lessonId;
    _selectedTaskId = sourceTaskId;
    _selectedOptionId = null;
    _teachingStepIndex = 0;
    _returnToPlayHubOnBack = false;
    if (_maybeShowBlockCompletionSummary(
      selectedWorld: world,
      selectedLesson: lesson,
      selectedTask: _taskById(lesson, sourceTaskId),
    )) {
      _persistProgress();
      return;
    }
    _advanceAfterTask(world, lesson);
  }

  bool _shouldRetryInsideLesson(
    Act0LessonTaskV1 selectedTask,
    Act0RunnerStateV1 runner,
  ) {
    final selectedOption = runner.selectedOption;
    if (selectedOption == null || selectedOption.isCorrect) {
      return false;
    }
    if (_activeRepairTaskId == selectedTask.taskId ||
        _placementDiagnosticActive) {
      return false;
    }
    return _lessonRunPendingRetryTaskIds.contains(selectedTask.taskId) &&
        !_lessonRunRetriedTaskIds.contains(selectedTask.taskId);
  }

  void _startInsideLessonRetry(
    Act0LessonTaskV1 selectedTask,
    Act0RunnerStateV1 runner,
  ) {
    _lessonRunPendingRetryTaskIds.remove(selectedTask.taskId);
    _lessonRunRetriedTaskIds.add(selectedTask.taskId);
    _selectedOptionId = null;
    _phase = runner.options.isEmpty
        ? selectedTask.phase
        : Act0LessonPhaseV1.drill;
    _teachingStepIndex = runner.teachingSteps.length;
    _persistProgress();
  }

  bool _maybeStartLessonWrapUpRetry(Act0LessonCardV1 selectedLesson) {
    if (_placementDiagnosticActive || _activeRepairTaskId != null) {
      return false;
    }
    final wrapUpAnchorTaskId = _lessonRunWrapUpAnchorTaskId ?? _selectedTaskId;
    if (_nextTask(selectedLesson, wrapUpAnchorTaskId) != null) {
      return false;
    }
    _lessonRunWrapUpAnchorTaskId ??= wrapUpAnchorTaskId;
    for (final task in selectedLesson.taskList) {
      if (!_lessonRunMistakeTaskIds.contains(task.taskId)) {
        continue;
      }
      if (_lessonRunWrapUpCompletedTaskIds.contains(task.taskId)) {
        continue;
      }
      _activeLessonWrapUpTaskId = task.taskId;
      _selectedTaskId = task.taskId;
      _selectedOptionId = null;
      _phase = task.runner.options.isEmpty
          ? task.phase
          : Act0LessonPhaseV1.drill;
      _teachingStepIndex = 0;
      _tab = Act0ShellTabV1.play;
      _showPlayHub = false;
      return true;
    }
    return false;
  }

  void _restoreWrapUpAnchorTaskId(Act0LessonCardV1 selectedLesson) {
    final wrapUpAnchorTaskId = _lessonRunWrapUpAnchorTaskId;
    if (wrapUpAnchorTaskId == null) {
      return;
    }
    final anchorTask = _taskById(selectedLesson, wrapUpAnchorTaskId);
    _selectedTaskId = anchorTask.taskId;
    _phase = anchorTask.entryPhase;
  }

  String _repairActionLabel(Act0LessonTaskV1 task) {
    return switch (task.stepKind) {
      Act0LessonStepKindV1.learn => 'Replay the idea once',
      Act0LessonStepKindV1.practice => 'Replay this spot once',
      Act0LessonStepKindV1.fixMistakes => 'Replay the repair spot',
      Act0LessonStepKindV1.review => 'Replay the key spot',
      Act0LessonStepKindV1.proveIt => 'Replay the final check',
    };
  }

  List<String> _repairContextLabels(
    Act0RunnerStateV1 runner,
    Act0RunnerOptionV1 option,
  ) {
    if (option.repairFocusLabels.isNotEmpty) {
      return option.repairFocusLabels;
    }
    return <String>[
      if (runner.table.centerLabel.isNotEmpty) runner.table.centerLabel,
      if (runner.table.potLabel.isNotEmpty) runner.table.potLabel,
      if (runner.table.toCallLabel.isNotEmpty) runner.table.toCallLabel,
    ];
  }

  int _remainingWrapUpTaskCount() {
    return _lessonRunMistakeTaskIds
        .where((taskId) => !_lessonRunWrapUpCompletedTaskIds.contains(taskId))
        .length;
  }

  Act0RunnerStateV1 _repairRunnerForTask(Act0LessonTaskV1 selectedTask) {
    if (_activeLessonWrapUpTaskId == selectedTask.taskId) {
      final record = _mistakeRecords[selectedTask.taskId];
      final option = record == null
          ? null
          : _optionById(selectedTask.runner.options, record.selectedOptionId);
      final focusLabels = option == null || record == null
          ? const <String>[]
          : _repairContextLabels(selectedTask.runner, option);
      final focusTable = option == null || record == null
          ? selectedTask.runner.table
          : _repairFocusedTable(selectedTask.runner.table, option, record);
      final showWrapUpIntro = _lessonRunWrapUpCompletedTaskIds.isEmpty;
      final remainingWrapUpTaskCount = _remainingWrapUpTaskCount();
      final wrapUpCountLine = remainingWrapUpTaskCount <= 1
          ? 'One spot to revisit before the lesson summary.'
          : '$remainingWrapUpTaskCount spots to revisit before the lesson summary.';
      return selectedTask.runner.copyWith(
        sharky: showWrapUpIntro
            ? selectedTask.runner.sharky.copyWith(
                preSessionLine: 'One last check before the lesson wraps.',
                preSessionMood: Act0SharkyMoodV1.thinking,
              )
            : selectedTask.runner.sharky,
        table: focusTable,
        teachingSteps: showWrapUpIntro
            ? <Act0TeachingStepV1>[
                Act0TeachingStepV1(
                  title: 'One last check',
                  body: record == null
                      ? wrapUpCountLine
                      : 'You missed this earlier. $wrapUpCountLine',
                  table: focusTable,
                  focusSeatIds: option?.repairFocusSeatIds ?? const <String>[],
                  focusCardIds: option?.repairFocusCardIds ?? const <String>[],
                  focusLabels: focusLabels,
                  ctaLabel: 'Retry',
                ),
              ]
            : const <Act0TeachingStepV1>[],
      );
    }
    final repairSourceTaskId = _activeRepairTaskId == selectedTask.taskId
        ? (_activeRepairSourceTaskId ?? selectedTask.taskId)
        : selectedTask.taskId;
    final record = _activeRepairTaskId == selectedTask.taskId
        ? _mistakeRecords[repairSourceTaskId]
        : null;
    if (record == null) {
      return selectedTask.runner;
    }
    final option = _optionById(
      selectedTask.runner.options,
      record.selectedOptionId,
    );
    final focusLabels = option == null
        ? record.contextLabels
        : _repairContextLabels(selectedTask.runner, option);
    final focusTable = option == null
        ? selectedTask.runner.table
        : _repairFocusedTable(selectedTask.runner.table, option, record);
    return selectedTask.runner.copyWith(
      sharky: selectedTask.runner.sharky.copyWith(
        preSessionLine: selectedTask.runner.sharky.repairLine,
        preSessionMood: Act0SharkyMoodV1.repair,
      ),
      table: focusTable,
      teachingSteps: <Act0TeachingStepV1>[
        Act0TeachingStepV1(
          title: repairSourceTaskId == selectedTask.taskId
              ? 'Repair this spot'
              : 'Try a similar spot',
          body: act0RepairPracticeIntroBodyV1(
            selectedLabel: record.selectedLabel,
            sameTask: repairSourceTaskId == selectedTask.taskId,
          ),
          table: focusTable,
          focusSeatIds: option?.repairFocusSeatIds ?? const <String>[],
          focusCardIds: option?.repairFocusCardIds ?? const <String>[],
          focusLabels: focusLabels,
          ctaLabel: 'Practice',
        ),
        ...selectedTask.runner.teachingSteps,
      ],
    );
  }

  Act0RunnerOptionV1? _optionById(
    List<Act0RunnerOptionV1> options,
    String optionId,
  ) {
    for (final option in options) {
      if (option.id == optionId) {
        return option;
      }
    }
    return null;
  }

  Act0TableStateV1 _repairFocusedTable(
    Act0TableStateV1 table,
    Act0RunnerOptionV1 option,
    _Act0MistakeRecordV1 record,
  ) {
    return table.copyWith(
      highlightedSeatIds: option.repairFocusSeatIds.isEmpty
          ? table.highlightedSeatIds
          : option.repairFocusSeatIds,
      highlightedCardIds: option.repairFocusCardIds.isEmpty
          ? table.highlightedCardIds
          : option.repairFocusCardIds,
      focusCalloutLabel: act0RepairFocusCalloutV1(
        selectedLabel: record.selectedLabel,
      ),
    );
  }
}
