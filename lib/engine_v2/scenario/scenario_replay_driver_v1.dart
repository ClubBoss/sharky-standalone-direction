import '../fsm/engine_fsm_v1.dart';
import 'scenario_v1.dart';

class ScenarioReplayDriverV1 {
  const ScenarioReplayDriverV1();

  ReplayTraceV1 runScenario(ScenarioV1 scenario) {
    final fsm = EngineFsmV1(initialSnapshot: scenario.initialSnapshot);
    final entries = <ReplayTraceEntryV1>[];

    for (var i = 0; i < scenario.steps.length; i++) {
      final step = scenario.steps[i];
      final result = fsm.apply(step.toEvent());
      final summary = result.violations.isEmpty
          ? null
          : result.violations.map((v) => '${v.code}:${v.message}').join('; ');

      entries.add(
        ReplayTraceEntryV1(
          stepIndex: i,
          step: step,
          result: result,
          violationSummary: summary,
        ),
      );

      if (result.violations.isNotEmpty) {
        return ReplayTraceV1(
          scenarioId: scenario.scenarioId,
          entries: entries,
          isSuccess: false,
          stoppedAtStep: i,
        );
      }
    }

    return ReplayTraceV1(
      scenarioId: scenario.scenarioId,
      entries: entries,
      isSuccess: true,
    );
  }
}
