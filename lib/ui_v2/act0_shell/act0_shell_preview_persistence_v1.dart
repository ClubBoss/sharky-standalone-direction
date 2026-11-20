part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewPersistenceV1 on _Act0ShellPreviewScreenV1State {
  bool _handleLearnLessonSelectV1({
    required Act0LessonCardV1 lesson,
    required String lessonId,
  }) {
    final effectiveDetailLessonId = _learnDetailWorldId == null
        ? _learnDetailLessonId
        : null;
    if (!lesson.isSelectable) {
      _setStateV1(() {
        _learnPopupTaskId = null;
      });
      return false;
    }
    if (effectiveDetailLessonId == lessonId) {
      _setStateV1(() {
        _learnDetailLessonId = null;
        _learnPopupTaskId = null;
      });
      return false;
    }
    _learnLessonOpenSequenceV1++;
    _setStateV1(() {
      _learnPopupTaskId = null;
      if (lesson.isSelectable) {
        _selectedLessonId = lessonId;
        _selectedTaskId = _firstIncompleteTask(lesson).taskId;
        _teachingStepIndex = 0;
        _resetLessonRunMetrics();
      }
      _learnDetailLessonId = lessonId;
      _learnDetailWorldId = null;
    });
    return false;
  }

  Future<void> _restorePersistedProgress() async {
    final epoch = _recoveryEpochV1;
    final store = _progressStore;
    final loaded = await store.loadState();
    if (!mounted || epoch != _recoveryEpochV1) return;
    if (loaded.isReset) {
      _restorePreviewToFreshStart(showPlacement: false);
      _progressStore = _Act0ShellPreviewScreenV1State._makeProgressStoreV1();
      return;
    }
    if (!store.isWriteLeaseCurrent) throw const Act0RecoveryHoldV1();
    final raw = loaded.payload;
    if (raw == null || raw.isEmpty || !mounted) {
      // First-start with no saved payload must not inherit sample/demo work.
      // Hosts that bypass first-start retain their established empty policy.
      if (widget.showPlacementOnStart) {
        _restorePreviewToFreshStart(showPlacement: false);
      }
      return;
    }
    final parsed = _Act0PersistedProgressV1.tryParse(raw);
    if (parsed == null) {
      return;
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final validTaskIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons)
          for (final task in lesson.taskList) task.taskId,
    };
    final validLessonIds = <String>{
      for (final world in state.worlds)
        for (final lesson in world.lessons) lesson.lessonId,
    };
    final validWorldIds = <String>{
      for (final world in state.worlds) world.worldId,
    };
    final completedTaskIds = parsed.completedTaskIds
        .where(validTaskIds.contains)
        .toSet();
    final skippedTaskIds = parsed.skippedTaskIds
        .where(validTaskIds.contains)
        .toSet();
    final completedLessonIds = parsed.completedLessonIds
        .where(validLessonIds.contains)
        .toSet();
    final compatLessonIds = _legacyCompatAutoCompletedLessonIdsV1(
      parsed: parsed,
      state: state,
    );
    final compatTaskIds = <String>{
      for (final lessonId in compatLessonIds)
        for (final task in state.lessonById(lessonId).taskList) task.taskId,
    }.where(validTaskIds.contains).toSet();
    completedTaskIds.addAll(compatTaskIds);
    completedLessonIds.addAll(compatLessonIds.where(validLessonIds.contains));
    // Placement skips are navigation, never earned completion: when only skips
    // (no genuine completion) show progress beyond the guide, keep the content
    // lesson path-closed as a SKIP so routing is unchanged, but earn nothing.
    final compatSkipTaskIds = <String>{
      for (final lessonId in _legacyCompatSkipClearedLessonIdsV1(
        parsed: parsed,
        state: state,
      ))
        for (final task in state.lessonById(lessonId).taskList) task.taskId,
    }.where(validTaskIds.contains).toSet();
    skippedTaskIds.addAll(compatSkipTaskIds.difference(completedTaskIds));
    final closedTaskIds = <String>{...completedTaskIds, ...skippedTaskIds};
    final worldsAfterProgress = _progressWorldsWithTaskIds(
      state,
      closedTaskIds,
      w1RulesBestScore: parsed.w1RulesBestScore,
    );
    final persistedWorld = _worldById(
      worldsAfterProgress,
      worldsAfterProgress.any(
            (world) => world.worldId == parsed.selectedWorldId,
          )
          ? parsed.selectedWorldId
          : state.selectedWorldId,
    );
    final selectedWorld = persistedWorld.status == Act0WorldStateV1.current
        ? persistedWorld
        : worldsAfterProgress.firstWhere(
            (world) =>
                world.status == Act0WorldStateV1.current && world.isSelectable,
            orElse: () => persistedWorld,
          );
    final persistedLesson =
        selectedWorld.lessons.any(
          (lesson) => lesson.lessonId == parsed.selectedLessonId,
        )
        ? _lessonById(selectedWorld.lessons, parsed.selectedLessonId)
        : null;
    final selectedLesson =
        persistedLesson != null &&
            !_lessonCompleteWithTaskIds(persistedLesson, closedTaskIds)
        ? persistedLesson
        : _firstPlayableLesson(selectedWorld);
    final selectedTask =
        selectedLesson.courseTaskList.any(
              (task) => task.taskId == parsed.selectedTaskId,
            ) &&
            !closedTaskIds.contains(parsed.selectedTaskId)
        ? _taskByIdWithTaskIds(
            selectedLesson,
            parsed.selectedTaskId,
            closedTaskIds,
          )
        : _firstIncompleteTaskWithTaskIds(selectedLesson, closedTaskIds);
    // Boot policy is Home-first. Persisted lesson/task progress is restored,
    // but ephemeral runner phase is not resumed over the launch surface.

    if (!mounted) {
      return;
    }
    final today = _todayDateString();
    final isNewDay = parsed.lastActiveDay != today;
    // Legacy 3/3 + lastActiveDay is NOT proof of completion on that date:
    // an old runtime could save yesterday's 3/3 after midnight. Fail closed
    // on the undated count without changing unrelated completed task/XP data.
    final earnedDay = parsed.lastEarnedDailyDay;
    // Older snapshots without this field lack even reliable provenance for
    // partial daily reps. New snapshots explicitly persist the field (empty
    // until the first completed set), so their 1/3–2/3 resume normally.
    final unverifiedLegacyDailyCount =
        !parsed.hasEarnedDailyDayField && parsed.dailyCompletedRepCount > 0;
    final unverifiedUnanchoredFullSet =
        earnedDay.isEmpty && parsed.dailyCompletedRepCount >= 3;
    final eligibleStreak =
        earnedDay == today || act0AreConsecutiveCivilDaysV1(earnedDay, today);
    final restoredStreakDays = eligibleStreak ? parsed.persistedStreakDays : 0;
    final restoredSkillValues = parsed.profileSkillValues.isEmpty
        ? _deriveSkillValuesFromCompletedTasks(completedTaskIds)
        : parsed.profileSkillValues;
    final restoredFirstValueCarry = _restorableFirstValueCarryV1(
      parsed.firstValueReturnCarry,
      state: state,
    );
    final restoredDurableRetention =
        parsed.durableRetentionHistory.families.isEmpty
        ? Act0DurableRetentionHistoryV1.fromLearningEvidence(
            parsed.learningEvidenceHistory,
          )
        : parsed.durableRetentionHistory;
    _setStateV1(() {
      _completedTaskIds = completedTaskIds;
      _diagnosticLearningEntryV1 = null;
      _diagnosticLearningReturnV1 = null;
      _spacedReviewReturnV1 = null;
      _activeSpacedReviewTaskV1 = null;
      _newSpacedReviewSavePendingV1 = false;
      _openedSpacedReviewTaskIdsV1
        ..clear()
        ..addAll(parsed.openedSpacedReviewTaskIds);
      _pendingReviewKindV1 = null;
      _completedLessonIds = completedLessonIds;
      _skippedTaskIds
        ..clear()
        ..addAll(skippedTaskIds);
      _visibleSkippedTaskIds
        ..clear()
        ..addAll(skippedTaskIds);
      _earnedXp = parsed.earnedXp;
      _profileSkillValues
        ..clear()
        ..addAll(restoredSkillValues);
      _recentSkillGains
        ..clear()
        ..addAll(parsed.recentSkillGains.take(6));
      _learningEvidenceHistoryV1 = parsed.learningEvidenceHistory;
      _w1StartChosenV1 = parsed.w1StartChosen;
      _w1RulesBestScoreV1 = parsed.w1RulesBestScore;
      _w1RulesFocusTaskIdsV1 = parsed.w1RulesFocusTaskIds;
      _studyObservationsV1 = parsed.studyObservations;
      final legacyPracticeDays = parsed.practiceDayKeys == null
          ? _learningEvidenceHistoryV1.practiceDayKeysLastWeek(
              widget.clock.nowUtc(),
            )
          : const <String>[];
      _savedPracticeDaysV1 =
          parsed.practiceDayKeys ??
          (legacyPracticeDays.isEmpty && earnedDay.isNotEmpty
              ? [earnedDay]
              : legacyPracticeDays);
      _durableRetentionHistoryV1 = restoredDurableRetention.refreshedAt(
        widget.clock.nowUtc(),
      );
      _reviewMistakeHistoryV1 = parsed.reviewMistakeHistory;
      _reviewResolutionReceiptHistoryV1 = parsed.reviewResolutionReceiptHistory;
      _conceptFamilyStateHistoryV1 = parsed.conceptFamilyStateHistory;
      _sessionIdentityStateV1 = parsed.sessionIdentityState;
      _repairOutcomeProjectionV1 = parsed.repairOutcomeProjection;
      _repairOutcomeSequenceV1 = parsed.repairOutcomeProjection.outcomes.fold(
        0,
        (latest, outcome) =>
            outcome.sequence > latest ? outcome.sequence : latest,
      );
      _selectedWorldId = selectedWorld.worldId;
      _selectedLessonId = selectedLesson.lessonId;
      _selectedTaskId = selectedTask.taskId;
      _pendingDecisionAssistanceV1
        ..clear()
        ..addEntries(
          parsed.pendingDecisionAssistance.map(
            (receipt) => MapEntry(receipt.key, receipt),
          ),
        );
      if (!parsed.hasPendingAssistanceProvenance &&
          parsed.resumePhase == 'drill' &&
          parsed.resumeSelectedOptionId == null &&
          selectedTask.taskId == parsed.selectedTaskId &&
          !closedTaskIds.contains(selectedTask.taskId)) {
        // Pre-fix snapshots cannot prove that this unfinished drill was unaided.
        final receipt = _Act0PendingDecisionAssistanceV1(
          worldId: selectedWorld.worldId,
          lessonId: selectedLesson.lessonId,
          taskId: selectedTask.taskId,
          fingerprint:
              act0CurrentAuthoredSourceFingerprintForIdentityV1(
                worldId: selectedWorld.worldId,
                lessonId: selectedLesson.lessonId,
                taskId: selectedTask.taskId,
              ) ??
              '',
          afterSourceOrder: _sourceEvidenceBoundaryV1(
            selectedWorld.worldId,
            selectedLesson.lessonId,
            selectedTask.taskId,
          ),
          kind: Act0DecisionAssistanceV1.legacyUnknown,
        );
        _pendingDecisionAssistanceV1[receipt.key] = receipt;
      }
      final hasPriorLessonProgress = selectedLesson.courseTaskList.any(
        (task) => completedTaskIds.contains(task.taskId),
      );
      final hasPriorLessonEvidence = parsed.learningEvidenceHistory.records.any(
        (record) =>
            !record.isPlacementAssessment &&
            !record.isDiagnosticLearningEntry &&
            record.lessonId == selectedLesson.lessonId,
      );
      _lessonRunEvidenceBoundariesV1
        ..clear()
        ..addAll(parsed.lessonRunEvidenceBoundaries)
        ..removeWhere((lessonId, _) => !validLessonIds.contains(lessonId));
      _lessonRunEvidenceLessonIdV1 = selectedLesson.lessonId;
      _lessonRunEvidenceStartOrderV1 =
          _lessonRunEvidenceBoundariesV1.containsKey(selectedLesson.lessonId)
          ? _lessonRunEvidenceBoundariesV1[selectedLesson.lessonId]
          : (hasPriorLessonProgress || hasPriorLessonEvidence
                ? null
                : _latestEvidenceOrderV1());
      _lessonRunEvidenceBoundariesV1[selectedLesson.lessonId] =
          _lessonRunEvidenceStartOrderV1;
      if (widget.initialTab == Act0ShellTabV1.learn) {
        _seedLearnRouteFocusV1(
          lessonId: selectedLesson.lessonId,
          taskId: selectedTask.taskId,
        );
      } else {
        _learnDetailLessonId = null;
      }
      _phase = selectedTask.entryPhase;
      _selectedOptionId = null;
      _teachingStepIndex = 0;
      _tab = widget.initialTab;
      _showPlayHub = widget.initialTab != Act0ShellTabV1.play;
      _blockCompletionSummary = null;
      _persistedStreakDays = restoredStreakDays;
      _lastDailyDate = earnedDay;
      _dailyRepCountDay = today;
      _dailyPracticeQueue = parsed.dailyPracticeQueue;
      _dailyCompletedTaskIds
        ..clear()
        ..addAll(
          isNewDay
              ? const <String>[]
              : parsed.dailyCompletedTaskIds.where(validTaskIds.contains),
        );
      _dailyCompletedRepCount =
          (isNewDay ||
              unverifiedLegacyDailyCount ||
              unverifiedUnanchoredFullSet)
          ? 0
          : parsed.dailyCompletedRepCount.clamp(0, 3);
      _retentionSequence = parsed.retentionSequence;
      _retentionMemoryByTaskId
        ..clear()
        ..addEntries(
          parsed.retentionMemory
              .where((entry) {
                return validTaskIds.contains(entry.taskId) &&
                    validLessonIds.contains(entry.lessonId) &&
                    validWorldIds.contains(entry.worldId);
              })
              .map(
                (entry) => MapEntry<String, _Act0RetentionMemoryEntryV1>(
                  entry.taskId,
                  entry,
                ),
              ),
        );
      // The repair queue owns unresolved debt. Placement can create valid
      // queue entries without a matching retention-memory entry. A missing or
      // changed target holds the recorded miss; it does not discharge it.
      bool isRestorableRepairIntentV1(Act0RepairIntentV1 intent) =>
          validWorldIds.contains(intent.sourceWorldId) &&
          validLessonIds.contains(intent.sourceLessonId) &&
          validTaskIds.contains(intent.sourceTaskId);
      final restoredRepairQueueEntries = parsed.multiRepairQueue.entries
          .map((entry) {
            final intent = _migratePersistedW1HeroButtonIntentV1(
              entry.repairIntent,
            );
            return identical(intent, entry.repairIntent)
                ? entry
                : entry.copyWith(repairIntent: intent);
          })
          .where((entry) => isRestorableRepairIntentV1(entry.repairIntent))
          .toList(growable: false);
      final restoredRepairQueue = Act0MultiRepairQueueV1(
        entries: List<Act0MultiRepairQueueEntryV1>.unmodifiable(
          restoredRepairQueueEntries,
        ),
      );
      _openRepairIntentBySourceTaskId
        ..clear()
        ..addEntries(
          restoredRepairQueue.activeRepairIntents().map(
            (intent) => MapEntry(intent.sourceTaskId, intent),
          ),
        );
      _suppressLegacyRecheckAfterRecoveryV1 =
          parsed.suppressLegacyRecheckAfterRecovery;
      if (_suppressLegacyRecheckAfterRecoveryV1)
        _sessionDrillRecheckQueueItemsV1 = const [];
      _multiRepairQueueV1 = restoredRepairQueue;
      _multiRepairQueueOrderV1 = parsed.multiRepairQueueOrder;
      _restorePersistedOpenRepairRecordsV1(state);
      _refreshRetentionMemoryStatusesV1();
      _firstValueReceiptCarry = restoredFirstValueCarry;
      _firstValueTodayShownTelemetryKey = '';
      _dismissedHomeHandoffKey = parsed.dismissedHomeHandoffKey;
      _dismissedHomeHandoffDay = parsed.dismissedHomeHandoffDay;
      _lastSessionLearnerStateV1 = parsed.lastSessionLearnerState;
      // Daily deck resets on new day
      if (isNewDay) {
        _dailyCompletedTaskIds.clear();
        _dailyPracticeQueue = const Act0DailyPracticeQueueV1();
        _dailyCompletedRepCount = 0;
        _rapidPracticeLoop = false;
      }
    });
    final restoredLastSession = parsed.lastSessionLearnerState;
    if (restoredLastSession != null &&
        restoredLastSession.isUsable &&
        act0AreConsecutiveCivilDaysV1(
          restoredLastSession.lastSessionDate,
          today,
        )) {
      _emitDay2ReturnTelemetryV1(restoredLastSession);
    }
  }

  _Act0FirstValueReceiptCarryV1? _restorableFirstValueCarryV1(
    _Act0FirstValueReceiptCarryV1? carry, {
    required Act0ShellStateV1 state,
  }) {
    if (carry == null) {
      return null;
    }
    if (carry.skillReceiptId.trim().isEmpty ||
        carry.skillAtomId.trim().isEmpty ||
        carry.sourceSignalId.trim().isEmpty ||
        carry.sourceSignalLabel.trim().isEmpty ||
        carry.nextRepId.trim().isEmpty ||
        carry.sourceWorldId.trim().isEmpty ||
        carry.sourceLessonId.trim().isEmpty ||
        carry.sourceTaskId.trim().isEmpty) {
      return null;
    }
    return _firstValueDailyRepTargetV1(carry, state: state) == null
        ? null
        : carry;
  }

  void _restorePersistedOpenRepairRecordsV1(Act0ShellStateV1 state) {
    _mistakeRecords.clear();
    _resolvedMistakeTaskIds.clear();
    for (final intent in _openRepairIntentBySourceTaskId.values) {
      final retention = _retentionMemoryByTaskId[intent.sourceTaskId];
      // A source repaired by a correct retry stays resolved, but its different
      // mapped same-signal repair is still owed and must remain actionable.
      final sourceRepairedButMappedOwed =
          retention != null &&
          retention.status != _Act0RetentionMemoryStatusV1.openRepair;
      if (sourceRepairedButMappedOwed &&
          _hasValidatedRepairClosureV1(intent) &&
          (act0IsExactRepairMappingTypeV1(intent.mappingType) ||
              intent.mappingType == 'unresolved_product_gap' ||
              intent.targetTaskId == intent.sourceTaskId)) {
        continue;
      }
      final world = state.worlds.cast<Act0WorldCardV1?>().firstWhere(
        (candidate) => candidate?.worldId == intent.sourceWorldId,
        orElse: () => null,
      );
      if (world == null) {
        continue;
      }
      final lesson = world.lessons.cast<Act0LessonCardV1?>().firstWhere(
        (candidate) => candidate?.lessonId == intent.sourceLessonId,
        orElse: () => null,
      );
      if (lesson == null) {
        continue;
      }
      final task = lesson.taskList.cast<Act0LessonTaskV1?>().firstWhere(
        (candidate) => candidate?.taskId == intent.sourceTaskId,
        orElse: () => null,
      );
      if (task == null) {
        continue;
      }
      // Placement owns genuine repair debt without retention. Restore its
      // diagnostic answer context only from the exact persisted occurrence;
      // the ordinary task can have different option IDs and answer meanings.
      final placementRunner = _placementRepairRunnerForRestoreV1(intent, task);
      final runner =
          placementRunner ??
          (retention != null || _hasValidatedRepairTargetV1(intent)
              ? task.runner
              : null);
      if (runner == null) {
        continue;
      }
      final selectedOption = runner.options
          .cast<Act0RunnerOptionV1?>()
          .firstWhere(
            (candidate) => candidate?.id == intent.choiceId,
            orElse: () => null,
          );
      final correctOption = runner.options
          .cast<Act0RunnerOptionV1?>()
          .firstWhere(
            (candidate) => candidate?.isCorrect == true,
            orElse: () => null,
          );
      if (selectedOption == null || correctOption == null) {
        continue;
      }
      final contextLabels = _repairContextLabels(runner, selectedOption);
      _mistakeRecords[intent.sourceTaskId] = _Act0MistakeRecordV1(
        taskId: intent.sourceTaskId,
        lessonId: lesson.lessonId,
        worldId: world.worldId,
        title: _localizedTaskTitleV1(task),
        weaknessLabel: _categoryForLesson(lesson.lessonId),
        selectedOptionId: selectedOption.id,
        selectedLabel: selectedOption.label,
        betterLabel: selectedOption.betterAnswerLabel.isEmpty
            ? correctOption.betterAnswerLabel
            : selectedOption.betterAnswerLabel,
        reason: _hardenMistakeReason(
          rawReason: selectedOption.feedbackReason,
          betterLabel: selectedOption.betterAnswerLabel.isEmpty
              ? correctOption.betterAnswerLabel
              : selectedOption.betterAnswerLabel,
          contextLabels: contextLabels,
        ),
        contextLabels: contextLabels,
        repairActionLabel: _repairActionLabel(task),
        // The live Placement projection also starts this one occurrence at 1.
        attempts: retention?.attempts.clamp(1, 99) ?? 1,
      );
      if (sourceRepairedButMappedOwed) {
        _resolvedMistakeTaskIds.add(intent.sourceTaskId);
      }
    }
  }

  Act0RunnerStateV1? _placementRepairRunnerForRestoreV1(
    Act0RepairIntentV1 intent,
    Act0LessonTaskV1 task,
  ) {
    final occurrenceId = intent.repairOccurrenceId;
    if (occurrenceId.isEmpty) {
      return null;
    }
    final history = _reviewMistakeHistoryV1.records
        .where(
          (record) =>
              record.sourceDecisionId == occurrenceId &&
              record.worldId == intent.sourceWorldId &&
              record.lessonId == intent.sourceLessonId &&
              record.decisionTaskId == intent.sourceTaskId &&
              record.sourceTaskId == intent.sourceTaskId &&
              record.selectedId == intent.choiceId &&
              record.runKind == act0PlacementAssessmentRunKindV1 &&
              record.attemptRecordIds.contains(occurrenceId),
        )
        .toList(growable: false);
    final evidence = _learningEvidenceHistoryV1.records
        .where(
          (record) =>
              record.recordId == occurrenceId &&
              record.worldId == intent.sourceWorldId &&
              record.lessonId == intent.sourceLessonId &&
              record.taskId == intent.sourceTaskId &&
              record.sourceTaskId == intent.sourceTaskId &&
              record.choiceId == intent.choiceId &&
              record.isPlacementAssessment &&
              !record.isCorrect,
        )
        .toList(growable: false);
    if (history.length != 1 || evidence.length != 1) {
      return null;
    }
    final miss = history.single;
    final decision = evidence.single;
    if (decision.runId.isEmpty ||
        (decision.runOrdinal ?? 0) <= 0 ||
        decision.sessionId.isEmpty ||
        miss.runId != decision.runId ||
        miss.runOrdinal != decision.runOrdinal ||
        miss.expectedId != decision.expectedChoiceId ||
        miss.resultKind != decision.resultKind ||
        decision.authoredSourceFingerprint.isEmpty ||
        decision.authoredSourceFingerprint !=
            act0CurrentAuthoredSourceFingerprintForIdentityV1(
              worldId: intent.sourceWorldId,
              lessonId: intent.sourceLessonId,
              taskId: intent.sourceTaskId,
            )) {
      return null;
    }
    Act0RunnerStateV1? matched;
    for (var index = 0; index < _placementDiagnosticSpotsV1.length; index++) {
      final spot = _placementDiagnosticSpotsV1[index];
      if (spot.worldId != intent.sourceWorldId ||
          spot.lessonId != intent.sourceLessonId ||
          spot.taskId != intent.sourceTaskId) {
        continue;
      }
      final candidate = _diagnosticSourceForIdentityV1(
        worldId: intent.sourceWorldId,
        lessonId: intent.sourceLessonId,
        taskId: intent.sourceTaskId,
        diagnosticVariantId: spot.signalId,
      )?.runner;
      if (candidate == null) continue;
      final selected = candidate.options.where(
        (option) => option.id == decision.choiceId && !option.isCorrect,
      );
      final expected = candidate.options.where((option) => option.isCorrect);
      if (selected.length == 1 &&
          expected.length == 1 &&
          expected.single.id == decision.expectedChoiceId) {
        // Shared choices such as not_sure_yet cannot identify a diagnostic.
        // Both source-owned choice and expected answer must match uniquely.
        if (matched != null) {
          return null;
        }
        matched = candidate;
      }
    }
    return matched;
  }

  bool _hasValidatedRepairTargetV1(Act0RepairIntentV1 intent) =>
      act0RepairGoalResolutionForIntentV1(
        intent,
        learningEvidence: _learningEvidenceHistoryV1,
        currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      ).canLaunch;

  ({Act0LessonTaskV1 task, Act0RunnerStateV1 runner})?
  _diagnosticSourceForIdentityV1({
    required String worldId,
    required String lessonId,
    required String taskId,
    required String diagnosticVariantId,
  }) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final tasks = [
      for (final world in state.worlds)
        if (world.worldId == worldId)
          for (final lesson in world.lessons)
            if (lesson.lessonId == lessonId)
              for (final task in lesson.taskList)
                if (task.taskId == taskId) task,
    ];
    final indices = [
      for (var i = 0; i < _placementDiagnosticSpotsV1.length; i++)
        if (_placementDiagnosticSpotsV1[i].worldId == worldId &&
            _placementDiagnosticSpotsV1[i].lessonId == lessonId &&
            _placementDiagnosticSpotsV1[i].taskId == taskId &&
            _placementDiagnosticSpotsV1[i].signalId == diagnosticVariantId)
          i,
    ];
    if (tasks.length != 1 || indices.length != 1) return null;
    final runner = placementQuickCheckRunnerV1(
      normalizeAct0DrillSeatHighlightPolicyV1(
        normalizeAct0SeatTapRunnerV1(
          tasks.single.runner.copyWith(
            lessonId: lessonId,
            phase: Act0LessonPhaseV1.drill,
          ),
        ),
      ),
      signalId: diagnosticVariantId,
      checkIndex: indices.single + 1,
      checkCount: _placementDiagnosticSpotsV1.length,
      isRu: _isRuLocaleV1,
    );
    return (task: tasks.single, runner: runner);
  }

  Act0DiagnosticLearningEntryV1? _diagnosticLearningEntryForIntentV1(
    Act0RepairIntentV1 intent,
  ) => act0DiagnosticLearningEntryForIntentV1(
    intent,
    learningEvidence: _learningEvidenceHistoryV1,
    reviewMistakeHistory: _reviewMistakeHistoryV1,
    currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
    currentDiagnosticVariantFingerprint:
        _diagnosticVariantFingerprintForIdentityV1,
  );

  bool _startDiagnosticLearningEntryV1(Act0RepairIntentV1 intent) {
    final entry = _diagnosticLearningEntryForIntentV1(intent);
    if (entry == null) return false;
    final world = _worldById(
      (widget.state ?? Act0ShellStateV1.sample).worlds,
      entry.targetWorldId,
    );
    _startTaskByIds(
      world,
      entry.targetLessonId,
      entry.targetTaskId,
      allowDrillBypass: true,
      evidenceRunKind: act0DiagnosticLearningEntryRunKindV1,
      evidenceStartedBy: 'placement_learning_entry',
      diagnosticLearningEntry: entry,
    );
    return _diagnosticLearningEntryV1 == entry;
  }

  void _returnFromDiagnosticLearningEntryV1() {
    final selection = _diagnosticLearningReturnV1;
    _diagnosticLearningEntryV1 = null;
    _diagnosticLearningReturnV1 = null;
    if (selection != null) {
      _selectedWorldId = selection.worldId;
      _selectedLessonId = selection.lessonId;
      _selectedTaskId = selection.taskId;
    }
    _clearActiveRepairLaunchV1();
    _activeActionSequenceStageV1 = null;
    _activeSameSignalRecheckTaskId = null;
    _activeSameSignalRecheckSourceTaskId = null;
    _selectedOptionId = null;
    _phase = Act0LessonPhaseV1.theory;
    _teachingStepIndex = 0;
    _showPlayHub = true;
    _returnToPlayHubOnBack = false;
    _tab = Act0ShellTabV1.review;
    _persistProgress();
  }

  bool _hasValidatedRepairClosureV1(Act0RepairIntentV1 intent) =>
      Act0QueueResolutionStateV1.fromSources(
            activeRepairIntents: [intent],
            repairOutcomeProjection: _repairOutcomeProjectionV1,
            learningEvidenceHistory: _learningEvidenceHistoryV1,
            currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
          )
          .resolutionForQueueItemId(queueItemIdForAct0RepairIntentV1(intent))
          ?.resolutionState ==
      act0QueueResolutionStateResolvedV1;

  void _showHeldRepairNoticeV1() {
    // A restored entry may be checked during initState. Resolve inherited
    // presentation only after the first frame, and never after disposal.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(
          backgroundColor: Act0AcademyLeafPaletteV1.inkRaised,
          content: Text(
            'This mistake is saved. Its practice is on hold.',
            style: TextStyle(color: Act0AcademyLeafPaletteV1.text),
          ),
        ),
      );
    });
  }

  List<Act0RepairIntentV1> _activeRepairIntentsV1() {
    if (!_multiRepairQueueV1.hasItems) {
      return _multiRepairQueueOrderV1 == 0
          ? _openRepairIntentBySourceTaskId.values.toList(growable: false)
          : const <Act0RepairIntentV1>[];
    }
    final resolutionState = Act0QueueResolutionStateV1.fromSources(
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      activeRepairIntents: _multiRepairQueueV1.activeRepairIntents(),
      repairOutcomeProjection: _repairOutcomeProjectionV1,
    );
    return _multiRepairQueueV1.activeRepairIntents(
      resolutionState: resolutionState,
    );
  }

  Act0ReviewResolutionStateV1 _reviewResolutionStateV1() {
    return Act0ReviewResolutionStateV1.fromSources(
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      reviewMistakeHistory: _reviewMistakeHistoryV1,
      activeRepairIntents: _activeRepairIntentsV1(),
      repairOutcomeProjection: _repairOutcomeProjectionV1,
      receiptHistory: _reviewResolutionReceiptHistoryV1,
    );
  }

  Act0MistakeCardV1? _repeatedMistakeForReviewV1(
    Act0ReviewStateV1 review,
    Act0ReviewPatternCoachingProjectionV1 coaching,
  ) {
    for (final pattern in coaching.patterns) {
      if (!pattern.isRepeatedIndependentMiss ||
          pattern.patternState != act0ReviewPatternStateActiveV1) {
        continue;
      }
      for (final taskId in pattern.sourceTaskIds.reversed) {
        final mistake = review.mistakes
            .where((card) => card.taskId == taskId)
            .firstOrNull;
        if (mistake == null) continue;
        final target = _openRepairIntentTargetForSourceTaskV1(taskId);
        if (target != null &&
            target.intent.missedSignalId == pattern.conceptFamilyId &&
            target.intent.errorType == pattern.errorType) {
          return mistake;
        }
      }
    }
    return null;
  }

  Act0ReviewPatternCoachingProjectionV1 _reviewPatternCoachingProjectionV1() {
    final now = widget.clock.nowUtc();
    return Act0ReviewPatternCoachingProjectionV1.fromSources(
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      nowUtc: now,
      reviewMistakeHistory: _reviewMistakeHistoryV1,
      reviewResolutionState: _reviewResolutionStateV1(),
      activeRepairIntents: _activeRepairIntentsV1(),
      repairOutcomeProjection: _repairOutcomeProjectionV1,
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(
            _learningEvidenceHistoryV1,
            // Scheduling cache remains historical; current proof is replayed.
            nowUtc: now,
          ),
    );
  }

  Act0FixProofProjectionV1 _fixProofProjectionV1() {
    return Act0FixProofProjectionV1.fromSources(
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      repairIntents: _activeRepairIntentsV1(),
      repairOutcomeProjection: _repairOutcomeProjectionV1,
      reviewResolutionReceiptHistory: _reviewResolutionReceiptHistoryV1,
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(
            _learningEvidenceHistoryV1,
            // Scheduling cache remains historical; current proof is replayed.
            nowUtc: widget.clock.nowUtc(),
          ),
    );
  }

  Act0SharkyImprovementObservationProjectionV1
  _sharkyImprovementObservationProjectionV1() {
    return Act0SharkyImprovementObservationProjectionV1.fromFixProof(
      _fixProofProjectionV1(),
      completedSessionId:
          _sessionIdentityStateV1.currentOrLatestSession?.sessionId ?? '',
    );
  }

  void _syncOpenRepairIntentIndexFromQueueV1() {
    _openRepairIntentBySourceTaskId
      ..clear()
      ..addEntries(
        _activeRepairIntentsV1().map(
          (intent) =>
              MapEntry<String, Act0RepairIntentV1>(intent.sourceTaskId, intent),
        ),
      );
  }

  void _pruneMultiRepairQueueWithResolutionV1() {
    final resolutionState = Act0QueueResolutionStateV1.fromSources(
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      activeRepairIntents: _multiRepairQueueV1.activeRepairIntents(),
      repairOutcomeProjection: _repairOutcomeProjectionV1,
    );
    _multiRepairQueueV1 = _multiRepairQueueV1.prunedWithResolution(
      resolutionState,
    );
  }

  void _ensureDailyCountDayV1() {
    final today = _todayDateString();
    if (_dailyRepCountDay == today) return;
    _dailyCompletedRepCount = 0;
    _dailyCompletedTaskIds.clear();
    _dailyPracticeQueue = const Act0DailyPracticeQueueV1();
    _dailyRepCountDay = today;
  }

  int _earnedStreakDaysTodayV1(String today) {
    final earnedToday = _lastDailyDate == today;
    final earnedYesterday = act0AreConsecutiveCivilDaysV1(
      _lastDailyDate,
      today,
    );
    if (_dailyRepCountDay == today && _dailyCompletedRepCount >= 3) {
      if (earnedToday) return _persistedStreakDays.clamp(1, 365);
      return earnedYesterday && _persistedStreakDays > 0
          ? (_persistedStreakDays + 1).clamp(0, 365)
          : 1;
    }
    return earnedToday || earnedYesterday ? _persistedStreakDays : 0;
  }

  void _persistProgress({Completer<bool>? acknowledgement}) {
    if (!_usesPersistedProgress ||
        _recoveryBusyV1 ||
        _progressLoadFailed ||
        !_progressRestoredV1) {
      acknowledgement?.complete(false);
      return;
    }
    _ensureDailyCountDayV1();
    final today = _todayDateString();
    final dailyDone = _dailyCompletedRepCount >= 3;
    final currentStreak = _earnedStreakDaysTodayV1(today);
    if (dailyDone) _lastDailyDate = today;
    _persistedStreakDays = currentStreak;
    final returnSelection =
        _diagnosticLearningReturnV1 ?? _spacedReviewReturnV1;
    final snapshot = _Act0PersistedProgressV1(
      suppressLegacyRecheckAfterRecovery: _suppressLegacyRecheckAfterRecoveryV1,
      completedTaskIds: _completedTaskIds,
      skippedTaskIds: _skippedTaskIds,
      completedLessonIds: _completedLessonIds,
      selectedWorldId: returnSelection?.worldId ?? _selectedWorldId,
      selectedLessonId: returnSelection?.lessonId ?? _selectedLessonId,
      selectedTaskId: returnSelection?.taskId ?? _selectedTaskId,
      earnedXp: _earnedXp,
      w1StartChosen: _w1StartChosenV1,
      w1RulesBestScore: _w1RulesBestScoreV1,
      w1RulesFocusTaskIds: _w1RulesFocusTaskIdsV1,
      profileSkillValues: _profileSkillValues,
      recentSkillGains: _recentSkillGains,
      lastActiveDay: today,
      lastEarnedDailyDay: _lastDailyDate,
      dailyCompletedRepCount: _dailyCompletedRepCount,
      dailyPracticeQueue: _dailyPracticeQueue,
      dailyCompletedTaskIds: _dailyCompletedTaskIds,
      persistedStreakDays: currentStreak,
      retentionSequence: _retentionSequence,
      retentionMemory: _retentionMemoryByTaskId.values.toList(growable: false),
      openRepairIntents: _activeRepairIntentsV1(),
      multiRepairQueue: _multiRepairQueueV1,
      multiRepairQueueOrder: _multiRepairQueueOrderV1,
      resumeInRunner:
          returnSelection == null &&
          _tab == Act0ShellTabV1.play &&
          !_showPlayHub &&
          _blockCompletionSummary == null &&
          !_showPlacement,
      resumePhase: returnSelection == null ? _phase.name : 'theory',
      resumeTeachingStepIndex: returnSelection == null ? _teachingStepIndex : 0,
      resumeSelectedOptionId: returnSelection == null
          ? _selectedOptionId
          : null,
      dismissedHomeHandoffKey: _dismissedHomeHandoffKey,
      dismissedHomeHandoffDay: _dismissedHomeHandoffDay,
      firstValueReturnCarry: _firstValueReceiptCarry,
      learningEvidenceHistory: _learningEvidenceHistoryV1,
      studyObservations: _studyObservationsV1,
      practiceDayKeys: _savedPracticeDaysV1,
      pendingDecisionAssistance: List.unmodifiable(
        _pendingDecisionAssistanceV1.values,
      ),
      lessonRunEvidenceBoundaries: Map<String, int?>.from(
        _lessonRunEvidenceBoundariesV1,
      ),
      openedSpacedReviewTaskIds: Set.unmodifiable(_openedSpacedReviewTaskIdsV1),
      durableRetentionHistory: _durableRetentionHistoryV1.refreshedAt(
        widget.clock.nowUtc(),
      ),
      reviewMistakeHistory: _reviewMistakeHistoryV1,
      reviewResolutionReceiptHistory: _reviewResolutionReceiptHistoryV1,
      conceptFamilyStateHistory: _conceptFamilyStateHistoryV1,
      sessionIdentityState: _sessionIdentityStateV1,
      repairOutcomeProjection: _repairOutcomeProjectionV1,
      lastSessionLearnerState: _lastSessionLearnerStateV1,
    );
    final generation = ++_progressPersistGeneration;
    // Capture attribution alongside the bytes, never from a newer route after
    // the asynchronous save. Empty session explicitly means unknown.
    final diagnosticContext = Map<String, Object?>.unmodifiable({
      'schemaVersion': 1,
      'operation': 'save',
      'request_generation': generation,
      'world_id': _selectedWorldId,
      'lesson_id': _selectedLessonId,
      'task_id': _selectedTaskId,
      'session_id': _sessionIdentityStateV1.currentActiveSessionId,
      'source_surface': 'act0_progress_store',
    });
    // Capture bytes, store and recovery epoch before yielding. A late save may
    // acknowledge its own bytes without acknowledging the latest live snapshot.
    final store = _progressStore;
    final epoch = _recoveryEpochV1;
    unawaited(
      _writePersistedProgress(
        snapshot.toStorageString(),
        generation,
        diagnosticContext,
        store,
        epoch,
      ).then<void>(
        (saved) {
          acknowledgement?.complete(saved);
        },
        onError: (Object _, StackTrace __) {
          _setProgressSaveStatusV1(
            _Act0ProgressSaveStatusV1.unconfirmed,
            generation,
            store,
            epoch,
          );
          acknowledgement?.complete(false);
        },
      ),
    );
  }

  Future<bool> _writePersistedProgress(
    String snapshot,
    int generation,
    Map<String, Object?> diagnosticContext,
    Act0ProgressStoreV1 store,
    int epoch,
  ) async {
    await Future<void>.value();
    if (generation != _progressPersistGeneration ||
        epoch != _recoveryEpochV1 ||
        !identical(store, _progressStore) ||
        _recoveryBusyV1 ||
        _progressLoadFailed ||
        !_progressRestoredV1) {
      return false; // Coalesced requests have no durable acknowledgement.
    }
    _setProgressSaveStatusV1(
      _Act0ProgressSaveStatusV1.saving,
      generation,
      store,
      epoch,
    );
    final acknowledged = await store.save(snapshot);
    // False is indeterminate, never proof of data loss or an OS-level cause.
    _recordTelemetryEventV1('progress_persist_result', <String, Object?>{
      ...diagnosticContext,
      'outcome': acknowledged ? 'acknowledged' : 'indeterminate',
    });
    final currentAcknowledgement = acknowledged && store.isWriteLeaseCurrent;
    _setProgressSaveStatusV1(
      currentAcknowledgement
          ? _Act0ProgressSaveStatusV1.idle
          : _Act0ProgressSaveStatusV1.unconfirmed,
      generation,
      store,
      epoch,
    );
    return currentAcknowledgement &&
        generation == _progressPersistGeneration &&
        epoch == _recoveryEpochV1 &&
        identical(store, _progressStore);
  }

  void _setProgressSaveStatusV1(
    _Act0ProgressSaveStatusV1 status,
    int generation,
    Act0ProgressStoreV1 store,
    int epoch,
  ) {
    if (!_progressSaveStatusDisposedV1 &&
        mounted &&
        generation == _progressPersistGeneration &&
        epoch == _recoveryEpochV1 &&
        identical(store, _progressStore) &&
        !_recoveryBusyV1 &&
        !_progressLoadFailed &&
        _progressRestoredV1) {
      _progressSaveStatusV1.value = status;
    }
  }

  Widget _progressSaveNoticeV1() {
    final epoch = _recoveryEpochV1;
    final store = _progressStore;
    return ValueListenableBuilder(
      valueListenable: _progressSaveStatusV1,
      builder: (context, status, _) {
        if (status == _Act0ProgressSaveStatusV1.idle) {
          return const SizedBox.shrink();
        }
        final saving = status == _Act0ProgressSaveStatusV1.saving;
        return Material(
          key: const Key('act0_progress_save_notice'),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      saving
                          ? 'Saving progress. Keep Sharky open.'
                          : 'Progress save not confirmed. Keep Sharky open and retry.',
                    ),
                  ),
                ),
                if (!saving)
                  TextButton(
                    key: const Key('act0_progress_save_retry'),
                    // Rebuild the full current snapshot. Never replay an old
                    // answer, completion or cached failed payload.
                    onPressed: () {
                      if (_acceptRecoveryCallbackV1(epoch) &&
                          identical(store, _progressStore)) {
                        _persistProgress();
                      }
                    },
                    child: const Text('Retry save'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _appendLearningEvidenceV1(
    Act0CompletedDecisionV1 decision, {
    String repairOccurrenceId = '',
  }) {
    final recordedAtUtc = widget.clock.nowUtc();
    final reviewKind = _reviewKindForDecisionV1(decision);
    final hadCanonicalRecord = _learningEvidenceHistoryV1.provenanceRecords.any(
      (record) => record.recordId == decision.attemptKey,
    );
    final wasAlreadyRecorded = _learningEvidenceHistoryV1.records.any(
      (record) => record.recordId == decision.attemptKey,
    );
    _learningEvidenceHistoryV1 = _learningEvidenceHistoryV1
        .appendCompletedDecision(
          decision,
          authoredSourceFingerprint:
              act0CurrentAuthoredSourceFingerprintForIdentityV1(
                worldId: decision.worldId ?? '',
                lessonId: decision.lessonId,
                taskId: decision.taskId,
              ) ??
              '',
          runKey: _activeLearningEvidenceRunKeyV1,
          sessionId: _sessionIdentityStateV1.currentActiveSessionId,
          recordedAtUtc: recordedAtUtc,
          reviewKind: reviewKind,
        );
    if (!hadCanonicalRecord &&
        _learningEvidenceHistoryV1.provenanceRecords.any(
          (record) => record.recordId == decision.attemptKey,
        )) {
      // Consume with the appended decision in the SAME durable snapshot.
      // A rejected/duplicate append must not erase ungraded assistance.
      _pendingDecisionAssistanceV1.remove(
        jsonEncode([
          decision.worldId ?? '',
          decision.lessonId,
          decision.taskId,
        ]),
      );
    }
    if (_diagnosticLearningEntryV1 != null) {
      _pendingReviewKindV1 = null;
      return;
    }
    _reviewMistakeHistoryV1 = _reviewMistakeHistoryV1.appendCompletedDecision(
      decision,
      repairOccurrenceId: repairOccurrenceId,
      runId: _activeLearningEvidenceRunKeyV1?.runId ?? '',
      runKind: _activeLearningEvidenceRunKeyV1?.runKind ?? '',
      runOrdinal: _activeLearningEvidenceRunKeyV1?.runOrdinal,
    );
    final latestRecord = _learningEvidenceHistoryV1.records
        .cast<Act0LearningEvidenceRecordV1?>()
        .lastWhere(
          (record) => record?.recordId == decision.attemptKey,
          orElse: () => null,
        );
    if (latestRecord != null && !wasAlreadyRecorded) {
      final day = latestRecord.localPracticeDayKey;
      if (day != null && !_savedPracticeDaysV1.contains(day)) {
        final days = [..._savedPracticeDaysV1, day]
          ..sort((a, b) => b.compareTo(a));
        _savedPracticeDaysV1 = days
            .take(Act0LearningEvidenceHistoryV1.maxStoredPracticeDays)
            .toList(growable: false);
      }
      if (_activePracticeGroupId == 'daily') _ensureDailyCountDayV1();
      if (_activePracticeGroupId == 'daily' &&
          latestRecord.runKind == 'practice' &&
          _dailyPracticeQueue.nextTaskId == latestRecord.taskId) {
        _dailyPracticeQueue = _dailyPracticeQueue.answer(
          latestRecord.taskId,
          independentCorrect: latestRecord.isIndependentCorrect,
        );
        _dailyCompletedTaskIds.add(latestRecord.taskId);
        _dailyCompletedRepCount = (_dailyCompletedRepCount + 1).clamp(0, 3);
      }
      _conceptFamilyStateHistoryV1 = _conceptFamilyStateHistoryV1
          .appendLearningEvidence(latestRecord);
      _durableRetentionHistoryV1 = _durableRetentionHistoryV1
          .applyEvidence(latestRecord)
          .refreshedAt(recordedAtUtc);
      if (widget.telemetrySink != null) {
        try {
          for (final event in act0EvidenceTelemetryEventsV1(
            record: latestRecord,
            history: _learningEvidenceHistoryV1,
            nowUtc: recordedAtUtc,
            repairOccurrenceId: repairOccurrenceId,
            actionState: _actionPersonalizationStateV1,
            actionStage: _activeActionSequenceStageV1,
          )) {
            _recordTelemetryEventV1(event.name, event.fields);
          }
        } catch (_) {
          // Diagnostics never interrupt accepted source evidence or progress.
        }
      }
    }
    _pendingReviewKindV1 = null;
  }
}
