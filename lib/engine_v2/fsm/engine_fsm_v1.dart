import '../model/action_v1.dart';
import '../model/engine_types_v1.dart';
import '../model/money_state_v1.dart';
import '../model/snapshot_v1.dart';
import '../model/state_v1.dart';

abstract class EngineEventV1 {
  const EngineEventV1();
}

class StartHandEventV1 extends EngineEventV1 {
  const StartHandEventV1();
}

class PlayerActionEventV1 extends EngineEventV1 {
  const PlayerActionEventV1(this.action);

  final ActionV1 action;
}

class AdvanceEventV1 extends EngineEventV1 {
  const AdvanceEventV1();
}

class FinishEventV1 extends EngineEventV1 {
  const FinishEventV1();
}

class EngineStepResultV1 {
  const EngineStepResultV1({
    required this.state,
    this.effects = const <String>[],
    this.violations = const <EngineViolationV1>[],
  });

  final EngineStateV1 state;
  final List<String> effects;
  final List<EngineViolationV1> violations;

  bool get isValid => violations.isEmpty;
}

class EngineFsmV1 {
  EngineFsmV1({
    EngineSnapshotV1? initialSnapshot,
    List<PlayerIdV1>? players,
    ChipsV1 startingStack = const ChipsV1(100),
  }) : _state = SetupEngineStateV1(
         snapshot:
             initialSnapshot ??
             EngineSnapshotV1.initial(
               players:
                   players ??
                   const <PlayerIdV1>[PlayerIdV1('p1'), PlayerIdV1('p2')],
               startingStack: startingStack,
             ),
       );

  EngineStateV1 _state;

  EngineStateV1 get state => _state;

  EngineStepResultV1 apply(EngineEventV1 event) {
    if (event is StartHandEventV1) {
      return _startHand();
    }
    if (event is PlayerActionEventV1) {
      return _playerAction(event.action);
    }
    if (event is AdvanceEventV1) {
      return _advance();
    }
    if (event is FinishEventV1) {
      return _finish();
    }
    return _invalid('unknown_event', 'Unsupported event: ${event.runtimeType}');
  }

  EngineStepResultV1 _startHand() {
    if (_state is! SetupEngineStateV1) {
      return _invalid(
        'invalid_start_hand_transition',
        'startHand is only allowed from setup',
      );
    }
    final nextSnapshot = _state.snapshot.copyWith(
      handStarted: true,
      clearLastAction: true,
    );
    _state = StreetActiveEngineStateV1(
      phase: StreetPhaseV1.acting,
      snapshot: nextSnapshot,
    );
    return EngineStepResultV1(
      state: _state,
      effects: const <String>['hand_started'],
    );
  }

  EngineStepResultV1 _playerAction(ActionV1 action) {
    final currentState = _state;
    if (currentState is! StreetActiveEngineStateV1 ||
        currentState.phase != StreetPhaseV1.acting) {
      return _invalid(
        'invalid_player_action_transition',
        'playerAction is only allowed in streetActive(acting)',
      );
    }

    final snapshot = currentState.snapshot;
    if (action.actorId != snapshot.actingPlayer) {
      return _invalid('invalid_actor', 'Action actor must match acting player');
    }
    if (snapshot.isFolded(action.actorId)) {
      return _invalid('actor_folded', 'Folded player cannot act');
    }

    final resolved = _resolveAction(snapshot, action);
    if (resolved.violations.isNotEmpty) {
      return EngineStepResultV1(state: _state, violations: resolved.violations);
    }

    _state = StreetActiveEngineStateV1(
      phase: StreetPhaseV1.resolving,
      snapshot: resolved.snapshot!,
    );
    return EngineStepResultV1(state: _state, effects: resolved.effects);
  }

  _ResolutionOutcome _resolveAction(
    EngineSnapshotV1 snapshot,
    ActionV1 action,
  ) {
    final actor = action.actorId;
    final stacksState = snapshot.stacksState;
    final stack = stacksState.stackFor(actor).value;
    final committed = stacksState.committedFor(actor).value;
    final toCall = snapshot.toCallFor(actor);

    final nextStacks = Map<PlayerIdV1, ChipsV1>.from(stacksState.stackByPlayer);
    final nextCommitted = Map<PlayerIdV1, ChipsV1>.from(
      stacksState.committedByPlayer,
    );
    final nextFolded = Map<PlayerIdV1, bool>.from(snapshot.foldedByPlayer);

    ChipsV1 nextCurrentBet = snapshot.currentBet;
    ChipsV1 nextLastBetSize = snapshot.lastBetSize;

    void deductAndCommit(int amount) {
      nextStacks[actor] = ChipsV1(stack - amount);
      nextCommitted[actor] = ChipsV1(committed + amount);
    }

    if (action.amount != null && action.amount! < 0) {
      return _ResolutionOutcome.violation(
        'invalid_action_amount',
        'Action amount must be non-negative',
      );
    }

    if (action.kind == ActionKindV1.fold) {
      nextFolded[actor] = true;
    } else if (action.kind == ActionKindV1.check) {
      if (toCall != 0) {
        return _ResolutionOutcome.violation(
          'check_requires_zero_to_call',
          'check is only allowed when toCall is zero',
        );
      }
    } else if (action.kind == ActionKindV1.call) {
      if (toCall <= 0) {
        return _ResolutionOutcome.violation(
          'call_requires_positive_to_call',
          'call is only allowed when toCall is positive',
        );
      }
      if (stack < toCall) {
        return _ResolutionOutcome.violation(
          'call_exceeds_stack',
          'call amount cannot exceed stack',
        );
      }
      deductAndCommit(toCall);
    } else if (action.kind == ActionKindV1.bet) {
      final bet = action.amount;
      if (toCall != 0) {
        return _ResolutionOutcome.violation(
          'bet_requires_zero_to_call',
          'bet is only allowed when toCall is zero',
        );
      }
      if (bet == null || bet <= 0) {
        return _ResolutionOutcome.violation(
          'invalid_bet_amount',
          'bet requires amount > 0',
        );
      }
      if (bet > stack) {
        return _ResolutionOutcome.violation(
          'bet_exceeds_stack',
          'bet amount cannot exceed stack',
        );
      }
      deductAndCommit(bet);
      nextCurrentBet = ChipsV1(committed + bet);
      nextLastBetSize = ChipsV1(bet);
    } else if (action.kind == ActionKindV1.raise) {
      final raiseTo = action.amount;
      if (toCall <= 0) {
        return _ResolutionOutcome.violation(
          'raise_requires_positive_to_call',
          'raise is only allowed when toCall is positive',
        );
      }
      if (raiseTo == null) {
        return _ResolutionOutcome.violation(
          'missing_raise_to_amount',
          'raise requires raise-to amount',
        );
      }
      if (raiseTo <= snapshot.currentBet.value) {
        return _ResolutionOutcome.violation(
          'raise_to_not_above_current_bet',
          'raise-to amount must be greater than current bet',
        );
      }
      final delta = raiseTo - committed;
      if (delta <= 0) {
        return _ResolutionOutcome.violation(
          'invalid_raise_delta',
          'raise delta must be positive',
        );
      }
      if (delta > stack) {
        return _ResolutionOutcome.violation(
          'raise_exceeds_stack',
          'raise amount cannot exceed stack',
        );
      }
      deductAndCommit(delta);
      nextCurrentBet = ChipsV1(raiseTo);
      nextLastBetSize = ChipsV1(raiseTo - snapshot.currentBet.value);
    }

    final nextActing = _nextActivePlayer(snapshot.players, nextFolded, actor);
    final nextSnapshot = snapshot.copyWith(
      actionCount: snapshot.actionCount + 1,
      stacksState: stacksState.copyWith(
        stackByPlayer: nextStacks,
        committedByPlayer: nextCommitted,
      ),
      foldedByPlayer: nextFolded,
      actingPlayer: nextActing,
      currentBet: nextCurrentBet,
      lastBetSize: nextLastBetSize,
      lastAction: action,
    );

    return _ResolutionOutcome.success(nextSnapshot, const <String>[
      'action_resolved',
    ]);
  }

  EngineStepResultV1 _advance() {
    final current = _state;
    if (current is! StreetActiveEngineStateV1 ||
        current.phase != StreetPhaseV1.resolving) {
      return _invalid(
        'invalid_advance_transition',
        'advance is only allowed in streetActive(resolving)',
      );
    }

    final snapshot = current.snapshot;
    final committedTotal = snapshot.stacksState.totalCommitted();
    final resetCommitted = <PlayerIdV1, ChipsV1>{
      for (final player in snapshot.players) player: const ChipsV1(0),
    };
    final movedSnapshot = snapshot.copyWith(
      stacksState: snapshot.stacksState.copyWith(
        committedByPlayer: resetCommitted,
        pot: ChipsV1(snapshot.stacksState.pot.value + committedTotal),
      ),
      currentBet: const ChipsV1(0),
      lastBetSize: const ChipsV1(0),
      clearLastAction: false,
    );

    final nextStreet = _nextStreetOrNull(movedSnapshot.street);
    if (nextStreet == null) {
      _state = EvaluationEngineStateV1(snapshot: movedSnapshot);
      return EngineStepResultV1(
        state: _state,
        effects: const <String>['street_resolved', 'entered_evaluation'],
      );
    }

    _state = StreetActiveEngineStateV1(
      phase: StreetPhaseV1.acting,
      snapshot: movedSnapshot.copyWith(street: nextStreet),
    );
    final revealEffect = switch (nextStreet) {
      StreetV1.flop => 'reveal_flop',
      StreetV1.turn => 'reveal_turn',
      StreetV1.river => 'reveal_river',
      StreetV1.preflop => 'reveal_preflop',
    };
    return EngineStepResultV1(
      state: _state,
      effects: <String>['street_resolved', revealEffect],
    );
  }

  EngineStepResultV1 _finish() {
    final current = _state;
    if (current is! EvaluationEngineStateV1) {
      return _invalid(
        'invalid_finish_transition',
        'finish is only allowed from evaluation',
      );
    }
    _state = OutcomeEngineStateV1(snapshot: current.snapshot);
    return EngineStepResultV1(
      state: _state,
      effects: const <String>['hand_finished'],
    );
  }

  PlayerIdV1 _nextActivePlayer(
    List<PlayerIdV1> players,
    Map<PlayerIdV1, bool> foldedByPlayer,
    PlayerIdV1 currentActor,
  ) {
    final start = players.indexOf(currentActor);
    for (var offset = 1; offset <= players.length; offset++) {
      final idx = (start + offset) % players.length;
      final candidate = players[idx];
      if (!(foldedByPlayer[candidate] ?? false)) {
        return candidate;
      }
    }
    return currentActor;
  }

  StreetV1? _nextStreetOrNull(StreetV1 street) {
    switch (street) {
      case StreetV1.preflop:
        return StreetV1.flop;
      case StreetV1.flop:
        return StreetV1.turn;
      case StreetV1.turn:
        return StreetV1.river;
      case StreetV1.river:
        return null;
    }
  }

  EngineStepResultV1 _invalid(String code, String message) {
    return EngineStepResultV1(
      state: _state,
      violations: <EngineViolationV1>[
        EngineViolationV1(code: code, message: message),
      ],
    );
  }
}

class _ResolutionOutcome {
  const _ResolutionOutcome({
    required this.snapshot,
    required this.effects,
    required this.violations,
  });

  final EngineSnapshotV1? snapshot;
  final List<String> effects;
  final List<EngineViolationV1> violations;

  factory _ResolutionOutcome.success(
    EngineSnapshotV1 snapshot,
    List<String> effects,
  ) {
    return _ResolutionOutcome(
      snapshot: snapshot,
      effects: effects,
      violations: const <EngineViolationV1>[],
    );
  }

  factory _ResolutionOutcome.violation(String code, String message) {
    return _ResolutionOutcome(
      snapshot: null,
      effects: const <String>[],
      violations: <EngineViolationV1>[
        EngineViolationV1(code: code, message: message),
      ],
    );
  }
}
