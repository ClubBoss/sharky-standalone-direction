import '../model/engine_types_v1.dart';
import '../model/action_v1.dart';
import '../scenario/scenario_replay_driver_v1.dart';
import '../scenario/scenario_v1.dart';
import '../scenario/scenario_validator_v1.dart';
import '../scenario/step_v1.dart';
import 'error_classification_v1.dart';
import 'outcome_v1.dart';

class ScenarioRunWithEvaluationV1 {
  const ScenarioRunWithEvaluationV1({
    required this.trace,
    required this.outcome,
  });

  final ReplayTraceV1 trace;
  final OutcomeV1 outcome;

  @override
  bool operator ==(Object other) {
    if (other is! ScenarioRunWithEvaluationV1) {
      return false;
    }
    return trace == other.trace && outcome == other.outcome;
  }

  @override
  int get hashCode => Object.hash(trace, outcome);
}

class EngineV2EvaluatorV1 {
  const EngineV2EvaluatorV1({
    this.validator = const ScenarioValidatorV1(),
    this.driver = const ScenarioReplayDriverV1(),
    this.classifier = const ErrorClassificationV1(),
  });

  final ScenarioValidatorV1 validator;
  final ScenarioReplayDriverV1 driver;
  final ErrorClassificationV1 classifier;

  ScenarioRunWithEvaluationV1 runScenarioWithEvaluation(ScenarioV1 scenario) {
    final validationViolations = validator.validateScenario(scenario);
    if (validationViolations.isNotEmpty) {
      final violation = validationViolations.first;
      final trace = ReplayTraceV1(
        scenarioId: scenario.scenarioId,
        entries: const <ReplayTraceEntryV1>[],
        isSuccess: false,
        stoppedAtStep: 0,
      );
      return ScenarioRunWithEvaluationV1(
        trace: trace,
        outcome: OutcomeV1(
          verdict: DecisionVerdictV1.incorrect,
          error: classifier.fromViolation(
            code: violation.code,
            message: violation.message,
          ),
          traceSummary: const OutcomeTraceSummaryV1(
            totalSteps: 0,
            executedSteps: 0,
            finalStateKind: EngineStateKindV1.setup,
            stoppedAtStep: 0,
          ),
        ),
      );
    }

    final trace = driver.runScenario(scenario);
    final states = trace.entries.map((entry) => entry.result.state).toList();
    final summary = OutcomeTraceSummaryV1(
      totalSteps: scenario.steps.length,
      executedSteps: trace.entries.length,
      finalStateKind: states.isEmpty ? null : states.last.kind,
      stoppedAtStep: trace.stoppedAtStep,
    );

    if (!trace.isSuccess) {
      final violation = trace.entries.last.result.violations.first;
      return ScenarioRunWithEvaluationV1(
        trace: trace,
        outcome: OutcomeV1(
          verdict: DecisionVerdictV1.incorrect,
          error: classifier.fromViolation(
            code: violation.code,
            message: violation.message,
          ),
          traceSummary: summary,
        ),
      );
    }

    final rangeMismatch = _findRangeMismatch(scenario, trace);
    if (rangeMismatch != null) {
      return ScenarioRunWithEvaluationV1(
        trace: trace,
        outcome: OutcomeV1(
          verdict: DecisionVerdictV1.incorrect,
          error: classifier.fromRangeMismatch(
            expected: rangeMismatch.expected,
            actual: rangeMismatch.actual,
          ),
          traceSummary: summary,
        ),
      );
    }

    return ScenarioRunWithEvaluationV1(
      trace: trace,
      outcome: OutcomeV1(
        verdict: DecisionVerdictV1.correct,
        traceSummary: summary,
      ),
    );
  }

  _RangeMismatchV1? _findRangeMismatch(
    ScenarioV1 scenario,
    ReplayTraceV1 trace,
  ) {
    final count = scenario.steps.length < trace.entries.length
        ? scenario.steps.length
        : trace.entries.length;
    for (var i = 0; i < count; i++) {
      final step = scenario.steps[i];
      if (step is! PlayerActionStepV1) {
        continue;
      }
      if (step.expectation == null) {
        continue;
      }
      final traceEntry = trace.entries[i];
      if (!traceEntry.result.isValid) {
        continue;
      }
      final expected = step.expectation!;
      if (!expected.matches(step.action)) {
        return _RangeMismatchV1(
          expected: _actionLabel(expected.expectedAction),
          actual: _actionLabel(step.action),
        );
      }
    }
    return null;
  }

  String _actionLabel(ActionV1 action) {
    final amount = action.amount == null ? '' : ':${action.amount}';
    return '${action.actorId.value}:${action.kind.name}$amount';
  }
}

class EngineV2 {
  const EngineV2({this.evaluator = const EngineV2EvaluatorV1()});

  final EngineV2EvaluatorV1 evaluator;

  ScenarioRunWithEvaluationV1 runScenarioWithEvaluation(ScenarioV1 scenario) {
    return evaluator.runScenarioWithEvaluation(scenario);
  }
}

class _RangeMismatchV1 {
  const _RangeMismatchV1({required this.expected, required this.actual});

  final String expected;
  final String actual;
}
