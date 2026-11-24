part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewProfileV1 on _Act0ShellPreviewScreenV1State {
  Act0ReviewStateV1 _reviewState(Act0ReviewStateV1 base) {
    final open = _debugReviewEmptyV1
        ? const <Act0MistakeCardV1>[]
        : _openMistakes().isEmpty
        ? base.mistakes
              .where(
                (mistake) =>
                    !mistake.resolved &&
                    !_isMistakeDischargedV1(mistake.taskId),
              )
              .toList()
        : _openMistakes();
    final fixed = _debugReviewEmptyV1
        ? const <Act0MistakeCardV1>[]
        : _fixedMistakes().isEmpty
        ? base.fixedMistakes
        : _fixedMistakes();
    final state = _catalogStateV1;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final strongSpots = _debugReviewEmptyV1
        ? const <String>[]
        : _strongCategories().isEmpty
        ? base.strongSpots
        : _strongCategories();
    return Act0ReviewStateV1(
      title: 'What to fix next',
      subtitle: recommendation.subtitle,
      weaknessLabel: open.isEmpty
          ? base.weaknessLabel
          : open.first.weaknessLabel,
      reason: open.isEmpty ? base.reason : open.first.reason,
      stats: <Act0ReviewStatV1>[
        Act0ReviewStatV1(label: 'Open', value: '${open.length}'),
        Act0ReviewStatV1(label: 'Deep', value: '${_deepLeakMistakes().length}'),
        Act0ReviewStatV1(
          label: 'Quick',
          value: '${_quickFixMistakes().length}',
        ),
        Act0ReviewStatV1(label: 'Replay', value: '${fixed.length}'),
        Act0ReviewStatV1(label: 'Strong', value: '${strongSpots.length}'),
      ],
      chosenLabel: open.isEmpty ? base.chosenLabel : open.first.selectedLabel,
      betterLabel: open.isEmpty ? base.betterLabel : open.first.betterLabel,
      mistakes: open,
      fixedMistakes: fixed,
      strongSpots: strongSpots,
    );
  }

  Act0ProfileStateV1 _profileState(
    Act0ProfileStateV1 base,
    _Act0ProgressSnapshotV1 progress,
  ) {
    final state = _catalogStateV1;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final totalTasks = _allLessons().fold<int>(
      0,
      (count, lesson) => count + lesson.taskList.length,
    );
    final completedCount = _completedTaskIds.length.clamp(0, totalTasks);
    final wrongAttempts = _mistakeRecords.values.fold<int>(
      0,
      (count, mistake) => count + mistake.attempts,
    );
    final totalAttempts = _cleanTaskIds.length + wrongAttempts;
    final accuracy = totalAttempts == 0
        ? (_debugFreshLearnerV1 || _usesPersistedProgress)
              ? _copyV1(
                  en: 'Make a decision to start tracking your practice',
                  ru: 'Подтверждение начнётся с первого решения',
                )
              : base.accuracyLine
        : '${((_cleanTaskIds.length / totalAttempts) * 100).round()}% practice accuracy';
    final perfectClearCount = _completedTaskIds.where((taskId) {
      if (!_cleanTaskIds.contains(taskId)) {
        return false;
      }
      return !_hasOpenMistakeRecord(taskId);
    }).length;
    final qualityLine = _profileQualityLineV1(
      perfectClearCount: perfectClearCount,
      completedCount: completedCount,
    );
    final streakDays = _effectiveStreakDays(state);
    final streakSaved = _streakSaveEarned();
    final focusTitle = recommendation.title.trim().isNotEmpty
        ? recommendation.title
        : (_weakCategories().isNotEmpty
              ? 'Repair ${_weakCategories().first}'
              : 'Keep the next clean rep simple');
    final focusBody = recommendation.subtitle.trim().isNotEmpty
        ? recommendation.subtitle
        : (_weakCategories().isNotEmpty
              ? 'One calm repair here will make the rest of the route lighter.'
              : 'Stay close to the active route and keep the next rep clean.');
    final focusCtaLabel = recommendation.ctaLabel.trim().isNotEmpty
        ? recommendation.ctaLabel
        : 'Open next step';
    return Act0ProfileStateV1(
      playerName: base.playerName,
      level: 'Level ${progress.level}',
      xpLine: '${progress.xp} / ${_catalogStateV1.xpTarget} XP',
      lessonsLine: '$completedCount of $totalTasks tasks complete',
      accuracyLine: accuracy,
      qualityLine: qualityLine,
      streakLine: streakDays == 0
          ? 'No streak yet'
          : streakSaved
          ? (streakDays == 1
                ? '1 day streak · saved today'
                : '$streakDays day streak · saved today')
          : (streakDays == 1 ? '1 day streak' : '$streakDays day streak'),
      streakDays: streakDays,
      // Ordinary persistence has no lifetime active-day counter. -1 is an
      // unknown presentation value, not a count derived from current streak.
      consistencyActiveDays: _usesPersistedProgress
          ? -1
          : _debugFreshLearnerV1
          ? 0
          : base.consistencyActiveDays,
      achievements: <Act0AchievementV1>[
        Act0AchievementV1(
          id: 'first_table_read',
          label: 'First clear read',
          locked: completedCount == 0,
        ),
        Act0AchievementV1(
          id: 'three_day_streak',
          label: 'Three Days of Practice',
          locked: streakDays < 3,
        ),
        Act0AchievementV1(
          id: 'repair_queue_clear',
          label: 'Good fix',
          locked: _resolvedMistakeTaskIds.isEmpty,
        ),
        Act0AchievementV1(
          id: 'streak_save_earned',
          label: 'Rhythm saved today',
          locked: !streakSaved,
        ),
        Act0AchievementV1(
          id: 'clean_practice_run',
          label: 'Clean drill chain',
          locked: _cleanTaskIds.length < 3,
        ),
      ],
      strongCategories: _strongCategories(),
      weakCategories: _weakCategories(),
      recentProgress: _recentProgress(),
      recentSkillGains: _debugFreshLearnerV1
          ? const <Act0SkillGainV1>[]
          : _profileRecentSkillGains(base.recentSkillGains),
      skillStats: _debugFreshLearnerV1
          ? const <Act0PlacementSkillStatV1>[]
          : _profileSkillStats(base.skillStats),
      // A single streak count/last-active date cannot prove seven dated cells.
      streakLast7: _usesPersistedProgress
          ? const <bool>[]
          : _debugFreshLearnerV1
          ? const <bool>[false, false, false, false, false, false, false]
          : base.streakLast7,
      recommendedFocusTitle: focusTitle,
      recommendedFocusBody: focusBody,
      recommendedFocusCtaLabel: focusCtaLabel,
      worldsClearedCount: _progressedWorlds(
        state,
      ).where((w) => w.status == Act0WorldStateV1.completed).length,
      worldsActiveCount: _progressedWorlds(
        state,
      ).where((w) => w.status == Act0WorldStateV1.current).length,
      totalWorldsCount: _progressedWorlds(state).length,
      mistakesFixedLine: _resolvedMistakeTaskIds.isEmpty
          ? ''
          : _copyV1(
              en: _resolvedMistakeTaskIds.length == 1
                  ? '1 spot repaired'
                  : '${_resolvedMistakeTaskIds.length} spots repaired',
              ru: _resolvedMistakeTaskIds.length == 1
                  ? '1 спот исправлен'
                  : '${_resolvedMistakeTaskIds.length} спота исправлены',
            ),
    );
  }

  String _profileQualityLineV1({
    required int perfectClearCount,
    required int completedCount,
  }) {
    if (perfectClearCount > 0) {
      return _copyV1(
        en: perfectClearCount == 1
            ? '1 perfect clear'
            : '$perfectClearCount perfect clears',
        ru: perfectClearCount == 1
            ? '1 идеальный проход'
            : '$perfectClearCount идеальных прохода',
      );
    }
    if (completedCount > 0) {
      return _copyV1(en: 'Ready for your next hand', ru: 'Идеал открыт');
    }
    return _copyV1(
      en: 'Start with your first hand',
      ru: 'Первое доказательство ещё не получено',
    );
  }

  Set<String> _perfectTaskIds() {
    return <String>{
      for (final taskId in _completedTaskIds)
        if (_cleanTaskIds.contains(taskId) && !_hasOpenMistakeRecord(taskId))
          taskId,
    };
  }

  bool _hasOpenMistakeRecord(String taskId) =>
      _mistakeRecords.containsKey(taskId) && !_isMistakeDischargedV1(taskId);

  /// The source clue was answered correctly, but a different mapped
  /// same-signal repair assigned for it has not been completed yet.
  bool _owesMappedRepairV1(String sourceTaskId) {
    if (!_resolvedMistakeTaskIds.contains(sourceTaskId)) {
      return false;
    }
    final intent = _openRepairIntentBySourceTaskId[sourceTaskId];
    return intent != null &&
        (!_hasValidatedRepairTargetV1(intent) ||
            (!act0IsExactRepairMappingTypeV1(intent.mappingType) &&
                intent.targetTaskId != sourceTaskId));
  }

  /// A source mistake is discharged only when it is resolved and no mapped
  /// repair remains owed.
  bool _isMistakeDischargedV1(String taskId) {
    // Practice Queue resolves keyed occurrences without rewriting the live
    // task-level cache. Consume the same validated resolution as Review history;
    // never hide another pending signal or a newer occurrence on this task.
    if (_activeRepairIntentsV1().any(
      (intent) => intent.sourceTaskId == taskId,
    )) {
      return false;
    }
    final resolutions = _reviewResolutionStateV1().resolutions.where(
      (resolution) => resolution.sourceTaskId == taskId,
    );
    if (resolutions.any((resolution) => resolution.isVisibleInActiveReview)) {
      return false;
    }
    if (_resolvedMistakeTaskIds.contains(taskId) &&
        !_owesMappedRepairV1(taskId)) {
      return true;
    }
    return resolutions.isNotEmpty &&
        resolutions.every(
          (resolution) =>
              resolution.reviewState == act0ReviewResolutionStateResolvedV1 &&
              resolution.resolutionReason ==
                  act0ReviewResolutionReasonRepairSucceededV1,
        );
  }

  Act0MistakeCardV1? _topOpenMistake() {
    final open = _openMistakes();
    final intentTarget = _topOpenRepairIntentTargetV1();
    if (intentTarget != null) {
      for (final mistake in open) {
        if (mistake.taskId == intentTarget.intent.sourceTaskId) {
          return mistake;
        }
      }
    }
    return open.isEmpty ? null : open.first;
  }

  List<Act0MistakeCardV1> _openMistakes() {
    final open = <Act0MistakeCardV1>[
      for (final record in _mistakeRecords.values)
        if (!_isMistakeDischargedV1(record.taskId))
          record.toCard(
            repairActionLabelOverride: _repairIntentSurfaceCopyLineV1(
              record.taskId,
            ),
            sourceRetriedCorrectly: _owesMappedRepairV1(record.taskId),
          ),
    ];
    open.sort((a, b) {
      final priority = _mistakePriority(b).compareTo(_mistakePriority(a));
      if (priority != 0) {
        return priority;
      }
      return a.taskId.compareTo(b.taskId);
    });
    return open;
  }

  String? _repairIntentSurfaceCopyLineV1(String sourceTaskId) {
    final intent = _openRepairIntentBySourceTaskId[sourceTaskId];
    if (intent != null && !_hasValidatedRepairTargetV1(intent)) {
      return 'Mistake saved for another try';
    }
    final target = _openRepairIntentTargetForSourceTaskV1(
      sourceTaskId,
      includeOwed: true,
    );
    if (target == null) {
      return null;
    }
    // The goal is bound to the saved choice by repair validation.
    final intentGoal = act0RepairGoalContractForSourceV1(
      worldId: target.intent.sourceWorldId,
      lessonId: target.intent.sourceLessonId,
      taskId: target.intent.sourceTaskId,
      choiceId: target.intent.choiceId,
    );
    if (intentGoal != null && intentGoal.goalId == target.intent.goalId) {
      return 'Review: ${intentGoal.learnerGoalLabel}';
    }
    final receipt = _Act0NextUsefulHandReasonReceiptV1.forRepairIntent(
      sourceTaskId: sourceTaskId,
      target: target,
    );
    final copyLine = _Act0NextUsefulHandCopyBridgeV1.fromReceipt(
      receipt,
    ).renderedCopyLine.trim();
    return copyLine.isEmpty ? null : copyLine;
  }

  int _mistakePriority(Act0MistakeCardV1 mistake) {
    final severity = switch (mistake.severityLabel) {
      'Deep leak' => 300,
      'Needs repair' => 200,
      'Recheck' => 150,
      'Quick fix' => 100,
      _ => 0,
    };
    return severity + mistake.attempts.clamp(0, 99);
  }

  List<Act0MistakeCardV1> _fixedMistakes() {
    final fixed = <Act0MistakeCardV1>[];
    final emittedTaskIds = <String>{};
    for (final record in _mistakeRecords.values) {
      if (!_resolvedMistakeTaskIds.contains(record.taskId)) {
        continue;
      }
      if (_owesMappedRepairV1(record.taskId)) {
        // Shown as the open mapped repair, not as a finished fix.
        emittedTaskIds.add(record.taskId);
        continue;
      }
      fixed.add(
        _retentionReviewCardForTaskV1(
          taskId: record.taskId,
          record: record,
          entry: _retentionMemoryByTaskId[record.taskId],
        ),
      );
      emittedTaskIds.add(record.taskId);
    }
    for (final entry in _retentionMemoryByTaskId.values) {
      if (emittedTaskIds.contains(entry.taskId) ||
          (_mistakeRecords.containsKey(entry.taskId) &&
              !_isMistakeDischargedV1(entry.taskId)) ||
          entry.status == _Act0RetentionMemoryStatusV1.openRepair) {
        continue;
      }
      fixed.add(
        _retentionReviewCardForTaskV1(taskId: entry.taskId, entry: entry),
      );
      emittedTaskIds.add(entry.taskId);
    }
    fixed.sort((a, b) {
      final priority = _fixedReviewPriorityV1(
        b,
      ).compareTo(_fixedReviewPriorityV1(a));
      if (priority != 0) {
        return priority;
      }
      return a.taskId.compareTo(b.taskId);
    });
    return fixed;
  }

  int _fixedReviewPriorityV1(Act0MistakeCardV1 mistake) {
    return switch (mistake.severityLabel) {
      'Recheck' => 300,
      'Quick fix' => 100,
      _ => 200,
    };
  }

  Act0MistakeCardV1? _topRetentionReplayCardV1(
    String status, {
    Set<String>? excludedTaskIds,
  }) {
    final blockedTaskIds = excludedTaskIds ?? const <String>{};
    final entries = _retentionMemoryByTaskId.values
        .where((entry) {
          return entry.status == status &&
              !blockedTaskIds.contains(entry.taskId);
        })
        .toList(growable: false);
    if (entries.isEmpty) {
      return null;
    }
    entries.sort((a, b) {
      final primary = switch (status) {
        _Act0RetentionMemoryStatusV1.agedRecheck => a.fixedAtSequence.compareTo(
          b.fixedAtSequence,
        ),
        _Act0RetentionMemoryStatusV1.ownedCandidate =>
          a.lastRecheckSequence.compareTo(b.lastRecheckSequence),
        _ => a.taskId.compareTo(b.taskId),
      };
      if (primary != 0) {
        return primary;
      }
      return a.taskId.compareTo(b.taskId);
    });
    final entry = entries.first;
    return _retentionReviewCardForTaskV1(taskId: entry.taskId, entry: entry);
  }

  Act0MistakeCardV1 _retentionReviewCardForTaskV1({
    required String taskId,
    _Act0MistakeRecordV1? record,
    _Act0RetentionMemoryEntryV1? entry,
  }) {
    if (record != null &&
        entry?.status != _Act0RetentionMemoryStatusV1.agedRecheck &&
        entry?.status != _Act0RetentionMemoryStatusV1.ownedCandidate) {
      return record.toCard(
        resolved: true,
        completionState: _perfectTaskIds().contains(record.taskId)
            ? Act0CompletionDisplayStateV1.perfect
            : (_cleanTaskIds.contains(record.taskId)
                  ? Act0CompletionDisplayStateV1.clear
                  : null),
        qualityLine: _perfectTaskIds().contains(record.taskId)
            ? _copyV1(en: 'Perfect clear complete.', ru: 'Идеально пройдено.')
            : (_cleanTaskIds.contains(record.taskId)
                  ? _copyV1(
                      en: 'Clear path still open.',
                      ru: 'Путь к идеалу открыт.',
                    )
                  : ''),
      );
    }
    final state = _catalogStateV1;
    final lessonId = entry?.lessonId ?? record?.lessonId ?? '';
    final lesson = state.lessonById(lessonId);
    final task = lesson.taskList.firstWhere(
      (candidate) => candidate.taskId == taskId,
      orElse: () => lesson.taskList.first,
    );
    final correctOption = task.runner.options.firstWhere(
      act0RunnerOptionIsPreferredV1,
      orElse: () => task.runner.options.isEmpty
          ? const Act0RunnerOptionV1(
              id: '',
              label: '',
              isCorrect: true,
              preferredLabel: '',
              quality: Act0FeedbackQualityV1.correct,
              feedbackTitle: '',
              feedbackReason: '',
            )
          : task.runner.options.first,
    );
    final replayStatus = entry?.status;
    final stableOwned = entry != null && _isStableOwnedCandidateV1(entry);
    final completionState =
        replayStatus == _Act0RetentionMemoryStatusV1.ownedCandidate
        ? (_perfectTaskIds().contains(taskId)
              ? Act0CompletionDisplayStateV1.perfect
              : Act0CompletionDisplayStateV1.clear)
        : null;
    return Act0MistakeCardV1(
      taskId: taskId,
      lessonId: lesson.lessonId,
      worldId: entry?.worldId ?? record?.worldId ?? '',
      title: _localizedTaskTitleV1(task),
      weaknessLabel: _categoryForLesson(lesson.lessonId),
      selectedOptionId: record?.selectedOptionId ?? '',
      selectedLabel:
          record?.selectedLabel ?? _copyV1(en: 'Review', ru: 'Повтор'),
      betterLabel: record?.betterLabel ?? correctOption.betterAnswerLabel,
      reason: record?.reason ?? correctOption.feedbackReason,
      attempts: entry?.attempts ?? record?.attempts ?? 0,
      severityLabel: replayStatus == _Act0RetentionMemoryStatusV1.agedRecheck
          ? 'Recheck'
          : replayStatus == _Act0RetentionMemoryStatusV1.ownedCandidate &&
                stableOwned
          ? 'Kept sharp'
          : (record?.attempts == 1 ? 'Quick fix' : 'Clear'),
      contextLabels: record?.contextLabels ?? const <String>[],
      repairActionLabel:
          replayStatus == _Act0RetentionMemoryStatusV1.agedRecheck
          ? _copyV1(en: 'Prove it again', ru: 'Подтверди ещё раз')
          : replayStatus == _Act0RetentionMemoryStatusV1.ownedCandidate &&
                stableOwned
          ? _copyV1(en: 'Keep sharp', ru: 'Держи острым')
          : _repairActionLabel(task),
      resolved: true,
      completionState: completionState,
      qualityLine: switch (replayStatus) {
        _Act0RetentionMemoryStatusV1.agedRecheck => _copyV1(
          en: 'Still yours? One calm replay keeps it honest.',
          ru: 'Ещё твоё? Один спокойный повтор это подтвердит.',
        ),
        _Act0RetentionMemoryStatusV1.ownedCandidate => _copyV1(
          en: stableOwned
              ? 'Skill holding. One light replay keeps it sharp.'
              : 'Proved once. One more clean replay will keep it honest.',
          ru: stableOwned
              ? 'Навык держится. Один лёгкий повтор сохранит остроту.'
              : 'Один раз подтверждено. Ещё один чистый повтор закрепит это.',
        ),
        _ =>
          _perfectTaskIds().contains(taskId)
              ? _copyV1(en: 'Perfect clear complete.', ru: 'Идеально пройдено.')
              : _copyV1(
                  en: 'Clear path still open.',
                  ru: 'Путь к идеалу открыт.',
                ),
      },
    );
  }

  List<Act0MistakeCardV1> _quickFixMistakes() => [
    for (final mistake in _fixedMistakes())
      if (mistake.severityLabel == 'Quick fix') mistake,
  ];

  List<Act0MistakeCardV1> _deepLeakMistakes() => [
    for (final mistake in _openMistakes())
      if (mistake.severityLabel == 'Deep leak') mistake,
  ];

  List<String> _strongCategories() {
    final categories = <String>{};
    for (final taskId in _cleanTaskIds) {
      if (_hasOpenMistakeRecord(taskId)) {
        continue;
      }
      final lesson = _lessonForTaskId(taskId);
      if (lesson != null) {
        categories.add(_categoryForLesson(lesson.lessonId));
      }
    }
    return categories.take(4).toList();
  }

  List<String> _weakCategories() {
    final categories = <String>{};
    for (final mistake in _openMistakes()) {
      categories.add(mistake.weaknessLabel);
    }
    return categories.take(4).toList();
  }

  List<String> _recentProgress() {
    final items = <String>[];
    for (final taskId in _completedTaskIds.toList().reversed) {
      final task = _taskForId(taskId);
      if (task != null) {
        items.add(task.title);
        if (_isRuLocaleV1) {
          items[items.length - 1] = _localizedTaskTitleV1(task);
        }
      }
      if (items.length == 4) {
        break;
      }
    }
    return items;
  }

  void _seedProfileSkillStats(List<Act0PlacementSkillStatV1> stats) {
    for (final stat in stats) {
      _profileSkillValues[_canonicalSkillLabel(stat.label)] = stat.value;
    }
  }

  void _incrementSkillStatsForCorrectAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    final deltas = _skillDeltaForAnswer(selectedLesson, selectedTask);
    _mergeSkillGainCountsV1(_lessonRunSkillGainCounts, deltas);
    for (final entry in deltas.entries) {
      final current = _profileSkillValues[entry.key] ?? 0;
      _profileSkillValues[entry.key] = (current + entry.value).clamp(0, 99);
      _pushRecentSkillGain(
        label: entry.key,
        gain: entry.value,
        source: selectedTask.title,
      );
    }
  }

  void _mergeSkillGainCountsV1(
    Map<String, int> target,
    Map<String, int> deltas,
  ) {
    for (final entry in deltas.entries) {
      target[entry.key] = (target[entry.key] ?? 0) + entry.value;
    }
  }

  Map<String, int> _deriveSkillValuesFromCompletedTasks(Set<String> taskIds) {
    final values = <String, int>{};
    for (final taskId in taskIds) {
      final lesson = _lessonForTaskId(taskId);
      final task = lesson == null ? null : _taskForId(taskId);
      if (lesson == null || task == null) {
        continue;
      }
      final deltas = _skillDeltaForTask(lesson.lessonId, task.taskId);
      for (final entry in deltas.entries) {
        values[entry.key] = ((values[entry.key] ?? 0) + entry.value).clamp(
          0,
          99,
        );
      }
    }
    return values;
  }

  Map<String, int> _skillDeltaForTask(String lessonId, String taskId) {
    final exact = _taskSkillDeltasV1[taskId];
    if (exact != null) {
      return exact;
    }
    if (taskId.startsWith('positions_')) {
      return const <String, int>{'Position play': 4, 'Table sense': 2};
    }
    if (taskId.startsWith('blinds_')) {
      return const <String, int>{'Blind play': 4, 'Table sense': 2};
    }
    if (taskId.startsWith('actions_') ||
        taskId.contains('fold') ||
        taskId.contains('check') ||
        taskId.contains('call') ||
        taskId.contains('raise') ||
        taskId.contains('bet')) {
      return const <String, int>{'Betting decisions': 4, 'Table sense': 1};
    }
    if (taskId.startsWith('hand_rankings_') || taskId.startsWith('showdown_')) {
      return taskId.contains('best_five') ||
              taskId.contains('straight') ||
              taskId.contains('flush')
          ? const <String, int>{'Hand reading': 3, 'Board reading': 2}
          : const <String, int>{'Hand reading': 4, 'Board reading': 1};
    }
    if (taskId.contains('board') ||
        taskId.contains('river') ||
        taskId.contains('flop') ||
        taskId.contains('turn')) {
      return const <String, int>{'Board reading': 4, 'Hand reading': 1};
    }
    return switch (lessonId) {
      'what_poker_is' => <String, int>{'Table sense': 5},
      'cards_ranks_suits' => <String, int>{
        'Board reading': 3,
        'Hand reading': 2,
      },
      'your_first_hand' => <String, int>{
        'Table sense': 2,
        'Board reading': 2,
        'Betting decisions': 1,
      },
      'fold_check_call_raise' => <String, int>{
        'Betting decisions': 4,
        'Table sense': 1,
      },
      'blinds_action_order' => <String, int>{'Blind play': 4, 'Table sense': 2},
      'positions' => <String, int>{'Position play': 4, 'Table sense': 2},
      'hand_rankings_table' => <String, int>{'Hand reading': 4},
      'showdown_winning' => <String, int>{
        'Hand reading': 4,
        'Board reading': 1,
      },
      _ =>
        taskId.contains('blind')
            ? <String, int>{'Blind play': 3}
            : <String, int>{'Table sense': 2},
    };
  }

  Map<String, int> _skillDeltaForAnswer(
    Act0LessonCardV1 selectedLesson,
    Act0LessonTaskV1 selectedTask,
  ) {
    return _skillDeltaForTask(selectedLesson.lessonId, selectedTask.taskId);
  }

  void _pushRecentSkillGain({
    required String label,
    required int gain,
    required String source,
  }) {
    _recentSkillGains.insert(
      0,
      Act0SkillGainV1(label: label, gain: gain, source: source),
    );
    if (_recentSkillGains.length > 6) {
      _recentSkillGains.removeRange(6, _recentSkillGains.length);
    }
  }

  List<Act0SkillGainV1> _skillGainsFromMapV1(
    Map<String, int> deltas, {
    required String source,
  }) {
    final entries = deltas.entries.toList()
      ..sort((a, b) {
        final gainCompare = b.value.compareTo(a.value);
        if (gainCompare != 0) {
          return gainCompare;
        }
        return a.key.compareTo(b.key);
      });
    return <Act0SkillGainV1>[
      for (final entry in entries.take(3))
        Act0SkillGainV1(label: entry.key, gain: entry.value, source: source),
    ];
  }

  bool _isTaskCompletingLessonMilestoneV1({
    required Act0LessonCardV1 lesson,
    required String taskId,
  }) {
    if (_nextTask(lesson, taskId) == null) {
      return true;
    }
    return _activeLessonWrapUpTaskId == taskId;
  }

  Map<String, int> _aggregateSkillDeltasForWorldV1(Act0WorldCardV1 world) {
    final totals = <String, int>{};
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        _mergeSkillGainCountsV1(
          totals,
          _skillDeltaForTask(lesson.lessonId, task.taskId),
        );
      }
    }
    return totals;
  }

  int _completedTaskCountForWorldV1(Act0WorldCardV1 world) {
    var count = 0;
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        if (_completedTaskIds.contains(task.taskId)) {
          count += 1;
        }
      }
    }
    return count;
  }

  int _perfectTaskCountForWorldV1(Act0WorldCardV1 world) {
    final perfectTaskIds = _perfectTaskIds();
    var count = 0;
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        if (perfectTaskIds.contains(task.taskId)) {
          count += 1;
        }
      }
    }
    return count;
  }

  int _openMistakeCountForLessonV1(Act0LessonCardV1 lesson) {
    var count = 0;
    for (final task in lesson.taskList) {
      if (_hasOpenMistakeRecord(task.taskId)) {
        count += 1;
      }
    }
    return count;
  }

  int _openMistakeCountForWorldV1(Act0WorldCardV1 world) {
    var count = 0;
    for (final lesson in world.lessons) {
      count += _openMistakeCountForLessonV1(lesson);
    }
    return count;
  }

  List<Act0SkillGainV1> _profileRecentSkillGains(
    List<Act0SkillGainV1> baseGains,
  ) {
    if (_recentSkillGains.isNotEmpty) {
      return _recentSkillGains.take(4).toList();
    }
    return _usesPersistedProgress ? const <Act0SkillGainV1>[] : baseGains;
  }

  List<Act0PlacementSkillStatV1> _profileSkillStats(
    List<Act0PlacementSkillStatV1> baseStats,
  ) {
    const statOrder = <String>[
      'Table sense',
      'Board reading',
      'Hand reading',
      'Betting decisions',
      'Position play',
      'Blind play',
    ];

    final seededValues = <String, int>{
      if (!_usesPersistedProgress)
        for (final stat in baseStats)
          _canonicalSkillLabel(stat.label): stat.value,
      ..._profileSkillValues,
    };

    return <Act0PlacementSkillStatV1>[
      for (final label in statOrder)
        Act0PlacementSkillStatV1.core(
          label: label,
          value: seededValues[label] ?? 0,
          locked: !seededValues.containsKey(label),
        ),
    ];
  }

  String _canonicalSkillLabel(String label) {
    return switch (label) {
      'Situational awareness' || 'Hand flow' || 'Table flow' => 'Table sense',
      'Action decisions' ||
      'Betting choices' ||
      'Calm under pressure' => 'Betting decisions',
      'Blind defense' || '3-bet pots' || '3-bet game' => 'Blind play',
      'Showdown reading' => 'Hand reading',
      _ => label,
    };
  }

  List<Act0LessonCardV1> _allLessons() => [
    for (final world in _catalogStateV1.worlds) ...world.lessons,
  ];

  Act0LessonCardV1? _lessonForTaskId(String taskId) {
    for (final lesson in _allLessons()) {
      if (lesson.taskList.any((task) => task.taskId == taskId)) {
        return lesson;
      }
    }
    return null;
  }

  Act0LessonTaskV1? _taskForId(String taskId) {
    final lesson = _lessonForTaskId(taskId);
    if (lesson == null) {
      return null;
    }
    return lesson.taskList.firstWhere(
      (task) => task.taskId == taskId,
      orElse: () => lesson.taskList.first,
    );
  }

  String _categoryForLesson(String lessonId) {
    return switch (lessonId) {
      'what_poker_is' => 'Table',
      'cards_ranks_suits' => 'Cards',
      'your_first_hand' => 'Streets',
      'fold_check_call_raise' => 'Actions',
      'blinds_action_order' => 'Blinds',
      'positions' => 'Positions',
      'hand_rankings_table' => 'Rankings',
      'showdown_winning' => 'Showdown',
      _ => 'Practice',
    };
  }
}
