import 'package:poker_analyzer/engine_v2/engine_v2.dart';
import 'package:test/test.dart';

void main() {
  group('EngineV2AutoOpponentPolicyV1', () {
    test('toCall==0 chooses CHECK', () {
      final policy = const EngineV2AutoOpponentPolicyV1();
      final snapshot = EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('hero'), PlayerIdV1('villain')],
        startingStack: const ChipsV1(100),
      );

      final action = policy.chooseAction(snapshot);
      expect(action.kind, ActionKindV1.check);
      expect(action.actorId, snapshot.actingPlayer);
    });

    test('toCall>0 and stack>=toCall chooses CALL', () {
      final policy = const EngineV2AutoOpponentPolicyV1();
      final base = EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('hero'), PlayerIdV1('villain')],
        startingStack: const ChipsV1(100),
      );
      final snapshot = base.copyWith(currentBet: const ChipsV1(12));

      final action = policy.chooseAction(snapshot);
      expect(action.kind, ActionKindV1.call);
      expect(action.actorId, snapshot.actingPlayer);
    });

    test('stack<toCall chooses FOLD', () {
      final policy = const EngineV2AutoOpponentPolicyV1();
      final base = EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('hero'), PlayerIdV1('villain')],
        startingStack: const ChipsV1(100),
      );
      final snapshot = base.copyWith(
        currentBet: const ChipsV1(10),
        stacksState: base.stacksState.copyWith(
          stackByPlayer: <PlayerIdV1, ChipsV1>{
            const PlayerIdV1('hero'): const ChipsV1(5),
            const PlayerIdV1('villain'): const ChipsV1(100),
          },
        ),
      );

      final action = policy.chooseAction(snapshot);
      expect(action.kind, ActionKindV1.fold);
      expect(action.actorId, snapshot.actingPlayer);
    });
  });

  group('EngineV2AutoResolveDriverV1', () {
    test('driver stops at hero-to-act boundary', () {
      final fsm = EngineFsmV1();
      fsm.apply(const StartHandEventV1());

      final run = const EngineV2AutoResolveDriverV1().runUntilBoundary(
        fsm: fsm,
        heroPlayerId: const PlayerIdV1('p1'),
      );

      expect(run.stopReason, EngineV2AutoResolveStopReasonV1.heroToAct);
      expect(run.entries, isEmpty);
    });

    test('driver stops on violation and does not mutate state', () {
      final base = EngineSnapshotV1.initial(
        players: const <PlayerIdV1>[PlayerIdV1('hero'), PlayerIdV1('villain')],
        startingStack: const ChipsV1(100),
      );
      final fsm = EngineFsmV1(
        initialSnapshot: base.copyWith(
          actingPlayer: const PlayerIdV1('villain'),
          foldedByPlayer: <PlayerIdV1, bool>{
            PlayerIdV1('hero'): false,
            PlayerIdV1('villain'): true,
          },
        ),
      );
      fsm.apply(const StartHandEventV1());
      final before = fsm.state;

      final run = const EngineV2AutoResolveDriverV1().runUntilBoundary(
        fsm: fsm,
        heroPlayerId: const PlayerIdV1('hero'),
      );

      expect(run.stopReason, EngineV2AutoResolveStopReasonV1.violation);
      expect(run.violations, isNotEmpty);
      expect(run.violations.first.code, 'actor_folded');
      expect(fsm.state, before);
    });
  });
}
