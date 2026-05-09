class TableStateEngine {
  TableStateEngine(this.seatCount);

  final int seatCount;
  final Set<int> folded = <int>{};

  bool isFolded(int seat) => folded.contains(seat);

  void markFold(int seat) => folded.add(seat);

  List<int> get activeSeats => List<int>.generate(
    seatCount,
    (i) => i,
  ).where((seat) => !folded.contains(seat)).toList();

  int nextActiveSeat(int from) {
    final a = activeSeats;
    if (a.isEmpty) return from;
    final idx = a.indexOf(from);
    if (idx < 0) {
      return a.first;
    }
    return a[(idx + 1) % a.length];
  }
}
