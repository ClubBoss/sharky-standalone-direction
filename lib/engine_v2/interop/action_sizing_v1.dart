class ActionSizingV1 {
  const ActionSizingV1._();
  static const int _bbUnitsV1 = 2; // 1 BB = 2 units (1 unit = 0.5 BB)
  static const int _maxDefaultRaiseBbV1 = 6;

  static int _defaultRaiseToCapV1() => _bbUnitsV1 * _maxDefaultRaiseBbV1;

  static int _capToStack({required int amount, required int stack}) {
    if (stack <= 0) return 0;
    if (amount < 1) return 1;
    return amount > stack ? stack : amount;
  }

  // BET sizing: 1/3 pot, rounded to chips, min 1, capped by stack.
  static int deterministicBet({required int pot, required int stack}) {
    return deterministicBetThirdPot(pot: pot, stack: stack);
  }

  static int deterministicBetThirdPot({required int pot, required int stack}) {
    final raw = (pot / 3).round();
    return _capToStack(amount: raw, stack: stack);
  }

  static int deterministicBetHalfPot({required int pot, required int stack}) {
    final raw = (pot / 2).round();
    return _capToStack(amount: raw, stack: stack);
  }

  static int deterministicBetPot({required int pot, required int stack}) {
    return _capToStack(amount: pot, stack: stack);
  }

  // RAISE sizing: raiseTo=max(minRaiseTo, currentBet + toCall), capped by stack+committed.
  static int deterministicRaiseTo({
    required int minRaiseTo,
    required int currentBet,
    required int toCall,
    required int stack,
    required int committed,
  }) {
    final cap = stack + committed;
    if (cap <= currentBet) {
      return currentBet;
    }
    final candidateA = minRaiseTo;
    final candidateB = currentBet + toCall;
    var raiseTo = candidateA > candidateB ? candidateA : candidateB;
    final reasonableCap = minRaiseTo > _defaultRaiseToCapV1()
        ? minRaiseTo
        : _defaultRaiseToCapV1();
    if (raiseTo > reasonableCap) {
      raiseTo = reasonableCap;
    }
    if (raiseTo > cap) {
      raiseTo = cap;
    }
    if (raiseTo < currentBet + 1) {
      raiseTo = currentBet + 1;
    }
    return raiseTo;
  }

  static int deterministicRaiseToDoubleCurrentBet({
    required int currentBet,
    required int stack,
    required int committed,
  }) {
    final cap = stack + committed;
    if (cap <= currentBet) {
      return currentBet;
    }
    var raiseTo = currentBet * 2;
    if (raiseTo > _defaultRaiseToCapV1()) {
      raiseTo = _defaultRaiseToCapV1();
    }
    if (raiseTo > cap) {
      raiseTo = cap;
    }
    if (raiseTo < currentBet + 1) {
      raiseTo = currentBet + 1;
    }
    return raiseTo;
  }

  static int deterministicRaiseToPot({
    required int currentBet,
    required int toCall,
    required int pot,
    required int stack,
    required int committed,
  }) {
    final cap = stack + committed;
    if (cap <= currentBet) {
      return currentBet;
    }
    // Pot raise approximation as raise-to target.
    var raiseTo = currentBet + toCall + pot;
    final floor = currentBet + toCall;
    final reasonableCap = floor > _defaultRaiseToCapV1()
        ? floor
        : _defaultRaiseToCapV1();
    if (raiseTo > reasonableCap) {
      raiseTo = reasonableCap;
    }
    if (raiseTo > cap) {
      raiseTo = cap;
    }
    if (raiseTo < currentBet + 1) {
      raiseTo = currentBet + 1;
    }
    return raiseTo;
  }
}
