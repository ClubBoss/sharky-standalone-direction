part of 'act0_imported_hand_v1.dart';

const _boardCount = [0, 3, 4, 5];
const _maxMoneyCents = 999999999;

bool _validHand(Act0ImportedHandV1 hand) => _handError(hand) == null;

String? _handError(Act0ImportedHandV1 hand) {
  if (_readCards(hand.heroCards, 2) == null ||
      _readCards(hand.board, hand.board.length) == null ||
      hand.shownCards.values.any((cards) => _readCards(cards, 2) == null)) {
    return 'Enter cards as rank and suit, for example As Kd.';
  }
  if (hand.actions.length > _maxHandActions) return 'Too many actions.';

  if (hand.tableSize < 2 ||
      hand.tableSize > 9 ||
      hand.seats.length < 2 ||
      hand.seats.length > hand.tableSize ||
      !_boardCount.contains(hand.board.length) ||
      hand.smallBlindCents <= 0 ||
      hand.bigBlindCents <= hand.smallBlindCents ||
      hand.bigBlindCents > _maxMoneyCents) {
    return 'Check the table size, blinds and board card count.';
  }
  var previous = 0;
  for (final seat in hand.seats) {
    if (seat.number <= previous ||
        seat.number > hand.tableSize ||
        seat.stackCents <= 0 ||
        seat.stackCents > _maxMoneyCents) {
      return 'Enter a valid stack for each occupied seat.';
    }
    previous = seat.number;
  }
  final ledger = _HandLedger(
    hand.seats,
    hand.tableSize,
    hand.buttonSeat,
    hand.smallBlindCents,
    hand.bigBlindCents,
  );
  if (!ledger.remaining.containsKey(hand.heroSeat) ||
      !ledger.remaining.containsKey(hand.buttonSeat)) {
    return 'The button and your seat must both be occupied.';
  }
  final lastStreet = _boardCount.indexOf(hand.board.length);
  for (final (index, action) in hand.actions.indexed) {
    if (action.street.index > lastStreet)
      return 'An action refers to a street without board cards.';
    while (ledger.street.index < action.street.index) {
      if (!ledger.advance())
        return 'Finish betting and record any uncalled return before the next street.';
    }
    if (!ledger.add(action)) {
      return 'Action ${index + 1} (${action.street.name}, seat ${action.seat}) '
          'is illegal. Check the action order, chip amount and stack.';
    }
  }
  while (ledger.street.index < lastStreet) {
    if (!ledger.advance())
      return 'Finish betting and record any uncalled return before dealing more cards.';
  }
  if (ledger.hasSidePot) return act0OwnHandSidePotMessageV1;
  if (!ledger.complete) {
    return 'Finish betting and record any uncalled return.';
  }
  if ((hand.showdown
          ? lastStreet != PokerStreet.river.index || ledger.liveSeats.length < 2
          : ledger.liveSeats.length != 1 || hand.shownCards.isNotEmpty) ||
      hand.payouts.isEmpty ||
      (!hand.showdown && hand.payouts.length != 1) ||
      hand.rakeCents < 0 ||
      hand.rakeCents > hand.potCents ||
      hand.potCents != ledger.potCents) {
    return 'The hand must end in a fold or a complete showdown, with payouts and rake.';
  }
  var paid = hand.rakeCents;
  for (final entry in hand.payouts.entries) {
    if (entry.value <= 0 ||
        entry.value > hand.potCents ||
        !ledger.liveSeats.contains(entry.key) ||
        (hand.showdown && !hand.shownCards.containsKey(entry.key))) {
      return 'Each payout must go to a live seat. Record the cards shown by each showdown winner.';
    }
    paid += entry.value;
  }
  if (paid != hand.potCents) return 'Payouts plus rake must equal the pot.';

  final visible = <String>{...hand.heroCards, ...hand.board};
  if (visible.length != hand.heroCards.length + hand.board.length)
    return 'Your cards and the board contain a duplicate card.';
  for (final entry in hand.shownCards.entries) {
    if (!ledger.liveSeats.contains(entry.key))
      return 'Only live seats can show at showdown.';
    if (entry.key == hand.heroSeat) {
      if (entry.value.toSet().length != 2 ||
          !entry.value.every(hand.heroCards.contains)) {
        return 'Your shown cards must match your hole cards.';
      }
    } else if (entry.value.any((card) => !visible.add(card))) {
      return 'A shown card duplicates another known card.';
    }
  }
  if (hand.showdown) {
    final known = {
      ...hand.shownCards,
      if (ledger.liveSeats.contains(hand.heroSeat))
        hand.heroSeat: hand.heroCards,
    };
    final seats = known.keys.toList();
    List<CardModel> cards(List<String> tokens) => [
      for (final token in tokens) CardModel(rank: token[0], suit: token[1]),
    ];
    final winners = HandEvaluator.evaluateShowdown([
      for (final seat in seats) cards(known[seat]!),
    ], cards(hand.board));
    for (final (index, seat) in seats.indexed) {
      if (hand.payouts.containsKey(seat) && !winners.contains(index)) {
        return 'Seat $seat is beaten by another known hand at showdown.';
      }
    }
  }
  return null;
}

/// Replays only the explicitly supported single-pot rules. Used when importing
/// text and when checking a persisted record before exposing it to the archive.
class _HandLedger {
  _HandLedger(
    List<Act0ImportedSeatV1> seats,
    this.tableSize,
    this.buttonSeat,
    this.smallBlind,
    this.bigBlind,
  ) : remaining = {for (final seat in seats) seat.number: seat.stackCents},
      liveSeats = {for (final seat in seats) seat.number},
      _lastSeat = buttonSeat,
      _raiseMinimum = bigBlind;

  final int tableSize, buttonSeat, smallBlind, bigBlind;
  final Map<int, int> remaining;
  final Set<int> liveSeats;
  final Map<int, int> _streetCents = {};
  final Map<int, int> _totalCents = {};

  // Two contributions above a live all-in stack create a second pot.
  // Count folded contributions too, after any uncalled return.
  bool get hasSidePot => liveSeats.any(
    (seat) =>
        remaining[seat] == 0 &&
        _totalCents.values
                .where((total) => total > _totalCents[seat]!)
                .length >=
            2,
  );
  final Map<int, PokerStreet> folds = {};
  PokerStreet street = PokerStreet.preflop;
  int potCents = 0;
  int _lastSeat, _raiseMinimum;
  int? _smallBlindSeat, _bigBlindSeat;
  Set<int>? _pending;
  bool _refunded = false;
  bool _voluntaryWager = false;

  int contributed(int seat) => _streetCents[seat] ?? 0;
  int get highest => _streetCents.values.fold(0, (a, b) => a > b ? a : b);
  Iterable<int> get _funded => liveSeats.where((seat) => remaining[seat]! > 0);
  Set<int> get _eligible => _pending ?? _funded.toSet();
  int _nextSeat(int after, Set<int> candidates) => List.generate(
    tableSize,
    (index) => (after + index) % tableSize + 1,
  ).firstWhere(candidates.contains);
  bool get _settled =>
      liveSeats.length == 1 ||
      _eligible.isEmpty ||
      (_funded.length == 1 && contributed(_funded.single) == highest);

  int _excess(int seat) {
    final other = _streetCents.entries
        .where((entry) => entry.key != seat)
        .fold(0, (max, entry) => entry.value > max ? entry.value : max);
    return contributed(seat) - other;
  }

  bool get complete =>
      _bigBlindSeat != null &&
      _settled &&
      (_refunded || liveSeats.every((seat) => _excess(seat) <= 0));

  bool advance() {
    if (!complete || liveSeats.length < 2 || street == PokerStreet.river) {
      return false;
    }
    street = PokerStreet.values[street.index + 1];
    _streetCents.clear();
    _pending = null;
    _refunded = false;
    _lastSeat = buttonSeat;
    _raiseMinimum = bigBlind;
    return true;
  }

  bool add(Act0ImportedActionV1 action) {
    final (street: actionStreet, :seat, :kind, :cents) = action;
    final stack = remaining[seat];
    if (actionStreet != street ||
        stack == null ||
        !liveSeats.contains(seat) ||
        cents < 0 ||
        _refunded) {
      return false;
    }
    if (kind == Act0ImportedActionKindV1.uncalledReturn) {
      final blindWalk =
          street == PokerStreet.preflop &&
          !_voluntaryWager &&
          liveSeats.length == 1 &&
          seat == _bigBlindSeat &&
          cents == bigBlind;
      if (_bigBlindSeat == null ||
          !_settled ||
          cents <= 0 ||
          (!blindWalk && cents != _excess(seat))) {
        return false;
      }
      _transfer(seat, -cents);
      _refunded = true;
      return true;
    }
    if (cents > stack) return false;
    if (kind == Act0ImportedActionKindV1.smallBlind ||
        kind == Act0ImportedActionKindV1.bigBlind) {
      if (_bigBlindSeat != null || stack <= cents) return false;
      if (kind == Act0ImportedActionKindV1.smallBlind) {
        final expected = liveSeats.length == 2
            ? buttonSeat
            : _nextSeat(buttonSeat, liveSeats);
        if (_smallBlindSeat != null ||
            cents != smallBlind ||
            seat != expected) {
          return false;
        }
        _smallBlindSeat = seat;
      } else {
        if (_smallBlindSeat == null ||
            seat != _nextSeat(_smallBlindSeat!, liveSeats) ||
            cents != bigBlind) {
          return false;
        }
        _bigBlindSeat = seat;
        _lastSeat = seat;
      }
      _transfer(seat, cents);
      return true;
    }

    if (_bigBlindSeat == null || _settled || stack == 0) return false;
    final pending = _pending ??= _funded.toSet();
    final next = _nextSeat(_lastSeat, pending);
    if (seat != next) return false;
    final due = highest - contributed(seat);
    final raises =
        kind == Act0ImportedActionKindV1.bet ||
        kind == Act0ImportedActionKindV1.raise;
    final legal = switch (kind) {
      Act0ImportedActionKindV1.fold => cents == 0,
      Act0ImportedActionKindV1.check => due == 0 && cents == 0,
      Act0ImportedActionKindV1.call => due > 0 && cents == min(due, stack),
      Act0ImportedActionKindV1.bet => highest == 0 && cents >= _raiseMinimum,
      Act0ImportedActionKindV1.raise =>
        highest > 0 && cents - due >= _raiseMinimum,
      _ => false,
    };
    if (!legal || (raises && _funded.length != liveSeats.length)) return false;
    if (kind == Act0ImportedActionKindV1.fold) {
      liveSeats.remove(seat);
      folds[seat] = street;
    }
    if (cents > 0) {
      _voluntaryWager = true;
      _transfer(seat, cents);
    }
    if (raises) {
      _raiseMinimum = cents - due;
      _pending = _funded.toSet();
    }
    _pending!.remove(seat);
    _lastSeat = seat;
    return true;
  }

  void _transfer(int seat, int cents) {
    remaining[seat] = remaining[seat]! - cents;
    _streetCents[seat] = contributed(seat) + cents;
    _totalCents[seat] = (_totalCents[seat] ?? 0) + cents;
    potCents += cents;
  }
}
