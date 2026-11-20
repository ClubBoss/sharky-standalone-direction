part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewLaunchV1 on _Act0ShellPreviewScreenV1State {
  bool _startFirstValueDailyRepLaunchV1(_Act0FirstValueReceiptCarryV1 carry) {
    final target = _firstValueDailyRepTargetV1(carry);
    if (target == null) {
      return false;
    }
    final launchWorld = _worldById(
      _progressedWorlds(widget.state ?? Act0ShellStateV1.sample),
      target.worldId,
    );
    final launchLesson = _lessonById(launchWorld.lessons, target.lessonId);
    final launchTask = _taskById(launchLesson, target.taskId);
    if (launchTask.phase != Act0LessonPhaseV1.drill) {
      return false;
    }
    // A daily rep may only use content the learner has opened. A target in a
    // locked world or lesson (e.g. a World 3 checkpoint for a World 1
    // learner) falls back to the route instead of jumping ahead.
    if (!launchWorld.isSelectable || launchLesson.isLocked) {
      return false;
    }
    _emitFirstValueTodayConsumedTelemetryV1(carry);
    _emitFirstValueDailyRepLaunchedTelemetryV1(carry: carry, target: target);
    _firstValueReceiptCarry = null;
    _firstValueTodayShownTelemetryKey = '';
    _placementHandoffActive = false;
    _startTaskByIds(
      launchWorld,
      launchLesson.lessonId,
      launchTask.taskId,
      skipTeaching: true,
      allowDrillBypass: true,
      rapidPracticeLoop: false,
    );
    _returnToPlayHubOnBack = false;
    _activePracticeGroupId = carry.isRepair ? 'weak_spots' : 'daily';
    if (carry.isRepair) {
      _activeRepairTaskId = launchTask.taskId;
      _activeRepairSourceTaskId = carry.sourceTaskId;
      _activeRepairObligationV1 =
          _openRepairIntentBySourceTaskId[carry.sourceTaskId];
      _activeRepairResultReceiptLine = null;
      _activeRepairSessionSummaryLines = const <String>[];
    }
    _persistProgress();
    return true;
  }

  _Act0FirstValueDailyRepTargetV1? _firstValueDailyRepTargetV1(
    _Act0FirstValueReceiptCarryV1 carry, {
    Act0ShellStateV1? state,
  }) {
    if (!carry.nextRepId.startsWith('repeat_')) {
      return null;
    }
    if (carry.isRepair) {
      return _openRepairIntentTargetForSourceTaskV1(
        carry.sourceTaskId,
        state: state,
        includeOwed: true,
      )?.target;
    }
    final adjudication = act0RepairGapAdjudicationForSourceTaskV1(
      carry.sourceTaskId,
    );
    if (adjudication?.outcome == Act0RepairGapOutcomeV1.unresolvedProductGap) {
      return null;
    }
    final worlds = _progressedWorlds(
      state ?? widget.state ?? Act0ShellStateV1.sample,
    );
    if (adjudication?.outcome ==
        Act0RepairGapOutcomeV1.intentionalExactReplay) {
      return _sameSignalRepTargetIfLaunchableV1(
        worlds,
        worldId: adjudication!.sourceWorldId,
        lessonId: adjudication.sourceLessonId,
        taskId: adjudication.sourceTaskId,
        sourceTaskId: '',
        mappingType: adjudication.mappingType,
      );
    }
    final mappedTarget = _firstValueMappedDailyRepTargetV1(carry, worlds);
    if (mappedTarget != null) {
      return mappedTarget;
    }
    return _firstValueReplayDailyRepTargetV1(carry, worlds);
  }

  _Act0FirstValueDailyRepTargetV1? _firstValueMappedDailyRepTargetV1(
    _Act0FirstValueReceiptCarryV1 carry,
    List<Act0WorldCardV1> worlds,
  ) {
    final mapping = act0FirstValueSameSignalRepMappingV1(
      nextRepId: carry.nextRepId,
      skillAtomId: carry.skillAtomId,
      sourceSignalId: carry.sourceSignalId,
      sourceTaskId: carry.sourceTaskId,
      receiptOutcome: carry.outcomeId,
    );
    if (mapping == null) {
      return null;
    }
    return _sameSignalRepTargetIfLaunchableV1(
      worlds,
      worldId: mapping.worldId,
      lessonId: mapping.lessonId,
      taskId: mapping.taskId,
      sourceTaskId: carry.sourceTaskId,
      mappingType: mapping.mappingType,
    );
  }

  _Act0FirstValueDailyRepTargetV1? _firstValueReplayDailyRepTargetV1(
    _Act0FirstValueReceiptCarryV1 carry,
    List<Act0WorldCardV1> worlds,
  ) {
    final worldId = carry.sourceWorldId.trim();
    final lessonId = carry.sourceLessonId.trim();
    final taskId = carry.sourceTaskId.trim();
    if (worldId.isEmpty || lessonId.isEmpty || taskId.isEmpty) {
      return null;
    }
    return _sameSignalRepTargetIfLaunchableV1(
      worlds,
      worldId: worldId,
      lessonId: lessonId,
      taskId: taskId,
      sourceTaskId: '',
      mappingType: 'replay',
    );
  }

  _Act0FirstValueDailyRepTargetV1? _sameSignalRepTargetIfLaunchableV1(
    List<Act0WorldCardV1> worlds, {
    required String worldId,
    required String lessonId,
    required String taskId,
    required String sourceTaskId,
    required String mappingType,
  }) {
    final targetWorldId = worldId.trim();
    final targetLessonId = lessonId.trim();
    final targetTaskId = taskId.trim();
    if (targetWorldId.isEmpty ||
        targetLessonId.isEmpty ||
        targetTaskId.isEmpty ||
        targetTaskId == sourceTaskId.trim()) {
      return null;
    }
    final world = worlds.cast<Act0WorldCardV1?>().firstWhere(
      (candidate) => candidate?.worldId == targetWorldId,
      orElse: () => null,
    );
    if (world == null) {
      return null;
    }
    final lesson = world.lessons.cast<Act0LessonCardV1?>().firstWhere(
      (candidate) => candidate?.lessonId == targetLessonId,
      orElse: () => null,
    );
    if (lesson == null) {
      return null;
    }
    final task = lesson.taskList.cast<Act0LessonTaskV1?>().firstWhere(
      (candidate) => candidate?.taskId == targetTaskId,
      orElse: () => null,
    );
    if (task == null ||
        (task.phase != Act0LessonPhaseV1.drill &&
            mappingType != 'intentional_exact')) {
      return null;
    }
    return _Act0FirstValueDailyRepTargetV1(
      worldId: world.worldId,
      lessonId: lesson.lessonId,
      taskId: task.taskId,
      mappingType: mappingType,
    );
  }

  _Act0OpenRepairIntentTargetV1? _topOpenRepairIntentTargetV1({
    Act0ShellStateV1? state,
  }) {
    for (final mistake in _openMistakes()) {
      final target = _openRepairIntentTargetForSourceTaskV1(
        mistake.taskId,
        state: state,
        includeOwed: true,
      );
      if (target != null) {
        return target;
      }
    }
    return null;
  }

  /// [includeOwed] opts presentation and launch entry points into a mapped
  /// repair still owed after the source clue was answered correctly. In-lesson
  /// flow logic keeps the default so a source retry still finishes normally.
  _Act0OpenRepairIntentTargetV1? _openRepairIntentTargetForSourceTaskV1(
    String sourceTaskId, {
    Act0ShellStateV1? state,
    bool includeOwed = false,
  }) {
    final normalizedSourceTaskId = sourceTaskId.trim();
    final discharged = includeOwed
        ? _isMistakeDischargedV1(normalizedSourceTaskId)
        : _resolvedMistakeTaskIds.contains(normalizedSourceTaskId);
    if (normalizedSourceTaskId.isEmpty ||
        discharged ||
        !_mistakeRecords.containsKey(normalizedSourceTaskId)) {
      return null;
    }
    final intent = _openRepairIntentBySourceTaskId[normalizedSourceTaskId];
    if (intent == null) {
      return null;
    }
    if (!_hasValidatedRepairTargetV1(intent)) {
      return null;
    }
    final worlds = _progressedWorlds(
      state ?? widget.state ?? Act0ShellStateV1.sample,
    );
    final mappedTarget = _repairIntentTargetByIdsIfLaunchableV1(
      worlds,
      worldId: intent.targetWorldId,
      lessonId: intent.targetLessonId,
      taskId: intent.targetTaskId,
      mappingType: intent.mappingType,
      allowSourceTask: intent.mappingType == 'intentional_exact',
      sourceTaskId: normalizedSourceTaskId,
    );
    final target = mappedTarget;
    if (target == null) {
      return null;
    }
    return _Act0OpenRepairIntentTargetV1(intent: intent, target: target);
  }

  _Act0FirstValueDailyRepTargetV1? _repairIntentTargetByIdsIfLaunchableV1(
    List<Act0WorldCardV1> worlds, {
    required String worldId,
    required String lessonId,
    required String taskId,
    required String mappingType,
    required bool allowSourceTask,
    required String sourceTaskId,
  }) {
    final targetWorldId = worldId.trim();
    final targetLessonId = lessonId.trim();
    final targetTaskId = taskId.trim();
    if (targetWorldId.isEmpty ||
        targetLessonId.isEmpty ||
        targetTaskId.isEmpty ||
        (!allowSourceTask && targetTaskId == sourceTaskId.trim())) {
      return null;
    }
    final world = worlds.cast<Act0WorldCardV1?>().firstWhere(
      (candidate) => candidate?.worldId == targetWorldId,
      orElse: () => null,
    );
    if (world == null) {
      return null;
    }
    final lesson = world.lessons.cast<Act0LessonCardV1?>().firstWhere(
      (candidate) => candidate?.lessonId == targetLessonId,
      orElse: () => null,
    );
    if (lesson == null) {
      return null;
    }
    final task = lesson.taskList.cast<Act0LessonTaskV1?>().firstWhere(
      (candidate) => candidate?.taskId == targetTaskId,
      orElse: () => null,
    );
    if (task == null ||
        (task.phase != Act0LessonPhaseV1.drill &&
            mappingType != 'intentional_exact')) {
      return null;
    }
    return _Act0FirstValueDailyRepTargetV1(
      worldId: world.worldId,
      lessonId: lesson.lessonId,
      taskId: task.taskId,
      mappingType: mappingType,
    );
  }

  void _startHomeRepairAction(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      _startRecommendation(
        recommendation,
        selectedWorld,
        returnToPlayHub: false,
      );
      return;
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      _tab = Act0ShellTabV1.review;
    }
  }

  void _startHomeDailyPlanJob(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
    String jobId,
  ) {
    if (jobId == 'continue') {
      _startHomeNextAction(selectedWorld);
      return;
    }
    if (jobId.startsWith('repair:')) {
      _startHomeRepairAction(selectedWorld, currentLesson);
      return;
    }
    if (jobId.startsWith('recheck:')) {
      final taskId = jobId.substring('recheck:'.length);
      final mistake = _topRetentionReplayCardV1(
        _Act0RetentionMemoryStatusV1.agedRecheck,
      );
      if (mistake != null && mistake.taskId == taskId) {
        _startMistakeRepair(
          selectedWorld,
          mistake,
          returnToPlayHub: false,
          practiceGroupId: 'weak_spots',
        );
      }
      return;
    }
    if (jobId.startsWith('prove:')) {
      final taskId = jobId.substring('prove:'.length);
      final mistake = _topRetentionReplayCardV1(
        _Act0RetentionMemoryStatusV1.ownedCandidate,
      );
      if (mistake != null && mistake.taskId == taskId) {
        _startMistakeRepair(
          selectedWorld,
          mistake,
          returnToPlayHub: false,
          practiceGroupId: 'weak_spots',
        );
      }
      return;
    }
    _startHomeRepairAction(selectedWorld, currentLesson);
  }

  Act0PracticeGroupV1 _groupForLesson(
    Act0WorldCardV1 world, {
    required String groupId,
    required String lessonId,
    required String title,
    required String subtitle,
    required String ctaLabel,
    required String categoryLabel,
    required String sessionLabel,
    String? countLabel,
    String durationLabel = '',
    bool preferDrill = false,
    bool isRecommended = false,
    bool skipTeaching = false,
    bool allowDrillBypass = false,
  }) {
    final lesson = world.lessons.cast<Act0LessonCardV1?>().firstWhere(
      (candidate) => candidate?.lessonId == lessonId,
      orElse: () => null,
    );
    final task = lesson == null
        ? null
        : _playLaunchTaskForLesson(lesson, preferDrill: preferDrill);
    return Act0PracticeGroupV1(
      groupId: groupId,
      title: title,
      subtitle: subtitle,
      ctaLabel: ctaLabel,
      categoryLabel: categoryLabel,
      isEnabled: lesson != null && lesson.isSelectable && task != null,
      targetLessonId: lesson?.lessonId,
      targetTaskId: task?.taskId,
      countLabel:
          countLabel ??
          (lesson == null ? '' : '${lesson.taskList.length} steps'),
      sessionLabel: sessionLabel,
      durationLabel: durationLabel,
      isRecommended: isRecommended,
      skipTeaching: skipTeaching,
      allowDrillBypass: allowDrillBypass,
    );
  }

  Act0PracticeGroupV1 _groupForTaskPack(
    Act0ShellStateV1 state, {
    required _Act0TopicPackSpecV1 spec,
    bool isRecommended = false,
  }) {
    final target = _topicPackLaunchTarget(state, spec);
    return Act0PracticeGroupV1(
      groupId: spec.groupId,
      title: spec.title,
      subtitle: target == null
          ? _copyV1(
              en: 'Clear it on the route first.',
              ru: 'Сначала закрой это на маршруте.',
            )
          : spec.subtitle,
      ctaLabel: 'Practice',
      categoryLabel: spec.categoryLabel,
      isEnabled: target != null,
      targetWorldId: target?.worldId,
      targetLessonId: target?.lessonId,
      targetTaskId: target?.taskId,
      sessionLabel: spec.sessionLabel,
      durationLabel: spec.durationLabel,
      isRecommended: isRecommended,
      skipTeaching: true,
      allowDrillBypass: true,
      useRapidPracticeLoop: true,
    );
  }

  _Act0PracticeLaunchTargetV1? _topicPackLaunchTarget(
    Act0ShellStateV1 state,
    _Act0TopicPackSpecV1 spec,
  ) {
    for (final world in _progressedWorlds(state)) {
      for (final lesson in world.lessons) {
        if (lesson.lessonId != spec.lessonId) {
          continue;
        }
        for (final task in lesson.taskList) {
          if (task.taskId != spec.taskId ||
              task.phase != Act0LessonPhaseV1.drill ||
              !_completedTaskIds.contains(task.taskId)) {
            continue;
          }
          return _Act0PracticeLaunchTargetV1(
            worldId: world.worldId,
            lessonId: lesson.lessonId,
            taskId: task.taskId,
          );
        }
      }
    }
    return null;
  }

  Act0LessonTaskV1? _preferredPracticeTask(
    Act0LessonCardV1 lesson, {
    bool preferDrill = false,
  }) {
    final firstIncomplete = _firstIncompleteTask(lesson);
    if (!preferDrill || firstIncomplete.phase == Act0LessonPhaseV1.drill) {
      return firstIncomplete;
    }
    return lesson.courseTaskList.firstWhere(
      (task) =>
          task.phase == Act0LessonPhaseV1.drill &&
          _taskAvailable(lesson, task.taskId),
      orElse: () => firstIncomplete,
    );
  }

  Act0LessonTaskV1? _playLaunchTaskForLesson(
    Act0LessonCardV1 lesson, {
    bool preferDrill = false,
  }) {
    if (!preferDrill) {
      return _firstIncompleteTask(lesson);
    }
    for (final task in lesson.courseTaskList) {
      if (task.phase == Act0LessonPhaseV1.drill) {
        return task;
      }
    }
    return _firstIncompleteTask(lesson);
  }

  String _learnGuideTitle(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeRepairLabel(selectedWorld, selectedLesson);
  }

  String _learnGuideLine(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeRepairHeadline(selectedWorld, selectedLesson);
  }

  String _learnGuideDetail(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    return _homeRepairDetail(selectedWorld, selectedLesson);
  }

  Act0SharkyMoodV1 _learnGuideMood(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => Act0SharkyMoodV1.repair,
      _Act0LearningNextActionKindV1.repairWeakSpot => Act0SharkyMoodV1.repair,
      _Act0LearningNextActionKindV1.reviewQuickFix => Act0SharkyMoodV1.thinking,
      _Act0LearningNextActionKindV1.continueLesson => Act0SharkyMoodV1.happy,
      _Act0LearningNextActionKindV1.dailyDrill => Act0SharkyMoodV1.happy,
      _Act0LearningNextActionKindV1.categoryPractice =>
        Act0SharkyMoodV1.thinking,
      _Act0LearningNextActionKindV1.dailyDone => Act0SharkyMoodV1.celebrate,
    };
  }

  Map<String, String> _lessonOutcomeLabels(List<Act0LessonCardV1> lessons) {
    return <String, String>{
      for (final lesson in lessons)
        lesson.lessonId: _lessonOutcomeLabel(lessons, lesson),
    };
  }

  String _lessonOutcomeLabel(
    List<Act0LessonCardV1> lessons,
    Act0LessonCardV1 lesson,
  ) {
    final nextLesson = _nextLesson(lessons, lesson.lessonId);
    return switch (lesson.state) {
      Act0LessonStateV1.completed =>
        nextLesson == null
            ? 'Lesson complete. Replay any step for more practice.'
            : 'Already clear. Next open lesson: ${nextLesson.title}.',
      Act0LessonStateV1.current =>
        nextLesson == null
            ? 'On clear: move into Play and lock the pattern in.'
            : 'On clear: unlock ${nextLesson.title}.',
      Act0LessonStateV1.available => 'Open for practice.',
      Act0LessonStateV1.locked => 'Opens after the current lesson is cleared.',
    };
  }

  Act0LessonCardV1? _nextLesson(
    List<Act0LessonCardV1> lessons,
    String lessonId,
  ) {
    final nextLessonId = _nextLessonId(lessons, lessonId);
    if (nextLessonId == null) {
      return null;
    }
    return _lessonById(lessons, nextLessonId);
  }

  String _playDrillTitleForLesson(String lessonId) {
    if (_isRuLocaleV1) {
      return switch (lessonId) {
        'what_poker_is' => 'Действия',
        'cards_ranks_suits' => 'Старшинство рук',
        'your_first_hand' => 'Улицы',
        'fold_check_call_raise' => 'Действия',
        'blinds_action_order' => 'Позиции',
        'positions' => 'Позиции',
        'hand_rankings_table' => 'Старшинство рук',
        'showdown_winning' => 'Шоудаун',
        _ => 'Быстрый дневной дрилл',
      };
    }
    return switch (lessonId) {
      'what_poker_is' => 'Actions',
      'cards_ranks_suits' => 'Hand rankings',
      'your_first_hand' => 'Streets',
      'fold_check_call_raise' => 'Actions',
      'blinds_action_order' => 'Positions',
      'positions' => 'Positions',
      'hand_rankings_table' => 'Hand rankings',
      'showdown_winning' => 'Showdown',
      _ => 'Start a short rep',
    };
  }

  bool _launchDailyPracticeQueueTaskV1() {
    _ensureDailyCountDayV1();
    final taskId = _dailyPracticeQueue.nextTaskId;
    if (taskId == null) return false;
    final state = widget.state ?? Act0ShellStateV1.sample;
    final entries = _dailyDeckEntries(
      state,
    ).where((entry) => entry.taskId == taskId);
    if (entries.isEmpty) return false;
    final target = entries.first;
    final world = _worldById(_progressedWorlds(state), target.worldId);
    if (!_startTaskByIds(
      world,
      target.lessonId,
      target.taskId,
      skipTeaching: true,
      allowDrillBypass: true,
      rapidPracticeLoop: true,
      evidenceRunKind: 'practice',
      evidenceStartedBy: 'practice_daily',
    ))
      return false;
    _activePracticeGroupId = 'daily';
    _returnToPlayHubOnBack = true;
    _persistProgress();
    return true;
  }

  void _startPracticeGroup(
    Act0PracticeGroupV1 group,
    Act0WorldCardV1 selectedWorld,
  ) {
    _practiceCompletionTitle = null;
    _practiceCompletionBody = null;
    final lessonId = group.targetLessonId;
    final taskId = group.targetTaskId;
    if (!group.isEnabled || lessonId == null || taskId == null) {
      return;
    }
    if (_learningRunV1 != null) {
      _closeLearningRunForLearnExitV1();
    }
    if (group.groupId == 'daily') {
      _ensureDailyCountDayV1();
      final entries = _dailyDeckEntries(
        widget.state ?? Act0ShellStateV1.sample,
      );
      final eligible = entries.map((entry) => entry.taskId).toSet();
      if (!_dailyPracticeQueue.isValidFor(eligible) ||
          _dailyPracticeQueue.nextTaskId == null) {
        _dailyPracticeQueue = Act0DailyPracticeQueueV1.start(
          eligible,
          practicedToday: _dailyCompletedTaskIds,
        );
      }
      _emitPracticeStartedTelemetryV1(practiceGroupId: 'daily');
      _launchDailyPracticeQueueTaskV1();
      return;
    }
    if (group.groupId == 'weak_spots') {
      final weakSpot = _topOpenMistake();
      if (weakSpot != null) {
        _startMistakeRepair(
          selectedWorld,
          weakSpot,
          returnToPlayHub: true,
          practiceGroupId: group.groupId,
          skipTeaching: group.skipTeaching,
          allowDrillBypass: group.allowDrillBypass,
          rapidPracticeLoop: group.useRapidPracticeLoop,
        );
        return;
      }
      final quickFix = _quickFixMistakes().isEmpty
          ? null
          : _quickFixMistakes().first;
      if (quickFix != null) {
        _startMistakeRepair(
          selectedWorld,
          quickFix,
          returnToPlayHub: true,
          practiceGroupId: group.groupId,
          skipTeaching: group.skipTeaching,
          allowDrillBypass: group.allowDrillBypass,
          rapidPracticeLoop: group.useRapidPracticeLoop,
        );
        return;
      }
      return;
    }
    _emitPracticeStartedTelemetryV1(practiceGroupId: group.groupId);
    var launchWorld = selectedWorld;
    final targetWorldId = group.targetWorldId;
    if (targetWorldId != null) {
      final baseState = widget.state ?? Act0ShellStateV1.sample;
      launchWorld = _worldById(_progressedWorlds(baseState), targetWorldId);
    }
    _startTaskByIds(
      launchWorld,
      lessonId,
      taskId,
      skipTeaching: group.skipTeaching,
      allowDrillBypass: group.allowDrillBypass,
      rapidPracticeLoop: group.useRapidPracticeLoop,
      evidenceRunKind: 'practice',
      evidenceStartedBy: 'practice_${group.groupId}',
    );
    _returnToPlayHubOnBack = true;
    _activePracticeGroupId = group.groupId;
    _rapidPracticeLoop = group.useRapidPracticeLoop;
  }

  void _startPracticeRepairQueueTarget(
    Act0PracticeRepairQueueLaunchRequestV1 request, {
    String evidenceStartedBy = 'practice_repair_queue',
  }) {
    if (!request.isLaunchable ||
        request.targetType != act0PracticeRepairQueueTargetTypeActiveRepairV1) {
      return;
    }
    final intent = _openRepairIntentBySourceTaskId[request.sourceTaskId];
    if (intent == null ||
        !_hasValidatedRepairTargetV1(intent) ||
        request.repairOccurrenceId != intent.repairOccurrenceId ||
        request.queueItemId != queueItemIdForAct0RepairIntentV1(intent) ||
        request.targetWorldId != intent.targetWorldId ||
        request.targetLessonId != intent.targetLessonId ||
        request.targetTaskId != intent.targetTaskId) {
      _showHeldRepairNoticeV1();
      return;
    }
    final preserveRepairBridge = _shouldPreserveLearningRunForRepairBridgeV1(
      currentTab: _tab,
      requestedTab: Act0ShellTabV1.play,
      requestedRepairSourceTaskId: request.sourceTaskId,
    );
    if (_learningRunV1 != null && !preserveRepairBridge) {
      _closeLearningRunForLearnExitV1();
    }
    final baseState = widget.state ?? Act0ShellStateV1.sample;
    final launchWorld = _worldById(
      _progressedWorlds(baseState),
      request.targetWorldId,
    );
    final started = _startTaskByIds(
      launchWorld,
      request.targetLessonId,
      request.targetTaskId,
      skipTeaching: true,
      allowDrillBypass: true,
      evidenceRunKind: 'repair',
      evidenceStartedBy: evidenceStartedBy,
      repairLaunchIntent: intent,
    );
    if (!started ||
        _selectedWorldId != request.targetWorldId ||
        _selectedLessonId != request.targetLessonId ||
        _selectedTaskId != request.targetTaskId ||
        _tab != Act0ShellTabV1.play ||
        _showPlayHub) {
      return;
    }
    _returnToPlayHubOnBack = true;
    _activePracticeGroupId = 'weak_spots';
    _activeRepairTaskId = request.repairTaskId;
    _activeRepairSourceTaskId = request.sourceTaskId;
    _activePracticeRepairQueueRequestV1 = request;
    _activeRepairObligationV1 =
        _openRepairIntentBySourceTaskId[request.sourceTaskId];
    if (intent.sourceTaskId == act0ActionLearningSequenceV1.practiceTaskId &&
        intent.targetTaskId == 'actions_legal_context') {
      // Queue and feedback launches feed the same canonical Action policy.
      // The policy still validates the actual current source/target attempts.
      _activeActionSequenceStageV1 = Act0ActionSequenceStageV1.repair;
    }
    final launchTask = _taskById(
      _lessonById(launchWorld.lessons, request.targetLessonId),
      request.targetTaskId,
    );
    if (launchTask.phase == Act0LessonPhaseV1.drill) {
      // skipTeaching applies to the rendered repair wrapper too. Its intro
      // exists only after the active source/target context has been bound.
      _teachingStepIndex = _repairRunnerForTask(
        launchTask,
      ).teachingSteps.length;
    }
    _emitRepairStartedTelemetryV1(
      sourceTaskId: request.sourceTaskId,
      repairTaskId: request.repairTaskId,
    );
  }

  void _startMistakeRepair(
    Act0WorldCardV1 selectedWorld,
    Act0MistakeCardV1 mistake, {
    required bool returnToPlayHub,
    String? practiceGroupId,
    bool skipTeaching = false,
    bool allowDrillBypass = false,
    bool rapidPracticeLoop = false,
    bool familiarReplayOnly = false,
  }) {
    final sourceTaskId = mistake.taskId;
    final diagnosticIntent = _openRepairIntentBySourceTaskId[sourceTaskId];
    if (!familiarReplayOnly &&
        diagnosticIntent != null &&
        _startDiagnosticLearningEntryV1(diagnosticIntent))
      return;
    if (familiarReplayOnly && !_isMistakeDischargedV1(sourceTaskId)) {
      _showHeldRepairNoticeV1();
      return;
    }
    final retentionStatus = _retentionMemoryByTaskId[sourceTaskId]?.status;
    final isRetentionReplay =
        familiarReplayOnly ||
        retentionStatus == _Act0RetentionMemoryStatusV1.agedRecheck ||
        retentionStatus == _Act0RetentionMemoryStatusV1.ownedCandidate;
    final repairIntentTarget = isRetentionReplay
        ? null
        : _openRepairIntentTargetForSourceTaskV1(
            sourceTaskId,
            includeOwed: true,
          );
    if (!isRetentionReplay && repairIntentTarget == null) {
      _showHeldRepairNoticeV1();
      return;
    }
    final repairTarget = isRetentionReplay
        ? _Act0RepairTargetV1(lessonId: mistake.lessonId, taskId: sourceTaskId)
        : (repairIntentTarget == null
              ? _repairVariantTargetForSourceV1(
                      sourceTaskId,
                      sourceLessonId: mistake.lessonId,
                    ) ??
                    _Act0RepairTargetV1(
                      lessonId: mistake.lessonId,
                      taskId: sourceTaskId,
                    )
              : _Act0RepairTargetV1(
                  lessonId: repairIntentTarget.target.lessonId,
                  taskId: repairIntentTarget.target.taskId,
                ));
    final repairTaskId = repairTarget.taskId;
    final mappingType = isRetentionReplay
        ? 'replay'
        : (repairTaskId == sourceTaskId &&
              repairTarget.lessonId == mistake.lessonId)
        ? 'exact'
        : 'mapped';
    final isResumingActiveRepair =
        !isRetentionReplay &&
        _activeRepairSourceTaskId == sourceTaskId &&
        _activeRepairTaskId == repairTaskId;
    final isResumingFeedbackRepair =
        !isRetentionReplay &&
        _pendingFeedbackRepairSourceTaskIdV1 == sourceTaskId &&
        _pendingFeedbackRepairTaskIdV1 == repairTaskId;
    final launchWorldId = repairIntentTarget?.target.worldId ?? mistake.worldId;
    final launchWorld = launchWorldId.trim().isEmpty
        ? selectedWorld
        : _worldById(
            _progressedWorlds(widget.state ?? Act0ShellStateV1.sample),
            launchWorldId,
          );
    final launchLesson = _lessonById(
      launchWorld.lessons,
      repairTarget.lessonId,
    );
    final launchTask = _taskById(launchLesson, repairTaskId);
    if (!isRetentionReplay) {
      _mistakeRecords.putIfAbsent(
        sourceTaskId,
        () => _Act0MistakeRecordV1(
          taskId: sourceTaskId,
          lessonId: mistake.lessonId,
          worldId: mistake.worldId,
          title: mistake.title,
          weaknessLabel: mistake.weaknessLabel,
          selectedOptionId: mistake.selectedOptionId,
          selectedLabel: mistake.selectedLabel,
          betterLabel: mistake.betterLabel,
          reason: mistake.reason,
          contextLabels: mistake.contextLabels,
          repairActionLabel: mistake.repairActionLabel,
          attempts: mistake.attempts,
        ),
      );
    }
    final started = _startTaskByIds(
      launchWorld,
      repairTarget.lessonId,
      repairTaskId,
      skipTeaching: skipTeaching,
      allowDrillBypass:
          allowDrillBypass ||
          mappingType == 'mapped' ||
          launchTask.phase == Act0LessonPhaseV1.drill,
      rapidPracticeLoop: rapidPracticeLoop,
      repairLaunchIntent: isRetentionReplay
          ? null
          : _openRepairIntentBySourceTaskId[sourceTaskId],
      evidenceRunKind: familiarReplayOnly ? 'practice' : 'repair',
      evidenceStartedBy: familiarReplayOnly
          ? 'review_familiar_replay'
          : practiceGroupId == null
          ? 'repair'
          : 'practice_$practiceGroupId',
    );
    if (!started) {
      _showHeldRepairNoticeV1();
      return;
    }
    // The feedback CTA owns the first same-signal launch. Review may resume
    // that still-active repair after Back, but it must not start the same
    // lifecycle a second time.
    if (!familiarReplayOnly &&
        !isResumingActiveRepair &&
        !isResumingFeedbackRepair) {
      _emitRepairStartedTelemetryV1(
        sourceTaskId: sourceTaskId,
        repairTaskId: repairTaskId,
      );
      _emitRepairItemStartedTelemetryV1(
        mistake: mistake,
        targetTaskId: repairTaskId,
        mappingType: mappingType,
      );
    }
    _activeRepairTaskId = familiarReplayOnly ? null : repairTaskId;
    _activeRepairSourceTaskId = isRetentionReplay ? null : sourceTaskId;
    _activeRepairObligationV1 = isRetentionReplay
        ? null
        : _openRepairIntentBySourceTaskId[sourceTaskId];
    if (_activeRepairObligationV1 != null &&
        sourceTaskId == act0ActionLearningSequenceV1.practiceTaskId &&
        repairTaskId == 'actions_legal_context') {
      _activeActionSequenceStageV1 = Act0ActionSequenceStageV1.repair;
    }
    if (skipTeaching && launchTask.phase == Act0LessonPhaseV1.drill) {
      _teachingStepIndex = _repairRunnerForTask(
        launchTask,
      ).teachingSteps.length;
    }
    _activeSameSignalFeedbackRepairV1 = false;
    _pendingFeedbackRepairSourceTaskIdV1 = null;
    _pendingFeedbackRepairTaskIdV1 = null;
    _activeRepairResultReceiptLine = null;
    _activeRepairSessionSummaryLines = const <String>[];
    _returnToPlayHubOnBack = returnToPlayHub;
    _activePracticeGroupId = practiceGroupId;
    _rapidPracticeLoop = rapidPracticeLoop;
    _practiceCompletionTitle = null;
    _practiceCompletionBody = null;
  }

  /// Consumes the repair intent created by the just-reviewed missed answer.
  ///
  /// This is intentionally owned by the feedback CTA path rather than the
  /// Review/Practice entry points: the learner was promised the same clue at
  /// this exact moment, so advancing the lesson queue would be untruthful.
  bool _startSameSignalRepairFromFeedbackV1({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerStateV1 runner,
  }) {
    if ((runner.selectedOption?.isCorrect ?? true) ||
        _activeRepairTaskId != null ||
        _activeSameSignalRecheckTaskId != null) {
      return false;
    }
    final sourceTaskId = selectedTask.taskId;
    final repair = _openRepairIntentTargetForSourceTaskV1(sourceTaskId);
    // The lesson already owns retries of this same exercise. Keep its
    // progress and wrap-up flow; Home and Review can open the saved replay.
    if (repair == null || repair.intent.isFoundationExactRehearsal) {
      return false;
    }
    final Act0MistakeCardV1? mistake =
        _mistakeRecords[sourceTaskId]?.toCard() ??
        _openMistakes().cast<Act0MistakeCardV1?>().firstWhere(
          (candidate) => candidate?.taskId == sourceTaskId,
          orElse: () => null,
        );
    if (mistake == null) {
      return false;
    }
    _pendingFeedbackRepairSourceTaskIdV1 = null;
    _pendingFeedbackRepairTaskIdV1 = null;
    _startMistakeRepair(
      selectedWorld,
      mistake,
      returnToPlayHub: false,
      skipTeaching: true,
      allowDrillBypass: true,
    );
    _activeSameSignalFeedbackRepairV1 = true;
    _pendingFeedbackRepairSourceTaskIdV1 = sourceTaskId;
    _pendingFeedbackRepairTaskIdV1 = _activeRepairTaskId;
    return _activeRepairTaskId != null &&
        _activeRepairSourceTaskId == sourceTaskId;
  }

  void _recordPlacementDiagnosticMissForRepairV1({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerStateV1 runner,
    required Act0RunnerOptionV1 option,
  }) {
    if (option.isCorrect) {
      return;
    }
    _storeOpenRepairIntentForMissV1(
      sourceWorldId: selectedWorld.worldId,
      sourceLessonId: selectedLesson.lessonId,
      sourceTaskId: selectedTask.taskId,
      runner: runner,
      option: option,
      diagnosticSourceTask: selectedTask,
    );
    final contextLabels = _repairContextLabels(runner, option);
    _mistakeRecords.putIfAbsent(
      selectedTask.taskId,
      () => _Act0MistakeRecordV1(
        taskId: selectedTask.taskId,
        lessonId: selectedLesson.lessonId,
        worldId: selectedWorld.worldId,
        title: _localizedTaskTitleV1(selectedTask),
        weaknessLabel: _categoryForLesson(selectedLesson.lessonId),
        selectedOptionId: option.id,
        selectedLabel: option.label,
        betterLabel: option.betterAnswerLabel,
        reason: _hardenMistakeReason(
          rawReason: option.feedbackReason,
          betterLabel: option.betterAnswerLabel,
          contextLabels: contextLabels,
        ),
        contextLabels: contextLabels,
        repairActionLabel: _repairActionLabel(selectedTask),
        attempts: 1,
      ),
    );
  }

  /// The mapped repair task is the correction rep. A correct correction is
  /// followed by one graded replay of the original task so repair and recheck
  /// remain separately observable rather than silently completing together.
  bool _startSameSignalRecheckV1({
    required Act0WorldCardV1 selectedWorld,
    required String sourceTaskId,
  }) {
    final record = _mistakeRecords[sourceTaskId];
    if (record == null) {
      return false;
    }
    final sourceWorld = record.worldId.trim().isEmpty
        ? selectedWorld
        : _worldById(
            _progressedWorlds(widget.state ?? Act0ShellStateV1.sample),
            record.worldId,
          );
    final sourceLesson = _lessonById(sourceWorld.lessons, record.lessonId);
    final sourceTask = _taskById(sourceLesson, sourceTaskId);
    if (sourceTask.phase != Act0LessonPhaseV1.drill) {
      return false;
    }
    final mappedRepairTaskId = _activeRepairTaskId;
    final actionBridge =
        sourceTaskId == act0ActionLearningSequenceV1.practiceTaskId &&
        _activeRepairSourceTaskId == sourceTaskId &&
        mappedRepairTaskId == 'actions_legal_context' &&
        _actionPersonalizationStateV1.latestOutcome?.stage ==
            Act0ActionSequenceStageV1.repair &&
        _actionPersonalizationStateV1.latestOutcome?.isCorrect == true;
    _recordTelemetryEventV1('recheck_started', <String, Object?>{
      'schemaVersion': 1,
      if (actionBridge) 'sequence_id': act0ActionLearningSequenceV1.sequenceId,
      'source_task_id': sourceTaskId,
      'repair_task_id': _activeRepairTaskId,
      'recheck_task_id': sourceTaskId,
      'source_surface': 'act0_feedback_cta',
    });
    _startTaskByIds(
      sourceWorld,
      record.lessonId,
      sourceTaskId,
      skipTeaching: true,
      allowDrillBypass: true,
      evidenceRunKind: 'recheck',
      evidenceStartedBy: 'same_signal_feedback_cta',
    );
    if (_selectedTaskId != sourceTaskId) {
      return false;
    }
    _activeSameSignalRecheckTaskId = sourceTaskId;
    _activeSameSignalRecheckSourceTaskId = sourceTaskId;
    if (actionBridge) {
      _activeActionSequenceStageV1 = Act0ActionSequenceStageV1.recheck;
      _recordTelemetryEventV1(
        'action_sequence_recheck_entry',
        <String, Object?>{
          'schemaVersion': 1,
          'sequenceId': act0ActionLearningSequenceV1.sequenceId,
          'repairTaskId': mappedRepairTaskId,
          'recheckTaskId': sourceTaskId,
        },
      );
    }
    return true;
  }

  bool _completeSameSignalRecheckV1({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required Act0LessonTaskV1 selectedTask,
    required Act0RunnerStateV1 runner,
  }) {
    if (_activeSameSignalRecheckTaskId != selectedTask.taskId) {
      return false;
    }
    final sourceTaskId =
        _activeSameSignalRecheckSourceTaskId ?? selectedTask.taskId;
    final correct = runner.selectedOption?.isCorrect ?? false;
    final independentProof = act0IndependentRepairProofV1(
      isCorrect: correct,
      assistanceKind: _choiceAssistanceV1,
    );
    final actionRecheck =
        sourceTaskId == act0ActionLearningSequenceV1.practiceTaskId &&
        _activeActionSequenceStageV1 == Act0ActionSequenceStageV1.recheck &&
        _actionPersonalizationStateV1.repairSucceeded;
    _recordTelemetryEventV1('recheck_result', <String, Object?>{
      'schemaVersion': 1,
      if (actionRecheck) 'sequence_id': act0ActionLearningSequenceV1.sequenceId,
      'source_task_id': sourceTaskId,
      'recheck_task_id': selectedTask.taskId,
      'result': correct ? 'correct' : 'incorrect',
      'proof_status':
          _choiceAssistanceV1 == Act0DecisionAssistanceV1.legacyUnknown
          ? 'not_verified'
          : (_choiceWasAssistedV1 ? 'assisted_not_proven' : 'unassisted'),
      'source_surface': 'act0_feedback_cta',
    });
    _emitRecheckCompletedTelemetryV1(
      taskId: selectedTask.taskId,
      completedCorrectly: independentProof,
      successfulRecheckCount: independentProof ? 1 : 0,
    );
    _activeSameSignalRecheckTaskId = null;
    _activeSameSignalRecheckSourceTaskId = null;
    if (!independentProof) {
      // An unresolved recheck must not advance the parent lesson. This
      // inline recheck is only ever launched from the feedback CTA's own
      // "Try same clue" flow, so a miss here falls back to Review the same
      // way the pre-existing repair-completion branch already does.
      _selectedOptionId = null;
      _phase = Act0LessonPhaseV1.theory;
      _teachingStepIndex = 0;
      _returnToPlayHubOnBack = false;
      _showPlayHub = true;
      _tab = Act0ShellTabV1.review;
      return true;
    }
    if (actionRecheck && _actionPersonalizationStateV1.recheckSucceeded) {
      _activeActionSequenceStageV1 = Act0ActionSequenceStageV1.complete;
      _recordTelemetryEventV1('action_sequence_completed', <String, Object?>{
        'schemaVersion': 1,
        'sequenceId': act0ActionLearningSequenceV1.sequenceId,
        'completionTaskId': selectedTask.taskId,
      });
    }
    _completeCurrentTask(selectedTask);
    _returnToPlayHubOnBack = false;
    if (_maybeStartLessonWrapUpRetry(selectedLesson)) {
      return true;
    }
    if (_maybeShowBlockCompletionSummary(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
      selectedTask: selectedTask,
    )) {
      _selectedOptionId = null;
      _teachingStepIndex = 0;
      return true;
    }
    _advanceAfterTask(selectedWorld, selectedLesson);
    _selectedOptionId = null;
    _teachingStepIndex = 0;
    return true;
  }

  void _startRecommendation(
    _Act0LearningRecommendationV1 recommendation,
    Act0WorldCardV1 selectedWorld, {
    required bool returnToPlayHub,
  }) {
    final mistake = recommendation.mistake;
    if (mistake != null &&
        (recommendation.kind == _Act0LearningNextActionKindV1.repairDeepLeak ||
            recommendation.kind ==
                _Act0LearningNextActionKindV1.repairWeakSpot)) {
      _startMistakeRepair(
        selectedWorld,
        mistake,
        returnToPlayHub: returnToPlayHub,
        practiceGroupId: recommendation.practiceGroupId,
      );
      return;
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      final quickFix = _quickFixMistakes().isEmpty
          ? null
          : _quickFixMistakes().first;
      if (quickFix != null) {
        _startMistakeRepair(
          selectedWorld,
          quickFix,
          returnToPlayHub: returnToPlayHub,
          practiceGroupId: recommendation.practiceGroupId,
        );
      }
      return;
    }
    final lessonId = recommendation.lessonId;
    final taskId = recommendation.taskId;
    if (lessonId == null || taskId == null) {
      return;
    }
    _startTaskByIds(selectedWorld, lessonId, taskId);
    _returnToPlayHubOnBack = returnToPlayHub;
    _activePracticeGroupId = recommendation.practiceGroupId;
  }
}
