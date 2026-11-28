part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewLearningRunV1 on _Act0ShellPreviewScreenV1State {
  Act0ReviewKindV1 _reviewKindForDecisionV1(Act0CompletedDecisionV1 decision) {
    // This is a first graded observation of the teaching target. The explicit
    // guided run kind excludes proof; never infer unseen transfer from it.
    if (_diagnosticLearningEntryV1 != null) {
      return Act0ReviewKindV1.initialAssessment;
    }
    if (_pendingReviewKindV1 == Act0ReviewKindV1.unseenTransfer) {
      return decision.assistanceKind == Act0DecisionAssistanceV1.none
          ? Act0ReviewKindV1.unseenTransfer
          : Act0ReviewKindV1.spacedReview;
    }
    final routed = _routeReviewKindForTaskIdV1(decision.taskId);
    if (routed != Act0ReviewKindV1.initialAssessment &&
        routed != Act0ReviewKindV1.unseenTransfer) {
      return routed;
    }
    // A placement diagnostic answer is itself the initial assessment.
    if (_activeLearningEvidenceRunKeyV1?.runKind ==
        act0PlacementAssessmentRunKindV1) {
      return Act0ReviewKindV1.initialAssessment;
    }
    // Guided exposure is not prior proof, but seeing this exact current
    // question makes a later ordinary attempt familiar rather than unseen.
    final currentFingerprint = _repairFingerprintForIdentityV1(
      worldId: decision.worldId ?? '',
      lessonId: decision.lessonId,
      taskId: decision.taskId,
    );
    if (currentFingerprint != null &&
        currentFingerprint.isNotEmpty &&
        _learningEvidenceHistoryV1.provenanceRecords.any(
          (record) =>
              record.isDiagnosticLearningEntry &&
              record.worldId == decision.worldId &&
              record.lessonId == decision.lessonId &&
              record.taskId == decision.taskId &&
              record.sourceTaskId == decision.taskId &&
              record.authoredSourceFingerprint == currentFingerprint,
        )) {
      return Act0ReviewKindV1.exactReplay;
    }
    final prior = _learningEvidenceHistoryV1.provenanceRecords.where(
      (r) => !r.isPlacementAssessment && !r.isDiagnosticLearningEntry,
    );
    if (_completedTaskIds.contains(decision.taskId) ||
        prior.any((r) => r.taskId == decision.taskId)) {
      return Act0ReviewKindV1.exactReplay;
    }
    if (!_learningEvidenceHistoryV1.hasCompleteLineage)
      return Act0ReviewKindV1.legacyUnspaced;
    if (routed == Act0ReviewKindV1.unseenTransfer) return routed;
    final conceptFamilyId =
        <String?>[
              decision.conceptFamilyId,
              decision.repairFocusId,
              decision.skillAtomId,
              decision.errorType,
            ]
            .map((value) => value?.trim() ?? '')
            .firstWhere(
              (value) => value.isNotEmpty && value != 'none',
              orElse: () => '',
            );
    if (conceptFamilyId.isNotEmpty) {
      // A placement diagnostic answer is assessment, not earlier learning.
      final priorFamilyRecords = _learningEvidenceHistoryV1.provenanceRecords
          .where(
            (record) =>
                !record.isPlacementAssessment &&
                !record.isDiagnosticLearningEntry &&
                act0ConceptFamilyIdForDurableEvidenceV1(record) ==
                    conceptFamilyId,
          );
      if (priorFamilyRecords.isNotEmpty &&
          priorFamilyRecords.every(
            (record) => record.taskId != decision.taskId,
          )) {
        return Act0ReviewKindV1.unseenTransfer;
      }
    }
    return Act0ReviewKindV1.initialAssessment;
  }

  Act0ReviewKindV1 _routeReviewKindForTaskIdV1(String rawTaskId) {
    final pending = _pendingReviewKindV1;
    if (pending != null) {
      return pending;
    }
    final taskId = rawTaskId.trim();
    final sourceTaskId = _activeRepairSourceTaskId?.trim() ?? '';
    if (_activeRepairTaskId == taskId) {
      if (sourceTaskId.isEmpty || sourceTaskId == taskId) {
        return Act0ReviewKindV1.exactReplay;
      }
      return Act0ReviewKindV1.alternateSameSignal;
    }
    final request = _practiceQueueRepairRequestForTaskV1(taskId);
    if (request != null) {
      return request.sourceTaskId == request.repairTaskId
          ? Act0ReviewKindV1.exactReplay
          : Act0ReviewKindV1.alternateSameSignal;
    }
    if (_activeSameSignalRecheckTaskId == taskId) {
      return Act0ReviewKindV1.originalSourceRecheck;
    }
    return Act0ReviewKindV1.initialAssessment;
  }

  void _recordLearningRunDecisionV1(Act0CompletedDecisionV1 decision) {
    if (_diagnosticLearningEntryV1 != null) return;
    if (!_learningRunLearnVisitActiveV1) {
      return;
    }
    if (decision.taskId == act0ActionLearningSequenceV1.practiceTaskId) {
      final outcomes = _actionPersonalizationStateV1.outcomes;
      if (outcomes.isEmpty) {
        return;
      }
      final first = outcomes.first;
      final sawFailedRecheck = outcomes.any(
        (outcome) =>
            outcome.stage == Act0ActionSequenceStageV1.recheck &&
            !outcome.isCorrect,
      );
      final finalOutcome = first.isCorrect
          ? Act0LearningRunFinalOutcomeV1.masteredFirstTry
          : _actionPersonalizationStateV1.recheckSucceeded
          ? Act0LearningRunFinalOutcomeV1.recoveredAfterRepair
          : sawFailedRecheck
          ? Act0LearningRunFinalOutcomeV1.stillNeedsPractice
          : Act0LearningRunFinalOutcomeV1.incomplete;
      _recordLearningRunOutcomeV1(
        Act0LearningRunOutcomeV1(
          outcomeId: 'action:${first.attemptKey}',
          lessonId: decision.lessonId,
          taskId: decision.taskId,
          skillId: 'action_read',
          firstAttemptCorrect: first.isCorrect,
          errorType: first.isCorrect
              ? 'none'
              : act0ActionLearningSequenceV1.repairErrorType,
          repairAttempted:
              _actionPersonalizationStateV1.repairSucceeded ||
              _actionPersonalizationStateV1.hasRepairFailure,
          recheckResult: _actionPersonalizationStateV1.recheckSucceeded
              ? true
              : sawFailedRecheck
              ? false
              : null,
          finalOutcome: finalOutcome,
          missedSignal: 'no_bet_yet',
          recommendationSignal: 'read_action_order',
          eventOrder: _nextLearningRunEventOrderV1(),
        ),
        userChoice: decision.selectedId,
        timeToDecision: decision.decisionTimeBucket,
      );
      return;
    }
    if (Act0StartingHandPersonalizationV1.isCanonicalSourceTask(
      decision.taskId,
    )) {
      if (_routeReviewKindForTaskIdV1(decision.taskId) !=
          Act0ReviewKindV1.initialAssessment) {
        return;
      }
      _recordLearningRunOutcomeV1(
        Act0LearningRunOutcomeV1(
          outcomeId: 'starting_hand:${decision.attemptKey}',
          lessonId: decision.lessonId,
          taskId: decision.taskId,
          skillId: Act0StartingHandPersonalizationV1.skillId,
          firstAttemptCorrect: decision.isCorrect,
          errorType: decision.isCorrect
              ? 'none'
              : Act0StartingHandPersonalizationV1.errorType,
          repairAttempted: false,
          recheckResult: null,
          finalOutcome: decision.isCorrect
              ? Act0LearningRunFinalOutcomeV1.masteredFirstTry
              : Act0LearningRunFinalOutcomeV1.incomplete,
          missedSignal: Act0StartingHandPersonalizationV1.missedSignalId,
          recommendationSignal: 'compare_seat_and_action_frame',
          eventOrder: _nextLearningRunEventOrderV1(),
        ),
        userChoice: decision.selectedId,
        timeToDecision: decision.decisionTimeBucket,
      );
      return;
    }
    if (Act0BoardTexturePersonalizationV1.isCanonicalSourceTask(
      decision.taskId,
    )) {
      if (_routeReviewKindForTaskIdV1(decision.taskId) !=
          Act0ReviewKindV1.initialAssessment)
        return;
      _recordLearningRunOutcomeV1(
        Act0LearningRunOutcomeV1(
          outcomeId: 'board_texture:${decision.attemptKey}',
          lessonId: decision.lessonId,
          taskId: decision.taskId,
          skillId: Act0BoardTexturePersonalizationV1.skillId,
          firstAttemptCorrect: decision.isCorrect,
          errorType: decision.isCorrect
              ? 'none'
              : Act0BoardTexturePersonalizationV1.errorType,
          repairAttempted: false,
          recheckResult: null,
          finalOutcome: decision.isCorrect
              ? Act0LearningRunFinalOutcomeV1.masteredFirstTry
              : Act0LearningRunFinalOutcomeV1.incomplete,
          missedSignal: Act0BoardTexturePersonalizationV1.missedSignalId,
          recommendationSignal: 'compare_board_connection',
          eventOrder: _nextLearningRunEventOrderV1(),
        ),
        userChoice: decision.selectedId,
        timeToDecision: decision.decisionTimeBucket,
      );
      return;
    }
    if (!Act0PositionPersonalizationV1.isCanonicalSourceTask(decision.taskId)) {
      if (!Act0PricePersonalizationV1.isCanonicalSourceTask(decision.taskId)) {
        return;
      }
      _recordLearningRunOutcomeV1(
        Act0LearningRunOutcomeV1(
          outcomeId: 'price:${decision.attemptKey}',
          lessonId: decision.lessonId,
          taskId: decision.taskId,
          skillId: Act0PricePersonalizationV1.skillId,
          firstAttemptCorrect: decision.isCorrect,
          errorType: decision.isCorrect
              ? 'none'
              : Act0PricePersonalizationV1.errorType,
          repairAttempted: false,
          recheckResult: null,
          finalOutcome: decision.isCorrect
              ? Act0LearningRunFinalOutcomeV1.masteredFirstTry
              : Act0LearningRunFinalOutcomeV1.incomplete,
          missedSignal: Act0PricePersonalizationV1.missedSignalId,
          recommendationSignal: 'compare_pot_to_call',
          eventOrder: _nextLearningRunEventOrderV1(),
        ),
        userChoice: decision.selectedId,
        timeToDecision: decision.decisionTimeBucket,
      );
      return;
    }
    _recordLearningRunOutcomeV1(
      Act0LearningRunOutcomeV1(
        outcomeId: 'position:${decision.attemptKey}',
        lessonId: decision.lessonId,
        taskId: decision.taskId,
        skillId: Act0PositionPersonalizationV1.skillId,
        firstAttemptCorrect: decision.isCorrect,
        errorType: decision.isCorrect
            ? 'none'
            : Act0PositionPersonalizationV1.errorType,
        repairAttempted: false,
        recheckResult: null,
        finalOutcome: decision.isCorrect
            ? Act0LearningRunFinalOutcomeV1.masteredFirstTry
            : Act0LearningRunFinalOutcomeV1.incomplete,
        missedSignal: Act0PositionPersonalizationV1.missedSignalId,
        recommendationSignal: 'find_button_before_late_position',
        eventOrder: _nextLearningRunEventOrderV1(),
      ),
      userChoice: decision.selectedId,
      timeToDecision: decision.decisionTimeBucket,
    );
  }

  Act0LearningRunOutcomeV1? _recordLearningRunSourceRecheckV1({
    required String sourceTaskId,
    required bool recheckCorrect,
  }) {
    final run = _learningRunV1;
    if (run == null) {
      return null;
    }
    final normalizedSourceTaskId = sourceTaskId.trim();
    if (normalizedSourceTaskId.isEmpty) {
      return null;
    }
    Act0LearningRunOutcomeV1? source;
    for (final outcome in run.outcomes.reversed) {
      if (outcome.taskId == normalizedSourceTaskId &&
          !outcome.firstAttemptCorrect &&
          outcome.finalOutcome == Act0LearningRunFinalOutcomeV1.incomplete) {
        source = outcome;
        break;
      }
    }
    if (source == null || source.firstAttemptCorrect) {
      return null;
    }
    final finalized = Act0LearningRunOutcomeV1(
      outcomeId: source.outcomeId,
      lessonId: source.lessonId,
      taskId: source.taskId,
      skillId: source.skillId,
      firstAttemptCorrect: false,
      errorType: source.errorType,
      repairAttempted: true,
      recheckResult: recheckCorrect,
      finalOutcome: recheckCorrect
          ? Act0LearningRunFinalOutcomeV1.recoveredAfterRepair
          : Act0LearningRunFinalOutcomeV1.stillNeedsPractice,
      missedSignal: source.missedSignal,
      recommendationSignal: source.recommendationSignal,
      eventOrder: _nextLearningRunEventOrderV1(),
    );
    _recordLearningRunOutcomeV1(finalized);
    return finalized;
  }

  void _emitPersonalizationFamilySourceRecheckTelemetryV1({
    required Act0LearningRunOutcomeV1 finalized,
  }) {
    final sourceTaskId = finalized.taskId;
    final recheckCorrect = finalized.recheckResult == true;
    if (sourceTaskId == Act0PositionPersonalizationV1.sourceTaskId) {
      const family = Act0PositionPersonalizationCaseV1();
      _recordTelemetryEventV1(
        'position_personalization_recheck',
        family.telemetryFields(
          attemptPhase: 'recheck',
          finalLearningOutcome: recheckCorrect
              ? family.successfulPayoffOutcome
              : family.failedRecheckOutcome,
        ),
      );
      if (recheckCorrect) {
        _recordTelemetryEventV1(
          'position_personalization_payoff',
          family.telemetryFields(
            attemptPhase: 'payoff',
            finalLearningOutcome: family.successfulPayoffOutcome,
          ),
        );
      }
      return;
    }
    if (sourceTaskId == Act0PricePersonalizationV1.sourceTaskId) {
      const family = Act0PricePersonalizationCaseV1();
      _recordTelemetryEventV1(
        'price_personalization_recheck',
        family.telemetryFields(
          attemptPhase: 'recheck',
          finalLearningOutcome: recheckCorrect
              ? family.successfulPayoffOutcome
              : family.failedRecheckOutcome,
        ),
      );
      if (recheckCorrect) {
        _recordTelemetryEventV1(
          'price_personalization_payoff',
          family.telemetryFields(
            attemptPhase: 'payoff',
            finalLearningOutcome: family.successfulPayoffOutcome,
          ),
        );
      }
      return;
    }
    if (sourceTaskId == Act0StartingHandPersonalizationV1.sourceTaskId) {
      const family = Act0StartingHandPersonalizationCaseV1();
      _recordTelemetryEventV1(
        'starting_hand_personalization_recheck',
        family.telemetryFields(
          attemptPhase: 'recheck',
          finalLearningOutcome: recheckCorrect
              ? family.successfulPayoffOutcome
              : family.failedRecheckOutcome,
        ),
      );
      if (recheckCorrect) {
        _recordTelemetryEventV1(
          'starting_hand_personalization_payoff',
          family.telemetryFields(
            attemptPhase: 'payoff',
            finalLearningOutcome: family.successfulPayoffOutcome,
          ),
        );
      }
      return;
    }
    if (sourceTaskId == Act0BoardTexturePersonalizationV1.sourceTaskId) {
      const family = Act0BoardTexturePersonalizationCaseV1();
      _recordTelemetryEventV1(
        'board_texture_personalization_recheck',
        family.telemetryFields(
          attemptPhase: 'recheck',
          finalLearningOutcome: recheckCorrect
              ? family.successfulPayoffOutcome
              : family.failedRecheckOutcome,
        ),
      );
      if (recheckCorrect)
        _recordTelemetryEventV1(
          'board_texture_personalization_payoff',
          family.telemetryFields(
            attemptPhase: 'payoff',
            finalLearningOutcome: family.successfulPayoffOutcome,
          ),
        );
    }
  }

  int _nextLearningRunEventOrderV1() => ++_learningRunEventOrderV1;

  bool _activeLearningRunContainsRepairSourceV1(String sourceTaskId) {
    final run = _learningRunV1;
    final normalizedSourceTaskId = sourceTaskId.trim();
    if (run == null || normalizedSourceTaskId.isEmpty) {
      return false;
    }
    return run.outcomes.any(
      (outcome) => outcome.taskId == normalizedSourceTaskId,
    );
  }

  bool _hasMatchingLearningRunRepairIntentV1() {
    if (_learningRunV1 == null) {
      return false;
    }
    return _openRepairIntentBySourceTaskId.values.any(
      (intent) => _activeLearningRunContainsRepairSourceV1(intent.sourceTaskId),
    );
  }

  bool _shouldPreserveLearningRunForRepairBridgeV1({
    required Act0ShellTabV1 currentTab,
    required Act0ShellTabV1 requestedTab,
    String requestedRepairSourceTaskId = '',
  }) {
    if (_learningRunV1 == null || requestedTab != Act0ShellTabV1.play) {
      return false;
    }
    final sourceTaskId = requestedRepairSourceTaskId.trim();
    if (sourceTaskId.isNotEmpty) {
      final intent = _openRepairIntentBySourceTaskId[sourceTaskId];
      return intent != null &&
          _activeLearningRunContainsRepairSourceV1(intent.sourceTaskId);
    }
    return currentTab == Act0ShellTabV1.learn &&
        _hasMatchingLearningRunRepairIntentV1();
  }

  void _recordLearningRunOutcomeV1(
    Act0LearningRunOutcomeV1 outcome, {
    String userChoice = '',
    String timeToDecision = '',
  }) {
    var run = _learningRunV1;
    if (run == null) {
      run = Act0LearningRunStateV1(
        runId: 'learning_run_v1|${++_learningRunOrdinalV1}',
        startedAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
      );
      _learningRunOutcomeTelemetryKeysV1.clear();
      _recordTelemetryEventV1('learning_run_started', <String, Object?>{
        'schemaVersion': 1,
        'run_id': run.runId,
        'source_surface': 'act0_learn',
      });
    }
    final next = run.record(outcome);
    _learningRunV1 = next;
    // Canonical repair-bridge incomplete observations remain internal so a
    // matching Practice repair projects one normalized terminal row. Other
    // families retain their existing telemetry contract.
    final terminalOnlyRepairBridge =
        outcome.skillId == Act0PositionPersonalizationV1.skillId ||
        outcome.skillId == Act0PricePersonalizationV1.skillId ||
        outcome.skillId == Act0StartingHandPersonalizationV1.skillId ||
        outcome.skillId == Act0BoardTexturePersonalizationV1.skillId;
    if (!outcome.isMeaningful &&
        terminalOnlyRepairBridge &&
        !_learningRunProductionLearnVisitV1) {
      return;
    }
    // A production Learn visit records its source observation immediately.
    // Its recheck replaces the same run outcome in state, so it must not emit
    // a second source-outcome row for the same attempt.
    final telemetryKey = '${next.runId}|${outcome.outcomeId}';
    if (!_learningRunOutcomeTelemetryKeysV1.add(telemetryKey)) {
      return;
    }
    final fields = <String, Object?>{
      'schemaVersion': 1,
      'run_id': next.runId,
      'lesson_id': outcome.lessonId,
      'task_id': outcome.taskId,
      'skill_id': outcome.skillId,
      'outcome_type': outcome.finalOutcome.name,
      'error_type': outcome.errorType,
      'repair_attempted': outcome.repairAttempted,
      if (outcome.recheckResult != null)
        'recheck_result': outcome.recheckResult,
      'missed_signal': outcome.missedSignal,
      'recommendation_signal': outcome.recommendationSignal,
      'event_order': outcome.eventOrder,
      'meaningful_outcome_count': next.meaningfulAttemptCount,
      if (userChoice.isNotEmpty) 'user_choice': userChoice,
      if (timeToDecision.isNotEmpty) 'time_to_decision_bucket': timeToDecision,
    };
    _recordTelemetryEventV1('learning_run_outcome_recorded', fields);
    _recordTelemetryEventV1('session_skill_outcome', fields);
  }

  void _closeLearningRunForLearnExitV1() {
    final active = _learningRunV1;
    if (active == null) {
      _learningRunLearnVisitActiveV1 = false;
      _learningRunProductionLearnVisitV1 = false;
      return;
    }
    final closed = active.close(
      reason: 'explicit_learn_to_home',
      finalizedAtMilliseconds: DateTime.now().millisecondsSinceEpoch,
    );
    final payoff = Act0LearningRunPayoffPolicyV1.evaluate(closed);
    if (payoff != null) {
      _recordTelemetryEventV1('learning_run_payoff_eligible', <String, Object?>{
        'schemaVersion': 1,
        'run_id': closed.runId,
        'meaningful_outcome_count': closed.meaningfulAttemptCount,
      });
    }
    _recordTelemetryEventV1('learning_run_closed', <String, Object?>{
      'schemaVersion': 1,
      'run_id': closed.runId,
      'closure_reason': closed.closureReason,
      'meaningful_outcome_count': closed.meaningfulAttemptCount,
      'elapsed_run_ms':
          closed.finalizedAtMilliseconds! - closed.startedAtMilliseconds,
      'payoff_eligible': payoff != null,
    });
    if (payoff == null) {
      _recordTelemetryEventV1(
        'session_payoff_skipped_insufficient_evidence',
        <String, Object?>{
          'schemaVersion': 1,
          'run_id': closed.runId,
          'meaningful_outcome_count': closed.meaningfulAttemptCount,
          'closure_reason': closed.closureReason,
        },
      );
      _learningRunV1 = null;
      _learningRunLearnVisitActiveV1 = false;
      _learningRunProductionLearnVisitV1 = false;
      return;
    }
    _recordTelemetryEventV1('session_payoff_generated', <String, Object?>{
      'schemaVersion': 1,
      'run_id': closed.runId,
      'closure_reason': closed.closureReason,
      'meaningful_outcome_count': closed.meaningfulAttemptCount,
    });
    final focus = payoff.focus;
    if (focus != null) {
      _recordTelemetryEventV1('session_focus_selected', <String, Object?>{
        'schemaVersion': 1,
        'run_id': closed.runId,
        'skill_id': focus.skillId,
        'selected_focus': focus.recommendationSignal,
      });
      _recordTelemetryEventV1('next_practice_recommended', <String, Object?>{
        'schemaVersion': 1,
        'run_id': closed.runId,
        'skill_id': focus.skillId,
        'recommendation_source': focus.recommendationSignal,
      });
    }
    _learningRunV1 = closed.markPayoffViewed();
    _pendingLearningRunPayoffV1 = payoff;
    _recordTelemetryEventV1('session_payoff_viewed', <String, Object?>{
      'schemaVersion': 1,
      'run_id': closed.runId,
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pendingLearningRunPayoffV1 == null) {
        return;
      }
      showDialog<void>(
        context: context,
        animationStyle: MediaQuery.disableAnimationsOf(context)
            ? AnimationStyle.noAnimation
            : null,
        barrierDismissible: false,
        builder: (context) => Act0LearningRunPayoffSheetV1(
          payoff: _pendingLearningRunPayoffV1!,
          onComplete: () {
            Navigator.of(context).pop();
            _setStateV1(_completeLearningRunPayoffV1);
          },
        ),
      );
    });
  }

  // A directed repair may rehearse a locked future-world task. Returning to
  // Learn must restore an actionable curriculum focus, not that repair target.
  void _restoreSelectableLearnFocusV1() {
    final worlds = _progressedWorlds(_catalogStateV1);
    final selected = _worldById(worlds, _selectedWorldId);
    final world = selected.isSelectable
        ? selected
        : worlds.firstWhere(
            (world) =>
                world.status == Act0WorldStateV1.current && world.isSelectable,
            orElse: () => worlds.firstWhere((world) => world.isSelectable),
          );
    _selectedWorldId = world.worldId;
    final lesson = _firstPlayableLesson(world);
    _seedLearnRouteFocusV1(
      lessonId: lesson.lessonId,
      taskId: _firstIncompleteTask(lesson).taskId,
    );
    _showWorldMenu = false;
    _learnDetailWorldId = null;
  }

  // A normal Learn entry may happen from Home or Runner Back. Eligibility is
  // lazy: the first eligible decision, not this navigation transition, creates
  // the run.
  void _activateLearnVisitEligibilityV1() {
    _learningRunLearnVisitActiveV1 = true;
    _learningRunProductionLearnVisitV1 = true;
  }

  /// A payoff recommendation is only actionable when it resolves back to one
  /// existing source-owned drill. It deliberately fails closed to Home rather
  /// than inventing a route for ambiguous or non-drill content.
  bool _startLearningRunPayoffFocusV1(Act0LearningRunOutcomeV1? focus) {
    final state = _catalogStateV1;
    final route = Act0LearningRunPayoffFocusResolverV1.resolve(
      state: state,
      focus: focus,
    );
    if (route == null) return false;
    _startTaskByIds(
      route.world,
      route.lesson.lessonId,
      route.task.taskId,
      skipTeaching: true,
      allowDrillBypass: true,
      evidenceRunKind: 'practice',
      evidenceStartedBy: 'learning_run_payoff',
    );
    return true;
  }

  Future<void> _invalidatePersistedProgressWrites() async {
    if (!_usesPersistedProgress) {
      return;
    }
    _recoveryEpochV1++;
    _learnLessonOpenSequenceV1++;
    _progressPersistGeneration += 1;
    if (await _progressStore.clear()) {
      return;
    }
    // false is indeterminate: the durable state, not the result, decides.
    String? durable;
    try {
      durable = await _progressStore.load();
    } catch (_) {
      if (mounted) {
        _setStateV1(() => _progressLoadFailed = true);
      }
      throw StateError('Progress reset outcome could not be verified');
    }
    if (durable != null) {
      throw StateError('Progress reset was not saved');
    }
  }

  void _restorePreviewToFreshStart({
    bool showPlacement = true,
    Act0ShellTabV1 tab = Act0ShellTabV1.home,
  }) {
    _diagnosticLearningEntryV1 = null;
    _diagnosticLearningReturnV1 = null;
    final state = _catalogStateV1;
    final zeroProgressWorlds = _progressWorldsWithTaskIds(
      state,
      <String>{},
      retainedAccessWorldIds: const <String>{},
    );
    final zeroWorld = zeroProgressWorlds.firstWhere(
      (world) => world.status == Act0WorldStateV1.current && world.isSelectable,
      orElse: () => zeroProgressWorlds.first,
    );
    final zeroLesson = _firstPlayableLesson(zeroWorld);
    final zeroTask = _firstIncompleteTask(zeroLesson);
    _setStateV1(() {
      _tab = tab;
      _phase = Act0LessonPhaseV1.theory;
      _selectedWorldId = zeroWorld.worldId;
      _selectedLessonId = zeroLesson.lessonId;
      _selectedTaskId = zeroTask.taskId;
      _learnPopupTaskId = null;
      _completedLessonIds = <String>{};
      _completedWorldIds = <String>{};
      _retainedAccessWorldIds = <String>{};
      _completedTaskIds = <String>{};
      _lastShortSessionDayV1 = '';
      _returningAfterBreakV1 = false;
      _returnRefreshOfferDayV1 = '';
      _returnRefreshQueueV1 = null;
      _returnRefreshSelectionV1 = null;
      _firstLessonReminderAnsweredV1 = false;
      _lessonResumeV1 = null;
      _multiStreetRunsV1.clear();
      _tasksWithDeferredXpV1.clear();
      _skippedTaskIds.clear();
      _visibleSkippedTaskIds.clear();
      _showWorldMenu = false;
      _learnDetailWorldId = null;
      _learnDetailLessonId = null;
      _learnPopupTaskId = null;
      _selectedOptionId = null;
      _reviewConfidence = null;
      _teachingStepIndex = 0;
      _earnedXp = 0;
      _lessonRunXp = 0;
      _showPlayHub = tab != Act0ShellTabV1.play;
      _returnToPlayHubOnBack = false;
      _suppressLegacyRecheckAfterRecoveryV1 = true;
      _sessionDrillRecheckQueueItemsV1 = const [];
      _multiRepairQueueV1 = const Act0MultiRepairQueueV1();
      _multiRepairQueueOrderV1 = 0;
      _repairIntentAuditTrailV1.clear();
      _latestCompletedDecisionV1 = null;
      _choiceAssistanceV1 = Act0DecisionAssistanceV1.none;
      _pendingDecisionAssistanceV1.clear();
      _firstValueReceiptCarry = null;
      _firstValueTodayShownTelemetryKey = '';
      _learningRunV1 = null;
      _pendingLearningRunPayoffV1 = null;
      _learningRunOutcomeTelemetryKeysV1.clear();
      _mistakeRecords.clear();
      _openRepairIntentBySourceTaskId.clear();
      _resolvedMistakeTaskIds.clear();
      _cleanTaskIds.clear();
      _lessonRunMistakeTaskIds.clear();
      _lessonRunAssistedTaskIds.clear();
      _lessonRunPendingRetryTaskIds.clear();
      _lessonRunRetriedTaskIds.clear();
      _lessonRunQuickFixTaskIds.clear();
      _lessonRunDeepLeakTaskIds.clear();
      _dailyCompletedTaskIds.clear();
      _dailyCompletedLessonIds.clear();
      _dailyPracticeQueue = const Act0DailyPracticeQueueV1();
      _routePracticeV1 = const Act0RoutePracticeProgressV1();
      _routePracticePresetV1 = null;
      _dailyCompletedRepCount = 0;
      _rapidPracticeLoop = false;
      _activeLearningEvidenceRunKeyV1 = null;
      _learningEvidenceRunOrdinalV1 = 0;
      _learningEvidenceHistoryV1 = const Act0LearningEvidenceHistoryV1();
      _attemptArchiveV1 = const Act0AttemptArchiveV1.empty();
      _showAttemptArchiveV1 = false;
      _studyObservationsV1 = const [];
      _savedPracticeDaysV1 = const [];
      _durableRetentionHistoryV1 = const Act0DurableRetentionHistoryV1();
      _reviewMistakeHistoryV1 = const Act0ReviewMistakeHistoryV1();
      _reviewResolutionReceiptHistoryV1 =
          const Act0ReviewResolutionReceiptHistoryV1();
      _conceptFamilyStateHistoryV1 = const Act0ConceptFamilyStateHistoryV1();
      _sessionIdentityStateV1 = const Act0SessionIdentityStateV1();
      _repairOutcomeProjectionV1 = const Act0RepairOutcomeProjectionV1();
      _repairOutcomeSequenceV1 = 0;
      _retentionSequence = 0;
      _spacedReviewReturnV1 = null;
      _activeSpacedReviewTaskV1 = null;
      _activeDueReviewItemV1 = null;
      _newSpacedReviewSavePendingV1 = false;
      _openedSpacedReviewTaskIdsV1.clear();
      _retentionMemoryByTaskId.clear();
      _activePracticeGroupId = null;
      _clearActiveRepairLaunchV1();
      _activeRepairSourceTaskId = null;
      _activeRepairResultReceiptLine = null;
      _activeRepairSessionSummaryLines = const <String>[];
      _blockCompletionSummary = null;
      _dismissedHomeHandoffKey = '';
      _dismissedHomeHandoffDay = '';
      _lastSessionLearnerStateV1 = null;
      _persistedStreakDays = 0;
      _lastDailyDate = '';
      _placementRetakeV1 = false;
      _w1StartChosenV1 = false;
      _w1RulesBestScoreV1 = 0;
      _w1RulesFocusTaskIdsV1 = const {};
      _showW1StartV1 = false;
      _w1RulesAnswersV1 = null;
      _w1RulesResultV1 = null;
      _showPlacement = showPlacement;
      _showWelcome = false;
      _welcomeCompletedV1 = false;
      _introductionSkippedV1 = false;
      _skipIntroductionSavingV1 = false;
      _welcomeCompletionSavingV1 = false;
      _welcomeCompletionEpochV1 += 1;
      _welcomeHandoffStartsRecommendedTaskV1 = false;
      _welcomeReturnTabV1 = null;
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
      _profileSkillValues.clear();
      _learnerGoalV1 = Act0LearnerGoalV1.onlineCash;
      _goalRoutePlacementV1 = null;
      _recentSkillGains.clear();
      _placementResult = null;
      _resetLessonRunMetrics(forceFreshProvenance: true);
    });
  }

  void _openDevMapSkippingPlacement() {
    _setStateV1(() {
      _showPlacement = false;
      _showWelcome = false;
      _welcomeReturnTabV1 = null;
      _endPlacementAssessmentRunV1();
      _placementDiagnosticActive = false;
      _placementIntroVisible = false;
      _placementDiagnosticIndex = 0;
      _placementDiagnosticCorrect = 0;
      _placementDiagnosticScore = 0;
      _placementDiagnosticHitSignals.clear();
      _placementDiagnosticMissSignals.clear();
      _tab = Act0ShellTabV1.learn;
      _showPlayHub = true;
      _returnToPlayHubOnBack = false;
      _showWorldMenu = false;
      _learnDetailWorldId = null;
      _learnDetailLessonId = null;
    });
  }

  void _openDevSurface({required Act0ShellTabV1 tab, bool showPlayHub = true}) {
    final state = _catalogStateV1;
    final worlds = _progressWorlds(state);
    _normalizeSelection(worlds);
    final selectedWorld = _worldById(worlds, _selectedWorldId);
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final selectedTask = _taskById(selectedLesson, _selectedTaskId);
    _setStateV1(() {
      _showPlacement = false;
      _showWelcome = false;
      _welcomeReturnTabV1 = null;
      _endPlacementAssessmentRunV1();
      _placementDiagnosticActive = false;
      _tab = tab;
      _showPlayHub = tab == Act0ShellTabV1.play ? showPlayHub : true;
      _returnToPlayHubOnBack = false;
      _blockCompletionSummary = null;
      _clearActiveRepairLaunchV1();
      _activeRepairSourceTaskId = null;
      _activeRepairResultReceiptLine = null;
      _activeRepairSessionSummaryLines = const <String>[];
      _selectedOptionId = null;
      _phase = selectedTask.entryPhase;
      _teachingStepIndex = 0;
      if (tab != Act0ShellTabV1.learn) {
        _learnDetailLessonId = null;
        _learnDetailWorldId = null;
        _showWorldMenu = false;
      }
    });
  }

  Future<void> _handleResetAppProgress() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      animationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset progress?'),
          content: const Text(
            'This clears app progress and returns the dev shell to Today.',
          ),
          actions: [
            TextButton(
              key: const Key('act0_shell_dev_menu_reset_cancel'),
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              key: const Key('act0_shell_dev_menu_reset_confirm'),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
    if (shouldReset != true || !mounted) {
      return;
    }
    await _invalidatePersistedProgressWrites();
    await ProgressService.debugReset();
    await OnboardingPreferencesService.resetOnboarding();
    await Act0FirstStartPreferencesV1.resetWelcome();
    if (!mounted) {
      return;
    }
    _restorePreviewToFreshStart(showPlacement: true);
    _persistProgress();
  }

  Future<void> _openPremiumPreviewSheet({
    required String eyebrow,
    required String title,
    required String summary,
    required List<String> valuePoints,
    required String trustLine,
    String? footerLine,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : null,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Act0PremiumPreviewSheetV1(
        eyebrow: eyebrow,
        title: title,
        summary: summary,
        valuePoints: valuePoints,
        trustLine: trustLine,
        footerLine: footerLine,
      ),
    );
  }
}
