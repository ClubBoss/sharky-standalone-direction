import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

import 'act0_catalog_poker_facts_v1.dart';
import 'act0_catalog_snapshot_v1.dart';

/// A clean out completes the named draw and wins outright against every
/// compatible holding in the model. A blocked card and a tie are not wins.
Set<String> catalogCleanOutsV1({
  required List<String> hero,
  required List<String> board,
  required Set<String> completionCards,
  required List<List<String>> opponentRange,
}) {
  if (board.length != 4 || opponentRange.isEmpty) {
    throw ArgumentError('Clean out enumeration needs a turn and a range.');
  }
  final known = {...hero, ...board};
  final legalRange = opponentRange
      .where(
        (hand) =>
            hand.length == 2 &&
            hand.toSet().length == 2 &&
            !hand.any(known.contains),
      )
      .toList();
  if (legalRange.isEmpty) throw ArgumentError('No legal opponent holdings.');
  final current = Hand.solveHand([...hero, ...board]);
  return completionCards.where((card) {
    if (known.contains(card)) return false;
    final compatible = legalRange.where((hand) => !hand.contains(card));
    if (compatible.isEmpty) return false;
    final river = [...board, card];
    final hand = Hand.solveHand([...hero, ...river]);
    return hand.compare(current) < 0 &&
        compatible.every(
          (villain) => hand.compare(Hand.solveHand([...villain, ...river])) < 0,
        );
  }).toSet();
}

typedef CatalogOutsAuditV1 = ({
  Map<String, String> findings,
  Set<String> checked,
  Set<String> unmodelled,
});

const _number =
    r'(0|[1-9]\d?|zero|one|two|three|four|five|six|seven|eight|nine|ten|eleven|twelve|thirteen|fourteen|fifteen)';
final _claim = RegExp(
  '\\b' +
      _number +
      r'\s+(?:(clean|winning)\s+)?'
          r'(outs?\b|rivers?\b|wins?\s+(?:in|out of)\s+\d+|'
          r'(?:hearts?|diamonds?|clubs?|spades?)\s+win\b|'
          r'(?:out of|of)\s+(?:44|46)\b)',
  caseSensitive: false,
);
final _suitWin = RegExp(r'\b(hearts?|diamonds?|clubs?|spades?)\s+win\b');
final _assumedCompletions = RegExp(
  r'\bassume (?:every (?:flush|straight) wins|[^.!?]+always win for your straight)\b',
  caseSensitive: false,
);
final _rawDraw = RegExp(
  r'\b(?:to make it|to (?:complete|fill)|unseen|could fill the flush)\b',
  caseSensitive: false,
);
final _nonHeartKingQueen = RegExp(
  r'\bholds a king and a queen, neither a heart\b',
  caseSensitive: false,
);

final _statedCards = RegExp(
  r'\b(?:holds?|shows?) ([2-9TJQKA][♠♥♦♣shdc])\s+(?:and\s+)?([2-9TJQKA][♠♥♦♣shdc])',
);
final _loss = RegExp(r'\b(?:lose|loses)\b', caseSensitive: false);
const _suits = {'♠': 's', '♥': 'h', '♦': 'd', '♣': 'c'};
String _card(String token) => token[0] + (_suits[token[1]] ?? token[1]);
final _deck = {
  for (final rank in pokerRanks.split(''))
    for (final suit in 'shdc'.split('')) '$rank$suit',
};

int _numberValue(String text) =>
    int.tryParse(text) ??
    const [
      'zero',
      'one',
      'two',
      'three',
      'four',
      'five',
      'six',
      'seven',
      'eight',
      'nine',
      'ten',
      'eleven',
      'twelve',
      'thirteen',
      'fourteen',
      'fifteen',
    ].indexOf(text.toLowerCase());

CatalogOutsAuditV1 auditCatalogOutsV1(Iterable<CatalogTask> rows) {
  final findings = <String, String>{};
  final checked = <String>{};
  final unmodelled = <String>{};
  for (final row in rows) {
    final task = row.task;
    final runner = task.runner;
    final table = runner.table;
    final facts = CatalogPokerFacts(table);
    if (facts.board.length != 3 && facts.board.length != 4) continue;
    final liveOpponents = table.seats.where(
      (seat) => !seat.isHero && seat.isOccupied && !seat.isFolded,
    );
    final opponent = liveOpponents.singleOrNull;
    final holes = opponent?.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp
        ? physicalCards(opponent!.holeCards)
        : const <String>[];
    final question = catalogQuestion(task);
    final pair = _statedCards.firstMatch('${runner.caption} $question');
    final range = [
      if (pair != null)
        [_card(pair[1]!), _card(pair[2]!)]
      else if (holes.length == 2)
        holes,
      if (pair == null &&
          holes.isEmpty &&
          opponent != null &&
          _nonHeartKingQueen.hasMatch(runner.caption))
        for (final kingSuit in 'sdc'.split(''))
          for (final queenSuit in 'sdc'.split(''))
            ['K$kingSuit', 'Q$queenSuit'],
    ];
    final canCompare =
        facts.complete && facts.board.length == 4 && range.isNotEmpty;
    final clean = canCompare
        ? catalogCleanOutsV1(
            hero: facts.hero,
            board: facts.board,
            completionCards: _deck,
            opponentRange: range,
          )
        : null;
    final assumeCompletions = _assumedCompletions.hasMatch(
      '${runner.caption} $question',
    );
    void check(String surface, String quote, RegExpMatch? match, int count) {
      final key = '${task.taskId}|$surface';
      final explicitWinClaim =
          match != null &&
          (match[2] != null || !match[3]!.toLowerCase().startsWith('out'));
      final onlyCompletion =
          assumeCompletions ||
          !explicitWinClaim &&
              (!canCompare && facts.board.length == 3 ||
                  _rawDraw.hasMatch('${runner.caption} $quote'));
      if (clean == null && !onlyCompletion) {
        unmodelled.add(task.taskId);
        return;
      }
      var calculated = onlyCompletion ? facts.completionCards : clean!;
      final suit = match == null
          ? null
          : _suitWin.firstMatch(match[0]!.toLowerCase());
      if (suit != null) {
        calculated = calculated.where((card) => card[1] == suit[1]![0]).toSet();
      }
      checked.add(task.taskId);
      if (count != calculated.length) {
        findings['$key|${match?.group(0)?.toLowerCase() ?? count}'] =
            '“$quote” → $count claimed, ${calculated.length} calculated '
            '(${calculated.join(', ')})';
      }
    }

    final countQuestion = RegExp(
      r'\bhow many\b.*\bouts?\b',
      caseSensitive: false,
    ).hasMatch(question);
    final copy = <String, String>{
      'caption': runner.caption,
      for (final option in runner.options)
        'feedback ${option.id}': option.feedbackReason,
      for (final option in runner.options.where((option) => option.isCorrect))
        'correct option ${option.id}': option.label,
    };
    for (final entry in copy.entries) {
      for (final sentence in entry.value.split(RegExp(r'(?<=[.!?])\s+'))) {
        // Contrasts such as "seven, not nine" are not two asserted counts.
        for (final match in _claim.allMatches(sentence)) {
          if (RegExp(
            r'\b(?:not|up to)\s+$',
            caseSensitive: false,
          ).hasMatch(sentence.substring(0, match.start))) {
            continue;
          }
          if (match[3]!.toLowerCase() == 'rivers' && match[2] == null) continue;
          if (facts.completionCards.isEmpty ||
              (match[3]!.contains('44') || match[3]!.contains('46')) &&
                  _loss.hasMatch(sentence.substring(match.end))) {
            continue;
          }
          check(entry.key, sentence, match, _numberValue(match[1]!));
        }
        if (countQuestion && entry.key.startsWith('correct option')) {
          final value = int.tryParse(sentence.trim());
          if (value != null)
            check(entry.key, '${runner.question} $question', null, value);
        }
      }
    }
  }
  return (findings: findings, checked: checked, unmodelled: unmodelled);
}
