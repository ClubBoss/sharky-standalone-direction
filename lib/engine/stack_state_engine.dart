class StackStateEngine {
  StackStateEngine(this.seatCount) : stacks = List.filled(seatCount, 100.0);

  final int seatCount;
  final List<double> stacks;

  bool isAllIn(int seat) => stacks[seat] <= 0.0;

  double take(int seat, double amount) {
    final available = stacks[seat];
    final taken = amount.clamp(0, available);
    final takenDouble = taken.toDouble();
    stacks[seat] = (available - takenDouble).clamp(0.0, double.infinity);
    return takenDouble;
  }

  void resetForNextHand() {
    for (var i = 0; i < seatCount; i++) {
      stacks[i] = 100.0;
    }
  }
}
