import '../fsm/engine_fsm_v1.dart';
import '../model/snapshot_v1.dart';
import 'step_v1.dart';

class ScenarioV1 {
  const ScenarioV1({
    required this.scenarioId,
    required this.initialSnapshot,
    required this.steps,
  });

  final String scenarioId;
  final EngineSnapshotV1 initialSnapshot;
  final List<StepV1> steps;
}

class ReplayTraceEntryV1 {
  const ReplayTraceEntryV1({
    required this.stepIndex,
    required this.step,
    required this.result,
    this.violationSummary,
  });

  final int stepIndex;
  final StepV1 step;
  final EngineStepResultV1 result;
  final String? violationSummary;

  @override
  bool operator ==(Object other) {
    if (other is! ReplayTraceEntryV1) {
      return false;
    }
    return stepIndex == other.stepIndex &&
        step == other.step &&
        result.state == other.result.state &&
        _listEquals(result.effects, other.result.effects) &&
        _listEquals(result.violations, other.result.violations) &&
        violationSummary == other.violationSummary;
  }

  @override
  int get hashCode => Object.hash(
    stepIndex,
    step,
    result.state,
    Object.hashAll(result.effects),
    Object.hashAll(result.violations),
    violationSummary,
  );
}

class ReplayTraceV1 {
  const ReplayTraceV1({
    required this.scenarioId,
    required this.entries,
    required this.isSuccess,
    this.stoppedAtStep,
  });

  final String scenarioId;
  final List<ReplayTraceEntryV1> entries;
  final bool isSuccess;
  final int? stoppedAtStep;

  @override
  bool operator ==(Object other) {
    if (other is! ReplayTraceV1) {
      return false;
    }
    return scenarioId == other.scenarioId &&
        _listEquals(entries, other.entries) &&
        isSuccess == other.isSuccess &&
        stoppedAtStep == other.stoppedAtStep;
  }

  @override
  int get hashCode => Object.hash(
    scenarioId,
    Object.hashAll(entries),
    isSuccess,
    stoppedAtStep,
  );
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) {
    return true;
  }
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
