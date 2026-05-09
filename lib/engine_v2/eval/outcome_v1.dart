import '../model/engine_types_v1.dart';
import '../model/state_v1.dart';
import 'error_classification_v1.dart';

class OutcomeTraceSummaryV1 {
  const OutcomeTraceSummaryV1({
    required this.totalSteps,
    required this.executedSteps,
    required this.finalStateKind,
    this.stoppedAtStep,
  });

  final int totalSteps;
  final int executedSteps;
  final EngineStateKindV1? finalStateKind;
  final int? stoppedAtStep;

  @override
  bool operator ==(Object other) {
    if (other is! OutcomeTraceSummaryV1) {
      return false;
    }
    return totalSteps == other.totalSteps &&
        executedSteps == other.executedSteps &&
        finalStateKind == other.finalStateKind &&
        stoppedAtStep == other.stoppedAtStep;
  }

  @override
  int get hashCode =>
      Object.hash(totalSteps, executedSteps, finalStateKind, stoppedAtStep);
}

class OutcomeV1 {
  const OutcomeV1({required this.verdict, this.error, this.traceSummary});

  final DecisionVerdictV1 verdict;
  final ErrorDetailV1? error;
  final OutcomeTraceSummaryV1? traceSummary;

  @override
  bool operator ==(Object other) {
    if (other is! OutcomeV1) {
      return false;
    }
    return verdict == other.verdict &&
        error == other.error &&
        traceSummary == other.traceSummary;
  }

  @override
  int get hashCode => Object.hash(verdict, error, traceSummary);
}

class OutcomeAdapterV1 {
  const OutcomeAdapterV1();

  List<String> toSummaryLines(OutcomeV1 outcome) {
    final lines = <String>['Verdict: ${outcome.verdict.name}'];
    final error = outcome.error;
    if (error != null) {
      lines.add('Error type: ${error.type.name}');
      lines.add('Error code: ${error.code}');
      lines.add('Message: ${error.message}');
      if (error.expected != null) {
        lines.add('Expected: ${error.expected}');
      }
      if (error.actual != null) {
        lines.add('Actual: ${error.actual}');
      }
    }
    final summary = outcome.traceSummary;
    if (summary != null) {
      lines.add('Trace: ${summary.executedSteps}/${summary.totalSteps}');
      if (summary.finalStateKind != null) {
        lines.add('Final state: ${summary.finalStateKind!.name}');
      }
      if (summary.stoppedAtStep != null) {
        lines.add('Stopped at step: ${summary.stoppedAtStep}');
      }
    }
    return List<String>.unmodifiable(lines);
  }

  EngineStateKindV1? finalStateKindFromEntries(List<EngineStateV1> states) {
    if (states.isEmpty) {
      return null;
    }
    return states.last.kind;
  }
}
