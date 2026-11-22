import 'act0_shell_state_v1.dart';

class Act0W1RulesQuestionV1 {
  const Act0W1RulesQuestionV1({
    required this.id,
    required this.lessonId,
    required this.topic,
    required this.question,
    required this.choices,
    required this.correctChoice,
    required this.reason,
    this.hero = '',
    this.board = '',
    this.opponent = '',
    this.occupiedSeats = const ['BTN'],
    this.foldedSeats = const [],
    this.actedSeats = const [],
  });

  final String id;
  final String lessonId;
  final String topic;
  final String question;
  final List<String> choices;
  final int correctChoice;
  final String reason;
  final String hero;
  final String board;
  final String opponent;
  final List<String> occupiedSeats;
  final List<String> foldedSeats;
  final List<String> actedSeats;

  String get taskId => 'w1_rules_check_$id';
  String get correctLabel => choices[correctChoice];

  Act0RunnerStateV1 runner(int index) {
    final heroCards = _rulesCards(hero);
    final boardCards = _rulesCards(board);
    final opponentCards = _rulesCards(opponent);
    return Act0RunnerStateV1(
      lessonId: lessonId,
      lessonTitle: 'W1 rules check',
      lessonSubtitle: '',
      beatIndex: index + 1,
      beatCount: act0W1RulesQuestionsV1.length,
      phase: Act0LessonPhaseV1.drill,
      caption: '',
      hint: '',
      hintPolicy: Act0HintPolicyV1.hidden,
      question: question,
      options: [
        for (final (choice, label) in choices.indexed)
          Act0RunnerOptionV1(
            id: 'choice_$choice',
            label: label,
            isCorrect: choice == correctChoice,
            quality: choice == correctChoice
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            preferredLabel: correctLabel,
            betterAnswerLabel: choice == correctChoice ? '' : correctLabel,
            feedbackTitle: topic,
            feedbackReason: reason,
          ),
      ],
      feedbackTitle: topic,
      feedbackReason: reason,
      primaryCtaLabel: '',
      nextLessonId: null,
      returnTarget: '',
      table: Act0TableStateV1(
        tableFormat: Act0TableFormatV1.sixMax,
        playerCount: 6,
        heroSeatId: 'btn',
        heroCards: heroCards,
        boardCards: boardCards,
        streetLabel: switch (boardCards.length) {
          5 => 'River',
          4 => 'Turn',
          3 => 'Flop',
          _ => 'Preflop',
        },
        potLabel: '',
        toCallLabel: '',
        centerLabel: '',
        highlightedSeatIds: const [],
        highlightedCardIds: const [],
        seats: [
          for (final seat in act0CanonicalSeatOrderForFormatV1(
            Act0TableFormatV1.sixMax,
          ))
            _seat(seat, heroCards, opponentCards),
        ],
      ),
    );
  }

  Act0SeatStateV1 _seat(
    String seat,
    List<Act0CardStateV1> heroCards,
    List<Act0CardStateV1> opponentCards,
  ) {
    final cards = switch (seat) {
      'BTN' => heroCards,
      'CO' => opponentCards,
      _ => const <Act0CardStateV1>[],
    };
    final occupied = occupiedSeats.contains(seat) || cards.isNotEmpty;
    final folded = foldedSeats.contains(seat);
    return Act0SeatStateV1(
      seatId: seat.toLowerCase(),
      seatLabel: seat,
      displayName: seat == 'BTN' ? 'You' : seat,
      isHero: seat == 'BTN',
      isDealerButton: seat == 'BTN',
      isSmallBlind: occupied && seat == 'SB',
      isBigBlind: occupied && seat == 'BB',
      isOccupied: occupied,
      isInHand: occupied && !folded,
      isFolded: folded,
      hasActed: folded || actedSeats.contains(seat),
      holeCards: cards,
      cardsVisibleMode: cards.isNotEmpty
          ? Act0CardsVisibleModeV1.faceUp
          : occupied && !folded
          ? Act0CardsVisibleModeV1.faceDown
          : Act0CardsVisibleModeV1.none,
    );
  }
}

List<Act0CardStateV1> _rulesCards(String cards) => [
  if (cards.isNotEmpty)
    for (final card in cards.split(' '))
      Act0CardStateV1(rank: card[0], suit: card[1]),
];

const _sixSeats = ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'];

const act0W1RulesQuestionsV1 = <Act0W1RulesQuestionV1>[
  Act0W1RulesQuestionV1(
    id: 'made_hand',
    lessonId: 'hand_rankings_upper',
    topic: 'Hand rankings',
    question: 'At showdown, which hand wins in Hold’em?',
    choices: ['Two pair', 'Three of a kind', 'They tie'],
    correctChoice: 1,
    reason: 'Three of a kind ranks above two pair.',
  ),
  Act0W1RulesQuestionV1(
    id: 'ace_kicker',
    lessonId: 'showdown_winning',
    topic: 'Kickers and ties',
    question: 'You hold A♠ 7♥ and CO holds K♠ Q♦. On this board, who wins?',
    choices: ['You', 'CO', 'Split the pot'],
    correctChoice: 0,
    reason:
        'Both play a pair of nines. Your ace beats CO’s king as the highest kicker.',
    hero: 'As 7h',
    opponent: 'Ks Qd',
    board: '9c 9d 6s 4h 2c',
  ),
  Act0W1RulesQuestionV1(
    id: 'board_tie',
    lessonId: 'showdown_winning',
    topic: 'Kickers and ties',
    question: 'You hold 2♣ 3♦ and CO holds 7♥ 8♣. Who wins this pot?',
    choices: ['You', 'CO', 'Split the pot'],
    correctChoice: 2,
    reason:
        'Both players use the board’s ace-high straight. Cards outside the best five do not break a tie.',
    hero: '2c 3d',
    opponent: '7h 8c',
    board: 'As Kd Qc Jh Ts',
  ),
  Act0W1RulesQuestionV1(
    id: 'best_straight',
    lessonId: 'cards_ranks_suits',
    topic: 'Best five cards',
    question:
        'You can play a straight. What is the top card in your best five?',
    choices: ['7', 'Ace', '8'],
    correctChoice: 2,
    reason:
        'Your best straight uses 4, 5, 6, 7, and 8. The ace is outside that five-card hand.',
    hero: '8d Ah',
    board: '3c 4d 5h 6s 7c',
  ),
  Act0W1RulesQuestionV1(
    id: 'preflop_after_hj',
    lessonId: 'blinds_action_order',
    topic: 'Preflop order',
    question:
        'At a six-player table before the flop, UTG has acted and HJ folds. Who acts next?',
    choices: ['BTN', 'CO', 'BB'],
    correctChoice: 1,
    reason:
        'After HJ, the first preflop pass goes to CO, then BTN, then the blinds.',
    occupiedSeats: _sixSeats,
    foldedSeats: ['HJ'],
    actedSeats: ['UTG', 'HJ'],
  ),
  Act0W1RulesQuestionV1(
    id: 'postflop_two_left',
    lessonId: 'positions',
    topic: 'Postflop order',
    question:
        'A six-player hand is down to SB and BTN on the flop. Who acts first?',
    choices: ['SB', 'BTN', 'Whoever raised before the flop'],
    correctChoice: 0,
    reason:
        'On the flop, the first player still in the hand clockwise after the dealer acts first. That is SB here.',
    board: 'Kc 8d 5h',
    occupiedSeats: _sixSeats,
    foldedSeats: ['UTG', 'HJ', 'CO', 'BB'],
  ),
  Act0W1RulesQuestionV1(
    id: 'forced_bets',
    lessonId: 'blinds_action_order',
    topic: 'Blinds',
    question:
        'At a six-player table with no ante or straddle, who must put chips in before the deal?',
    choices: [
      'Only the big blind',
      'Every player',
      'The small blind and big blind',
    ],
    correctChoice: 2,
    reason: 'The small blind and big blind are the forced bets in this setup.',
    occupiedSeats: _sixSeats,
  ),
  Act0W1RulesQuestionV1(
    id: 'check_behind',
    lessonId: 'fold_check_call_raise',
    topic: 'Legal actions',
    question:
        'It is your turn on the river. Every player before you checked. How can you stay in without adding chips?',
    choices: ['Call', 'Check', 'Fold'],
    correctChoice: 1,
    reason:
        'CO checked on the river, so checking takes you to showdown without paying. A fold gives up your chance to win.',
    board: '2s 6c 9d Jh Qc',
    occupiedSeats: ['CO', 'BTN'],
    actedSeats: ['CO'],
  ),
  Act0W1RulesQuestionV1(
    id: 'raise_call_price',
    lessonId: 'fold_check_call_raise',
    topic: 'Price to call',
    question:
        'You put in 3 BB on this street. An opponent raises to 8 BB. How much more does a call cost you?',
    choices: ['5 BB', '8 BB', '11 BB'],
    correctChoice: 0,
    reason: 'You already put in 3 BB. Add 5 BB to match the new total of 8 BB.',
    occupiedSeats: ['CO', 'BTN'],
  ),
  Act0W1RulesQuestionV1(
    id: 'uncalled_all_in',
    lessonId: 'what_poker_is_content',
    topic: 'All-in bets',
    question:
        'Two players remain. You go all-in for 25 BB. Your opponent can call only 11 BB. How much of your bet is returned?',
    choices: ['11 BB', '25 BB', '14 BB'],
    correctChoice: 2,
    reason:
        'Your opponent matches 11 BB. The remaining 14 BB of your bet is uncalled and comes back to you.',
    occupiedSeats: ['CO', 'BTN'],
  ),
];

class Act0W1RulesResultV1 {
  Act0W1RulesResultV1(List<int> choices)
    : choices = List.unmodifiable(choices) {
    if (choices.length != act0W1RulesQuestionsV1.length ||
        choices.indexed.any(
          (entry) =>
              entry.$2 < 0 ||
              entry.$2 >= act0W1RulesQuestionsV1[entry.$1].choices.length,
        )) {
      throw ArgumentError.value(
        choices,
        'choices',
        'Complete the ten questions',
      );
    }
  }

  static const passingScore = 9;
  static const xpPerCorrectAnswer = 2;
  final List<int> choices;

  int get score => choices.indexed
      .where(
        (entry) => entry.$2 == act0W1RulesQuestionsV1[entry.$1].correctChoice,
      )
      .length;
  bool get passed => score >= passingScore;
  int get xp => score * xpPerCorrectAnswer;
  Iterable<Act0W1RulesQuestionV1> get missedQuestions sync* {
    for (final (index, choice) in choices.indexed) {
      final question = act0W1RulesQuestionsV1[index];
      if (choice != question.correctChoice) yield question;
    }
  }
}
