import '../fsm/engine_fsm_v1.dart';
import '../model/action_v1.dart';
import '../model/engine_types_v1.dart';
import '../model/state_v1.dart';
import 'scenario_v1.dart';
import 'step_v1.dart';

class ScenarioValidatorV1 {
  const ScenarioValidatorV1();

  List<EngineViolationV1> validateScenario(ScenarioV1 scenario) {
    final steps = scenario.steps;
    if (steps.isEmpty) {
      return const <EngineViolationV1>[
        EngineViolationV1(
          code: 'scenario_empty_steps',
          message: 'Scenario must include at least one step',
        ),
      ];
    }

    if (steps.first is! StartHandStepV1) {
      return const <EngineViolationV1>[
        EngineViolationV1(
          code: 'scenario_must_start_with_start_hand',
          message: 'Scenario first step must be startHand',
        ),
      ];
    }

    final knownPlayers = scenario.initialSnapshot.players.toSet();
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      if (step is FinishStepV1 && i != steps.length - 1) {
        return <EngineViolationV1>[
          EngineViolationV1(
            code: 'scenario_finish_not_last',
            message: 'finish must be the final step (index=$i)',
          ),
        ];
      }
      if (step is PlayerActionStepV1) {
        if (!knownPlayers.contains(step.playerId)) {
          return <EngineViolationV1>[
            EngineViolationV1(
              code: 'scenario_unknown_player',
              message: 'Unknown playerId at step $i: ${step.playerId.value}',
            ),
          ];
        }
        if (step.action.actorId != step.playerId) {
          return <EngineViolationV1>[
            EngineViolationV1(
              code: 'scenario_action_actor_mismatch',
              message: 'playerId does not match action.actorId at step $i',
            ),
          ];
        }
      }
    }

    final fsm = EngineFsmV1(initialSnapshot: scenario.initialSnapshot);
    var seenStartHand = false;

    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];

      if (step is StartHandStepV1) {
        seenStartHand = true;
      }

      if (step is PlayerActionStepV1 && !seenStartHand) {
        return <EngineViolationV1>[
          EngineViolationV1(
            code: 'scenario_action_before_start_hand',
            message: 'playerAction is not allowed before startHand (step=$i)',
          ),
        ];
      }

      if (step is PlayerActionStepV1) {
        final precheck = _precheckAction(fsm.state, step.action);
        if (precheck != null) {
          return <EngineViolationV1>[
            EngineViolationV1(
              code: precheck.code,
              message: '${precheck.message} (step=$i)',
            ),
          ];
        }
      }

      final result = fsm.apply(step.toEvent());
      if (result.violations.isNotEmpty) {
        final v = result.violations.first;
        return <EngineViolationV1>[
          EngineViolationV1(
            code: 'scenario_step_invalid:${v.code}',
            message: '${v.message} (step=$i)',
          ),
        ];
      }
    }

    return const <EngineViolationV1>[];
  }

  EngineViolationV1? _precheckAction(EngineStateV1 state, ActionV1 action) {
    if (state is! StreetActiveEngineStateV1 ||
        state.phase != StreetPhaseV1.acting) {
      return const EngineViolationV1(
        code: 'scenario_action_outside_acting_phase',
        message: 'playerAction must occur in streetActive(acting)',
      );
    }

    final snapshot = state.snapshot;
    final toCall = snapshot.toCallFor(action.actorId);
    if (action.kind == ActionKindV1.check && toCall != 0) {
      return const EngineViolationV1(
        code: 'scenario_check_requires_zero_to_call',
        message: 'check requires toCall == 0',
      );
    }
    if (action.kind == ActionKindV1.bet && toCall != 0) {
      return const EngineViolationV1(
        code: 'scenario_bet_requires_zero_to_call',
        message: 'bet requires toCall == 0',
      );
    }
    if (action.kind == ActionKindV1.call && toCall == 0) {
      return const EngineViolationV1(
        code: 'scenario_call_requires_positive_to_call',
        message: 'call requires toCall > 0',
      );
    }
    if (action.kind == ActionKindV1.raise && toCall == 0) {
      return const EngineViolationV1(
        code: 'scenario_raise_requires_positive_to_call',
        message: 'raise requires toCall > 0',
      );
    }
    return null;
  }
}
