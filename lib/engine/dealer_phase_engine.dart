class DealerPhaseResult {
  const DealerPhaseResult({
    required this.dealerSeat,
    required this.smallBlindSeat,
    required this.bigBlindSeat,
    required this.handId,
  });

  final int dealerSeat;
  final int smallBlindSeat;
  final int bigBlindSeat;
  final int handId;
}

class DealerPhaseEngine {
  DealerPhaseEngine({int initialDealer = 0}) : _nextDealer = initialDealer;

  int _nextDealer;
  int _handCounter = 0;

  DealerPhaseResult startNewHand(int seatCount) {
    if (seatCount <= 0) {
      throw ArgumentError.value(seatCount, 'seatCount', 'must be positive');
    }
    final dealerSeat = _nextDealer % seatCount;
    final smallBlindSeat = (dealerSeat + 1) % seatCount;
    final bigBlindSeat = (dealerSeat + 2) % seatCount;
    final result = DealerPhaseResult(
      dealerSeat: dealerSeat,
      smallBlindSeat: smallBlindSeat,
      bigBlindSeat: bigBlindSeat,
      handId: _handCounter,
    );
    _handCounter++;
    _nextDealer = (dealerSeat + 1) % seatCount;
    return result;
  }
}
