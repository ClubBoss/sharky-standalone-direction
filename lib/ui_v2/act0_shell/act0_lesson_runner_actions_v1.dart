part of 'act0_lesson_runner_shell_v1.dart';

class _PhaseTrackerV1 extends StatelessWidget {
  const _PhaseTrackerV1({required this.phase});

  final Act0LessonPhaseV1 phase;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('act0_shell_phase_tracker'),
      children: Act0LessonPhaseV1.values
          .map((item) {
            final active = item == phase;
            final label = switch (item) {
              Act0LessonPhaseV1.theory => 'Learn',
              Act0LessonPhaseV1.drill => 'Practice',
              Act0LessonPhaseV1.review => 'Review',
            };
            final activeColor = switch (item) {
              Act0LessonPhaseV1.theory => Act0ShellTokensV1.info,
              Act0LessonPhaseV1.drill => Act0ShellTokensV1.primary,
              Act0LessonPhaseV1.review => Act0ShellTokensV1.gold,
            };
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? activeColor.withValues(alpha: 0.18)
                      : Act0ShellTokensV1.surface2,
                  borderRadius: BorderRadius.circular(
                    Act0ShellTokensV1.radiusPill,
                  ),
                  border: Border.all(
                    color: active ? activeColor : Act0ShellTokensV1.border,
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Act0ShellTokensV1.label.copyWith(
                    color: active ? activeColor : Act0ShellTokensV1.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _DecisionHintV1 {
  const _DecisionHintV1({
    required this.quickHint,
    required this.fullIdeaTitle,
    required this.fullIdeaBlocks,
  });

  final String quickHint;
  final String fullIdeaTitle;
  final List<String> fullIdeaBlocks;

  bool get hasFullIdea =>
      fullIdeaTitle.trim().isNotEmpty || fullIdeaBlocks.isNotEmpty;
}

_DecisionHintV1? _resolveDecisionHintV1({
  required Act0TaskFamilyV1? taskFamily,
  required Act0RunnerStateV1 runner,
  required String prompt,
  required String question,
  required String supportLine,
  required Act0TeachingStepV1? fullIdeaStep,
}) {
  if (runner.phase != Act0LessonPhaseV1.drill || runner.options.isEmpty) {
    return null;
  }
  var quickHint = _genericDecisionHintV1(
    taskFamily: taskFamily,
    focusText: question.trim().isNotEmpty ? question : prompt,
    text:
        '$prompt $question $supportLine '
        '${runner.lessonTitle} ${runner.lessonSubtitle}',
  );
  if (quickHint.isEmpty) {
    return null;
  }
  // Even a short generic hint must not name the graded correct option.
  final answers = runner.options.where((option) => option.isCorrect).toList();
  if (answers.length != 1) {
    quickHint = 'Use the visible facts to compare each option before deciding.';
  } else {
    final correct = answers.single;
    final answerTerms = <String>[
      correct.label,
      correct.amountLabel,
      if (correct.seatId != null) correct.seatId!,
    ];
    bool namesAnswer(String text) =>
        answerTerms.any((term) => _preChoiceTextNamesOptionV1(text, term));
    if (namesAnswer(quickHint)) {
      quickHint = _answerNeutralReasoningGuideV1(
        taskFamily: taskFamily,
        question: question,
      );
      if (namesAnswer(quickHint)) {
        quickHint =
            'Use the visible facts to compare each option before deciding.';
      }
    }
  }
  final safeIdea = _preChoiceTheoryIdeaV1(
    taskFamily: taskFamily,
    runner: runner,
    question: question.trim().isNotEmpty ? question : prompt,
    fullIdeaStep: fullIdeaStep,
  );
  return _DecisionHintV1(
    quickHint: quickHint,
    fullIdeaTitle: safeIdea.title,
    fullIdeaBlocks: fullIdeaStep == null
        ? const <String>[]
        : act0BuildSupportingCopyBlocksV1(text: safeIdea.body, compact: true),
  );
}

// The authored theory step is still taught intact during Learn and after
// grading. During an independent drill, however, that same text may name the
// exact graded answer. Only substitute an answer-neutral *pre-choice* guide
// when an authored correct option is present in the assistance copy.
({String title, String body}) _preChoiceTheoryIdeaV1({
  required Act0TaskFamilyV1? taskFamily,
  required Act0RunnerStateV1 runner,
  required String question,
  required Act0TeachingStepV1? fullIdeaStep,
}) {
  if (fullIdeaStep == null) return (title: '', body: '');
  if (runner.phase != Act0LessonPhaseV1.drill || runner.options.isEmpty) {
    return (title: fullIdeaStep.title, body: fullIdeaStep.body);
  }
  final answers = runner.options.where((option) => option.isCorrect).toList();
  // Without one verified source answer, don't pass potentially answer-bearing
  // material through a graded assistance surface.
  if (answers.length != 1) {
    return (
      title: 'Reasoning guide',
      body: 'Use the visible facts to compare each option before deciding.',
    );
  }
  final answer = answers.single;
  final answerTerms = <String>[
    answer.label,
    answer.amountLabel,
    if (answer.seatId != null) answer.seatId!,
  ];
  bool namesAnswer(String text) =>
      answerTerms.any((term) => _preChoiceTextNamesOptionV1(text, term));
  if (!namesAnswer(fullIdeaStep.title + ' ' + fullIdeaStep.body) ||
      _isNeutralRangeTaxonomyV1(question: question, step: fullIdeaStep)) {
    return (title: fullIdeaStep.title, body: fullIdeaStep.body);
  }
  var guide = _answerNeutralReasoningGuideV1(
    taskFamily: taskFamily,
    question: question,
  );
  if (namesAnswer(guide)) {
    guide = 'Use the visible facts to compare each option before deciding.';
  }
  return (title: 'Reasoning guide', body: guide);
}

// A neutral taxonomy names *all* categories without grading the current hand.
// Preserve that useful reference instead of treating every word match as a leak.
bool _isNeutralRangeTaxonomyV1({
  required String question,
  required Act0TeachingStepV1 step,
}) {
  final reference = step.body.toLowerCase().trim();
  return question.toLowerCase().contains('which range bucket') &&
      reference.startsWith('after the flop, sort your hand into') &&
      reference.contains('value (') &&
      reference.contains('bluff candidate (') &&
      reference.contains('missed (') &&
      !reference.contains(' on this board') &&
      !reference.contains(' on this flop');
}

bool _preChoiceTextNamesOptionV1(String text, String term) {
  final answer = term.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (answer.isEmpty ||
      (answer.length == 1 && !RegExp(r'^\d$').hasMatch(answer))) {
    return false;
  }
  final escaped = RegExp.escape(answer).replaceAll(' ', r'\s+');
  return RegExp(
    '(^|[^a-z0-9])' + escaped + r'([^a-z0-9]|$)',
    caseSensitive: false,
  ).hasMatch(text);
}

String _answerNeutralReasoningGuideV1({
  required Act0TaskFamilyV1? taskFamily,
  required String question,
}) {
  final focus = question.toLowerCase();
  if (focus.contains('everyone use') ||
      (focus.contains('which cards') && focus.contains('everyone'))) {
    return 'Separate cards held privately from cards available to all '
        'players before choosing the matching description.';
  }
  if (focus.contains('suit') ||
      RegExp(r'\b[akqjt2-9][shdc]\b').hasMatch(focus)) {
    return 'Decode the rank and suit parts separately, then apply the '
        'card notation from the lesson to this exact card.';
  }
  if (focus.contains('street') ||
      (focus.contains('turn') && focus.contains('after'))) {
    return 'Trace the order of betting streets from the named point, '
        'then identify the next stage.';
  }
  if (focus.contains('blind') ||
      focus.contains('seat') ||
      focus.contains('button') ||
      focus.contains('position') ||
      focus.contains('utg') ||
      focus.startsWith('tap ')) {
    return 'Locate the relevant seat marker and compare its position '
        'with the forced wagers and button before choosing.';
  }
  if ((focus.contains('hand') &&
          (focus.contains('stronger') ||
              focus.contains('rank') ||
              focus.contains('hero have') ||
              focus.contains('higher'))) ||
      focus.contains('showdown')) {
    return 'Build the best hand pattern from the private and shared cards. '
        'Compare patterns using the hand hierarchy, not a single high card.';
  }
  if (taskFamily == Act0TaskFamilyV1.counting ||
      focus.contains('how many') ||
      focus.contains('combos') ||
      focus.contains('effective stack')) {
    return 'Identify exactly which items are being counted, then '
        'work through the relevant combinations or quantities.';
  }
  if (focus.contains('price') ||
      focus.contains('action') ||
      focus.contains('play for free') ||
      focus.contains('no bet') ||
      taskFamily == Act0TaskFamilyV1.sizing) {
    return 'Read the current amount required to continue and the '
        'available actions; relate the cost to the situation.';
  }
  if (focus.contains('bucket') || focus.contains('range')) {
    return 'Start with the hand or range category, then use the '
        'visible position and board clues before committing to a category.';
  }
  if (focus.contains('board') ||
      focus.contains('flop') ||
      focus.contains('draw')) {
    return 'Re-read the shared cards and compare the changed hand '
        'signals before evaluating the options.';
  }
  return 'Find the relevant table clue, compare it with each option, '
      'and make the decision yourself.';
}

String _genericDecisionHintV1({
  required Act0TaskFamilyV1? taskFamily,
  required String focusText,
  required String text,
}) {
  // The question carries the task's subject. Lesson support may mention
  // pot, seats and cards together, so it must not override that subject.
  final focus = focusText.toLowerCase();
  final normalized = text.toLowerCase();
  if (focus.contains('what suit') || focus.contains('which suit')) {
    return 'Match the suit symbol or letter on the named card to the suit key.';
  }
  if (focus.contains('which rank') || focus.contains('what rank')) {
    return 'Compare the ranks on the named cards in deck order.';
  }
  if (focus.contains('which bucket') || focus.contains('which group')) {
    return 'Read your two cards first. Match the ranks and suits to the chart.';
  }
  if (focus.contains('which earns more') && focus.contains('win')) {
    return 'Use the visible pot and the amount you would add to find the required chance.';
  }
  if (focus.contains('sharky starting chart')) {
    return 'Find the chart row for your two cards. Check your seat and who raised.';
  }
  final isBoardFocus =
      focus.contains('board') ||
      focus.contains('community card') ||
      focus.contains('flop') ||
      focus.contains('river');
  if (isBoardFocus &&
      (taskFamily == Act0TaskFamilyV1.counting ||
          focus.contains('how many') ||
          focus.contains('count'))) {
    return 'Track the board street by street, not chips in the pot.';
  }
  if (taskFamily != Act0TaskFamilyV1.sizing &&
      RegExp(r'\b(?:which|what)\s+action\b').hasMatch(focus)) {
    return 'Name the action before choosing what it means.';
  }
  if (focus.contains('position') ||
      focus.contains('seat') ||
      focus.contains('button') ||
      focus.contains('btn') ||
      focus.contains('utg') ||
      focus.contains('blind')) {
    return 'Start from the button, then follow seat order.';
  }
  if (taskFamily == Act0TaskFamilyV1.sizing ||
      focus.contains('pot') ||
      focus.contains('chip') ||
      focus.contains('matched')) {
    return 'Count only chips that are actually in the pot or matched.';
  }
  if (focus.contains('action') ||
      focus.contains('fold') ||
      focus.contains('check') ||
      focus.contains('call') ||
      focus.contains('raise') ||
      focus.contains('bet')) {
    return 'Name the action before choosing what it means.';
  }
  if (taskFamily == Act0TaskFamilyV1.counting) {
    return 'Count only the items named in the question.';
  }
  if (isBoardFocus ||
      taskFamily == Act0TaskFamilyV1.recognition ||
      taskFamily == Act0TaskFamilyV1.compare ||
      normalized.contains('board') ||
      normalized.contains('card') ||
      normalized.contains('flop') ||
      normalized.contains('turn') ||
      normalized.contains('river')) {
    return 'Read the board cards before using memory.';
  }
  if (taskFamily == Act0TaskFamilyV1.decision ||
      taskFamily == Act0TaskFamilyV1.transfer ||
      taskFamily == Act0TaskFamilyV1.repair ||
      normalized.contains('action') ||
      normalized.contains('fold') ||
      normalized.contains('check') ||
      normalized.contains('call') ||
      normalized.contains('raise') ||
      normalized.contains('bet')) {
    return 'Name the action before choosing what it means.';
  }
  if (normalized.contains('position') ||
      normalized.contains('seat') ||
      normalized.contains('button') ||
      normalized.contains('btn') ||
      normalized.contains('utg') ||
      normalized.contains('blind')) {
    return 'Start from the button, then follow seat order.';
  }
  if (normalized.contains('pot') ||
      normalized.contains('chip') ||
      normalized.contains('matched')) {
    return 'Count only chips that are actually in the pot or matched.';
  }
  return 'Start with what is visible on the table.';
}

class _ActionPanelV1 extends StatelessWidget {
  const _ActionPanelV1({
    required this.options,
    required this.selectedOptionId,
    required this.onChoose,
    this.compactDecision = false,
    this.fillAvailableHeight = false,
  });

  final List<Act0RunnerOptionV1> options;
  final String? selectedOptionId;
  final ValueChanged<Act0RunnerOptionV1> onChoose;
  final bool compactDecision;
  final bool fillAvailableHeight;

  bool _shouldStackOptionsV1(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth <= 420) {
      return true;
    }
    if (options.length > 3) {
      return true;
    }
    var longestLabelLength = 0;
    for (final option in options) {
      final localizedLabel = act0RuntimeLocalizedOptionLabelV1(
        context,
        option.label,
      );
      if (localizedLabel.length > longestLabelLength) {
        longestLabelLength = localizedLabel.length;
      }
    }
    return longestLabelLength > 24 || options.length > 3;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveCompactDecision =
        compactDecision ||
        _CompactAnswerListDecisionScopeV1.isCompact(context) ||
        _usesCompactAnswerListLeafFallbackV1(context);
    final stackOptions = _shouldStackOptionsV1(context);
    final hasLongStackedLabel = options.any(
      (option) =>
          act0RuntimeLocalizedOptionLabelV1(context, option.label).length >
              16 ||
          option.amountLabel.trim().isNotEmpty,
    );
    final unselectedForeground = Act0ShellTokensV1.text;
    final unselectedBackground = Act0ShellTokensV1.surface2.withValues(
      alpha: stackOptions ? 0.88 : 0.82,
    );
    final unselectedBorder = stackOptions
        ? Act0ShellTokensV1.info.withValues(alpha: 0.22)
        : Act0ShellTokensV1.border.withValues(alpha: 0.92);
    Widget withCommitMotion(Widget child) {
      return _DecisionCommitMotionV1(child: child);
    }

    if (stackOptions) {
      if (effectiveCompactDecision) {
        return withCommitMotion(
          Column(
            key: const Key('act0_shell_action_panel'),
            mainAxisSize: fillAvailableHeight
                ? MainAxisSize.max
                : MainAxisSize.min,
            children: [
              if (fillAvailableHeight)
                Expanded(
                  child: Column(
                    key: const Key('act0_shell_answer_sheet'),
                    children: [
                      for (final entry in options.indexed) ...[
                        Expanded(
                          child: _AnswerChoiceRowV1(
                            option: entry.$2,
                            optionIndex: entry.$1,
                            selected: entry.$2.id == selectedOptionId,
                            onChoose: onChoose,
                            compact: true,
                            readableCompactHeight:
                                options.length <= 3 && hasLongStackedLabel,
                          ),
                        ),
                        if (entry.$1 < options.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: Act0ShellTokensV1.info.withValues(
                              alpha: 0.08,
                            ),
                          ),
                      ],
                    ],
                  ),
                )
              else
                Column(
                  key: const Key('act0_shell_answer_sheet'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final entry in options.indexed) ...[
                      _AnswerChoiceRowV1(
                        option: entry.$2,
                        optionIndex: entry.$1,
                        selected: entry.$2.id == selectedOptionId,
                        onChoose: onChoose,
                        compact: true,
                        readableCompactHeight:
                            options.length <= 3 && hasLongStackedLabel,
                      ),
                      if (entry.$1 < options.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Act0ShellTokensV1.info.withValues(alpha: 0.08),
                        ),
                    ],
                  ],
                ),
            ],
          ),
        );
      }
      return withCommitMotion(
        Container(
          key: const Key('act0_shell_action_panel'),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface2.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(
              effectiveCompactDecision ? 16 : 22,
            ),
            border: Border.all(color: unselectedBorder),
          ),
          child: Column(
            key: const Key('act0_shell_answer_sheet'),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in options.indexed) ...[
                _AnswerChoiceRowV1(
                  option: entry.$2,
                  optionIndex: entry.$1,
                  selected: entry.$2.id == selectedOptionId,
                  onChoose: onChoose,
                  compact: effectiveCompactDecision,
                  readableCompactHeight:
                      effectiveCompactDecision &&
                      options.length <= 3 &&
                      hasLongStackedLabel,
                ),
                if (entry.$1 < options.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
                  ),
              ],
            ],
          ),
        ),
      );
    }

    final buttons = options.indexed
        .map((entry) {
          final optionIndex = entry.$1;
          final option = entry.$2;
          final selected = option.id == selectedOptionId;
          final tone = selected
              ? option.isCorrect
                    ? Act0VisualCanonV1.greenTable
                    : Act0ShellTokensV1.danger
              : unselectedForeground;
          final background = selected
              ? tone.withValues(alpha: 0.16)
              : unselectedBackground;
          final buttonHeight = stackOptions ? 62.0 : 48.0;
          final marker = String.fromCharCode(65 + optionIndex);
          return OutlinedButton(
            key: Key('act0_shell_option_${option.id}'),
            onPressed: () => onChoose(option),
            style: Act0ShellTokensV1.quietButtonStyle(height: buttonHeight)
                .copyWith(
                  foregroundColor: WidgetStatePropertyAll(
                    selected ? tone : unselectedForeground,
                  ),
                  backgroundColor: WidgetStatePropertyAll(background),
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      color: selected
                          ? tone.withValues(alpha: 0.92)
                          : unselectedBorder,
                      width: selected ? 1.3 : 1,
                    ),
                  ),
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(
                      horizontal: effectiveCompactDecision
                          ? 10
                          : (stackOptions ? 14 : 12),
                      vertical: effectiveCompactDecision
                          ? 6
                          : (stackOptions ? 10 : 8),
                    ),
                  ),
                  alignment: stackOptions
                      ? Alignment.centerLeft
                      : Alignment.center,
                ),
            child: stackOptions
                ? Row(
                    children: [
                      Container(
                        key: Key('act0_shell_option_marker_${option.id}'),
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? tone.withValues(alpha: 0.18)
                              : Act0ShellTokensV1.info.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                          border: Border.all(
                            color: selected
                                ? tone.withValues(alpha: 0.46)
                                : Act0ShellTokensV1.info.withValues(
                                    alpha: 0.24,
                                  ),
                          ),
                        ),
                        child: Text(
                          marker,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: selected
                                ? tone
                                : Act0ShellTokensV1.info.withValues(
                                    alpha: 0.92,
                                  ),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: Act0ShellTokensV1.gapSm),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act0AcademyW1OptionLabelV1(
                                context,
                                act0RuntimeLocalizedOptionLabelV1(
                                  context,
                                  option.label,
                                ),
                              ),
                              textAlign: TextAlign.left,
                              style: Act0ShellTokensV1.body.copyWith(
                                color: selected ? tone : unselectedForeground,
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                              ),
                            ),
                            if (option.amountLabel.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                option.amountLabel,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 9,
                                  height: 1.0,
                                  color: selected
                                      ? tone.withValues(alpha: 0.9)
                                      : Act0ShellTokensV1.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        act0RuntimeLocalizedOptionLabelV1(
                          context,
                          option.label,
                        ),
                        textAlign: TextAlign.center,
                        style: Act0ShellTokensV1.body.copyWith(
                          color: selected ? tone : unselectedForeground,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 10,
                        child: option.amountLabel.isNotEmpty
                            ? Align(
                                alignment: Alignment.center,
                                child: Text(
                                  option.amountLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 9,
                                    height: 1.0,
                                    color: selected
                                        ? tone.withValues(alpha: 0.9)
                                        : Act0ShellTokensV1.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
          );
        })
        .toList(growable: false);
    if (buttons.length <= 3 && !stackOptions) {
      return withCommitMotion(
        Row(
          key: const Key('act0_shell_action_panel'),
          children: [
            for (var i = 0; i < buttons.length; i++) ...[
              Expanded(child: buttons[i]),
              if (i < buttons.length - 1)
                const SizedBox(width: Act0ShellTokensV1.gapSm),
            ],
          ],
        ),
      );
    }
    return withCommitMotion(
      Column(
        key: const Key('act0_shell_action_panel'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            buttons[i],
            if (i < buttons.length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
        ],
      ),
    );
  }
}

class _DecisionCommitMotionV1 extends StatefulWidget {
  const _DecisionCommitMotionV1({required this.child});

  final Widget child;

  @override
  State<_DecisionCommitMotionV1> createState() =>
      _DecisionCommitMotionV1State();
}

class _DecisionCommitMotionV1State extends State<_DecisionCommitMotionV1> {
  var _settled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _settled = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return KeyedSubtree(
        key: const Key('act0_shell_decision_commit_motion'),
        child: widget.child,
      );
    }
    return AnimatedScale(
      key: const Key('act0_shell_decision_commit_motion'),
      scale: _settled ? 1 : 0.985,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: widget.child,
    );
  }
}

class _AnswerChoiceRowV1 extends StatelessWidget {
  const _AnswerChoiceRowV1({
    required this.option,
    required this.optionIndex,
    required this.selected,
    required this.onChoose,
    this.compact = false,
    this.readableCompactHeight = false,
  });

  final Act0RunnerOptionV1 option;
  final int optionIndex;
  final bool selected;
  final ValueChanged<Act0RunnerOptionV1> onChoose;
  final bool compact;
  final bool readableCompactHeight;

  @override
  Widget build(BuildContext context) {
    final actionVisual = _pokerActionChoiceVisualV1(option.label);
    final tone = selected
        ? option.isCorrect
              ? Act0VisualCanonV1.greenTable
              : Act0ShellTokensV1.danger
        : Act0ShellTokensV1.text;
    final markerTone = selected ? tone : Act0ShellTokensV1.info;
    final marker = option.id == 'not_sure_yet'
        ? '?'
        : String.fromCharCode(65 + optionIndex);
    return Act0SemanticActionV1(
      label: act0RuntimeLocalizedOptionLabelV1(context, option.label),
      value: option.amountLabel.trim().isEmpty ? null : option.amountLabel,
      selected: selected,
      sortKey: OrdinalSortKey(optionIndex.toDouble(), name: 'act0_choices'),
      onTap: () => onChoose(option),
      child: KeyedSubtree(
        key: actionVisual == null
            ? null
            : Key('act0_shell_poker_action_button_${actionVisual.id}'),
        child: Material(
          key: actionVisual == null
              ? null
              : Key('act0_shell_poker_action_tactile_surface_${option.id}'),
          elevation: actionVisual == null ? 0 : (selected ? 5 : 2),
          shadowColor: markerTone.withValues(alpha: selected ? 0.34 : 0.18),
          color: selected
              ? tone.withValues(alpha: 0.16)
              : actionVisual == null
              ? Colors.transparent
              : Act0ShellTokensV1.surface3.withValues(alpha: 0.76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: selected
                  ? tone.withValues(alpha: 0.52)
                  : actionVisual == null
                  ? Colors.transparent
                  : markerTone.withValues(alpha: 0.22),
            ),
          ),
          child: InkWell(
            key: Key('act0_shell_option_${option.id}'),
            onTap: () => onChoose(option),
            borderRadius: BorderRadius.circular(18),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: compact ? (readableCompactHeight ? 56 : 48) : 52,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 14,
                  vertical: compact ? 5 : 10,
                ),
                child: Row(
                  children: [
                    Container(
                      key: Key('act0_shell_option_marker_${option.id}'),
                      width: compact ? 26 : 32,
                      height: compact ? 26 : 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? tone.withValues(alpha: 0.18)
                            : markerTone.withValues(
                                alpha: actionVisual == null ? 0.10 : 0.13,
                              ),
                        borderRadius: BorderRadius.circular(
                          Act0ShellTokensV1.radiusPill,
                        ),
                        border: Border.all(
                          color: selected
                              ? tone.withValues(alpha: 0.46)
                              : markerTone.withValues(
                                  alpha: actionVisual == null ? 0.24 : 0.34,
                                ),
                        ),
                      ),
                      child: Text(
                        marker,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: selected
                              ? tone
                              : Act0ShellTokensV1.info.withValues(alpha: 0.92),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    SizedBox(width: compact ? 8 : 10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            act0AcademyW1OptionLabelV1(
                              context,
                              act0RuntimeLocalizedOptionLabelV1(
                                context,
                                option.label,
                              ),
                            ),
                            textAlign: TextAlign.left,
                            style: Act0ShellTokensV1.body.copyWith(
                              color: tone,
                              fontSize: compact ? 12.6 : 13.2,
                              fontWeight: actionVisual == null
                                  ? FontWeight.w700
                                  : FontWeight.w900,
                              height: compact ? 1.08 : 1.14,
                            ),
                          ),
                          if (option.amountLabel.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              option.amountLabel,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 9,
                                height: 1.0,
                                color: selected
                                    ? tone.withValues(alpha: 0.9)
                                    : Act0ShellTokensV1.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PokerActionChoiceVisualV1 {
  const _PokerActionChoiceVisualV1({
    required this.id,
    required this.icon,
    required this.tone,
  });

  final String id;
  final IconData icon;
  final Color tone;
}

_PokerActionChoiceVisualV1? _pokerActionChoiceVisualV1(String label) {
  final normalized = label.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }
  final firstWord = normalized.split(RegExp(r'\s+')).first;
  if (normalized == 'fold' || firstWord == 'fold') {
    return const _PokerActionChoiceVisualV1(
      id: 'fold',
      icon: Icons.logout_rounded,
      tone: Act0ShellTokensV1.danger,
    );
  }
  if (normalized == 'check' || firstWord == 'check') {
    return const _PokerActionChoiceVisualV1(
      id: 'check',
      icon: Icons.check_rounded,
      tone: Act0VisualCanonV1.greenTable,
    );
  }
  if (normalized == 'call' || firstWord == 'call') {
    return const _PokerActionChoiceVisualV1(
      id: 'call',
      icon: Icons.call_received_rounded,
      tone: Act0ShellTokensV1.primary,
    );
  }
  if (normalized == 'raise' ||
      normalized == 'bet' ||
      normalized.endsWith('-bet') ||
      firstWord == 'raise' ||
      firstWord == 'bet') {
    return const _PokerActionChoiceVisualV1(
      id: 'raise',
      icon: Icons.trending_up_rounded,
      tone: Act0ShellTokensV1.gold,
    );
  }
  return null;
}

class _ActionPromptPanelV1 extends StatelessWidget {
  const _ActionPromptPanelV1({
    required this.taskLabel,
    required this.questionBadgeLabel,
    required this.question,
    required this.child,
    this.contextLine,
    this.trailingContext,
    this.embedChildInSurface = false,
    this.compactDecision = false,
    this.fillAllocatedDock = false,
    this.onBack,
    this.recallLabel,
    this.onRecall,
  });

  final String taskLabel;
  final String questionBadgeLabel;
  final String question;
  final Widget child;
  final String? contextLine;
  final Widget? trailingContext;
  final bool embedChildInSurface;
  final bool compactDecision;
  final bool fillAllocatedDock;
  final VoidCallback? onBack;
  final String? recallLabel;
  final VoidCallback? onRecall;

  @override
  Widget build(BuildContext context) {
    final effectiveCompactDecision =
        !embedChildInSurface &&
        (compactDecision ||
            _CompactAnswerListDecisionScopeV1.isCompact(context) ||
            _usesCompactAnswerListLeafFallbackV1(context));
    final formattedTaskLabel = _formatActionPromptCopyV1(
      taskLabel,
      shortThreshold: 32,
    );
    final formattedQuestion = _formatActionPromptCopyV1(
      question,
      shortThreshold: 58,
    );
    final compactContextLine = (contextLine ?? '').trim();
    final showCompactContextLine =
        compactContextLine.isNotEmpty &&
        compactContextLine != 'Start with what is visible.';
    final normalizedQuestion = question.trim().toLowerCase();
    final normalizedTaskLabel = taskLabel.trim().toLowerCase();
    final isFirstTableOrientation =
        normalizedQuestion.contains('hero seat') ||
        normalizedTaskLabel.contains('correct seat');
    Widget buildPromptHeader({bool integrated = false}) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: _DockBackButtonV1(
                key: const Key('act0_shell_interaction_back_cta'),
                onPressed: onBack!,
              ),
            ),
            const SizedBox(width: Act0ShellTokensV1.gapSm),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFirstTableOrientation) ...[
                  if (effectiveCompactDecision)
                    Row(
                      key: const Key('act0_shell_first_table_read_milestone'),
                      children: [
                        const Icon(
                          Icons.table_restaurant_rounded,
                          size: 13,
                          color: Act0ShellTokensV1.info,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'First table read \u00B7 Locate your seat',
                            key: const Key(
                              'act0_shell_first_table_orientation',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Act0ShellTokensV1.label.copyWith(
                              color: Act0ShellTokensV1.info,
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    Column(
                      key: const Key('act0_shell_first_table_read_milestone'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          key: const Key('act0_shell_first_table_orientation'),
                          children: [
                            const Icon(
                              Icons.table_restaurant_rounded,
                              size: 14,
                              color: Act0ShellTokensV1.info,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'First table read',
                              style: Act0ShellTokensV1.label.copyWith(
                                color: Act0ShellTokensV1.info,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Step 1 \u00B7 Locate your seat',
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontSize: 10.8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Read the table from your seat before any action.',
                      style: Act0ShellTokensV1.muted.copyWith(
                        color: Act0ShellTokensV1.textMuted,
                        fontSize: 10.0,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                ],
                if (!effectiveCompactDecision) ...[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _DockStatusPillV1(
                      key: const Key('act0_shell_question_badge'),
                      label: questionBadgeLabel,
                      icon: Icons.help_outline_rounded,
                      tone: Act0ShellTokensV1.gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formattedTaskLabel,
                    key: const Key('act0_shell_action_task_label'),
                    textAlign: TextAlign.left,
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.info,
                      letterSpacing: 0.12,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.6,
                    ),
                  ),
                ],
                if (!effectiveCompactDecision &&
                    contextLine != null &&
                    contextLine!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    contextLine!,
                    key: const Key('act0_shell_action_context_line'),
                    textAlign: TextAlign.left,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: 10.8,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                ],
                if (!effectiveCompactDecision) const SizedBox(height: 7),
                if (effectiveCompactDecision &&
                    onRecall != null &&
                    recallLabel != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          formattedQuestion,
                          key: const Key('act0_shell_action_question'),
                          textAlign: TextAlign.left,
                          style: Act0ShellTokensV1.body.copyWith(
                            color: Act0ShellTokensV1.text,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w900,
                            height: 1.06,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      KeyedSubtree(
                        key: const Key('act0_shell_compact_hint_inline'),
                        child: _TheoryRecallCtaV1(
                          label: recallLabel!,
                          onPressed: onRecall!,
                          centered: false,
                          compact: true,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    formattedQuestion,
                    key: const Key('act0_shell_action_question'),
                    textAlign: TextAlign.left,
                    style: Act0ShellTokensV1.body.copyWith(
                      color: Act0ShellTokensV1.text,
                      fontSize: effectiveCompactDecision ? 14.0 : 15.8,
                      fontWeight: FontWeight.w900,
                      height: effectiveCompactDecision ? 1.06 : 1.14,
                    ),
                  ),
                if (effectiveCompactDecision && showCompactContextLine) ...[
                  const SizedBox(height: 1),
                  Text(
                    compactContextLine,
                    key: const Key('act0_shell_action_context_line'),
                    textAlign: TextAlign.left,
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                    style: Act0ShellTokensV1.muted.copyWith(
                      color: Act0ShellTokensV1.textMuted,
                      fontSize: 10.6,
                      fontWeight: FontWeight.w700,
                      height: 1.08,
                    ),
                  ),
                ],
                if (!effectiveCompactDecision &&
                    onRecall != null &&
                    recallLabel != null) ...[
                  SizedBox(height: effectiveCompactDecision ? 2 : 6),
                  _TheoryRecallCtaV1(
                    label: recallLabel!,
                    onPressed: onRecall!,
                    centered: false,
                    compact: effectiveCompactDecision,
                  ),
                ],
                if (integrated) ...[
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Act0ShellTokensV1.info.withValues(alpha: 0.16),
                  ),
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      key: const Key('act0_shell_action_prompt_panel'),
      mainAxisSize:
          fillAllocatedDock && question.isNotEmpty && effectiveCompactDecision
          ? MainAxisSize.max
          : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (question.isNotEmpty && embedChildInSurface) ...[
          Container(
            key: const Key('act0_shell_action_prompt_integrated_surface'),
            padding: const EdgeInsets.fromLTRB(
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapSm,
              Act0ShellTokensV1.gapMd,
              Act0ShellTokensV1.gapMd,
            ),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildPromptHeader(integrated: true),
                if (trailingContext != null) ...[
                  trailingContext!,
                  const SizedBox(height: Act0ShellTokensV1.gapSm),
                ],
                child,
              ],
            ),
          ),
        ] else if (question.isNotEmpty && effectiveCompactDecision) ...[
          if (fillAllocatedDock)
            Expanded(child: _buildCompactDecisionSurface(buildPromptHeader))
          else
            _buildCompactDecisionSurface(buildPromptHeader),
        ] else if (question.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.fromLTRB(
              effectiveCompactDecision ? 12 : Act0ShellTokensV1.gapMd,
              effectiveCompactDecision ? 6 : Act0ShellTokensV1.gapSm,
              effectiveCompactDecision ? 12 : Act0ShellTokensV1.gapMd,
              effectiveCompactDecision ? 7 : Act0ShellTokensV1.gapMd,
            ),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface2.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
              border: Border.all(
                color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
              ),
            ),
            child: buildPromptHeader(),
          ),
          SizedBox(
            height: effectiveCompactDecision ? 5 : Act0ShellTokensV1.gapSm,
          ),
        ] else if (question.isEmpty &&
            onRecall != null &&
            recallLabel != null) ...[
          // The canonical scene owns the question, not the hint affordance.
          Align(
            alignment: Alignment.centerLeft,
            child: _TheoryRecallCtaV1(
              label: recallLabel!,
              onPressed: onRecall!,
              compact: effectiveCompactDecision,
            ),
          ),
          const SizedBox(height: 3),
        ] else if (onBack != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: _DockBackButtonV1(
              key: const Key('act0_shell_interaction_back_cta'),
              onPressed: onBack!,
            ),
          ),
          const SizedBox(height: Act0ShellTokensV1.gapSm),
        ],
        // The canonical scene can own the question above this dock.
        // Without a local prompt surface, keep its context and answers mounted.
        if ((!embedChildInSurface || question.isEmpty) &&
            !(question.isNotEmpty && effectiveCompactDecision)) ...[
          if (trailingContext != null) ...[
            trailingContext!,
            const SizedBox(height: Act0ShellTokensV1.gapSm),
          ],
          child,
        ],
      ],
    );
  }

  Widget _buildCompactDecisionContent(
    Widget Function({bool integrated}) buildPromptHeader,
  ) {
    return Column(
      mainAxisSize: fillAllocatedDock ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildPromptHeader(),
        const SizedBox(height: 3),
        if (trailingContext != null) ...[
          const SizedBox(height: Act0ShellTokensV1.gapXs),
          trailingContext!,
          const SizedBox(height: Act0ShellTokensV1.gapXs),
        ],
        if (fillAllocatedDock)
          Expanded(
            child: KeyedSubtree(
              key: const Key('act0_shell_wave1b_actionability_anchor'),
              child: KeyedSubtree(
                key: const Key('act0_shell_wave1b_answer_peek'),
                child: child,
              ),
            ),
          )
        else
          KeyedSubtree(
            key: const Key('act0_shell_wave1b_actionability_anchor'),
            child: KeyedSubtree(
              key: const Key('act0_shell_wave1b_answer_peek'),
              child: child,
            ),
          ),
      ],
    );
  }

  Widget _buildCompactDecisionSurface(
    Widget Function({bool integrated}) buildPromptHeader,
  ) {
    return KeyedSubtree(
      key: const Key('act0_shell_runner_decision_rhythm_surface'),
      child: Container(
        key: const Key('act0_shell_compact_decision_surface'),
        padding: const EdgeInsets.fromLTRB(8, 5, 8, 6),
        decoration: BoxDecoration(
          color: Act0ShellTokensV1.surface2.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Act0ShellTokensV1.info.withValues(alpha: 0.20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: _buildCompactDecisionContent(buildPromptHeader),
      ),
    );
  }
}

class _TheoryRecallCtaV1 extends StatelessWidget {
  const _TheoryRecallCtaV1({
    required this.label,
    required this.onPressed,
    this.centered = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool centered;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final effectiveCompact =
        compact || _CompactAnswerListDecisionScopeV1.isCompact(context);
    if (effectiveCompact) {
      final button = IconButton(
        key: const Key('act0_shell_theory_recall_cta'),
        onPressed: onPressed,
        tooltip: label,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: Act0ShellTokensV1.info,
        ),
        icon: const Icon(Icons.auto_stories_rounded, size: 15),
      );
      if (centered) {
        return Align(alignment: Alignment.center, child: button);
      }
      return Align(alignment: Alignment.centerLeft, child: button);
    }
    final button = TextButton.icon(
      key: const Key('act0_shell_theory_recall_cta'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Act0ShellTokensV1.info.withValues(alpha: 0.10),
        side: BorderSide(color: Act0ShellTokensV1.info.withValues(alpha: 0.24)),
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: effectiveCompact ? 6 : 0,
          vertical: effectiveCompact ? 1 : 2,
        ),
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
        foregroundColor: Act0ShellTokensV1.info,
      ),
      icon: Icon(Icons.auto_stories_rounded, size: effectiveCompact ? 14 : 16),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Act0ShellTokensV1.label.copyWith(
          color: Act0ShellTokensV1.info,
          fontSize: effectiveCompact ? 10.6 : 11.6,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.12,
        ),
      ),
    );
    final coachingChip = KeyedSubtree(
      key: const Key('act0_shell_hint_coaching_chip'),
      child: button,
    );
    if (centered) {
      return Align(alignment: Alignment.center, child: coachingChip);
    }
    return Align(alignment: Alignment.centerLeft, child: coachingChip);
  }
}

class _DecisionHintPeekV1 extends StatelessWidget {
  const _DecisionHintPeekV1({
    required this.quickHint,
    this.localizeW1Ctas = false,
    required this.fullIdeaTitle,
    required this.fullIdeaBlocks,
    required this.showFullIdea,
    required this.onShowFullIdea,
    required this.onClose,
  });

  final String quickHint;
  final bool localizeW1Ctas;
  final String fullIdeaTitle;
  final List<String> fullIdeaBlocks;
  final bool showFullIdea;
  final VoidCallback? onShowFullIdea;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hasFullIdea =
        fullIdeaTitle.trim().isNotEmpty || fullIdeaBlocks.isNotEmpty;
    return Container(
      key: const Key('act0_shell_theory_recall_sheet'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  localizeW1Ctas
                      ? act0AcademyW1CtaV1(context, 'Quick hint')
                      : 'Quick hint',
                  key: const Key('act0_shell_hint_title'),
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    fontSize: 10.2,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.12,
                  ),
                ),
              ),
              TextButton.icon(
                key: const Key('act0_shell_theory_recall_close_cta'),
                onPressed: onClose,
                style: TextButton.styleFrom(
                  foregroundColor: Act0ShellTokensV1.info,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 15),
                label: Text(
                  localizeW1Ctas
                      ? act0AcademyW1CtaV1(context, 'Back to choices')
                      : 'Back to choices',
                  style: Act0ShellTokensV1.label.copyWith(
                    color: Act0ShellTokensV1.info,
                    fontSize: 10.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            quickHint,
            key: const Key('act0_shell_hint_body'),
            style: Act0ShellTokensV1.body.copyWith(
              color: Act0ShellTokensV1.textMuted,
              fontSize: 12.6,
              height: 1.14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasFullIdea && !showFullIdea) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              key: const Key('act0_shell_review_full_idea_cta'),
              onPressed: onShowFullIdea,
              style: TextButton.styleFrom(
                foregroundColor: Act0ShellTokensV1.info,
                minimumSize: const Size(48, 48),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.padded,
              ),
              icon: const Icon(Icons.auto_stories_rounded, size: 15),
              label: Text(
                localizeW1Ctas
                    ? act0AcademyW1CtaV1(context, 'Review full idea')
                    : 'Review full idea',
                style: Act0ShellTokensV1.label.copyWith(
                  color: Act0ShellTokensV1.info,
                  fontSize: 10.8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          if (hasFullIdea && showFullIdea) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              height: 1,
              color: Act0ShellTokensV1.info.withValues(alpha: 0.14),
            ),
            if (fullIdeaTitle.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                fullIdeaTitle.trim(),
                key: const Key('act0_shell_theory_recall_title'),
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.text,
                  fontSize: 14.2,
                  height: 1.08,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
            for (var i = 0; i < fullIdeaBlocks.length; i++) ...[
              SizedBox(height: i == 0 ? 7 : 5),
              Text(
                fullIdeaBlocks[i],
                key: i == 0 ? const Key('act0_shell_theory_recall_body') : null,
                style: Act0ShellTokensV1.body.copyWith(
                  color: Act0ShellTokensV1.textMuted,
                  fontSize: 12.4,
                  height: 1.14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _TheoryRecallSheetV1 extends StatelessWidget {
  const _TheoryRecallSheetV1({
    required this.label,
    required this.title,
    required this.bodyBlocks,
  });

  final String label;
  final String title;
  final List<String> bodyBlocks;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Container(
          key: const Key('act0_shell_theory_recall_sheet'),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: Act0ShellTokensV1.surface,
            borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusLg),
            border: Border.all(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.26),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: Act0ShellTokensV1.label.copyWith(
                        color: Act0ShellTokensV1.info,
                        fontSize: 10.4,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.18,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('act0_shell_theory_recall_close_cta'),
                    onPressed: () => Navigator.of(context).pop(),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 28,
                      height: 28,
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: Act0ShellTokensV1.textMuted,
                  ),
                ],
              ),
              if (title.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  title.trim(),
                  key: const Key('act0_shell_theory_recall_title'),
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.text,
                    fontSize: 16,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
              for (var i = 0; i < bodyBlocks.length; i++) ...[
                SizedBox(height: i == 0 ? 8 : 6),
                Text(
                  bodyBlocks[i],
                  key: i == 0
                      ? const Key('act0_shell_theory_recall_body')
                      : null,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontSize: 13,
                    height: 1.14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StreetReplayInlineV1 extends StatelessWidget {
  const _StreetReplayInlineV1({required this.replay});

  final Act0StreetReplayV1 replay;

  @override
  Widget build(BuildContext context) {
    final currentStreet = replay.steps
        .where((step) => step.isCurrentStreet)
        .toList(growable: false);
    final visibleSteps = currentStreet.isEmpty ? replay.steps : currentStreet;
    final history = Container(
      key: const Key('act0_shell_street_replay_inline'),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 9),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How we got here',
            style: Act0ShellTokensV1.label.copyWith(
              color: Act0ShellTokensV1.info,
              fontSize: 10.4,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < visibleSteps.length; i++) ...[
            _ProofMotionRevealV1(
              key: Key('act0_shell_street_replay_step_motion_$i'),
              child: _StreetReplayStepRowV1(step: visibleSteps[i], index: i),
            ),
            if (i < visibleSteps.length - 1)
              const SizedBox(height: Act0ShellTokensV1.gapXs),
          ],
          if (!visibleSteps.any((step) => step.isCurrentStreet)) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            _StreetReplayCurrentDecisionMarkerV1(replay: replay),
          ],
          if (replay.decisionContext.trim().isNotEmpty) ...[
            const SizedBox(height: Act0ShellTokensV1.gapXs),
            Text(
              replay.decisionContext.trim(),
              key: const Key('act0_shell_street_replay_decision_context'),
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: Act0ShellTokensV1.muted.copyWith(
                color: Act0ShellTokensV1.textMuted,
                fontSize: 10.4,
                height: 1.08,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
    if (visibleSteps.length <= 3) return history;
    // Long current-street histories must leave room for the answer buttons.
    // Start at the pending decision and let the learner scroll back.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height / 3,
      ),
      child: SingleChildScrollView(
        key: const Key('act0_shell_street_replay_scroll'),
        primary: false,
        reverse: true,
        child: history,
      ),
    );
  }
}

class _StreetReplayCurrentDecisionMarkerV1 extends StatelessWidget {
  const _StreetReplayCurrentDecisionMarkerV1({required this.replay});

  final Act0StreetReplayV1 replay;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('act0_shell_street_replay_current_street'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Act0ShellTokensV1.info.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: Act0ShellTokensV1.info.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${replay.currentStreet.name[0].toUpperCase()}${replay.currentStreet.name.substring(1)} decision',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                fontSize: 10.4,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            key: const Key('act0_shell_street_replay_here_marker'),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.info.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
            child: Text(
              'You are here',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.info,
                fontSize: 8.6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreetReplayStepRowV1 extends StatelessWidget {
  const _StreetReplayStepRowV1({required this.step, required this.index});

  final Act0StreetReplayStepV1 step;
  final int index;

  @override
  Widget build(BuildContext context) {
    final board = step.boardCardsAtStreet.join(' ');
    return Container(
      key: Key('act0_shell_street_replay_step_$index'),
      padding: const EdgeInsets.all(Act0ShellTokensV1.gapSm),
      decoration: BoxDecoration(
        color: step.isCurrentStreet
            ? Act0ShellTokensV1.info.withValues(alpha: 0.10)
            : Act0ShellTokensV1.surface2.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusMd),
        border: Border.all(
          color: step.isCurrentStreet
              ? Act0ShellTokensV1.info.withValues(alpha: 0.32)
              : Act0ShellTokensV1.border.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Act0ShellTokensV1.surface3.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
            ),
            child: Text(
              '${index + 1}',
              style: Act0ShellTokensV1.label.copyWith(
                color: Act0ShellTokensV1.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: Act0ShellTokensV1.gapSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        board.isEmpty
                            ? step.streetLabel
                            : '${step.streetLabel} - $board',
                        key: step.isCurrentStreet
                            ? const Key(
                                'act0_shell_street_replay_current_street',
                              )
                            : null,
                        style: Act0ShellTokensV1.label.copyWith(
                          color: Act0ShellTokensV1.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (step.isCurrentStreet) ...[
                      const SizedBox(width: 7),
                      Container(
                        key: const Key('act0_shell_street_replay_here_marker'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Act0ShellTokensV1.info.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(
                            Act0ShellTokensV1.radiusPill,
                          ),
                        ),
                        child: Text(
                          step.youAreHereLabel,
                          style: Act0ShellTokensV1.label.copyWith(
                            color: Act0ShellTokensV1.info,
                            fontSize: 8.6,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  step.actionSummary,
                  style: Act0ShellTokensV1.body.copyWith(
                    color: Act0ShellTokensV1.textMuted,
                    fontSize: 12,
                    height: 1.12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (step.potAtStreet.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.potAtStreet.trim(),
                    style: Act0ShellTokensV1.label.copyWith(
                      color: Act0ShellTokensV1.textDim,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatActionPromptCopyV1(String text, {required int shortThreshold}) {
  final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.length <= shortThreshold) {
    return normalized;
  }
  return _formatInstructionCopyV1(normalized, allowSingleClauseSplit: true);
}

class _DockStatusPillV1 extends StatelessWidget {
  const _DockStatusPillV1({
    super.key,
    required this.label,
    required this.icon,
    required this.tone,
  });

  final String label;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Act0ShellTokensV1.radiusPill),
        border: Border.all(color: tone.withValues(alpha: 0.34)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tone),
          const SizedBox(width: 5),
          Text(
            label,
            style: Act0ShellTokensV1.label.copyWith(
              color: tone,
              fontSize: 9.5,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionToneV1 {
  const _ActionToneV1({required this.foreground});

  final Color foreground;

  static _ActionToneV1 fromOption(Act0RunnerOptionV1 option) {
    final key = '${option.id} ${option.label}'.toLowerCase();
    if (key.contains('call')) {
      return _ActionToneV1(foreground: Act0ShellTokensV1.info);
    }
    if (key.contains('raise') || key.contains('bet') || key.contains('all')) {
      return _ActionToneV1(foreground: Act0ShellTokensV1.primary);
    }
    if (key.contains('fold') || key.contains('check')) {
      return _ActionToneV1(foreground: Act0ShellTokensV1.text);
    }
    return _ActionToneV1(foreground: Act0ShellTokensV1.text);
  }
}
