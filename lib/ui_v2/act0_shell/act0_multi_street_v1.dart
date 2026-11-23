part of 'act0_shell_state_v1.dart';

/// A multi_street task projects each decision from the same authored line.
class Act0MultiStreetV1 {
  Act0MultiStreetV1(
    Act0HandTimelinePrefixV1 line,
    List<({int boundary, Act0RunnerStateV1 runner, String authoredChoiceId})>
    points,
  ) : decisions = List.unmodifiable(points.map((point) => point.runner)) {
    if (decisions.length < 2 ||
        decisions.length > 4 ||
        line.coverage != Act0HandHistoryCoverageV1.complete) {
      throw const FormatException('Expected two to four complete decisions');
    }
    var previousBoundary = 0;
    final choiceIds = <String>{};
    for (final (index, point) in points.indexed) {
      if (point.boundary <= previousBoundary ||
          point.boundary > line.events.length) {
        throw FormatException('Invalid multi-street boundary ${index + 1}');
      }
      final prefix = line.takeEvents(point.boundary);
      final runner = point.runner;
      final table = runner.table;
      final priorStreet = index == 0
          ? PokerStreet.flop
          : decisions[index - 1].table.handTimelinePrefix!.street;
      if (prefix.street.index < priorStreet.index ||
          table.streetLabel != pokerStreetToString(prefix.street) ||
          table.decisionSeatId != prefix.heroSeat ||
          {
                ...prefix.board,
                ...table.heroCards.map((card) => card.label),
              }.length !=
              prefix.board.length + 2 ||
          table.seats.any(
            (seat) =>
                !seat.isHero &&
                seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp,
          ) ||
          prefix.street.index > priorStreet.index + 1 ||
          runner.caption.trim().isEmpty ||
          runner.question.trim().isEmpty ||
          !table.showDecisionPremise ||
          table.heroSeatId != prefix.heroSeat ||
          table.handTimelinePrefix?.events.length != point.boundary ||
          !prefix.events.indexed.every(
            (entry) =>
                identical(entry.$2, table.handTimelinePrefix!.events[entry.$1]),
          ) ||
          !act0PilotDailyDealTableIsValidV1(table) ||
          runner.options.length < 2 ||
          runner.options
                  .where(
                    (option) => option.quality == Act0FeedbackQualityV1.correct,
                  )
                  .length !=
              1 ||
          !runner.options.any(
            (option) =>
                option.id == point.authoredChoiceId &&
                option.quality.isPreferred,
          ) ||
          runner.options.any(
            (option) =>
                option.id.trim().isEmpty ||
                !choiceIds.add(option.id) ||
                option.quality == Act0FeedbackQualityV1.suboptimal ||
                option.isCorrect != option.quality.passes ||
                option.feedbackReason.trim().isEmpty,
          )) {
        throw FormatException('Invalid multi-street decision ${index + 1}');
      }
      previousBoundary = point.boundary;
    }
  }

  static const taskType = 'multi_street';
  final List<Act0RunnerStateV1> decisions;

  Act0RunnerOptionV1? choiceAt(int index, String? choiceId) => decisions[index]
      .options
      .where((option) => option.id == choiceId)
      .firstOrNull;
}

Act0LessonTaskV1 _w16HandPlaythroughV1(
  String sourceId,
  int flopBet,
  int turnBet, {
  bool threeBet = false,
  int riverLead = 0,
}) {
  // Accepted W16 specs. The river keeps the original enumerated response
  // model. Earlier choices exercise sizing on the recorded bet/call line.
  final source = _world16SourceV1.lessons
      .expand((lesson) => lesson.tasks)
      .singleWhere((task) => task.taskId == sourceId);
  final river = source.runner;
  final line = river.table._withTimeline({
    PokerStreet.preflop: [
      ('sb', Act0HandVerbV1.smallBlind, 50),
      ('bb', Act0HandVerbV1.bigBlind, 100),
      ('utg', Act0HandVerbV1.fold, 0),
      ('hj', Act0HandVerbV1.fold, 0),
      ('co', Act0HandVerbV1.fold, 0),
      ('btn', Act0HandVerbV1.raise, 250),
      ('sb', Act0HandVerbV1.fold, 0),
      if (threeBet) ...[
        ('bb', Act0HandVerbV1.raise, 900),
        ('btn', Act0HandVerbV1.call, 750),
      ] else
        ('bb', Act0HandVerbV1.call, 150),
    ],
    PokerStreet.flop: [
      ('bb', Act0HandVerbV1.check, 0),
      ('btn', Act0HandVerbV1.bet, flopBet),
      ('bb', Act0HandVerbV1.call, flopBet),
    ],
    PokerStreet.turn: [
      ('bb', Act0HandVerbV1.check, 0),
      ('btn', Act0HandVerbV1.bet, turnBet),
      ('bb', Act0HandVerbV1.call, turnBet),
    ],
    PokerStreet.river: [
      (
        'bb',
        riverLead == 0 ? Act0HandVerbV1.check : Act0HandVerbV1.bet,
        riverLead,
      ),
    ],
  }).handTimelinePrefix!;
  final taskId = 'h5_$sourceId';
  const title = 'Play the hand';

  final points = [
    for (final street in [
      PokerStreet.flop,
      PokerStreet.turn,
      PokerStreet.river,
    ])
      () {
        final boundary = street == PokerStreet.river
            ? line.events.length
            : line.events.indexWhere(
                (event) =>
                    event is Act0HandActionV1 &&
                    event.street == street &&
                    event.seat == 'btn',
              );
        final prefix = line.takeEvents(boundary);
        // H2's paused frame is safe to include through the current street
        // here because the input ends at this decision.
        final frame = Act0StreetSummaryV1(
          prefix,
          completedHand: true,
        ).frameAt(street)!;
        final table = _day7TableV1(
          hero: 'btn',
          actor: 'btn',
          hand: river.table.heroCards.map((card) => card.label).join(' '),
          street: street,
          board: _act0LessonCardsV1(frame.board.join(' ')),
          folded: frame.foldedSeats!,
          entries: prefix.contributions.entries,
          stacks: prefix.contributions.startingStackBbBySeat,
          history: [
            for (final action in prefix.events.whereType<Act0HandActionV1>())
              Act0ActionTrailItemV1(label: _pilotTrailLabelV1(action)),
          ],
          bets: street == PokerStreet.river
              ? {
                  for (final seat in river.table.seats)
                    if (seat.bet case final bet?) seat.seatId: bet,
                }
              : const {},
        ).copyWith(handTimelinePrefix: prefix, showDecisionPremise: true);

        if (street == PokerStreet.river &&
            (table.potLabel != river.table.potLabel ||
                table.toCallLabel != river.table.toCallLabel)) {
          throw FormatException('River amount differs from $sourceId');
        }

        var caption = river.caption;
        var question = river.question;
        var options = river.options;
        if (street != PokerStreet.river) {
          final wager =
              (line.events[boundary] as Act0HandActionV1).chipsAdded /
              line.bigBlind;
          final pot = frame.potBb!;
          final target = _act0BbLabelV1(pot + 2 * wager);
          final bet = 'Bet ${_act0BbLabelV1(wager)}';
          caption =
              'BB has checked. Assume BB calls any bet you see here. '
              'Your sizing goal is a pot of $target at the end of this street.';
          question = 'Which ${street.name} action reaches that pot?';
          options = _wave6AuthoredChoicesV1([
            (
              'bet',
              bet,
              Act0FeedbackQualityV1.correct,
              'Your bet and BB’s matching call bring the pot to $target.',
            ),
            (
              'check',
              'Check',
              Act0FeedbackQualityV1.wrong,
              'Checking closes the street with ${_act0BbLabelV1(pot)} in the pot.',
            ),
          ]);
        }
        final authored = options.singleWhere(
          (option) => option.quality == Act0FeedbackQualityV1.correct,
        );
        return (
          boundary: boundary,
          authoredChoiceId: '${street.name}_${authored.id}',
          runner: river.copyWith(
            lessonId: taskId,
            lessonTitle: title,
            caption: caption,
            question: question,
            table: table,
            feedbackReason: authored.feedbackReason,
            options: [
              for (final option in options)
                Act0RunnerOptionV1(
                  id: '${street.name}_${option.id}',
                  label: option.label,
                  amountLabel: option.amountLabel,
                  isCorrect: option.isCorrect,
                  quality: option.quality,
                  preferredLabel: option.preferredLabel,
                  betterAnswerLabel: option.betterAnswerLabel,
                  feedbackTitle: option.feedbackTitle,
                  feedbackReason: option.id != authored.id
                      ? '${option.feedbackReason} This hand continues with the recorded play: ${authored.label}.'
                      : option.feedbackReason,
                ),
            ],
          ),
        );
      }(),
  ];
  final hand = Act0MultiStreetV1(line, points);
  return Act0LessonTaskV1(
    taskId: taskId,
    title: title,
    phase: Act0LessonPhaseV1.drill,
    taskFamily: Act0TaskFamilyV1.transfer,
    runner: hand.decisions.first,
    rewardXp: source.rewardXp,
    multiStreet: hand,
  );
}
