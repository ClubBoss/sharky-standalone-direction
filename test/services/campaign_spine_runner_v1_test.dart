import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_registry;
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:test/test.dart';

class _MemorySpineStore implements CampaignSpineProgressStoreV1 {
  _MemorySpineStore({required this.packOrder});

  final List<String> packOrder;
  final Set<String> _completed = <String>{};
  String? _activePackId;
  int _nextHandIndex = 0;

  @override
  campaign_registry.MicroTaskStep beatForPackIdAndIndex(
    String packId,
    int index,
  ) {
    final pack = campaign_registry.kCampaignPacksV1[packId];
    if (pack == null) {
      throw StateError('Unknown pack: $packId');
    }
    return pack[index];
  }

  @override
  Future<void> clearActivePackId() async {
    _activePackId = null;
  }

  @override
  Future<int> getNextHandIndex() async => _nextHandIndex;

  @override
  Future<String> getNextPackToRun() async {
    for (final pack in packOrder) {
      if (!_completed.contains(pack)) {
        return pack;
      }
    }
    return packOrder.last;
  }

  @override
  Future<String?> getActivePackId() async => _activePackId;

  @override
  int handCountForPackId(String packId) =>
      campaign_registry.campaignHandCountForPackIdV1(packId);

  @override
  Future<bool> isPackCompleted(String packId) async =>
      _completed.contains(packId);

  @override
  Future<void> markPackCompleted(String packId) async {
    _completed.add(packId);
  }

  @override
  Future<void> setActivePackId(String packId) async {
    _activePackId = packId;
  }

  @override
  Future<void> setNextHandIndex(int index) async {
    _nextHandIndex = index;
  }

  @override
  int worldIndexForPackId(String packId) {
    return int.parse(RegExp(r'world(\d+)').firstMatch(packId)!.group(1)!);
  }
}

void main() {
  const world1 = 'world1_spine_campaign_v1';
  const world2 = 'world2_spine_campaign_v1';
  const world9 = 'world9_spine_campaign_v1';
  const world10 = 'world10_spine_campaign_v1';

  CampaignSpineRunnerV1 buildRunner(_MemorySpineStore store) {
    return CampaignSpineRunnerV1(store: store);
  }

  test('pointer advances to next beat after completion', () async {
    final store = _MemorySpineStore(packOrder: <String>[world1, world2]);
    final runner = buildRunner(store);

    final plan = await runner.startRun();
    expect(plan.pointer.packId, world1);
    expect(plan.pointer.beatIndex, 0);

    final runResult = runner.runScenario(plan: plan);
    final completion = await runner.completeRun(plan: plan, result: runResult);

    expect(completion.applied, isTrue);
    expect(completion.packCompleted, isFalse);
    expect(completion.nextPackId, world1);
    expect(completion.nextBeatIndex, 1);
  });

  test('double completion call is idempotent (no double counting)', () async {
    final store = _MemorySpineStore(packOrder: <String>[world1, world2]);
    final runner = buildRunner(store);

    final plan = await runner.startRun();
    final result = runner.runScenario(plan: plan);

    final first = await runner.completeRun(plan: plan, result: result);
    final second = await runner.completeRun(plan: plan, result: result);

    expect(first.applied, isTrue);
    expect(first.nextBeatIndex, 1);
    expect(second.applied, isFalse);
    expect(second.nextBeatIndex, 1);
    expect(second.nextPackId, world1);
  });

  test('completing last beat advances to next world start', () async {
    final store = _MemorySpineStore(packOrder: <String>[world1, world2]);
    final runner = buildRunner(store);

    await store.setActivePackId(world1);
    await store.setNextHandIndex(
      campaign_registry.campaignHandCountForPackIdV1(world1) - 1,
    );

    final plan = await runner.startRun();
    final result = runner.runScenario(plan: plan);
    final completion = await runner.completeRun(plan: plan, result: result);

    expect(completion.applied, isTrue);
    expect(completion.packCompleted, isTrue);
    expect(completion.nextPackId, world2);
    expect(completion.nextWorldId, 2);
    expect(completion.nextBeatIndex, 0);

    final nextPointer = await runner.getNextBeat();
    expect(nextPointer.packId, world2);
    expect(nextPointer.worldId, 2);
    expect(nextPointer.beatIndex, 0);
  });

  test('double completion on last beat is idempotent', () async {
    final store = _MemorySpineStore(packOrder: <String>[world1, world2]);
    final runner = buildRunner(store);

    await store.setActivePackId(world1);
    await store.setNextHandIndex(
      campaign_registry.campaignHandCountForPackIdV1(world1) - 1,
    );

    final plan = await runner.startRun();
    final result = runner.runScenario(plan: plan);
    final first = await runner.completeRun(plan: plan, result: result);
    final second = await runner.completeRun(plan: plan, result: result);

    expect(first.applied, isTrue);
    expect(first.packCompleted, isTrue);
    expect(first.nextPackId, world2);

    expect(second.applied, isFalse);
    expect(second.packCompleted, isTrue);
    expect(second.nextPackId, world2);
    expect(second.nextBeatIndex, 0);
  });

  test('completing world9 last beat advances to world10 start', () async {
    final store = _MemorySpineStore(packOrder: <String>[world9, world10]);
    final runner = buildRunner(store);

    await store.setActivePackId(world9);
    await store.setNextHandIndex(
      campaign_registry.campaignHandCountForPackIdV1(world9) - 1,
    );

    final plan = await runner.startRun();
    final result = runner.runScenario(plan: plan);
    final completion = await runner.completeRun(plan: plan, result: result);

    expect(completion.applied, isTrue);
    expect(completion.packCompleted, isTrue);
    expect(completion.nextPackId, world10);
    expect(completion.nextWorldId, 10);
    expect(completion.nextBeatIndex, 0);
  });

  test(
    'world10 terminal completion remains in deterministic stable state',
    () async {
      final store = _MemorySpineStore(packOrder: <String>[world10]);
      final runner = buildRunner(store);

      await store.setActivePackId(world10);
      await store.setNextHandIndex(
        campaign_registry.campaignHandCountForPackIdV1(world10) - 1,
      );

      final plan = await runner.startRun();
      final result = runner.runScenario(plan: plan);
      final completion = await runner.completeRun(plan: plan, result: result);

      expect(completion.applied, isTrue);
      expect(completion.packCompleted, isTrue);
      expect(completion.nextPackId, world10);
      expect(completion.nextWorldId, 10);
      expect(completion.nextBeatIndex, 0);

      final pointer = await runner.getNextBeat();
      expect(pointer.packId, world10);
      expect(pointer.worldId, 10);
      expect(pointer.beatIndex, 0);
    },
  );

  test(
    'outcome summary formatting is deterministic for same run input',
    () async {
      final store = _MemorySpineStore(packOrder: <String>[world1, world2]);
      final runner = buildRunner(store);

      final plan = await runner.startRun();
      final result = runner.runScenario(plan: plan);

      final first = runner.buildOutcomeSummary(
        plan: plan,
        result: result,
        timeToDecisionMs: 420,
      );
      final second = runner.buildOutcomeSummary(
        plan: plan,
        result: result,
        timeToDecisionMs: 420,
      );

      expect(first.packId, plan.pointer.packId);
      expect(first.worldId, plan.pointer.worldId);
      expect(first.beatIndex, plan.pointer.beatIndex);
      expect(first.lines, second.lines);
      expect(first.lines, isNotEmpty);
      expect(first.lines.first, 'Pack: ${plan.pointer.packId}');
    },
  );
}
