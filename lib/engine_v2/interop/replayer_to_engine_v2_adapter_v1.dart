import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';

import '../engine_v2.dart';

class EngineV2InteropResultV1 {
  const EngineV2InteropResultV1({
    required this.scenario,
    required this.violations,
  });

  final ScenarioV1? scenario;
  final List<EngineViolationV1> violations;

  bool get isSuccess => scenario != null && violations.isEmpty;
}

class ReplayerToEngineV2AdapterV1 {
  const ReplayerToEngineV2AdapterV1();

  // Deterministic conversion rule for numeric chips: nearest integer.
  static int toChipsInt(num value) => value.round();

  EngineV2InteropResultV1 tryConvert({
    required String scenarioId,
    required ScenarioReplayerSpec replayer,
  }) {
    if (replayer.steps.isEmpty) {
      return _fail(
        'interop_empty_steps',
        'Replayer scenario must include steps',
      );
    }

    final players = const <PlayerIdV1>[
      PlayerIdV1('hero'),
      PlayerIdV1('villain'),
    ];
    final hero = players[0];
    final villain = players[1];
    final actingPlayer = _mapSeat(replayer.initialSnapshot.actingSeat);
    final nonActingPlayer = actingPlayer == hero ? villain : hero;
    final toCallChips = toChipsInt(replayer.initialSnapshot.toCall);

    final baseSnapshot = EngineSnapshotV1.initial(
      players: players,
      startingStack: ChipsV1(toChipsInt(replayer.initialSnapshot.heroStack)),
    );

    final initialStacks = baseSnapshot.stacksState.copyWith(
      stackByPlayer: <PlayerIdV1, ChipsV1>{
        hero: ChipsV1(toChipsInt(replayer.initialSnapshot.heroStack)),
        villain: ChipsV1(toChipsInt(replayer.initialSnapshot.villainStack)),
      },
      committedByPlayer: <PlayerIdV1, ChipsV1>{
        hero: ChipsV1(
          toCallChips > 0 && nonActingPlayer == hero ? toCallChips : 0,
        ),
        villain: ChipsV1(
          toCallChips > 0 && nonActingPlayer == villain ? toCallChips : 0,
        ),
      },
      pot: ChipsV1(toChipsInt(replayer.initialSnapshot.pot)),
    );

    final initialSnapshot = baseSnapshot.copyWith(
      stacksState: initialStacks,
      actingPlayer: actingPlayer,
      street: _mapStreet(replayer.initialSnapshot.street),
      currentBet: ChipsV1(toCallChips),
      lastAction: toCallChips > 0
          ? ActionV1(actorId: nonActingPlayer, kind: ActionKindV1.bet)
          : null,
      lastBetSize: ChipsV1(
        _safeNonNegative(
          toChipsInt(replayer.initialSnapshot.minRaiseTo) - toCallChips,
        ),
      ),
    );

    final steps = <StepV1>[const StartHandStepV1()];

    for (final step in replayer.steps) {
      final actingPlayer = _mapSeat(step.actingSeat);
      final action = _chooseAction(
        legalActions: step.legalActions,
        actingPlayer: actingPlayer,
        toCall: toChipsInt(replayer.initialSnapshot.toCall),
        currentBet: toChipsInt(replayer.initialSnapshot.toCall),
        minAmount: _minLegalAmount(step.legalActions),
        actorStack: replayer.initialSnapshot.stackFor(step.actingSeat),
      );
      if (action == null) {
        return _fail(
          'interop_unsupported_legal_actions',
          'Unable to map legal actions to engine_v2 action',
        );
      }
      steps.add(PlayerActionStepV1(playerId: actingPlayer, action: action));
      steps.add(const AdvanceStepV1());
    }

    // Replay engine completes after one resolve. Engine v2 requires evaluation state
    // before finish, so deterministically advance through remaining streets with checks.
    final remainingStreets = _remainingStreetAdvances(
      _mapStreet(replayer.initialSnapshot.street),
    );
    var nextActor = _mapSeat(replayer.initialSnapshot.actingSeat) == hero
        ? villain
        : hero;
    for (var i = 0; i < remainingStreets; i++) {
      steps.add(
        PlayerActionStepV1(
          playerId: nextActor,
          action: ActionV1(actorId: nextActor, kind: ActionKindV1.check),
        ),
      );
      steps.add(const AdvanceStepV1());
      nextActor = nextActor == hero ? villain : hero;
    }

    steps.add(const FinishStepV1());

    final scenario = ScenarioV1(
      scenarioId: scenarioId,
      initialSnapshot: initialSnapshot,
      steps: List<StepV1>.unmodifiable(steps),
    );
    return EngineV2InteropResultV1(
      scenario: scenario,
      violations: const <EngineViolationV1>[],
    );
  }

  EngineV2InteropResultV1 _fail(String code, String message) {
    return EngineV2InteropResultV1(
      scenario: null,
      violations: <EngineViolationV1>[
        EngineViolationV1(code: code, message: message),
      ],
    );
  }

  PlayerIdV1 _mapSeat(ReplayerSeat seat) {
    return seat == ReplayerSeat.hero
        ? const PlayerIdV1('hero')
        : const PlayerIdV1('villain');
  }

  StreetV1 _mapStreet(ReplayerStreet street) {
    switch (street) {
      case ReplayerStreet.preflop:
        return StreetV1.preflop;
      case ReplayerStreet.flop:
        return StreetV1.flop;
      case ReplayerStreet.turn:
        return StreetV1.turn;
      case ReplayerStreet.river:
        return StreetV1.river;
    }
  }

  int _remainingStreetAdvances(StreetV1 street) {
    switch (street) {
      case StreetV1.preflop:
        return 3;
      case StreetV1.flop:
        return 2;
      case StreetV1.turn:
        return 1;
      case StreetV1.river:
        return 0;
    }
  }

  int _safeNonNegative(int value) => value < 0 ? 0 : value;

  int _minLegalAmount(List<ReplayerActionSpec> legalActions) {
    final values = legalActions
        .map((a) => a.minAmount)
        .whereType<int>()
        .toList();
    if (values.isEmpty) {
      return 1;
    }
    values.sort();
    return values.first;
  }

  ActionV1? _chooseAction({
    required List<ReplayerActionSpec> legalActions,
    required PlayerIdV1 actingPlayer,
    required int toCall,
    required int currentBet,
    required int minAmount,
    required int actorStack,
  }) {
    if (legalActions.isEmpty) {
      if (toCall == 0) {
        return ActionV1(actorId: actingPlayer, kind: ActionKindV1.check);
      }
      if (actorStack >= toCall) {
        return ActionV1(actorId: actingPlayer, kind: ActionKindV1.call);
      }
      return ActionV1(actorId: actingPlayer, kind: ActionKindV1.fold);
    }

    final kinds = legalActions.map((a) => a.kind).toSet();

    if (kinds.contains(ReplayerActionKind.callCheck)) {
      if (toCall > 0) {
        return ActionV1(actorId: actingPlayer, kind: ActionKindV1.call);
      }
      return ActionV1(actorId: actingPlayer, kind: ActionKindV1.check);
    }

    if (kinds.contains(ReplayerActionKind.betRaise)) {
      if (toCall > 0) {
        final raiseTo = minAmount > currentBet ? minAmount : currentBet + 1;
        return ActionV1(
          actorId: actingPlayer,
          kind: ActionKindV1.raise,
          amount: raiseTo,
        );
      }
      final betAmount = minAmount > 0 ? minAmount : 1;
      return ActionV1(
        actorId: actingPlayer,
        kind: ActionKindV1.bet,
        amount: betAmount,
      );
    }

    if (kinds.contains(ReplayerActionKind.fold)) {
      return ActionV1(actorId: actingPlayer, kind: ActionKindV1.fold);
    }

    return null;
  }
}
