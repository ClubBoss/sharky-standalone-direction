import 'betting_state_engine.dart';
import 'round_engine.dart';
import 'table_state_engine.dart';

class PreflopActionEngine {
  int nextToAct({
    required int smallBlindSeat,
    required int bigBlindSeat,
    required int utgSeat,
    required TableStateEngine table,
    required BettingStateEngine betting,
    required RoundEngine round,
    required int seatCount,
  }) {
    if (seatCount <= 0) {
      return smallBlindSeat;
    }
    final normalizedSmall = _normalizeSeat(smallBlindSeat, seatCount);
    final normalizedBig = _normalizeSeat(bigBlindSeat, seatCount);
    final normalizedUtg = _normalizeSeat(utgSeat, seatCount);

    if (_needsAction(normalizedSmall, table, betting, round)) {
      return normalizedSmall;
    }
    if (_needsAction(normalizedBig, table, betting, round)) {
      return normalizedBig;
    }
    if (_needsAction(normalizedUtg, table, betting, round)) {
      return normalizedUtg;
    }
    return _fallbackSeat(normalizedUtg, table, round, seatCount);
  }

  bool _needsAction(
    int seat,
    TableStateEngine table,
    BettingStateEngine betting,
    RoundEngine round,
  ) {
    if (!_isEligible(seat, table, betting)) {
      return false;
    }
    if (betting.contributed[seat] >= betting.callAmount) {
      return false;
    }
    return true;
  }

  bool _isEligible(
    int seat,
    TableStateEngine table,
    BettingStateEngine betting,
  ) {
    if (seat < 0) return false;
    if (table.isFolded(seat)) return false;
    if (betting.stack.isAllIn(seat)) return false;
    return true;
  }

  int _fallbackSeat(
    int from,
    TableStateEngine table,
    RoundEngine round,
    int seatCount,
  ) {
    final active = table.activeSeats;
    if (active.isEmpty) {
      return from;
    }
    var startIndex = active.indexOf(from);
    if (startIndex < 0) {
      startIndex = 0;
    }
    for (var offset = 0; offset < active.length; offset++) {
      final candidate = active[(startIndex + offset) % active.length];
      if (round.hasActed(candidate)) continue;
      return candidate;
    }
    return active[startIndex % active.length];
  }

  int _normalizeSeat(int seat, int seatCount) {
    if (seatCount <= 0) return 0;
    return seat % seatCount;
  }
}
