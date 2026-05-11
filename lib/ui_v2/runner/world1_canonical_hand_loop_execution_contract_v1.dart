import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';
import 'package:poker_analyzer/engine_v2/engine_v2.dart';

class World1CanonicalHandLoopRunV1 {
  const World1CanonicalHandLoopRunV1({
    required this.entries,
    required this.stopReason,
    required this.finalState,
    required this.heroActionsApplied,
    this.violations = const <EngineViolationV1>[],
    this.firstHeroActionMatchesExpected = true,
    this.firstHeroActionExpectedLabel,
    this.firstHeroActionActualLabel,
  });

  final List<EngineV2AutoResolveEntryV1> entries;
  final EngineV2AutoResolveStopReasonV1 stopReason;
  final EngineStateV1 finalState;
  final int heroActionsApplied;
  final List<EngineViolationV1> violations;
  final bool firstHeroActionMatchesExpected;
  final String? firstHeroActionExpectedLabel;
  final String? firstHeroActionActualLabel;
}

World1CanonicalHandLoopRunV1 runWorld1CanonicalEngineV2HandLoopV1(
  ScenarioV1 scenario, {
  ActionV1? firstHeroActionOverride,
  ActionKindV1? expectedFirstHeroActionKind,
}) {
  final heroId = const PlayerIdV1('hero');
  final fsm = EngineFsmV1(initialSnapshot: scenario.initialSnapshot);
  final entries = <EngineV2AutoResolveEntryV1>[];
  final heroActions = scenario.steps
      .whereType<PlayerActionStepV1>()
      .where((step) => step.playerId == heroId)
      .map((step) => step.action)
      .toList(growable: false);
  var heroActionIndex = 0;
  var loopSteps = 0;
  var firstHeroActionMatchesExpected = true;
  String? firstHeroActionExpectedLabel;
  String? firstHeroActionActualLabel;

  final startResult = fsm.apply(const StartHandEventV1());
  entries.add(
    EngineV2AutoResolveEntryV1(
      event: const StartHandEventV1(),
      result: startResult,
      label: 'hero_start_hand',
    ),
  );
  if (!startResult.isValid) {
    return World1CanonicalHandLoopRunV1(
      entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
      stopReason: EngineV2AutoResolveStopReasonV1.violation,
      finalState: fsm.state,
      violations: startResult.violations,
      heroActionsApplied: 0,
      firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
      firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
      firstHeroActionActualLabel: firstHeroActionActualLabel,
    );
  }

  while (loopSteps < 64) {
    final state = fsm.state;
    if (state is OutcomeEngineStateV1) {
      return World1CanonicalHandLoopRunV1(
        entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
        stopReason: EngineV2AutoResolveStopReasonV1.outcomeReached,
        finalState: state,
        heroActionsApplied: heroActionIndex,
        firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
        firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
        firstHeroActionActualLabel: firstHeroActionActualLabel,
      );
    }
    if (state is EvaluationEngineStateV1) {
      final finishResult = fsm.apply(const FinishEventV1());
      entries.add(
        EngineV2AutoResolveEntryV1(
          event: const FinishEventV1(),
          result: finishResult,
          label: 'auto_finish',
        ),
      );
      if (!finishResult.isValid) {
        return World1CanonicalHandLoopRunV1(
          entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
          stopReason: EngineV2AutoResolveStopReasonV1.violation,
          finalState: fsm.state,
          violations: finishResult.violations,
          heroActionsApplied: heroActionIndex,
          firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
          firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
          firstHeroActionActualLabel: firstHeroActionActualLabel,
        );
      }
      return World1CanonicalHandLoopRunV1(
        entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
        stopReason: EngineV2AutoResolveStopReasonV1.outcomeReached,
        finalState: fsm.state,
        heroActionsApplied: heroActionIndex,
        firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
        firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
        firstHeroActionActualLabel: firstHeroActionActualLabel,
      );
    }
    if (state is! StreetActiveEngineStateV1) {
      return World1CanonicalHandLoopRunV1(
        entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
        stopReason: EngineV2AutoResolveStopReasonV1.violation,
        finalState: fsm.state,
        violations: const <EngineViolationV1>[
          EngineViolationV1(
            code: 'cannot_auto_resolve',
            message: 'Unsupported state during hand loop',
          ),
        ],
        heroActionsApplied: heroActionIndex,
        firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
        firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
        firstHeroActionActualLabel: firstHeroActionActualLabel,
      );
    }

    if (state.phase == StreetPhaseV1.acting &&
        state.snapshot.actingPlayer == heroId) {
      if (heroActionIndex >= heroActions.length) {
        return World1CanonicalHandLoopRunV1(
          entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
          stopReason: EngineV2AutoResolveStopReasonV1.violation,
          finalState: fsm.state,
          violations: const <EngineViolationV1>[
            EngineViolationV1(
              code: 'cannot_auto_resolve',
              message: 'No hero action left for current decision point',
            ),
          ],
          heroActionsApplied: heroActionIndex,
          firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
          firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
          firstHeroActionActualLabel: firstHeroActionActualLabel,
        );
      }
      var heroAction = heroActions[heroActionIndex];
      if (heroActionIndex == 0 && firstHeroActionOverride != null) {
        heroAction = ActionV1(
          actorId: heroAction.actorId,
          kind: firstHeroActionOverride.kind,
          amount: firstHeroActionOverride.amount,
        );
      }
      if (heroActionIndex == 0) {
        firstHeroActionExpectedLabel = expectedFirstHeroActionKind?.name
            .toUpperCase();
        firstHeroActionActualLabel = heroAction.kind.name.toUpperCase();
        firstHeroActionMatchesExpected =
            expectedFirstHeroActionKind == null ||
            heroAction.kind == expectedFirstHeroActionKind;
      }
      final heroEvent = PlayerActionEventV1(heroAction);
      final heroResult = fsm.apply(heroEvent);
      entries.add(
        EngineV2AutoResolveEntryV1(
          event: heroEvent,
          result: heroResult,
          label: 'hero_action_${heroActionIndex + 1}',
        ),
      );
      if (!heroResult.isValid) {
        return World1CanonicalHandLoopRunV1(
          entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
          stopReason: EngineV2AutoResolveStopReasonV1.violation,
          finalState: fsm.state,
          violations: heroResult.violations,
          heroActionsApplied: heroActionIndex,
          firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
          firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
          firstHeroActionActualLabel: firstHeroActionActualLabel,
        );
      }
      heroActionIndex += 1;
    }

    final autoRun = const EngineV2AutoResolveDriverV1().runUntilBoundary(
      fsm: fsm,
      heroPlayerId: heroId,
      maxSteps: 32,
    );
    entries.addAll(autoRun.entries);
    if (autoRun.stopReason == EngineV2AutoResolveStopReasonV1.violation ||
        autoRun.stopReason == EngineV2AutoResolveStopReasonV1.stepCapReached) {
      return World1CanonicalHandLoopRunV1(
        entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
        stopReason: autoRun.stopReason,
        finalState: autoRun.finalState,
        violations: autoRun.violations,
        heroActionsApplied: heroActionIndex,
        firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
        firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
        firstHeroActionActualLabel: firstHeroActionActualLabel,
      );
    }
    if (heroActionIndex > 0 &&
        (autoRun.stopReason ==
                EngineV2AutoResolveStopReasonV1.evaluationReached ||
            autoRun.stopReason ==
                EngineV2AutoResolveStopReasonV1.outcomeReached)) {
      return World1CanonicalHandLoopRunV1(
        entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
        stopReason: autoRun.stopReason,
        finalState: autoRun.finalState,
        heroActionsApplied: heroActionIndex,
        firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
        firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
        firstHeroActionActualLabel: firstHeroActionActualLabel,
      );
    }
    if (autoRun.stopReason == EngineV2AutoResolveStopReasonV1.outcomeReached ||
        autoRun.stopReason ==
            EngineV2AutoResolveStopReasonV1.evaluationReached) {
      continue;
    }
    loopSteps += 1;
  }

  return World1CanonicalHandLoopRunV1(
    entries: List<EngineV2AutoResolveEntryV1>.unmodifiable(entries),
    stopReason: EngineV2AutoResolveStopReasonV1.stepCapReached,
    finalState: fsm.state,
    violations: const <EngineViolationV1>[
      EngineViolationV1(
        code: 'auto_resolve_step_cap_exceeded',
        message: 'Hand loop reached max step cap',
      ),
    ],
    heroActionsApplied: heroActionIndex,
    firstHeroActionMatchesExpected: firstHeroActionMatchesExpected,
    firstHeroActionExpectedLabel: firstHeroActionExpectedLabel,
    firstHeroActionActualLabel: firstHeroActionActualLabel,
  );
}
