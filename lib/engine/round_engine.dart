import 'betting_state_engine.dart';
import 'stack_state_engine.dart';
import 'table_state_engine.dart';

class RoundEngine {
  RoundEngine({required this.seatCount})
    : actedThisRound = List<bool>.filled(seatCount, false);

  final int seatCount;
  final List<bool> actedThisRound;

  void resetRound() => actedThisRound.fillRange(0, seatCount, false);

  void markActed(int seat) {
    if (seat >= 0 && seat < seatCount) {
      actedThisRound[seat] = true;
    }
  }

  bool roundComplete(
    List<int> activeSeats,
    BettingStateEngine betting,
    StackStateEngine stack,
    TableStateEngine table,
  ) {
    for (final seat in activeSeats) {
      if (table.isFolded(seat)) {
        continue;
      }
      if (!actedThisRound[seat]) {
        return false;
      }
      final contribution = betting.contributed[seat];
      if (contribution >= betting.callAmount) {
        continue;
      }
      if (stack.isAllIn(seat)) {
        continue;
      }
      return false;
    }
    return true;
  }

  bool hasActed(int seat) =>
      seat >= 0 && seat < seatCount ? actedThisRound[seat] : false;
}
