import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_pack_registry;
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';
import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:test/test.dart';

ScenarioReplayerSpec _minimalReplayerSpec({
  int heroStack = 100,
  int villainStack = 100,
  int pot = 10,
  int toCall = 10,
  ReplayerStreet street = ReplayerStreet.preflop,
}) {
  return ScenarioReplayerSpec(
    initialSnapshot: ReplayerSnapshot(
      heroStack: heroStack,
      villainStack: villainStack,
      pot: pot,
      toCall: toCall,
      street: street,
      actingSeat: ReplayerSeat.hero,
      minRaiseTo: toCall + 10,
    ),
    steps: const <ReplayerStep>[
      ReplayerStep(
        actingSeat: ReplayerSeat.hero,
        legalActions: <ReplayerActionSpec>[
          ReplayerActionSpec(kind: ReplayerActionKind.fold),
          ReplayerActionSpec(kind: ReplayerActionKind.callCheck),
          ReplayerActionSpec(kind: ReplayerActionKind.betRaise, minAmount: 20),
        ],
      ),
    ],
  );
}

void main() {
  test('converts minimal replayer scenario into ScenarioV1 with steps', () {
    final result = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'interop-min',
      replayer: _minimalReplayerSpec(),
    );

    expect(result.isSuccess, isTrue);
    final scenario = result.scenario!;
    expect(scenario.steps, isNotEmpty);
    expect(scenario.steps.first, isA<StartHandStepV1>());
  });

  test('maps empty legal actions deterministically', () {
    final unsupported = ScenarioReplayerSpec(
      initialSnapshot: _minimalReplayerSpec().initialSnapshot,
      steps: const <ReplayerStep>[
        ReplayerStep(
          actingSeat: ReplayerSeat.hero,
          legalActions: <ReplayerActionSpec>[],
        ),
      ],
    );

    final result = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'interop-unsupported',
      replayer: unsupported,
    );

    expect(result.isSuccess, isTrue);
    expect(result.scenario, isNotNull);
    expect(result.violations, isEmpty);
    expect(result.scenario!.steps.length, greaterThan(1));
  });

  test('still rejects empty replayer step list', () {
    final unsupported = ScenarioReplayerSpec(
      initialSnapshot: _minimalReplayerSpec().initialSnapshot,
      steps: const <ReplayerStep>[],
    );

    final result = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'interop-empty-steps',
      replayer: unsupported,
    );

    expect(result.isSuccess, isFalse);
    expect(result.scenario, isNull);
    expect(result.violations.first.code, 'interop_empty_steps');
  });

  test('rounding rule correctness for numeric chips', () {
    expect(ReplayerToEngineV2AdapterV1.toChipsInt(10.49), 10);
    expect(ReplayerToEngineV2AdapterV1.toChipsInt(10.50), 11);
    expect(ReplayerToEngineV2AdapterV1.toChipsInt(11), 11);
  });

  test('conversion is deterministic across repeated runs', () {
    final adapter = const ReplayerToEngineV2AdapterV1();
    final spec = _minimalReplayerSpec();

    final first = adapter.tryConvert(scenarioId: 'interop-d', replayer: spec);
    final second = adapter.tryConvert(scenarioId: 'interop-d', replayer: spec);

    expect(first.isSuccess, isTrue);
    expect(second.isSuccess, isTrue);
    expect(first.scenario!.initialSnapshot, second.scenario!.initialSnapshot);
    expect(first.scenario!.steps.length, second.scenario!.steps.length);
    expect(
      first.scenario!.steps.map((s) => s.label).toList(),
      second.scenario!.steps.map((s) => s.label).toList(),
    );
  });

  test('scenario validation passes for converted scenario', () {
    final converted = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'interop-valid',
      replayer: _minimalReplayerSpec(),
    );

    final violations = const ScenarioValidatorV1().validateScenario(
      converted.scenario!,
    );
    expect(violations, isEmpty);
  });

  test('runScenarioWithEvaluation works on converted scenario', () {
    final converted = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'interop-eval',
      replayer: _minimalReplayerSpec(street: ReplayerStreet.river),
    );

    final run = const EngineV2().runScenarioWithEvaluation(converted.scenario!);
    expect(run.trace.entries, isNotEmpty);
    expect(
      run.outcome.verdict == DecisionVerdictV1.correct ||
          run.outcome.verdict == DecisionVerdictV1.incorrect,
      isTrue,
    );
  });

  test('real world1 runner scenario converts and runs through engine_v2', () {
    final store = _FakeCampaignStoreV1();
    final runner = CampaignSpineRunnerV1(store: store);
    final pointer = CampaignSpineBeatPointerV1(
      packId: 'world1_spine_campaign_v1',
      worldId: 1,
      beatIndex: 0,
      totalBeats: store.handCountForPackId('world1_spine_campaign_v1'),
      beat: store.beatForPackIdAndIndex('world1_spine_campaign_v1', 0),
    );
    final replayer = runner.scenarioForPointer(pointer);

    final converted = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'world1-real-interop',
      replayer: replayer,
    );
    expect(converted.isSuccess, isTrue);

    final run = const EngineV2().runScenarioWithEvaluation(converted.scenario!);
    expect(run.trace.entries, isNotEmpty);
    expect(run.outcome.traceSummary, isNotNull);
  });

  test('multi-street progression is deterministic for one scenario', () {
    final converted = const ReplayerToEngineV2AdapterV1().tryConvert(
      scenarioId: 'interop-multistreet',
      replayer: _minimalReplayerSpec(street: ReplayerStreet.preflop),
    );
    expect(converted.isSuccess, isTrue);

    final run = const EngineV2().runScenarioWithEvaluation(converted.scenario!);
    expect(run.outcome.traceSummary?.finalStateKind, EngineStateKindV1.outcome);

    final actingStreetSequence = run.trace.entries
        .map((entry) => entry.result.state)
        .whereType<StreetActiveEngineStateV1>()
        .where((state) => state.phase == StreetPhaseV1.acting)
        .map((state) => state.snapshot.street)
        .fold<List<StreetV1>>(<StreetV1>[], (acc, street) {
          if (acc.isEmpty || acc.last != street) {
            acc.add(street);
          }
          return acc;
        });
    expect(actingStreetSequence, <StreetV1>[
      StreetV1.preflop,
      StreetV1.flop,
      StreetV1.turn,
      StreetV1.river,
    ]);

    final revealEffects = run.trace.entries
        .expand((entry) => entry.result.effects)
        .where((effect) => effect.startsWith('reveal_'))
        .toList(growable: false);
    expect(revealEffects, <String>[
      'reveal_flop',
      'reveal_turn',
      'reveal_river',
    ]);

    final boardVisibleByStreet = <StreetV1, int>{
      for (final street in actingStreetSequence)
        street: switch (street) {
          StreetV1.preflop => 0,
          StreetV1.flop => 3,
          StreetV1.turn => 4,
          StreetV1.river => 5,
        },
    };
    expect(boardVisibleByStreet, <StreetV1, int>{
      StreetV1.preflop: 0,
      StreetV1.flop: 3,
      StreetV1.turn: 4,
      StreetV1.river: 5,
    });
  });
}

class _FakeCampaignStoreV1 implements CampaignSpineProgressStoreV1 {
  @override
  campaign_pack_registry.MicroTaskStep beatForPackIdAndIndex(
    String packId,
    int index,
  ) {
    return const campaign_pack_registry.MicroTaskStep(
      prompt: 'p',
      hint: 'h',
      expectedSeatIds: <String>['btn'],
    );
  }

  @override
  Future<void> clearActivePackId() async {}

  @override
  Future<String?> getActivePackId() async => 'world1_spine_campaign_v1';

  @override
  Future<int> getNextHandIndex() async => 0;

  @override
  Future<String> getNextPackToRun() async => 'world1_spine_campaign_v1';

  @override
  int handCountForPackId(String packId) => 12;

  @override
  Future<bool> isPackCompleted(String packId) async => false;

  @override
  Future<void> markPackCompleted(String packId) async {}

  @override
  Future<void> setActivePackId(String packId) async {}

  @override
  Future<void> setNextHandIndex(int index) async {}

  @override
  int worldIndexForPackId(String packId) => 1;
}
