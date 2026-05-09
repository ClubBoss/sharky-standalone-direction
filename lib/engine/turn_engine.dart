enum TurnStatus { idle, waitingForPlayer }

class TurnEngine {
  const TurnEngine({required this.activeSeat, required this.status});

  final int activeSeat;
  final TurnStatus status;

  TurnEngine next(List<int> seats) {
    if (seats.isEmpty) {
      return this;
    }
    final index = seats.indexOf(activeSeat);
    final nextIndex = index < 0 ? 0 : (index + 1) % seats.length;
    final nextSeat = seats[nextIndex];
    return TurnEngine(activeSeat: nextSeat, status: status);
  }
}
