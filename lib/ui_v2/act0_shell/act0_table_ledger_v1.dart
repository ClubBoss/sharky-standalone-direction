import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Table Truth ledger: a narrow source-validation contract for authored
/// tables. It is not a poker engine: it chooses no actions, ranks no hands and
/// grades nothing. It replays a table's action trail under ordinary no-rake,
/// full-blind rules (optional equal antes) and checks that the shown pot,
/// price, live seats, bets, next actor and revealed hands follow from it.
///
/// It certifies only what the trail explains. It never infers folds from a pot
/// size and never invents contributions: a seat the trail skips must already be
/// authored as folded, and a postflop frame with no trail is unexplained.
///
/// Supported ordinary-hand rules:
/// - posted blinds from the seat flags; `Antes 0.25 BB each` before any action;
/// - an opening bet of at least one big blind;
/// - a raise to at least the current bet plus the last full raise increment;
/// - `shoves` only for a seat whose authored stack shows nothing behind
///   (`All-in` or `0 BB`); a short all-in that does not complete a raise is
///   accepted, but any later raise on that street is outside this contract;
/// - streets only move forward, and `X acts` ends the executable trail;
/// - every revealed opponent shows two real cards, no card appears twice, and
///   a completed river shows every live hand.
///
/// Trail grammar (one item per action, amounts in BB):
///   `UTG folds`, `HJ checks`, `CO calls 2.5 BB` (street total) or
///   `CO calls 2 BB more` (increment), `CO opens 2.5 BB` / `BTN raises to 7 BB`
///   (raise-to), `HJ bets 5 BB`, `BB shoves 18 BB` (shove-to), `BTN acts`.
///   A `Flop: ` / `Turn: ` / `River: ` prefix or `Flop dealt` moves to that
///   street. Note items ([Act0ActionTrailItemV1.note]) are teaching context and
///   are never executed.
///
/// Table scope decides the claim being checked: a played hand must certify; an
/// orientation frame may show only posted blinds and the seat to act; an
/// explanation diagram is checked against its stated chip claims.
enum Act0TableLedgerStatusV1 {
  /// The trail is a legal history and the table shows exactly its result.
  certified,

  /// The trail parses, but the table or the history breaks a rule.
  conflict,

  /// The table shows chips or a later street that no trail explains.
  unexplained,

  /// A non-note trail item is prose, not an action this ledger can replay.
  narrative,

  /// An orientation frame: seats and posted blinds before any action.
  orientation,

  /// An explanation diagram whose stated chip and seat claims hold.
  explanatory,
}

class Act0TableLedgerV1 {
  const Act0TableLedgerV1({
    required this.status,
    required this.potBb,
    required this.liveSeatIds,
    required this.nextActorSeatId,
    required this.heroPriceBb,
    required this.streetLabel,
    required this.problems,
  });

  final Act0TableLedgerStatusV1 status;

  /// Gross pot: every chip committed so far, including current-street bets.
  final double potBb;
  final Set<String> liveSeatIds;

  /// The seat the history leaves to act, or null when the round is closed.
  final String? nextActorSeatId;

  /// What Hero must add to continue on the current street.
  final double heroPriceBb;
  final String streetLabel;
  final List<String> problems;

  bool get isCertified => status == Act0TableLedgerStatusV1.certified;

  /// True when the table holds under its own scope's contract.
  bool get isAccounted =>
      status == Act0TableLedgerStatusV1.certified ||
      status == Act0TableLedgerStatusV1.orientation ||
      status == Act0TableLedgerStatusV1.explanatory;
}

const _kLedgerStreetsV1 = <String>['Preflop', 'Flop', 'Turn', 'River'];
const _kLedgerEpsilonV1 = 1e-9;
const _kBigBlindBbV1 = 1.0;

final _streetPrefixV1 = RegExp(r'^(Flop|Turn|River):\s*');
final _streetDealtV1 = RegExp(r'^(Flop|Turn|River) dealt$');
final _antesV1 = RegExp(r'^Antes (\d+(?:\.\d+)?) BB each$');
final _actionItemV1 = RegExp(
  r'^(\S+) (blind|folds|checks|calls|opens|raises to|raises|bets|shoves|acts)'
  r'(?: (\d+(?:\.\d+)?) BB)?( more)?$',
);
final _potLabelV1 = RegExp(r'^Pot (\d+(?:\.\d+)?) BB$');
final _splitPotLabelV1 = RegExp(
  r'^Main (\d+(?:\.\d+)?) BB; side (\d+(?:\.\d+)?) BB$',
);
final _toCallLabelV1 = RegExp(r'^To call (\d+(?:\.\d+)?) BB$');
final _amountLabelV1 = RegExp(r'^(\d+(?:\.\d+)?) BB$');
const _kRanksV1 = {
  'A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2', //
};
const _kSuitsV1 = {
  's': 's',
  'h': 'h',
  'd': 'd',
  'c': 'c',
  '♠': 's',
  '♥': 'h',
  '♦': 'd',
  '♣': 'c',
};

bool _sameBbV1(double a, double b) => (a - b).abs() < _kLedgerEpsilonV1;

String _bbV1(double value) {
  final rounded = value.roundToDouble();
  return _sameBbV1(value, rounded) ? '${rounded.toInt()}' : '$value';
}

/// Canonical `rank+suit` for a real card, or null for a placeholder.
String? _cardKeyV1(Act0CardStateV1 card) {
  final rank = card.rank.trim().toUpperCase() == '10'
      ? 'T'
      : card.rank.trim().toUpperCase();
  final suit = _kSuitsV1[card.suit.trim().toLowerCase()];
  if (suit == null || !_kRanksV1.contains(rank)) {
    return null;
  }
  return '$rank$suit';
}

/// Remaining chips behind for a seat with an authored stack, or null.
double? _behindBbV1(Act0SeatStateV1 seat) {
  final label = (seat.stackLabel ?? '').trim();
  if (label.toLowerCase() == 'all-in') return 0;
  final m = _amountLabelV1.firstMatch(label);
  return m == null ? null : double.parse(m.group(1)!);
}

Act0TableLedgerV1 act0TableLedgerForV1(Act0TableStateV1 table) {
  if (table.scope == Act0TableScopeV1.explanation) {
    return _explanationLedgerV1(table);
  }
  final problems = <String>[];
  final seatById = {for (final seat in table.seats) seat.seatId: seat};
  final seatIdByCanonicalLabel = {
    for (final seat in table.seats) seat.seatLabel.toUpperCase(): seat.seatId,
  };
  final preflopOrder = [
    for (final label in table.canonicalSeatOrder)
      if (seatIdByCanonicalLabel.containsKey(label))
        seatIdByCanonicalLabel[label]!,
  ];
  if (preflopOrder.length != table.seats.length) {
    problems.add('seats do not match the ${table.tableSize} seat order');
  }
  final heroId = table.heroSeat.seatId;
  final seatIdByLabel = <String, String>{
    for (final seat in table.seats) seat.seatLabel.toUpperCase(): seat.seatId,
    'HERO': heroId,
  };
  final sbIndex = preflopOrder.indexWhere(
    (id) => seatById[id]?.isSmallBlind ?? false,
  );
  final postflopOrder = sbIndex < 0
      ? preflopOrder
      : [...preflopOrder.sublist(sbIndex), ...preflopOrder.sublist(0, sbIndex)];

  final total = {for (final id in preflopOrder) id: 0.0};
  var streetBet = {for (final id in preflopOrder) id: 0.0};
  final live = {for (final id in preflopOrder) id};
  final allIn = <String>{};
  var acted = <String>{};
  var street = 0;
  var currentBet = 0.0;
  var lastFullRaise = _kBigBlindBbV1;
  var shortAllInThisStreet = false;
  // Executed actions other than posted blinds and the end marker.
  var voluntaryActions = 0;
  for (final id in preflopOrder) {
    final seat = seatById[id]!;
    final blind = seat.isSmallBlind
        ? 0.5
        : seat.isBigBlind
        ? _kBigBlindBbV1
        : 0.0;
    total[id] = blind;
    streetBet[id] = blind;
    if (blind > currentBet) {
      currentBet = blind;
    }
  }

  List<String> order() => street == 0 ? preflopOrder : postflopOrder;

  bool needsAction(String id) =>
      live.contains(id) &&
      !allIn.contains(id) &&
      (!acted.contains(id) || streetBet[id]! < currentBet - _kLedgerEpsilonV1);

  String? nextAfter(String? seatId) {
    final seats = order();
    final start = seatId == null ? 0 : seats.indexOf(seatId) + 1;
    for (var step = 0; step < seats.length; step++) {
      final id = seats[(start + step) % seats.length];
      if (needsAction(id)) {
        return id;
      }
    }
    return null;
  }

  String? toAct = nextAfter(null);
  bool roundClosed() =>
      live.length <= 1 || live.every((id) => !needsAction(id));

  void moveToStreet(int target, String why) {
    while (street < target) {
      if (!roundClosed()) {
        problems.add(
          '$why: ${_kLedgerStreetsV1[street]} betting is not closed',
        );
      }
      street += 1;
      currentBet = 0.0;
      lastFullRaise = _kBigBlindBbV1;
      shortAllInThisStreet = false;
      streetBet = {for (final id in preflopOrder) id: 0.0};
      acted = <String>{};
      toAct = nextAfter(null);
    }
  }

  Act0TableLedgerV1 result(Act0TableLedgerStatusV1 status) {
    final price = currentBet - streetBet[heroId]!;
    return Act0TableLedgerV1(
      status: status,
      potBb: total.values.fold(0.0, (sum, value) => sum + value),
      liveSeatIds: {...live},
      nextActorSeatId: toAct,
      heroPriceBb: price < 0 ? 0 : price,
      streetLabel: _kLedgerStreetsV1[street],
      problems: List.unmodifiable(problems),
    );
  }

  final tableStreet = _kLedgerStreetsV1.indexOf(table.streetLabel);
  if (tableStreet < 0) {
    problems.add('unknown street "${table.streetLabel}"');
    return result(Act0TableLedgerStatusV1.unexplained);
  }

  String? terminalActor;
  var anyAction = false;
  for (final item in table.actionTrail) {
    if (item.isNote) continue;
    if (terminalActor != null) {
      problems.add('"${item.label}" follows the end of the trail');
      continue;
    }
    var text = item.label.trim();
    final antes = _antesV1.firstMatch(text);
    if (antes != null) {
      if (anyAction) {
        problems.add('"${item.label}" must come before any action');
      }
      final ante = double.parse(antes.group(1)!);
      for (final id in preflopOrder) {
        total[id] = total[id]! + ante;
      }
      continue;
    }
    final prefix = _streetPrefixV1.firstMatch(text);
    if (prefix != null) {
      final target = _kLedgerStreetsV1.indexOf(prefix.group(1)!);
      if (target < street) {
        problems.add('"${item.label}" goes back to an earlier street');
      }
      moveToStreet(target, text);
      text = text.substring(prefix.end);
    }
    final dealt = _streetDealtV1.firstMatch(text);
    if (dealt != null) {
      final target = _kLedgerStreetsV1.indexOf(dealt.group(1)!);
      if (target <= street) {
        problems.add('"${item.label}" does not move to a later street');
      }
      moveToStreet(target, text);
      continue;
    }
    final match = _actionItemV1.firstMatch(text);
    final actor = match == null
        ? null
        : seatIdByLabel[match.group(1)!.toUpperCase()];
    if (match == null || actor == null || !total.containsKey(actor)) {
      problems.add('not a replayable action: "${item.label}"');
      return result(Act0TableLedgerStatusV1.narrative);
    }
    final verb = match.group(2)!;
    final amount = match.group(3) == null
        ? null
        : double.parse(match.group(3)!);
    final isIncrement = match.group(4) != null;

    if (verb == 'blind') {
      if (street != 0 ||
          anyAction ||
          amount == null ||
          !_sameBbV1(streetBet[actor]!, amount)) {
        problems.add('"${item.label}" does not match the posted blind');
      }
      continue;
    }
    anyAction = true;
    // A condensed trail may skip straight to the next street once the round
    // is closed, as in "BB calls 3 BB" followed by "BB checks". An explicit
    // street prefix always wins over this inference.
    if (prefix == null &&
        verb != 'acts' &&
        roundClosed() &&
        street < tableStreet) {
      moveToStreet(street + 1, item.label);
    }
    // Seats the trail skips must already be authored as folded.
    var guard = 0;
    while (toAct != null && toAct != actor && guard < preflopOrder.length) {
      final skipped = seatById[toAct]!;
      if (skipped.isFolded && !skipped.isInHand) {
        live.remove(toAct);
        acted.add(toAct!);
        toAct = nextAfter(toAct);
      } else {
        problems.add('"${item.label}" skips $toAct, who is still in the hand');
        break;
      }
      guard += 1;
    }
    if (!live.contains(actor)) {
      problems.add('"${item.label}": $actor already folded');
    } else if (allIn.contains(actor)) {
      problems.add('"${item.label}": $actor is already all-in');
    } else if (toAct != actor) {
      problems.add('"${item.label}": $actor acts out of turn');
    }
    if (verb == 'acts') {
      terminalActor = actor;
      continue;
    }
    voluntaryActions += 1;
    final owed = currentBet - streetBet[actor]!;
    switch (verb) {
      case 'folds':
        live.remove(actor);
      case 'checks':
        if (owed > _kLedgerEpsilonV1) {
          problems.add('"${item.label}" checks facing ${_bbV1(owed)} BB');
        }
      case 'calls':
        if (owed <= _kLedgerEpsilonV1) {
          problems.add('"${item.label}" calls with no bet to call');
        }
        final stated = amount;
        if (stated != null &&
            !(isIncrement
                ? _sameBbV1(stated, owed)
                : _sameBbV1(stated, currentBet))) {
          problems.add(
            '"${item.label}" states ${_bbV1(stated)} BB; the call is '
            '${_bbV1(owed)} BB more, to ${_bbV1(currentBet)} BB',
          );
        }
        total[actor] = total[actor]! + owed;
        streetBet[actor] = currentBet;
      default:
        if (amount == null || isIncrement) {
          problems.add('"${item.label}" needs a street-total amount');
          break;
        }
        final shove = verb == 'shoves';
        if (shove && _behindBbV1(seatById[actor]!) != 0) {
          problems.add(
            '"${item.label}" is not an all-in: no authored stack shows '
            '$actor with nothing behind',
          );
        }
        if (verb == 'bets' && currentBet > _kLedgerEpsilonV1) {
          problems.add('"${item.label}" bets facing a bet; that is a raise');
        }
        if (verb == 'bets' && !shove && amount < _kBigBlindBbV1) {
          problems.add(
            '"${item.label}" is below the minimum ${_bbV1(_kBigBlindBbV1)} '
            'BB bet',
          );
        }
        final isRaise = verb == 'opens' || verb.startsWith('raises');
        final minimumTo = currentBet + lastFullRaise;
        if (isRaise && amount < minimumTo - _kLedgerEpsilonV1) {
          problems.add(
            '"${item.label}" is below the minimum raise to '
            '${_bbV1(minimumTo)} BB',
          );
        }
        if (shove && amount <= currentBet + _kLedgerEpsilonV1) {
          problems.add(
            '"${item.label}": an all-in for no more than the current bet '
            'creates a side pot, outside this contract',
          );
        }
        if ((isRaise || (shove && currentBet > _kLedgerEpsilonV1)) &&
            shortAllInThisStreet) {
          problems.add(
            '"${item.label}" raises after a short all-in; reopening is '
            'outside this contract',
          );
        }
        total[actor] = total[actor]! + amount - streetBet[actor]!;
        streetBet[actor] = amount;
        if (amount > currentBet + _kLedgerEpsilonV1) {
          final increment = amount - currentBet;
          if (increment >= lastFullRaise - _kLedgerEpsilonV1 ||
              currentBet <= _kLedgerEpsilonV1) {
            lastFullRaise = increment < _kBigBlindBbV1
                ? _kBigBlindBbV1
                : increment;
            acted = <String>{};
          } else {
            // A short all-in raises the price without reopening the action.
            shortAllInThisStreet = true;
          }
          currentBet = amount;
        }
        if (shove) {
          allIn.add(actor);
        }
    }
    acted.add(actor);
    toAct = nextAfter(actor);
  }

  if (terminalActor == null && street < tableStreet) {
    moveToStreet(tableStreet, 'table shows ${table.streetLabel}');
  }
  if (street != tableStreet) {
    problems.add(
      'trail reaches ${_kLedgerStreetsV1[street]}; table shows '
      '${table.streetLabel}',
    );
  }

  final ledger = result(Act0TableLedgerStatusV1.certified);
  if (table.actionTrail.where((i) => !i.isNote).isEmpty &&
      (tableStreet > 0 || !_sameBbV1(ledger.potBb, _blindTotalV1(table)))) {
    problems.add('no trail explains a ${table.streetLabel} pot');
    return result(Act0TableLedgerStatusV1.unexplained);
  }

  final pot = _potLabelV1.firstMatch(table.potLabel.trim());
  if (pot == null) {
    problems.add('pot label "${table.potLabel}" is not one gross pot');
  } else if (!_sameBbV1(double.parse(pot.group(1)!), ledger.potBb)) {
    problems.add(
      '${table.potLabel} but contributions total ${_bbV1(ledger.potBb)} BB',
    );
  }

  final heroToAct = ledger.nextActorSeatId == heroId;
  final toCall = _toCallLabelV1.firstMatch(table.toCallLabel.trim());
  if (table.toCallLabel.trim().isNotEmpty && toCall == null) {
    problems.add('"${table.toCallLabel}" is not a call price');
  }
  if (toCall != null) {
    final shown = double.parse(toCall.group(1)!);
    if (!heroToAct) {
      problems.add('${table.toCallLabel} shown, but Hero is not to act');
    } else if (!_sameBbV1(shown, ledger.heroPriceBb)) {
      problems.add(
        '${table.toCallLabel} but Hero owes ${_bbV1(ledger.heroPriceBb)} BB',
      );
    }
    final heroBehind = _behindBbV1(table.heroSeat);
    if (heroBehind != null && heroBehind < shown - _kLedgerEpsilonV1) {
      problems.add(
        'Hero has ${_bbV1(heroBehind)} BB behind but faces ${_bbV1(shown)} BB',
      );
    }
  }

  final seenCards = <String>{};
  void claimCard(Act0CardStateV1 card, String owner) {
    final key = _cardKeyV1(card);
    if (key != null && !seenCards.add(key)) {
      problems.add('$key appears twice ($owner)');
    }
  }

  for (final card in table.heroCards) {
    claimCard(card, 'Hero');
  }
  for (final card in table.boardCards) {
    claimCard(card, 'board');
  }
  for (final seat in table.seats) {
    final isLive = ledger.liveSeatIds.contains(seat.seatId);
    final shownLive = seat.isInHand && !seat.isFolded;
    if (isLive != shownLive) {
      problems.add(
        '${seat.seatId} is ${isLive ? 'live' : 'out'} in the history but '
        '${shownLive ? 'live' : 'out'} on the table',
      );
    }
    final betLabel = seat.bet?.amountLabel ?? seat.currentBetLabel;
    if (betLabel != null && betLabel.trim().isNotEmpty) {
      final shown = _amountLabelV1.firstMatch(betLabel.trim());
      final committed = streetBet[seat.seatId]!;
      final deadBlind =
          street == 0 &&
          (seat.isSmallBlind || seat.isBigBlind) &&
          seat.bet?.kind == Act0SeatBetKindV1.post;
      if ((!isLive || !shownLive) && !deadBlind) {
        problems.add('${seat.seatId} shows a $betLabel bet but is out');
      }
      if (shown == null ||
          !_sameBbV1(double.parse(shown.group(1)!), committed)) {
        problems.add(
          '${seat.seatId} shows $betLabel; it has ${_bbV1(committed)} BB in '
          'this street',
        );
      }
    }
    final revealed =
        !seat.isHero && seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp;
    if (!revealed) continue;
    final keys = seat.holeCards.map(_cardKeyV1).toList();
    if (keys.length != 2 || keys.any((k) => k == null)) {
      problems.add('${seat.seatId} is face up without two real cards');
    }
    for (final card in seat.holeCards) {
      claimCard(card, seat.seatId);
    }
    if (!isLive) {
      problems.add('${seat.seatId} shows cards but is not in the hand');
    } else if (ledger.nextActorSeatId != null && !allIn.contains(seat.seatId)) {
      problems.add('${seat.seatId} shows cards while betting is still open');
    }
  }

  // A completed river is a showdown among every live seat; naming a winner
  // needs every live hand on the table.
  final showdown =
      street == 3 && ledger.nextActorSeatId == null && terminalActor == null;
  if (showdown) {
    for (final id in ledger.liveSeatIds) {
      final seat = seatById[id]!;
      if (!seat.isHero &&
          seat.cardsVisibleMode != Act0CardsVisibleModeV1.faceUp) {
        problems.add('showdown, but live $id has hidden cards');
      }
    }
  }

  if (table.scope == Act0TableScopeV1.orientation) {
    if (tableStreet != 0 || voluntaryActions > 0) {
      problems.add('an orientation frame shows only seats and posted blinds');
    }
    return result(
      problems.isEmpty
          ? Act0TableLedgerStatusV1.orientation
          : Act0TableLedgerStatusV1.conflict,
    );
  }

  return result(
    problems.isEmpty
        ? Act0TableLedgerStatusV1.certified
        : Act0TableLedgerStatusV1.conflict,
  );
}

/// An explanation diagram is not a played hand: its trail holds notes only,
/// and it is checked against what it states. With chip claims, the pots are
/// rebuilt from the stated commitments (all-in layers, folded money dead) and
/// must equal the claimed amounts and eligible seats. Without chip claims it
/// may show only the posted blinds.
Act0TableLedgerV1 _explanationLedgerV1(Act0TableStateV1 table) {
  final problems = <String>[];
  final live = {
    for (final seat in table.seats)
      if (seat.isInHand && !seat.isFolded) seat.seatId,
  };
  double potBb = 0;
  for (final item in table.actionTrail) {
    if (!item.isNote) {
      problems.add('explanation trail item "${item.label}" is not a note');
    }
  }
  final claims = table.chipExplanation;
  if (claims == null) {
    potBb = _blindTotalV1(table);
    final pot = _potLabelV1.firstMatch(table.potLabel.trim());
    if (pot == null || !_sameBbV1(double.parse(pot.group(1)!), potBb)) {
      problems.add('${table.potLabel} is not the posted blinds');
    }
    if (table.toCallLabel.trim().isNotEmpty) {
      problems.add('an explanation without chip claims shows no price');
    }
  } else {
    final contributions = claims.contributions;
    potBb = contributions.values.fold(0.0, (sum, v) => sum + v);
    final claimedTotal = claims.pots.fold(0.0, (sum, p) => sum + p.amountBb);
    if (!_sameBbV1(potBb, claimedTotal)) {
      problems.add(
        'claimed pots total ${_bbV1(claimedTotal)} BB; commitments total '
        '${_bbV1(potBb)} BB',
      );
    }
    final single = _potLabelV1.firstMatch(table.potLabel.trim());
    final split = _splitPotLabelV1.firstMatch(table.potLabel.trim());
    final shown = single != null
        ? [double.parse(single.group(1)!)]
        : split != null
        ? [double.parse(split.group(1)!), double.parse(split.group(2)!)]
        : const <double>[];
    if (shown.length != claims.pots.length ||
        [
          for (var i = 0; i < shown.length; i++)
            _sameBbV1(shown[i], claims.pots[i].amountBb),
        ].contains(false)) {
      problems.add('pot label "${table.potLabel}" does not show the pots');
    }
    // Rebuild the pots: one layer per all-in cap, then the rest. Folded chips
    // stay in the layers they reach; only live seats at a layer can win it.
    final caps = {
      for (final id in claims.allInSeatIds) contributions[id] ?? 0.0,
    }.toList()..sort();
    final top = contributions.values.fold(0.0, (m, v) => v > m ? v : m);
    if (caps.isEmpty || caps.last < top - _kLedgerEpsilonV1) caps.add(top);
    final rebuilt = <Act0PotClaimV1>[];
    var floor = 0.0;
    for (final cap in caps) {
      var amount = 0.0;
      final eligible = <String>{};
      contributions.forEach((id, c) {
        final share = (c < cap ? c : cap) - floor;
        if (share > _kLedgerEpsilonV1) amount += share;
        if (c >= cap - _kLedgerEpsilonV1 &&
            !claims.foldedSeatIds.contains(id)) {
          eligible.add(id);
        }
      });
      if (amount > _kLedgerEpsilonV1) {
        rebuilt.add(
          Act0PotClaimV1(amountBb: amount, eligibleSeatIds: eligible),
        );
      }
      floor = cap;
    }
    if (rebuilt.length != claims.pots.length) {
      problems.add(
        'the commitments make ${rebuilt.length} pots, not '
        '${claims.pots.length}',
      );
    } else {
      for (var i = 0; i < rebuilt.length; i++) {
        final r = rebuilt[i];
        final c = claims.pots[i];
        if (!_sameBbV1(r.amountBb, c.amountBb)) {
          problems.add(
            'pot ${i + 1} is ${_bbV1(r.amountBb)} BB, claimed '
            '${_bbV1(c.amountBb)} BB',
          );
        }
        if (r.eligibleSeatIds.length != c.eligibleSeatIds.length ||
            !r.eligibleSeatIds.containsAll(c.eligibleSeatIds)) {
          problems.add(
            'pot ${i + 1} can be won by ${r.eligibleSeatIds.toList()..sort()}, '
            'claimed ${c.eligibleSeatIds.toList()..sort()}',
          );
        }
      }
    }
    for (final id in claims.foldedSeatIds) {
      if (live.contains(id)) {
        problems.add('$id folded in the claims but is live on the table');
      }
    }
    for (final id in contributions.keys) {
      if (!claims.foldedSeatIds.contains(id) && !live.contains(id)) {
        problems.add('$id is in the claims but out on the table');
      }
    }
  }
  return Act0TableLedgerV1(
    status: problems.isEmpty
        ? Act0TableLedgerStatusV1.explanatory
        : Act0TableLedgerStatusV1.conflict,
    potBb: potBb,
    liveSeatIds: live,
    nextActorSeatId: null,
    heroPriceBb: 0,
    streetLabel: table.streetLabel,
    problems: List.unmodifiable(problems),
  );
}

double _blindTotalV1(Act0TableStateV1 table) => table.seats.fold(
  0.0,
  (sum, seat) =>
      sum +
      (seat.isSmallBlind
          ? 0.5
          : seat.isBigBlind
          ? _kBigBlindBbV1
          : 0.0),
);
