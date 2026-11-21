// Beginner glossary and hand ranks (HLP-02.a).
//
// One term dictionary serves two jobs:
// - the in-lesson Glossary sheet shows these definitions;
// - `act0_copy_error_classes_v1_test` checks that every entry with
//   [Act0GlossaryTermV1.teachOrderChecked] is explained by a lesson before
//   learner text uses it.
//
// Definitions are general Hold’em rules. The runner offers the reference
// during theory and feedback.

class Act0GlossaryTermV1 {
  const Act0GlossaryTermV1(
    this.name,
    this.use,
    this.definition, {
    this.inline,
    this.teachOrderChecked = false,
  });

  /// Name shown to the learner.
  final String name;

  /// Case-insensitive pattern that finds the term in learner text.
  final String use;

  /// One or two plain sentences.
  final String definition;

  /// Pattern of an inline explanation that counts as teaching the term.
  final String? inline;

  /// Whether the copy check requires a lesson to explain the term first.
  final bool teachOrderChecked;

  bool usedIn(String text) => RegExp(use, caseSensitive: false).hasMatch(text);
}

const act0GlossaryTermsV1 = <Act0GlossaryTermV1>[
  // Table and seats.
  Act0GlossaryTermV1(
    'Hero',
    r'\bhero\b',
    'You: the player whose decision the task asks about.',
  ),
  Act0GlossaryTermV1(
    'Blinds (SB, BB)',
    r'\bblinds?\b|\bSB\b|\bBB\b',
    'Forced bets posted before the cards are dealt. The small blind (SB) '
        'is usually half the big blind (BB). A stack or bet can be measured '
        'in big blinds.',
  ),
  Act0GlossaryTermV1(
    'Button (BTN)',
    r'\bbutton\b|\bBTN\b',
    'Marks the dealer position. The button acts last after the flop if still '
        'in the hand. It moves clockwise each hand.',
  ),
  Act0GlossaryTermV1(
    'Positions (UTG, HJ, CO)',
    r'\bUTG\b|\bHJ\b|\bCO\b|\bposition',
    'First to act before the flop: under the gun (UTG), then hijack (HJ), '
        'cutoff (CO), button (BTN), small blind (SB) and big blind (BB). '
        'After the flop, the first player still in the hand clockwise from '
        'the button acts first.',
  ),
  Act0GlossaryTermV1(
    'Private cards',
    r'\bprivate cards?\b',
    'The two cards dealt face down to each player. Only that player sees them.',
  ),
  Act0GlossaryTermV1(
    'Board',
    r'\bboard\b|\bcommunity cards?\b',
    'The shared cards in the middle of the table. Every player can use them.',
  ),
  // Streets.
  Act0GlossaryTermV1(
    'Preflop',
    r'\bpreflop\b',
    'The first betting round, after private cards are dealt and before any '
        'board card.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Flop',
    r'\bflop\b',
    'The first three board cards, dealt together, and the betting round '
        'after them.',
    inline: r'\(the flop\)',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Turn',
    r'\bturn\b(?! to act)',
    'The fourth board card and the betting round after it.',
  ),
  Act0GlossaryTermV1(
    'River',
    r'\briver\b',
    'The fifth and last board card and the final betting round.',
    inline: r'last street, the river',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Postflop',
    r'\bpostflop\b',
    'Every betting round after the flop is dealt: flop, turn and river.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Showdown',
    r'\bshowdown\b',
    'The players still in the hand compare their best five-card hands. The '
        'strongest eligible hand wins, and equal best hands split the pot.',
  ),
  // Actions and money.
  Act0GlossaryTermV1(
    'Pot',
    r'\bpot\b',
    'Chips committed by players in this hand. An all-in can create separate '
        'pots with different eligible players.',
  ),
  Act0GlossaryTermV1(
    'Side pot',
    r'\bside[- ]pots?\b',
    'A separate pot made from extra chips that players with more chips '
        'can still bet. A player who is already all-in can win the pot '
        'their chips matched, not the extra chips.',
  ),
  Act0GlossaryTermV1(
    'To call (price)',
    r'\bto call\b|\bprice\b',
    'How many more chips you must add to match the biggest bet on this '
        'street.',
  ),
  Act0GlossaryTermV1(
    'Fold',
    r'\bfold',
    'Give up the hand and any chips already in the pot.',
  ),
  Act0GlossaryTermV1(
    'Check',
    r'\bcheck',
    'Pass without adding chips. Only allowed when no bet faces you.',
  ),
  Act0GlossaryTermV1(
    'Call',
    r'\bcall',
    'Match the bet facing you. If you have fewer chips left, you can call '
        'all-in for less.',
  ),
  Act0GlossaryTermV1(
    'Bet and raise',
    r'\bbet\b|\braise',
    'A bet puts chips in when nobody has yet on this street. A raise makes '
        'an existing bet bigger.',
  ),
  Act0GlossaryTermV1(
    'All-in',
    r'\ball-in\b',
    'Putting in every chip you have left. You can still win only the part of '
        'the pot your chips match.',
  ),
  Act0GlossaryTermV1(
    'Limp',
    r'\blimp',
    'Entering the pot before the flop by just calling the big blind instead '
        'of raising.',
    inline: r'limping \(just calling the big blind\)',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'First in',
    r'\bfirst[- ]in\b',
    'Entering the pot before the flop when nobody else has put chips in '
        'voluntarily. Forced blinds do not count as entering.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'For value',
    r'\bfor value\b|\bvalue bet',
    'Betting with a strong hand so that weaker hands call and pay you.',
    inline: r'value bet wants weaker hands to call',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Open / opener',
    r'\bopen\s*/\s*opener\b|\b(?:unopened pot|open(?:-raise|ing|ed|er|s)? (?:the pot|first|fewer|too loose|weak|from|here|[0-9])|(?:an?|first|CO|HJ|UTG|BB) open|opened\b|opener\b|open-or-fold)',
    'An open is the first raise before the flop when nobody has entered '
        'voluntarily. The player who makes that raise is the opener.',
  ),
  Act0GlossaryTermV1(
    '3-bet',
    r'\b(?:3|three)[- ]bets?\b',
    'The first re-raise before the flop, after an opening raise.',
  ),
  Act0GlossaryTermV1(
    'Continuation bet (c-bet)',
    r'\b(?:continuation|c)[- ]bets?\b',
    'A bet on the flop by the player who made the last raise before '
        'the flop. They can make it with a strong hand or as a bluff.',
  ),
  Act0GlossaryTermV1(
    'In position',
    r'\b(?:in|out of) position\b',
    'You are in position against a player when you act after them in '
        'the usual order after the flop.',
  ),
  Act0GlossaryTermV1(
    'Bluff',
    r'\bbluff(?:s|ing)?\b',
    'A bet or raise that tries to make a better hand fold.',
  ),
  Act0GlossaryTermV1(
    'Protection',
    r'\bprotect(?:ion bets?|ion)\b',
    'Betting so an opponent with a weaker hand has to pay to see the '
        'next card. If they fold, they give up their chance to improve.',
  ),
  Act0GlossaryTermV1(
    'One-third pot',
    r'\bone-third(?:[- ]pot)?\b',
    'A bet equal to one-third of the pot before the bet. Into 6 BB, '
        'that is 2 BB.',
  ),
  Act0GlossaryTermV1(
    'Half-pot',
    r'\bhalf[- ]pot\b',
    'A bet equal to half of the pot before the bet. Into 6 BB, '
        'that is 3 BB.',
  ),
  Act0GlossaryTermV1(
    'Pot-size',
    r'\bpot[- ]size\b',
    'A bet equal to the pot before the bet. Into 6 BB, that is 6 BB.',
  ),
  // Hands.
  Act0GlossaryTermV1(
    'Broadway',
    r'\bbroadways?\b',
    'The broadway ranks are ten, jack, queen, king and ace. A broadway '
        'starting hand has two cards from those ranks.',
  ),
  Act0GlossaryTermV1(
    'Dominated',
    r'\bdominat(?:ed|es|ion)\b',
    'When starting hands share a rank, the hand with the lower other '
        'card is often dominated. For example, ace-seven has the lower '
        'other card against ace-king.',
  ),
  Act0GlossaryTermV1(
    'Top pair',
    r'\btop pair\b',
    'A pair made by matching one of your private cards with the highest '
        'rank on the board.',
  ),
  Act0GlossaryTermV1(
    'Middle pair',
    r'\b(?:middle|second) pair\b',
    'On the flop, a pair made by matching one of your private cards with '
        'the second-highest rank on the board.',
  ),
  Act0GlossaryTermV1(
    'Overpair',
    r'\boverpairs?\b',
    'A pair in your private cards that is higher than any card on the board. '
        'Two queens are an overpair on a jack-high board.',
  ),
  Act0GlossaryTermV1(
    'Overcard',
    r'\bovercards?\b',
    'A card higher than the rank you are comparing it with. An ace in '
        'your hand is an overcard to a king-high flop.',
  ),
  Act0GlossaryTermV1(
    'Set',
    r'^set$|\b(?:a set|trips and sets|top set|middle set|bottom set)\b',
    'Three cards of the same rank made with a pair in your private cards '
        'and one card on the board.',
  ),
  Act0GlossaryTermV1(
    'Flush draw',
    r'\bflush draws?\b',
    'Four cards of the same suit between your hand and the board. One '
        'more card of that suit would make a flush. With four seen, nine remain.',
  ),
  Act0GlossaryTermV1(
    'Backdoor draw',
    r'\bback[- ]?door(?: draw| flush| straight)?\b',
    'A draw on the flop that needs a helpful card on both the turn and '
        'the river to become a made hand.',
  ),
  Act0GlossaryTermV1(
    'Dry board',
    r'\bdry (?:board|flop)\b',
    'A board whose cards give players few ways to complete a straight '
        'or a flush on the next card.',
  ),
  Act0GlossaryTermV1(
    'Wet board',
    r'\bwet (?:board|flop)\b',
    'A board that gives players many ways to draw to a straight or flush, '
        'often through close ranks or matching suits.',
  ),
  Act0GlossaryTermV1(
    'Rainbow flop',
    r'\brainbow\b',
    'A flop with three different suits.',
  ),
  Act0GlossaryTermV1(
    'Two-tone flop',
    r'\btwo[ -]tone\b',
    'A flop with exactly two cards of one suit and one card of another.',
  ),
  Act0GlossaryTermV1(
    'Paired board',
    r'\bpaired (?:board|flop)\b',
    'A board with two cards that share a rank.',
  ),
  Act0GlossaryTermV1(
    'Open-ended straight draw',
    r'\bopen[ -]ended\b',
    'Four ranks in a row that can make a straight at either end. '
        'Four cards of each rank can finish it, for eight outs.',
  ),
  Act0GlossaryTermV1(
    'Gutshot',
    r'\bgutshots?\b',
    'A straight draw with one missing rank inside it. Any of the four '
        'cards of that rank can complete the straight.',
  ),
  Act0GlossaryTermV1(
    'Out',
    r'\bouts?\b',
    'An unseen card that would improve your hand. Count how many would '
        'actually win before using outs to decide whether to call.',
  ),
  Act0GlossaryTermV1(
    'Blank',
    r'\bblanks?\b',
    'A new board card that changes little for the hand or draw you are tracking.',
  ),
  Act0GlossaryTermV1(
    'Combo',
    r'\bcombos?\b',
    'One exact pair of private cards. Two different ranks have 16 combos '
        'before seeing any cards: four suited and 12 offsuit. A pocket pair has six. '
        'Seeing one card of the relevant rank can reduce 16 to 12 or six to three.',
  ),
  Act0GlossaryTermV1(
    'SPR',
    r'\bspr\b|\bstack-to-pot ratio\b',
    'The stack-to-pot ratio. Divide the effective stack (the smaller '
        'remaining stack heads-up) by the current pot.',
  ),
  Act0GlossaryTermV1(
    'Full ring',
    r'\bfull[ -]ring\b',
    'A table with nine seats in this course.',
  ),
  Act0GlossaryTermV1(
    'Suited',
    r'\bsuited\b',
    'Both private cards share one suit.',
  ),
  Act0GlossaryTermV1(
    'Offsuit',
    r'\boffsuit\b',
    'Two private cards of different suits.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Kicker',
    r'\bkicker',
    'A side card that can break a tie when players have the same main hand. '
        'When more than one kicker counts, compare them highest first.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Straight',
    r'\bstraight\b',
    'Five cards in a row of any suits, such as 5-6-7-8-9.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Flush',
    r'\bflush',
    'Five cards of one suit, in any order.',
    inline: r'flushes \(five cards of one suit\)',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Draw',
    r'\bdraws?\b|\bdraw-',
    'A chance to complete a stronger hand on a later card, such as having '
        'four cards of one suit and needing a fifth to make a flush.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Board texture',
    r'\btexture\b',
    'How the board cards connect: paired, one suit, close in rank, or spread '
        'out. It changes which hands are likely.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Range',
    r'\branges?\b',
    'All the hands a player could hold in this spot, not just one hand.',
    teachOrderChecked: true,
  ),
  Act0GlossaryTermV1(
    'Range advantage',
    r'\brange advantage\b',
    'An edge in hand strength across one player’s possible hands compared '
        'with the other player’s on the same board.',
  ),
  Act0GlossaryTermV1(
    'Equity',
    r'\bequity\b',
    'Your share of the pot if all cards were dealt out with no more betting, '
        'shown as a percentage.',
    teachOrderChecked: true,
  ),
];

class Act0HandRankV1 {
  const Act0HandRankV1(this.name, this.example, this.definition);

  final String name;
  final String example;
  final String definition;
}

/// Made hands from strongest to weakest.
const act0HandRanksV1 = <Act0HandRankV1>[
  Act0HandRankV1(
    'Royal flush',
    'A K Q J 10, one suit',
    'The best straight flush.',
  ),
  Act0HandRankV1(
    'Straight flush',
    '5 6 7 8 9, one suit',
    'Five cards in a row, all one suit.',
  ),
  Act0HandRankV1('Four of a kind', '9 9 9 9 K', 'Four cards of one rank.'),
  Act0HandRankV1(
    'Full house',
    'Q Q Q 4 4',
    'Three of one rank plus a pair of another.',
  ),
  Act0HandRankV1('Flush', 'A J 8 5 2, one suit', 'Five cards of one suit.'),
  Act0HandRankV1(
    'Straight',
    '6 7 8 9 10',
    'Five cards in a row. An ace can be low in A-2-3-4-5.',
  ),
  Act0HandRankV1(
    'Three of a kind (trips)',
    '7 7 7 K 2',
    'Three cards of one rank.',
  ),
  Act0HandRankV1('Two pair', 'J J 5 5 A', 'Two different pairs.'),
  Act0HandRankV1('One pair', '10 10 A 8 3', 'Two cards of one rank.'),
  Act0HandRankV1(
    'High card',
    'A Q 9 6 3',
    'No pair or better: the highest card plays.',
  ),
];
