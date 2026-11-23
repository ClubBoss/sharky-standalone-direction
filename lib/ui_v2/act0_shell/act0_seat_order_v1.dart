import 'package:poker_analyzer/models/poker_street.dart';

/// Position names in clockwise order, starting with the first preflop actor.
/// At a heads-up table BTN also posts the small blind.
const act0PreflopPositionsByCountV1 = <int, List<String>>{
  2: ['BTN', 'BB'],
  3: ['BTN', 'SB', 'BB'],
  4: ['CO', 'BTN', 'SB', 'BB'],
  5: ['HJ', 'CO', 'BTN', 'SB', 'BB'],
  6: ['UTG', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
  7: ['UTG', 'LJ', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
  8: ['UTG', 'MP', 'LJ', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
  9: ['UTG', 'UTG+1', 'MP', 'LJ', 'HJ', 'CO', 'BTN', 'SB', 'BB'],
};

/// The clockwise ring of seats dealt into a hand. The order stays fixed after
/// folds or all-ins. Callers supply the seats still eligible to act.
class Act0SeatOrderV1<T extends Object> {
  Act0SeatOrderV1(Iterable<T> clockwiseSeats, this.button)
    : seats = List.unmodifiable(clockwiseSeats) {
    if (!act0PreflopPositionsByCountV1.containsKey(seats.length) ||
        seats.toSet().length != seats.length ||
        !seats.contains(button)) {
      throw const FormatException('Invalid seat order or button');
    }
  }

  final List<T> seats;
  final T button;

  T get smallBlind => seats.length == 2 ? button : nextAfter(button)!;
  T get bigBlind => nextAfter(smallBlind)!;

  Iterable<T> _after(T anchor) sync* {
    final index = seats.indexOf(anchor);
    if (index < 0) throw ArgumentError.value(anchor, 'anchor', 'Unknown seat');
    for (var offset = 1; offset <= seats.length; offset++) {
      yield seats[(index + offset) % seats.length];
    }
  }

  T? nextAfter(T anchor, {Set<T>? eligible}) => _after(
    anchor,
  ).where((seat) => eligible?.contains(seat) ?? true).firstOrNull;

  List<T> actionOrder(PokerStreet street) =>
      _after(street == PokerStreet.preflop ? bigBlind : button).toList();

  Map<T, String> get positions {
    final order = actionOrder(PokerStreet.preflop);
    final labels = act0PreflopPositionsByCountV1[seats.length]!;
    return {for (final (index, seat) in order.indexed) seat: labels[index]};
  }
}
