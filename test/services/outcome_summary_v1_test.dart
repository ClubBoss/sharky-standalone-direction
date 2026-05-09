import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';
import 'package:test/test.dart';

ScenarioReplayerViewModel _snapshot() {
  return const ScenarioReplayerViewModel(
    heroStack: 110,
    villainStack: 90,
    pot: 20,
    toCall: 0,
    street: ReplayerStreet.turn,
    actingSeat: ReplayerSeat.hero,
    stepIndex: 0,
    minRaiseTo: 20,
  );
}

void main() {
  test('success outcome kind produces stable deterministic lines', () {
    final summary = OutcomeSummaryV1.fromScenarioResult(
      packId: 'world1_spine_campaign_v1',
      worldId: 1,
      beatIndex: 0,
      winner: ReplayerSeat.hero,
      reason: 'call',
      finalSnapshot: _snapshot(),
      timeToDecisionMs: 420,
    );

    expect(summary.outcomeKind, OutcomeKindV1.success);
    expect(summary.lines[2], 'Outcome: line held');
    expect(summary.lines, contains('Decision ms: 420'));
  });

  test('mistake outcome includes factual feedback line deterministically', () {
    final summary = OutcomeSummaryV1.fromScenarioResult(
      packId: 'world2_spine_campaign_v1',
      worldId: 2,
      beatIndex: 3,
      winner: ReplayerSeat.villain,
      reason: 'incorrect_seat',
      finalSnapshot: _snapshot(),
    );

    expect(summary.outcomeKind, OutcomeKindV1.mistake);
    expect(summary.lines[2], 'Outcome: mistake punished');
    expect(summary.lines, contains('Fact: villain won after incorrect_seat.'));
    expect(summary.errorType, 'incorrect_seat');
  });

  test('aborted outcome kind is mapped from reason', () {
    final summary = OutcomeSummaryV1.fromScenarioResult(
      packId: 'world3_spine_campaign_v1',
      worldId: 3,
      beatIndex: 4,
      winner: ReplayerSeat.villain,
      reason: 'aborted',
      finalSnapshot: _snapshot(),
    );

    expect(summary.outcomeKind, OutcomeKindV1.aborted);
    expect(summary.lines[2], 'Outcome: run aborted');
    expect(
      summary.lines,
      contains('Fact: run stopped before a resolved showdown.'),
    );
  });

  test('same input yields identical lines', () {
    final first = OutcomeSummaryV1.fromScenarioResult(
      packId: 'world4_spine_campaign_v1',
      worldId: 4,
      beatIndex: 8,
      winner: ReplayerSeat.villain,
      reason: 'fold',
      finalSnapshot: _snapshot(),
      timeToDecisionMs: 123,
    );
    final second = OutcomeSummaryV1.fromScenarioResult(
      packId: 'world4_spine_campaign_v1',
      worldId: 4,
      beatIndex: 8,
      winner: ReplayerSeat.villain,
      reason: 'fold',
      finalSnapshot: _snapshot(),
      timeToDecisionMs: 123,
    );

    expect(first.outcomeKind, OutcomeKindV1.mistake);
    expect(first.lines, second.lines);
  });
}
