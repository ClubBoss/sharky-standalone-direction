class SidePot {
  const SidePot(this.amount, this.eligibleSeats);

  final double amount;
  final List<int> eligibleSeats;
}

class SidePotEngine {
  const SidePotEngine();

  List<SidePot> buildSidePots(List<double> contributions) {
    final indexed = <int, double>{};
    for (var i = 0; i < contributions.length; i++) {
      final value = contributions[i];
      if (value > 0) {
        indexed[i] = value;
      }
    }
    if (indexed.isEmpty) {
      return const [];
    }
    final levels = indexed.values.toSet().toList()..sort();
    var prev = 0.0;
    final pots = <SidePot>[];
    for (final level in levels) {
      final slice = level - prev;
      final eligible = indexed.keys
          .where((seat) => (indexed[seat] ?? 0) >= level)
          .toList();
      if (eligible.isEmpty) {
        prev = level;
        continue;
      }
      pots.add(SidePot(slice * eligible.length, eligible));
      prev = level;
    }
    return pots;
  }
}
