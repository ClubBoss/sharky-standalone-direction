import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:poker_analyzer/ui_v2/runner/world1_canonical_hand_loop_execution_contract_v1.dart';

ScenarioV1 _heroCheckScenario() {
  final players = const <PlayerIdV1>[PlayerIdV1('hero'), PlayerIdV1('villain')];
  final base = EngineSnapshotV1.initial(
    players: players,
    startingStack: const ChipsV1(100),
  );

  return ScenarioV1(
    scenarioId: 'hero_check',
    initialSnapshot: base,
    steps: const <StepV1>[
      StartHandStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('hero'),
        action: ActionV1(actorId: PlayerIdV1('hero'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('villain'),
        action: ActionV1(
          actorId: PlayerIdV1('villain'),
          kind: ActionKindV1.check,
        ),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('hero'),
        action: ActionV1(actorId: PlayerIdV1('hero'), kind: ActionKindV1.check),
      ),
      AdvanceStepV1(),
      PlayerActionStepV1(
        playerId: PlayerIdV1('villain'),
        action: ActionV1(
          actorId: PlayerIdV1('villain'),
          kind: ActionKindV1.check,
        ),
      ),
      AdvanceStepV1(),
      FinishStepV1(),
    ],
  );
}

void main() {
  test(
    'hand-loop execution contract runs engine body and records expectation',
    () {
      final run = runWorld1CanonicalEngineV2HandLoopV1(
        _heroCheckScenario(),
        expectedFirstHeroActionKind: ActionKindV1.check,
      );

      expect(run.entries, isNotEmpty);
      expect(run.heroActionsApplied, greaterThan(0));
      expect(run.firstHeroActionMatchesExpected, isTrue);
      expect(run.firstHeroActionExpectedLabel, 'CHECK');
      expect(run.firstHeroActionActualLabel, 'CHECK');
    },
  );

  test('hand-loop execution contract detects first-action mismatch', () {
    final run = runWorld1CanonicalEngineV2HandLoopV1(
      _heroCheckScenario(),
      firstHeroActionOverride: const ActionV1(
        actorId: PlayerIdV1('hero'),
        kind: ActionKindV1.fold,
      ),
      expectedFirstHeroActionKind: ActionKindV1.check,
    );

    expect(run.entries, isNotEmpty);
    expect(run.firstHeroActionMatchesExpected, isFalse);
    expect(run.firstHeroActionExpectedLabel, 'CHECK');
    expect(run.firstHeroActionActualLabel, 'FOLD');
  });
}
