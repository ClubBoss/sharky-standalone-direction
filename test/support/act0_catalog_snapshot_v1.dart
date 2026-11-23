import 'package:poker_analyzer/ui_v2/act0_shell/act0_decision_reasoning_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_lesson_runner_shell_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_prechoice_answer_cue_policy_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_decision_v1.dart';
import 'act0_catalog_poker_facts_v1.dart';

typedef CatalogTask = ({
  Act0WorldCardV1 world,
  Act0LessonCardV1 lesson,
  Act0LessonTaskV1 task,
  int lessonIndex,
});

final catalogTasks = [
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final (index, lesson) in world.lessons.indexed)
      for (final task in lesson.taskList)
        (world: world, lesson: lesson, task: task, lessonIndex: index),
];

final rulesCheckCatalogTasks = [
  for (final entry in act0W1RulesReviewTasksV1)
    (
      world: Act0ShellStateV1.sample.worldById(entry.worldId),
      lesson: Act0ShellStateV1.sample.lessonById(entry.lessonId),
      task: entry.task,
      lessonIndex: Act0ShellStateV1.sample
          .worldById(entry.worldId)
          .lessons
          .indexWhere((lesson) => lesson.lessonId == entry.lessonId),
    ),
];

final day7CatalogTasks = [
  for (final entry in act0NewReviewTasksV1)
    (
      world: Act0ShellStateV1.sample.worldById(entry.worldId),
      lesson: Act0ShellStateV1.sample.lessonById(entry.lessonId),
      task: entry.task,
      lessonIndex: Act0ShellStateV1.sample
          .worldById(entry.worldId)
          .lessons
          .indexWhere((lesson) => lesson.lessonId == entry.lessonId),
    ),
];

String catalogQuestion(Act0LessonTaskV1 task) =>
    (act0IsPrechoiceAssessmentTaskV1(task)
        ? act0PrechoiceNeutralQuestionByTaskIdV1[task.taskId]
        : null) ??
    task.runner.question;

String catalogTitle(Act0LessonTaskV1 task) => act0PrechoiceDisplayTitleV1(
  taskId: task.taskId,
  authoredTitle: task.title,
  isAssessment: act0IsPrechoiceAssessmentTaskV1(task),
  hasSubmittedCurrentDecision: false,
);

String _joined(Iterable<String> values) => values.join(', ');

String catalogTableLine(Act0TableStateV1 table) {
  final facts = CatalogPokerFacts(table);
  return [
    table.streetLabel,
    if (facts.hero.isNotEmpty) 'You ' + facts.hero.join(' '),
    if (facts.board.isNotEmpty) 'Board ' + facts.board.join(' '),
    table.potLabel,
    table.toCallLabel,
    if (table.seats.any((seat) => seat.isHero))
      'Seat ' + table.heroSeat.seatLabel,
    if ((table.activeSeatId ?? '').isNotEmpty) 'Active ' + table.activeSeatId!,
    if ((table.decisionSeatId ?? '').isNotEmpty)
      'Decision ' + table.decisionSeatId!,
    if (table.highlightedSeatIds.isNotEmpty)
      'Seat focus ' + _joined(table.highlightedSeatIds),
    if (table.highlightedCardIds.isNotEmpty)
      'Card focus ' + _joined(table.highlightedCardIds),
    if (table.selectableSeatIds.isNotEmpty)
      'Tap ' + _joined(table.selectableSeatIds),
    if (table.centerLabel.isNotEmpty) 'Center ' + table.centerLabel,
    if (table.focusCalloutLabel.isNotEmpty)
      'Callout ' + table.focusCalloutLabel,
    if (table.emptyBoardLabel.isNotEmpty)
      'Empty board ' + table.emptyBoardLabel,
    'Facts ' + facts.description,
  ].where((part) => part.isNotEmpty).join(' | ');
}

String _seatLine(Act0TableStateV1 table) => table.seats
    .map(
      (seat) => [
        seat.seatLabel,
        if (!seat.isOccupied) 'empty',
        if (seat.isFolded) 'folded',
        if (seat.isDealerButton) 'dealer',
        if (seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp &&
            physicalCards(seat.holeCards).isNotEmpty)
          physicalCards(seat.holeCards).join(' '),
        if (seat.stackLabel case final stack?) 'stack $stack',
        if (seat.bet case final bet?) bet.kind.name + ' ' + bet.amountLabel,
      ].join(' '),
    )
    .join(' | ');

String _trail(Act0TableStateV1 table) => table.actionTrail
    .map((item) => item.displayLabel ?? item.label)
    .join(' · ');

Iterable<String> renderCatalogTaskSectionV1(
  Iterable<CatalogTask> rows, {
  bool showPotBeforeDecision = false,
}) sync* {
  String? lessonId;
  for (final row in rows) {
    final task = row.task;
    final runner = task.runner;
    final table = runner.table;
    final tableLine = catalogTableLine(table);
    if (lessonId != row.lesson.authoredLessonId) {
      lessonId = row.lesson.authoredLessonId;
      yield '===== WORLD ' +
          row.world.worldNumber.toString() +
          ' · LESSON $lessonId · ' +
          row.lesson.title +
          ' =====';
      yield '';
    }
    final reviewFamily = act0NewReviewConceptFamilyV1(
      row.world.worldId,
      row.lesson.authoredLessonId,
      task.taskId,
    );
    yield 'TASK ' +
        task.taskId +
        ' [' +
        task.phase.name +
        '] ' +
        catalogTitle(task);
    if (reviewFamily != null) yield 'DAY 7 FAMILY: $reviewFamily';
    if (task.entryPhase != task.phase) yield 'ENTRY: ${task.entryPhase.name}';
    if (catalogTitle(task) != task.title) yield 'AUTHORED TITLE: ' + task.title;
    final summary = task.summary;
    if (summary != null && summary.isNotEmpty) {
      yield 'SUMMARY: ' +
          act0PrechoiceDisplaySummaryV1(
            taskId: task.taskId,
            authoredSummary: summary,
            isAssessment: act0IsPrechoiceAssessmentTaskV1(task),
            hasSubmittedCurrentDecision: false,
          );
    }
    if (runner.caption.isNotEmpty) yield 'CAPTION: ' + runner.caption;
    for (final step in runner.teachingSteps) {
      yield 'TEACH: ' + step.title + ' ' + step.body;
      if (step.ctaLabel != 'Next') yield 'TEACH CTA: ${step.ctaLabel}';
      if (step.focusLabels.isNotEmpty)
        yield 'TEACH LABELS: ' + _joined(step.focusLabels);
      final projected = act0TeachingTableForRunnerV1(table, step);
      final projectedLine = catalogTableLine(projected);
      if (projectedLine != tableLine) yield 'TEACH TABLE: $projectedLine';
      if (_seatLine(projected) != _seatLine(table))
        yield 'TEACH SEATS: ' + _seatLine(projected);
      if (_trail(projected) != _trail(table))
        yield 'TEACH TRAIL: ' + _trail(projected);
    }
    yield 'Q: ' + catalogQuestion(task);
    if (catalogQuestion(task) != runner.question)
      yield 'AUTHORED Q: ' + runner.question;
    yield 'HINT [${runner.hintPolicy.name}]: ' +
        (runner.hint.trim().isEmpty ? '(none)' : runner.hint);
    yield 'TABLE: $tableLine';
    if (catalogDecisionKindV1(task, row.world.worldNumber) ==
        Act0DecisionKindV1.table) {
      final decision = CatalogDecisionLedgerV1(table);
      final stacks = [
        for (final seat in decision.activeSeatIds)
          if (seat != table.heroSeat.seatId)
            '${decision.seatLabel(seat)} '
                '${decision.effectiveStacks[seat] == null ? 'unknown' : _bb(decision.effectiveStacks[seat]!)}',
      ];
      yield 'EFFECTIVE: ${stacks.isEmpty ? 'none' : stacks.join(' · ')}';
      if (decision.hasAllIn && showPotBeforeDecision) {
        final pot = decision.ledger
            ?.amounts(seatIds: decision.occupiedSeatIds)
            .potBb;
        yield 'POTS: ${pot == null ? 'unknown' : 'current ${_bb(pot)}'}';
      } else if (decision.hasAllIn) {
        final pots = decision.pots;
        yield 'POTS: ${pots == null
            ? 'unknown'
            : pots.isEmpty
            ? 'pending'
            : [for (final (i, pot) in pots.indexed) '${i == 0 ? 'main' : 'side'} ${_bb(pot.amountBb)} '
                    '(${pot.eligibleSeatIds.map(decision.seatLabel).join(', ')})'].join(' · ')}';
      }
    }
    if (act0DecisionReasoningV1[task.taskId] case final reason?) {
      yield 'REASONING: principle ${reason.principleId} · '
          'alt ${reason.bestAlternativeOptionId} · '
          'edge ${reason.edgeMechanism.name}'
          '${reason.edgeBb == null ? '' : ' ${_bb(reason.edgeBb!)} BB'} · '
          'stack_matters ${reason.stackMatters ?? 'unknown'} · '
          'assumption ${reason.preChoiceAssumption ?? 'none'}';
    }
    if (table.seats.isNotEmpty) yield 'SEATS: ' + _seatLine(table);
    if (table.actionTrail.isNotEmpty) yield 'TRAIL: ' + _trail(table);
    if (runner.options.isEmpty && runner.feedbackReason.isNotEmpty)
      yield 'REVIEW: ${runner.feedbackReason}';
    if (runner.sizingConfig.isEnabled) {
      yield 'SIZES: ' +
          runner.sizingConfig.presets
              .map(
                (preset) =>
                    (preset.displayLabel ?? preset.label) +
                    ' ' +
                    preset.potFraction.toString(),
              )
              .join(' | ');
    }
    for (final o in runner.options) {
      final sign = o.isCorrect ? '+' : '-';
      yield '  $sign [' +
          o.quality.name +
          '] ' +
          o.label +
          (o.seatId == null ? '' : ' [seat ${o.seatId}]') +
          (o.amountLabel.isEmpty ? '' : ' [' + o.amountLabel + ']') +
          ' — ' +
          o.feedbackTitle +
          ' ' +
          o.feedbackReason;
      if (o.betterAnswerLabel.isNotEmpty && o.betterAnswerLabel != o.label)
        yield '    BETTER ANSWER: ${o.betterAnswerLabel}';
      if (o.repairFocusLabels.isNotEmpty)
        yield '    REPAIR LABELS: ' + _joined(o.repairFocusLabels);
      final feedbackTable = act0FeedbackTableForRunnerV1(
        runner: runner.copyWith(
          phase: Act0LessonPhaseV1.review,
          selectedOptionId: o.id,
          teachingStepIndex: runner.teachingSteps.length,
        ),
        taskFamily: task.resolvedTaskFamily,
      );
      final feedbackLine = catalogTableLine(feedbackTable);
      if (feedbackLine != tableLine) yield '    FEEDBACK TABLE: $feedbackLine';
      if (_seatLine(feedbackTable) != _seatLine(table))
        yield '    FEEDBACK SEATS: ' + _seatLine(feedbackTable);
      if (_trail(feedbackTable) != _trail(table))
        yield '    FEEDBACK TRAIL: ' + _trail(feedbackTable);
    }
    yield '';
  }
}

String renderCatalogSnapshot({Set<int>? worlds, bool excludePilot = false}) {
  Iterable<CatalogTask> include(Iterable<CatalogTask> rows) => worlds == null
      ? rows.where((row) => !excludePilot || row.world.worldNumber <= 12)
      : rows.where((row) => worlds.contains(row.world.worldNumber));
  final course = include(catalogTasks).toList();
  final worldNames = worlds == null
      ? 'W1–W${course.last.world.worldNumber}'
      : (worlds.toList()..sort()).map((world) => 'W$world').join(', ');
  return ([
        'SHARKY POKER — EN learning content, ${course.length} tasks · $worldNames',
        'Canonical catalog order. Options tagged +/−; repair-only tasks follow the route.',
        'Teaching and feedback table variants use the Runner projections. Board facts are deterministic.',
        '',
        ...renderCatalogTaskSectionV1(
          course.where((row) => !row.task.repairOnly),
        ),
        '===== REPAIR-ONLY TASKS =====',
        '',
        ...renderCatalogTaskSectionV1(
          course.where((row) => row.task.repairOnly),
        ),
        if (worlds == null || worlds.contains(1)) ...[
          '===== W1 RULES CHECK =====',
          '',
          ...renderCatalogTaskSectionV1(include(rulesCheckCatalogTasks)),
        ],
        '===== DAY 7 REVIEW-ONLY TASKS · ZERO XP =====',
        '',
        ...renderCatalogTaskSectionV1(include(day7CatalogTasks)),
      ].join('\n').trimRight() +
      '\n');
}

String _bb(double value) => double.parse(
  value.toStringAsFixed(8),
).toString().replaceFirst(RegExp(r'\.0$'), '');
