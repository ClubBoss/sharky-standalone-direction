// PKR-06 / PKR-08 source oracle over the authored Act0 tables (MACHINE).
//
// Independent of the Runner: it reads only supplied stacks, bets, trail
// amounts, seat flags and cards. It never infers a missing stack, card,
// contribution or winner; anything it cannot derive is UNPROVED, not PASS.
// Hand strength uses the accepted PKR-07 ranking (`poker_solver`) and is only
// applied to real source cards. This is not a betting engine.
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

enum PotTruthVerdictV1 { proved, unproved, contradiction }

class PotTruthFindingV1 {
  const PotTruthFindingV1(this.taskId, this.rule, this.detail);
  final String taskId;
  final String rule;
  final String detail;
  String get key => '$taskId|$rule|$detail';
  @override
  String toString() => key;
}

/// Preflop action order for the six-max catalog.
const act0PotTruthPreflopOrderV1 = <String>[
  'UTG',
  'HJ',
  'CO',
  'BTN',
  'SB',
  'BB',
];

final _amount = RegExp(r'^(\d+(?:\.\d+)?)\s*BB$', caseSensitive: false);
final _trailAmount = RegExp(r'(\d+(?:\.\d+)?)\s*BB', caseSensitive: false);
final _actor = RegExp(
  r'^(?:(?:Preflop|Flop|Turn|River):\s*)?(UTG|HJ|CO|BTN|SB|BB|Hero)\b\s*(.*)$',
  caseSensitive: false,
);

double? potTruthBbV1(String? label) {
  final m = _amount.firstMatch(label?.trim() ?? '');
  return m == null ? null : double.parse(m.group(1)!);
}

class PotTruthActionV1 {
  const PotTruthActionV1(this.actor, this.verb, this.amount, this.raw);
  final String actor; // seat label in upper case
  final String verb; // fold | all_in | call | raise_to | bet | total | post
  final double? amount;
  final String raw;
}

String _heroActor(Act0TableStateV1 table) {
  for (final seat in table.seats) {
    if (seat.isHero) return seat.seatLabel.trim().toUpperCase();
  }
  return '';
}

/// Parses one trail label into an attributed action. Labels that do not name
/// a single seat (for example "CO and BB: 30 BB each to side") are ignored.
PotTruthActionV1? potTruthParseActionV1(Act0TableStateV1 table, String label) {
  final m = _actor.firstMatch(label.trim());
  if (m == null) return null;
  var actor = m.group(1)!.toUpperCase();
  if (actor == 'HERO') actor = _heroActor(table);
  final rest = m.group(2)!.toLowerCase();
  if (rest.startsWith('and ')) return null;
  final amount = double.tryParse(_trailAmount.firstMatch(rest)?.group(1) ?? '');
  final String verb;
  if (rest.contains('fold')) {
    verb = 'fold';
  } else if (rest.contains('shove') || rest.contains('all-in')) {
    verb = 'all_in';
  } else if (rest.contains('contributes') && rest.contains('total')) {
    verb = 'total';
  } else if (rest.startsWith('raises to')) {
    verb = 'raise_to';
  } else if (rest.startsWith('calls')) {
    verb = 'call';
  } else if (rest.startsWith('bets')) {
    verb = 'bet';
  } else if (rest.startsWith('blind') || rest.startsWith('posts')) {
    verb = 'post';
  } else {
    return null;
  }
  return PotTruthActionV1(actor, verb, amount, label);
}

bool _live(Act0SeatStateV1 seat) => seat.isInHand && !seat.isFolded;

/// PKR-06: stacks, all-in, contribution caps, eligibility and side pots.
/// Applies to every table that supplies a stack, an all-in or a pot split.
List<PotTruthFindingV1> pkr06FindingsV1(String taskId, Act0TableStateV1 t) {
  final out = <PotTruthFindingV1>[];
  void bad(String rule, String detail) =>
      out.add(PotTruthFindingV1(taskId, rule, detail));
  final seats = {for (final s in t.seats) s.seatLabel.trim().toUpperCase(): s};
  final actions = [
    for (final item in t.actionTrail)
      if (potTruthParseActionV1(t, item.label) case final a?) a,
  ];

  for (final s in t.seats) {
    for (final (name, label) in [
      ('stack', s.stackLabel),
      ('bet', s.currentBetLabel),
    ]) {
      if (label != null && potTruthBbV1(label) == null) {
        bad('amount_unparsed', '${s.seatId}.$name=$label');
      }
    }
  }

  // An explicit fold in the source cannot leave that player live, because a
  // live seat is eligible to win chips.
  for (final a in actions.where((a) => a.verb == 'fold')) {
    final seat = seats[a.actor];
    if (seat != null && _live(seat)) bad('folded_seat_live', a.actor);
  }

  final allIns = actions.where((a) => a.verb == 'all_in').toList();
  for (final a in allIns) {
    final stack = potTruthBbV1(seats[a.actor]?.stackLabel);
    if (stack != null && stack > 0) {
      bad('all_in_with_chips_behind', '${a.actor} behind=$stack');
    }
  }
  for (final s in t.seats) {
    final stack = potTruthBbV1(s.stackLabel);
    final bet = potTruthBbV1(s.currentBetLabel) ?? 0;
    final actor = s.seatLabel.trim().toUpperCase();
    if (stack == 0 && bet > 0 && !allIns.any((a) => a.actor == actor)) {
      bad('zero_stack_without_all_in', actor);
    }
    // Contribution cap: nothing attributed to a seat may exceed the chips it
    // is shown to own (behind + committed).
    if (stack != null) {
      final cap = stack + bet;
      for (final a in actions.where((a) => a.actor == actor)) {
        if (a.amount != null &&
            const {'all_in', 'raise_to', 'total'}.contains(a.verb) &&
            a.amount! > cap + 1e-9) {
          bad('bet_exceeds_stack', '$actor ${a.raw} cap=$cap');
        }
      }
    }
  }

  // Once an all-in has been answered preflop, every seat that had to act in
  // between either matched it (or is all-in itself) or folded. A live seat
  // that did neither would be shown as eligible for chips it never matched.
  if (allIns.isNotEmpty && t.boardCards.isEmpty) {
    final first = allIns.first;
    final from = act0PotTruthPreflopOrderV1.indexOf(first.actor);
    final after = actions.skip(actions.indexOf(first) + 1);
    var reach = 0;
    for (final a in after) {
      final i = act0PotTruthPreflopOrderV1.indexOf(a.actor);
      if (from < 0 || i < 0 || a.actor == first.actor) continue;
      final d = (i - from) % act0PotTruthPreflopOrderV1.length;
      if (d > reach) reach = d;
    }
    for (var d = 1; d < reach; d++) {
      final actor =
          act0PotTruthPreflopOrderV1[(from + d) %
              act0PotTruthPreflopOrderV1.length];
      final seat = seats[actor];
      if (seat == null || !_live(seat)) continue;
      final put = potTruthBbV1(seat.currentBetLabel) ?? 0;
      final matched = put + 1e-9 >= (first.amount ?? double.infinity);
      if (!matched && !allIns.any((a) => a.actor == actor)) {
        bad('live_seat_neither_matched_nor_folded', '$actor put=$put');
      }
    }
  }

  // Declared main/side split: recompute from contributions and eligibility.
  final split = RegExp(
    r'^Main\s+(\d+(?:\.\d+)?)\s*BB;\s*side\s+(\d+(?:\.\d+)?)\s*BB$',
    caseSensitive: false,
  ).firstMatch(t.potLabel.trim());
  if (split != null) {
    final shortIns = [
      for (final a in allIns)
        if (seats[a.actor] case final s? when _live(s))
          potTruthBbV1(s.currentBetLabel),
    ].whereType<double>().toList();
    if (shortIns.isEmpty) {
      bad('side_pot_without_live_all_in', t.potLabel);
    } else {
      final level = shortIns.reduce((a, b) => a < b ? a : b);
      var main = 0.0, side = 0.0;
      for (final s in t.seats) {
        final c = potTruthBbV1(s.currentBetLabel) ?? 0;
        main += c < level ? c : level;
        side += c > level ? c - level : 0;
      }
      if ((main - double.parse(split.group(1)!)).abs() > 1e-9 ||
          (side - double.parse(split.group(2)!)).abs() > 1e-9) {
        bad('side_pot_amounts', 'computed main=$main side=$side');
      }
      final hero = t.seats.where((s) => s.isHero).firstOrNull;
      final heroPut = potTruthBbV1(hero?.currentBetLabel) ?? 0;
      if (hero != null && _live(hero) && heroPut <= level + 1e-9) {
        // Hero is the short all-in: eligible for main, never for side.
        if (heroPut + 1e-9 < level) bad('hero_not_main_eligible', '$heroPut');
      }
    }
  }
  return out;
}

/// Whether the table supplies any stack/all-in/split fact PKR-06 can judge.
bool pkr06ApplicableV1(Act0TableStateV1 t) =>
    t.seats.any((s) => s.stackLabel != null) ||
    t.actionTrail.any(
      (a) => potTruthParseActionV1(t, a.label)?.verb == 'all_in',
    ) ||
    t.potLabel.toLowerCase().contains('side');

String? potTruthSolverCardV1(Act0CardStateV1 c) {
  var r = c.rank.trim().toUpperCase();
  if (r == '10') r = 'T';
  final s = c.suit.trim().toLowerCase();
  const ranks = 'AKQJT98765432';
  if (r.length != 1 ||
      !ranks.contains(r) ||
      !'shdc'.contains(s) ||
      s.length != 1) {
    return null;
  }
  return '$r$s';
}

/// PKR-08 showdown resolution from real source cards only.
class ShowdownTruthV1 {
  const ShowdownTruthV1._(this.verdict, this.reason, this.winners, this.potBb);
  final PotTruthVerdictV1 verdict;
  final String reason;
  final List<String> winners; // seat ids
  final double? potBb;
}

ShowdownTruthV1 resolveShowdownTruthV1(Act0TableStateV1 t) {
  ShowdownTruthV1 no(String reason) =>
      ShowdownTruthV1._(PotTruthVerdictV1.unproved, reason, const [], null);
  if (t.scope != Act0TableScopeV1.playedHand) return no('not_played_hand');
  if (t.potLabel.toLowerCase().contains('side')) {
    return no('side_pot_showdown_not_supported');
  }
  final board = t.boardCards.map(potTruthSolverCardV1).toList();
  if (board.length != 5 || board.contains(null)) return no('board_incomplete');
  final live = t.seats.where(_live).toList();
  if (live.length < 2) return no('fewer_than_two_live');
  final shown = <String, List<String>>{};
  final hidden = <String>[];
  for (final s in live) {
    final cards = (s.isHero ? t.heroCards : s.holeCards)
        .map(potTruthSolverCardV1)
        .toList();
    final visible =
        s.isHero || s.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp;
    if (visible && cards.length == 2 && !cards.contains(null)) {
      shown[s.seatId] = cards.cast<String>();
    } else if (visible) {
      return no('shown_hand_incomplete:${s.seatId}');
    } else {
      hidden.add(s.seatId);
    }
  }
  final used = [...board.cast<String>(), for (final c in shown.values) ...c];
  if (used.toSet().length != used.length) return no('duplicate_card');
  if (shown.length < 2 && hidden.isEmpty) return no('fewer_than_two_shown');

  final hands = {
    for (final e in shown.entries)
      e.key: Hand.solveHand(<String>[...board.cast<String>(), ...e.value]),
  };
  final best = Hand.winners(hands.values.toList());
  final winners = [
    for (final e in hands.entries)
      if (best.contains(e.value)) e.key,
  ];
  // A hidden live hand is only irrelevant when no possible holding from the
  // unseen deck could beat or tie the best shown hand.
  if (hidden.isNotEmpty) {
    const ranks = 'AKQJT98765432';
    final deck = [
      for (final r in ranks.split(''))
        for (final s in 'shdc'.split('')) '$r$s',
    ]..removeWhere(used.contains);
    final top = hands[winners.first]!;
    for (var i = 0; i < deck.length; i++) {
      for (var j = i + 1; j < deck.length; j++) {
        final h = Hand.solveHand(<String>[
          ...board.cast<String>(),
          deck[i],
          deck[j],
        ]);
        if (h.compare(top) <= 0) {
          return no('hidden_live_hand_can_win_or_tie:${hidden.join(",")}');
        }
      }
    }
  }
  final pot = potTruthBbV1(t.potLabel.replaceFirst(RegExp('^Pot\\s+'), ''));
  if (pot == null) return no('pot_unparsed');
  return ShowdownTruthV1._(
    PotTruthVerdictV1.proved,
    'source_cards',
    winners,
    pot,
  );
}
