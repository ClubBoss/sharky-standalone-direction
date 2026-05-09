import 'dart:math' as math;

import 'betting_state_engine.dart';
import 'stack_state_engine.dart';

class BlindPostingEngine {
  void postBlinds({
    required int smallBlindSeat,
    required int bigBlindSeat,
    required StackStateEngine stacks,
    required BettingStateEngine betting,
    required int smallBlindAmount,
    required int bigBlindAmount,
  }) {
    final sbAmount = math.min(
      smallBlindAmount.toDouble(),
      stacks.stackOf(smallBlindSeat),
    );
    stacks.applyBlind(smallBlindSeat, sbAmount);
    betting.applyBlind(smallBlindSeat, sbAmount);

    final bbAmount = math.min(
      bigBlindAmount.toDouble(),
      stacks.stackOf(bigBlindSeat),
    );
    stacks.applyBlind(bigBlindSeat, bbAmount);
    betting.applyBlind(bigBlindSeat, bbAmount);
  }
}

extension _StackStateBlindSupport on StackStateEngine {
  double stackOf(int seat) => stacks[seat].toDouble();

  void applyBlind(int seat, double amount) {
    take(seat, amount);
  }
}

extension _BettingBlindSupport on BettingStateEngine {
  void applyBlind(int seat, double amount) {
    final oldCall = callAmount;
    final actual = stack.take(seat, amount);
    contributed[seat] += actual;
    pot += actual;
    if (contributed[seat] > callAmount) {
      callAmount = contributed[seat];
      lastRaise = callAmount - oldCall;
    }
  }
}
