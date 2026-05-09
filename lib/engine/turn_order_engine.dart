class TurnOrderEngine {
  const TurnOrderEngine(this.maxSeats);

  final int maxSeats;

  int nextSeat(int current) => (current + 1) % maxSeats;
}
