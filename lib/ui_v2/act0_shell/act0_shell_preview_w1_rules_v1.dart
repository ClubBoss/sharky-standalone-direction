part of 'act0_shell_preview_screen_v1.dart';

extension _PreviewW1RulesV1 on _Act0ShellPreviewScreenV1State {
  bool get _canTakeW1RulesCheckV1 => !_progressWorlds(
    _catalogStateV1,
  ).any((world) => world.worldId == 'world_2' && world.isSelectable);

  void _beginW1RulesCheckV1() {
    if (_w1RulesAnswersV1 != null || !_canTakeW1RulesCheckV1) return;
    _setStateV1(() {
      _rulesOriginTabV1 = _showW1StartV1 ? null : _tab;
      _showW1StartV1 = false;
      _showPlayHub = true;
      _w1RulesAnswersV1 = <int>[];
      _w1RulesResultV1 = null;
    });
    _recordBetaActivityV1(Act0BetaMetricsStoreV1.recordRulesCheckStarted);
    _recordW1RulesEventV1('w1_rules_check_started', 1);
  }

  void _closeW1RulesCheckV1() {
    final origin = _rulesOriginTabV1;
    final answers = _w1RulesAnswersV1;
    if (origin == null && answers != null) {
      // Leaving the initial check starts the normal W1 lesson with no award.
      // Settings/Learn retakes instead return to their originating tab.
      _openRulesStartLessonV1('world_1');
      return;
    }
    if (answers != null) {
      _recordW1RulesEventV1('w1_rules_check_abandoned', answers.length + 1);
    }
    _setStateV1(() {
      _w1RulesAnswersV1 = null;
      _w1RulesResultV1 = null;
      _rulesOriginTabV1 = null;
      _showW1StartV1 = origin == null;
      _tab = origin ?? Act0ShellTabV1.home;
      _showPlayHub = true;
    });
  }

  void _answerW1RulesCheckV1(int index, int answer) {
    final answers = _w1RulesAnswersV1;
    if (answers == null || answers.length != index) return;
    unawaited(UiHapticsV1.fire(UiHapticEventV1.answer));
    _setStateV1(() {
      answers.add(answer);
      if (answers.length != act0W1RulesQuestionsV1.length) return;
      final result = Act0W1RulesResultV1(answers);
      _w1RulesAnswersV1 = null;
      _w1RulesResultV1 = result;
      _w1StartChosenV1 = true;
      if (result.score > _w1RulesBestScoreV1) {
        _earnedXp +=
            result.xp -
            _w1RulesBestScoreV1 * Act0W1RulesResultV1.xpPerCorrectAnswer;
        _w1RulesBestScoreV1 = result.score;
      }
      final missed = result.passed
          ? const <Act0W1RulesQuestionV1>[]
          : result.missedQuestions.toList();
      _w1RulesFocusTaskIdsV1 = missed
          .map((question) => question.taskId)
          .toSet();
      _durableRetentionHistoryV1 = _durableRetentionHistoryV1
          .reconcileW1CheckMisses(missed, widget.clock.nowUtc());
      _selectRulesStartWorldV1(result.passed ? 'world_2' : 'world_1');
      _persistProgress();
      _recordW1RulesEventV1(
        result.passed ? 'w1_rules_check_passed' : 'w1_rules_check_failed',
        act0W1RulesQuestionsV1.length,
        score: result.score,
      );
    });
  }

  void _recordW1RulesEventV1(String name, int question, {int? score}) {
    _recordTelemetryEventV1(name, <String, Object?>{
      'schemaVersion': 1,
      'question': question,
      if (score != null) 'score': score,
    });
  }

  void _selectRulesStartWorldV1(String worldId) {
    final world = _worldById(_progressWorlds(_catalogStateV1), worldId);
    final lesson = _firstPlayableLesson(world);
    _selectedWorldId = world.worldId;
    _selectedLessonId = lesson.lessonId;
    _selectedTaskId = _firstIncompleteTask(lesson).taskId;
  }

  void _openRulesStartLessonV1(String worldId) {
    final answers = _w1RulesAnswersV1;
    if (answers != null) {
      _recordW1RulesEventV1('w1_rules_check_abandoned', answers.length + 1);
    }
    _setStateV1(() {
      _w1StartChosenV1 = true;
      _rulesOriginTabV1 = null;
      _showW1StartV1 = false;
      _w1RulesAnswersV1 = null;
      _w1RulesResultV1 = null;
      _showPlacement = false;
      _showWelcome = false;
      _selectRulesStartWorldV1(worldId);
      final world = _worldById(_progressWorlds(_catalogStateV1), worldId);
      _startTaskByIds(world, _selectedLessonId, _selectedTaskId);
    });
  }

  Widget _buildW1RulesFlowV1() {
    final view = Act0W1RulesViewModelV1(
      answers: _w1RulesAnswersV1,
      result: _w1RulesResultV1,
    );
    final result = view.result;
    final Widget body;
    if (view.question case final question?) {
      final index = view.index;
      final runner = question.runner(index);
      body = Act0LessonRunnerShellV1(
        key: ValueKey(question.taskId),
        runner: runner,
        worldNumber: 1,
        selectedWorldId: 'world_1',
        selectedLessonId: question.lessonId,
        selectedTaskId: question.taskId,
        selectedTaskFamily: Act0TaskFamilyV1.decision,
        showDecisionCoach: false,
        progressLabel: 'Rules check · ${index + 1} of ${view.total}',
        onBack: _closeW1RulesCheckV1,
        onContinueTheory: () {},
        onChooseOption: (option) => _answerW1RulesCheckV1(
          index,
          runner.options.indexWhere((candidate) => candidate.id == option.id),
        ),
        onContinueReview: () {},
      );
    } else if (result != null) {
      final missed = view.missed;
      body = Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Act0ShellRouteHeaderV1(
              title: 'Your start',
              onBack: _closeW1RulesCheckV1,
            ),
            const SizedBox(height: 8),
            Text(
              result.passed
                  ? 'W1 passed by test. You start at W2.'
                  : 'Start with W1.',
              style: Act0ShellTokensV1.body,
            ),
            if (missed.isNotEmpty && !result.passed) ...[
              const SizedBox(height: 8),
              Text(
                'Focus: ${missed.map((question) => question.topic).toSet().join(', ')}',
                style: Act0ShellTokensV1.body,
              ),
            ],
            const SizedBox(height: 8),
            Text('${result.score} of ${view.total} correct'),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: missed.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final question = missed[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.topic, style: Act0ShellTokensV1.label),
                      Text(question.reason, style: Act0ShellTokensV1.body),
                    ],
                  );
                },
              ),
            ),
            FilledButton(
              key: const Key('act0_shell_w1_rules_continue'),
              onPressed: () => _openRulesStartLessonV1(view.landingWorldId),
              child: Text(result.passed ? 'Start World 2' : 'Start World 1'),
            ),
          ],
        ),
      );
    } else {
      body = Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Sharky Poker', style: Act0ShellTokensV1.sectionTitle),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('act0_shell_w1_start_basics'),
                onPressed: () => _openRulesStartLessonV1('world_1'),
                child: const Text('Start with the basics'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                key: const Key('act0_shell_w1_start_check'),
                onPressed: _beginW1RulesCheckV1,
                child: const Text(
                  'I already play — take the 10-question rules check',
                ),
              ),
              const SizedBox(height: 6),
              Text('Stop any time, no penalty', style: Act0ShellTokensV1.muted),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      key: const Key('act0_shell_preview_screen'),
      backgroundColor: Act0AcademyLeafPaletteV1.ink,
      body: SafeArea(
        child: Column(
          children: [
            _progressSaveNoticeV1(),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
