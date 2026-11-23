import 'dart:math';

import 'package:poker_analyzer/models/poker_street.dart';

import 'act0_hand_contributions_v1.dart';
import 'act0_seat_order_v1.dart';

enum Act0HandVerbV1 {
  smallBlind('Small blind'),
  bigBlind('Big blind'),
  fold('Fold'),
  check('Check'),
  call('Call'),
  bet('Bet'),
  raise('Raise'),
  uncalledReturn('Uncalled return'),
  ante('Ante');

  const Act0HandVerbV1(this.label);
  final String label;
}

/// Replays betting for a dealt-in ring. Importers can impose additional
/// restrictions on the source formats they accept.
class Act0HandBettingLedgerV1 {
  Act0HandBettingLedgerV1(
    List<({int number, int stackCents})> seats,
    this.tableSize,
    this.buttonSeat,
    this.smallBlind,
    this.bigBlind, {
    this.allowShortRaises = false,
  }) : remaining = {for (final seat in seats) seat.number: seat.stackCents},
       _seatOrder = Act0SeatOrderV1(
         seats.map((seat) => seat.number).toList()..sort(),
         buttonSeat,
       ),
       liveSeats = {for (final seat in seats) seat.number},
       _lastSeat = buttonSeat,
       _raiseMinimum = bigBlind {
    if (!act0PreflopPositionsByCountV1.containsKey(tableSize) ||
        seats.any((seat) => seat.number < 1 || seat.number > tableSize)) {
      throw const FormatException('Seat number outside the table');
    }
  }

  final Act0SeatOrderV1<int> _seatOrder;
  final bool allowShortRaises;
  final int tableSize, buttonSeat, smallBlind, bigBlind;
  final Map<int, int> remaining;
  final Set<int> liveSeats;
  final Map<int, int> _streetCents = {};
  final Map<int, int> _totalCents = {};

  int _anteCents = 0;

  /// Current contestable amounts in exact integer units, excluding uncalled
  /// excess. Once betting settles and returns are recorded, these sum to potCents.
  List<({int amountCents, Set<int> eligibleSeats})> get pots {
    if (complete && liveSeats.length == 1) {
      return [
        (amountCents: potCents, eligibleSeats: {...liveSeats}),
      ];
    }
    final contestable = act0ContestablePotsV1(
      _totalCents,
      liveSeats: liveSeats,
      deadChips: _anteCents,
    );
    return [
      for (final pot in contestable ?? const [])
        (amountCents: pot.amount.toInt(), eligibleSeats: pot.eligibleSeats),
    ];
  }

  bool get hasSidePot => pots.length > 1;

  final Map<int, PokerStreet> folds = {};
  PokerStreet street = PokerStreet.preflop;
  int potCents = 0;
  int _lastSeat, _raiseMinimum;
  int? _smallBlindSeat, _bigBlindSeat;
  int? get smallBlindSeat => _smallBlindSeat;
  int? get bigBlindSeat => _bigBlindSeat;
  Set<int>? _pending;
  final Map<int, ({int price, int minimum})> _actedAt = {};
  final Set<int> _anteSeats = {};
  bool _refunded = false;
  bool _voluntaryWager = false;

  int contributed(int seat) => _streetCents[seat] ?? 0;
  int get highest => _streetCents.values.fold(0, (a, b) => a > b ? a : b);
  Iterable<int> get _funded => liveSeats.where((seat) => remaining[seat]! > 0);
  Set<int> get _eligible => _pending ?? _funded.toSet();
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
    _actedAt.clear();
    _refunded = false;
    _lastSeat = buttonSeat;
    _raiseMinimum = bigBlind;
    return true;
  }

  int? get nextActor => _settled || _bigBlindSeat == null
      ? null
      : _seatOrder.nextAfter(_lastSeat, eligible: _eligible);

  bool add(
    ({PokerStreet street, int seat, Act0HandVerbV1 kind, int cents}) action,
  ) {
    final (street: actionStreet, :seat, :kind, :cents) = action;
    final stack = remaining[seat];
    if (actionStreet != street ||
        stack == null ||
        !liveSeats.contains(seat) ||
        cents < 0 ||
        _refunded) {
      return false;
    }
    if (kind == Act0HandVerbV1.uncalledReturn) {
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
    if (kind == Act0HandVerbV1.ante) {
      if (street != PokerStreet.preflop ||
          _pending != null ||
          cents <= 0 ||
          cents == stack ||
          !_anteSeats.add(seat)) {
        return false;
      }
      remaining[seat] = stack - cents;
      _anteCents += cents;
      potCents += cents;
      return true;
    }
    if (kind == Act0HandVerbV1.smallBlind || kind == Act0HandVerbV1.bigBlind) {
      if (_bigBlindSeat != null || stack <= cents) return false;
      if (kind == Act0HandVerbV1.smallBlind) {
        if (_smallBlindSeat != null ||
            cents != smallBlind ||
            seat != _seatOrder.smallBlind) {
          return false;
        }
        _smallBlindSeat = seat;
      } else {
        if (_smallBlindSeat == null ||
            seat != _seatOrder.bigBlind ||
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
    final next = _seatOrder.nextAfter(_lastSeat, eligible: pending);
    if (seat != next) return false;
    final due = highest - contributed(seat);
    final raises = kind == Act0HandVerbV1.bet || kind == Act0HandVerbV1.raise;
    final fullRaise = cents - due >= _raiseMinimum;
    final shortAllIn = allowShortRaises && cents == stack && cents > due;
    // Several short all-ins can reopen action once the price increase reaches
    // the full raise that applied when this seat last acted.
    final previous = _actedAt[seat];
    final canRaise =
        previous == null || highest - previous.price >= previous.minimum;
    final legal = switch (kind) {
      Act0HandVerbV1.fold => cents == 0,
      Act0HandVerbV1.check => due == 0 && cents == 0,
      Act0HandVerbV1.call => due > 0 && cents == min(due, stack),
      Act0HandVerbV1.bet => highest == 0 && (fullRaise || shortAllIn),
      Act0HandVerbV1.raise => highest > 0 && (fullRaise || shortAllIn),
      _ => false,
    };
    if (!legal ||
        (raises &&
            (allowShortRaises
                ? !canRaise || _funded.length < 2
                : _funded.length != liveSeats.length))) {
      return false;
    }
    if (kind == Act0HandVerbV1.fold) {
      liveSeats.remove(seat);
      folds[seat] = street;
    }
    if (cents > 0) {
      _voluntaryWager = true;
      _transfer(seat, cents);
    }
    if (raises && fullRaise) {
      _raiseMinimum = cents - due;
      _pending = _funded.toSet();
      _actedAt.clear();
    } else if (raises) {
      _pending!.addAll(_funded.where((other) => contributed(other) < highest));
    }
    _actedAt[seat] = (price: highest, minimum: _raiseMinimum);
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
