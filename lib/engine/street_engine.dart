enum Street { preflop, flop, turn, river, showdown }

class StreetEngine {
  const StreetEngine(this.current);

  final Street current;

  StreetEngine advanceStreet() {
    switch (current) {
      case Street.preflop:
        return const StreetEngine(Street.flop);
      case Street.flop:
        return const StreetEngine(Street.turn);
      case Street.turn:
        return const StreetEngine(Street.river);
      case Street.river:
        return const StreetEngine(Street.showdown);
      case Street.showdown:
        return const StreetEngine(Street.showdown);
    }
  }
}
