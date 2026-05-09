enum ReplayerStreet { preflop, flop, turn, river }

enum ReplayerSeat { hero, villain }

enum ReplayerActionKind { fold, callCheck, betRaise }

class ReplayerActionSpec {
  const ReplayerActionSpec({required this.kind, this.minAmount});

  final ReplayerActionKind kind;
  final int? minAmount;
}

class ReplayerStep {
  const ReplayerStep({required this.actingSeat, required this.legalActions});

  final ReplayerSeat actingSeat;
  final List<ReplayerActionSpec> legalActions;
}

class ReplayerSnapshot {
  const ReplayerSnapshot({
    required this.heroStack,
    required this.villainStack,
    required this.pot,
    required this.toCall,
    required this.street,
    required this.actingSeat,
    required this.minRaiseTo,
  });

  final int heroStack;
  final int villainStack;
  final int pot;
  final int toCall;
  final ReplayerStreet street;
  final ReplayerSeat actingSeat;
  final int minRaiseTo;

  int stackFor(ReplayerSeat seat) {
    return seat == ReplayerSeat.hero ? heroStack : villainStack;
  }

  ReplayerSnapshot copyWith({
    int? heroStack,
    int? villainStack,
    int? pot,
    int? toCall,
    ReplayerStreet? street,
    ReplayerSeat? actingSeat,
    int? minRaiseTo,
  }) {
    return ReplayerSnapshot(
      heroStack: heroStack ?? this.heroStack,
      villainStack: villainStack ?? this.villainStack,
      pot: pot ?? this.pot,
      toCall: toCall ?? this.toCall,
      street: street ?? this.street,
      actingSeat: actingSeat ?? this.actingSeat,
      minRaiseTo: minRaiseTo ?? this.minRaiseTo,
    );
  }
}

class ScenarioReplayerSpec {
  const ScenarioReplayerSpec({
    required this.initialSnapshot,
    required this.steps,
  });

  final ReplayerSnapshot initialSnapshot;
  final List<ReplayerStep> steps;
}

class ScenarioReplayerViewModel {
  const ScenarioReplayerViewModel({
    required this.heroStack,
    required this.villainStack,
    required this.pot,
    required this.toCall,
    required this.street,
    required this.actingSeat,
    required this.stepIndex,
    required this.minRaiseTo,
  });

  final int heroStack;
  final int villainStack;
  final int pot;
  final int toCall;
  final ReplayerStreet street;
  final ReplayerSeat actingSeat;
  final int stepIndex;
  final int minRaiseTo;

  @override
  bool operator ==(Object other) {
    if (other is! ScenarioReplayerViewModel) return false;
    return heroStack == other.heroStack &&
        villainStack == other.villainStack &&
        pot == other.pot &&
        toCall == other.toCall &&
        street == other.street &&
        actingSeat == other.actingSeat &&
        stepIndex == other.stepIndex &&
        minRaiseTo == other.minRaiseTo;
  }

  @override
  int get hashCode => Object.hash(
    heroStack,
    villainStack,
    pot,
    toCall,
    street,
    actingSeat,
    stepIndex,
    minRaiseTo,
  );
}

class ScenarioReplayerOutcome {
  const ScenarioReplayerOutcome({
    required this.winner,
    required this.reason,
    required this.finalSnapshot,
  });

  final ReplayerSeat winner;
  final String reason;
  final ScenarioReplayerViewModel finalSnapshot;

  @override
  bool operator ==(Object other) {
    if (other is! ScenarioReplayerOutcome) return false;
    return winner == other.winner &&
        reason == other.reason &&
        finalSnapshot == other.finalSnapshot;
  }

  @override
  int get hashCode => Object.hash(winner, reason, finalSnapshot);
}
