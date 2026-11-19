import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

import 'act0_catalog_poker_facts_v1.dart';

typedef CatalogClaim = ({String rule, String value, bool? matches});

RegExp _rx(String pattern) => RegExp(pattern, caseSensitive: false);
const _rankWords = {
  'ace': 'A',
  'king': 'K',
  'queen': 'Q',
  'jack': 'J',
  'ten': 'T',
  'nine': '9',
  'eight': '8',
  'seven': '7',
  'six': '6',
  'five': '5',
  'four': '4',
  'three': '3',
  'two': '2',
};

final _made = _rx(
  r'\b(?:(?:you|hero) (?:now )?(?:have|hold|make|made|has|holds|makes)|your hand is|you are holding|this is)'
  r' (?:just |only )?(?:an? )?(high card|top pair|middle pair|second pair|'
  r'bottom pair|overpair|underpair|pocket pair|two pair|one pair|pair|'
  r'royal flush|straight flush|straight|flush draw|flush|full house|four of a kind|quads|'
  r'three of a kind|set|trips|open-ended(?: straight draw)?|'
  r'gutshot(?: straight draw)?|backdoor flush draw|backdoor straight draw)\b'
  r'(?![ -]draw\b)',
);
final _heldPair = _rx(
  r'(?:\b(?:you|hero) (?:have|hold|has|holds|start with) (?:a )?(?:pocket|two) |^(?:with )?pocket )'
  r'(aces?|kings?|queens?|jacks?|tens?|nines?|eights?|sevens?|sixes?|'
  r'fives?|fours?|threes?|twos?)\b',
);
final _rankedPair = _rx(
  r'\b(?:(?:you|hero) (?:have|has|make|makes|made)|you win with) a pair of (aces|kings|queens|jacks|tens|'
  r'nines|eights|sevens|sixes|fives|fours|threes|twos)\b',
);
final _texture = _rx(
  r'\b(?:this (?:board|flop) is (?:now )?|(?:on|shows|has) (?:an? )?|'
  r'^(?:a )?)(rainbow|two[- ]tone|monotone|paired|unpaired|consecutive)'
  r'(?: (?:board|flop))?\b',
);
final _boardRun = RegExp(
  r'\b(?:[Oo]n|[Bb]oard(?: is| shows)?|[Ff]lop(?: is| shows)?) '
  r'(?:a )?((?:10|[AKQJT2-9])(?:[-–](?:10|[AKQJT2-9])){2,4})\b',
);
final _card = RegExp(r'\b(10|[AKQJT2-9])([shdc])\b|\b(10|[AKQJT2-9])([♠♥♦♣])');
final _namedCard = _rx(
  r'\b(' + _rankWords.keys.join('|') + r') of (spades|hearts|diamonds|clubs)\b',
);
final _privateRankCode = RegExp(
  r'\b(?:[Yy]ou (?:hold|have)|Hero (?:holds?|has|shows)) '
  r'((?:10|[AKQJT2-9])[-–](?:10|[AKQJT2-9]))(?: (suited|offsuit))?\b',
);
final _handCode = RegExp(r'\b([AKQJT2-9]{2}[so])\b');
final _outs = _rx(
  r'\b(?:you (?:now )?have|hero has) (\d+) (?:(clean) )?(?:(flush|straight) )?outs\b',
);
final _hypothetical = _rx(
  r'\b(?:if|imagine|suppose|for example|could|might|would|versus|instead of|'
  r'either|next hand|another (?:hand|spot)|the first frame|the second frame|'
  r'not the same|compare both|compare .{0,48} with|would make)\b',
);
final _teachingDefinition = _rx(
  r'\b(?:means|is defined as|is called|for example|requires?|needs?|repeats? a rank|has two cards of the same rank)\b',
);

// Only assertion shapes whose referent can be located in a single scene.
// Definitions, comparative examples, distractor labels and hidden hands are
// handled by their owning grading/teaching rule, not treated as current cards.
List<CatalogClaim> catalogClaims(
  String text,
  Act0TableStateV1 table, {
  required bool titleOrLabel,
}) {
  final facts = CatalogPokerFacts(table);
  final claims = <CatalogClaim>[];
  void add(String rule, String value, bool? matches) =>
      claims.add((rule: rule, value: value, matches: matches));

  bool? made(String value) {
    final rank = facts.rank;
    final normalized = value.replaceAll('‑', '-');
    if (normalized == 'pocket pair') {
      return facts.hero.length == 2 ? facts.pocketPair : null;
    }
    if (rank == null) return null;
    return switch (normalized) {
      'top pair' ||
      'overpair' ||
      'underpair' ||
      'middle pair' ||
      'bottom pair' => facts.pairType == normalized,
      'second pair' => facts.pairType == 'middle pair',
      'pair' => rank == 'one pair',
      'three of a kind' => const {
        'set',
        'trips',
        'three of a kind',
      }.contains(rank),
      'quads' => rank == 'four of a kind',
      'royal flush' =>
        rank == 'straight flush' &&
            (facts.hand?.cards.any((card) => card.toString().startsWith('A')) ??
                false) &&
            (facts.hand?.cards.any((card) => card.toString().startsWith('T')) ??
                false),
      'flush draw' => facts.flushSuits.isNotEmpty,
      'open-ended' || 'open-ended straight draw' => facts.openEnded,
      'gutshot' || 'gutshot straight draw' => facts.gutshot,
      'backdoor flush draw' => facts.backdoorFlush,
      'backdoor straight draw' => facts.backdoorStraight,
      _ => rank == normalized,
    };
  }

  // "With two queens on Q-9-4" refers to the current private ranks or
  // a made pair. The exact constructor is checked separately when the text
  // calls it a pair rather than two private cards.
  for (final line in text.split(RegExp(r'(?<=[.!?])\s+|\n+'))) {
    final futureOutcome =
        facts.board.length < 5 &&
        RegExp(r'^(Turn|River) (?:10|[AKQJT2-9])[shdc]:').hasMatch(line);
    final hypothetical = _hypothetical.hasMatch(line) || futureOutcome;
    for (final match in _made.allMatches(line)) {
      final claim = match[1]!.toLowerCase();
      add('hand.category', match[0]!, hypothetical ? null : made(claim));
    }
    for (final match in _heldPair.allMatches(line)) {
      if (_rankedPair.hasMatch(line) ||
          _rx(
            r'^(?:with )?pocket .+ (?:has|have) \d+ (?:possible )?combos',
          ).hasMatch(line)) {
        continue;
      }
      final rank =
          _rankWords[match[1]!.toLowerCase().replaceFirst(RegExp(r's$'), '')];
      add(
        'hand.private_pair',
        match[0]!,
        hypothetical || rank == null || facts.hero.length != 2
            ? null
            : facts.hero.every((c) => c[0] == rank),
      );
    }
    for (final match in _rankedPair.allMatches(line)) {
      final rank =
          _rankWords[match[1]!.toLowerCase().replaceFirst(RegExp(r's$'), '')];
      final solved = facts.hand;
      add(
        'hand.made_pair',
        match[0]!,
        hypothetical || solved == null || rank == null
            ? null
            : facts.rank == 'one pair' &&
                  solved.cards
                      .take(2)
                      .every((card) => card.toString()[0] == rank),
      );
    }
    for (final match in _texture.allMatches(line)) {
      final claim = match[1]!.toLowerCase().replaceAll(' ', '-');
      // A leading "Paired boards..." is a general lesson, not a scene claim.
      if (match.end < line.length && RegExp(r'\w').hasMatch(line[match.end]))
        continue;
      add(
        'board.texture',
        match[0]!,
        hypothetical ||
                _teachingDefinition.hasMatch(line) ||
                facts.board.isEmpty
            ? null
            : switch (claim) {
                'paired' => facts.pairedBoard,
                'unpaired' => !facts.pairedBoard,
                'consecutive' => facts.consecutiveBoard,
                _ => facts.boardTone == null ? null : facts.boardTone == claim,
              },
      );
    }
    for (final match in _boardRun.allMatches(line)) {
      final named = match[1]!
          .split(RegExp(r'[-–]'))
          .map((r) => r == '10' ? 'T' : r)
          .join();
      add(
        'board.ranks',
        match[1]!,
        hypothetical || facts.board.isEmpty
            ? null
            : facts.board.map((c) => c[0]).join().startsWith(named),
      );
    }
    for (final match in _card.allMatches(line)) {
      final rank = match[1] ?? match[3]!;
      final suit =
          match[2] ?? {'♠': 's', '♥': 'h', '♦': 'd', '♣': 'c'}[match[4]]!;
      final code = (rank == '10' ? 'T' : rank) + suit;
      add(
        'card.named',
        code,
        hypothetical ||
                _teachingDefinition.hasMatch(line) ||
                facts.exposed.isEmpty
            ? null
            : facts.exposed.contains(code),
      );
    }
    for (final match in _namedCard.allMatches(line)) {
      final rank = _rankWords[match[1]!.toLowerCase()]!;
      final suit = match[2]!.toLowerCase()[0];
      final code = '$rank$suit';
      add(
        'card.named',
        code,
        hypothetical ||
                _teachingDefinition.hasMatch(line) ||
                facts.exposed.isEmpty
            ? null
            : facts.exposed.contains(code),
      );
    }
    for (final match in _privateRankCode.allMatches(line)) {
      final ranks = match[1]!.replaceAll('10', 'T').split(RegExp(r'[-–]'))
        ..sort();
      final held = facts.hero.map((card) => card[0]).toList()..sort();
      final suited =
          facts.hero.length == 2 && facts.hero[0][1] == facts.hero[1][1];
      final suitKind = match[2];
      add(
        'hand.code',
        match[0]!,
        hypothetical || held.length != 2
            ? null
            : held.join() == ranks.join() &&
                  (suitKind == null || (suitKind == 'suited') == suited),
      );
    }
    if (titleOrLabel ||
        _rx(
          r'\b(?:you|hero) (?:hold|holds|have|has|show|shows|are .*with)\b',
        ).hasMatch(line)) {
      for (final match in _handCode.allMatches(line)) {
        add(
          'hand.code',
          match[0]!,
          hypothetical || facts.code == null ? null : facts.code == match[0],
        );
      }
    }
    for (final match in _outs.allMatches(line)) {
      final kind = match[3]?.toLowerCase();
      final candidates = facts.completionCards.where(
        (card) => switch (kind) {
          'flush' => facts.flushSuits.contains(card[1]),
          'straight' => facts.straightRanks.contains(card[0]),
          _ => true,
        },
      );
      add(
        'draw.completions',
        match[0]!,
        hypothetical ||
                match[2] != null ||
                !facts.complete ||
                facts.board.length == 5 ||
                kind == null && facts.completionCards.isEmpty
            ? null
            : int.parse(match[1]!) == candidates.length,
      );
    }
  }
  return claims;
}
