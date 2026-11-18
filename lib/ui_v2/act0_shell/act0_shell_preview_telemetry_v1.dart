part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewTelemetryV1 on _Act0ShellPreviewScreenV1State {
  void _recordTelemetryEventV1(String name, Map<String, Object?> fields) {
    final sink = widget.telemetrySink;
    if (sink == null) {
      return;
    }
    try {
      sink.record(
        Act0TelemetryEventV1(
          name: name,
          fields: _sessionTelemetryFieldsV1(name, fields),
        ),
      );
    } catch (_) {
      // Telemetry must never interrupt the learner route.
    }
  }

  Map<String, Object?> _sessionTelemetryFieldsV1(
    String name,
    Map<String, Object?> fields,
  ) {
    if (name == 'learning_effect_delta_viewed' ||
        name == 'learning_effect_delta_completed') {
      return fields;
    }
    if (fields.containsKey('sessionId') || fields.containsKey('session_id')) {
      return fields;
    }
    final sessionId = _sessionIdForTelemetryEventV1(name);
    if (sessionId.isEmpty) {
      return fields;
    }
    return <String, Object?>{
      ...fields,
      'sessionId': sessionId,
      'session_id': sessionId,
    };
  }

  String _sessionIdForTelemetryEventV1(String name) {
    final active = _sessionIdentityStateV1.currentActiveSessionId;
    if (active.isNotEmpty) {
      return active;
    }
    if (name == 'session_complete' ||
        name == 'session_exited' ||
        name == 'day2_return' ||
        name == 'world_complete') {
      return _sessionIdentityStateV1.currentOrLatestSession?.sessionId ?? '';
    }
    return '';
  }

  Act0TelemetrySinkV1? _sessionAwareTelemetrySinkV1() {
    final sink = widget.telemetrySink;
    if (sink == null) {
      return null;
    }
    return _Act0SessionTelemetrySinkV1(
      sink,
      () => _sessionIdentityStateV1.currentActiveSessionId,
    );
  }

  void _emitSessionStartTelemetryV1({
    required String lessonId,
    required String taskId,
    required String sourceSurface,
  }) {
    final result = _ensureActiveSessionIdentityV1(
      worldId: _selectedWorldId,
      lessonId: lessonId,
    );
    if (!result.startedNewSession) {
      return;
    }
    _recordTelemetryEventV1('session_start', <String, Object?>{
      'schemaVersion': 1,
      'worldId': _selectedWorldId,
      'world_id': _selectedWorldId,
      'lessonId': lessonId,
      'lesson_id': lessonId,
      'taskId': taskId,
      'task_id': taskId,
      'source_surface': sourceSurface,
    });
  }

  void _emitSessionCompleteTelemetryV1({
    required String sourceSurface,
    String? practiceGroupId,
    int? completedRepCount,
    int? cleanRepCount,
    String? resultSummary,
  }) {
    final result = _completeActiveSessionIdentityV1(
      completionReason: sourceSurface,
    );
    if (!result.completedNow) {
      return;
    }
    _recordTelemetryEventV1('session_complete', <String, Object?>{
      'schemaVersion': 1,
      'worldId': _selectedWorldId,
      'world_id': _selectedWorldId,
      if (_selectedLessonId.trim().isNotEmpty) ...{
        'lessonId': _selectedLessonId,
        'lesson_id': _selectedLessonId,
      },
      if (_selectedTaskId.trim().isNotEmpty) ...{
        'taskId': _selectedTaskId,
        'task_id': _selectedTaskId,
      },
      if (practiceGroupId != null) ...{
        'practiceGroupId': practiceGroupId,
        'practice_group_id': practiceGroupId,
      },
      if (completedRepCount != null) 'completed_rep_count': completedRepCount,
      if (cleanRepCount != null) 'clean_rep_count': cleanRepCount,
      if (resultSummary != null) 'result_summary': resultSummary,
      'source_surface': sourceSurface,
    });
    _persistProgress();
  }

  void _emitSessionExitedTelemetryV1({required String sourceSurface}) {
    final result = _completeActiveSessionIdentityV1(
      completionReason: sourceSurface,
    );
    if (!result.completedNow) {
      return;
    }
    _recordTelemetryEventV1('session_exited', <String, Object?>{
      'schemaVersion': 1,
      'worldId': _selectedWorldId,
      'world_id': _selectedWorldId,
      if (_selectedLessonId.trim().isNotEmpty) ...{
        'lessonId': _selectedLessonId,
        'lesson_id': _selectedLessonId,
      },
      if (_selectedTaskId.trim().isNotEmpty) ...{
        'taskId': _selectedTaskId,
        'task_id': _selectedTaskId,
      },
      'source_surface': sourceSurface,
    });
  }

  void _emitDay2ReturnTelemetryV1(Act0LastSessionLearnerStateV1 lastSession) {
    _recordTelemetryEventV1('day2_return', <String, Object?>{
      'schemaVersion': 1,
      'worldId': lastSession.lastSessionWorldId,
      'world_id': lastSession.lastSessionWorldId,
      if (lastSession.lastSessionRepairFocusId.trim().isNotEmpty)
        'repair_focus_id': lastSession.lastSessionRepairFocusId,
      'proof_result': _currentDay2ProofResultV1(lastSession),
      'source_surface': 'act0_home',
    });
  }

  String _currentDay2ProofResultV1(Act0LastSessionLearnerStateV1 lastSession) {
    if (lastSession.lastSessionProofResult != act0LastSessionProofFixLandedV1) {
      return lastSession.lastSessionProofResult;
    }
    // Keep the historical cache unchanged. A current positive event needs its
    // exact recorded repair; matching a broad focus or old boolean is no proof.
    final ref = lastSession.lastSessionRepairOutcomeRef;
    if (ref.isEmpty) return act0LastSessionProofUnconfirmedV1;
    final matches = _repairOutcomeProjectionV1.outcomes
        .where(
          (outcome) =>
              'repair_outcome_v1|${outcome.sequence}|${outcome.queueItemId}' ==
              ref,
        )
        .toList();
    if (matches.length != 1) return act0LastSessionProofUnconfirmedV1;
    final outcome = matches.single;
    if (outcome.isCorrect != true ||
        outcome.repairFocusKey != lastSession.lastSessionRepairFocusId ||
        outcome.targetWorldId != lastSession.lastSessionWorldId ||
        outcome.sessionId !=
            _sessionIdentityStateV1.currentOrLatestSession?.sessionId ||
        !_fixProofProjectionV1().proofs.any(
          (proof) =>
              proof.repairOutcomeRef == ref &&
              proof.repairSessionId == outcome.sessionId,
        )) {
      return act0LastSessionProofUnconfirmedV1;
    }
    final intent = act0RepairIntentForRecordedOutcomeV1(
      outcome: outcome,
      learningEvidence: _learningEvidenceHistoryV1,
      currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
      repairIntents: _activeRepairIntentsV1(),
    );
    if (intent == null ||
        act0RepairCurrentViewHasUnconfirmedLaterSourceAttemptV1(
          intent: intent,
          outcome: outcome,
          learningEvidence: _learningEvidenceHistoryV1,
          currentFingerprintForIdentity: _repairFingerprintForIdentityV1,
        ))
      return act0LastSessionProofUnconfirmedV1;
    final attempts = act0RepairEvidenceRecordsForIdV1(
      _learningEvidenceHistoryV1,
      outcome.repairAttemptId,
    );
    if (attempts.length != 1 || attempts.single.recordedAtUtc == null) {
      return act0LastSessionProofUnconfirmedV1;
    }
    final local = attempts.single.recordedAtUtc!.toLocal();
    final civilDate =
        '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
    return civilDate == lastSession.lastSessionDate
        ? act0LastSessionProofFixLandedV1
        : act0LastSessionProofUnconfirmedV1;
  }

  _Act0NextUsefulHandReasonReceiptV1 _nextUsefulHandReasonReceiptV1({
    required _Act0LearningRecommendationV1 recommendation,
    required Act0WorldCardV1 selectedWorld,
    Act0ShellStateV1? state,
  }) {
    final sourceTaskId = recommendation.mistake?.taskId;
    final repairIntentTarget = sourceTaskId == null
        ? null
        : _openRepairIntentTargetForSourceTaskV1(
            sourceTaskId,
            state: state,
            includeOwed: true,
          );
    if (repairIntentTarget != null) {
      return _Act0NextUsefulHandReasonReceiptV1.forRepairIntent(
        sourceTaskId: sourceTaskId!,
        target: repairIntentTarget,
        practiceGroupId: recommendation.practiceGroupId,
        repeatedMissCount: recommendation.mistake?.attempts ?? 1,
      );
    }
    return _Act0NextUsefulHandReasonReceiptV1.existingFallback(
      sourceTaskId: sourceTaskId ?? '',
      targetWorldId: selectedWorld.worldId,
      targetLessonId: recommendation.lessonId ?? '',
      targetTaskId: recommendation.taskId ?? '',
      practiceGroupId: recommendation.practiceGroupId,
    );
  }

  String _auditTransitionForReceiptV1(
    _Act0NextUsefulHandReasonReceiptV1 receipt,
  ) {
    return switch (receipt.selectionSource) {
      'repair_intent_mapped' => 'mapped_selection',
      'repair_intent_exact_replay' => 'exact_replay_selection',
      _ => 'existing_fallback_selection',
    };
  }

  void _recordRepairIntentAuditTransitionV1(
    String transition, {
    required _Act0NextUsefulHandReasonReceiptV1 receipt,
  }) {
    _appendRepairIntentAuditEntryV1(
      _Act0RepairIntentAuditEntryV1(
        transition: transition,
        sourceTaskId: receipt.sourceTaskId,
        targetTaskId: receipt.targetTaskId,
        selectionSource: receipt.selectionSource,
        reasonCode: receipt.reasonCode,
        mappingType: receipt.mappingType,
      ),
    );
  }

  void _appendRepairIntentAuditEntryV1(_Act0RepairIntentAuditEntryV1 entry) {
    if (_repairIntentAuditTrailV1.isNotEmpty &&
        _repairIntentAuditTrailV1.last.hasSamePayload(entry)) {
      return;
    }
    _repairIntentAuditTrailV1.add(entry);
    const maxEntries = 12;
    if (_repairIntentAuditTrailV1.length > maxEntries) {
      _repairIntentAuditTrailV1.removeRange(
        0,
        _repairIntentAuditTrailV1.length - maxEntries,
      );
    }
  }

  void _emitRepairCompletedTelemetryV1({
    required String sourceTaskId,
    required String repairTaskId,
    required bool repaired,
  }) {
    _recordTelemetryEventV1('repair_completed', <String, Object?>{
      'schemaVersion': 1,
      'sourceTaskId': sourceTaskId,
      'repairTaskId': repairTaskId,
      'result': repaired ? 'correct' : 'incorrect',
      'attemptOrdinal': 1,
      'repairStatus': repaired ? 'fixed' : 'open',
    });
    if (repaired) {
      _recordTelemetryEventV1('fix_landed', <String, Object?>{
        'schemaVersion': 1,
        'worldId': _selectedWorldId,
        'world_id': _selectedWorldId,
        'repair_focus_id': sourceTaskId,
        'sourceTaskId': sourceTaskId,
        'source_task_id': sourceTaskId,
        'taskId': repairTaskId,
        'task_id': repairTaskId,
        'is_correct': true,
        'result': 'correct',
        'source_surface': 'act0_review',
      });
    }
  }

  void _emitRepairItemShownTelemetryV1(Act0MistakeCardV1 mistake) {
    final key = '${mistake.taskId}:${mistake.attempts}';
    if (_repairItemShownTelemetryKeys.contains(key)) {
      return;
    }
    _repairItemShownTelemetryKeys.add(key);
    _recordTelemetryEventV1('repair_item_shown', <String, Object?>{
      'schemaVersion': 1,
      'repairItemId': 'repair:${mistake.taskId}',
      'sourceTaskId': mistake.taskId,
      'createdFrom': 'mistake',
      'status': 'open',
    });
  }

  void _emitRepairItemStartedTelemetryV1({
    required Act0MistakeCardV1 mistake,
    required String targetTaskId,
    required String mappingType,
  }) {
    _recordTelemetryEventV1('repair_item_started', <String, Object?>{
      'schemaVersion': 1,
      'repairItemId': 'repair:${mistake.taskId}',
      'sourceTaskId': mistake.taskId,
      'targetTaskId': targetTaskId,
      'createdFrom': 'mistake',
      'status': 'in_progress',
      'mappingType': mappingType,
    });
  }

  void _emitRepairItemCompletedTelemetryV1({
    required String sourceTaskId,
    required String targetTaskId,
    required bool repaired,
    _Act0MistakeRecordV1? record,
  }) {
    _recordTelemetryEventV1('repair_item_completed', <String, Object?>{
      'schemaVersion': 1,
      'repairItemId': 'repair:$sourceTaskId',
      'sourceTaskId': sourceTaskId,
      'targetTaskId': targetTaskId,
      'createdFrom': 'mistake',
      'status': repaired ? 'repaired' : 'open',
      'outcome': repaired ? 'repaired' : 'needs_repair',
      'correct': repaired,
    });
  }

  void _emitRepairStartedTelemetryV1({
    required String sourceTaskId,
    required String repairTaskId,
  }) {
    _recordTelemetryEventV1('repair_started', <String, Object?>{
      'schemaVersion': 1,
      'sourceTaskId': sourceTaskId,
      'repairTaskId': repairTaskId,
      'attemptOrdinal': 1,
    });
    _recordTelemetryEventV1('repair_entered', <String, Object?>{
      'schemaVersion': 1,
      'sourceTaskId': sourceTaskId,
      'source_task_id': sourceTaskId,
      'repairTaskId': repairTaskId,
      'repair_task_id': repairTaskId,
      'attemptOrdinal': 1,
      'source_surface': 'act0_repair',
    });
    _recordTelemetryEventV1('repair_attempted', <String, Object?>{
      'schemaVersion': 1,
      'worldId': _selectedWorldId,
      'world_id': _selectedWorldId,
      'repair_focus_id': sourceTaskId,
      'sourceTaskId': sourceTaskId,
      'source_task_id': sourceTaskId,
      'taskId': repairTaskId,
      'task_id': repairTaskId,
      'attemptOrdinal': 1,
      'attempt_ordinal': 1,
      'source_surface': 'act0_review',
    });
  }

  void _emitPracticeCompletedTelemetryV1({
    required String practiceGroupId,
    required int completedRepCount,
    required int cleanRepCount,
    required String resultSummary,
  }) {
    _emitSessionCompleteTelemetryV1(
      sourceSurface: 'act0_practice',
      practiceGroupId: practiceGroupId,
      completedRepCount: completedRepCount,
      cleanRepCount: cleanRepCount,
      resultSummary: resultSummary,
    );
    _recordTelemetryEventV1('practice_completed', <String, Object?>{
      'schemaVersion': 1,
      'practiceGroupId': practiceGroupId,
      'completedRepCount': completedRepCount,
      'cleanRepCount': cleanRepCount,
      'resultSummary': resultSummary,
    });
  }

  void _emitPracticeStartedTelemetryV1({required String practiceGroupId}) {
    _recordTelemetryEventV1('practice_started', <String, Object?>{
      'schemaVersion': 1,
      'practiceGroupId': practiceGroupId,
    });
    _emitSessionStartTelemetryV1(
      lessonId: _selectedLessonId,
      taskId: _selectedTaskId,
      sourceSurface: 'act0_practice',
    );
  }

  void _emitRecheckCompletedTelemetryV1({
    required String taskId,
    required bool completedCorrectly,
    required int successfulRecheckCount,
  }) {
    _recordTelemetryEventV1('recheck_completed', <String, Object?>{
      'schemaVersion': 1,
      'taskId': taskId,
      'result': completedCorrectly ? 'correct' : 'incorrect',
      'attemptOrdinal': 1,
      'retentionStatus': completedCorrectly
          ? _Act0RetentionMemoryStatusV1.ownedCandidate
          : _Act0RetentionMemoryStatusV1.agedRecheck,
      'successfulRecheckCount': successfulRecheckCount,
    });
  }

  void _emitProveCompletedTelemetryV1({
    required String taskId,
    required bool completedCorrectly,
  }) {
    _recordTelemetryEventV1('prove_completed', <String, Object?>{
      'schemaVersion': 1,
      'taskId': taskId,
      'result': completedCorrectly ? 'correct' : 'incorrect',
      'attemptOrdinal': 1,
      'retentionStatus': completedCorrectly
          ? _Act0RetentionMemoryStatusV1.ownedCandidate
          : _Act0RetentionMemoryStatusV1.openRepair,
    });
  }

  void _emitLessonStartedTelemetryV1({
    required String lessonId,
    required String taskId,
  }) {
    _recordTelemetryEventV1('lesson_started', <String, Object?>{
      'schemaVersion': 1,
      'lessonId': lessonId,
      'taskId': taskId,
    });
    _emitSessionStartTelemetryV1(
      lessonId: lessonId,
      taskId: taskId,
      sourceSurface: 'act0_learn',
    );
  }

  void _emitActionTheoryCompletedTelemetryV1(Act0LessonTaskV1 task) {
    final sequence = act0ActionLearningSequenceForTaskV1(task.taskId);
    if (sequence == null || task.taskId != sequence.theoryTaskId) {
      return;
    }
    final key =
        '${_sessionIdentityStateV1.currentActiveSessionId}:$_selectedWorldId:$_selectedLessonId:${task.taskId}';
    if (!_actionTheoryCompletedTelemetryKeysV1.add(key)) {
      return;
    }
    _recordTelemetryEventV1('theory_completed', <String, Object?>{
      'schemaVersion': 1,
      'worldId': _selectedWorldId,
      'world_id': _selectedWorldId,
      'lessonId': _selectedLessonId,
      'lesson_id': _selectedLessonId,
      'taskId': task.taskId,
      'task_id': task.taskId,
      'sequence_id': sequence.sequenceId,
      'sequence_stage': Act0ActionSequenceStageV1.theory.name,
    });
  }

  void _emitFirstValueTodayShownTelemetryV1(
    _Act0FirstValueReceiptCarryV1 carry,
  ) {
    if (_firstValueTodayShownTelemetryKey == carry.skillReceiptId) {
      return;
    }
    _firstValueTodayShownTelemetryKey = carry.skillReceiptId;
    _recordTelemetryEventV1('first_value_today_shown', <String, Object?>{
      'schemaVersion': 1,
      'skillReceiptId': carry.skillReceiptId,
      'skillAtomId': carry.skillAtomId,
      'nextRepId': carry.nextRepId,
      'receiptOutcome': carry.outcomeId,
    });
  }

  void _emitFirstValueTodayConsumedTelemetryV1(
    _Act0FirstValueReceiptCarryV1 carry,
  ) {
    _recordTelemetryEventV1('first_value_today_consumed', <String, Object?>{
      'schemaVersion': 1,
      'skillReceiptId': carry.skillReceiptId,
      'skillAtomId': carry.skillAtomId,
      'nextRepId': carry.nextRepId,
      'receiptOutcome': carry.outcomeId,
    });
  }

  void _emitFirstValueDailyRepLaunchedTelemetryV1({
    required _Act0FirstValueReceiptCarryV1 carry,
    required _Act0FirstValueDailyRepTargetV1 target,
  }) {
    _recordTelemetryEventV1('first_value_daily_rep_launched', <String, Object?>{
      'schemaVersion': 1,
      'skillReceiptId': carry.skillReceiptId,
      'skillAtomId': carry.skillAtomId,
      'nextRepId': carry.nextRepId,
      'receiptOutcome': carry.outcomeId,
      'feedbackSignal': carry.sourceSignalId,
      'mappedTargetTaskId': target.taskId,
      'mappingType': target.mappingType,
    });
  }
}
