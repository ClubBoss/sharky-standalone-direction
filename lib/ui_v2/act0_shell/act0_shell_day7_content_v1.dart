part of 'act0_shell_state_v1.dart';

final _act0Day7ReviewTasksV1 = <_SpacedReviewEntryV1>[
  _day7ExampleV1(
    1,
    "what_poker_is",
    "hero_button",
    _day7PreflopV1("co", "Kh 6d"),
    question: "Which two cards are private to you in this hand?",
    choices: const ["Kh and 6d", "Every card you can see", "Only the king"],
    correct: 0,
    reason:
        "Kh and 6d sit by your seat. Your two private cards cannot be used by another player.",
  ),
  _day7ExampleV1(
    1,
    "what_poker_is",
    "hero_cards_board_pot",
    _day7PostflopV1("bb", "Ac 8d", "Ks 6h 2c", openBb: 3.25),
    question: "Which reading matches this table?",
    choices: const [
      "Two private cards, four on the board, 7 BB in the pot",
      "Two private cards, three on the board, 7 BB in the pot",
      "Three private cards, two on the board, 7 BB in the pot",
    ],
    correct: 1,
    reason:
        "You have Ac and 8d. The board has three cards and the middle shows a 7 BB pot.",
  ),
  _day7ExampleV1(
    1,
    "what_poker_is",
    "pot_to_call",
    _day7PostflopV1("co", "Jh 8c", "Qd 7h 4s 2d", betBb: 2),
    question:
        "You missed the decision in this hand and left the lesson. Where can you work on that error?",
    choices: const ["You", "Learn", "Review"],
    correct: 2,
    reason:
        "Review brings back mistakes for another attempt. Learn is the course path and You holds your progress.",
  ),
  _day7ExampleV1(
    1,
    "what_poker_is",
    "board_cards",
    _day7PostflopV1("bb", "Td 8d", "Js 5c 3h Kc"),
    question: "Could your opponent use the king to make a hand?",
    choices: const [
      "Yes, it is on the shared board",
      "No, only you can use it",
      "Yes, but only if you fold",
    ],
    correct: 0,
    reason:
        "Kc is in the middle with the board. Both players still in the hand can use it.",
  ),
  _day7ExampleV1(
    1,
    "cards_ranks_suits",
    "confused_card_rank_suit",
    _day7PreflopV1("hj", "Jd 9d"),
    question: "What do your two cards have in common?",
    choices: const [
      "They share a rank",
      "They share a suit",
      "They share a rank and a suit",
    ],
    correct: 1,
    reason: "The ranks are jack and nine. The d on both cards means diamonds.",
  ),
  _day7ExampleV1(
    1,
    "cards_ranks_suits",
    "hero_cards_board_pot",
    _day7PostflopV1("co", "Tc 8s", "Jh 9s 7c 2d 3h"),
    question:
        "Which two cards can you combine with the board that BB cannot use?",
    choices: const ["Jh and 9s", "2d and 3h", "Tc and 8s"],
    correct: 2,
    reason:
        "Tc and 8s are beside your seat. The other listed cards are shared in the middle.",
  ),
  _day7ExampleV1(
    1,
    "hand_rankings_table",
    "hero_cards_board_pot",
    _day7PostflopV1("bb", "7s 7d", "Qh 7c 2s"),
    question: "How many sevens are in your made hand?",
    choices: const ["Three", "Two", "Four"],
    correct: 0,
    reason:
        "Both private cards are sevens, and 7c on the board makes three of a kind.",
  ),
  _day7ExampleV1(
    1,
    "hand_rankings_upper",
    "hero_cards_board_pot",
    _day7PostflopV1("co", "9h 8h", "Th 7h 6h 2s Kd"),
    question: "What is your strongest hand on this board?",
    choices: const [
      "Flush without a straight",
      "Straight flush",
      "Ordinary straight",
    ],
    correct: 1,
    reason:
        "6h through Th are five consecutive hearts. They make a straight and a flush with the same cards.",
  ),
  _day7ExampleV1(
    1,
    "hand_rankings_upper",
    "board_cards",
    _day7PostflopV1("bb", "As 5s", "Js 8s 3d 9s 2c"),
    question: "Which best-five category can you make?",
    choices: const ["Straight", "High card", "Flush"],
    correct: 2,
    reason:
        "As, Js, 9s, 8s and 5s are all spades. They do not form five consecutive ranks.",
  ),
  _day7ExampleV1(
    1,
    "blinds_action_order",
    "hero_button",
    _day7PreflopV1("hj", "9s 7s"),
    question:
        "Which seat would post the small blind immediately after the current Button?",
    choices: const ["SB", "CO", "HJ"],
    correct: 0,
    reason:
        "The small blind sits immediately clockwise from the Button. It posts half a big blind before action.",
  ),
  _day7ExampleV1(
    1,
    "blinds_action_order",
    "utg",
    _day7PreflopV1("utg", "Ah Jd"),
    question:
        "All six seats are in, and nobody has acted. Which seat has the first preflop decision?",
    choices: const ["BB", "UTG", "SB"],
    correct: 1,
    reason:
        "Preflop action starts immediately after BB on this six-player table. UTG is next after BB.",
  ),
  _day7ExampleV1(
    1,
    "blinds_action_order",
    "cutoff",
    _day7PreflopV1("co", "Qc 6h"),
    question:
        "Which seat is immediately before the dealer in the six-seat order?",
    choices: const ["HJ", "SB", "CO"],
    correct: 2,
    reason: "The order around this part of the table is HJ, CO, BTN, then SB.",
  ),
  _day7ExampleV1(
    1,
    "blinds_action_order",
    "big_blind",
    _day7PreflopV1("co", "Ts 6s"),
    question:
        "One seat posted a full big blind before anyone acted. Which seat was it?",
    choices: const ["BB", "SB", "BTN"],
    correct: 0,
    reason:
        "BB posted 1 BB. SB posted the smaller forced bet of 0.5 BB, and BTN did not post.",
  ),
  _day7ExampleV1(
    1,
    "blinds_action_order",
    "button",
    _day7PostflopV1("bb", "Js 9h", "8s 6c 2h 4s", opponent: "btn"),
    question:
        "Two players remain. Which one can wait for the other player's first decision on this turn?",
    choices: const ["BB", "BTN", "Whoever opened preflop"],
    correct: 1,
    reason:
        "BB acts first after the flop. BTN gets to see that decision before acting.",
  ),
  _day7ExampleV1(
    1,
    "positions",
    "button",
    _day7PostflopV1("bb", "Ad 7c", "As Th 5d", opponent: "btn"),
    question: "On this flop, who gets to react after the other player acts?",
    choices: const ["Whoever has the bigger stack", "BB", "BTN"],
    correct: 2,
    reason: "BB acts before BTN after the flop, regardless of stack size.",
  ),
  _day7ExampleV1(
    1,
    "positions",
    "utg",
    _day7PreflopV1("utg", "8c 3d"),
    question: "Who faces more players yet to act on the first preflop pass?",
    choices: const ["UTG", "BTN", "They face the same number"],
    correct: 0,
    reason:
        "Five players follow UTG on the first pass. Only the two blinds follow BTN.",
  ),
  _day7ExampleV1(
    1,
    "fold_check_call_raise",
    "pot_to_call",
    _day7PostflopV1("bb", "Qh 7d", "Ts 6c 3d Ah", betBb: 2, showTurn: true),
    question:
        "HJ has bet. Which action matches the wager and keeps your hand in?",
    choices: const ["Check", "Call", "Fold"],
    correct: 1,
    reason:
        "Calling pays the outstanding bet. A check cannot match it, and folding ends your participation.",
  ),
  _day7ExampleV1(
    1,
    "fold_check_call_raise",
    "hero_button",
    _day7PreflopV1("hj", "Ac Kd", opener: "utg", openBb: 3, showTurn: true),
    question: "UTG raised. Which action would set a higher wager than UTG's?",
    choices: const ["Call", "Fold", "Raise"],
    correct: 2,
    reason:
        "A raise increases the live wager. A call matches the current price and a fold gives up the hand.",
  ),
  _day7ExampleV1(
    1,
    "your_first_hand",
    "hero_cards",
    _day7PostflopV1("bb", "Ad Td", "Kc 8h 4s"),
    question: "Which two cards are beside your own seat?",
    choices: const ["Ad and Td", "Kc and 8h", "Td and 4s"],
    correct: 0,
    reason:
        "Ad and Td are your private cards. Kc, 8h and 4s belong to the board.",
  ),
  _day7ExampleV1(
    1,
    "your_first_hand",
    "hero_cards_board_pot",
    _day7PostflopV1("co", "Jc Ts", "Qh Td 3c 7s"),
    question: "What changed when the latest shared card appeared?",
    choices: const [
      "The flop went straight to the river",
      "The board went from three cards to four",
      "A third private card appeared",
    ],
    correct: 1,
    reason:
        "The first three shared cards are the flop. The fourth shared card, 7s, is the turn.",
  ),
  _day7ExampleV1(
    1,
    "your_first_hand",
    "board_cards",
    _day7PostflopV1("bb", "Ah Jc", "Ac Ts 6h 4d 2s", shownHand: "Ad 9d"),
    question: "Both players have a pair of aces. Who wins this pot?",
    choices: const ["HJ with a nine", "They tie", "You with a jack"],
    correct: 2,
    reason:
        "Your jack is the highest side card after the paired aces. HJ uses the shared ten next.",
  ),
  _day7ExampleV1(
    1,
    "what_poker_is_content",
    "confused_chip_commitment_eligibility",
    _day7PreflopV1(
      "co",
      "Ad Qd",
      opener: "hj",
      openBb: 17,
      heroStartingBb: 9,
      allIn: true,
      showTurn: true,
    ),
    question:
        "If you call and everyone else folds, how much of HJ's wager is returned?",
    choices: const ["8 BB", "17 BB", "9 BB"],
    correct: 0,
    reason:
        "You can match only the 9 BB in your stack. The unmatched 8 BB from HJ is returned.",
  ),
  _day7ExampleV1(
    1,
    "what_poker_is_content",
    "misread_poker_win_condition",
    _day7PostflopV1("co", "Ts 8s", "Kh 7d 3c Js", checkedToHero: true),
    question: "If you bet now and BB folds, what happens?",
    choices: const [
      "You must reveal your cards",
      "You take the pot without a showdown",
      "The board still goes to the river",
    ],
    correct: 1,
    reason:
        "A fold from the last opponent ends the hand. The remaining player takes the pot without comparing cards.",
  ),
  _day7ExampleV1(
    1,
    "what_poker_is_content",
    "hero_cards_board_pot",
    _day7PostflopV1("bb", "6s 6d", "Kc 6c 2h 9s 3h", shownHand: "Ks 9d"),
    question: "Why does your hand win at showdown?",
    choices: const [
      "You were in BB",
      "HJ acted after you",
      "Three sixes outrank two pair",
    ],
    correct: 2,
    reason:
        "You have three sixes using 6c and both private cards. HJ has kings and nines.",
  ),
  _day7ExampleV1(
    1,
    "showdown_winning",
    "hero_cards_board_pot",
    _day7PostflopV1("co", "Jd 7c", "As Ks Qh Td 9c", shownHand: "Jh 4s"),
    question:
        "You and BB each use a jack with the board. What happens to the pot?",
    choices: const [
      "It is split",
      "CO wins on position",
      "BB wins on the lower private card",
    ],
    correct: 0,
    reason:
        "Both play A-K-Q-J-T. Neither player's other private card is used in the best five.",
  ),
  _day7ExampleV1(
    2,
    "hand_discipline_buckets",
    "pot_to_call",
    _day7PreflopV1("hj", "Kh Kc"),
    question: "Which Sharky starting-hand bucket fits your kings?",
    choices: const ["Medium", "Premium", "Weak"],
    correct: 1,
    reason:
        "KK is in the Premium group. A pair of kings stays in that group regardless of position.",
  ),
  _day7ExampleV1(
    2,
    "fold_discipline",
    "pot_to_call",
    _day7PreflopV1("hj", "9d 4s", showTurn: true),
    question:
        "By the Sharky starting chart, what do you do first in from HJ with 94o?",
    choices: const ["Call", "Raise", "Fold"],
    correct: 2,
    reason:
        "94o is a Weak offsuit hand. The chart folds this hand first in from HJ.",
  ),
  _day7ExampleV1(
    2,
    "weak_ace_warning",
    "pot_to_call",
    _day7PreflopV1("co", "Ac 4d", opener: "hj", openBb: 3, showTurn: true),
    question:
        "Your A4o and HJ's A-Q can both pair an ace. Why can continuing be costly?",
    choices: const [
      "HJ can win with the higher side card",
      "Your ace always beats HJ's ace",
      "An ace on the board guarantees a tie",
    ],
    correct: 0,
    reason:
        "When both players pair the ace and no stronger combination appears, HJ's queen can beat your four.",
  ),
  _day7ExampleV1(
    2,
    "continue_or_let_go",
    "pot_to_call",
    _day7PreflopV1("co", "Jc 4h", opener: "hj", openBb: 3.5, showTurn: true),
    question:
        "Which fact makes this a decision about continuing rather than opening?",
    choices: const [
      "You sit in CO",
      "HJ already raised",
      "Your cards are offsuit",
    ],
    correct: 1,
    reason:
        "HJ put in the first raise, to 3.5 BB. A first-in decision only happens before anyone enters.",
  ),
  _day7ExampleV1(
    2,
    "continue_or_let_go",
    "hero_button",
    _day7PreflopV1("co", "Kh Jh", showTurn: true),
    question:
        "By the Sharky starting chart, what can you do first in from CO with KJs?",
    choices: const ["Fold", "Call", "Raise"],
    correct: 2,
    reason:
        "KJs has two high cards of one suit. The chart includes KJs for a first-in raise from CO.",
  ),
  _day7ExampleV1(
    2,
    _w2ThreeBetLessonId,
    'pot_to_call',
    _day7PreflopV1('co', 'Ah Kh', opener: 'hj', openBb: 3, showTurn: true),
    question: _w2ThreeBetQuestion,
    choices: const ['Call', 'Fold', 'Raise'],
    correct: 2,
    reason:
        'AK suited is Premium in the starting chart. From CO, you can '
        'reraise the 3 BB HJ open to build the pot in position. Calling '
        'leaves the pot smaller, and folding gives up a Premium hand.',
  ),
  _day7ExampleV1(
    2,
    "hand_discipline_apply",
    "pot_to_call",
    _day7PreflopV1("utg", "6d 2c", showTurn: true),
    question:
        "You are first in with 62o. What does the Sharky starting chart say to do?",
    choices: const ["Fold", "Raise", "Call"],
    correct: 0,
    reason:
        "62o is a weak offsuit hand in the first seat to act. The chart leaves it out of UTG opens.",
  ),
  _day7ExampleV1(
    2,
    "hand_discipline_apply",
    "hero_seat",
    _day7PreflopV1("hj", "As Jd", showTurn: true),
    question:
        "By the Sharky starting chart, what do you do first in from HJ with AJo?",
    choices: const ["Call", "Raise", "Fold"],
    correct: 1,
    reason:
        "AJo is Medium. The chart includes it for first-in raises from HJ and the later non-blind seats.",
  ),
  _day7ExampleV1(
    2,
    "discipline_checkpoint",
    "pot_to_call",
    _day7PreflopV1("co", "As 5d", opener: "utg", openBb: 4, showTurn: true),
    question: "Which description matches your hand and the action before you?",
    choices: const [
      "Unopened with a premium hand",
      "Checked to you with a suited ace",
      "Facing a raise with a weak offsuit ace",
    ],
    correct: 2,
    reason:
        "UTG raised to 4 BB. A5o is a weak offsuit ace, so both the hand group and the earlier raise matter.",
  ),
  _day7ExampleV1(
    3,
    "position_six_seats",
    "seat",
    _day7PreflopV1("hj", "9c 6d"),
    question: "Who sits immediately clockwise after UTG?",
    choices: const ["HJ", "CO", "BB"],
    correct: 0,
    reason: "The six-seat preflop order starts UTG, HJ, then CO.",
  ),
  _day7ExampleV1(
    3,
    "position_six_seats",
    "cutoff",
    _day7PreflopV1("co", "8h 5h"),
    question: "Which position sits between HJ and the Button?",
    choices: const ["SB", "CO", "UTG"],
    correct: 1,
    reason: "CO sits one place before the Button and one place after HJ.",
  ),
  _day7ExampleV1(
    3,
    "position_six_seats",
    "hero_button",
    _day7PreflopV1("hj", "Td 7h"),
    question:
        "You are sitting in HJ. Which seat has the round dealer marker this hand?",
    choices: const ["SB", "HJ", "BTN"],
    correct: 2,
    reason:
        "The dealer marker is at BTN. Your own HJ seat and the dealer are separate.",
  ),
  _day7ExampleV1(
    3,
    "position_six_seats",
    "small_blind",
    _day7PreflopV1("sb", "7d 5c"),
    question: "You have posted half a big blind. Which position are you in?",
    choices: const ["SB", "BB", "BTN"],
    correct: 0,
    reason:
        "SB is the smaller blind immediately after the Button. It posts 0.5 BB here.",
  ),
  _day7ExampleV1(
    3,
    "position_six_seats",
    "big_blind",
    _day7PreflopV1("bb", "Ks 4h"),
    question:
        "You have already posted the full blind. What does the label at your seat mean?",
    choices: const ["Button", "Big blind", "Small blind"],
    correct: 1,
    reason: "BB means big blind. It is the seat that posted 1 BB in this hand.",
  ),
  _day7ExampleV1(
    3,
    "position_six_seats",
    "misread_table_position",
    _day7PreflopV1("utg", "Tc 7c"),
    question: "Which sequence starts at UTG and follows this table clockwise?",
    choices: const [
      "UTG, CO, HJ, BTN, BB, SB",
      "UTG, BTN, SB, BB, HJ, CO",
      "UTG, HJ, CO, BTN, SB, BB",
    ],
    correct: 2,
    reason:
        "HJ and CO follow UTG before the Button. The blinds follow BTN, with SB before BB.",
  ),
  _day7ExampleV1(
    3,
    "button_advantage",
    "button",
    _day7PreflopV1("sb", "Tc 4d"),
    question:
        "The dealer marker is directly before your seat. Which position has it?",
    choices: const ["BTN", "CO", "BB"],
    correct: 0,
    reason:
        "SB follows the Button clockwise. The dealer marker belongs to BTN.",
  ),
  _day7ExampleV1(
    3,
    "button_advantage",
    "pot_to_call",
    _day7PreflopV1("btn", "7h 7d", showTurn: true),
    question:
        "Everyone before BTN folded. According to the Sharky starting chart, what do you do with a pair of sevens?",
    choices: const ["Fold", "Raise", "Call"],
    correct: 1,
    reason:
        "A pair of sevens is included in the chart's BTN first-in opens. Only the blinds have decisions left.",
  ),
  _day7ExampleV1(
    3,
    "button_advantage",
    "hero_button",
    _day7PostflopV1("bb", "Kh Js", "Qs 8d 3s 2c 6h", opponent: "btn"),
    question: "Who gets to see the other's first river action before acting?",
    choices: const ["BB", "The preflop caller regardless of seat", "BTN"],
    correct: 2,
    reason:
        "BB acts first on the river. BTN can use BB's action when making a decision.",
  ),
  _day7ExampleV1(
    3,
    "early_vs_late",
    "hero_button",
    _day7PostflopV1("bb", "Ac 9c", "Ah 4s 2d", opponent: "btn"),
    question: "If BB checks this flop, which seat is next to decide?",
    choices: const ["BTN", "UTG", "SB"],
    correct: 0,
    reason: "Only BB and BTN are still in. BB's check passes action to BTN.",
  ),
  _day7ExampleV1(
    3,
    "early_vs_late",
    "seat",
    _day7PreflopV1("co", "8c 7c"),
    question:
        "On the first preflop pass, which position sees more earlier decisions than HJ but fewer than BTN?",
    choices: const ["BB", "CO", "UTG"],
    correct: 1,
    reason: "The preflop order reaches CO just after HJ and just before BTN.",
  ),
  _day7ExampleV1(
    3,
    "early_vs_late",
    "misread_position_action_order",
    _day7PreflopV1("hj", "Ks 8c"),
    question:
        "UTG folded. How many players still act after you on this first pass?",
    choices: const ["Two", "Five", "Four"],
    correct: 2,
    reason: "CO, BTN, SB and BB remain behind HJ. UTG has already folded.",
  ),
  _day7ExampleV1(
    3,
    "same_hand_different_seat",
    "pot_to_call",
    _day7PreflopV1("co", "Qd Td", showTurn: true),
    question:
        "By the Sharky starting chart, what is the first-in action here with QTs?",
    choices: const ["Raise", "Fold", "Call"],
    correct: 0,
    reason:
        "The chart includes QTs when CO is first in. An earlier raise would give you a different decision.",
  ),
  _day7ExampleV1(
    3,
    "same_hand_different_seat",
    "seat",
    _day7PreflopV1("utg", "Kd Th"),
    question: "In another unopened hand you held KTo at CO. What changes here?",
    choices: const [
      "Your cards become suited",
      "Your seat leaves more opponents to act",
      "The big blind is worth more",
    ],
    correct: 1,
    reason:
        "Your cards and blinds are the same. UTG has five seats behind, whereas CO has three.",
  ),
  _day7ExampleV1(
    3,
    "same_hand_different_seat",
    "position_action_order",
    _day7PreflopV1("hj", "Qh Jd", opener: "utg", openBb: 3),
    question:
        "You opened QJo first in from CO earlier. What is different in this hand?",
    choices: const [
      "Only the board matters now",
      "QJo is now a pair",
      "Your seat changed and an opponent has already raised",
    ],
    correct: 2,
    reason:
        "You are earlier at HJ and face UTG's raise. A first-in choice depends on both position and prior action.",
  ),
  _day7ExampleV1(
    3,
    "position_apply",
    "pot_to_call",
    _day7PreflopV1("hj", "Ac Qd", showTurn: true),
    question:
        "By the Sharky starting chart, what do you do first in from HJ with AQo?",
    choices: const ["Raise", "Call", "Fold"],
    correct: 0,
    reason:
        "AQo is included in HJ's first-in raises. No opponent has entered before you.",
  ),
  _day7ExampleV1(
    3,
    "position_checkpoint",
    "pot_to_call",
    _day7PreflopV1("utg", "Ah 8s", showTurn: true),
    question:
        "You have A8o first in from UTG. What does the Sharky starting chart say?",
    choices: const ["Call", "Fold", "Raise"],
    correct: 1,
    reason:
        "A8o is a weak offsuit ace from UTG. The chart leaves it out of that seat's first-in opens.",
  ),
  _day7ExampleV1(
    3,
    "position_checkpoint",
    "players_behind",
    _day7PreflopV1("hj", "Js Tc"),
    question:
        "One player folded and action is on HJ. Which players are still behind you on this pass?",
    choices: const [
      "UTG and CO",
      "BTN and the blinds only",
      "CO, BTN, SB and BB",
    ],
    correct: 2,
    reason: "UTG is out. CO, BTN and both blinds have yet to act.",
  ),
  _day7ExampleV1(
    3,
    'button_advantage',
    'hero_cards_board_pot',
    _day7PostflopV1('btn', 'Ad 8s', 'As 6h 4c', betBb: 0, checkedToHero: true),
    question: 'What did acting later let you learn about the 6 BB pot?',
    choices: const [
      'BB checked before you had to choose',
      'Your bet size was set by BB',
      'The flop was dealt after your bet',
    ],
    correct: 0,
    reason:
        'BB checked on A-6-4 before BTN had to act. You know BB did '
        'not lead into the 6 BB pot, so you can decide with that information.',
  ),
  _day7ExampleV1(
    3,
    'w3_play_from_blinds',
    'pot_to_call',
    _day7PreflopV1('bb', '8h 3c', opener: 'btn', openBb: 3.5, showTurn: true),
    caption:
        'BTN raises to 3.5 BB and SB folds. Assume you win 28% and face '
        'no later bets. Compare calling with folding.',
    question: 'What does the call price tell you?',
    choices: const [
      'Your chance to win covers the price',
      'The price is too high',
      'Your posted blind makes the call free',
    ],
    correct: 1,
    reason:
        'The 2.5 BB call would make a 7.5 BB pot, so you need about 33% '
        'equity. With 28% for 83o in this model, folding saves the extra 2.5 BB.',
  ),
  _day7ExampleV1(
    4,
    "why_bets_happen",
    "hero_cards_board_pot",
    _day7PostflopV1(
      "co",
      "As Qh",
      "Ad 9d 5c 2s",
      checkedToHero: true,
      showTurn: true,
    ),
    question:
        "BB calls a 3 BB bet with A-T or A-K. Which of those calls would this bet get from a worse hand?",
    choices: const ["A-T", "A-K", "Neither hand"],
    correct: 0,
    reason:
        "All three hands have a pair of aces. Your queen beats the ten but loses to the king.",
  ),
  _day7ExampleV1(
    4,
    "small_half_pot",
    "board_cards",
    _day7PostflopV1("bb", "Kd 9d", "Kh 7s 4h", openBb: 3.75),
    question: "Which bet is half of this pot?",
    choices: const ["2 BB", "4 BB", "8 BB"],
    correct: 1,
    reason: "The pot is 8 BB. Half of 8 BB is 4 BB.",
  ),
  _day7ExampleV1(
    4,
    "small_half_pot",
    "minimum_raise",
    _day7PostflopV1("co", "Kc Jd", "Kd 7c 2s", betBb: 3),
    question:
        "BB bets 3 BB on the flop. What is the smallest legal raise total from CO?",
    choices: const ["4.5 BB", "6 BB", "9 BB"],
    correct: 1,
    reason:
        "BB bet 3 BB on the flop, so adding 3 BB on top of 3 BB makes 6 BB the smallest legal raise.",
  ),
  _day7ExampleV1(
    4,
    "call_price",
    "pot_to_call",
    _day7PostflopV1("bb", "Jc 9s", "Jd 8h 4s 2c", betBb: 2, showTurn: true),
    question:
        "If you win 1 in 4 with no ties or more betting, which earns more in the stated model?",
    choices: const ["Fold", "Both choices earn zero", "Call"],
    correct: 2,
    reason:
        "Pay 2 BB to play for a final 10 BB pot. You need 20% and have 25%, so calling is ahead.",
    caption:
        "6-max micro-stakes. With one decision left, assume you win 1 time in 4 if you call.",
  ),
  _day7ExampleV1(
    4,
    "value_bets",
    "board_cards",
    _day7PostflopV1(
      "co",
      "Kd Qc",
      "Kh 8h 5s 3c 2d",
      checkedToHero: true,
      showTurn: true,
    ),
    question: "Which play lets BB pay you with a weaker king?",
    choices: const ["Bet 3 BB", "Check to showdown", "Fold"],
    correct: 0,
    reason:
        "A 3 BB bet gets a call from the weaker kings in this model. A check ends the hand without that payment.",
    caption:
        "6-max micro-stakes. In this example BB calls 3 BB with K-J and K-T.",
  ),
  _day7ExampleV1(
    4,
    "bluff_pressure",
    "board_cards",
    _day7PostflopV1(
      "co",
      "Jh 8h",
      "Qs 7h 3c 2s 9d",
      checkedToHero: true,
      showTurn: true,
    ),
    question:
        "Which choice can make BB give up a better hand in the stated example?",
    choices: const ["Check", "Bet 3 BB", "Fold"],
    correct: 1,
    reason:
        "A pair of sevens beats your queen-high. Betting 3 BB makes that better hand fold in this model.",
    caption:
        "6-max micro-stakes. BB has a pair of sevens and folds it to a 3 BB bet.",
  ),
  _day7ExampleV1(
    4,
    "protection_and_denial",
    "board_cards",
    _day7PostflopV1(
      "co",
      "9s 9h",
      "8c 5d 2h",
      checkedToHero: true,
      showTurn: true,
    ),
    question:
        "Which choice makes BB pay or fold instead of seeing the next card free?",
    choices: const ["Check", "Fold", "Bet 3 BB"],
    correct: 2,
    reason:
        "Your check lets the round end without a price. A bet sets a price BB must pay to see the next card.",
    caption:
        "6-max micro-stakes. Assume BB has A-K and can pair either card on the turn.",
  ),
  _day7ExampleV1(
    4,
    "price_checkpoint",
    "hero_cards_board_pot",
    _day7PostflopV1(
      "co",
      "Ad Jd",
      "Ah 7d 5s 2h Kc",
      checkedToHero: true,
      showTurn: true,
    ),
    question: "Which calling hand would give your bet value?",
    choices: const ["A-9", "A-Q", "Both of them"],
    correct: 0,
    reason:
        "Your jack beats A-9's nine side card. A-Q has the higher side card and beats your pair of aces.",
    caption: "6-max micro-stakes. Assume BB calls 3 BB with either A-9 or A-Q.",
  ),
  _day7ExampleV1(
    4,
    "price_checkpoint",
    "pot_to_call",
    _day7PostflopV1("bb", "Qd Ts", "Qh 8c 4d 3h 2s", betBb: 3, showTurn: true),
    question:
        "With that chance and price, which choice earns more over many hands?",
    choices: const ["Call", "Fold", "Both earn the same"],
    correct: 1,
    reason:
        "Calling costs 3 BB for a final 12 BB pot and needs 25% wins. One win in five is 20%; folding saves the 3 BB.",
    caption:
        "6-max micro-stakes. Two players, no ties or further betting. Assume one win in five against this opponent's range.",
  ),
  _day7ExampleV1(
    1,
    "hand_rankings_upper",
    "w1_rules_check_made_hand",
    _day7PostflopV1("bb", "Th Td", "Tc 6d 6s 3h 2c", shownHand: "As 6h"),
    question: "Whose best five rank higher?",
    choices: const [
      "HJ's three sixes",
      "Both players tie",
      "Your tens full of sixes",
    ],
    correct: 2,
    reason:
        "Your two tens and Tc plus both board sixes make a full house. HJ has three sixes only.",
  ),
  _day7ExampleV1(
    1,
    "showdown_winning",
    "w1_rules_check_ace_kicker",
    _day7PostflopV1("bb", "Ad 3h", "7c 7d 6s 4h 2c", shownHand: "Kc 8s"),
    question: "Both hands use the pair of sevens. Who wins the comparison?",
    choices: const ["You", "HJ", "Split the pot"],
    correct: 0,
    reason:
        "The shared pair ties. Your ace is higher than HJ's king, the next card in each best five.",
  ),
  _day7ExampleV1(
    1,
    "showdown_winning",
    "w1_rules_check_board_tie",
    _day7PostflopV1("co", "2d 6c", "Kh Qd Jc Ts 9h", shownHand: "3s 8d"),
    question: "Who takes the pot on this river?",
    choices: const ["BB", "Both split it", "You"],
    correct: 1,
    reason:
        "The best five for both are the king-high straight on the board. Neither player can make a higher one.",
  ),
  _day7ExampleV1(
    1,
    "cards_ranks_suits",
    "w1_rules_check_best_straight",
    _day7PostflopV1("bb", "9d Kh", "4s 5h 6d 7c 8s"),
    question: "Which card is highest in your best straight?",
    choices: const ["8", "King", "9"],
    correct: 2,
    reason:
        "You can replace 4 with 9 and use 5-6-7-8-9. Your king does not extend that run.",
  ),
  _day7ExampleV1(
    1,
    "blinds_action_order",
    "w1_rules_check_preflop_after_hj",
    _day7PreflopV1("co", "Js 5d"),
    question:
        "UTG and HJ both folded. Whose decision is next on the first pass?",
    choices: const ["CO", "BB", "BTN"],
    correct: 0,
    reason:
        "CO follows HJ in the first preflop pass, before the Button and the blinds.",
  ),
  _day7ExampleV1(
    1,
    "positions",
    "w1_rules_check_postflop_two_left",
    _day7PostflopV1("bb", "9h 5h", "As Jc 4d"),
    question:
        "HJ and BB are the only seats still in. Who must act first on this flop?",
    choices: const ["HJ", "BB", "Whoever opened"],
    correct: 1,
    reason:
        "After the flop the first live seat clockwise after the Button acts first. That is BB.",
  ),
  _day7ExampleV1(
    1,
    "blinds_action_order",
    "w1_rules_check_forced_bets",
    _day7PreflopV1("hj", "Ad 8c"),
    question: "Who put chips into this hand before any voluntary action?",
    choices: const ["UTG and HJ", "Everyone at the table", "SB and BB"],
    correct: 2,
    reason: "The two forced posts are 0.5 BB from SB and 1 BB from BB.",
  ),
  _day7ExampleV1(
    1,
    "fold_check_call_raise",
    "w1_rules_check_check_behind",
    _day7PostflopV1(
      "co",
      "9s 7c",
      "Ah Td 4h 3s",
      checkedToHero: true,
      showTurn: true,
    ),
    question:
        "BB has checked this turn. How can you see the last card without putting in any chips?",
    choices: const ["Check", "Call", "Fold"],
    correct: 0,
    reason:
        "There is nothing to match. A check keeps your hand live without adding chips.",
  ),
  _day7ExampleV1(
    1,
    "fold_check_call_raise",
    "w1_rules_check_raise_call_price",
    _day7PostflopV1("co", "Kh Qs", "Kd 8s 4d", heroLeadBb: 3, betBb: 9),
    question:
        "You already put in 3 BB on this flop. BB made it 9 BB. How much more matches the raise?",
    choices: const ["9 BB", "6 BB", "12 BB"],
    correct: 1,
    reason:
        "The 3 BB already in front of you count. Add 6 BB to reach the new total of 9 BB.",
  ),
  _day7ExampleV1(
    1,
    "what_poker_is_content",
    "w1_rules_check_uncalled_all_in",
    _day7PreflopV1(
      "co",
      "Ks Kd",
      opener: "hj",
      openBb: 18,
      heroStartingBb: 11,
      allIn: true,
      showTurn: true,
    ),
    question:
        "If you call and everyone else folds, how many of HJ's chips are returned?",
    choices: const ["11 BB", "18 BB", "7 BB"],
    correct: 2,
    reason:
        "HJ put in 18 BB. Your 11 BB call matches 11, so HJ's other 7 BB are returned.",
  ),
  _day7ExampleV1(
    6,
    'range_bucket_basics',
    'hero_cards_board_pot',
    _day7PostflopV1('co', 'Kh Jh', 'Kd 4s 2c', checkedToHero: true),
    question: 'BB can call a small bet with worse kings. Which bucket fits KJ?',
    choices: const ['Missed', 'Value', 'Bluff candidate'],
    correct: 1,
    reason:
        'KJ pairs the highest card. If weaker kings call, it can earn chips as a value hand.',
  ),
  _day7ExampleV1(
    6,
    'range_bucket_basics',
    'board_cards',
    _day7PostflopV1('co', 'Ac Jd', 'Ks 6c 4s', checkedToHero: true),
    question: 'What do you check before choosing a bet size with AJ?',
    choices: const [
      'Only the size of the pot',
      'Which bucket fits AJ on this flop',
      'Whether AJ can open preflop',
    ],
    correct: 1,
    reason:
        'AJ has no pair on K-6-4. Read the cards together before deciding whether a bet could work.',
  ),
  _day7ExampleV1(
    6,
    'range_board_fit',
    'hero_cards_board_pot',
    _day7PostflopV1('co', 'Qh Jd', '7s 6h 4h', checkedToHero: true),
    question: 'How well does QJ fit this flop before you know what BB folds?',
    choices: const [
      'Top pair for value',
      'Missed the flop',
      'An immediate flush draw',
    ],
    correct: 1,
    reason:
        'QJ pairs none of the three board cards and has only three hearts between hand and board.',
  ),
  _day7ExampleV1(
    6,
    'range_board_fit',
    'range_bucket_shift',
    _day7PostflopV1('co', 'As 5d', 'Kd 8c 4s 8s', checkedToHero: true),
    caption:
        'BB checked again and now calls small bets with every better hand in the modeled range.',
    question: 'What happened to the flop bluff candidate?',
    choices: const [
      'It can move to missed',
      'It became a value hand',
      'Its old bluff still works the same way',
    ],
    correct: 0,
    reason:
        'A5 has no private-card pair on this board. With better hands no longer folding, the stated reason to bluff has gone.',
  ),
  _day7ExampleV1(
    6,
    'range_pressure_lines',
    'no_bet_yet',
    _day7PostflopV1('co', 'Ks Qh', 'Kd 9s 3c', checkedToHero: true),
    caption: 'BB checks and will call a small bet with KJ and KT.',
    question: 'What can a small bet accomplish with KQ?',
    choices: const [
      'Get weaker kings to call',
      'Make KJ fold',
      'Call the existing bet',
    ],
    correct: 0,
    reason:
        'BB has checked. KQ can bet for value because KJ and KT make the same pair with a lower kicker.',
  ),
  _day7ExampleV1(
    6,
    'range_pressure_lines',
    'hero_cards_board_pot',
    _day7PostflopV1('co', 'Ts 8d', 'Qh 7c 3s', checkedToHero: true),
    caption: 'In the modeled range BB folds ace-high to a small bet.',
    question: 'Which purpose can a small bet serve with T8?',
    choices: const [
      'Get called by weaker pairs',
      'Fold out a better unpaired hand',
      'Protect top pair',
    ],
    correct: 1,
    reason:
        'T8 misses Q-7-3. Ace-high beats it when neither improves, so a fold from ace-high gives the bet a bluff purpose.',
  ),
  _day7ExampleV1(
    6,
    'range_pressure_lines',
    'board_cards',
    _day7PostflopV1('co', 'Jc 9d', 'Kh 6s 2c', checkedToHero: true),
    caption: 'BB folds QJ to a small bet and calls with every pair.',
    question: 'Which fold would help your J9 bluff on this flop?',
    choices: const ['QJ folding', 'A king calling', 'A six calling'],
    correct: 0,
    reason:
        'Neither J9 nor QJ pairs K-6-2. QJ has the higher high card, so its fold gives up a hand that is ahead.',
  ),
  _day7ExampleV1(
    6,
    'range_pressure_lines',
    'range_bucket_shift',
    _day7PostflopV1('co', 'Jd 9s', 'Kh 6c 2s 6d', checkedToHero: true),
    caption: 'BB no longer folds any better hand to a bet after the six pairs.',
    question: 'Which plan fits J9 after BB checks this turn?',
    choices: const [
      'Check behind',
      'Repeat the flop bluff plan',
      'Make a large value bet',
    ],
    correct: 0,
    reason:
        'J9 still has no private-card pair. Checking saves the price of a bluff that can no longer fold out a better hand.',
  ),
  _day7ExampleV1(
    6,
    'range_pressure_lines',
    'board_texture_change',
    _day7PostflopV1('co', 'Kh Td', 'Ks 8c 4c 6c', checkedToHero: true),
    caption:
        'On this turn BB calls bets only with a flush or two pair or better.',
    question: 'What is the cleaner choice for your top pair after BB checks?',
    choices: const [
      'Bet big for value',
      'Check behind',
      'Use the same value bet as the flop',
    ],
    correct: 1,
    reason:
        'The third club completes possible flushes. Under the stated rule only hands that beat KT call, so checking saves the cost of a turn bet.',
  ),
  _day7ExampleV1(
    6,
    'range_combo_counts',
    'pot_to_call',
    _day7PreflopV1('co', '8c 4d'),
    question: 'Before blockers, how many distinct K-Q hands are suited?',
    choices: const ['Six', 'Four', 'Sixteen'],
    correct: 1,
    reason:
        'There are four suits, each providing one same-suit king and queen. The sixteen all include offsuit hands.',
  ),
  _day7ExampleV1(
    6,
    'w6_continuation_bet',
    'board_cards',
    _day7PostflopV1('co', 'Jh Tc', 'Js 6h 2d', checkedToHero: true),
    caption:
        'CO raised preflop. BB called and checked the dry flop. Weaker jacks will call a small bet.',
    question: 'Which continuation size fits the small-bet plan?',
    choices: const ['6 BB', '2 BB', '9 BB'],
    correct: 1,
    reason:
        'JT has top pair on J-6-2 rainbow. Two BB is one third of this 6 BB pot and offers weaker jacks a smaller price.',
  ),
  _day7ExampleV1(
    6,
    'range_thinking_checkpoint',
    'hero_cards_board_pot',
    _day7PostflopV1('co', 'Qh Qd', '9s 5d 2c', checkedToHero: true),
    caption: 'BB will call a small bet with a nine.',
    question: 'What can your overpair gain by betting small?',
    choices: const [
      'A call from a weaker hand',
      'A call only from a set',
      'A fold from every nine',
    ],
    correct: 0,
    reason:
        'QQ beats a nine on this board. A small bet can get paid by that weaker pair.',
  ),
  _day7ExampleV1(
    6,
    'range_thinking_checkpoint',
    'pot_to_call',
    _day7PreflopV1('hj', '4s 3d'),
    question:
        'How many two-card combinations make pocket tens before blockers?',
    choices: const ['Twelve', 'Four', 'Six'],
    correct: 2,
    reason:
        'Choose two distinct tens from four suits. Counting each pair once leaves six combinations.',
  ),
  _day7ExampleV1(
    6,
    'range_thinking_checkpoint',
    'board_cards',
    _day7PostflopV1('co', '7h 6c', 'Qd 9c 2s', checkedToHero: true),
    caption: 'BB folds KJ to a small bet and calls with a pair.',
    question: 'What could a small bet with 76 aim to do?',
    choices: const [
      'Get a weaker hand to call',
      'Get a better high-card hand to fold',
      'Protect a pocket pair',
    ],
    correct: 1,
    reason:
        '76 misses Q-9-2 and trails KJ when both stay unpaired. A fold from KJ is a reason to bluff.',
  ),
  _day7ExampleV1(
    6,
    'range_reading_review',
    'hero_cards_board_pot',
    _day7PostflopV1('co', 'Kc Jd', 'Kh 5s 2d', checkedToHero: true),
    caption: 'BB will call a small flop bet with KT.',
    question: 'Why can KJ make a small value bet on this flop?',
    choices: const [
      'It can get paid by a weaker king',
      'KT beats KJ and will fold',
      'KJ has a straight draw',
    ],
    correct: 0,
    reason:
        'Both hands make top pair on K-5-2. KJ wins by kicker, so a call from KT pays the stronger hand.',
  ),
  _day7ExampleV1(
    6,
    'range_reading_review',
    'pot_to_call',
    _day7PreflopV1('hj', '7s 4s'),
    question:
        'With no blockers, how many distinct K-J combinations are possible?',
    choices: const ['4', '12', '16'],
    correct: 2,
    reason:
        'Four kings each pair with four jacks. This includes four suited hands and twelve offsuit hands.',
  ),
  // W11 fresh hands.
  _day7ExampleV1(
    11,
    'post_session_review_loop',
    'hj',
    _day7PreflopV1('co', 'Jd Td', opener: 'hj', showTurn: true),
    question: 'When you mark the first raise for review, which seat made it?',
    choices: const ['UTG', 'HJ', 'BB'],
    correct: 1,
    reason:
        'HJ raised to 2.5 BB. The two blind posts came before voluntary action.',
    wrongReasons: const {
      0: 'UTG folded. Marking that seat would record the wrong player for the review.',
      2: 'BB posted 1 BB as a blind. Counting that as a raise would hide who first took the betting lead.',
    },
  ),
  _day7ExampleV1(
    11,
    'session_plan_basics',
    'misread_real_play_process',
    _day7PostflopV1('bb', 'As 8d', 'Ah 6c 2s', openBb: 2.5, betBb: 2),
    question:
        'Your goal is to read the price. What should you log about this hand?',
    choices: const [
      'The price you faced',
      'The mean size of each stack',
      'Where the dealer chip sits',
    ],
    correct: 0,
    wrongReasons: const {
      1: 'Stack size is a different note. HJ\'s 2 BB flop bet is the price you wanted to save.',
      2: 'The button tells you order. It will not tell you what the 2 BB call cost.',
    },
    reason:
        'Use HJ’s decision as a chance to log this call price. That matches the goal you set before you sat.',
  ),
  _day7ExampleV1(
    11,
    'table_trigger_reads',
    'misread_real_play_process',
    _day7PostflopV1('bb', '9s 8s', 'Th 7d 3c', openBb: 2.5, betBb: 2),
    question:
        'HJ made this small flop bet three times in a row. What should you track next?',
    choices: const [
      'A new plan for the whole table',
      'Which hands HJ shows after this bet',
      'What HJ did hands ago with a large bet',
    ],
    correct: 1,
    wrongReasons: const {
      0: 'The repeated 2 BB bet is HJ\'s cue. A whole-table plan loses that specific read.',
      2: 'A large bet from HJ is a different cue. It gives weak evidence for these 2 BB bets.',
    },
    reason:
        'This repeat gives you a pattern to test. A show of cards after a small flop bet helps you check what it means.',
  ),
  _day7ExampleV1(
    11,
    'table_trigger_reads',
    'hero_cards_board_pot',
    _day7PostflopV1('co', 'Kc 8h', 'Ks 7d 4s', openBb: 2.5),
    question: 'Which made hand do your cards give you?',
    choices: const [
      'Top two pair',
      'Two pair, kings and eights',
      'Top pair, kings',
    ],
    correct: 2,
    wrongReasons: const {
      0: 'The king on the flop matches your king. The eight does not match, so there is no second pair.',
      1: 'The board has no eight. Treating your spare card as a second pair makes the hand look too strong.',
    },
    reason:
        'Only the king at your seat pairs with the board. The eight is your spare card.',
  ),
  _day7ExampleV1(
    11,
    'table_trigger_reads',
    'pot_to_call',
    _day7PostflopV1(
      'bb',
      'Ad 4d',
      'Ts 8h 3c',
      openBb: 2.5,
      betBb: 3,
      showTurn: true,
    ),
    question: 'How much must BB add to stay in this hand?',
    choices: const ['3 BB', '5.5 BB', '8.5 BB'],
    correct: 0,
    wrongReasons: const {
      1: 'The 5.5 BB was already in the middle before HJ bet. Calling that much would overstate the cost.',
      2: '8.5 BB is in the middle after the bet. Counting it as your cost mixes the pot and the price.',
    },
    reason: 'HJ bet 3 BB on the flop. That is the part you must match.',
  ),
  _day7ExampleV1(
    11,
    'post_session_review_loop',
    'misread_real_play_process',
    _day7PostflopV1('bb', 'Jh 9h', 'Jd 7s 3c 2h', openBb: 2.5, betBb: 4),
    question:
        'You called too fast. What should you keep for tomorrow’s review?',
    choices: const [
      'How long you sat',
      'The hand and what the turn call cost',
      'Just the last card',
    ],
    correct: 1,
    wrongReasons: const {
      0: 'Minutes played cannot show if the call was good. Save HJ\'s 4 BB bet and your jack pair.',
      2: 'The fourth card alone leaves out HJ\'s bet. You need both to review the turn price.',
    },
    reason:
        'Write down this board and the 4 BB bet. You can use the full spot to check your call next time.',
  ),
  _day7ExampleV1(
    11,
    'real_play_transfer_checkpoint',
    'misread_real_play_process',
    _day7PostflopV1('co', 'Ac Jd', 'Ah 8c 4d 3s', openBb: 2.5, betBb: 4),
    question:
        'This hand comes after two loose calls. What is the best check on your plan?',
    choices: const [
      'Recall the size of each loss',
      'Switch to a new plan mid-hand',
      'Read this price before you act',
    ],
    correct: 2,
    wrongReasons: const {
      0: 'The earlier losses cannot price this new 4 BB bet. You would miss the point of the drill.',
      1: 'A fresh plan mid-hand drops the check you chose. Read the 4 BB cost first.',
    },
    reason:
        'The new 4 BB bet needs its own read. Use the plan you set and save the past calls for review.',
  ),
  _day7ExampleV1(
    11,
    'real_play_transfer_checkpoint',
    'hero_cards_board_pot',
    _day7PostflopV1('bb', 'Qh Td', 'Qs 9s 5c 3d', openBb: 2.5),
    question: 'What is your made hand on the turn?',
    choices: const ['A pair of queens', 'A straight', 'A pair of tens'],
    correct: 0,
    wrongReasons: const {
      1: 'Your queen and the board queen match. The turn does not give you five cards in a row.',
      2: 'No ten is on the board. Counting a pair of tens would make you miss your actual queen pair.',
    },
    reason:
        'Your queen pairs with the queen on the board. The ten does not pair.',
  ),
  _day7ExampleV1(
    11,
    'real_play_transfer_checkpoint',
    'big_blind',
    _day7PostflopV1('bb', 'Kc 9s', 'Kh 6h 4d', openBb: 2.5),
    question: 'You and HJ are the sole live seats. Who acts first on the flop?',
    choices: const ['HJ', 'BB', 'BTN'],
    correct: 1,
    wrongReasons: const {
      0: 'HJ opened preflop, but that does not set the flop order. Acting there would skip BB.',
      2: 'BTN is out. Giving that seat an action would put a folded player back in.',
    },
    reason:
        'BB is the first live seat to the left of the Button. HJ acts after BB.',
  ),
  _day7ExampleV1(
    11,
    'real_play_transfer_checkpoint',
    'pot_to_call',
    _day7PostflopV1(
      'bb',
      'Ah 9h',
      'Kh 7d 4s Qh',
      openBb: 2.5,
      betBb: 2,
      showTurn: true,
    ),
    question: 'What is the cost to see the last card?',
    choices: const ['2 BB', '5.5 BB', '7.5 BB'],
    correct: 0,
    wrongReasons: const {
      1: '5.5 BB was the pot before the bet. Using it as the call makes this draw look too costly.',
      2: '7.5 BB is the pot with the bet. Match the 2 BB bet rather than the whole pot.',
    },
    reason: 'The turn bet is 2 BB. Match that bet to see the river.',
  ),
  _day7ExampleV1(
    11,
    'post_session_review_loop',
    'board_cards',
    _day7PostflopV1('bb', 'Ad 5d', 'Kh 9c 4s 2d', openBb: 2.5),
    question: 'You are saving this hand for review. Which card was the turn?',
    choices: const ['The four', 'The two', 'The king'],
    correct: 1,
    wrongReasons: const {
      0: '4s was on the flop. Saving it as the turn changes the order the cards came out.',
      2: 'Kh was on the flop, not the fourth card. That note would send you back to the wrong street.',
    },
    reason:
        'The flop is the first three cards. Save 2d as the fourth card so you can replay the same choice.',
  ),
  _day7ExampleV1(
    11,
    'session_plan_basics',
    'pot_to_call',
    _day7PreflopV1('hj', 'Ah Td', showTurn: true),
    question: 'UTG folded. How much would a limp cost from HJ in this hand?',
    choices: const ['0.5 BB', '1 BB', '1.5 BB'],
    correct: 1,
    wrongReasons: const {
      0: '0.5 BB is what SB posted. A limp from HJ must match the full big blind.',
      2: '1.5 BB is the sum of the two blinds, not the largest live wager. It overstates the cost by half a blind.',
    },
    reason: 'You have posted no blind. A limp matches the 1 BB big blind.',
  ),
  _day7ExampleV1(
    11,
    'post_session_review_loop',
    'pot_to_call',
    _day7PostflopV1(
      'bb',
      'Kc Jd',
      'Ks 9c 4s 8d',
      openBb: 2.5,
      betBb: 5,
      showTurn: true,
    ),
    question: 'Which price should you write down to review your turn call?',
    choices: const ['5.5 BB', '10.5 BB', '5 BB'],
    correct: 2,
    wrongReasons: const {
      0: '5.5 BB is what was in the pot before the turn bet. It is not the cost you are reviewing.',
      1: '10.5 BB is the pot after the bet. Using it as the price would make your call look too large.',
    },
    reason:
        'The turn bet costs 5 BB to match. The 10.5 BB in the pot is what you stand to win before calling.',
  ),
];
