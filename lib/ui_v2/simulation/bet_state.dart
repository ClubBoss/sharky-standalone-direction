import 'dart:math';

import 'package:poker_analyzer/compat/player_action_compat.dart';

/// Represents the betting state for the current street.
class BetState {
  BetState({
    required this.currentBet,
    required this.totalPot,
    required this.minRaise,
    required this.lastRaiseSize,
    required this.isAllIn,
    Map<int, int>? contributions,
    List<SidePot>? sidePots,
  }) : contributions = Map<int, int>.from(contributions ?? const {}),
       sidePots = List<SidePot>.from(sidePots ?? const []);

  factory BetState.initial({required int bigBlind}) {
    return BetState(
      currentBet: 0,
      totalPot: 0,
      minRaise: bigBlind,
      lastRaiseSize: bigBlind,
      isAllIn: false,
    );
  }

  final Map<int, int> contributions;
  final List<SidePot> sidePots;

  final int currentBet;
  final int totalPot;
  final int minRaise;
  final int lastRaiseSize;
  final bool isAllIn;

  BetState copyWith({
    int? currentBet,
    int? totalPot,
    int? minRaise,
    int? lastRaiseSize,
    bool? isAllIn,
    Map<int, int>? contributions,
    List<SidePot>? sidePots,
  }) {
    return BetState(
      currentBet: currentBet ?? this.currentBet,
      totalPot: totalPot ?? this.totalPot,
      minRaise: minRaise ?? this.minRaise,
      lastRaiseSize: lastRaiseSize ?? this.lastRaiseSize,
      isAllIn: isAllIn ?? this.isAllIn,
      contributions: contributions ?? this.contributions,
      sidePots: sidePots ?? this.sidePots,
    );
  }

  BetActionResult applyAction({
    required BetParticipant player,
    required PlayerAction action,
    int? amount,
    Iterable<BetParticipant> participants = const [],
  }) {
    var state = this;
    var updatedPlayer = player;
    var invested = 0;

    switch (action) {
      case PlayerAction.fold:
        updatedPlayer = player.copyWith(hasFolded: true);
        break;
      case PlayerAction.check:
      case PlayerAction.none:
        if (player.currentBet < currentBet) {
          throw StateError('Cannot check when facing a bet.');
        }
        break;
      case PlayerAction.call:
        final needed = state.currentBet - player.currentBet;
        if (needed <= 0) {
          break;
        }
        final callAmount = needed.clamp(0, player.stack);
        final newPlayerBet = player.currentBet + callAmount;
        invested = callAmount;
        updatedPlayer = player.copyWith(
          stack: player.stack - callAmount,
          currentBet: newPlayerBet,
          isAllIn: player.stack == callAmount,
        );
        state = state._withContribution(
          player.seatIndex,
          newPlayerBet,
          additionalPot: callAmount,
          anyAllIn: updatedPlayer.isAllIn,
          participants: participants,
        );
        break;
      case PlayerAction.bet:
      case PlayerAction.raise:
      case PlayerAction.post:
      case PlayerAction.allIn:
      case PlayerAction.push:
        if (amount == null && player.stack == 0) {
          throw StateError('Invalid bet/raise amount.');
        }
        final targetBet = _resolveTargetBet(
          state: state,
          player: player,
          amount: amount,
          action: action,
        );
        final payment = (targetBet - player.currentBet).clamp(0, player.stack);
        if (payment <= 0) {
          break;
        }
        final nextPlayerBet = player.currentBet + payment;
        invested = payment;

        final becameAllIn = payment == player.stack;
        final raiseSize = nextPlayerBet - state.currentBet;

        updatedPlayer = player.copyWith(
          stack: player.stack - payment,
          currentBet: nextPlayerBet,
          isAllIn: becameAllIn,
        );

        final nextCurrentBet = nextPlayerBet > state.currentBet
            ? nextPlayerBet
            : state.currentBet;

        final nextMinRaise = raiseSize > 0
            ? max(state.minRaise, raiseSize)
            : state.minRaise;

        state = state._withContribution(
          player.seatIndex,
          nextPlayerBet,
          additionalPot: payment,
          nextCurrentBet: nextCurrentBet,
          nextMinRaise: nextMinRaise,
          nextLastRaiseSize: raiseSize > 0 ? raiseSize : state.lastRaiseSize,
          anyAllIn: becameAllIn,
          participants: participants,
        );
        break;
    }

    return BetActionResult(
      state: state,
      player: updatedPlayer,
      invested: invested,
    );
  }

  int _resolveTargetBet({
    required BetState state,
    required BetParticipant player,
    required int? amount,
    required PlayerAction action,
  }) {
    if (action == PlayerAction.allIn || action == PlayerAction.push) {
      return player.currentBet + player.stack;
    }
    if (amount != null && amount > 0) {
      return amount;
    }

    if (state.currentBet == 0) {
      return state.minRaise;
    }
    return state.currentBet + state.minRaise;
  }

  BetState _withContribution(
    int seatIndex,
    int contribution, {
    required int additionalPot,
    int? nextCurrentBet,
    int? nextMinRaise,
    int? nextLastRaiseSize,
    bool anyAllIn = false,
    Iterable<BetParticipant> participants = const [],
  }) {
    final updatedContributions = Map<int, int>.from(contributions)
      ..[seatIndex] = contribution;
    final updatedState = copyWith(
      totalPot: totalPot + additionalPot,
      currentBet: nextCurrentBet ?? currentBet,
      minRaise: nextMinRaise ?? minRaise,
      lastRaiseSize: nextLastRaiseSize ?? lastRaiseSize,
      isAllIn: anyAllIn || isAllIn,
      contributions: updatedContributions,
    );
    final rebuiltSidePots = _rebuildSidePots(
      updatedContributions,
      participants.toList(),
    );
    return updatedState.copyWith(sidePots: rebuiltSidePots);
  }

  List<SidePot> _rebuildSidePots(
    Map<int, int> contributions,
    List<BetParticipant> participants,
  ) {
    if (contributions.isEmpty) {
      return const [];
    }

    final indexed =
        contributions.entries
            .map((entry) => _Contribution(entry.key, entry.value))
            .where((entry) => entry.amount > 0)
            .toList()
          ..sort((a, b) => a.amount.compareTo(b.amount));

    if (indexed.isEmpty) {
      return const [];
    }

    final participantMap = {for (final p in participants) p.seatIndex: p};

    final result = <SidePot>[];
    var previous = 0;

    for (final entry in indexed) {
      if (entry.amount <= previous) {
        continue;
      }
      final contributingSeats = indexed
          .where((e) => e.amount >= entry.amount)
          .map((e) => e.seat)
          .toSet();
      final eligible = contributingSeats
          .where((seat) => !(participantMap[seat]?.hasFolded ?? false))
          .toSet();
      final slice = entry.amount - previous;
      final amount = slice * contributingSeats.length;
      if (amount > 0) {
        result.add(SidePot(amount: amount, eligibleSeats: eligible));
      }
      previous = entry.amount;
    }

    return result;
  }
}

class SidePot {
  const SidePot({required this.amount, required this.eligibleSeats});

  final int amount;
  final Set<int> eligibleSeats;
}

class BetParticipant {
  const BetParticipant({
    required this.seatIndex,
    required this.stack,
    required this.currentBet,
    this.hasFolded = false,
    this.isAllIn = false,
  });

  final int seatIndex;
  final int stack;
  final int currentBet;
  final bool hasFolded;
  final bool isAllIn;

  BetParticipant copyWith({
    int? stack,
    int? currentBet,
    bool? hasFolded,
    bool? isAllIn,
  }) {
    return BetParticipant(
      seatIndex: seatIndex,
      stack: stack ?? this.stack,
      currentBet: currentBet ?? this.currentBet,
      hasFolded: hasFolded ?? this.hasFolded,
      isAllIn: isAllIn ?? this.isAllIn,
    );
  }
}

class BetActionResult {
  const BetActionResult({
    required this.state,
    required this.player,
    required this.invested,
  });

  final BetState state;
  final BetParticipant player;
  final int invested;
}

class _Contribution {
  _Contribution(this.seat, this.amount);

  final int seat;
  final int amount;
}
