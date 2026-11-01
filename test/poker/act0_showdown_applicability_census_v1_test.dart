// Showdown and hand-class applicability census for the live Act0 catalog.
//
// The live poker-truth guard checks explicit "who wins" questions and
// excludes the rest. This census closes that gap: every task whose table has
// a complete board, or whose options name a hand class, a tie, a split or a
// kicker, is listed below with the claim it makes, and each applicable claim
// is recomputed with the vendored poker_solver (ranking pinned by
// poker_solver_standard_ranking_v1_test.dart). A task that is not applicable
// says why; a new task with such options must be added here.
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

enum _Claim {
  /// The keyed option names the category of the unique winning hand.
  winnerClass,

  /// "Who wins" between revealed hands: keyed seat equals the solver winner.
  winnerSeat,

  /// The keyed option names Hero's best-hand category.
  heroClass,

  /// The revealed hands split the pot.
  tie,

  /// Same category and same pair; a kicker decides a unique winner.
  kickerDecides,

  /// Concept question over a revealed showdown with one clear winner.
  clearWinner,

  /// Hero held a four-card draw by the turn and missed it on the river.
  drawMissed,

  /// Abstract category order (no table cards involved).
  categoryOrder,

  /// Hero holds four cards of one suit (no flush); [note] names the suit
  /// word the keyed option uses.
  flushDraw,

  /// The ranks that complete Hero's straight: exactly [note], comma-joined.
  straightOuts,

  /// Hero has top pair; the board shows two cards of one suit (draw pressure)
  /// but no flush is possible yet.
  madeHandWithDrawPressure,

  /// Hero pairs the highest board card.
  topPair,

  /// The board is paired and Hero holds none of that rank.
  pairedBoardNoneHeld,

  /// Theory-phase option data is not rendered or graded.
  theoryNotRendered,

  /// No hand claim: counting, street or price questions.
  notApplicable,
}

const _census = <String, (_Claim, String)>{
  'what_poker_is_showdown_win': (_Claim.clearWinner, 'best hand decides'),
  'your_first_hand_showdown': (_Claim.clearWinner, 'best hand decides'),
  'showdown_best_hand_drill': (_Claim.clearWinner, 'best hand decides'),
  'showdown_review': (_Claim.clearWinner, 'best hand wins'),
  'hand_rankings_two_pair_drill': (_Claim.winnerClass, 'two pair'),
  'hand_rankings_trips_drill': (_Claim.winnerClass, 'three of a kind'),
  'hand_rankings_flush_drill': (_Claim.winnerClass, 'flush'),
  'hand_rankings_full_house_vs_flush_drill': (_Claim.winnerSeat, 'hero'),
  'hand_rankings_quads_vs_full_house_drill': (_Claim.winnerSeat, 'hero'),
  'hand_rankings_royal_vs_flush_drill': (_Claim.winnerSeat, 'hero'),
  'w6_kicker_showdown_compare': (_Claim.winnerSeat, 'hero'),
  'w6_board_pair_strength_compare': (_Claim.winnerSeat, 'co'),
  'w6_checkpoint_table_best_five': (_Claim.tie, 'board straight plays'),
  'hand_rankings_full_house_drill': (_Claim.heroClass, 'full house'),
  'hand_rankings_quads_drill': (_Claim.heroClass, 'four of a kind'),
  'hand_rankings_royal_flush_drill': (_Claim.heroClass, 'royal flush'),
  'hand_rankings_pair_drill': (_Claim.heroClass, 'pair'),
  'showdown_kicker_drill': (_Claim.kickerDecides, 'kicker'),
  'showdown_board_plays_drill': (_Claim.tie, 'board plays'),
  'showdown_tie_drill': (_Claim.tie, 'split pot'),
  'hand_rankings_review': (_Claim.categoryOrder, 'flush over straight'),
  'turn_river_changes_w5_river_misses': (_Claim.drawMissed, 'flush draw'),
  'turn_river_changes_w5_river_draw_story_transfer': (
    _Claim.drawMissed,
    'flush draw',
  ),
  'cards_ranks_suits_board_count': (_Claim.notApplicable, 'counts cards'),
  'cards_ranks_suits_best_five': (_Claim.notApplicable, 'counts cards'),
  'cards_ranks_suits_recap': (_Claim.notApplicable, 'counts cards'),
  'hand_rankings_best_five_drill': (_Claim.notApplicable, 'counts cards'),
  'hand_rankings_straight_drill': (_Claim.notApplicable, 'defines a straight'),
  'your_first_hand_river': (_Claim.notApplicable, 'counts board cards'),
  'your_first_hand_recap': (_Claim.notApplicable, 'names a street'),
  'w12_pretty_hand_bad_price_fold': (_Claim.notApplicable, 'price decision'),
  'flush_draws_w5_flush_draw_find': (_Claim.flushDraw, 'flush draw'),
  'flush_draws_w5_flush_draw_recheck_transfer': (
    _Claim.flushDraw,
    'flush draw',
  ),
  'outs_improvement_w5_table_outs_flush_transfer': (_Claim.flushDraw, 'heart'),
  'straight_draws_w5_straight_draw_find': (_Claim.straightOuts, '4,9'),
  'straight_draws_w5_gutshot_draw': (_Claim.straightOuts, '6'),
  'straight_draws_w5_gutshot_contrast_transfer': (_Claim.straightOuts, '6'),
  'outs_improvement_w5_table_outs_straight_transfer': (
    _Claim.straightOuts,
    '4,9',
  ),
  'flush_draws_w5_made_hand_vs_flush_draw_transfer': (
    _Claim.madeHandWithDrawPressure,
    'top pair, two hearts on board',
  ),
  'w7_top_pair_spr2_transfer': (_Claim.topPair, 'K-Q on K-7-2'),
  'w10_table_value_vs_caller_transfer': (_Claim.topPair, 'K-Q on K-7-2'),
  'w11_trigger_bad_price_fold': (_Claim.topPair, 'Q-J on J-7-4-2'),
  'paired_board_texture_lite_intro': (
    _Claim.pairedBoardNoneHeld,
    'two sevens, trips still possible',
  ),
  'hand_rankings_theory': (_Claim.theoryNotRendered, 'theory options'),
  'w10_checkpoint_tag_line': (_Claim.notApplicable, '"pair" is a verb'),
};

const _ranks = '23456789TJQKA';

/// Ranks whose addition makes a straight that [cards] do not already make.
Set<String> _straightCompleters(List<String> cards) {
  bool straight(Set<int> v) {
    final s = {...v, if (v.contains(14)) 1};
    for (var hi = 5; hi <= 14; hi++) {
      if (List.generate(5, (i) => hi - i).every(s.contains)) return true;
    }
    return false;
  }

  final values = {for (final c in cards) _ranks.indexOf(c[0]) + 2};
  if (straight(values)) return const {};
  return {
    for (var v = 2; v <= 14; v++)
      if (!values.contains(v) && straight({...values, v})) _ranks[v - 2],
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
  'two pair': 'two pair',
  'one pair': 'pair',
  'pair': 'pair',
  'high card': 'high card',
};

String? _named(String text) {
  final lower = text.toLowerCase();
  for (final e in _categoryWords.entries) {
    if (RegExp('\\b${e.key}\\b').hasMatch(lower)) return e.value;
  }
  return null;
}

String? _card(Act0CardStateV1 c) {
  var rank = c.rank.trim().toUpperCase();
  if (rank == '10') rank = 'T';
  final suit = c.suit.trim().toLowerCase();
  if (rank.length != 1 || !'23456789TJQKA'.contains(rank)) return null;
  if (!'shdc'.contains(suit) || suit.length != 1) return null;
  return '$rank$suit';
}

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

typedef _Player = ({String id, List<String> cards, Hand hand});

void main() {
  final tasks = <Act0LessonTaskV1>[
    for (final w in Act0ShellStateV1.sample.worlds)
      for (final l in w.lessons) ...l.taskList,
  ];
  Act0LessonTaskV1 task(String id) => tasks.singleWhere((t) => t.taskId == id);

  List<String> board(Act0TableStateV1 t) =>
      t.boardCards.map(_card).whereType<String>().toList();

  List<_Player> players(Act0TableStateV1 t) {
    final b = board(t);
    final hero = t.heroCards.map(_card).whereType<String>().toList();
    return [
      if (hero.length == 2)
        (id: 'hero', cards: hero, hand: Hand.solveHand([...b, ...hero])),
      for (final s in t.seats)
        if (!s.isHero &&
            s.isInHand &&
            !s.isFolded &&
            s.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp)
          (
            id: s.seatId,
            cards: s.holeCards.map(_card).whereType<String>().toList(),
            hand: Hand.solveHand([
              ...b,
              ...s.holeCards.map(_card).whereType<String>(),
            ]),
          ),
    ];
  }

  Set<String> winners(List<_Player> ps) {
    final best = Hand.winners([for (final p in ps) p.hand]);
    return {
      for (final p in ps)
        if (best.contains(p.hand)) p.id,
    };
  }

  test('every board-complete or hand-class task is in the census', () {
    final needed = <String>{};
    for (final t in tasks) {
      final table = t.runner.table;
      final namesHand = t.runner.options.any(
        (o) =>
            _named(o.label) != null ||
            RegExp(
              r'\b(tie|split|kicker)\b',
              caseSensitive: false,
            ).hasMatch(o.label),
      );
      if (table.boardCards.length == 5 ||
          (namesHand && t.runner.options.isNotEmpty)) {
        if (table.boardCards.isNotEmpty || table.boardCards.length == 5) {
          needed.add(t.taskId);
        }
      }
    }
    expect(needed.difference(_census.keys.toSet()), isEmpty);
    expect(
      _census.keys.toSet().difference(tasks.map((t) => t.taskId).toSet()),
      isEmpty,
    );
  });

  for (final entry in _census.entries) {
    final (claim, note) = entry.value;
    test('${entry.key}: ${claim.name} ($note)', () {
      final t = task(entry.key);
      final table = t.runner.table;
      final keyed = t.runner.options.where((o) => o.isCorrect).toList();
      final ps = players(table);
      switch (claim) {
        case _Claim.winnerClass:
          expect(table.boardCards, hasLength(5));
          expect(ps.length, greaterThanOrEqualTo(2));
          final w = winners(ps);
          expect(w, hasLength(1), reason: 'one winner');
          final winner = ps.singleWhere((p) => p.id == w.single);
          expect(_category(winner.hand), note);
          expect(keyed, hasLength(1));
          expect(_named(keyed.single.label), note);
          // Every other offered class belongs to a losing hand or nobody.
          for (final o in t.runner.options.where((o) => !o.isCorrect)) {
            final other = _named(o.label);
            if (other == null) continue;
            expect(other, isNot(note), reason: o.label);
          }
        case _Claim.winnerSeat:
          expect(ps.length, greaterThanOrEqualTo(2));
          expect(winners(ps), {note});
        case _Claim.heroClass:
          final hero = ps.singleWhere((p) => p.id == 'hero');
          expect(_category(hero.hand), note);
          expect(_named(keyed.single.label), note);
        case _Claim.tie:
          expect(ps.length, greaterThanOrEqualTo(2));
          expect(winners(ps), ps.map((p) => p.id).toSet());
          final label = keyed.single.label.toLowerCase();
          expect(label, anyOf(contains('tie'), contains('split')));
        case _Claim.kickerDecides:
          expect(ps.length, 2);
          final a = ps[0].hand, b = ps[1].hand;
          expect(_category(a), _category(b));
          expect(_category(a), 'pair');
          expect(a.cards[0].value, b.cards[0].value, reason: 'same pair');
          expect(winners(ps), hasLength(1), reason: 'kicker decides');
          expect(keyed.single.label.toLowerCase(), contains('kicker'));
        case _Claim.clearWinner:
          expect(ps.length, greaterThanOrEqualTo(2));
          expect(winners(ps), hasLength(1));
        case _Claim.drawMissed:
          final hero = ps.singleWhere((p) => p.id == 'hero');
          final turn = [...board(table).take(4), ...hero.cards];
          final suits = <String, int>{};
          for (final c in turn) {
            suits[c[1]] = (suits[c[1]] ?? 0) + 1;
          }
          expect(suits.values.any((n) => n == 4), isTrue, reason: 'draw');
          expect(
            _category(hero.hand),
            isNot(anyOf('flush', 'straight', 'straight flush')),
          );
        case _Claim.categoryOrder:
          final flush = Hand.solveHand([
            'Ah',
            'Jh',
            '8h',
            '4h',
            '2h',
            'Kc',
            'Qd',
          ]);
          final straight = Hand.solveHand([
            '5h',
            '6d',
            '7c',
            '8s',
            '9h',
            '2c',
            'Kd',
          ]);
          expect(Hand.winners([flush, straight]), [flush]);
          expect(_named(keyed.single.label), 'flush');
        case _Claim.flushDraw:
          final hero = ps.singleWhere((p) => p.id == 'hero');
          final seen = [...board(table), ...hero.cards];
          final bySuit = <String, int>{};
          for (final c in seen) {
            bySuit[c[1]] = (bySuit[c[1]] ?? 0) + 1;
          }
          final drawSuit = bySuit.entries.where((e) => e.value == 4);
          expect(drawSuit, hasLength(1), reason: 'four to one suit');
          expect(
            hero.cards.every((c) => c[1] == drawSuit.single.key),
            isTrue,
            reason: 'both hole cards in the draw suit',
          );
          expect(_category(hero.hand), isNot('flush'));
          expect(keyed.single.label.toLowerCase(), contains(note));
        case _Claim.straightOuts:
          final hero = ps.singleWhere((p) => p.id == 'hero');
          final outs = _straightCompleters([...board(table), ...hero.cards]);
          expect(outs, note.split(',').toSet());
          final label = keyed.single.label.toLowerCase();
          if (outs.length == 1) expect(label, contains('gutshot'));
          if (outs.length == 2 &&
              t.runner.options.any((o) => o.id == 'gutshot')) {
            expect(label, isNot(contains('gutshot')));
          }
        case _Claim.madeHandWithDrawPressure:
          final hero = ps.singleWhere((p) => p.id == 'hero');
          final b = board(table);
          final top = b
              .map((c) => _ranks.indexOf(c[0]))
              .reduce((a, c) => a > c ? a : c);
          expect(_category(hero.hand), 'pair');
          expect(hero.cards.any((c) => _ranks.indexOf(c[0]) == top), isTrue);
          expect(b.where((c) => c[1] == 'h').length, 2);
          expect(hero.cards.any((c) => c[1] == 'h'), isFalse);
          expect(keyed.single.label.toLowerCase(), contains('top pair'));
        case _Claim.topPair:
          final hero = ps.singleWhere((p) => p.id == 'hero');
          final top = board(
            table,
          ).map((c) => _ranks.indexOf(c[0])).reduce((a, c) => a > c ? a : c);
          expect(_category(hero.hand), 'pair');
          expect(hero.cards.any((c) => _ranks.indexOf(c[0]) == top), isTrue);
        case _Claim.pairedBoardNoneHeld:
          final hero = ps.singleWhere((p) => p.id == 'hero');
          final b = board(table);
          final counts = <String, int>{};
          for (final c in b) {
            counts[c[0]] = (counts[c[0]] ?? 0) + 1;
          }
          final paired = counts.entries.singleWhere((e) => e.value == 2).key;
          expect(hero.cards.any((c) => c[0] == paired), isFalse);
          expect(keyed.single.label.toLowerCase(), contains('trips'));
        case _Claim.theoryNotRendered:
          expect(t.phase, Act0LessonPhaseV1.theory);
        case _Claim.notApplicable:
          for (final o in keyed) {
            expect(_named(o.label), isNull, reason: 'no hand claim keyed');
          }
      }
    });
  }
}
