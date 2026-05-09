import 'package:poker_analyzer/engine/scenario_replayer/scenario_events.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';

enum ReplayerFsmStateKind { setup, streetActive, evaluation, outcome }

enum StreetActivePhase { acting, resolving }

abstract class ReplayerFsmState {
  const ReplayerFsmState(this.kind);

  final ReplayerFsmStateKind kind;
}

class SetupReplayerState extends ReplayerFsmState {
  const SetupReplayerState() : super(ReplayerFsmStateKind.setup);
}

class StreetActiveReplayerState extends ReplayerFsmState {
  const StreetActiveReplayerState({required this.phase})
    : super(ReplayerFsmStateKind.streetActive);

  final StreetActivePhase phase;
}

class EvaluationReplayerState extends ReplayerFsmState {
  const EvaluationReplayerState() : super(ReplayerFsmStateKind.evaluation);
}

class OutcomeReplayerState extends ReplayerFsmState {
  const OutcomeReplayerState() : super(ReplayerFsmStateKind.outcome);
}

class ReplayerValidationError implements Exception {
  ReplayerValidationError(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'ReplayerValidationError($code): $message';
}

class ScenarioReplayerEngine {
  ScenarioReplayerEngine(this._spec)
    : _snapshot = _spec.initialSnapshot,
      _state = const SetupReplayerState() {
    if (_spec.steps.isEmpty) {
      throw ReplayerValidationError(
        'empty_steps',
        'Scenario must include steps',
      );
    }
  }

  final ScenarioReplayerSpec _spec;
  ReplayerSnapshot _snapshot;
  ReplayerFsmState _state;
  int _stepIndex = 0;
  SubmitActionEvent? _pendingAction;

  ReplayerFsmState get currentState => _state;

  ScenarioReplayerViewModel viewModel() {
    return ScenarioReplayerViewModel(
      heroStack: _snapshot.heroStack,
      villainStack: _snapshot.villainStack,
      pot: _snapshot.pot,
      toCall: _snapshot.toCall,
      street: _snapshot.street,
      actingSeat: _snapshot.actingSeat,
      stepIndex: _stepIndex,
      minRaiseTo: _snapshot.minRaiseTo,
    );
  }

  List<ReplayerActionSpec> legalActions() {
    if (_state is! StreetActiveReplayerState)
      return const <ReplayerActionSpec>[];
    final active = _state as StreetActiveReplayerState;
    if (active.phase != StreetActivePhase.acting) {
      return const <ReplayerActionSpec>[];
    }
    return List<ReplayerActionSpec>.unmodifiable(_currentStep.legalActions);
  }

  ScenarioReplayerOutcome? dispatch(ScenarioReplayerEvent event) {
    if (event is StartHandEvent) {
      _requireState<SetupReplayerState>('start_hand_invalid_state');
      _state = const StreetActiveReplayerState(phase: StreetActivePhase.acting);
      return null;
    }
    if (event is SubmitActionEvent) {
      final active = _requireState<StreetActiveReplayerState>(
        'submit_invalid_state',
      );
      if (active.phase != StreetActivePhase.acting) {
        throw ReplayerValidationError(
          'submit_invalid_phase',
          'Submit requires acting phase',
        );
      }
      _validateAndApplyAction(event);
      _pendingAction = event;
      _state = const StreetActiveReplayerState(
        phase: StreetActivePhase.resolving,
      );
      return null;
    }
    if (event is ResolveStreetEvent) {
      final active = _requireState<StreetActiveReplayerState>(
        'resolve_invalid_state',
      );
      if (active.phase != StreetActivePhase.resolving) {
        throw ReplayerValidationError(
          'resolve_invalid_phase',
          'Resolve requires resolving phase',
        );
      }
      if (_pendingAction == null) {
        throw ReplayerValidationError(
          'resolve_missing_action',
          'Missing action before resolve',
        );
      }
      _state = const EvaluationReplayerState();
      return null;
    }
    if (event is CompleteEvaluationEvent) {
      _requireState<EvaluationReplayerState>('complete_eval_invalid_state');
      _state = const OutcomeReplayerState();
      final pending = _pendingAction;
      if (pending == null) {
        throw ReplayerValidationError(
          'complete_eval_missing_action',
          'Missing action before outcome',
        );
      }
      final winner = pending.kind == ReplayerActionKind.fold
          ? _otherSeat(pending.seat)
          : ReplayerSeat.hero;
      return ScenarioReplayerOutcome(
        winner: winner,
        reason: pending.kind == ReplayerActionKind.fold ? 'fold' : 'resolved',
        finalSnapshot: viewModel(),
      );
    }
    throw ReplayerValidationError(
      'unknown_event',
      'Unsupported event: ${event.runtimeType}',
    );
  }

  void _validateAndApplyAction(SubmitActionEvent event) {
    if (event.seat != _currentStep.actingSeat ||
        event.seat != _snapshot.actingSeat) {
      throw ReplayerValidationError(
        'wrong_actor',
        'Action seat is not acting seat',
      );
    }
    final actionSpec = _currentStep.legalActions.where(
      (spec) => spec.kind == event.kind,
    );
    if (actionSpec.isEmpty) {
      throw ReplayerValidationError(
        'illegal_action',
        'Action is not legal for this step',
      );
    }
    if (event.kind == ReplayerActionKind.fold) {
      return;
    }

    final stack = _snapshot.stackFor(event.seat);
    if (event.kind == ReplayerActionKind.callCheck) {
      final callAmount = _snapshot.toCall < stack ? _snapshot.toCall : stack;
      _applyChipDelta(event.seat, callAmount);
      _snapshot = _snapshot.copyWith(toCall: 0);
      return;
    }

    final rawAmount = event.amount;
    if (rawAmount == null) {
      throw ReplayerValidationError(
        'missing_amount',
        'bet/raise requires amount',
      );
    }
    if (rawAmount > stack) {
      throw ReplayerValidationError(
        'amount_exceeds_stack',
        'bet/raise exceeds stack',
      );
    }
    final minAllowed = _snapshot.minRaiseTo > _snapshot.toCall
        ? _snapshot.minRaiseTo
        : _snapshot.toCall;
    if (rawAmount < minAllowed) {
      throw ReplayerValidationError(
        'amount_below_minimum',
        'bet/raise below minimum',
      );
    }
    _applyChipDelta(event.seat, rawAmount);
    _snapshot = _snapshot.copyWith(toCall: rawAmount, minRaiseTo: rawAmount);
  }

  void _applyChipDelta(ReplayerSeat seat, int amount) {
    if (amount < 0) {
      throw ReplayerValidationError(
        'negative_amount',
        'Amount must be non-negative',
      );
    }
    if (seat == ReplayerSeat.hero) {
      _snapshot = _snapshot.copyWith(
        heroStack: _snapshot.heroStack - amount,
        pot: _snapshot.pot + amount,
      );
      return;
    }
    _snapshot = _snapshot.copyWith(
      villainStack: _snapshot.villainStack - amount,
      pot: _snapshot.pot + amount,
    );
  }

  ReplayerSeat _otherSeat(ReplayerSeat seat) {
    return seat == ReplayerSeat.hero ? ReplayerSeat.villain : ReplayerSeat.hero;
  }

  ReplayerStep get _currentStep {
    return _spec.steps[_stepIndex];
  }

  T _requireState<T extends ReplayerFsmState>(String code) {
    final current = _state;
    if (current is T) {
      return current;
    }
    throw ReplayerValidationError(
      code,
      'Unexpected state: ${current.runtimeType}',
    );
  }
}
