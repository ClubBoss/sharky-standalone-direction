import '../fsm/engine_fsm_v1.dart';
import '../model/action_v1.dart';
import '../model/engine_types_v1.dart';
import '../model/money_state_v1.dart';
import '../model/snapshot_v1.dart';
import '../model/state_v1.dart';

enum EngineV2AutoResolveStopReasonV1 {
  heroToAct,
  streetAdvanced,
  evaluationReached,
  outcomeReached,
  violation,
  stepCapReached,
}

class EngineV2AutoResolveEntryV1 {
  const EngineV2AutoResolveEntryV1({
    required this.event,
    required this.result,
    this.label,
  });

  final EngineEventV1 event;
  final EngineStepResultV1 result;
  final String? label;
}

class EngineV2AutoResolveRunV1 {
  const EngineV2AutoResolveRunV1({
    required this.entries,
    required this.stopReason,
    required this.finalState,
    this.violations = const <EngineViolationV1>[],
  });

  final List<EngineV2AutoResolveEntryV1> entries;
  final EngineV2AutoResolveStopReasonV1 stopReason;
  final EngineStateV1 finalState;
  final List<EngineViolationV1> violations;
}

class EngineV2AutoOpponentPolicyV1 {
  const EngineV2AutoOpponentPolicyV1();

  ActionV1 chooseAction(EngineSnapshotV1 snapshot) {
    final actor = snapshot.actingPlayer;
    final toCall = snapshot.toCallFor(actor);
    final stack = snapshot.stacksState.stackFor(actor).value;
    if (toCall == 0) {
      return ActionV1(actorId: actor, kind: ActionKindV1.check);
    }
    if (stack >= toCall) {
      return ActionV1(actorId: actor, kind: ActionKindV1.call);
    }
    return ActionV1(actorId: actor, kind: ActionKindV1.fold);
  }
}

class EngineV2AutoResolveDriverV1 {
  const EngineV2AutoResolveDriverV1({
    this.policy = const EngineV2AutoOpponentPolicyV1(),
  });

  final EngineV2AutoOpponentPolicyV1 policy;

  EngineV2AutoResolveRunV1 runUntilBoundary({
    required EngineFsmV1 fsm,
    required PlayerIdV1 heroPlayerId,
    int maxSteps = 32,
  }) {
    final entries = <EngineV2AutoResolveEntryV1>[];
    var stepCount = 0;
    while (stepCount < maxSteps) {
      final state = fsm.state;
      if (state is OutcomeEngineStateV1) {
        return EngineV2AutoResolveRunV1(
          entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
          stopReason: EngineV2AutoResolveStopReasonV1.outcomeReached,
          finalState: fsm.state,
        );
      }
      if (state is EvaluationEngineStateV1) {
        return EngineV2AutoResolveRunV1(
          entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
          stopReason: EngineV2AutoResolveStopReasonV1.evaluationReached,
          finalState: fsm.state,
        );
      }
      if (state is! StreetActiveEngineStateV1) {
        return EngineV2AutoResolveRunV1(
          entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
          stopReason: EngineV2AutoResolveStopReasonV1.violation,
          finalState: fsm.state,
          violations: const <EngineViolationV1>[
            EngineViolationV1(
              code: 'cannot_auto_resolve',
              message: 'Unsupported state for auto-resolve',
            ),
          ],
        );
      }

      if (state.phase == StreetPhaseV1.acting) {
        if (state.snapshot.actingPlayer == heroPlayerId) {
          return EngineV2AutoResolveRunV1(
            entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
            stopReason: EngineV2AutoResolveStopReasonV1.heroToAct,
            finalState: fsm.state,
          );
        }
        final action = policy.chooseAction(state.snapshot);
        final event = PlayerActionEventV1(action);
        final result = fsm.apply(event);
        entries.add(
          EngineV2AutoResolveEntryV1(
            event: event,
            result: result,
            label: 'auto_opponent_action',
          ),
        );
        if (!result.isValid) {
          return EngineV2AutoResolveRunV1(
            entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
            stopReason: EngineV2AutoResolveStopReasonV1.violation,
            finalState: fsm.state,
            violations: result.violations,
          );
        }
        stepCount += 1;
        continue;
      }

      final event = const AdvanceEventV1();
      final result = fsm.apply(event);
      entries.add(
        EngineV2AutoResolveEntryV1(
          event: event,
          result: result,
          label: 'auto_street_advance',
        ),
      );
      if (!result.isValid) {
        return EngineV2AutoResolveRunV1(
          entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
          stopReason: EngineV2AutoResolveStopReasonV1.violation,
          finalState: fsm.state,
          violations: result.violations,
        );
      }
      return EngineV2AutoResolveRunV1(
        entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
        stopReason: EngineV2AutoResolveStopReasonV1.streetAdvanced,
        finalState: fsm.state,
      );
    }

    return EngineV2AutoResolveRunV1(
      entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
      stopReason: EngineV2AutoResolveStopReasonV1.stepCapReached,
      finalState: fsm.state,
      violations: const <EngineViolationV1>[
        EngineViolationV1(
          code: 'auto_resolve_step_cap_exceeded',
          message: 'Auto-resolve reached max step cap',
        ),
      ],
    );
  }
}
