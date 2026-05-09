import 'betting_state_engine.dart';
import 'round_engine.dart';
import 'table_state_engine.dart';

class PostflopActionEngine {
  int nextToAct({
    required int currentActiveSeat,
    required TableStateEngine table,
    required BettingStateEngine betting,
    required RoundEngine round,
    required int seatCount,
  }) {
    if (seatCount <= 0) {
      return currentActiveSeat;
    }
    final normalized = _normalizeSeat(currentActiveSeat, seatCount);
    if (_shouldSkipSeat(normalized, table, betting)) {
      return _nextEligibleSeat(normalized, table, betting, round);
    }
    if (!_hasActed(normalized, round) ||
        !_hasMatchedCall(normalized, betting)) {
      return normalized;
    }
    return _nextEligibleSeat(normalized, table, betting, round);
  }

  bool _hasActed(int seat, RoundEngine round) => round.hasActed(seat);

  bool _hasMatchedCall(int seat, BettingStateEngine betting) =>
      betting.contributed[seat] >= betting.callAmount;

  bool _shouldSkipSeat(
    int seat,
    TableStateEngine table,
    BettingStateEngine betting,
  ) {
    if (seat < 0) return true;
    if (table.isFolded(seat)) {
      return true;
    }
    if (betting.stack.isAllIn(seat)) {
      return true;
    }
    return false;
  }

  int _nextEligibleSeat(
    int startSeat,
    TableStateEngine table,
    BettingStateEngine betting,
    RoundEngine round,
  ) {
    final active = table.activeSeats;
    if (active.isEmpty) {
      return startSeat;
    }
    var index = active.indexOf(startSeat);
    if (index < 0) {
      index = 0;
    }
    for (var offset = 0; offset < active.length; offset++) {
      final candidate = active[(index + offset) % active.length];
      if (_shouldSkipSeat(candidate, table, betting)) {
        continue;
      }
      if (!_hasActed(candidate, round) ||
          !_hasMatchedCall(candidate, betting)) {
        return candidate;
      }
    }
    return active[index % active.length];
  }

  int _normalizeSeat(int seat, int seatCount) {
    if (seatCount <= 0) {
      return 0;
    }
    return seat % seatCount;
  }
}
