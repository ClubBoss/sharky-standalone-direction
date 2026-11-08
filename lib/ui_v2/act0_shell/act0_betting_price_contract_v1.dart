import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';
import 'package:poker_analyzer/ui_v2/act0_shell/act0_street_replay_contract_v1.dart';

/// This is a source contradiction guard, not a poker simulator or an answer
/// oracle. It never turns an unproved history into a correct learner answer.
enum Act0BettingPriceTruthV1 { unproved, consistent, contradiction }

class Act0BettingPriceResultV1 {
  const Act0BettingPriceResultV1(
    this.truth,
    this.reason, {
    this.callCostBb,
    this.amountToMatchBb,
    this.minimumRaiseToBb,
    this.actorCommittedBb,
  });

  final Act0BettingPriceTruthV1 truth;
  final String reason;

  /// Capped additional call cost; null when the actor stack is unknown.
  final double? callCostBb;

  /// Uncapped outstanding street commitment, derived from the history.
  final double? amountToMatchBb;

  /// Ordinary full-raise threshold; a legal short all-in may be below it.
  /// Null when the source does not establish that threshold.
  final double? minimumRaiseToBb;
  final double? actorCommittedBb;

  bool get isContradiction => truth == Act0BettingPriceTruthV1.contradiction;
}

const _unit = 1000000;
const _unknown = Act0BettingPriceTruthV1.unproved;
const _consistent = Act0BettingPriceTruthV1.consistent;
const _contradiction = Act0BettingPriceTruthV1.contradiction;

// Decimal BB units avoid binary floating-point errors at exact minimum raises.
// Other units, rounding, symbolic sizes, negative or extravagant inputs are not
// silently reinterpreted. The normalizer is deliberately bounded.
int? _bb(String label, {String prefix = ''}) {
  final match = RegExp(
    '^${RegExp.escape(prefix)}([0-9]{1,7})(?:\\.([0-9]{1,6}))?\\s+BB\$',
    caseSensitive: false,
  ).firstMatch(label.trim());
  if (match == null) return null;
  return int.parse(match[1]!) * _unit +
      int.parse((match[2] ?? '').padRight(6, '0'));
}

int? _street(String value) => switch (value.trim().toLowerCase()) {
  'preflop' => 0,
  'flop' => 1,
  'turn' => 2,
  'river' => 3,
  _ => null,
};

class _PriceLedger {
  final committed = <String, int>{};
  final lastActedAt = <String, int>{};
  final lastActedFullRaise = <String, int>{};
  final allIn = <String>{};
  int price = _unit;
  int fullRaise = _unit;
  int street = 0;
  bool shortOpening = false;

  bool canRaise(String actor) =>
      !lastActedAt.containsKey(actor) ||
      price - lastActedAt[actor]! >= lastActedFullRaise[actor]!;

  void acted(String actor) {
    lastActedAt[actor] = price;
    lastActedFullRaise[actor] = fullRaise;
  }
}

/// Checks a numeric action against its authored history. Calls in choice
/// amountLabel are additional chips; raises are street-total commitments.
/// Trail calls are totals unless the source explicitly says "BB more".
///
/// Supported source profile: ordinary 0.5/1 BB no-limit hold'em, explicit blind
/// start and explicit street boundaries. No ante, straddle, pot-limit, forced
/// completion, uncalled-return, inferred fold, or inferred historical stack.
/// Missing grammar/facts remain unproved. The PKR-03 owner still decides order.
/// Legal short all-in choices are preserved using the actor's supplied stack;
/// a short all-in in the history does not itself reopen a prior actor's raise.
Act0BettingPriceResultV1 act0BettingPriceForOptionV1(
  Act0TableStateV1 table,
  Act0RunnerOptionV1 option,
) {
  final actionMatch = RegExp(
    r'^(call|bet|raise|shove|jam)\b',
    caseSensitive: false,
  ).firstMatch(option.label.trim());
  if (actionMatch == null || option.amountLabel.trim().isEmpty) {
    return const Act0BettingPriceResultV1(_unknown, 'not_numeric_action');
  }
  // Do not guess whether an explicitly incremental raise is a raise-to total.
  if (RegExp(r'\bby\b', caseSensitive: false).hasMatch(option.label)) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'incremental_raise_unknown',
    );
  }
  final chosen = _bb(option.amountLabel);
  if (chosen == null) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'unsupported_choice_amount',
    );
  }
  if (table.scope != Act0TableScopeV1.playedHand ||
      !table.usesCanonicalPlayerCount ||
      table.seats.length != table.playerCount) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'not_complete_hand_profile',
    );
  }
  final seats = <String, Act0SeatStateV1>{};
  final ids = <String>{};
  for (final seat in table.seats) {
    final actor = seat.seatLabel.trim().toUpperCase();
    if (!seat.isOccupied ||
        !table.canonicalSeatOrder.contains(actor) ||
        seats.containsKey(actor) ||
        !ids.add(seat.seatId)) {
      return const Act0BettingPriceResultV1(_unknown, 'ambiguous_participants');
    }
    seats[actor] = seat;
  }
  final matching = table.seats.where((s) => s.seatId == table.activeSeatId);
  if (matching.length != 1) {
    return const Act0BettingPriceResultV1(_unknown, 'missing_active_actor');
  }
  final hero = matching.single;
  if (!hero.isHero || hero.seatId != table.heroSeatId) {
    return const Act0BettingPriceResultV1(_unknown, 'not_hero_action');
  }
  if (chosen <= 0) {
    return const Act0BettingPriceResultV1(_contradiction, 'nonpositive_wager');
  }
  if (hero.isFolded || !hero.isInHand) {
    return const Act0BettingPriceResultV1(_contradiction, 'inactive_actor');
  }
  final actor = hero.seatLabel.trim().toUpperCase();
  final ledger = _PriceLedger();
  var actionCount = 0;
  for (final item in table.actionTrail) {
    if (item.isNote) continue;
    var label = item.label.trim();
    final marker = RegExp(
      r'^(Preflop|Flop|Turn|River):\s*(.*)$',
      caseSensitive: false,
    ).firstMatch(label);
    if (marker != null) {
      final next = _street(marker[1]!)!;
      if (next != ledger.street) {
        // A partial prefix or an omitted earlier street cannot establish the
        // supported history profile. Do not punish the learner for absent facts.
        if (actionCount < 2) {
          return const Act0BettingPriceResultV1(
            _unknown,
            'missing_blind_start',
          );
        }
        if (next > ledger.street + 1) {
          return const Act0BettingPriceResultV1(
            _unknown,
            'unrecorded_street_gap',
          );
        }
        if (next < ledger.street) {
          return const Act0BettingPriceResultV1(_contradiction, 'street_order');
        }
        ledger.street = next;
        ledger.price = 0;
        ledger.fullRaise = _unit;
        ledger.committed.clear();
        ledger.lastActedAt.clear();
        ledger.lastActedFullRaise.clear();
        ledger.shortOpening = false;
      }
      label = marker[2]!.trim();
      if (label.isEmpty) continue;
    }
    final parsed = RegExp(
      r'^(UTG|HJ|CO|BTN|SB|BB|UTG\+1|UTG\+2|LJ) '
      r'(blind|posts|folds?|checks?|calls?|bets?|raises?|shoves?|jams?)'
      r'(?: (?:to )?([0-9]{1,7}(?:\.[0-9]{1,6})? BB)( more)?)?$',
      caseSensitive: false,
    ).firstMatch(label);
    if (parsed == null) {
      return const Act0BettingPriceResultV1(_unknown, 'unsupported_history');
    }
    final who = parsed[1]!.toUpperCase();
    final verb = parsed[2]!.toLowerCase();
    if (!seats.containsKey(who)) {
      return const Act0BettingPriceResultV1(_unknown, 'unknown_history_actor');
    }
    if (ledger.allIn.contains(who)) {
      return const Act0BettingPriceResultV1(
        _contradiction,
        'action_after_all_in',
      );
    }
    final amount = parsed[3] == null ? null : _bb(parsed[3]!);
    final more = parsed[4] != null;
    final post = verb == 'blind' || verb == 'posts';
    if (actionCount < 2) {
      if (!post ||
          ledger.street != 0 ||
          more ||
          who != (actionCount == 0 ? 'SB' : 'BB') ||
          amount != (actionCount == 0 ? _unit ~/ 2 : _unit)) {
        return const Act0BettingPriceResultV1(_unknown, 'missing_blind_start');
      }
      ledger.committed[who] = amount!;
      actionCount++;
      continue;
    }
    actionCount++;
    if (post) {
      return const Act0BettingPriceResultV1(_unknown, 'extra_forced_post');
    }
    if (verb.startsWith('fold') || verb.startsWith('check')) {
      if (amount != null || more) {
        return const Act0BettingPriceResultV1(
          _unknown,
          'unexpected_passive_amount',
        );
      }
      if (verb.startsWith('check') &&
          (ledger.committed[who] ?? 0) != ledger.price) {
        return const Act0BettingPriceResultV1(
          _contradiction,
          'check_facing_price',
        );
      }
      if (verb.startsWith('check')) ledger.acted(who);
      continue;
    }
    if (amount == null || amount <= 0 || (more && !verb.startsWith('call'))) {
      return const Act0BettingPriceResultV1(
        _unknown,
        'unsupported_history_amount',
      );
    }
    final before = ledger.committed[who] ?? 0;
    final total = more ? before + amount : amount;
    final isAllIn = verb.startsWith('shove') || verb.startsWith('jam');
    if (verb.startsWith('call') || (isAllIn && total <= ledger.price)) {
      if (ledger.price == 0 ||
          total <= before ||
          total > ledger.price ||
          (!isAllIn && total != ledger.price)) {
        return const Act0BettingPriceResultV1(
          _unknown,
          'unproved_history_call',
        );
      }
    } else {
      if (ledger.shortOpening) {
        return const Act0BettingPriceResultV1(
          _unknown,
          'short_opening_completion',
        );
      }
      if (total <= ledger.price ||
          (verb.startsWith('bet') && ledger.price > 0) ||
          (verb.startsWith('raise') && ledger.price == 0)) {
        return const Act0BettingPriceResultV1(
          _contradiction,
          'inconsistent_aggression',
        );
      }
      if (!ledger.canRaise(who)) {
        return const Act0BettingPriceResultV1(
          _contradiction,
          'raise_not_reopened',
        );
      }
      final increment = total - ledger.price;
      if (increment < ledger.fullRaise) {
        // Only explicit all-in history may be short. A sparse stack cannot
        // certify an ordinary bet as illegal: it might consume the whole stack.
        if (!isAllIn) {
          final remaining = _bb(seats[who]!.stackLabel ?? '');
          return Act0BettingPriceResultV1(
            remaining != null && remaining > 0 ? _contradiction : _unknown,
            'short_history_wager_without_all_in',
          );
        }
        if (ledger.price == 0) ledger.shortOpening = true;
      } else {
        ledger.fullRaise = increment;
      }
      ledger.price = total;
    }
    ledger.committed[who] = total;
    ledger.acted(who);
    if (isAllIn) ledger.allIn.add(who);
  }
  if (actionCount < 2 || _street(table.streetLabel) != ledger.street) {
    return const Act0BettingPriceResultV1(
      _unknown,
      'unrecorded_current_street',
    );
  }
  final order = act0BettingRoundOrderTruthForTableV1(table);
  if (order == Act0BettingRoundOrderTruthV1.contradiction) {
    return const Act0BettingPriceResultV1(
      _contradiction,
      'source_order_contradiction',
    );
  }
  if (ledger.allIn.contains(actor)) {
    return const Act0BettingPriceResultV1(
      _contradiction,
      'active_actor_all_in',
    );
  }
  final committed = ledger.committed[actor] ?? 0;
  final due = ledger.price - committed;
  final remaining = _bb(hero.stackLabel ?? '');
  final cappedCall = remaining == null
      ? null
      : (due < remaining ? due : remaining);
  Act0BettingPriceResultV1 result(
    Act0BettingPriceTruthV1 truth,
    String reason,
  ) => Act0BettingPriceResultV1(
    truth,
    reason,
    callCostBb: cappedCall == null ? null : cappedCall / _unit,
    amountToMatchBb: due / _unit,
    minimumRaiseToBb: ledger.shortOpening
        ? null
        : (ledger.price + ledger.fullRaise) / _unit,
    actorCommittedBb: committed / _unit,
  );
  if (due < 0) return result(_contradiction, 'commitment_exceeds_price');
  final action = actionMatch[1]!.toLowerCase();
  final allInChoice = action == 'shove' || action == 'jam';
  final callChoice =
      action == 'call' || (allInChoice && chosen <= ledger.price);
  if (callChoice) {
    final callAmount = action == 'call' ? chosen : chosen - committed;
    if (due == 0) return result(_contradiction, 'call_without_price');
    if (remaining == null) {
      return callAmount > due
          ? result(_contradiction, 'call_exceeds_price')
          : result(_unknown, 'missing_actor_stack');
    }
    final legalCall = due < remaining ? due : remaining;
    if (callAmount != legalCall ||
        legalCall <= 0 ||
        (allInChoice && callAmount != remaining)) {
      return result(_contradiction, 'call_cost_mismatch');
    }
  } else {
    if (ledger.shortOpening)
      return result(_unknown, 'short_opening_completion');
    final total = chosen;
    final additional = total - committed;
    if (additional <= 0 || total <= ledger.price) {
      return result(_contradiction, 'aggression_does_not_raise_price');
    }
    if ((action == 'bet' && ledger.price > 0) ||
        (action == 'raise' && ledger.price == 0)) {
      return result(_contradiction, 'wrong_wager_kind');
    }
    if (!ledger.canRaise(actor))
      return result(_contradiction, 'raise_not_reopened');
    if (remaining == null) return result(_unknown, 'missing_actor_stack');
    if (additional > remaining)
      return result(_contradiction, 'wager_exceeds_stack');
    if ((action == 'shove' || action == 'jam') && additional != remaining) {
      return result(_contradiction, 'all_in_not_whole_stack');
    }
    if (total < ledger.price + ledger.fullRaise && additional != remaining) {
      return result(_contradiction, 'wager_below_minimum');
    }
  }
  // Display is a claim to verify, not the authority used to derive the price.
  final displayLabel = table.toCallLabel.trim();
  if (displayLabel.isEmpty && due > 0) {
    return result(_unknown, 'missing_display_price');
  }
  final displayed = displayLabel.isEmpty
      ? 0
      : _bb(displayLabel, prefix: 'To call ');
  if (displayed == null) return result(_unknown, 'unsupported_display_price');
  // With an all-in cap, displays may expose either the outstanding price or
  // the actual chips the short stack can call. Neither changes the ledger.
  if (displayed != due && displayed != cappedCall) {
    return result(_contradiction, 'display_price_mismatch');
  }
  return result(
    order == Act0BettingRoundOrderTruthV1.consistent ? _consistent : _unknown,
    order == Act0BettingRoundOrderTruthV1.consistent
        ? 'numeric_action_consistent'
        : 'numeric_price_only_order_unproved',
  );
}

/// A malformed source success must not create learner error/debt or success/XP.
/// Incorrect/suboptimal distractors remain available for their teaching role.
bool act0BettingPriceBlocksAuthoredSuccessV1(
  Act0TableStateV1 table,
  Act0RunnerOptionV1 option,
) =>
    (option.isCorrect || option.quality == Act0FeedbackQualityV1.correct) &&
    act0BettingPriceForOptionV1(table, option).isContradiction;
