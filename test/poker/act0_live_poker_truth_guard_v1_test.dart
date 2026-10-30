// Live-catalog poker-truth guard for the English Act0 Academy (issue #334).
//
// Every check enumerates `Act0ShellStateV1.sample`, decides per task whether
// the authored state carries enough information to prove the rule, and
// records the task as checked, excluded (with a reason) or violating. Hands
// are scored with the vendored poker_solver, whose ranking is pinned by
// poker_solver_standard_ranking_v1_test.dart.
//
// The integrated candidate has no known-failure exclusions. The frozen #334
// registry is a resolved-finding coverage contract, not permission to skip.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

class _Ref {
  _Ref(this.worldId, this.task);

  final String worldId;
  final Act0LessonTaskV1 task;

  String get id => task.taskId;
  Act0RunnerStateV1 get runner => task.runner;
  Act0TableStateV1 get table => task.runner.table;
}

final List<_Ref> _catalog = <_Ref>[
  for (final world in Act0ShellStateV1.sample.worlds)
    for (final lesson in world.lessons)
      for (final task in lesson.taskList) _Ref(world.worldId, task),
];

// Empty by contract: a new violation must be fixed or the candidate held.
const Map<String, String> _knownMaterialFails = <String, String>{};

// ---------------------------------------------------------------------------
// Card helpers.

const _rankOrder = '23456789TJQKA';

String? _solverCard(Act0CardStateV1 card) {
  var rank = card.rank.trim().toUpperCase();
  if (rank == '10') rank = 'T';
  final suit = card.suit.trim().toLowerCase();
  const suits = {'s': 's', 'h': 'h', 'd': 'd', 'c': 'c'};
  if (rank.length != 1 || !_rankOrder.contains(rank) || suits[suit] == null) {
    return null;
  }
  return '$rank${suits[suit]}';
}

int _rankValue(String rank) => _rankOrder.indexOf(rank) + 2;

class _Participant {
  _Participant(this.id, this.label, this.cards, this.cardIds);

  final String id; // 'hero' or seat id
  final String label; // 'Hero' or seat label
  final List<String> cards;
  final List<String> cardIds;
}

/// Hero plus every face-up, live opponent with two readable cards.
List<_Participant> _participants(Act0TableStateV1 table) {
  final out = <_Participant>[];
  final hero = table.heroCards.take(2).map(_solverCard).toList();
  if (hero.length == 2 && !hero.contains(null)) {
    out.add(
      _Participant('hero', 'Hero', hero.cast<String>(), ['hero_0', 'hero_1']),
    );
  }
  for (final seat in table.seats) {
    if (seat.isHero ||
        seat.isFolded ||
        !seat.isInHand ||
        seat.cardsVisibleMode != Act0CardsVisibleModeV1.faceUp ||
        seat.holeCards.length < 2) {
      continue;
    }
    final cards = seat.holeCards.take(2).map(_solverCard).toList();
    if (cards.contains(null)) continue;
    out.add(
      _Participant(seat.seatId, seat.seatLabel, cards.cast<String>(), [
        '${seat.seatId}_0',
        '${seat.seatId}_1',
      ]),
    );
  }
  return out;
}

class _Showdown {
  _Showdown(this.board, this.players, this.hands);

  final List<String> board;
  final List<_Participant> players;
  final List<Hand> hands;

  Set<String> get winnerIds {
    final winners = Hand.winners(hands);
    return {
      for (var i = 0; i < players.length; i++)
        if (winners.contains(hands[i])) players[i].id,
    };
  }

  Set<String> bestFiveIds(int index) {
    final ids = <String, String>{
      for (var i = 0; i < board.length; i++) board[i]: 'board_$i',
      for (var i = 0; i < 2; i++)
        players[index].cards[i]: players[index].cardIds[i],
    };
    return {
      for (final card in hands[index].cards) ids["${card.value}${card.suit}"]!,
    };
  }
}

/// A complete, duplicate-free showdown, or the reason it cannot be scored.
Object _showdown(Act0TableStateV1 table) {
  if (table.boardCards.length != 5) return 'board is not complete';
  final board = table.boardCards.map(_solverCard).toList();
  if (board.contains(null)) return 'board card unreadable';
  final players = _participants(table);
  if (players.isEmpty) return 'no readable hand';
  final all = [...board.cast<String>(), for (final p in players) ...p.cards];
  if (all.toSet().length != all.length) {
    return 'duplicate physical card (#333 D5)';
  }
  return _Showdown(board.cast<String>(), players, [
    for (final p in players)
      Hand.solveHand([...board.cast<String>(), ...p.cards]),
  ]);
}

/// Category word for a scored hand, in the vocabulary the copy uses.
String _category(Hand hand) {
  if (hand.name == 'Straight Flush') {
    return hand.descr == 'Royal Flush' ? 'royal flush' : 'straight flush';
  }
  return switch (hand.name) {
    'Four of a Kind' => 'four of a kind',
    'Full House' => 'full house',
    'Flush' => 'flush',
    'Straight' => 'straight',
    'Three of a Kind' => 'three of a kind',
    'Two Pair' => 'two pair',
    'Pair' => 'pair',
    _ => 'high card',
  };
}

const _categoryWords = <String, String>{
  'royal flush': 'royal flush',
  'straight flush': 'straight flush',
  'four of a kind': 'four of a kind',
  'quads': 'four of a kind',
  'full house': 'full house',
  'flush': 'flush',
  'straight': 'straight',
  'three of a kind': 'three of a kind',
  'trips': 'three of a kind',
  'set': 'three of a kind',
  'two pair': 'two pair',
};

// ---------------------------------------------------------------------------
// Option classification for winner questions.

final _winnerQuestion = RegExp(
  r'who wins|stronger at showdown|which hand is stronger|which hand ranks higher|'
  r'before the pot is pushed',
  caseSensitive: false,
);

/// 'hero', a seat id, 'tie', or null when the option is not a winner claim.
String? _optionOutcome(Act0RunnerOptionV1 option, _Showdown showdown) {
  final text = '${option.id} ${option.label}'.toLowerCase();
  if (RegExp(
    r'\b(tie|split|board plays)\b|_tie\b|^tie|split_',
  ).hasMatch(text)) {
    return 'tie';
  }
  if (text.startsWith('hero') || text.contains(' hero ')) return 'hero';
  final opponents = showdown.players.where((p) => p.id != 'hero').toList();
  if (opponents.length == 1 &&
      (text.startsWith('villain') ||
          text.startsWith('${opponents.single.id}_') ||
          text.contains(' ${opponents.single.label.toLowerCase()} '))) {
    return opponents.single.id;
  }
  return null;
}

Set<String> _outcomeOf(String outcome, _Showdown s) =>
    outcome == 'tie' ? s.players.map((p) => p.id).toSet() : {outcome};

// ---------------------------------------------------------------------------
// Rule checks. Each returns violations by task id and records coverage.

class _Coverage {
  final checked = <String>{};
  final excluded = <String, String>{};
  final violations = <String, String>{};
}

final _rules = <String, _Coverage Function()>{
  'showdown_winner_key': _checkShowdownWinnerKey,
  'hero_hand_key': _checkHeroHandKey,
  'hand_claim': _checkHandClaims,
  'stated_hand_claim': _checkStatedHandClaims,
  'board_claim': _checkBoardClaims,
  'action_legality': _checkActionLegality,
  'pot_odds_wording': _checkPotOddsWording,
  'effective_stack_key': _checkEffectiveStackKey,
  'combo_count_key': _checkComboCountKey,
  'm_ratio_zone': _checkMRatioZone,
  'seat_rule_key': _checkSeatRuleKey,
  'deterministic_tier': _checkDeterministicTier,
  'pre_answer_reveal': _checkPreAnswerReveal,
  'answer_in_center_label': _checkAnswerInCenterLabel,
  'pot_label_convention': _checkPotLabelConvention,
};

_Coverage _checkShowdownWinnerKey() {
  final c = _Coverage();
  for (final ref in _catalog) {
    final s = _showdown(ref.table);
    if (s is! _Showdown) {
      if (ref.table.boardCards.length == 5) c.excluded[ref.id] = s as String;
      continue;
    }
    if (s.players.length < 2) {
      c.excluded[ref.id] = 'no face-up opponent';
      continue;
    }
    final keyed = ref.runner.options.where((o) => o.isCorrect).toList();
    final outcome = keyed.length == 1 ? _optionOutcome(keyed.single, s) : null;
    if (!_winnerQuestion.hasMatch(ref.runner.question) || outcome == null) {
      c.excluded[ref.id] = 'question is not a winner claim';
      continue;
    }
    c.checked.add(ref.id);
    final keyedWinners = _outcomeOf(outcome, s);
    if (!_sameSet(keyedWinners, s.winnerIds)) {
      c.violations[ref.id] = 'keyed $keyedWinners, true winners ${s.winnerIds}';
    }
  }
  return c;
}

_Coverage _checkHeroHandKey() {
  final c = _Coverage();
  for (final ref in _catalog) {
    if (!RegExp(
      r'what does hero have',
      caseSensitive: false,
    ).hasMatch(ref.runner.question)) {
      continue;
    }
    final s = _showdown(ref.table);
    if (s is! _Showdown) {
      c.excluded[ref.id] = s as String;
      continue;
    }
    final keyed = ref.runner.options.firstWhere((o) => o.isCorrect);
    final claimed = _claimedCategory(keyed.label);
    if (claimed == null) {
      c.excluded[ref.id] = 'keyed label names no category';
      continue;
    }
    c.checked.add(ref.id);
    final actual = _category(
      s.hands[s.players.indexWhere((p) => p.id == 'hero')],
    );
    if (claimed != actual)
      c.violations[ref.id] = 'keyed $claimed, hero has $actual';
  }
  return c;
}

String? _claimedCategory(String text) {
  final lower = text.toLowerCase();
  for (final entry in _categoryWords.entries) {
    if (RegExp('\\b${entry.key}\\b').hasMatch(lower)) return entry.value;
  }
  return null;
}

/// "<subject> ... make(s)/into/has/flopped <category>" in feedback, steps,
/// caption and hint, where the subject resolves to one scored player.
_Coverage _checkHandClaims() {
  final c = _Coverage();
  final verbs = r'(?:makes?|turns? \w+ into|into|has|flopped|reaches|to make)';
  final words = _categoryWords.keys.join('|');
  final claim = RegExp(
    '(Hero|Villain|You|[A-Z]{2,3}|[AKQJT2-9]-[AKQJT2-9])\\b[^.]{0,40}?\\b$verbs\\s+(?:an? )?($words)\\b',
  );
  for (final ref in _catalog) {
    final s = _showdown(ref.table);
    if (s is! _Showdown || s.players.length < 2) continue;
    c.checked.add(ref.id);
    for (final text in _authoredTexts(ref.runner)) {
      for (final m in claim.allMatches(text)) {
        final who = _resolveSubject(m.group(1)!, s);
        if (who == null) continue;
        final claimed = _categoryWords[m.group(2)!]!;
        final actual = _category(s.hands[who]);
        final ok =
            claimed == actual ||
            (claimed == 'straight flush' && actual == 'royal flush');
        if (!ok) {
          c.violations[ref.id] =
              '"${m.group(0)}": ${s.players[who].label} has $actual';
        }
      }
    }
  }
  return c;
}

int? _resolveSubject(String subject, _Showdown s) {
  final opponents = [
    for (var i = 0; i < s.players.length; i++)
      if (s.players[i].id != 'hero') i,
  ];
  if (subject == 'Hero' || subject == 'You') {
    return s.players.indexWhere((p) => p.id == 'hero');
  }
  if (subject == 'Villain')
    return opponents.length == 1 ? opponents.single : null;
  if (subject.contains('-')) {
    final ranks = subject.split('-')..sort();
    for (var i = 0; i < s.players.length; i++) {
      final held = s.players[i].cards.map((c) => c[0]).toList()..sort();
      if (held.join() == ranks.join()) return i;
    }
    return null;
  }
  final bySeat = s.players.indexWhere((p) => p.label == subject);
  return bySeat < 0 ? null : bySeat;
}

List<String> _authoredTexts(Act0RunnerStateV1 runner) => [
  runner.caption,
  runner.hint,
  for (final step in runner.teachingSteps) step.body,
  for (final option in runner.options) option.feedbackReason,
];

/// Rank-only claims about a hand the caption states ("Hero holds A-Q").
/// Only rank multiplicity and overcards are judged, never suits.
_Coverage _checkStatedHandClaims() {
  final c = _Coverage();
  final stated = RegExp(r'Hero (?:holds|has|shows) ([AKQJT2-9])-([AKQJT2-9])');
  for (final ref in _catalog) {
    final m = stated.firstMatch(ref.runner.caption);
    if (m == null || ref.table.boardCards.length < 3) continue;
    final board = ref.table.boardCards.map((x) => _solverCard(x)?[0]).toList();
    if (board.contains(null)) {
      c.excluded[ref.id] = 'board card unreadable';
      continue;
    }
    c.checked.add(ref.id);
    final hole = [m.group(1)!, m.group(2)!];
    final hand = '${hole[0]}-${hole[1]}';
    final boardRanks = board.cast<String>().map(_rankValue).toList();
    final holeRanks = hole.map(_rankValue).toList();
    final counts = <int, int>{};
    for (final r in [...holeRanks, ...boardRanks]) {
      counts[r] = (counts[r] ?? 0) + 1;
    }
    final pairCount = counts.values.where((n) => n >= 2).length;
    final overcards = holeRanks.where(
      (r) => r > boardRanks.reduce((a, b) => a > b ? a : b),
    );
    final texts = [ref.runner.hint, ..._authoredTexts(ref.runner)];
    for (final text in texts) {
      final subjectless = text == ref.runner.hint;
      bool about(String pattern) => RegExp(
        subjectless ? '(^|$hand[^.]*)$pattern' : '$hand[^.]*$pattern',
        caseSensitive: false,
      ).hasMatch(text);
      if (about(r'\btwo pair') && pairCount < 2) {
        c.violations[ref.id] = '$hand on the board is not two pair';
      }
      if (about(r'\btwo overcards') && overcards.length != 2) {
        c.violations[ref.id] =
            '$hand has ${overcards.length} overcard(s) to the board';
      }
    }
  }
  return c;
}

/// "With R-R-R-R on board": every named rank must be on the board.
_Coverage _checkBoardClaims() {
  final c = _Coverage();
  final claim = RegExp(
    r'[Ww]ith ((?:[AKQJT2-9]-)+[AKQJT2-9]) on (?:the )?board',
  );
  for (final ref in _catalog) {
    final board = ref.table.boardCards.map((x) => _solverCard(x)?[0]).toSet();
    for (final text in _authoredTexts(ref.runner)) {
      for (final m in claim.allMatches(text)) {
        c.checked.add(ref.id);
        final missing = m.group(1)!.split('-').where((r) => !board.contains(r));
        if (missing.isNotEmpty) {
          c.violations[ref.id] = '"${m.group(0)}" but board lacks $missing';
        }
      }
    }
  }
  // Rank spans explicitly attributed to the board remain checkable after
  // correcting a combined hole-card/board explanation.
  final attributed = RegExp(r'((?:[AKQJT2-9]-)+[AKQJT2-9]) on (?:the )?board');
  for (final ref in _catalog) {
    final board = ref.table.boardCards.map((x) => _solverCard(x)?[0]).toSet();
    for (final text in _authoredTexts(ref.runner)) {
      for (final m in attributed.allMatches(text)) {
        c.checked.add(ref.id);
        if (m.group(1)!.split('-').any((r) => !board.contains(r))) {
          c.violations[ref.id] = 'named board rank absent: ${m.group(0)}';
        }
      }
    }
  }
  return c;
}

/// Postflop: nobody calls, raises or folds before a bet on that street.
/// Preflop: only the big blind can face a price of 0.
_Coverage _checkActionLegality() {
  final c = _Coverage();
  final streetLine = RegExp(r'^(Flop|Turn|River)\b:?\s*(.*)$');
  final aggressive = RegExp(
    r'\b(bets?|barrels?|opens?|shoves?|jams?|all-in)\b',
    caseSensitive: false,
  );
  final response = RegExp(r'\b(calls|raises|folds)\b', caseSensitive: false);
  for (final ref in _catalog) {
    final table = ref.table;
    var street = 'Preflop';
    var betMade = false;
    if (table.actionTrail.isNotEmpty) c.checked.add(ref.id);
    for (final item in table.actionTrail) {
      var rest = item.label;
      final m = streetLine.firstMatch(item.label);
      if (m != null) {
        street = m.group(1)!;
        betMade = false;
        rest = m.group(2)!;
      }
      if (street == 'Preflop') continue;
      if (aggressive.hasMatch(rest)) {
        betMade = true;
      } else if (response.hasMatch(rest) && !betMade) {
        c.violations[ref.id] = '"${item.label}" before any $street bet';
      }
    }
    final hero = table.seats.where((s) => s.isHero).firstOrNull;
    final toCall = _bb(table.toCallLabel);
    if (table.streetLabel == 'Preflop' && hero != null && toCall != null) {
      c.checked.add(ref.id);
      if (!hero.isBigBlind && toCall == 0) {
        c.violations[ref.id] = '${hero.seatLabel} shows "To call 0 BB" preflop';
      }
    }
  }
  return c;
}

double? _bb(String label) {
  final m = RegExp(r'(-?\d+(?:\.\d+)?)\s*BB').firstMatch(label);
  return m == null ? null : double.parse(m.group(1)!);
}

/// "Risk X to win a pot that is only Y" must count the villain's bet in Y.
_Coverage _checkPotOddsWording() {
  final c = _Coverage();
  final framing = [
    RegExp(
      r'spends (\d+(?:\.\d+)?) BB to win a pot that is only (\d+(?:\.\d+)?) BB',
    ),
    RegExp(
      r'Pot (\d+(?:\.\d+)?) BB is not enough to justify risking (\d+(?:\.\d+)?) BB',
    ),
  ];
  final equity = RegExp(
    r'(\d+(?:\.\d+)?) BB call into a (\d+(?:\.\d+)?) BB [a-z ]*pot needs about (\d+)% equity',
  );
  final riskToWin = RegExp(
    r'risk(?:s|ing)? (\d+(?:\.\d+)?) BB to win (\d+(?:\.\d+)?) BB[^.]*?needs? about (\d+)% equity',
  );
  for (final ref in _catalog) {
    final toCall = _bb(ref.table.toCallLabel);
    final pot = _bb(ref.table.potLabel);
    for (final text in _authoredTexts(ref.runner)) {
      for (final m in framing[0].allMatches(text)) {
        c.checked.add(ref.id);
        if (double.parse(m.group(2)!) == pot &&
            toCall == double.parse(m.group(1)!)) {
          c.violations[ref.id] =
              '"${m.group(0)}" leaves out the ${m.group(1)} BB bet';
        }
      }
      for (final m in framing[1].allMatches(text)) {
        c.checked.add(ref.id);
        if (double.parse(m.group(1)!) == pot &&
            toCall == double.parse(m.group(2)!)) {
          c.violations[ref.id] =
              '"${m.group(0)}" leaves out the ${m.group(2)} BB bet';
        }
      }
      for (final m in riskToWin.allMatches(text)) {
        c.checked.add(ref.id);
        final risk = double.parse(m.group(1)!);
        final win = double.parse(m.group(2)!);
        final required = 100 * risk / (win + risk);
        if ((required - int.parse(m.group(3)!)).abs() > 1.5) {
          c.violations[ref.id] =
              '"${m.group(0)}" but required is ${required.toStringAsFixed(1)}%';
        }
      }
      for (final m in equity.allMatches(text)) {
        c.checked.add(ref.id);
        final call = double.parse(m.group(1)!);
        final before = double.parse(m.group(2)!);
        final required = 100 * call / (before + call + call);
        if ((required - int.parse(m.group(3)!)).abs() > 1.5) {
          c.violations[ref.id] =
              '"${m.group(0)}" but required is ${required.toStringAsFixed(1)}%';
        }
      }
    }
  }
  return c;
}

_Coverage _checkEffectiveStackKey() {
  final c = _Coverage();
  final stacks = RegExp(r'Hero has (\d+) BB\. Villain has (\d+) BB');
  for (final ref in _catalog) {
    final m = stacks.firstMatch(ref.runner.caption);
    if (m == null) continue;
    c.checked.add(ref.id);
    final effective = [
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
    ].reduce((a, b) => a < b ? a : b);
    final keyed = ref.runner.options.firstWhere((o) => o.isCorrect).label;
    if (keyed.trim() != '$effective BB') {
      c.violations[ref.id] = 'keyed "$keyed", effective stack is $effective BB';
    }
  }
  return c;
}

final _comboQuestion = RegExp(
  r'how many combos|appears? more often|expect more often|'
  r'what decides a showdown|what wins at showdown',
  caseSensitive: false,
);

/// Preflop combinations before blockers: pair 6, suited 4, offsuit 12,
/// unpaired family 16.
int? _comboWeight(String label) {
  final l = label.toLowerCase();
  if (l.startsWith('pocket ')) return 6;
  if (RegExp(r'^[akqjt2-9]-[akqjt2-9] suited').hasMatch(l)) return 4;
  if (RegExp(r'^[akqjt2-9]-[akqjt2-9] offsuit').hasMatch(l)) return 12;
  final pair = RegExp(r'^([akqjt2-9])-([akqjt2-9])\b').firstMatch(l);
  if (pair != null) return pair.group(1) == pair.group(2) ? 6 : 16;
  return null;
}

_Coverage _checkComboCountKey() {
  final c = _Coverage();
  final count = RegExp(r'How many combos does ([AKQJT2-9])-([AKQJT2-9]) have');
  for (final ref in _catalog) {
    final q = ref.runner.question;
    final keyed = ref.runner.options.where((o) => o.isCorrect).firstOrNull;
    if (keyed == null) continue;
    final m = count.firstMatch(q);
    if (m != null) {
      c.checked.add(ref.id);
      final expected = m.group(1) == m.group(2) ? 6 : 16;
      if (!keyed.label.startsWith('$expected combos')) {
        c.violations[ref.id] = 'keyed "${keyed.label}", expected $expected';
      }
      continue;
    }
    if (!RegExp(r'appears? more often|expect more often').hasMatch(q)) continue;
    final weights = {
      for (final o in ref.runner.options)
        if (_comboWeight(o.label) != null) o.id: _comboWeight(o.label)!,
    };
    if (weights.length < 2) {
      c.excluded[ref.id] = 'options are not combo families';
      continue;
    }
    c.checked.add(ref.id);
    final top = weights.values.reduce((a, b) => a > b ? a : b);
    final keyedWeight = weights[keyed.id];
    final unique = weights.values.where((w) => w == top).length == 1;
    if (unique && keyedWeight != top) {
      c.violations[ref.id] =
          'keyed "${keyed.label}" ($keyedWeight) is not the heaviest family ($top)';
    }
  }
  return c;
}

/// M = stack / (SB + BB + antes) <= stack / 1.5. Three zones: green M >= 20,
/// yellow 10 <= M < 20, red M < 10. Antes only lower M, so a claim is
/// refuted when even the ante-free M falls outside the named zone.
_Coverage _checkMRatioZone() {
  final c = _Coverage();
  final claim = RegExp(r'(\d+(?:\.\d+)?) BB in (green|yellow|red) zone');
  for (final ref in _catalog) {
    for (final text in [ref.runner.caption, ref.runner.hint]) {
      for (final m in claim.allMatches(text)) {
        c.checked.add(ref.id);
        final maxM = double.parse(m.group(1)!) / 1.5;
        final zone = m.group(2)!;
        final ok = switch (zone) {
          'green' => maxM >= 20,
          'yellow' => maxM >= 10,
          _ => true,
        };
        if (!ok) {
          c.violations[ref.id] =
              '${m.group(1)} BB gives M <= ${maxM.toStringAsFixed(1)}, not $zone';
        }
      }
    }
  }
  final explicit = RegExp(
    r'(\d+(?:\.\d+)?) BB.*no antes, M = (\d+(?:\.\d+)?): (green|yellow|red)',
  );
  for (final ref in _catalog) {
    for (final text in _authoredTexts(ref.runner)) {
      final m = explicit.firstMatch(text);
      if (m == null) continue;
      c.checked.add(ref.id);
      final expected = double.parse(m.group(1)!) / 1.5;
      final stated = double.parse(m.group(2)!);
      final zone = expected >= 20
          ? 'green'
          : expected >= 10
          ? 'yellow'
          : 'red';
      if ((expected - stated).abs() > 0.001 || m.group(3) != zone) {
        c.violations[ref.id] =
            'no-ante M arithmetic or three-zone claim contradicts stack';
      }
    }
  }
  return c;
}

/// Seat-rule questions whose answer is fixed by the rules of the game.
_Coverage _checkSeatRuleKey() {
  final c = _Coverage();
  final rules = <RegExp, String>{
    RegExp(r'blind posts 1 BB|sets the 1 BB'): 'bb',
    RegExp(r'blind posts 0\.5 BB'): 'sb',
    RegExp(r'acts first preflop', caseSensitive: false): 'utg',
    RegExp(
      r'last postflop actor|latest after the flop|acts last after the flop',
      caseSensitive: false,
    ): 'btn',
    RegExp(r'^(Which seat is the Button|Tap the Button)'): 'btn',
  };
  for (final ref in _catalog) {
    final keyed = ref.runner.options.where((o) => o.isCorrect).firstOrNull;
    if (keyed == null) continue;
    for (final rule in rules.entries) {
      if (!rule.key.hasMatch(ref.runner.question)) continue;
      c.checked.add(ref.id);
      final seat = (keyed.seatId ?? keyed.id).toLowerCase();
      final ok =
          seat == rule.value ||
          keyed.label.toUpperCase().startsWith(rule.value.toUpperCase());
      if (!ok) {
        c.violations[ref.id] =
            'keyed "${keyed.label}", rules give ${rule.value.toUpperCase()}';
      }
    }
  }
  return c;
}

/// Questions with one factual answer grade every other option `wrong`.
_Coverage _checkDeterministicTier() {
  final c = _Coverage();
  const factualLessons = {'hand_rankings_table', 'showdown_winning'};
  for (final world in Act0ShellStateV1.sample.worlds) {
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        final runner = task.runner;
        final factual =
            task.resolvedTaskFamily == Act0TaskFamilyV1.counting ||
            factualLessons.contains(lesson.lessonId) ||
            _winnerQuestion.hasMatch(runner.question) ||
            _comboQuestion.hasMatch(runner.question);
        if (!factual || task.phase == Act0LessonPhaseV1.theory) continue;
        c.checked.add(task.taskId);
        for (final o in runner.options) {
          if (!o.isCorrect && o.quality != Act0FeedbackQualityV1.wrong) {
            c.violations[task.taskId] = '"${o.label}" graded ${o.quality.name}';
          }
        }
      }
    }
  }
  return c;
}

/// Before a winner question is answered, the table must not light the
/// winner's cards while leaving the loser's dark.
_Coverage _checkPreAnswerReveal() {
  final c = _Coverage();
  for (final ref in _catalog) {
    if (!_winnerQuestion.hasMatch(ref.runner.question)) continue;
    final s = _showdown(ref.table);
    if (s is! _Showdown || s.players.length < 2) {
      c.excluded[ref.id] = s is String ? s : 'no face-up opponent';
      continue;
    }
    final keyed = ref.runner.options.where((o) => o.isCorrect).toList();
    if (keyed.length != 1 || _optionOutcome(keyed.single, s) == null) {
      c.excluded[ref.id] = 'keyed option is not a winner claim';
      continue;
    }
    c.checked.add(ref.id);
    final lit = ref.table.highlightedCardIds.toSet();
    final winners = s.winnerIds;
    bool holeLit(_Participant p) => p.cardIds.any(lit.contains);
    if (winners.length == 1) {
      final winner = s.players.firstWhere((p) => winners.contains(p.id));
      final losersDark = s.players
          .where((p) => !winners.contains(p.id))
          .every((p) => !holeLit(p));
      if (holeLit(winner) && losersDark) {
        c.violations[ref.id] = 'only ${winner.label}\'s winning cards are lit';
      }
    } else {
      final shared = s.bestFiveIds(0);
      if (lit.isNotEmpty && _sameSet(lit, shared)) {
        c.violations[ref.id] = 'the shared best five is lit before answering';
      }
    }
  }
  return c;
}

/// The decision-time table center label must not state the keyed answer,
/// or, for a winner question, which hand wins. Whether the runner shows the
/// label depends on its clue gate, so this checks the authored source.
_Coverage _checkAnswerInCenterLabel() {
  final c = _Coverage();
  for (final world in Act0ShellStateV1.sample.worlds) {
    for (final lesson in world.lessons) {
      for (final task in lesson.taskList) {
        final runner = task.runner;
        if (task.phase == Act0LessonPhaseV1.theory) continue;
        final keyed = runner.options.where((o) => o.isCorrect).toList();
        if (keyed.length != 1 || runner.options.length < 2) continue;
        final center = runner.table.centerLabel.toLowerCase();
        if (center.trim().isEmpty) continue;
        c.checked.add(task.taskId);
        bool names(String label) =>
            label.length >= 3 &&
            RegExp(
              '(?<![\\w-])${RegExp.escape(label.toLowerCase())}(?![\\w-])',
            ).hasMatch(center);
        final answer = keyed.single.label.trim();
        final others = runner.options
            .where((o) => !o.isCorrect)
            .map((o) => o.label.trim());
        if (names(answer) && !others.any(names)) {
          c.violations[task.taskId] =
              'center label "${runner.table.centerLabel}" states "$answer"';
        }
        final s = _showdown(runner.table);
        if (s is _Showdown &&
            _winnerQuestion.hasMatch(runner.question) &&
            _optionOutcome(keyed.single, s) != null &&
            RegExp(r'\b(beats?|wins?)\b').hasMatch(center)) {
          c.violations[task.taskId] =
              'center label "${runner.table.centerLabel}" names the winner';
        }
      }
    }
  }
  return c;
}

/// Owner policy (#334): a displayed "Pot X BB" is the total committed at the
/// decision, including an outstanding bet. Provable only where the copy
/// itself says the bet goes "into" the displayed pot, or prices the call
/// against the displayed pot alone.
_Coverage _checkPotLabelConvention() {
  final c = _Coverage();
  final into = RegExp(
    r'bets? (\d+(?:\.\d+)?) BB into (\d+(?:\.\d+)?) BB|(\d+(?:\.\d+)?) BB call into a (\d+(?:\.\d+)?) BB',
  );
  for (final ref in _catalog) {
    final toCall = _bb(ref.table.toCallLabel);
    final pot = _bb(ref.table.potLabel);
    if (toCall == null || toCall == 0 || pot == null) continue;
    if (ref.table.streetLabel == 'Preflop') continue;
    final texts = [ref.runner.caption, ..._authoredTexts(ref.runner)];
    var evidence = false;
    for (final text in texts) {
      for (final m in into.allMatches(text)) {
        if (double.parse(m.group(2) ?? m.group(4)!) == pot) evidence = true;
      }
      if (text.contains(
            'the ${_fmt(pot)} BB pot plus the ${_fmt(toCall)} BB bet',
          ) ||
          text.contains('to win a pot that is only ${_fmt(pot)} BB') ||
          text.contains('Pot ${_fmt(pot)} BB is not enough to justify')) {
        evidence = true;
      }
    }
    final explicitInto = RegExp(
      r'bets? (\d+(?:\.\d+)?) BB into (\d+(?:\.\d+)?) BB',
    );
    final sameHandPot = RegExp(
      r'pot is (\d+(?:\.\d+)?) BB.*?now bets (\d+(?:\.\d+)?) BB',
    );
    final explicitAfter = RegExp(
      r'Pot is (\d+(?:\.\d+)?) BB after the (\d+(?:\.\d+)?) BB bet',
    );
    var hasEquation = false;
    for (final text in texts) {
      for (final m in sameHandPot.allMatches(text)) {
        hasEquation = true;
        c.checked.add(ref.id);
        final expected = double.parse(m.group(1)!) + double.parse(m.group(2)!);
        if ((pot - expected).abs() > 0.001 ||
            (toCall - double.parse(m.group(2)!)).abs() > 0.001) {
          c.violations[ref.id] =
              'current decision pot/price contradicts the explicit same-hand historical pot and new bet';
        }
      }
      for (final m in explicitInto.allMatches(text)) {
        // A previous-street line cannot price the current call.
        if ((double.parse(m.group(1)!) - toCall).abs() > 0.001) continue;
        hasEquation = true;
        c.checked.add(ref.id);
        final expected = double.parse(m.group(1)!) + double.parse(m.group(2)!);
        if ((pot - expected).abs() > 0.001) {
          c.violations[ref.id] =
              'decision pot $pot != historical pot + outstanding bet $expected';
        }
      }
      for (final m in explicitAfter.allMatches(text)) {
        hasEquation = true;
        c.checked.add(ref.id);
        if ((pot - double.parse(m.group(1)!)).abs() > 0.001 ||
            (toCall - double.parse(m.group(2)!)).abs() > 0.001) {
          c.violations[ref.id] =
              'decision pot or price contradicts explicit after-bet snapshot';
        }
      }
    }
    if (hasEquation) continue;
    if (!evidence) {
      c.excluded[ref.id] = 'pot label meaning not provable from copy';
      continue;
    }
    c.checked.add(ref.id);
    c.violations[ref.id] =
        '"${ref.table.potLabel}" is the pot before the ${_fmt(toCall)} BB bet';
  }
  return c;
}

String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';

bool _sameSet(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

// ---------------------------------------------------------------------------

void main() {
  final results = {for (final e in _rules.entries) e.key: e.value()};

  test('coverage report', () {
    final output = Platform.environment['POKER_TRUTH_LEDGER'];
    if (output != null) {
      File(output).writeAsStringSync(
        const JsonEncoder.withIndent(' ').convert([
          for (final ref in _catalog)
            for (final rule in results.entries)
              {
                'task_id': ref.id,
                'world_id': ref.worldId,
                'rule': rule.key,
                'result': rule.value.violations.containsKey(ref.id)
                    ? 'FAIL'
                    : rule.value.checked.contains(ref.id)
                    ? 'PASS'
                    : rule.value.excluded.containsKey(ref.id)
                    ? 'NEEDS_SOURCE_CONTEXT'
                    : 'NOT_APPLICABLE',
                'reason':
                    rule.value.violations[ref.id] ??
                    rule.value.excluded[ref.id],
              },
        ]),
      );
    }
    expect(_catalog, hasLength(367), reason: 'live English catalog size');
    final lines = <String>['task universe: ${_catalog.length}'];
    for (final e in results.entries) {
      lines.add(
        '${e.key}: checked=${e.value.checked.length} '
        'excluded=${e.value.excluded.length} '
        'violations=${e.value.violations.length}',
      );
    }
    // ignore: avoid_print
    print(lines.join('\n'));
    // Showdown denominators are pinned so silent drift is visible.
    expect(results['showdown_winner_key']!.checked, hasLength(6));
    expect(results['hand_claim']!.checked, hasLength(18));
  });

  test('all 49 historical #334 findings are resolved without exclusions', () {
    final actual = <String, String>{
      for (final e in results.entries)
        for (final v in e.value.violations.entries)
          '${e.key}|${v.key}': v.value,
    };
    final historical =
        jsonDecode(
              File(
                'test/poker/fixtures/resolved_334_v1.json',
              ).readAsStringSync(),
            )
            as Map;
    expect(historical.length, 49);
    expect(
      historical.keys.map((k) => (k as String).split('|').last).toSet(),
      hasLength(39),
    );
    for (final key in historical.keys.cast<String>()) {
      final split = key.split('|');
      expect(
        results[split.first]!.checked,
        contains(split.last),
        reason:
            'A resolved historical finding must stay proved, not excluded: $key',
      );
      expect(
        results[split.first]!.violations.containsKey(split.last),
        isFalse,
        reason: key,
      );
    }
    final unexpected = actual.keys.toSet().difference(
      _knownMaterialFails.keys.toSet(),
    );
    final stale = _knownMaterialFails.keys.toSet().difference(
      actual.keys.toSet(),
    );
    expect(
      unexpected.map((k) => '$k: ${actual[k]}').toList(),
      isEmpty,
      reason: 'new poker-truth violation; fix the content, do not ledger it',
    );
    expect(
      stale,
      isEmpty,
      reason:
          'ledger entry no longer reproduces; remove it and unskip the rule',
    );
  });

  for (final rule in _rules.keys) {
    final known = _knownMaterialFails.entries
        .where((e) => e.key.startsWith('$rule|'))
        .map((e) => '${e.key.split('|').last} (${e.value})')
        .toList();
    test(
      'rule $rule has no violations',
      () => expect(results[rule]!.violations, isEmpty),
      skip: known.isEmpty ? false : 'KNOWN_MATERIAL_FAIL: ${known.join(', ')}',
    );
  }
}
