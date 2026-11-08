import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_solver/poker_solver.dart';

/// Test-only factual oracle. Rule reference:
/// https://www.pokerstars.com/poker/games/rules/
/// Never reads isCorrect, quality or preferredLabel.
/// A fact can verify binary answer truth; it cannot authorize the author's
/// wrong/suboptimal distinction or prove the EV of a strategic recommendation.
class Asm03AnswerFact {
  const Asm03AnswerFact(this.supported, this.basis, this.reason);
  final bool supported;
  final String basis;
  final String reason;
}

String asm03Card(Act0CardStateV1 card) => '${card.rank}${card.suit}';

Set<int> asm03StraightCompletingRanks(Iterable<Act0CardStateV1> cards) {
  final ranks = cards.map((c) => '23456789TJQKA'.indexOf(c.rank) + 2).toSet();
  if (ranks.contains(14)) ranks.add(1);
  final result = <int>{};
  for (var next = 2; next <= 14; next++) {
    final after = {...ranks, next, if (next == 14) 1};
    if ([
      for (var lo = 1; lo <= 10; lo++) lo,
    ].any((lo) => [for (var n = lo; n < lo + 5; n++) n].every(after.contains)))
      result.add(next);
  }
  return result;
}

Asm03AnswerFact? asm03AnswerFact(
  Act0LessonTaskV1 task,
  Act0RunnerOptionV1 choice,
) {
  final id = task.taskId;
  final table = task.runner.table;
  if (id == 'first_table_guide_one_clear_choice') {
    final btn = table.seats.singleWhere((s) => s.seatId == 'btn');
    final co = table.seats.singleWhere((s) => s.seatId == 'co');
    final heroActs = table.activeSeatId == 'btn' && btn.isHero;
    final value = switch (choice.label) {
      'CO/cutoff already folded, so You at BTN act next' =>
        co.isFolded && heroActs,
      'CO/cutoff still acts before You at BTN' =>
        !co.isFolded && table.activeSeatId == 'co',
      'Blinds are posted, but You at BTN have no cards' =>
        table.heroCards.isEmpty,
      'You are BTN, blinds are posted, and no board is out yet' =>
        btn.isHero &&
            table.boardCards.isEmpty &&
            table.potLabel == 'Pot 1.5 BB',
      _ => null,
    };
    return value == null
        ? null
        : Asm03AnswerFact(
            value,
            'authored-seat-state',
            'CO folded=${co.isFolded}; Hero at BTN=${btn.isHero}; active=${table.activeSeatId}; private=${table.heroCards.map(asm03Card).join(",")}; board=${table.boardCards.length}.',
          );
  }

  // The mathematical question explicitly asks for counts before blockers.
  // Visible illustrative cards therefore do not silently become exclusions.
  final comboAnswer = <String, (String, int)>{
    'w6_ak_combos': ('AK', 16),
    'range_checkpoint_combos': ('AK', 16),
    'w6_pair_combos': ('88', 6),
  }[id];
  if (comboAnswer != null) {
    final pair = comboAnswer.$1[0] == comboAnswer.$1[1];
    final count = pair
        ? [
            for (var a = 0; a < 4; a++)
              for (var b = a + 1; b < 4; b++) (a, b),
          ].length
        : [
            for (var a = 0; a < 4; a++)
              for (var b = 0; b < 4; b++) (a, b),
          ].length;
    final value = int.tryParse(choice.label.split(' ').first);
    return value == null
        ? null
        : Asm03AnswerFact(
            value == count,
            '52-card-combinatorics',
            '${comboAnswer.$1}: ${pair ? "choose(4,2)" : "4*4"}=$count before blockers; choice=$value.',
          );
  }

  final fraction = <String, double>{
    'w4_small_bet': 1 / 3,
    'w4_half_pot_bet': .5,
    'w4_pot_bet': 1,
  }[id];
  if (fraction != null) {
    final pot = double.parse(RegExp(r'[\d.]+').firstMatch(table.potLabel)![0]!);
    final amount = double.tryParse(choice.label.split(' ').first);
    return amount == null
        ? null
        : Asm03AnswerFact(
            (amount / pot - fraction).abs() < 1e-9,
            'pot-fraction-arithmetic',
            '$amount / $pot compared with $fraction.',
          );
  }

  final count = <String, int>{
    'your_first_hand_flop': 3,
    'your_first_hand_turn': 4,
    'your_first_hand_river': 5,
    'cards_ranks_suits_board_count': 5,
    'cards_ranks_suits_best_five': 5,
    'cards_ranks_suits_recap': 5,
    'hand_rankings_best_five_drill': 5,
  }[id];
  if (count != null) {
    final answer = <String, int>{
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
    }[choice.label.toLowerCase()];
    return answer == null
        ? null
        : Asm03AnswerFact(
            answer == count,
            'holdem-card-count-rules',
            'Question asks for $count cards; selected $answer.',
          );
  }

  final categoryIds = <String>{
    'hand_rankings_pair_drill',
    'hand_rankings_full_house_drill',
    'hand_rankings_quads_drill',
    'hand_rankings_royal_flush_drill',
  };
  if (categoryIds.contains(id)) {
    final cards = [
      ...table.heroCards,
      ...table.boardCards,
    ].map(asm03Card).toList();
    final solved = Hand.solveHand(cards);
    final category = <String, String>{
      'Pair': 'pair',
      'Full House': 'full house',
      'Four of a Kind': 'four of a kind',
      'Straight Flush': solved.descr == 'Royal Flush'
          ? 'royal flush'
          : 'straight flush',
    }[solved.name];
    if (category == null) return null;
    return Asm03AnswerFact(
      choice.label.toLowerCase() == category,
      'vendored-poker-solver',
      '${cards.join(" ")} => ${solved.descr}; choice=${choice.label}.',
    );
  }

  // Definitions, not strategic best-action judgements. Each local choice is
  // interpreted from its public action/card meaning, independently of flags.
  final correctLabel = <String, String>{
    'actions_legal_context': 'Check',
    'actions_check_drill': 'Check',
    'actions_fold_drill': 'Fold',
    'actions_call_drill': 'Call',
    'cards_ranks_suits_rank_drill': 'Ace',
    'cards_ranks_suits_suit_drill': 'Hearts',
    'cards_ranks_suits_private_board': 'Board cards',
    'what_poker_is_all_in_meaning': 'Hero put in all remaining chips',
    'what_poker_is_matched_chips_transfer':
        'Only the chips CO matched against the 20 BB all-in',
    'what_poker_is_side_pot_intro':
        'Hero can win the main pot, but not the side pot',
    'what_poker_is_showdown_win': 'Best hand',
    'your_first_hand_showdown': 'Best hand',
    'showdown_best_hand_drill': 'Best hand',
    'showdown_review': 'Best hand',
    'showdown_foldout_drill': 'Win now',
    'showdown_tie_drill': 'Split',
    'showdown_board_plays_drill': 'Tie',
    'showdown_kicker_drill': 'Kicker',
    'hand_rankings_review': 'Flush',
    'hand_rankings_flush_drill': 'Flush',
    'hand_rankings_trips_drill': 'Trips',
    'hand_rankings_two_pair_drill': 'Two pair',
    'hand_rankings_straight_drill': 'Five in a row',
    'your_first_hand_recap': 'River',
  }[id];
  if (correctLabel == null) return null;
  return Asm03AnswerFact(
    choice.label == correctLabel,
    'holdem-rules-or-rank-order',
    'Definition question: ${task.runner.question}; ${choice.label} ${choice.label == correctLabel ? "matches" : "does not match"} the rule ($correctLabel).',
  );
}

// A hypothetical heads-up checkdown oracle, never a claim about the authored
// opponent or future betting. It proves that the missing range can change EV.
double asm03RiverCheckdownEquity(Act0TableStateV1 table, List<String> villain) {
  final hero = table.heroCards.map(asm03Card).toList();
  final board = table.boardCards.map(asm03Card).toList();
  final known = {...hero, ...board, ...villain};
  if (board.length != 4 || known.length != 8)
    throw ArgumentError('need eight distinct cards on turn');
  var score = 0.0;
  var rivers = 0;
  for (final rank in '23456789TJQKA'.split('')) {
    for (final suit in 'shdc'.split('')) {
      final river = '$rank$suit';
      if (known.contains(river)) continue;
      final h = Hand.solveHand([...hero, ...board, river]);
      final v = Hand.solveHand([...villain, ...board, river]);
      final winners = Hand.winners([h, v]);
      if (winners.contains(h)) score += 1 / winners.length;
      rivers++;
    }
  }
  return score / rivers;
}
