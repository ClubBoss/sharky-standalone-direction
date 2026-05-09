import '../engine_v2.dart';
import '../fixtures/engine_v2_fixture_scenario_v1.dart';

class EngineV2MvpRunSummaryV1 {
  const EngineV2MvpRunSummaryV1({
    required this.verdict,
    required this.errorType,
    required this.lines,
  });

  final String verdict;
  final String? errorType;
  final List<String> lines;
}

class EngineV2MvpRunBridgeV1 {
  const EngineV2MvpRunBridgeV1();

  EngineV2MvpRunSummaryV1 run({bool rangeMismatchVariant = false}) {
    final scenario = rangeMismatchVariant
        ? buildEngineV2FixtureScenarioRangeMismatchV1()
        : buildEngineV2FixtureScenarioV1();

    final runResult = const EngineV2().runScenarioWithEvaluation(scenario);
    final outcome = runResult.outcome;
    final lines = const OutcomeAdapterV1().toSummaryLines(outcome);

    return EngineV2MvpRunSummaryV1(
      verdict: outcome.verdict.name,
      errorType: outcome.error?.type.name,
      lines: lines,
    );
  }
}
