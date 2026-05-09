import 'package:poker_analyzer/engine/scenario_replayer_fsm_v1.dart';
import 'package:poker_analyzer/services/drill_contract_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_invariant_spine_v1.dart';
import 'package:poker_analyzer/services/session_drill_projection_truth_reconciliation_v1.dart';

void validateScenarioBackedDeterministicActionContractV1({
  required DrillScenarioCoreV1 core,
  required DrillScenarioSeatContextV1? seatContext,
  required bool requireInitiative,
  required String errorPrefix,
}) {
  if (seatContext == null) {
    throw StateError('$errorPrefix requires seat context');
  }
  if (core.availableActionsV1 == null || core.availableActionsV1!.isEmpty) {
    throw StateError('$errorPrefix requires available_actions_v1');
  }
  if (core.expectedActionIdV1 == null || core.expectedActionIdV1!.isEmpty) {
    throw StateError('$errorPrefix requires expected_action');
  }
  if (core.feedbackCorrectV1 == null || core.feedbackIncorrectV1 == null) {
    throw StateError(
      '$errorPrefix requires explicit feedback_correct_v1 and feedback_incorrect_v1',
    );
  }
  final activeSeats = seatContext.activeSeatsV1;
  final foldedSeats = seatContext.foldedSeatsV1 ?? const <String>[];
  final emptySeats = seatContext.emptySeatsV1 ?? const <String>[];
  final allSeats = <String>{...activeSeats, ...foldedSeats, ...emptySeats};
  if (allSeats.length !=
      activeSeats.length + foldedSeats.length + emptySeats.length) {
    throw StateError(
      '$errorPrefix requires disjoint active/folded/empty seats',
    );
  }
  if (!allSeats.contains(seatContext.heroSeatV1) ||
      !allSeats.contains(seatContext.villainSeatV1)) {
    throw StateError(
      '$errorPrefix requires hero/villain seats inside authored seat state',
    );
  }
  final hasAnyInitiativeField =
      seatContext.lastAggressorV1 != null ||
      seatContext.initiativeOwnerV1 != null;
  final hasFullInitiativeFields =
      seatContext.lastAggressorV1 != null &&
      seatContext.initiativeOwnerV1 != null;
  if (hasAnyInitiativeField && !hasFullInitiativeFields) {
    throw StateError(
      '$errorPrefix requires both last_aggressor_v1 and initiative_owner_v1 together',
    );
  }
  if (requireInitiative && !hasFullInitiativeFields) {
    throw StateError(
      '$errorPrefix requires last_aggressor_v1 and initiative_owner_v1 for initiative-driven scenarios',
    );
  }
}

class HeadlessScenarioValidationResultV1 {
  const HeadlessScenarioValidationResultV1({
    required this.stepCount,
    required this.scenarioSpecs,
  });

  final int stepCount;
  final List<ScenarioSpecV1> scenarioSpecs;
}

class HeadlessScenarioValidatorV1 {
  const HeadlessScenarioValidatorV1();

  HeadlessScenarioValidationResultV1 validateWorld2SingleStepTableScenarioV1(
    DrillSpecV1 spec,
  ) {
    if (spec.kind != DrillKindV1.positionThinkingChoice &&
        spec.kind != DrillKindV1.initiativeAggressorChoice) {
      throw StateError(
        'headless World 2 single-step validation requires position_thinking_choice_v1 or initiative_aggressor_choice_v1',
      );
    }

    final core = spec.scenarioCoreV1;
    final tableContext = spec.scenarioTableContextV1;
    validateScenarioBackedDeterministicActionContractV1(
      core: core,
      seatContext: tableContext?.seatContextV1,
      requireInitiative: spec.kind == DrillKindV1.initiativeAggressorChoice,
      errorPrefix: 'headless World 2 single-step validation',
    );
    final scenario = _buildScenarioSpecFromContext(
      core: core,
      tableContext: tableContext,
      errorPrefix: 'headless World 2 single-step validation',
    );

    return _validateScenarioExecution(
      spec: spec,
      scenario: scenario,
      expectedAction: core.expectedActionIdV1!,
      legalActions: core.availableActionsV1!,
      chainStepIndex: null,
      errorPrefix: 'headless World 2 single-step validation',
      stepLabel: '',
    );
  }

  HeadlessScenarioValidationResultV1 validateWorld2ThreeStepHandChainV1(
    DrillSpecV1 spec,
  ) {
    validateDeterministicMultiStepChainShapeContractV1(
      spec: spec,
      minSteps: 3,
      maxSteps: 3,
      errorPrefix: 'headless World 2 three-step validation',
    );
    final steps = spec.chainStepsV1!;

    final scenarios = <ScenarioSpecV1>[];
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      _assertStepPayload(step);
      final scenario = _buildScenarioSpecFromContext(
        core: step.scenarioCoreV1,
        tableContext: step.scenarioTableContextV1,
        errorPrefix: 'headless World 2 three-step validation',
      );
      final result = _validateScenarioExecution(
        spec: spec,
        scenario: scenario,
        expectedAction: step.scenarioCoreV1.expectedActionIdV1!,
        legalActions: step.scenarioCoreV1.availableActionsV1!,
        chainStepIndex: i,
        errorPrefix: 'headless World 2 three-step validation',
        stepLabel: 'step ${i + 1} ',
      );
      scenarios.addAll(result.scenarioSpecs);
    }

    return HeadlessScenarioValidationResultV1(
      stepCount: steps.length,
      scenarioSpecs: List<ScenarioSpecV1>.unmodifiable(scenarios),
    );
  }

  HeadlessScenarioValidationResultV1
  validateWorld2PositionInitiativeTextureChainV1(DrillSpecV1 spec) {
    return validateWorld2ThreeStepHandChainV1(spec);
  }

  void _assertStepPayload(DrillChainStepV1 step) {
    validateScenarioBackedDeterministicActionContractV1(
      core: step.scenarioCoreV1,
      seatContext: step.scenarioTableContextV1?.seatContextV1,
      requireInitiative:
          step.scenarioTableContextV1?.seatContextV1?.initiativeOwnerV1 != null,
      errorPrefix: 'headless World 2 three-step validation',
    );
    final boardContext = step.scenarioTableContextV1?.boardContextV1;
    final boardCards = boardContext?.boardCardsV1;
    if (boardCards != null && boardCards.length != 3) {
      throw StateError(
        'headless World 2 three-step validation requires exactly 3 board_cards_v1 when board context is authored',
      );
    }
    final heroHoleCards = boardContext?.heroHoleCardsV1;
    if (heroHoleCards != null && heroHoleCards.length != 2) {
      throw StateError(
        'headless World 2 three-step validation requires exactly 2 hero_hole_cards_v1 when hero cards are authored',
      );
    }
    if (_isBoardActionStep(step.scenarioCoreV1.availableActionsV1!) &&
        boardCards == null) {
      throw StateError(
        'headless World 2 three-step validation requires board_cards_v1 for board-driven action steps',
      );
    }
    if (_isOutsStep(step.scenarioCoreV1.availableActionsV1!) &&
        (boardCards == null || heroHoleCards == null)) {
      throw StateError(
        'headless World 2 three-step validation requires board_cards_v1 and hero_hole_cards_v1 for outs steps',
      );
    }
  }

  HeadlessScenarioValidationResultV1 _validateScenarioExecution({
    required DrillSpecV1 spec,
    required ScenarioSpecV1 scenario,
    required String expectedAction,
    required List<String> legalActions,
    required int? chainStepIndex,
    required String errorPrefix,
    required String stepLabel,
  }) {
    scenario.validate();

    final activeState = ScenarioReplayerFsmV1.start(scenario).state;
    if (activeState is! StreetActiveState) {
      throw StateError(
        '$errorPrefix ${stepLabel}did not enter StreetActiveState',
      );
    }
    if (!_sameOrder(activeState.legalActions, legalActions)) {
      throw StateError(
        '$errorPrefix ${stepLabel}legal actions do not match authored order',
      );
    }
    if (!activeState.legalActions.contains(expectedAction)) {
      throw StateError(
        '$errorPrefix ${stepLabel}expected action is not legal in scenario state',
      );
    }

    final eval = const DrillEvaluatorV1().evaluate(
      spec,
      DrillUserEventV1.actionChoice(
        expectedAction,
        chainStepIndex: chainStepIndex,
      ),
    );
    if (!eval.isPass || eval.isSoftPass) {
      throw StateError(
        '$errorPrefix ${stepLabel}expected action did not evaluate as a hard pass',
      );
    }

    final engine = ScenarioReplayerFsmV1.start(scenario);
    final evaluationState = engine.applyUserAction(expectedAction);
    if (evaluationState is! EvaluationState ||
        evaluationState.action != expectedAction) {
      throw StateError(
        '$errorPrefix ${stepLabel}did not enter EvaluationState for expected action',
      );
    }
    final outcomeState = engine.advance();
    if (outcomeState is! OutcomeState ||
        outcomeState.result != expectedAction) {
      throw StateError(
        '$errorPrefix ${stepLabel}did not resolve to the expected action',
      );
    }

    return HeadlessScenarioValidationResultV1(
      stepCount: 1,
      scenarioSpecs: List<ScenarioSpecV1>.unmodifiable(<ScenarioSpecV1>[
        scenario,
      ]),
    );
  }

  ScenarioSpecV1 _buildScenarioSpecFromContext({
    required DrillScenarioCoreV1 core,
    required DrillScenarioTableContextV1? tableContext,
    required String errorPrefix,
  }) {
    final seatContext = tableContext?.seatContextV1;
    if (seatContext == null) {
      throw StateError('$errorPrefix requires seat context');
    }

    final activeSeats = seatContext.activeSeatsV1;
    final foldedSeats = seatContext.foldedSeatsV1 ?? const <String>[];
    final emptySeats = seatContext.emptySeatsV1 ?? const <String>[];
    final initiativeActor = seatContext.initiativeOwnerV1;
    final actingSeatId = initiativeActor == 'hero'
        ? seatContext.heroSeatV1
        : initiativeActor == 'villain'
        ? seatContext.villainSeatV1
        : core.expectedActionIdV1 == 'villain'
        ? seatContext.villainSeatV1
        : seatContext.heroSeatV1;
    final reconciledTruth = reconcileSessionDrillTableTruthV1(
      errorPrefix: errorPrefix,
      playerCountV1: seatContext.playerCountV1,
      heroSeatV1: seatContext.heroSeatV1,
      villainSeatV1: seatContext.villainSeatV1,
      activeSeatsV1: activeSeats,
      foldedSeatsV1: foldedSeats,
      emptySeatsV1: emptySeats,
      actingSeatV1: actingSeatId,
      blindLevelV1: seatContext.blindLevelV1,
      seatOrderPolicyV1:
          SessionDrillSeatOrderPolicyV1.canonicalAuthoredArcOrder,
    );
    return buildValidatedSessionDrillProjectedScenarioV1(
      errorPrefix: errorPrefix,
      reconciledTruthV1: reconciledTruth,
      streetV1: Street.values.firstWhere(
        (value) => value.name == core.streetV1,
      ),
      legalActionsV1: core.availableActionsV1!,
      solutionBestActionV1: core.expectedActionIdV1!,
    );
  }

  bool _isBoardActionStep(List<String> actions) =>
      _sameOrder(actions, const <String>['call', 'raise']);

  bool _isOutsStep(List<String> actions) =>
      _sameOrder(actions, const <String>['4', '8', '9', '15']);

  bool _sameOrder(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
