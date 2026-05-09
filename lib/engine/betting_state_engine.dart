import 'dart:math' show max;

import 'stack_state_engine.dart';

class BettingStateEngine {
  BettingStateEngine(this.seatCount, this.stack)
    : contributed = List<double>.filled(seatCount, 0.0);

  final int seatCount;
  final List<double> contributed;
  final StackStateEngine stack;
  double callAmount = 0.0;
  double pot = 0.0;

  double toCall(int seat) => max(0.0, callAmount - contributed[seat]);

  double minRaiseAmount() => callAmount + lastRaise;

  bool canRaise(int seat) => lastRaise > 0 || callAmount > 0;

  void applyFold(int seat) {
    // placeholder, no pot changes yet
  }

  void applyCall(int seat) {
    final c = toCall(seat);
    final actual = stack.take(seat, c);
    contributed[seat] += actual;
    pot += actual;
  }

  void applyRaise(int seat, double amount) {
    final target = max(amount, minRaiseAmount());
    final diff = max(0.0, target - contributed[seat]);
    final actual = stack.take(seat, diff);
    contributed[seat] += actual;
    pot += actual;
    final oldCall = callAmount;
    callAmount = contributed[seat];
    lastRaise = callAmount - oldCall;
  }

  void resetForNextStreet() {
    for (var i = 0; i < seatCount; i++) {
      contributed[i] = 0.0;
    }
    callAmount = 0.0;
    lastRaise = 0.0;
  }

  double lastRaise = 0.0;
}
