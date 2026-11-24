part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewRoutePracticeV1 on _Act0ShellPreviewScreenV1State {
  Act0RoutePracticeStepV1? _requiredRoutePracticeV1(
    Act0WorldCardV1 world,
    Set<String> pathClosedTaskIds, {
    int? w1RulesBestScore,
  }) {
    if (world.worldId == 'world_1' &&
        (w1RulesBestScore ?? _w1RulesBestScoreV1) >=
            Act0W1RulesResultV1.passingScore) {
      return null;
    }
    return act0RequiredRoutePracticeV1(world, pathClosedTaskIds, {
      ..._routePracticeV1.finished,
      ..._routePracticeV1.waived,
    });
  }

  List<Act0RoutePracticeRepV1> _routePracticeDeckV1(Act0WorldCardV1 owner) {
    final state = _catalogStateV1;
    final eligibleLessons = act0RoutePracticeEligibleLessonIdsV1(
      state.worlds,
      _pathClosedTaskIds,
      throughWorld: owner.worldNumber,
      passedW1RulesCheck:
          _w1RulesBestScoreV1 >= Act0W1RulesResultV1.passingScore,
    );
    final openMistakes = _mistakeRecords.values.where(
      (record) =>
          eligibleLessons.contains(record.lessonId) &&
          !_isMistakeDischargedV1(record.taskId),
    );
    final weakLessons = <String>{};
    final latestByTask = <String, Act0LearningEvidenceRecordV1>{};
    for (final record in _learningEvidenceHistoryV1.records) {
      if (eligibleLessons.contains(record.lessonId)) {
        latestByTask[record.taskId] = record;
      }
    }
    for (final record in latestByTask.values) {
      if (!record.isIndependentCorrect) weakLessons.add(record.lessonId);
    }
    return act0RoutePracticeDeckV1(
      eligibleLessonIds: eligibleLessons,
      preferredWorldId: owner.worldId,
      openMistakeLessonIds: openMistakes
          .map((record) => record.lessonId)
          .toSet(),
      openMistakeFamilies: {
        for (final record in openMistakes)
          if (_openRepairIntentBySourceTaskId[record.taskId]?.missedSignalId
              case final String family)
            family,
      },
      weakLessonIds: weakLessons,
      seenTaskIds: {
        ..._routePracticeV1.seen,
        ..._openedSpacedReviewTaskIdsV1,
        ...latestByTask.keys,
      },
    );
  }

  Act0LessonCardV1? _routePracticeMissionV1(
    Act0WorldCardV1 world,
    Act0RoutePracticeStepV1 step,
  ) {
    final active = _routePracticeV1.run;
    if (active != null &&
        active.stepId == step.id &&
        active.answered >= active.taskIds.length) {
      return null;
    }
    final tasks = active != null && active.stepId == step.id
        ? active.taskIds
              .map((id) => act0RoutePracticeRepsByIdV1[id]!.task)
              .toList()
        : _routePracticeDeckV1(world).map((rep) => rep.task).toList();
    if (tasks.isEmpty) return null;
    return Act0LessonCardV1(
      lessonId: step.id,
      title: _copyV1(en: 'Practice', ru: 'Практика'),
      subtitle: _copyV1(
        en: 'Complete this set to open the next lesson.',
        ru: 'Пройди эту серию, чтобы открыть следующий урок.',
      ),
      state: Act0LessonStateV1.current,
      phaseLabel: 'Practice',
      primaryCtaLabel: 'Start',
      isSelectable: true,
      isLocked: false,
      rewardXp: 0,
      runner: tasks.first.runner,
      tasks: tasks,
    );
  }

  void _closeRoutePracticeV1() {
    if (!_routePracticeV1.inRunner) return;
    _setStateV1(() {
      _routePracticePresetV1 = null;
      _routePracticeV1 = _routePracticeV1.update(
        _routePracticeV1.run,
        inRunner: false,
      );
      _returnToRunnerOriginV1(Act0ShellTabV1.learn);
    });
    _persistProgress();
  }

  void _startRoutePracticeV1(
    Act0WorldCardV1 world,
    Act0RoutePracticeStepV1 step,
  ) {
    if (!world.isSelectable ||
        _requiredRoutePracticeV1(world, _pathClosedTaskIds)?.id != step.id) {
      return;
    }
    var run = _routePracticeV1.run;
    if (run == null || run.stepId != step.id) {
      final deck = _routePracticeDeckV1(world);
      if (deck.length < Act0RoutePracticeRunV1.minReps) return;
      run = Act0RoutePracticeRunV1(
        stepId: step.id,
        taskIds: deck.map((rep) => rep.task.taskId).toList(growable: false),
      );
    }
    _recordRunnerOriginV1();
    _closeLearningRunForLearnExitV1();
    _tab = Act0ShellTabV1.learn;
    _showPlayHub = true;
    _blockCompletionSummary = null;
    _learnDetailLessonId = null;
    _learnPopupTaskId = null;
    _routePracticePresetV1 = null;
    _routePracticeV1 = _routePracticeV1.update(
      run,
      inRunner: true,
      seenTaskId: run.taskId,
    );
    _persistProgress();
  }

  Widget _buildRoutePracticeRunnerV1(Act0RoutePracticeRunV1 run) {
    final rep = act0RoutePracticeRepsByIdV1[run.taskId]!;
    final task = rep.task;
    final title = _copyV1(en: 'Practice', ru: 'Практика');
    final runner = normalizeAct0DrillSeatHighlightPolicyV1(
      normalizeAct0SeatTapRunnerV1(
        task.runner.copyWith(
          lessonTitle: title,
          lessonSubtitle: '',
          phase: run.choiceId == null
              ? Act0LessonPhaseV1.drill
              : Act0LessonPhaseV1.review,
          selectedOptionId: run.choiceId,
          selectedPresetId: _routePracticePresetV1,
          teachingStepIndex: task.runner.teachingSteps.length,
          beatIndex: run.answered + 1,
          beatCount: run.taskIds.length,
          hintPolicy: Act0HintPolicyV1.hidden,
        ),
      ),
    );
    final epoch = _recoveryEpochV1;
    final evidenceRunId = 'route_practice|${run.stepId}|${run.answered}';
    final evidenceNextOrder = _latestEvidenceOrderV1() + 1;
    bool isCurrent() =>
        _acceptRecoveryCallbackV1(epoch) &&
        identical(_routePracticeV1.run, run) &&
        _routePracticeV1.inRunner;
    void choose(Act0RunnerOptionV1 option) {
      if (!isCurrent() || run.choiceId != null) return;
      _setStateV1(() {
        _routePracticeV1 = _routePracticeV1.update(
          run.choose(option.id),
          inRunner: true,
          seenTaskId: task.taskId,
        );
      });
    }

    return Act0LessonRunnerShellV1(
      key: ValueKey(('route_practice', run.stepId, run.taskId)),
      runner: runner,
      worldNumber: int.tryParse(rep.worldId.split('_').last) ?? 0,
      selectedWorldId: rep.worldId,
      selectedLessonId: rep.lessonId,
      selectedTaskId: task.taskId,
      selectedTaskTitle: title,
      selectedTaskFamily: task.resolvedTaskFamily,
      tablePresentation: task.tablePresentation,
      compositionFamily: task.resolvedCompositionFamily,
      preserveSourceOwnedQuestion: true,
      showDecisionCoach: false,
      suppressFeedbackRepairFocus: true,
      feedbackForwardCtaLabel: run.isLast
          ? _copyV1(en: 'Finish practice', ru: 'Завершить практику')
          : _copyV1(en: 'Continue', ru: 'Дальше'),
      onBack: () {
        if (isCurrent()) _closeRoutePracticeV1();
      },
      onContinueTheory: () {},
      onChooseOption: choose,
      evidenceRunId: evidenceRunId,
      evidenceNextOrder: evidenceNextOrder,
      onCompletedDecision: (decision) {
        final updated = _routePracticeV1.run;
        if (!_acceptRecoveryCallbackV1(epoch) ||
            !_routePracticeV1.inRunner ||
            updated?.stepId != run.stepId ||
            updated?.taskId != task.taskId ||
            updated?.choiceId != decision.selectedId) {
          return;
        }
        final previousRun = _activeLearningEvidenceRunKeyV1;
        _startLearningEvidenceRunV1(
          worldId: rep.worldId,
          lessonId: rep.lessonId,
          runKind: 'practice',
          startedBy: 'required_learn_practice',
        );
        _appendLearningEvidenceV1(decision);
        _activeLearningEvidenceRunKeyV1 = previousRun;
        _persistProgress();
      },
      onChooseSeat: (seat) {
        final option = runner.options
            .where((o) => o.seatId == seat)
            .firstOrNull;
        if (option != null) choose(option);
      },
      onSelectSizingPreset: (preset) {
        if (isCurrent()) _setStateV1(() => _routePracticePresetV1 = preset.id);
      },
      onConfirmSizingPreset: () {
        final option = runner.options
            .where((o) => o.id == _routePracticePresetV1)
            .firstOrNull;
        if (option != null) choose(option);
      },
      onContinueReview: () {
        if (!isCurrent() || run.choiceId == null) return;
        _setStateV1(() {
          _routePracticePresetV1 = null;
          _routePracticeV1 = _routePracticeV1.update(
            run.isLast ? null : run.next(),
            inRunner: !run.isLast,
            finishedStepId: run.isLast ? run.stepId : null,
            seenTaskId: run.isLast ? null : run.taskIds[run.answered + 1],
          );
          if (run.isLast) _returnToRunnerOriginV1(Act0ShellTabV1.learn);
        });
        _persistProgress();
      },
    );
  }
}
