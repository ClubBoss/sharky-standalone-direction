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
  if (!hand.seats.any((seat) => seat.number == hand.heroSeat) ||
      !hand.seats.any((seat) => seat.number == hand.buttonSeat)) {
    return 'The button and your seat must both be occupied.';
  }
  final ledger = Act0HandBettingLedgerV1(
    hand.seats,
    hand.tableSize,
    hand.buttonSeat,
    hand.smallBlindCents,
    hand.bigBlindCents,
  );
  final lastStreet = _boardCount.indexOf(hand.board.length);
  for (final (index, action) in hand.actions.indexed) {
    if (action.street.index > lastStreet)
      return 'An action refers to a street without board cards.';
    while (ledger.street.index < action.street.index) {
      if (!ledger.advance())
        return 'Finish betting and record any uncalled return before the next street.';
    }
    if (!ledger.add(_bettingAction(action))) {
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
