part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewHomeV1 on _Act0ShellPreviewScreenV1State {
  List<Act0WorldCardV1> _progressWorlds(Act0ShellStateV1 state) {
    return _progressWorldsWithTaskIds(state, _pathClosedTaskIds);
  }

  List<Act0WorldCardV1> _progressWorldsWithTaskIds(
    Act0ShellStateV1 state,
    Set<String> completedTaskIds, {
    int? w1RulesBestScore,
  }) => act0ProgressWorldsV1(
    state.worlds,
    pathClosedTaskIds: completedTaskIds,
    earnedTaskIds: _completedTaskIds,
    passedW1RulesCheck:
        (w1RulesBestScore ?? _w1RulesBestScoreV1) >=
        Act0W1RulesResultV1.passingScore,
  );

  List<Act0WorldCardV1> _progressedWorlds(Act0ShellStateV1 state) =>
      _progressWorlds(state);

  List<Act0PracticeGroupV1> _practiceGroups({
    required Act0ShellStateV1 state,
    required Act0WorldCardV1 world,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final currentTask = _firstIncompleteTask(selectedLesson);
    final openMistake = _topOpenMistake();
    final quickFix = _quickFixMistakes().isEmpty
        ? null
        : _quickFixMistakes().first;
    final repairCandidate = openMistake ?? quickFix;
    final hasOpenRepair = openMistake != null;
    final recommendation = _learningRecommendation(
      selectedWorld: world,
      selectedLesson: selectedLesson,
    );
    final dailyDeckEntry = _nextDailyDeckEntry(state: state);
    return <Act0PracticeGroupV1>[
      Act0PracticeGroupV1(
        groupId: 'continue',
        title: _copyV1(en: 'Continue lesson', ru: 'Продолжить урок'),
        subtitle:
            '${_localizedLessonTitleV1(selectedLesson)}: ${act0PrechoiceDisplayTitleV1(taskId: currentTask.taskId, authoredTitle: _localizedTaskTitleV1(currentTask), isAssessment: act0IsPrechoiceAssessmentTaskV1(currentTask), hasSubmittedCurrentDecision: false)}',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        categoryLabel: 'Next lesson step',
        isEnabled: selectedLesson.isSelectable,
        targetLessonId: selectedLesson.lessonId,
        targetTaskId: currentTask.taskId,
        sessionLabel: 'Best next',
        durationLabel: '~5 min',
        isRecommended: recommendation.practiceGroupId == 'continue',
      ),
      Act0PracticeGroupV1(
        groupId: 'placement',
        title: 'Find my level',
        subtitle: 'Answer a short table spot before we tune your start point.',
        ctaLabel: 'Start check',
        categoryLabel: 'Placement',
        isEnabled: true,
        targetLessonId: selectedLesson.lessonId,
        targetTaskId: currentTask.taskId,
        countLabel: 'Preview',
        sessionLabel: 'Diagnostic',
        durationLabel: '~3 min',
        isRecommended: recommendation.practiceGroupId == 'placement',
      ),
      Act0PracticeGroupV1(
        groupId: 'weak_spots',
        title:
            repairCandidate?.title ??
            _copyV1(
              en: 'Review one quick fix',
              ru: 'Сделай один лёгкий повтор',
            ),
        subtitle: repairCandidate == null
            ? _copyV1(
                en: 'Quick fixes unlock after you repair one spot in Review.',
                ru: 'Лёгкие повторы откроются после одного разбора во вкладке Разбор.',
              )
            : hasOpenRepair
            ? recommendation.subtitle
            : 'One light review keeps this quick fix stable.',
        ctaLabel: repairCandidate != null
            ? hasOpenRepair
                  ? recommendation.ctaLabel
                  : _recommendationCtaLabel(
                      _Act0LearningNextActionKindV1.reviewQuickFix,
                    )
            : 'Review',
        categoryLabel: 'Repair',
        isEnabled: repairCandidate != null,
        targetLessonId: repairCandidate?.lessonId,
        targetTaskId: repairCandidate?.taskId,
        countLabel: repairCandidate == null
            ? ''
            : hasOpenRepair
            ? '${_openMistakes().length} open'
            : '${_quickFixMistakes().length} ready',
        sessionLabel: hasOpenRepair ? 'Repair' : 'Quick fix',
        durationLabel: '~4 min',
        isRecommended: recommendation.practiceGroupId == 'weak_spots',
        skipTeaching: true,
        allowDrillBypass: true,
        useRapidPracticeLoop: false,
      ),
      Act0PracticeGroupV1(
        groupId: 'daily',
        title: dailyDeckEntry == null
            ? 'Daily practice'
            : _dailyPracticeQueue.nextTaskId != null
            ? 'Resume your short set'
            : _dailyPracticeQueue.taskIds.isNotEmpty
            ? 'Start a new short set'
            : 'Practice a short set',
        subtitle: dailyDeckEntry == null
            ? 'Unlocks as you work through lessons.'
            : 'Practice up to three different completed spots. Start a new set when it ends.',
        ctaLabel: _dailyPracticeQueue.nextTaskId != null
            ? 'Resume practice'
            : _dailyPracticeQueue.taskIds.isNotEmpty
            ? 'Start new set'
            : 'Start practice',
        categoryLabel: 'Daily',
        isEnabled: dailyDeckEntry != null,
        targetWorldId: dailyDeckEntry?.worldId,
        targetLessonId: dailyDeckEntry?.lessonId,
        targetTaskId: dailyDeckEntry?.taskId,
        countLabel: _dailyGoalValueLabel(),
        sessionLabel: 'Up to 3 spots',
        durationLabel: '~3 min',
        isRecommended: recommendation.practiceGroupId == 'daily',
        skipTeaching: true,
        allowDrillBypass: true,
        useRapidPracticeLoop: true,
      ),
      ..._topicPackSpecsV1.map(
        (spec) => _groupForTaskPack(
          state,
          spec: spec,
          isRecommended: recommendation.practiceGroupId == spec.groupId,
        ),
      ),
    ];
  }

  _Act0DailyDeckEntryV1? _nextDailyDeckEntry({
    required Act0ShellStateV1 state,
  }) {
    final deck = _dailyDeckEntries(state);
    if (deck.isEmpty) {
      return null;
    }
    final eligible = deck.map((entry) => entry.taskId).toSet();
    final queue =
        _dailyPracticeQueue.isValidFor(eligible) &&
            _dailyPracticeQueue.nextTaskId != null
        ? _dailyPracticeQueue
        : Act0DailyPracticeQueueV1.start(
            eligible,
            practicedToday: _dailyCompletedTaskIds,
          );
    final nextTaskId = queue.nextTaskId;
    return nextTaskId == null
        ? null
        : deck.firstWhere((entry) => entry.taskId == nextTaskId);
  }

  List<_Act0DailyDeckEntryV1> _dailyDeckEntries(Act0ShellStateV1 state) {
    final practiceWorlds = _progressedWorlds(state)
        .where(
          (world) =>
              world.isSelectable &&
              world.worldNumber >= 1 &&
              world.worldNumber <= 4,
        )
        .toList(growable: false);
    if (practiceWorlds.isEmpty) {
      return const <_Act0DailyDeckEntryV1>[];
    }
    final tasksByWorldId = <String, List<_Act0DailyDeckEntryV1>>{};
    for (final world in practiceWorlds) {
      final entries = <_Act0DailyDeckEntryV1>[];
      for (final lesson in world.lessons) {
        if (!lesson.isSelectable) {
          continue;
        }
        for (final task in lesson.taskList) {
          if (task.phase != Act0LessonPhaseV1.drill ||
              !_completedTaskIds.contains(task.taskId)) {
            continue;
          }
          entries.add(
            _Act0DailyDeckEntryV1(
              worldId: world.worldId,
              lessonId: lesson.lessonId,
              taskId: task.taskId,
              isSpaced: true,
            ),
          );
        }
      }
      if (entries.isNotEmpty) {
        tasksByWorldId[world.worldId] = entries;
      }
    }
    if (tasksByWorldId.isEmpty) {
      return const <_Act0DailyDeckEntryV1>[];
    }
    final worldOrder = practiceWorlds
        .map((world) => world.worldId)
        .where(tasksByWorldId.containsKey)
        .toList(growable: false);
    final deck = <_Act0DailyDeckEntryV1>[];
    var hasAny = true;
    while (hasAny) {
      hasAny = false;
      for (final worldId in worldOrder) {
        final entries = tasksByWorldId[worldId]!;
        if (entries.isEmpty) {
          continue;
        }
        deck.add(entries.removeAt(0));
        hasAny = true;
      }
    }
    return deck;
  }

  _Act0LearningRecommendationV1 _learningRecommendation({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final topMistake = _topOpenMistake();
    if (topMistake != null) {
      final isDeep =
          topMistake.severityLabel == 'Deep leak' ||
          topMistake.severityLabel == 'Deep repair';
      final repairIntentTarget = _openRepairIntentTargetForSourceTaskV1(
        topMistake.taskId,
        includeOwed: true,
      );
      return _Act0LearningRecommendationV1(
        kind: isDeep
            ? _Act0LearningNextActionKindV1.repairDeepLeak
            : _Act0LearningNextActionKindV1.repairWeakSpot,
        label: isDeep
            ? _copyV1(en: 'Deep repair', ru: 'Серьёзный разбор')
            : _copyV1(en: 'Needs work', ru: 'Нужно подтянуть'),
        title: isDeep
            ? _copyV1(
                en: 'Practice one deep spot',
                ru: 'Разбери один серьёзный спот',
              )
            : _copyV1(
                en: 'Repair one weak spot',
                ru: 'Разбери одно слабое место',
              ),
        subtitle: isDeep
            ? _copyV1(
                en: 'This spot missed twice. Repair it before moving on.',
                ru: 'Этот спот уже дважды не дался. Разбери его, прежде чем идти дальше.',
              )
            : _copyV1(
                en: 'Repeat the table clue before it becomes a habit.',
                ru: 'Разбери этот спот, пока он не закрепился.',
              ),
        ctaLabel: _recommendationCtaLabel(
          isDeep
              ? _Act0LearningNextActionKindV1.repairDeepLeak
              : _Act0LearningNextActionKindV1.repairWeakSpot,
        ),
        hint: _copyV1(
          en: 'Repeat the table clue before it becomes a habit.',
          ru: 'Разбери этот спот сейчас.',
        ),
        outcome: isDeep
            ? _copyV1(
                en: 'Deep repair first: practice ${_playDrillTitleForLesson(topMistake.lessonId)}.',
                ru: 'Сначала разбери серьёзную ошибку: ${_playDrillTitleForLesson(topMistake.lessonId)}.',
              )
            : _copyV1(
                en: 'On repair: return to ${_playDrillTitleForLesson(topMistake.lessonId)}.',
                ru: 'После разбора вернись к ${_playDrillTitleForLesson(topMistake.lessonId)}.',
              ),
        mistake: topMistake,
        lessonId: repairIntentTarget?.target.lessonId ?? topMistake.lessonId,
        taskId: repairIntentTarget?.target.taskId ?? topMistake.taskId,
        practiceGroupId: 'weak_spots',
      );
    }

    final quickFix = _quickFixMistakes().isEmpty
        ? null
        : _quickFixMistakes().first;
    // Fixed does not mean due. Never promise an immediate Review CTA
    // when the durable spaced-review owner has no launchable due item.
    final quickFixDue =
        quickFix != null &&
        _dueReviewItemsV1().any((item) => item.taskId == quickFix.taskId);
    if (quickFix != null && quickFixDue) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.reviewQuickFix,
        label: _copyV1(en: 'Quick fix', ru: 'Лёгкий повтор'),
        title: _copyV1(en: 'Review a quick fix', ru: 'Сделай лёгкий повтор'),
        subtitle: _copyV1(
          en: 'You repaired this spot once. A later spaced review can show whether it holds.',
          ru: 'Ты один раз исправил этот спот. Позже повтор с интервалом покажет, удержалось ли чтение.',
        ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.reviewQuickFix,
        ),
        hint: _copyV1(
          en: 'Light review in Review.',
          ru: 'Сделай лёгкий повтор во вкладке Разбор.',
        ),
        outcome: _copyV1(
          en: 'Light review: keep ${_playDrillTitleForLesson(quickFix.lessonId)} warm.',
          ru: 'Лёгкий повтор: ещё раз спокойно пройди ${_playDrillTitleForLesson(quickFix.lessonId)}.',
        ),
        mistake: quickFix,
        lessonId: quickFix.lessonId,
        taskId: quickFix.taskId,
        practiceGroupId: 'weak_spots',
      );
    }

    final currentTask = _firstIncompleteTask(selectedLesson);

    if (_dailyCompletedRepCount >= 3 && _openMistakes().isEmpty) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDone,
        label: _copyV1(en: 'Done for today', ru: 'На сегодня всё'),
        title: _copyV1(en: 'Practice complete', ru: 'Практика завершена'),
        subtitle: _copyV1(
          en: 'Your practice is saved. Come back whenever you’re ready.',
          ru: 'Ответы сохранены. Возвращайся, когда захочешь.',
        ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDone,
        ),
        hint: '',
        outcome: _copyV1(
          en: 'Continue your course whenever you’re ready.',
          ru: 'Продолжай курс, когда захочешь.',
        ),
        lessonId: selectedLesson.lessonId,
        taskId: null,
        practiceGroupId: 'daily',
      );
    }

    if (!_completedTaskIds.contains(currentTask.taskId)) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.continueLesson,
        label: _cleanTaskIds.isEmpty && _completedTaskIds.isEmpty
            ? _copyV1(en: 'Start here', ru: 'Начни здесь')
            : _copyV1(en: 'Continue', ru: 'Продолжить'),
        title: _localizedLessonTitleV1(selectedLesson),
        subtitle: _localizedLessonSubtitleV1(selectedLesson),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        hint: _copyV1(
          en: 'Continue this lesson now.',
          ru: 'Продолжи этот урок сейчас.',
        ),
        outcome:
            _nextLesson(selectedWorld.lessons, selectedLesson.lessonId) == null
            ? _copyV1(
                en: 'Pick up with the next hand when you return.',
                ru: 'Когда вернёшься, просто продолжай чистый проход.',
              )
            : _copyV1(
                en: 'On return: ${_nextLesson(selectedWorld.lessons, selectedLesson.lessonId)!.title} stays next to unlock.',
                ru: 'Когда вернёшься, следующим для открытия останется ${act0LocalizedLessonTitleAtomByIdV1(_nextLesson(selectedWorld.lessons, selectedLesson.lessonId)!.lessonId, fallback: _nextLesson(selectedWorld.lessons, selectedLesson.lessonId)!.title, isRu: _isRuLocaleV1)}.',
              ),
        lessonId: selectedLesson.lessonId,
        taskId: currentTask.taskId,
        practiceGroupId: 'continue',
      );
    }

    final dailyDeckEntry = _nextDailyDeckEntry(
      state: widget.state ?? Act0ShellStateV1.sample,
    );
    if (_dailyCompletedRepCount < 3 &&
        dailyDeckEntry != null &&
        (_dailyPracticeQueue.taskIds.isEmpty ||
            _dailyPracticeQueue.nextTaskId != null)) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDrill,
        label: _copyV1(en: 'Daily set', ru: 'Дневная серия'),
        title: _copyV1(en: 'Start a short rep', ru: 'Начать короткий повтор'),
        subtitle: _copyV1(
          en: 'Choose a short set whenever you’re ready.',
          ru: 'Пройди три коротких спота, чтобы держать день в ритме.',
        ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDrill,
        ),
        hint: _copyV1(
          en: 'Short rep in Practice.',
          ru: 'Быстрый дневной дрилл во вкладке Практика.',
        ),
        outcome: _copyV1(
          en: 'Practice up to three spots.',
          ru: 'Дневной набор: 3 чётких спота без лишнего шума.',
        ),
        lessonId: dailyDeckEntry.lessonId,
        taskId: dailyDeckEntry.taskId,
        practiceGroupId: 'daily',
      );
    }

    if (_dailyCompletedRepCount >= 3 && _openMistakes().isEmpty) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.dailyDone,
        label: 'Done for today',
        title: 'Practice complete',
        subtitle: 'Your practice is saved. Come back whenever you’re ready.',
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.dailyDone,
        ),
        hint: '',
        outcome: 'Continue your course whenever you’re ready.',
        lessonId: selectedLesson.lessonId,
        taskId: null,
        practiceGroupId: 'daily',
      );
    }

    final categoryPracticeTarget = _topicPackLaunchTarget(
      widget.state ?? Act0ShellStateV1.sample,
      _topicPackSpecsV1.first,
    );
    if (categoryPracticeTarget == null) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.continueLesson,
        label: _copyV1(en: 'Keep going', ru: 'Продолжай'),
        title: _localizedLessonTitleV1(selectedLesson),
        subtitle: _copyV1(
          en: 'Practice unlocks from reps you already cleared on the route.',
          ru: 'Практика открывается из спотов, которые ты уже закрыл на маршруте.',
        ),
        ctaLabel: _recommendationCtaLabel(
          _Act0LearningNextActionKindV1.continueLesson,
        ),
        hint: _copyV1(
          en: 'Clear one more route rep first.',
          ru: 'Сначала закрой ещё один спот на маршруте.',
        ),
        outcome: _copyV1(
          en: 'On return: Practice will repeat what you already know.',
          ru: 'Когда вернёшься, Практика будет повторять то, что ты уже знаешь.',
        ),
        lessonId: selectedLesson.lessonId,
        taskId: currentTask.taskId,
        practiceGroupId: 'continue',
      );
    }
    return _Act0LearningRecommendationV1(
      kind: _Act0LearningNextActionKindV1.categoryPractice,
      label: _copyV1(en: 'Keep going', ru: 'Продолжай'),
      title: _copyV1(en: 'Actions', ru: 'Действия'),
      subtitle: _copyV1(
        en: 'Lock in one core action pattern.',
        ru: 'Закрепи один базовый паттерн действий.',
      ),
      ctaLabel: _recommendationCtaLabel(
        _Act0LearningNextActionKindV1.categoryPractice,
      ),
      hint: _copyV1(
        en: 'Category practice in Play.',
        ru: 'Практика по категории во вкладке Практика.',
      ),
      outcome: _copyV1(
        en: 'Category practice: keep your strongest reads warm.',
        ru: 'Практика по категории: закрепи то, что уже хорошо читается.',
      ),
      lessonId: categoryPracticeTarget.lessonId,
      taskId: categoryPracticeTarget.taskId,
      practiceGroupId: 'actions',
    );
  }

  String _recommendationCtaLabel(_Act0LearningNextActionKindV1 kind) {
    return switch (kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => _copyV1(
        en: 'Practice this spot',
        ru: 'Разобрать этот спот',
      ),
      _Act0LearningNextActionKindV1.repairWeakSpot => _copyV1(
        en: 'Practice this spot',
        ru: 'Разобрать этот спот',
      ),
      _Act0LearningNextActionKindV1.reviewQuickFix => _copyV1(
        en: 'Review now',
        ru: 'Повторить сейчас',
      ),
      _Act0LearningNextActionKindV1.continueLesson => _copyV1(
        en: 'Continue',
        ru: 'Продолжить',
      ),
      _Act0LearningNextActionKindV1.dailyDrill => _copyV1(
        en: 'Start daily set',
        ru: 'Начать дневную серию',
      ),
      _Act0LearningNextActionKindV1.dailyDone => _copyV1(
        en: 'Practice extra reps',
        ru: 'Смотреть прогресс',
      ),
      _Act0LearningNextActionKindV1.categoryPractice => _copyV1(
        en: 'Practice',
        ru: 'Практика',
      ),
    };
  }

  String _homeNextActionLabel() {
    if (_placementHandoffActive) {
      return _copyV1(en: 'Start here', ru: 'Начни здесь');
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).label;
  }

  String _homeNextActionTitle(Act0LessonCardV1 currentLesson) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).title;
  }

  String _homeNextActionSubtitle(Act0LessonCardV1 currentLesson) {
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).subtitle;
  }

  String _homeNextActionCtaLabel() {
    if (_placementHandoffActive) {
      return _copyV1(en: 'Start first hand', ru: 'Начать первую раздачу');
    }
    final state = widget.state ?? Act0ShellStateV1.sample;
    final selectedWorld = _worldById(
      _progressedWorlds(state),
      _selectedWorldId,
    );
    final selectedLesson = _lessonById(
      selectedWorld.lessons,
      _selectedLessonId,
    );
    return _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    ).ctaLabel;
  }

  String? _homeCtaHint(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(
        en: 'One tap opens the first hand chosen from your placement result.',
        ru: 'Одно нажатие откроет первую раздачу, выбранную по результату плейсмента.',
      );
    }
    final hint = _homePrimaryRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    ).hint;
    if (hint == 'Continue this lesson now.') {
      return null;
    }
    return hint.isEmpty ? null : hint;
  }

  // A first-value repair cue is actionable only while the same source debt
  // remains open. Review may resolve it without consuming the Home cue.
  _Act0FirstValueReceiptCarryV1? get _actionableFirstValueReceiptCarryV1 {
    final carry = _firstValueReceiptCarry;
    if (carry != null && carry.isRepair) {
      final intent = _openRepairIntentBySourceTaskId[carry.sourceTaskId];
      if (intent == null ||
          intent.missedSignalId != carry.sourceSignalId ||
          intent.skillAtomId != carry.skillAtomId ||
          !_openMistakes().any(
            (mistake) => mistake.taskId == carry.sourceTaskId,
          )) {
        return null;
      }
    }
    return carry;
  }

  _Act0LearningRecommendationV1 _homePrimaryRecommendation({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
  }) {
    final firstValueCarry = _actionableFirstValueReceiptCarryV1;
    if (firstValueCarry != null) {
      return _Act0LearningRecommendationV1(
        kind: _Act0LearningNextActionKindV1.continueLesson,
        label: firstValueCarry.isRepair
            ? _copyV1(en: 'Repair', ru: 'Разбор')
            : _copyV1(en: 'Next', ru: 'Дальше'),
        title: firstValueCarry.homeTitle,
        subtitle: firstValueCarry.homeSubtitle,
        ctaLabel: _copyV1(en: 'Continue', ru: 'Продолжить'),
        hint: firstValueCarry.homeSubtitle,
        outcome: firstValueCarry.homeSubtitle,
        lessonId: selectedLesson.lessonId,
        taskId: _firstIncompleteTask(selectedLesson).taskId,
        practiceGroupId: 'continue',
      );
    }
    final repairRecommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    if (repairRecommendation.mistake != null) {
      return repairRecommendation;
    }
    final currentTask = _firstIncompleteTask(selectedLesson);
    final nextLesson = _nextLesson(
      selectedWorld.lessons,
      selectedLesson.lessonId,
    );
    // The W1 action-primer cue must not follow a learner into later worlds.
    // Reuse the current authored lesson subtitle for a truthful next step.
    final currentLessonCue = selectedWorld.worldId == 'world_1'
        ? _copyV1(
            en: 'Read the legal actions first so the first real hand is not a guess.',
            ru: 'Сначала прочитай доступные действия, чтобы первая реальная раздача не была угадайкой.',
          )
        : _localizedLessonSubtitleV1(selectedLesson).trim().isNotEmpty
        ? _localizedLessonSubtitleV1(selectedLesson).trim()
        : _copyV1(
            en: 'Continue with the next decision in this lesson.',
            ru: 'Продолжи со следующим решением в этом уроке.',
          );
    return _Act0LearningRecommendationV1(
      kind: _Act0LearningNextActionKindV1.continueLesson,
      label: _cleanTaskIds.isEmpty && _completedTaskIds.isEmpty
          ? _copyV1(en: 'Start here', ru: 'Начни здесь')
          : _copyV1(en: 'Next', ru: 'Дальше'),
      title: _localizedLessonTitleV1(selectedLesson),
      subtitle: currentLessonCue,
      ctaLabel: _copyV1(en: 'Continue', ru: 'Продолжить'),
      hint: currentLessonCue,
      outcome: nextLesson == null
          ? _copyV1(
              en: 'Pick up with the next hand when you return.',
              ru: 'Когда вернёшься, просто продолжай чистый проход.',
            )
          : _copyV1(
              en: 'On return: ${nextLesson.title} stays next to unlock.',
              ru: 'Когда вернёшься, следующим для открытия останется ${nextLesson.title}.',
            ),
      lessonId: selectedLesson.lessonId,
      taskId: currentTask.taskId,
      practiceGroupId: 'continue',
    );
  }

  _Act0NextUsefulHandReasonReceiptV1 _sharedHomeSummaryReceiptV1(
    Act0WorldCardV1 selectedWorld,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: _firstPlayableLesson(selectedWorld),
    );
    return _nextUsefulHandReasonReceiptV1(
      recommendation: recommendation,
      selectedWorld: selectedWorld,
      state: widget.state ?? Act0ShellStateV1.sample,
    );
  }

  String _sharedHomeSummaryReasonLineV1(
    _Act0NextUsefulHandReasonReceiptV1 receipt,
  ) {
    final english = _Act0NextUsefulHandCopyBridgeV1.fromReceipt(
      receipt,
    ).renderedCopyLine.trim();
    if (english.isEmpty) return '';
    return _copyV1(
      en: english,
      ru: receipt.selectionSource == 'repair_intent_exact_replay'
          ? 'Повтори исходный спот и проверь ту же подсказку без помощи.'
          : 'Исправь ту же ошибку на следующем споте. Сначала назови подсказку стола.',
    );
  }

  Act0SummaryNextHandoffV1 _summaryHomeHandoffV1(
    Act0WorldCardV1 selectedWorld,
  ) {
    final receipt = _sharedHomeSummaryReceiptV1(selectedWorld);
    return Act0SummaryNextHandoffV1(
      sourceTaskId: receipt.sourceTaskId,
      targetWorldId: receipt.targetWorldId,
      targetLessonId: receipt.targetLessonId,
      targetTaskId: receipt.targetTaskId,
      reasonCode: receipt.reasonCode,
      selectionSource: receipt.selectionSource,
      copyLine: _sharedHomeSummaryReasonLineV1(receipt),
    );
  }

  bool _firstCorrectReadEarnedInCurrentLessonRunV1() {
    final boundary = _lessonRunEvidenceStartOrderV1;
    if (boundary == null || _selectedLessonId.isEmpty) return false;
    // Earliest correct, non-assisted LESSON-run record. A placement answer is
    // assessment, not a read earned in this lesson run, so it is skipped here
    // (the achievement projection itself still counts it; recorded P2 N1).
    final eligible =
        _learningEvidenceHistoryV1.records
            .where(
              (record) =>
                  record.isCorrect &&
                  !record.isAssistedCorrect &&
                  !act0RecordIsAuthoredTeachingV1(record) &&
                  !record.isPlacementAssessment &&
                  !record.isDiagnosticLearningEntry,
            )
            .toList()
          ..sort((a, b) => a.createdOrder.compareTo(b.createdOrder));
    final first = eligible.firstOrNull;
    return first != null &&
        first.createdOrder > boundary &&
        first.lessonId == _selectedLessonId &&
        first.assistanceKind == Act0DecisionAssistanceV1.none;
  }

  String? _homeNextUsefulHandReasonLine(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 selectedLesson,
  ) {
    final receipt = _sharedHomeSummaryReceiptV1(selectedWorld);
    if (receipt.selectionSource != 'repair_intent_mapped' &&
        receipt.selectionSource != 'repair_intent_exact_replay') {
      return null;
    }
    final renderedLine = _sharedHomeSummaryReasonLineV1(receipt);
    return renderedLine.isEmpty ? null : renderedLine;
  }

  Act0PersonalizedReturnReasonV1 _personalizedNextStepV1(
    Act0ReviewStateV1 reviewState,
  ) {
    final availableTaskIds = reviewState.mistakes
        .map((mistake) => mistake.taskId)
        .toSet();
    final actionableIntents = _activeRepairIntentsV1()
        .where(
          (intent) =>
              availableTaskIds.contains(intent.sourceTaskId) &&
              _hasValidatedRepairTargetV1(intent),
        )
        .toList(growable: false);
    final actionableHistory = Act0ConceptFamilyStateHistoryV1(
      families: _conceptFamilyStateHistoryV1.families
          .where((family) {
            final retryIsUnavailable =
                (family.lastOutcome ==
                        act0ConceptFamilyOutcomeRepairNotYetSucceededV1 ||
                    family.repairAttemptCount > family.successfulRepairCount) &&
                !availableTaskIds.contains(family.lastTaskId);
            // An unavailable route is not a successful repair. Retain the
            // stored history and omit this unsupported recommendation.
            return !retryIsUnavailable;
          })
          .toList(growable: false),
      appliedSourceIds: _conceptFamilyStateHistoryV1.appliedSourceIds,
    );
    return Act0PersonalizedReturnReasonV1.fromSources(
      activeRepairIntents: actionableIntents,
      conceptFamilyStateHistory: actionableHistory,
      transferMeasurement:
          Act0LearningTransferMeasurementV1.fromLearningEvidence(
            _learningEvidenceHistoryV1,
            // Scheduling cache remains historical; current proof is replayed.
            nowUtc: widget.clock.nowUtc(),
          ),
      dueReviewItems: _dueReviewItemsV1(),
    );
  }

  String? _homePersonalizedReturnReasonLine() => _personalizedNextStepV1(
    _reviewState((widget.state ?? Act0ShellStateV1.sample).review),
  ).copyLine;

  void _schedulePersonalizedNextStepExposureV1(
    Act0PersonalizedReturnReasonV1 nextStep, {
    required String surface,
  }) {
    if (nextStep.reasonType == act0ReturnReasonNoPersonalReasonAvailableV1) {
      return;
    }
    final fingerprint =
        '$surface|${nextStep.reasonType}|${nextStep.recommendedAction}|${nextStep.rawEvidenceRef}';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          (_tab == Act0ShellTabV1.home
                  ? 'home'
                  : _tab == Act0ShellTabV1.review
                  ? 'review'
                  : '') !=
              surface) {
        return;
      }
      if (!_personalizedNextStepShownTelemetryKeysV1.add(fingerprint)) {
        return;
      }
      _recordTelemetryEventV1(
        'personalized_next_step_selected',
        <String, Object?>{
          // OBS-03: the privacy sink rejects unversioned events, which made
          // every real Home next-step route an incomplete incident trace.
          'schemaVersion': 1,
          'surface': surface,
          ...nextStep.toTelemetryPayload(),
        },
      );
    });
  }

  /// The due spaced-review item a personalized next step will actually launch.
  /// Shared by the Home primary card (what it says) and
  /// [_openPersonalizedNextStepV1] (what it opens) so they cannot disagree.
  Act0DueReviewItemV1? _launchableDueReviewV1(
    Act0PersonalizedReturnReasonV1 step,
  ) {
    if (step.recommendedAction != 'spaced_review') {
      return null;
    }
    return _dueReviewItemsV1().cast<Act0DueReviewItemV1?>().firstWhere(
      (item) => item?.taskId == step.sourceTaskId,
      orElse: () => null,
    );
  }

  void _recordPersonalizedNextStepOpenedV1(
    Act0PersonalizedReturnReasonV1 nextStep,
    String surface,
  ) => _recordTelemetryEventV1(
    'personalized_next_step_opened',
    <String, Object?>{
      'schemaVersion': 1,
      'surface': surface,
      ...nextStep.toTelemetryPayload(),
    },
  );

  String _homeRepairLabel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(en: 'Review', ru: 'Разбор');
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    return switch (recommendation.kind) {
      _Act0LearningNextActionKindV1.repairDeepLeak => _copyV1(
        en: 'Fix next',
        ru: 'Исправь следующим',
      ),
      _Act0LearningNextActionKindV1.repairWeakSpot => _copyV1(
        en: 'Fix next',
        ru: 'Исправь следующим',
      ),
      _Act0LearningNextActionKindV1.reviewQuickFix => _copyV1(
        en: 'Review next',
        ru: 'Повтори следующим',
      ),
      _Act0LearningNextActionKindV1.dailyDrill => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
      _Act0LearningNextActionKindV1.categoryPractice => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
      _Act0LearningNextActionKindV1.continueLesson => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
      _Act0LearningNextActionKindV1.dailyDone => _copyV1(
        en: 'Review',
        ru: 'Разбор',
      ),
    };
  }

  bool _showHomeRepairPanel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    return recommendation.mistake != null ||
        recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix;
  }

  bool _showHomeChecklistV1() {
    return _actionableFirstValueReceiptCarryV1 != null ||
        _completedTaskIds.isNotEmpty ||
        _dailyCompletedRepCount > 0 ||
        _openMistakes().isNotEmpty ||
        _retentionMemoryByTaskId.isNotEmpty;
  }

  String? _homeDailyPlanTitle(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final carry = _actionableFirstValueReceiptCarryV1;
    if (carry != null) {
      return carry.focusTitle;
    }
    return null;
  }

  String _homeDailyGoalCtaLabel(
    Act0WorldCardV1 _selectedWorld,
    Act0LessonCardV1 _currentLesson,
  ) {
    return _copyV1(en: 'Start practice', ru: 'Начать практику');
  }

  String _homeRepairHeadline(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(en: 'All sharp.', ru: 'Всё чётко.');
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return 'Fix ${recommendation.mistake!.title}.';
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(
        en: 'Review this quick fix.',
        ru: 'Сделай здесь лёгкий повтор.',
      );
    }
    return _copyV1(en: 'All sharp.', ru: 'Всё чётко.');
  }

  String _homeRepairDetail(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    if (_placementHandoffActive) {
      return _copyV1(
        en: 'No urgent repair open. Keep going.',
        ru: 'Сейчас явных ошибок нет. Просто продолжай.',
      );
    }
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return _copyV1(
        en: 'Last miss came from ${_playDrillTitleForLesson(recommendation.mistake!.lessonId)}.',
        ru: 'Последняя ошибка пришла из ${_playDrillTitleForLesson(recommendation.mistake!.lessonId)}.',
      );
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(
        en: 'Last repair came from ${_playDrillTitleForLesson(recommendation.lessonId ?? currentLesson.lessonId)}.',
        ru: 'Последний разбор был по уроку ${_playDrillTitleForLesson(recommendation.lessonId ?? currentLesson.lessonId)}.',
      );
    }
    return _copyV1(
      en: 'No urgent repair open. Keep going.',
      ru: 'Сейчас явных ошибок нет. Просто продолжай.',
    );
  }

  String _homeRepairOutcome(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return _copyV1(
        en: 'One practice pass keeps this spot from following you forward.',
        ru: 'Один разбор сейчас не даст этой ошибке закрепиться.',
      );
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(
        en: 'One light review keeps this spot stable.',
        ru: 'Один лёгкий повтор удержит этот спот стабильным.',
      );
    }
    return '';
  }

  String? _homeRepairCtaLabel(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      return _copyV1(en: 'Fix now', ru: 'Исправить сейчас');
    }
    if (recommendation.kind == _Act0LearningNextActionKindV1.reviewQuickFix) {
      return _copyV1(en: 'Open Review', ru: 'Открыть разбор');
    }
    return null;
  }

  List<Act0HomePlanJobV1> _homeDailyPlanJobs(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final jobs = <Act0HomePlanJobV1>[];
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    final openTaskIds = _openMistakes()
        .map((mistake) => mistake.taskId)
        .toSet();
    final hasRepairJob = recommendation.mistake != null;
    final agedRecheck = _topRetentionReplayCardV1(
      _Act0RetentionMemoryStatusV1.agedRecheck,
      excludedTaskIds: openTaskIds,
    );
    final ownedCandidate = _topRetentionReplayCardV1(
      _Act0RetentionMemoryStatusV1.ownedCandidate,
      excludedTaskIds: openTaskIds,
    );
    final hasPlanMix =
        hasRepairJob || agedRecheck != null || ownedCandidate != null;
    if (hasPlanMix) {
      final continueLabel = _dailyCompletedRepCount >= 3
          ? _copyV1(en: 'Next useful hand ready', ru: 'Продолжай, если хочешь')
          : (_cleanTaskIds.isEmpty && _completedTaskIds.isEmpty
                ? _copyV1(en: 'New hand', ru: 'Новая раздача')
                : _copyV1(en: 'Continue route', ru: 'Продолжить маршрут'));
      final continueDetail = _dailyCompletedRepCount >= 3
          ? _copyV1(
              en: 'Session complete. Come back tomorrow or take one fresh route spot.',
              ru: 'Сегодняшний ритм уже засчитан. Но один новый спот всё ещё открыт, если хочешь.',
            )
          : _copyV1(
              en: 'One fresh route step is still open.',
              ru: 'Сохрани движение маршрута через один новый спот.',
            );
      jobs.add(
        Act0HomePlanJobV1(
          jobId: 'continue',
          label: continueLabel,
          title: _localizedLessonTitleV1(currentLesson),
          detail: continueDetail,
        ),
      );
    }
    if (hasRepairJob) {
      jobs.add(
        Act0HomePlanJobV1(
          jobId: 'repair:${recommendation.mistake!.taskId}',
          label: _copyV1(en: 'Repair one mistake', ru: 'Разбери одну ошибку'),
          title: recommendation.mistake!.title,
          detail: recommendation.subtitle,
        ),
      );
      openTaskIds.add(recommendation.mistake!.taskId);
    }
    if (agedRecheck != null) {
      jobs.add(
        Act0HomePlanJobV1(
          jobId: 'recheck:${agedRecheck.taskId}',
          label: _copyV1(en: 'Recheck old spot', ru: 'Повтори старый спот'),
          title: agedRecheck.title,
          detail: _copyV1(
            en: 'Still yours? One calm replay keeps it honest.',
            ru: 'Ещё твоё? Один спокойный повтор это подтвердит.',
          ),
        ),
      );
      openTaskIds.add(agedRecheck.taskId);
    }
    if (ownedCandidate != null) {
      final ownedEntry = _retentionMemoryByTaskId[ownedCandidate.taskId];
      final stableProof =
          ownedEntry != null && _isStableOwnedCandidateV1(ownedEntry);
      jobs.add(
        Act0HomePlanJobV1(
          jobId: 'prove:${ownedCandidate.taskId}',
          label: stableProof
              ? _copyV1(en: 'Keep sharp', ru: 'Держи острым')
              : _copyV1(en: 'Prove it', ru: 'Подтверди'),
          title: ownedCandidate.title,
          detail: stableProof
              ? _copyV1(
                  en: 'Skill holding. One calm replay keeps it honest.',
                  ru: 'Навык держится. Один спокойный повтор это подтвердит.',
                )
              : _copyV1(
                  en: 'Run it clean once more to keep the spot sharp.',
                  ru: 'Пройди его ещё раз чисто, чтобы место оставалось острым.',
                ),
        ),
      );
    }
    return jobs;
  }

  Act0HomeWeeklyFocusV1? _homeWeeklyFocus(
    Act0WorldCardV1 selectedWorld,
    Act0LessonCardV1 currentLesson,
  ) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: currentLesson,
    );
    if (recommendation.mistake != null) {
      final title = recommendation.mistake!.weaknessLabel.trim();
      if (title.isEmpty) {
        return null;
      }
      return Act0HomeWeeklyFocusV1(
        label: _copyV1(en: 'Focus today', ru: 'Фокус сегодня'),
        title: title,
        detail: _copyV1(
          en: 'Repair this idea in fresh frames today.',
          ru: 'Сегодня закрепи эту идею в новых фреймах.',
        ),
      );
    }
    final agedRecheck = _topRetentionReplayCardV1(
      _Act0RetentionMemoryStatusV1.agedRecheck,
      excludedTaskIds: _openMistakes().map((mistake) => mistake.taskId).toSet(),
    );
    if (agedRecheck != null) {
      final title = agedRecheck.weaknessLabel.trim();
      if (title.isEmpty) {
        return null;
      }
      return Act0HomeWeeklyFocusV1(
        label: _copyV1(en: 'Focus today', ru: 'Фокус сегодня'),
        title: title,
        detail: _copyV1(
          en: 'Bring this idea back today.',
          ru: 'Вернись к этой идее сегодня.',
        ),
      );
    }
    final fallbackTitle = _localizedLessonTitleV1(currentLesson).trim();
    if (fallbackTitle.isEmpty) {
      return null;
    }
    return Act0HomeWeeklyFocusV1(
      label: _copyV1(en: 'Focus today', ru: 'Фокус сегодня'),
      title: fallbackTitle,
      detail: _copyV1(
        en: 'Keep the route clean through this next spot.',
        ru: 'Держи маршрут чистым через следующий спот.',
      ),
    );
  }

  _Act0PracticeSurfaceRecommendationV1 _practiceSurfaceRecommendation({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required List<Act0PracticeGroupV1> groups,
  }) {
    Act0PracticeGroupV1? groupById(String groupId) {
      for (final group in groups) {
        if (group.groupId == groupId) {
          return group;
        }
      }
      return null;
    }

    final topMistake = _topOpenMistake();
    final quickFixGroup = groupById('weak_spots');
    final dailyGroup = groupById('daily');
    final firstPack = groups.firstWhere(
      (group) =>
          group.isEnabled &&
          !_kPracticePrimaryGroupIdsV1.contains(group.groupId) &&
          group.groupId != 'continue' &&
          group.groupId != 'placement',
      orElse: () => dailyGroup ?? groups.first,
    );

    if (quickFixGroup != null && quickFixGroup.isEnabled) {
      final repairPracticeRecommendation =
          _repairPracticeSurfaceRecommendationV1(
            selectedWorld: selectedWorld,
            selectedLesson: selectedLesson,
            quickFixGroup: quickFixGroup,
          );
      if (repairPracticeRecommendation != null) {
        return repairPracticeRecommendation;
      }
      return _Act0PracticeSurfaceRecommendationV1(
        groupId: quickFixGroup.groupId,
        title: _copyV1(
          en: 'Replay one useful spot',
          ru: 'Повтори один полезный спот',
        ),
        subtitle: _copyV1(
          en: 'Keep one idea available without dropping back into full Review.',
          ru: 'Удержи одну идею доступной без возврата в полный режим Разбора.',
        ),
        reasonLabel: _copyV1(en: 'Keep it sharp', ru: 'Удержи в тонусе'),
        outcomeLead: _copyV1(en: 'One calm rep:', ru: 'Один спокойный повтор:'),
        outcome: _copyV1(
          en: 'replay the spot, then move back into today\'s reps or one skill pack.',
          ru: 'повтори спот, а потом вернись к сегодняшним повторам или к одному паку.',
        ),
        masteryLabel: _copyV1(en: 'Light repair rep', ru: 'Лёгкий повтор'),
        screenSubtitle: _copyV1(
          en: 'Practice keeps replay notes sharp. Review still owns deeper repairs.',
          ru: 'Практика удерживает заметки для повтора в тонусе. Более глубокий разбор всё ещё живёт во вкладке Разбор.',
        ),
      );
    }

    if (dailyGroup != null && dailyGroup.isEnabled) {
      final repairStillOpen = topMistake != null;
      return _Act0PracticeSurfaceRecommendationV1(
        groupId: dailyGroup.groupId,
        title: dailyGroup.title,
        subtitle: repairStillOpen
            ? _copyV1(
                en: 'Review owns the repair. Practice keeps one short sharpening set ready after that.',
                ru: 'Разбор забирает ошибку на себя. Практика держит здесь короткую серию закрепляющих повторов на потом.',
              )
            : dailyGroup.subtitle,
        reasonLabel: _copyV1(en: 'Today\'s reps', ru: 'Сегодняшние повторы'),
        outcomeLead: repairStillOpen
            ? _copyV1(en: 'After Review:', ru: 'После Разбора:')
            : _copyV1(en: 'Sharpens today:', ru: 'Сегодня укрепляет:'),
        outcome: repairStillOpen
            ? _copyV1(
                en: 'run one clean set to keep today\'s read warm without reopening the lesson.',
                ru: 'проведи одну чистую серию, чтобы удержать сегодняшнее чтение в тонусе без возврата в урок.',
              )
            : _copyV1(
                en: 'three short spots keep today\'s table reads and next decisions feeling ready without reopening a full lesson.',
                ru: 'три коротких спота удержат сегодняшние чтения стола и следующие решения готовыми без открытия полного урока.',
              ),
        masteryLabel: repairStillOpen
            ? _copyV1(en: 'Review first', ru: 'Сначала разбор')
            : _copyV1(en: 'Today\'s reps', ru: 'Сегодняшние повторы'),
        screenSubtitle: repairStillOpen
            ? _copyV1(
                en: 'Short reps stay light here. Review owns the deeper repair first.',
                ru: 'Здесь повторы остаются лёгкими. Ошибку сначала чинит Разбор.',
              )
            : _copyV1(
                en: 'Short reps keep today\'s skill ready for tomorrow\'s table decisions.',
                ru: 'Короткие повторы удерживают сегодняшний навык готовым к завтрашним решениям за столом.',
              ),
      );
    }

    return _Act0PracticeSurfaceRecommendationV1(
      groupId: firstPack.groupId,
      title: firstPack.title,
      subtitle: firstPack.subtitle,
      reasonLabel: _copyV1(en: 'Practice focus', ru: 'Фокус практики'),
      outcomeLead: _copyV1(en: 'One clean rep:', ru: 'Один чистый повтор:'),
      outcome: _copyV1(
        en: 'keep one known skill family sharp without reopening lesson mode.',
        ru: 'удержи одну уже знакомую семью навыков в тонусе без возврата в режим урока.',
      ),
      masteryLabel: _copyV1(en: 'Practice focus', ru: 'Фокус практики'),
      screenSubtitle: _copyV1(
        en: 'Short reps keep known skills sharp between Learn and Review.',
        ru: 'Короткие повторы удерживают знакомые навыки в тонусе между Уроками и Разбором.',
      ),
    );
  }

  _Act0PracticeSurfaceRecommendationV1? _repairPracticeSurfaceRecommendationV1({
    required Act0WorldCardV1 selectedWorld,
    required Act0LessonCardV1 selectedLesson,
    required Act0PracticeGroupV1 quickFixGroup,
  }) {
    final recommendation = _learningRecommendation(
      selectedWorld: selectedWorld,
      selectedLesson: selectedLesson,
    );
    final receipt = _nextUsefulHandReasonReceiptV1(
      recommendation: recommendation,
      selectedWorld: selectedWorld,
      state: widget.state ?? Act0ShellStateV1.sample,
    );
    if (receipt.source != 'repair_intent') {
      return null;
    }

    final clue = _practiceRepairClueNameV1(receipt.missedSignalLabel);
    final isExactReplay =
        receipt.selectionSource == 'repair_intent_exact_replay';
    return _Act0PracticeSurfaceRecommendationV1(
      groupId: quickFixGroup.groupId,
      title: isExactReplay
          ? _copyV1(en: 'Replay this spot', ru: 'Повтори этот спот')
          : _copyV1(en: 'Practice the $clue', ru: 'Закрепи подсказку $clue'),
      subtitle: isExactReplay
          ? _copyV1(
              en: 'Current useful rep: train the exact table clue again.',
              ru: 'Повтори именно этот спот ещё раз.',
            )
          : _copyV1(
              en: 'Current useful rep: one same-clue hand before daily reps.',
              ru: 'Один повтор с той же подсказкой поможет закрепить её.',
            ),
      reasonLabel: _practiceRepairReturnReasonLineV1(receipt.missedSignalLabel),
      outcomeLead: _copyV1(en: 'Practice now:', ru: 'Практика сейчас:'),
      outcome: isExactReplay
          ? _copyV1(
              en: 'repeat the same spot once, then return to today\'s reps.',
              ru: 'повтори тот же спот один раз, затем вернись к сегодняшним повторам.',
            )
          : _copyV1(
              en: 'reinforce the missed clue before moving back to daily reps.',
              ru: 'закрепи пропущенную подсказку перед возвратом к дневным повторам.',
            ),
      masteryLabel: _copyV1(
        en: 'Repair reinforcement',
        ru: 'Закрепление ремонта',
      ),
      screenSubtitle: _copyV1(
        en: 'Current useful rep first. Locked inventory stays secondary until the route opens it.',
        ru: 'Практика закрепляет следующую полезную руку. Глубокие паттерны остаются в Разборе.',
      ),
    );
  }

  String _practiceRepairClueNameV1(String missedSignalLabel) {
    final normalized = missedSignalLabel
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    if (normalized.isEmpty) {
      return 'table clue';
    }
    if (normalized.endsWith('-clue')) {
      return normalized;
    }
    return '$normalized clue';
  }

  String _practiceRepairReturnReasonLineV1(String missedSignalLabel) {
    final label = missedSignalLabel.trim();
    if (label.isEmpty) {
      return _copyV1(
        en: 'This table clue is still the one to stabilize.',
        ru: 'Эту подсказку стола ещё нужно закрепить.',
      );
    }
    return _copyV1(
      en: '$label is still the clue to stabilize.',
      ru: 'Подсказку $label ещё нужно закрепить.',
    );
  }

  String _dailyGoalValueLabel() {
    final count = _dailyCompletedRepCount.clamp(0, 3);
    if (count < 3) {
      return _copyV1(en: '$count/3 daily spots', ru: '$count/3 дневных спота');
    }
    return _copyV1(en: 'Done for today', ru: 'На сегодня всё');
  }

  String _compactDailyLabel() {
    final count = _dailyCompletedRepCount.clamp(0, 3);
    if (count < 3) {
      return _copyV1(en: 'Today $count/3', ru: 'Сегодня $count/3');
    }
    return _copyV1(en: 'Done \u2713', ru: 'Готово \u2713');
  }

  // The bar under `_compactDailyLabel()` must track the same today's-goal
  // count it labels, not the unrelated overall curriculum/XP progress.
  double _dailyGoalProgressValueV1() {
    final count = _dailyCompletedRepCount.clamp(0, 3);
    return count / 3;
  }

  bool _streakSaveEarned() {
    return _dailyCompletedRepCount >= 3 && _resolvedMistakeTaskIds.isNotEmpty;
  }

  Act0SharkyCueV1? _homeSharkyOverride() {
    final state = widget.state ?? Act0ShellStateV1.sample;

    // Daily done after successful repair — celebrate saved streak effort
    if (_streakSaveEarned()) {
      return const Act0SharkyCueV1(
        preSessionLine:
            'You corrected a mistake. Try that skill again tomorrow.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Check the clue again.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine:
            'You corrected a mistake today. Practice it again tomorrow.',
        preSessionMood: Act0SharkyMoodV1.celebrate,
      );
    }

    // Daily goal complete — highest priority
    if (_dailyCompletedRepCount >= 3) {
      return const Act0SharkyCueV1(
        preSessionLine:
            'Good work completing today\'s practice. Review an open mistake or try one fresh hand.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Check the clue again.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Next time, Sharky will keep the next useful hand ready.',
        preSessionMood: Act0SharkyMoodV1.celebrate,
      );
    }

    // First ever session — zero completed tasks
    if (_completedTaskIds.isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Let\'s see how the table looks to you.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Check the clue again.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Every strong player started exactly here.',
        preSessionMood: Act0SharkyMoodV1.neutral,
      );
    }

    // Repair queue just cleared — all prior mistakes resolved
    if (_resolvedMistakeTaskIds.isNotEmpty && _openMistakes().isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Repair queue clear. Clean slate.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Check the clue again.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'No open leaks. That is a real edge.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Clean run — 5+ correct answers with no open mistakes
    if (_cleanTaskIds.length >= 5 && _openMistakes().isEmpty) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Clean run. The reads are sharpening.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Check the clue again.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'Accuracy builds trust. You are building it.',
        preSessionMood: Act0SharkyMoodV1.happy,
      );
    }

    // Open mistakes — repair prompt
    final topMistake = _topOpenMistake();
    if (topMistake != null) {
      return const Act0SharkyCueV1(
        preSessionLine: 'Fix one weak spot before you stop.',
        correctReaction: 'Sharp read.',
        wrongReaction: 'Check the clue again.',
        repairLine: 'Take one breath. I will point at the clue.',
        summaryLine: 'One repair now saves two repairs tomorrow.',
        preSessionMood: Act0SharkyMoodV1.repair,
      );
    }

    return null;
  }

  bool _rememberLessonRunnerV1() {
    if (_tab != Act0ShellTabV1.play ||
        _showPlayHub ||
        _showPlacement ||
        _showWelcome ||
        _blockCompletionSummary != null ||
        _placementDiagnosticActive ||
        _diagnosticLearningEntryV1 != null ||
        _spacedReviewReturnV1 != null ||
        _lessonExampleSourceTaskIdV1 != null ||
        _rapidPracticeLoop ||
        _activeRepairTaskId != null ||
        _activeSameSignalRecheckTaskId != null) {
      return false;
    }
    final resume = (
      worldId: _selectedWorldId,
      lessonId: _selectedLessonId,
      taskId: _selectedTaskId,
      phase: _phase,
      teachingStepIndex: _teachingStepIndex,
      selectedOptionId: _selectedOptionId,
    );
    final worlds = (widget.state ?? Act0ShellStateV1.sample).worlds;
    if (_validLessonResumeV1(
      resume,
      worlds,
      _pathClosedTaskIds,
      requireSelectable: false,
    )) {
      _lessonResumeV1 = resume;
      return true;
    }
    return false;
  }

  bool _validLessonResumeV1(
    _Act0LessonResumeV1 resume,
    List<Act0WorldCardV1> worlds,
    Set<String> closedTasks, {
    bool requireSelectable = true,
  }) {
    if (closedTasks.contains(resume.taskId)) return false;
    final world = worlds
        .where(
          (world) =>
              world.worldId == resume.worldId &&
              (!requireSelectable || world.isSelectable),
        )
        .firstOrNull;
    final lesson = world?.lessons
        .where(
          (lesson) =>
              lesson.lessonId == resume.lessonId &&
              (!requireSelectable || lesson.isSelectable),
        )
        .firstOrNull;
    final task = lesson?.courseTaskList
        .where((task) => task.taskId == resume.taskId)
        .firstOrNull;
    if (task == null ||
        resume.teachingStepIndex > task.runner.teachingSteps.length) {
      return false;
    }
    if (resume.phase != Act0LessonPhaseV1.review ||
        task.runner.options.isEmpty) {
      return resume.selectedOptionId == null;
    }
    return task.runner.options.any(
      (option) => option.id == resume.selectedOptionId,
    );
  }

  void _resumeHomeLessonV1(_Act0LessonResumeV1 resume) {
    if (_lessonResumeV1 != resume) return;
    final worlds = _progressWorlds(widget.state ?? Act0ShellStateV1.sample);
    if (!_validLessonResumeV1(resume, worlds, _pathClosedTaskIds)) return;
    final world = _worldById(worlds, resume.worldId);
    if (!_startTaskByIds(
      world,
      resume.lessonId,
      resume.taskId,
      persist: false,
    )) {
      return;
    }
    _phase = resume.phase;
    _teachingStepIndex = resume.teachingStepIndex;
    _selectedOptionId = resume.selectedOptionId;
    _choiceAssistanceV1 = _pendingAssistanceForV1(
      resume.worldId,
      resume.lessonId,
      resume.taskId,
    );
    if (resume.phase == Act0LessonPhaseV1.review) {
      final answer = _learningEvidenceHistoryV1.records.reversed
          .where(
            (record) =>
                record.worldId == resume.worldId &&
                record.lessonId == resume.lessonId &&
                record.taskId == resume.taskId &&
                record.choiceId == resume.selectedOptionId &&
                !record.isDiagnosticLearningEntry &&
                !record.isPlacementAssessment,
          )
          .firstOrNull;
      _choiceAssistanceV1 =
          answer?.assistanceKind ?? Act0DecisionAssistanceV1.legacyUnknown;
      if (answer != null && !answer.isCorrect) {
        _lessonRunMistakeTaskIds.add(resume.taskId);
        _lessonRunPendingRetryTaskIds.add(resume.taskId);
      }
    }
    _returnToPlayHubOnBack = false;
    _persistProgress();
  }

  void _finishFirstLessonReminderV1(bool enable) {
    if (_firstLessonReminderAnsweredV1) return;
    final epoch = _recoveryEpochV1;
    _setStateV1(() => _firstLessonReminderAnsweredV1 = true);
    _persistProgress();
    if (!enable) return;
    _syncPracticeReminderV1();
    unawaited(
      Act0PracticeReminderV1.setEnabled(true).then<void>(
        (_) {},
        onError: (Object _) {
          if (mounted && epoch == _recoveryEpochV1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The reminder could not be enabled.'),
              ),
            );
          }
        },
      ),
    );
  }

  void _startHomeNextAction(Act0WorldCardV1 selectedWorld) {
    final firstValueCarry = _actionableFirstValueReceiptCarryV1;
    if (firstValueCarry != null &&
        _startFirstValueDailyRepLaunchV1(firstValueCarry)) {
      return;
    }
    if (_placementHandoffActive) {
      // Home promises the eligible route task, including an unfinished Guide.
      // A Placement recommendation is not permission to bypass prerequisites.
      final lesson = _firstPlayableLesson(selectedWorld);
      final task = _firstIncompleteTask(lesson);
      _startTaskByIds(selectedWorld, lesson.lessonId, task.taskId);
      _returnToPlayHubOnBack = false;
      return;
    }
    _placementHandoffActive = false;
    final lesson = _firstPlayableLesson(selectedWorld);
    _startRecommendation(
      _homePrimaryRecommendation(
        selectedWorld: selectedWorld,
        selectedLesson: lesson,
      ),
      selectedWorld,
      returnToPlayHub: false,
    );
  }
}
