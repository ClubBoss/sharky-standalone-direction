import 'package:poker_analyzer/ui_v2/act0_shell/act0_shell_state_v1.dart';

/// Table Truth ledger: replays an authored table's action trail under ordinary
/// no-ante, no-rake rules and checks that the shown pot, price, live seats,
/// bets and next actor follow from it.
///
/// It certifies only what the trail explains. It never infers folds from a pot
/// size and never invents contributions: a seat the trail skips must already be
/// authored as folded, and a postflop frame with no trail is unexplained.
///
/// Trail grammar (one item per action, amounts in BB):
///   `SB blind 0.5 BB`, `UTG folds`, `HJ checks`, `CO calls 2.5 BB` (street
///   total) or `CO calls 2 BB more` (increment), `CO opens 2.5 BB`,
///   `BTN raises to 7 BB`, `HJ bets 5 BB`, `BTN shoves 20 BB`, `BTN acts`
///   (the seat now to act; ends the trail). A `Flop: ` / `Turn: ` / `River: `
///   prefix or a `Flop dealt` item moves to that street. Blinds are posted from
///   the seat flags even when the trail omits them.
enum Act0TableLedgerStatusV1 {
  /// The trail is a legal history and the table shows exactly its result.
  certified,

  /// The trail parses, but the table or the history breaks a rule.
  conflict,

  /// The table shows chips or a later street that no trail explains.
  unexplained,

  /// A trail item is prose, not an action this ledger can replay.
  narrative,
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
}

const _kLedgerStreetsV1 = <String>['Preflop', 'Flop', 'Turn', 'River'];
const _kLedgerEpsilonV1 = 1e-9;

final _streetPrefixV1 = RegExp(r'^(Flop|Turn|River):\s*');
final _streetDealtV1 = RegExp(r'^(Flop|Turn|River) dealt$');
final _actionItemV1 = RegExp(
  r'^(\S+) (blind|folds|checks|calls|opens|raises to|raises|bets|shoves|acts)'
  r'(?: (\d+(?:\.\d+)?) BB)?( more)?$',
);
final _potLabelV1 = RegExp(r'^Pot (\d+(?:\.\d+)?) BB$');
final _toCallLabelV1 = RegExp(r'^To call (\d+(?:\.\d+)?) BB$');
final _amountLabelV1 = RegExp(r'^(\d+(?:\.\d+)?) BB$');

bool _sameBbV1(double a, double b) => (a - b).abs() < _kLedgerEpsilonV1;

String _bbV1(double value) {
  final rounded = value.roundToDouble();
  return _sameBbV1(value, rounded) ? '${rounded.toInt()}' : '$value';
}

Act0TableLedgerV1 act0TableLedgerForV1(Act0TableStateV1 table) {
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
  for (final id in preflopOrder) {
    final seat = seatById[id]!;
    final blind = seat.isSmallBlind
        ? 0.5
        : seat.isBigBlind
        ? 1.0
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
  for (final item in table.actionTrail) {
    var text = item.label.trim();
    final prefix = _streetPrefixV1.firstMatch(text);
    if (prefix != null) {
      moveToStreet(_kLedgerStreetsV1.indexOf(prefix.group(1)!), text);
      text = text.substring(prefix.end);
    }
    final dealt = _streetDealtV1.firstMatch(text);
    if (dealt != null) {
      moveToStreet(_kLedgerStreetsV1.indexOf(dealt.group(1)!), text);
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
      if (street != 0 || amount == null || !_sameBbV1(total[actor]!, amount)) {
        problems.add('"${item.label}" does not match the posted blind');
      }
      continue;
    }
    // A condensed trail may skip straight to the next street once the round
    // is closed, as in "BB calls 3 BB" followed by "BB checks".
    if (verb != 'acts' && roundClosed() && street < tableStreet) {
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
    } else if (toAct != actor) {
      problems.add('"${item.label}": $actor acts out of turn');
    }
    if (verb == 'acts') {
      terminalActor = actor;
      break;
    }
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
        if (verb == 'bets' && currentBet > _kLedgerEpsilonV1) {
          problems.add('"${item.label}" bets facing a bet; that is a raise');
        }
        if ((verb == 'opens' || verb.startsWith('raises')) &&
            amount <= currentBet + _kLedgerEpsilonV1) {
          problems.add('"${item.label}" is not above the current bet');
        }
        total[actor] = total[actor]! + amount - streetBet[actor]!;
        streetBet[actor] = amount;
        if (amount > currentBet) {
          currentBet = amount;
          acted = <String>{};
        }
        if (verb == 'shoves') {
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
  if (table.actionTrail.isEmpty &&
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
  if (toCall != null) {
    final shown = double.parse(toCall.group(1)!);
    if (!heroToAct) {
      problems.add('${table.toCallLabel} shown, but Hero is not to act');
    } else if (!_sameBbV1(shown, ledger.heroPriceBb)) {
      problems.add(
        '${table.toCallLabel} but Hero owes ${_bbV1(ledger.heroPriceBb)} BB',
      );
    }
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
        !seat.isHero &&
        seat.cardsVisibleMode == Act0CardsVisibleModeV1.faceUp &&
        seat.holeCards.isNotEmpty;
    if (revealed && !isLive) {
      problems.add('${seat.seatId} shows cards but is not in the hand');
    } else if (revealed &&
        ledger.nextActorSeatId != null &&
        !allIn.contains(seat.seatId)) {
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

  return result(
    problems.isEmpty
        ? Act0TableLedgerStatusV1.certified
        : Act0TableLedgerStatusV1.conflict,
  );
}

double _blindTotalV1(Act0TableStateV1 table) => table.seats.fold(
  0.0,
  (sum, seat) =>
      sum +
      (seat.isSmallBlind
          ? 0.5
          : seat.isBigBlind
          ? 1.0
          : 0.0),
);
