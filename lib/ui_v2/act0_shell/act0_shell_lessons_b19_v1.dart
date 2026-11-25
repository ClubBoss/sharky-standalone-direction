part of 'act0_shell_state_v1.dart';

final _b19PilotLessons = [
  _act0PilotLessonV1("where_is_the_mistake", "Where is the mistake in this hand?", [
    // B17 source world: 4.
    _b92MistakeDrillV1(
      id: "mistake_half_pot",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "You told a study partner you would bet half the river pot. Review these annotated actions. BTN opens to 2.75 BB and BB calls. The flop and turn then check through.",
      question: "Which annotated action misses the stated sizing plan?",
      choices: const [
        (
          "river_bet",
          "River · bet 2 BB",
          "Half of this 6 BB pot is 3 BB. The reviewed bet is only one third.",
        ),
        (
          "open",
          "Preflop · open to 2.75 BB",
          "That is the earlier open. The plan applies to a fraction of the river pot.",
        ),
        (
          "bb_call",
          "Preflop · BB calls 1.75 BB more",
          "The blind already put in one BB, so this call correctly matches the open.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ac Qd",
        board: "Qs 8c 4h 3d 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.75",
          "preflop: SB folds",
          "preflop: BB calls 1.75",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB checks",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.75),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.75),
        ],
      ),
    ),
    // B17 source world: 4.
    _b92MistakeDrillV1(
      id: "mistake_minimum_raise",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "Review the actions with enough chips for a full raise. BB led on the turn. Only one annotation breaks the betting rule.",
      question: "Which annotated action was illegal at the stated depth?",
      choices: const [
        (
          "short_raise",
          "Turn · announce raise to 6 BB",
          "The full raise has to add at least the opening 4 BB to the current 4 BB. Eight BB is the minimum total.",
        ),
        (
          "lead",
          "Turn · BB leads 4 BB",
          "A first turn bet of 4 BB exceeds the one-BB minimum.",
        ),
        (
          "btn_flop",
          "Flop · check back",
          "BB checked on the flop and gave BTN the option to check back.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ac Qd",
        board: "Qs 8c 4h 3d",
        street: PokerStreet.turn,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB bets 4",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.turn, "bb", Act0ContributionKindV1.wager, 4.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 4.0)},
      ),
    ),
    // B17 source world: 4.
    _b92MistakeDrillV1(
      id: "mistake_already_committed",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "The replay pauses before BTN responds to the flop raise. Both players can afford the full match. The three annotations include one claimed amount.",
      question: "Where did BTN incorrectly track the chips?",
      choices: const [
        (
          "price",
          "Flop · count another 9 BB to call",
          "Nine BB is the total wager. Your 3 BB already in reduce the call to 6 BB.",
        ),
        (
          "first_bet",
          "Flop · bet 3 BB",
          "The first wager is legal. Those chips now count toward matching a raise.",
        ),
        (
          "raise",
          "Flop · BB raises to 9 BB",
          "From a bet of 3 BB, a full raise can add 3 BB or more. Adding six is legal.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah Qh",
        board: "Qs 7c 4d",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB raises to 9",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 9.0),
        ],
        bets: const {
          "btn": (Act0SeatBetKindV1.bet, 3.0),
          "bb": (Act0SeatBetKindV1.raise, 9.0),
        },
      ),
    ),
    // B17 source world: 5.
    _b92MistakeDrillV1(
      id: "mistake_turn_straight_call",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "Replay stops before the river. Under the teaching model the legal winning rivers are the four fives and four tens. You know your cards and the turn board, no ties or later chips. BB led 4 BB on the turn.",
      question: "Which choice is the mistake in the reviewed line?",
      choices: const [
        (
          "bad_call",
          "Turn · call 4 BB",
          "Eight of 46 rivers fall below the call price. Folding saves the modeled loss.",
        ),
        (
          "check",
          "Flop · check behind",
          "The mistake being priced is on the turn. The replay makes no claim that the flop check loses chips.",
        ),
        (
          "count",
          "Turn · identify eight straight completions",
          "Both ends complete the straight. The error was using those eight winners to justify this price.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "7d 6c",
        board: "9h 8s 2c Qd",
        street: PokerStreet.turn,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB bets 4",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.turn, "bb", Act0ContributionKindV1.wager, 4.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 4.0)},
      ),
    ),
    // B17 source world: 5.
    _b92MistakeDrillV1(
      id: "mistake_turn_flush_fold",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "The study model counts all nine unseen hearts as winning rivers and the other rivers as losses. There are no ties, raises or later betting. BB leads 1 BB on the turn.",
      question: "Which annotated choice gives up positive chip EV?",
      choices: const [
        (
          "fold",
          "Turn · fold to 1 BB",
          "The nine winning hearts give enough equity for a one-BB call. Folding leaves that gain unrealized.",
        ),
        (
          "count",
          "Turn · count nine winning hearts",
          "Four hearts are visible, so the model has nine remaining winners.",
        ),
        (
          "match",
          "Turn · note an extra 1 BB is needed",
          "BB’s lead sets the price. You have added nothing on this street yet.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah 6h",
        board: "Kh 8h 3c 2d",
        street: PokerStreet.turn,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB bets 1",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.turn, "bb", Act0ContributionKindV1.wager, 1.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 1.0)},
      ),
    ),
    // B17 source world: 6.
    _b92MistakeDrillV1(
      id: "mistake_worse_calls",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "For this replay only, BB calls a 3 BB river bet with K-J or K-T and folds Q-J. Weight every legal combination equally. The earlier checks are given history.",
      question: "Where does the reviewed plan leave chips on the table?",
      choices: const [
        (
          "check",
          "River · check K-Q behind",
          "K-Q beats every modeled holding. Betting 3 BB earns extra from the weaker kings that call.",
        ),
        (
          "flop",
          "Flop · BB checks first",
          "BB acts first postflop. This is a legal check by the opponent, outside the river comparison.",
        ),
        (
          "note",
          "River · identify K-J and K-T as weaker calls",
          "Your queen beats both listed kickers after the shared pair of kings.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Kh Qd",
        board: "Ks 8c 4d 3h 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB checks",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
        ],
      ),
    ),
    // B17 source world: 6.
    _b92MistakeDrillV1(
      id: "mistake_bluff_calls",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "BB checks the river. At 3 BB and 7 BB the equally weighted teaching roster calls KcQd 8h9h 7h7c 4s5s KcJc 8hTc and folds Ah7h Qs7s Qd9d As9s. Your hand loses to every holding on a showdown. Review BTN’s proposed line.",
      question: "Which annotated river action is worse than checking?",
      choices: const [
        (
          "big",
          "River · bluff for 7 BB",
          "Four folds in ten cannot fund the seven-BB losses on six calls. The 3 BB bluff earns more.",
        ),
        (
          "price",
          "River · note the pot is 5.5 BB",
          "The pot includes both 2.5 BB preflop contributions and the dead half blind.",
        ),
        (
          "fold_list",
          "River · keep the same four folds at both sizes",
          "The supplied response gives the same fold set at both sizes.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Jh Td",
        board: "Ks 8c 4d 3h 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB checks",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
        ],
      ),
    ),
    // B17 source world: 7.
    _b92MistakeDrillV1(
      id: "mistake_known_blocker",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "The river review compares all K-Q combinations without suit restrictions. Ks is on the board and Kh is in your hand. No queen is visible. These are notes made before a choice; there is no result shown.",
      question: "Which note counts too many opponent combinations?",
      choices: const [
        (
          "count",
          "River · record twelve possible K-Q hands",
          "Twelve removes only the board king. Remove your king too and count two kings times four queens.",
        ),
        (
          "board",
          "River · exclude the king on the board",
          "Ks cannot be dealt as an opponent’s private card.",
        ),
        (
          "queen",
          "River · keep four queens available",
          "No queen is visible, so each legal king can pair with all four queens.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Kh Jd",
        board: "Ks 9c 5h 3d 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB checks",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
        ],
      ),
    ),
    // B17 source world: 8.
    _b92MistakeDrillV1(
      id: "mistake_matched_amount",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "After preflop BTN and BB each contributed 2.5 BB. On the river BB pushes its last 15 BB. BTN has 6 BB behind. The action line includes the full announced wager. The displayed pot caps the wager at the 6 BB you can match.",
      question: "Which note is wrong for this heads-up pot?",
      choices: const [
        (
          "all",
          "River · count all 15 BB as matched",
          "Only your remaining 6 BB can match BB. The 9 BB excess comes back to the opponent.",
        ),
        (
          "dead_sb",
          "Preflop · keep the folded small blind in the pot",
          "The small blind’s half BB remains as dead money after the fold.",
        ),
        (
          "effective",
          "River · use your remaining stack as the cap",
          "The smaller remaining stack is the greatest amount that both players can match.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ac Qd",
        board: "Qs 8c 4h 3d 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 8.5,
          "sb": 100,
          "bb": 17.5,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB bets 6 BB",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.river, "bb", Act0ContributionKindV1.wager, 6.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 6.0)},
        wagerDeclaration: "river: BB declares all-in 15 BB (6 BB effective)",
      ),
    ),
    // B17 source world: 8.
    _b92MistakeDrillV1(
      id: "mistake_implied_cap",
      lesson: "where_is_the_mistake",
      lessonTitle: "Where is the mistake in this hand?",
      caption:
          "Study replay: BB leads 3 BB on the turn. After a matching call, BB has 3 BB left. BTN has at least that much. The model treats nine rivers as clean and lets BB pay its whole remaining stack on each hit.",
      question: "Where does the review invent a payoff the table cannot pay?",
      choices: const [
        (
          "extra",
          "Turn · plan to collect 8 BB extra on a hit",
          "BB cannot pay more than its remaining stack.",
        ),
        (
          "call",
          "Turn · record a 3 BB call price",
          "The call matches BB’s 3 BB lead from the same street.",
        ),
        (
          "good",
          "Turn · use the nine stated winning rivers",
          "The exercise supplies nine clean hits. The disputed number is the chips those hits can collect.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah Jh",
        board: "Kh 7h 4c 2d",
        street: PokerStreet.turn,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 8.5,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN checks",
          "turn: BB bets 3",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.turn, "bb", Act0ContributionKindV1.wager, 3.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 3.0)},
      ),
    ),
  ]),
  _act0PilotLessonV1("turn_card_impact", "Which turn card changes the decision?", [
    // B17 source world: 5.
    _b92TurnDrillV1(
      id: "turn_heart_completes",
      rangeText: "KsKd KcKd 8s8d",
      reference: "2c",
      candidates: const {"bad": "4c", "good": "Qh", "unchanged": "7c"},
      mechanism:
          "The queen completes your ace-high flush. Sets retain river redraws, but the remaining showdown share rises.",
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah 6h",
        board: "Kh 8h 3c",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 7.
    _b92TurnDrillV1(
      id: "turn_heart_pairs_board",
      rangeText: "KsKd KcKd 8s8d",
      reference: "Qh",
      candidates: const {"good": "2h", "bad": "3h", "unchanged": "4h"},
      mechanism:
          "You complete a flush as the board pairs. Every modeled set makes a full house, which drops your remaining showdown share.",
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah 6h",
        board: "Kh 8h 3c",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 5.
    _b92TurnDrillV1(
      id: "turn_straight_completes",
      rangeText: "AsAd AcAs QhQc",
      reference: "2d",
      candidates: const {"bad": "3c", "good": "Td", "unchanged": "4c"},
      mechanism:
          "The ten completes your straight. More rivers now preserve the win against the listed overpairs than before the turn was known.",
      table: _b19TableV1(
        hero: "btn",
        hand: "7d 6c",
        board: "9h 8s 2c",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 5.
    _b92TurnDrillV1(
      id: "turn_overcard_beats_pair",
      rangeText: "AcKc AdKd AcTd",
      reference: "2c",
      candidates: const {"good": "4c", "bad": "Ah", "unchanged": "7c"},
      mechanism:
          "The turn pairs every ace in the range. Those aces overtake pocket queens and cut your showdown share.",
      table: _b19TableV1(
        hero: "btn",
        hand: "Qs Qd",
        board: "Jh 8s 3d",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 7.
    _b92TurnDrillV1(
      id: "turn_remove_high_draw",
      rangeText: "AhKc AhJc ThTc Ah9h",
      reference: "As",
      candidates: const {"bad": "Ac", "good": "9h", "unchanged": "Ad"},
      mechanism:
          "You make a flush, and the turn removes Ah9h. The surviving higher hearts can outdraw you, but the current lead improves your share.",
      table: _b19TableV1(
        hero: "btn",
        hand: "8h 7h",
        board: "Qh 7s 2h",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 6.
    _b92TurnDrillV1(
      id: "turn_counterfeit_two_pair",
      rangeText: "AcAd AsAh QcQd",
      reference: "2c",
      candidates: const {"good": "3c", "bad": "Kh", "unchanged": "4c"},
      mechanism:
          "The turn pairs the king. BB’s overpairs can use both board kings, overtaking your two pair from the flop.",
      table: _b19TableV1(
        hero: "btn",
        hand: "8c 6s",
        board: "8h 6d Ks",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 8.
    _b92TurnDrillV1(
      id: "turn_redraw_good",
      rangeText: "AhJh AhTh QhJh",
      reference: "2h",
      candidates: const {"bad": "3h", "good": "5s", "unchanged": "6h"},
      mechanism:
          "The paired turn makes your full house. The modeled draws cannot beat it with a flush on the river.",
      table: _b19TableV1(
        hero: "btn",
        hand: "9d 9c",
        board: "9s 5h 4h",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 6.
    _b92TurnDrillV1(
      id: "turn_board_four_to_straight",
      rangeText: "JdTd JcTh Tc5c",
      reference: "2c",
      candidates: const {"good": "3c", "bad": "7s", "unchanged": "4c"},
      mechanism:
          "The seven gives every holding in the range a straight. Bare aces lose most of their flop-average showdown share.",
      table: _b19TableV1(
        hero: "btn",
        hand: "Ad Ac",
        board: "9c 8d 6h",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 7.
    _b92TurnDrillV1(
      id: "turn_dead_draw",
      rangeText: "Js8s JsTs Js9s",
      reference: "3c",
      candidates: const {"good": "Qc", "unchanged": null, "bad": "2d"},
      mechanism:
          "Every possible opponent hand already has four jacks. Neither offered turn nor its remaining rivers can beat that in this matchup.",
      table: _b19TableV1(
        hero: "btn",
        hand: "Ac Ks",
        board: "Jd Jh Jc",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
    // B17 source world: 8.
    _b92TurnDrillV1(
      id: "turn_turn_makes_set",
      rangeText: "AhQh AsKd AcJd",
      reference: "2c",
      candidates: const {"bad": "3c", "good": "5c", "unchanged": "4c"},
      mechanism:
          "Your set overtakes every top-pair holding in this range. Every legal river keeps you ahead in the modeled matchup.",
      table: _b19TableV1(
        hero: "btn",
        hand: "5h 5s",
        board: "Ad 9c 2h",
        street: PokerStreet.flop,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 2",
          "flop: BB calls 2",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 2.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 2.0),
        ],
      ),
    ),
  ]),
  _act0PilotLessonV1("slightly_harder", "A slightly harder next step", [
    // B17 source world: 7.
    _b19DrillV1(
      id: "harder_dirty_flush",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "Assume BB holds Ks Kd. After a call, see any remaining river and go directly to showdown without more bets. Compare call and fold under this study model. Replace the top-pair holding with a set.",
      question: "Which response earns more in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. With 3 BB offered, price = 3/17.5 = 17.1%. Harder case W/T/L=7/0/37, E=7/44. Call EV = 7/44×35/2−3 = -19/88 BB, fold=0. Baseline W/T/L=12/0/32, EV(call)=3/11×35/2−3=39/22 BB, fold=0. Baseline: hand Ah 6h; board Kh 8h 3c 2d; bet in BB 3.0; opponent Kc Qs; best option call; call EV in BB 1.77273. Model EV (BB): call -0.21591, fold 0. The stated sizes fit both players’ remaining stacks. Fold. Two hearts pair the board, making kings a full house; the clean winners come up short of the price. Edge: 0.21591 BB.",
      choices: const [
        (
          "fold",
          "Fold",
          Act0FeedbackQualityV1.correct,
          "Fold. Two hearts pair the board, making kings a full house; the clean winners come up short of the price.",
        ),
        (
          "call",
          "Call 3 BB",
          Act0FeedbackQualityV1.acceptable,
          "Also playable. Fold earns slightly more. The call has a small cost in this particular ledger once the two board-pairing hearts stop winning.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah 6h",
        board: "Kh 8h 3c 2d",
        street: PokerStreet.turn,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB bets 3",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.turn, "bb", Act0ContributionKindV1.wager, 3.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 3.0)},
      ),
      isTransfer: true,
    ),
    // B17 source world: 5.
    _b19DrillV1(
      id: "harder_straight_price_rises",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "Assume BB holds Qh Qs. After a call, see any remaining river and go directly to showdown without more bets. Compare call and fold under this study model. Increase the turn lead while keeping opponent holding and prior contributions fixed.",
      question: "Which response earns more in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. With 6.5 BB offered, price = 6.5/24.5 = 26.5%. Harder case W/T/L=8/0/36, E=2/11. Call EV = 2/11×49/2−13/2 = -45/22 BB, fold=0. Baseline W/T/L=8/0/36, EV(call)=2/11×31/2−2=9/11 BB, fold=0. Baseline: hand 7d 6c; board 9h 8s 2c Qd; bet in BB 2.0; opponent Qh Qs; best option call; call EV in BB 0.81818. Model EV (BB): call -2.04545, fold 0. The stated sizes fit both players’ remaining stacks. Fold. Your eight winners stay the same while the larger bet raises the share you need. Edge: 2.04545 BB.",
      choices: const [
        (
          "fold",
          "Fold",
          Act0FeedbackQualityV1.correct,
          "Fold. Your eight winners stay the same while the larger bet raises the share you need.",
        ),
        (
          "call",
          "Call 6.5 BB",
          Act0FeedbackQualityV1.suboptimal,
          "The same eight straight cards paid for the smaller lead. At this price a call loses chips.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "7d 6c",
        board: "9h 8s 2c Qd",
        street: PokerStreet.turn,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB bets 6.5",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.turn, "bb", Act0ContributionKindV1.wager, 6.5),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 6.5)},
      ),
      isTransfer: true,
    ),
    // B17 source world: 7.
    _b19DrillV1(
      id: "harder_remove_missed_hearts",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "BB bets each legal combination of 88 44 AhJh AhTh QhJh QhTh with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model. Swap the queen’s suit to hearts.",
      question: "Which response earns more in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. With 7 BB offered, price = 7/25.5 = 27.5%. Harder case W/T/L=2/0/6, E=1/4. Call EV = 1/4×51/2−7 = -5/8 BB, fold=0. Baseline W/T/L=4/0/6, EV(call)=2/5×51/2−7=16/5 BB, fold=0. Baseline: hand Kd Qd; board Ks 8h 4h 7c 2s; bet in BB 7.0; opponent 88 44 AhJh AhTh QhJh QhTh; best option call; call EV in BB 3.2. Model EV (BB): call -0.625, fold 0. The stated sizes fit both players’ remaining stacks. Fold. Your queen removes two missed heart holdings, leaving too few bluffs to meet the price. Edge: 0.625 BB.",
      choices: const [
        (
          "fold",
          "Fold",
          Act0FeedbackQualityV1.correct,
          "Fold. Your queen removes two missed heart holdings, leaving too few bluffs to meet the price.",
        ),
        (
          "call",
          "Call 7 BB",
          Act0FeedbackQualityV1.suboptimal,
          "The price remains unchanged. Only two winning combos survive the new blocker.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Kd Qh",
        board: "Ks 8h 4h 7c 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB bets 7",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.river, "bb", Act0ContributionKindV1.wager, 7.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 7.0)},
      ),
      isTransfer: true,
    ),
    // B17 source world: 7.
    _b19DrillV1(
      id: "harder_leave_misses_unblocked",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "BB bets each legal combination of 99 55 AcKc KcJc QcJc KcTc with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model. Swap the kicker’s suit from clubs to hearts.",
      question: "Which response earns more in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. With 8 BB offered, price = 8/27.5 = 29.1%. Harder case W/T/L=3/0/7, E=3/10. Call EV = 3/10×55/2−8 = 1/4 BB, fold=0. Baseline W/T/L=1/0/7, EV(call)=1/8×55/2−8=-73/16 BB, fold=0. Baseline: hand Ad Jc; board As 9c 5c 4d 2s; bet in BB 8.0; opponent 99 55 AcKc KcJc QcJc KcTc; best option fold; call EV in BB -4.5625. Model EV (BB): call 0.25, fold 0. The stated sizes fit both players’ remaining stacks. Call. Keeping the missed club draws available increases the winning share enough to pay the price. Edge: 0.25 BB.",
      choices: const [
        (
          "call",
          "Call 8 BB",
          Act0FeedbackQualityV1.correct,
          "Call. Keeping the missed club draws available increases the winning share enough to pay the price.",
        ),
        (
          "fold",
          "Fold",
          Act0FeedbackQualityV1.acceptable,
          "Also playable. Call 8 BB earns slightly more. Folding gives up the added showdown wins from the club holdings your new kicker leaves in.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ad Jh",
        board: "As 9c 5c 4d 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB bets 8",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.river, "bb", Act0ContributionKindV1.wager, 8.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 8.0)},
      ),
      isTransfer: true,
    ),
    // B17 source world: 6.
    _b19DrillV1(
      id: "harder_river_value_added",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "BB bets each legal combination of 88 44 KJ JTs 76s with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model. Add weaker K-J bets to a formerly polarized range.",
      question: "Which response earns more in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. With 9 BB offered, price = 9/29.5 = 30.5%. Harder case W/T/L=16/0/6, E=8/11. Call EV = 8/11×59/2−9 = 137/11 BB, fold=0. Baseline W/T/L=8/0/6, EV(call)=4/7×59/2−9=55/7 BB, fold=0. Baseline: hand Ks Qd; board Kh 8d 4c 3s 2c; bet in BB 9.0; opponent 88 44 JTs 76s; best option call; call EV in BB 7.85714. Model EV (BB): call 12.45455, fold 0. The stated sizes fit both players’ remaining stacks. Call. You beat missed draws and the modeled weaker kings. Count both groups against the price. Edge: 12.45455 BB.",
      choices: const [
        (
          "call",
          "Call 9 BB",
          Act0FeedbackQualityV1.correct,
          "Call. You beat missed draws and the modeled weaker kings. Count both groups against the price.",
        ),
        (
          "fold",
          "Fold",
          Act0FeedbackQualityV1.wrong,
          "Folding treats K-Q as though it beats only the missed draws. Weaker kings also pay you here.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ks Qd",
        board: "Kh 8d 4c 3s 2c",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB bets 9",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.river, "bb", Act0ContributionKindV1.wager, 9.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 9.0)},
      ),
      isTransfer: true,
    ),
    // B17 source world: 6.
    _b19DrillV1(
      id: "harder_paired_river_boats",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "BB bets each legal combination of 99 44 Q9s JTs 76s with equal weight. After a call, go directly to showdown without more bets. Compare call and fold under this study model. Replace the river-bluff-catch board’s turn three with a second nine.",
      question: "Which response earns more in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. With 10 BB offered, price = 10/31.5 = 31.7%. Harder case W/T/L=8/0/5, E=8/13. Call EV = 8/13×63/2−10 = 122/13 BB, fold=0. Baseline W/T/L=8/0/7, EV(call)=8/15×63/2−10=34/5 BB, fold=0. Baseline: hand As Qd; board Qs 9h 4c 3d 2h; bet in BB 10.0; opponent 99 44 Q9s JTs 76s; best option call; call EV in BB 6.8. Model EV (BB): call 9.38462, fold 0. The stated sizes fit both players’ remaining stacks. Call. The paired board changes the value group, but there are still enough misses in the legal betting range. Edge: 9.38462 BB.",
      choices: const [
        (
          "call",
          "Call 10 BB",
          Act0FeedbackQualityV1.correct,
          "Call. The paired board changes the value group, but there are still enough misses in the legal betting range.",
        ),
        (
          "fold",
          "Fold",
          Act0FeedbackQualityV1.wrong,
          "The board permits strong boats. Their existence by itself does not establish the required share of losses.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "As Qd",
        board: "Qs 9h 4c 9d 2h",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB bets 10",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.river, "bb", Act0ContributionKindV1.wager, 10.0),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 10.0)},
      ),
      isTransfer: true,
    ),
    // B17 source world: 4.
    _b19DrillV1(
      id: "harder_worse_calls_larger",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "BB has one equally weighted legal combination from KQ QJ QT 99 55 JTs. Checking goes to showdown. At 4 BB BB calls KQ QJ QT 99 55 and folds the rest.  At 10 BB BB calls KQ 99 55 and folds the rest. Remove a folding miss from the range. The paid groups stay fixed, so count how the denominator changes. Compare the listed response groups at each offered size.",
      question: "Which action earns the most chips in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. Check EV = P × 14/17 = 161/17 BB. At 4 BB, EV = (4/34)P + (30/34)[4/5 × (P+2B) − B] = 197/17 BB. At 10 BB, EV = (20/34)P + (14/34)[4/7 × (P+2B) − B] = 171/17 BB. Baseline: P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. Check EV = P × 16/19 = 184/19 BB. At 4 BB, EV = (8/38)P + (30/38)[4/5 × (P+2B) − B] = 220/19 BB. At 10 BB, EV = (24/38)P + (14/38)[4/7 × (P+2B) − B] = 194/19 BB. Baseline: hand As Qd; board Qs 9c 5d 4h 2s; opponent KQ, QJ, QT, 99, 55, JTs, 87s; best option bet_4. Model EV (BB): check 9.47059, bet_4 11.58824, bet_10 10.05882. The stated sizes fit both players’ remaining stacks. Bet 4 BB. The small size retains Q-J and Q-T, while stronger sets pay both sizes. Edge: 1.52942 BB.",
      choices: const [
        (
          "bet_4",
          "Bet 4 BB",
          Act0FeedbackQualityV1.correct,
          "Bet 4 BB. The small size retains Q-J and Q-T, while stronger sets pay both sizes.",
        ),
        (
          "bet_10",
          "Bet 10 BB",
          Act0FeedbackQualityV1.suboptimal,
          "The larger wager loses two groups of worse callers and keeps both stronger sets.",
        ),
        (
          "check",
          "Check",
          Act0FeedbackQualityV1.suboptimal,
          "Checking reaches showdown but leaves extra chips from worse queens uncollected.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "As Qd",
        board: "Qs 9c 5d 4h 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB checks",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
        ],
      ),
      isTransfer: true,
    ),
    // B17 source world: 6.
    _b19DrillV1(
      id: "harder_overbet_passes_value",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "BB has one equally weighted legal combination from JhTh Th8h 8h6h 99 KK KQ. Checking goes to showdown. At 5 BB BB calls JhTh Th8h 8h6h 99 KK KQ and folds the rest.  At 15 BB BB calls JhTh Th8h 8h6h 99 KK and folds the rest. Remove the weaker K-J group, which paid only at the smaller size. Recount the extra calls at that size. Compare the listed response groups at each offered size.",
      question: "Which action earns the most chips in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. Check EV = P × 1 = 23/2 BB. At 5 BB, EV = (0/18)P + (18/18)[1 × (P+2B) − B] = 33/2 BB. At 15 BB, EV = (9/18)P + (9/18)[1 × (P+2B) − B] = 19 BB. Baseline: P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. Check EV = P × 1 = 23/2 BB. At 5 BB, EV = (0/30)P + (30/30)[1 × (P+2B) − B] = 33/2 BB. At 15 BB, EV = (21/30)P + (9/30)[1 × (P+2B) − B] = 16 BB. Baseline: hand Ah Qh; board Kh 9h 4h 7c 2s; opponent JhTh, Th8h, 8h6h, 99, KK, KQ, KJ; best option bet_5. Model EV (BB): check 11.5, bet_5 16.5, bet_15 19.0. The stated sizes fit both players’ remaining stacks. Bet 15 BB. Enough flushes and sets pay the overbet to beat the smaller wager that also gets K-Q. Edge: 2.5 BB.",
      choices: const [
        (
          "bet_15",
          "Bet 15 BB",
          Act0FeedbackQualityV1.correct,
          "Bet 15 BB. Enough flushes and sets pay the overbet to beat the smaller wager that also gets K-Q.",
        ),
        (
          "bet_5",
          "Bet 5 BB",
          Act0FeedbackQualityV1.suboptimal,
          "The smaller size keeps K-Q, but the extra calls do not make up for the larger payment from flushes and sets.",
        ),
        (
          "check",
          "Check",
          Act0FeedbackQualityV1.wrong,
          "Checking wins at showdown but collects nothing from paid weaker made hands.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah Qh",
        board: "Kh 9h 4h 7c 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB checks",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
        ],
      ),
      isTransfer: true,
    ),
    // B17 source world: 7.
    _b19DrillV1(
      id: "harder_block_weaker_flushes",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "BB has one equally weighted legal combination from QhJh JhTh Th8h 8h6h 99 44 KQ KJ. Checking goes to showdown. At 5 BB BB calls QhJh JhTh Th8h 8h6h 99 44 KQ KJ and folds the rest.  At 18 BB BB calls QhJh JhTh Th8h 8h6h 99 44 and folds the rest. Replace Qh with Th. Both hero hands retain the nut flush, but the legal worse flushes and kings that pay change. Compare the listed response groups at each offered size.",
      question: "Which action earns the most chips in this model?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. Check EV = P × 1 = 23/2 BB. At 5 BB, EV = (0/32)P + (32/32)[1 × (P+2B) − B] = 33/2 BB. At 18 BB, EV = (24/32)P + (8/32)[1 × (P+2B) − B] = 16 BB. Baseline: P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. Check EV = P × 1 = 23/2 BB. At 5 BB, EV = (0/30)P + (30/30)[1 × (P+2B) − B] = 33/2 BB. At 18 BB, EV = (21/30)P + (9/30)[1 × (P+2B) − B] = 169/10 BB. Baseline: hand Ah Qh; board Kh 9h 4h 7c 2s; opponent QhJh, JhTh, Th8h, 8h6h, 99, 44, KQ, KJ; best option bet_18. Model EV (BB): check 11.5, bet_5 16.5, bet_18 16.0. The stated sizes fit both players’ remaining stacks. Bet 5 BB. Your ten blocks two of the flush calls, and the king calls at the small price make up the difference. Edge: 0.5 BB.",
      choices: const [
        (
          "bet_5",
          "Bet 5 BB",
          Act0FeedbackQualityV1.correct,
          "Bet 5 BB. Your ten blocks two of the flush calls, and the king calls at the small price make up the difference.",
        ),
        (
          "bet_18",
          "Bet 18 BB",
          Act0FeedbackQualityV1.acceptable,
          "Also playable. Bet 5 BB earns slightly more. The larger price loses all king calls. The remaining sets and flushes are too few to fund that size.",
        ),
        (
          "check",
          "Check",
          Act0FeedbackQualityV1.suboptimal,
          "Checking wins the original pot but gives up payment from weaker made hands.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah Th",
        board: "Kh 9h 4h 7c 2s",
        street: PokerStreet.river,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 100,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB checks",
          "turn: BTN checks",
          "river: BB checks",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
        ],
      ),
      isTransfer: true,
    ),
    // B17 source world: 8.
    _b19DrillV1(
      id: "harder_shorter_implied_payment",
      lesson: "slightly_harder",
      lessonTitle: "A slightly harder next step",
      caption:
          "Assume BB holds Ks Kd and starts with 13 BB. If you call and an unpaired heart comes, BB checks and pays a river bet up to 12 BB, capped by its stack. Other rivers check through. Compare call and fold. Reduce only BB’s starting stack from 22 BB to 13 BB. BB holds Ks Kd in this teaching replay. The set pays only on clean hearts and is capped by the remaining effective stack.",
      question: "Which option earns more under the short stack’s payoff cap?",
      explanation:
          "P = 5.5 (BTN) + 0.5 (SB) + 5.5 (BB) = 11.5 BB. With 4.5 BB offered, price = 4.5/20.5 = 22.0%. Enumerate 44 rivers after removing both hands. W/T/L=7/0/37. Remaining after the matched turn=13−5.5−4.5=3. EV(call)=7/44×(20.5+3)−4.5=-67/88; fold=0. Baseline remaining=22−5.5−4.5=12, EV(call)=59/88. Baseline: BB starting stack in BB 22; river payoff cap in BB 12; best option call; call EV in BB 0.67045. Model EV (BB): call -0.76136, fold 0. At 22 BB the opponent can pay 12 extra BB and the call is best; at 13 BB it can pay only 3. Fold. The short stack can pay only 3 BB more on a win, which does not make the draw worth its current price. Edge: 0.76136 BB.",
      choices: const [
        (
          "fold",
          "Fold",
          Act0FeedbackQualityV1.correct,
          "Fold. The short stack can pay only 3 BB more on a win, which does not make the draw worth its current price.",
        ),
        (
          "call",
          "Call 4.5 BB",
          Act0FeedbackQualityV1.suboptimal,
          "The extra river payoff is limited by BB’s stack. Counting the deeper example’s 12 BB would overstate this call’s return.",
        ),
      ],
      table: _b19TableV1(
        hero: "btn",
        hand: "Ah 6h",
        board: "Kh 8h 3c 2d",
        street: PokerStreet.turn,
        stacks: const {
          "utg": 100,
          "hj": 100,
          "co": 100,
          "btn": 100,
          "sb": 100,
          "bb": 13,
        },
        folded: const {"utg", "hj", "co", "sb"},
        history: const [
          "preflop: SB posts 0.5",
          "preflop: BB posts 1",
          "preflop: UTG folds",
          "preflop: HJ folds",
          "preflop: CO folds",
          "preflop: BTN raises to 2.5",
          "preflop: SB folds",
          "preflop: BB calls 1.5",
          "flop: BB checks",
          "flop: BTN bets 3",
          "flop: BB calls 3",
          "turn: BB bets 4.5",
        ],
        entries: const [
          (PokerStreet.preflop, "sb", Act0ContributionKindV1.blind, 0.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.blind, 1.0),
          (PokerStreet.preflop, "btn", Act0ContributionKindV1.wager, 2.5),
          (PokerStreet.preflop, "bb", Act0ContributionKindV1.wager, 1.5),
          (PokerStreet.flop, "btn", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.flop, "bb", Act0ContributionKindV1.wager, 3.0),
          (PokerStreet.turn, "bb", Act0ContributionKindV1.wager, 4.5),
        ],
        bets: const {"bb": (Act0SeatBetKindV1.bet, 4.5)},
      ),
      isTransfer: true,
    ),
  ]),
];

Act0LessonTaskV1 _b19DrillV1({
  required String id,
  required String lesson,
  required String lessonTitle,
  required String caption,
  required String question,
  required String explanation,
  required List<(String, String, Act0FeedbackQualityV1, String)> choices,
  required Act0TableStateV1 table,
  bool isTransfer = false,
}) => _wave6AuthoredTaskV1(
  id: id,
  lesson: lesson,
  lessonTitle: lessonTitle,
  title: question,
  phase: Act0LessonPhaseV1.drill,
  step: Act0LessonStepKindV1.practice,
  xp: 10,
  caption: caption,
  question: question,
  teach: '',
  choices: [
    for (final (id, label, grade, feedback) in choices)
      (
        id,
        label,
        grade,
        isTransfer && grade == Act0FeedbackQualityV1.correct
            ? '$feedback\n\n$explanation'
            : feedback,
      ),
  ],
  table: table,
  family: isTransfer ? Act0TaskFamilyV1.transfer : null,
  explanation: explanation,
);

Act0TableStateV1 _b19TableV1({
  required String hero,
  required String hand,
  required String board,
  required PokerStreet street,
  required Map<String, double> stacks,
  required Set<String> folded,
  required List<String> history,
  required List<(PokerStreet, String, Act0ContributionKindV1, double)> entries,
  Map<String, (Act0SeatBetKindV1, double)> bets = const {},
  bool highlightTurn = false,
  String? wagerDeclaration,
}) =>
    _day7TableV1(
      hero: hero,
      actor: hero,
      hand: hand,
      board: _act0LessonCardsV1(board),
      street: street,
      stacks: stacks,
      folded: folded,
      entries: [
        for (final (street, seat, kind, bb) in entries)
          Act0ContributionV1(street, seat, kind, bb),
      ],
      history: [
        for (final action in history) Act0ActionTrailItemV1(label: action),
        if (wagerDeclaration != null)
          Act0ActionTrailItemV1.note(
            label: 'Declared wager',
            displayLabel: wagerDeclaration,
          ),
      ],
      bets: {
        for (final MapEntry(key: seat, value: (kind, bb)) in bets.entries)
          seat: Act0SeatBetStateV1(
            kind: kind,
            label: kind.name,
            amountLabel: _act0BbLabelV1(bb),
          ),
      },
    ).copyWith(
      showDecisionPremise: true,
      highlightedCardIds: highlightTurn ? const ['board_3'] : const [],
    );

Act0LessonTaskV1 _b92TurnDrillV1({
  required String id,
  required String rangeText,
  required String reference,
  required Map<String, String?> candidates,
  required String mechanism,
  required Act0TableStateV1 table,
}) {
  final range = rangeText
      .split(' ')
      .map((combo) => [combo.substring(0, 2), combo.substring(2)])
      .toList();
  final price = act0B92TurnPriceV1(
    table.handContributions!,
    seats: table.seats.map((seat) => seat.seatId).toSet(),
    hero: table.heroSeat.seatId,
    opponent: 'bb',
  );
  final result = act0B92TurnChoicesV1(
    hero: table.heroCards.map((card) => card.label).toList(),
    flop: table.boardCards.map((card) => card.label).toList(),
    range: range,
    reference: reference,
    candidates: candidates,
    price: price.price,
  );
  final correctId = result.changingIds.single;
  String pct(double value) => '${(100 * value).toStringAsFixed(1)}%';
  String play(double share) => share > price.price ? 'Call' : 'Fold';
  final correctCard = candidates[correctId];
  final reason =
      '${correctCard == null ? 'None of these cards: $mechanism' : 'If $correctCard turns: $mechanism'} '
      'If $reference turns, you have ${pct(result.referenceShare)} showdown share '
      '(${play(result.referenceShare)}). '
      '${correctCard == null ? 'Neither offered card changes that decision.' : 'If $correctCard turns, you have ${pct(result.shares[correctId]!)} (${play(result.shares[correctId]!)}).'} '
      'The call needs ${pct(price.price)}.';
  // Rotate the existing choice identities so there is no position giveaway.
  final rows = candidates.entries.toList();
  final offset =
      id.codeUnits.fold<int>(0, (sum, code) => sum + code) % rows.length;
  return _b19DrillV1(
    id: id,
    lesson: 'turn_card_impact',
    lessonTitle: 'Which turn card changes the decision?',
    caption:
        'Imagine BB could hold $rangeText, with equal weight per legal '
        'combination. Imagine BB bets ${_act0BbLabelV1(price.bet)} on the turn '
        'into the ${_act0BbLabelV1(price.pot - price.due)} pot. '
        'If you call, go straight to showdown after the river; ties earn half. '
        'Compare each offered turn with a $reference turn. Choose call only '
        'when it earns more than folding.',
    question: switch (id) {
      'turn_heart_completes' => 'Which turn lets you call instead of folding?',
      'turn_heart_pairs_board' =>
        'Which turn makes folding better than calling?',
      'turn_straight_completes' => 'Which new card makes the call profitable?',
      'turn_overcard_beats_pair' =>
        'Which turn forces you to fold at this price?',
      'turn_remove_high_draw' =>
        'Which alternative turn changes a fold into a call?',
      'turn_counterfeit_two_pair' =>
        'Which card makes a once-profitable call lose chips?',
      'turn_redraw_good' =>
        'Which turn gives you enough showdown share to call?',
      'turn_board_four_to_straight' =>
        'Which card leaves too little showdown share to call?',
      'turn_dead_draw' => 'Can either offered turn make a call profitable?',
      'turn_turn_makes_set' => 'Which card changes the correct play to a call?',
      _ => throw ArgumentError.value(id),
    },
    explanation: reason,
    choices: [
      for (var i = 0; i < rows.length; i++)
        (() {
          final entry = rows[(i + offset) % rows.length];
          final card = entry.value;
          final correct = entry.key == correctId;
          return (
            entry.key,
            card ?? 'None of these',
            correct
                ? Act0FeedbackQualityV1.correct
                : Act0FeedbackQualityV1.wrong,
            correct
                ? reason
                : '${card == null ? 'One card does change the decision.' : 'If $card turns, you have ${pct(result.shares[entry.key]!)} (${play(result.shares[entry.key]!)}), the same decision as $reference.'} $reason',
          );
        })(),
    ],
    table: table,
  );
}

/// The reviewed annotations are separate from the actual, legal C1 replay.
/// Compare each assertion against the ledger/model, not its authored grade.
({Map<String, bool> mistakes, String correction}) act0B92MistakeTruthV1(
  String id,
  Act0TableStateV1 table,
) {
  final ledger = table.handContributions!;
  final hero = table.heroSeat.seatId;
  final amounts = ledger.amounts(
    seatIds: table.seats.map((seat) => seat.seatId).toSet(),
    actorSeatId: hero,
  );
  final due = amounts.toCallBb!;
  double contributed(String seat, [PokerStreet? street]) => ledger.entries
      .where((e) => e.seatId == seat && (street == null || e.street == street))
      .fold(0.0, (sum, e) => sum + e.netAmountBb);
  double behind(String seat) =>
      ledger.startingStackBbBySeat[seat]! - contributed(seat);
  double blind(String seat) => ledger.entries
      .singleWhere(
        (e) => e.seatId == seat && e.kind == Act0ContributionKindV1.blind,
      )
      .amountBb;
  double firstWager(PokerStreet street, String seat) => ledger.entries
      .firstWhere(
        (e) =>
            e.street == street &&
            e.seatId == seat &&
            e.kind == Act0ContributionKindV1.wager,
      )
      .amountBb;
  bool hasAction(String action) =>
      table.actionTrail.any((e) => e.label == action);
  final visible = [
    ...table.heroCards,
    ...table.boardCards,
  ].map((c) => c.label).toSet();
  final unseen = act0B19DeckV1.where((c) => !visible.contains(c)).toList();
  int countRank(String rank) => unseen.where((c) => c.startsWith(rank)).length;
  int countHearts() => unseen.where((c) => c.endsWith('h')).length;
  String bb(num n) => _act0BbLabelV1(n);
  String pct(double n) => '${(n * 100).toStringAsFixed(1)}%';
  double equity(int outs) => act0OneCardOutsV1(outs, unseen.length)!;
  double price() => act0CallPriceV1(amounts.potBb, due)!.equity;
  switch (id) {
    case 'mistake_half_pot':
      final half = amounts.potBb / 2;
      return (
        mistakes: {
          'river_bet': 2 != half,
          'open': contributed(hero, PokerStreet.preflop) != 2.75,
          'bb_call':
              contributed('bb', PokerStreet.preflop) - blind('bb') != 1.75,
        },
        correction:
            'Bet ${bb(half)}, half of the ${bb(amounts.potBb)} river pot, instead.',
      );
    case 'mistake_minimum_raise':
      final lead = firstWager(PokerStreet.turn, 'bb');
      return (
        mistakes: {
          'short_raise': 6 < 2 * lead,
          'lead': lead != 4 || lead < blind('bb'),
          'btn_flop':
              !hasAction('flop: BB checks') || !hasAction('flop: BTN checks'),
        },
        correction:
            'Raise to at least ${bb(2 * lead)}: match the ${bb(lead)} lead and add at least that much again.',
      );
    case 'mistake_already_committed':
      final first = firstWager(PokerStreet.flop, hero);
      final raised = contributed('bb', PokerStreet.flop);
      return (
        mistakes: {
          'price': 9 != due,
          'first_bet': first != 3 || first < blind('bb'),
          'raise': raised != 9 || raised < 2 * first,
        },
        correction:
            'Count ${bb(due)} more to call, subtracting your ${bb(first)} from the ${bb(raised)} raise total.',
      );
    case 'mistake_turn_straight_call':
      final outs = countRank('5') + countRank('T');
      return (
        mistakes: {
          'bad_call': due != 4 || equity(outs) < price(),
          'check':
              !hasAction('flop: BB checks') || !hasAction('flop: BTN checks'),
          'count': outs != 8,
        },
        correction:
            'Fold: $outs winning rivers out of ${unseen.length} give ${pct(equity(outs))}, below the ${pct(price())} required to call ${bb(due)}.',
      );
    case 'mistake_turn_flush_fold':
      final outs = countHearts();
      return (
        mistakes: {
          'fold': due != 1 || equity(outs) > price(),
          'count': outs != 9,
          'match': due != 1,
        },
        correction:
            'Call ${bb(due)}: $outs of ${unseen.length} rivers win (${pct(equity(outs))}), above the ${pct(price())} price.',
      );
    case 'mistake_worse_calls':
      final calling = countRank('K') * (countRank('J') + countRank('T'));
      final folding = countRank('Q') * countRank('J');
      final gain = 3 * calling / (calling + folding);
      final board = table.boardCards.map((c) => c.label).toList();
      final held = solver.Hand.solveHand([
        ...board,
        ...table.heroCards.map((c) => c.label),
      ]);
      bool beats(String a, String b) {
        final opponent = solver.Hand.solveHand([...board, a, b]);
        final winners = solver.Hand.winners([held, opponent]);
        return winners.length == 1 && winners.single == held;
      }
      final weaker = [
        for (final king in unseen.where((c) => c.startsWith('K')))
          for (final kicker in unseen.where(
            (c) => c.startsWith('J') || c.startsWith('T'),
          ))
            beats(king, kicker),
        for (final queen in unseen.where((c) => c.startsWith('Q')))
          for (final jack in unseen.where((c) => c.startsWith('J')))
            beats(queen, jack),
      ].every((wins) => wins);
      return (
        mistakes: {
          'check': weaker && gain > 0 && behind(hero) >= 3 && behind('bb') >= 3,
          'flop': !hasAction('flop: BB checks'),
          'note': !weaker,
        },
        correction:
            'Bet 3 BB: the $calling weaker king combinations call and the $folding queen-jack combinations fold. Checking gives up ${gain.toStringAsFixed(2)} BB on average.',
      );
    case 'mistake_bluff_calls':
      // The supplied response roster is identical at both sizes.
      const foldRoster = ['Ah7h', 'Qs7s', 'Qd9d', 'As9s'];
      const callRoster = ['KcQd', '8h9h', '7h7c', '4s5s', 'KcJc', '8hTc'];
      bool legalCombo(String combo) =>
          unseen.contains(combo.substring(0, 2)) &&
          unseen.contains(combo.substring(2));
      final folds = foldRoster.where(legalCombo).length;
      final calls = callRoster.where(legalCombo).length;
      if (folds != foldRoster.length || calls != callRoster.length) {
        throw StateError('Study response contains a blocked holding');
      }
      final small = (folds * amounts.potBb - calls * 3) / (folds + calls);
      final large = (folds * amounts.potBb - calls * 7) / (folds + calls);
      return (
        mistakes: {
          'big': large < 0 && small > large,
          'price': amounts.potBb != 5.5,
          'fold_list': folds != 4,
        },
        correction:
            'Bluff for 3 BB instead: it earns ${small.toStringAsFixed(2)} BB, while 7 BB earns ${large.toStringAsFixed(2)} BB against the same response range.',
      );
    case 'mistake_known_blocker':
      final kings = countRank('K'), queens = countRank('Q');
      return (
        mistakes: {
          'count': kings * queens != 12,
          'board': !table.boardCards.any((c) => c.rank == 'K'),
          'queen': queens != 4,
        },
        correction:
            'Count ${kings * queens} possible K-Q hands: $kings unseen kings times $queens unseen queens. Remove both the board king and your private king.',
      );
    case 'mistake_matched_amount':
      final announced =
          ledger.startingStackBbBySeat['bb']! -
          contributed('bb', PokerStreet.preflop);
      return (
        mistakes: {
          'all': announced != due,
          'dead_sb': contributed('sb') != blind('sb'),
          'effective': behind(hero) != due,
        },
        correction:
            'Count ${bb(due)} as matched, not ${bb(announced)}. The unmatched ${bb(announced - due)} returns to BB.',
      );
    case 'mistake_implied_cap':
      final cap = math.min(behind('bb'), behind(hero) - due);
      return (
        mistakes: {
          'extra': 8 > cap,
          'call': due != 3,
          'good': countHearts() != 9,
        },
        correction:
            'Cap the extra river payment at ${bb(cap)}: neither player can pay more than the smaller stack left after the call.',
      );
    default:
      throw ArgumentError.value(id, 'id', 'Unknown B19 mistake');
  }
}

Act0LessonTaskV1 _b92MistakeDrillV1({
  required String id,
  required String lesson,
  required String lessonTitle,
  required String caption,
  required String question,
  required List<(String, String, String)> choices,
  required Act0TableStateV1 table,
}) {
  final truth = act0B92MistakeTruthV1(id, table);
  final wrongId = truth.mistakes.entries
      .where((entry) => entry.value)
      .single
      .key;
  final wrongLabel = choices.singleWhere((row) => row.$1 == wrongId).$2;
  final correction = 'Mistake: $wrongLabel. ${truth.correction}';
  final offset =
      id.codeUnits.fold<int>(0, (sum, code) => sum + code) % choices.length;
  final ordered = [...choices.skip(offset), ...choices.take(offset)];
  return _b19DrillV1(
    id: id,
    lesson: lesson,
    lessonTitle: lessonTitle,
    caption: caption,
    question: question,
    explanation: correction,
    choices: [
      for (final (id, label, feedback) in ordered)
        (
          id,
          label,
          truth.mistakes[id]!
              ? Act0FeedbackQualityV1.correct
              : Act0FeedbackQualityV1.wrong,
          id == wrongId ? correction : '$feedback $correction',
        ),
    ],
    table: table,
  );
}
