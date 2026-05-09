import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_registry;
import 'package:poker_analyzer/engine/scenario_replayer/scenario_events.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_models.dart';
import 'package:poker_analyzer/engine/scenario_replayer/scenario_replayer_engine.dart';
import 'package:poker_analyzer/services/outcome_summary_v1.dart';

class CampaignSpineBeatPointerV1 {
  const CampaignSpineBeatPointerV1({
    required this.packId,
    required this.worldId,
    required this.beatIndex,
    required this.totalBeats,
    required this.beat,
  });

  final String packId;
  final int worldId;
  final int beatIndex;
  final int totalBeats;
  final campaign_registry.MicroTaskStep beat;
}

class CampaignSpineRunPlanV1 {
  const CampaignSpineRunPlanV1({required this.pointer, required this.scenario});

  final CampaignSpineBeatPointerV1 pointer;
  final ScenarioReplayerSpec scenario;
}

class CampaignSpineRunResultV1 {
  const CampaignSpineRunResultV1({
    required this.winner,
    required this.reason,
    required this.finalSnapshot,
  });

  final ReplayerSeat winner;
  final String reason;
  final ScenarioReplayerViewModel finalSnapshot;
}

class CampaignSpineCompletionV1 {
  const CampaignSpineCompletionV1({
    required this.applied,
    required this.packCompleted,
    required this.nextPackId,
    required this.nextWorldId,
    required this.nextBeatIndex,
  });

  final bool applied;
  final bool packCompleted;
  final String nextPackId;
  final int nextWorldId;
  final int nextBeatIndex;
}

abstract class CampaignSpineProgressStoreV1 {
  Future<String?> getActivePackId();

  Future<void> setActivePackId(String packId);

  Future<void> clearActivePackId();

  Future<int> getNextHandIndex();

  Future<void> setNextHandIndex(int index);

  Future<void> markPackCompleted(String packId);

  Future<bool> isPackCompleted(String packId);

  Future<String> getNextPackToRun();

  int worldIndexForPackId(String packId);

  int handCountForPackId(String packId);

  campaign_registry.MicroTaskStep beatForPackIdAndIndex(
    String packId,
    int index,
  );
}

class CampaignSpineRunnerV1 {
  CampaignSpineRunnerV1({required CampaignSpineProgressStoreV1 store})
    : _store = store;

  final CampaignSpineProgressStoreV1 _store;

  Future<CampaignSpineBeatPointerV1> getNextBeat() async {
    final activePack = await _store.getActivePackId();
    final packId = (activePack == null || activePack.isEmpty)
        ? await _store.getNextPackToRun()
        : activePack;

    final totalBeats = _store.handCountForPackId(packId);
    final rawIndex = await _store.getNextHandIndex();
    final beatIndex = rawIndex.clamp(0, totalBeats - 1);
    final beat = _store.beatForPackIdAndIndex(packId, beatIndex);

    return CampaignSpineBeatPointerV1(
      packId: packId,
      worldId: _store.worldIndexForPackId(packId),
      beatIndex: beatIndex,
      totalBeats: totalBeats,
      beat: beat,
    );
  }

  Future<CampaignSpineRunPlanV1> startRun() async {
    final pointer = await getNextBeat();
    await _store.setActivePackId(pointer.packId);
    await _store.setNextHandIndex(pointer.beatIndex);
    return CampaignSpineRunPlanV1(
      pointer: pointer,
      scenario: scenarioForPointer(pointer),
    );
  }

  CampaignSpineRunResultV1 runScenario({
    required CampaignSpineRunPlanV1 plan,
    ReplayerActionKind action = ReplayerActionKind.callCheck,
    int? amount,
  }) {
    final engine = ScenarioReplayerEngine(plan.scenario);
    engine.dispatch(const StartHandEvent());
    engine.dispatch(
      SubmitActionEvent(seat: ReplayerSeat.hero, kind: action, amount: amount),
    );
    engine.dispatch(const ResolveStreetEvent());
    final outcome = engine.dispatch(const CompleteEvaluationEvent());
    if (outcome == null) {
      throw StateError('Scenario completed without outcome');
    }
    return CampaignSpineRunResultV1(
      winner: outcome.winner,
      reason: outcome.reason,
      finalSnapshot: outcome.finalSnapshot,
    );
  }

  Future<CampaignSpineCompletionV1> completeRun({
    required CampaignSpineRunPlanV1 plan,
    required CampaignSpineRunResultV1 result,
  }) async {
    final packId = plan.pointer.packId;
    final beatIndex = plan.pointer.beatIndex;
    final activePack = await _store.getActivePackId();
    final persistedIndex = await _store.getNextHandIndex();

    if (activePack != null && activePack.isNotEmpty && activePack != packId) {
      final nextPack = await _store.getNextPackToRun();
      return CampaignSpineCompletionV1(
        applied: false,
        packCompleted: await _store.isPackCompleted(packId),
        nextPackId: nextPack,
        nextWorldId: _store.worldIndexForPackId(nextPack),
        nextBeatIndex: persistedIndex,
      );
    }

    if (persistedIndex > beatIndex) {
      final currentPack = activePack ?? await _store.getNextPackToRun();
      return CampaignSpineCompletionV1(
        applied: false,
        packCompleted: await _store.isPackCompleted(packId),
        nextPackId: currentPack,
        nextWorldId: _store.worldIndexForPackId(currentPack),
        nextBeatIndex: persistedIndex,
      );
    }

    if (await _store.isPackCompleted(packId)) {
      final nextPack = await _store.getNextPackToRun();
      return CampaignSpineCompletionV1(
        applied: false,
        packCompleted: true,
        nextPackId: nextPack,
        nextWorldId: _store.worldIndexForPackId(nextPack),
        nextBeatIndex: 0,
      );
    }

    final totalBeats = _store.handCountForPackId(packId);
    final isLastBeat = beatIndex >= totalBeats - 1;

    if (!isLastBeat) {
      final nextIndex = beatIndex + 1;
      await _store.setNextHandIndex(nextIndex);
      return CampaignSpineCompletionV1(
        applied: true,
        packCompleted: false,
        nextPackId: packId,
        nextWorldId: _store.worldIndexForPackId(packId),
        nextBeatIndex: nextIndex,
      );
    }

    await _store.markPackCompleted(packId);
    await _store.clearActivePackId();
    await _store.setNextHandIndex(0);

    final nextPack = await _store.getNextPackToRun();
    return CampaignSpineCompletionV1(
      applied: true,
      packCompleted: true,
      nextPackId: nextPack,
      nextWorldId: _store.worldIndexForPackId(nextPack),
      nextBeatIndex: 0,
    );
  }

  OutcomeSummaryV1 buildOutcomeSummary({
    required CampaignSpineRunPlanV1 plan,
    required CampaignSpineRunResultV1 result,
    int? timeToDecisionMs,
  }) {
    return OutcomeSummaryV1.fromScenarioResult(
      packId: plan.pointer.packId,
      worldId: plan.pointer.worldId,
      beatIndex: plan.pointer.beatIndex,
      winner: result.winner,
      reason: result.reason,
      finalSnapshot: result.finalSnapshot,
      timeToDecisionMs: timeToDecisionMs,
    );
  }

  ScenarioReplayerSpec scenarioForPointer(CampaignSpineBeatPointerV1 pointer) {
    final baseStack = 100 + (pointer.worldId * 10);
    final street = _streetForBeat(pointer.beatIndex);
    final preflopPattern = pointer.beatIndex % 3;
    const bbUnits = 2; // 1 unit = 0.5 BB
    late final int toCall;
    late final int minRaiseTo;
    late final int pot;

    if (street == ReplayerStreet.preflop) {
      if (preflopPattern == 0) {
        // Unopened preflop: default to BB to call and 2.5x open target.
        toCall = bbUnits;
        minRaiseTo = 5; // 2.5 BB open in 0.5 BB units
        pot = 3; // SB(1) + BB(2)
      } else {
        // Facing an open preflop: keep deterministic and realistic 3-bet floor.
        final openTo = preflopPattern == 1 ? 5 : 6;
        toCall = openTo;
        final minStep = openTo - bbUnits;
        minRaiseTo = openTo + (minStep > 0 ? minStep : 2);
        pot = openTo + bbUnits + 1; // opener + blinds
      }
    } else {
      final postflopToCall = 4 + (pointer.beatIndex % 3) * 2;
      toCall = postflopToCall;
      minRaiseTo = toCall + 4;
      pot = toCall * 2;
    }
    return ScenarioReplayerSpec(
      initialSnapshot: ReplayerSnapshot(
        heroStack: baseStack,
        villainStack: baseStack,
        pot: pot,
        toCall: toCall,
        street: street,
        actingSeat: ReplayerSeat.hero,
        minRaiseTo: minRaiseTo,
      ),
      steps: <ReplayerStep>[
        ReplayerStep(
          actingSeat: ReplayerSeat.hero,
          legalActions: <ReplayerActionSpec>[
            const ReplayerActionSpec(kind: ReplayerActionKind.fold),
            const ReplayerActionSpec(kind: ReplayerActionKind.callCheck),
            ReplayerActionSpec(
              kind: ReplayerActionKind.betRaise,
              minAmount: minRaiseTo,
            ),
          ],
        ),
      ],
    );
  }

  ReplayerStreet _streetForBeat(int beatIndex) {
    if (beatIndex <= 2) return ReplayerStreet.preflop;
    if (beatIndex <= 5) return ReplayerStreet.flop;
    if (beatIndex <= 8) return ReplayerStreet.turn;
    return ReplayerStreet.river;
  }
}
