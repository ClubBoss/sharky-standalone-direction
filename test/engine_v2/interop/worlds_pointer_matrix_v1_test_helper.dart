import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_pack_registry;
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';

List<CampaignSpineBeatPointerV1> buildWorldPointerMatrixV1({
  int pointersPerWorld = 4,
}) {
  if (pointersPerWorld < 1) {
    throw ArgumentError('pointersPerWorld must be >= 1');
  }
  final store = CampaignRegistryStoreV1TestHelper();
  final pointers = <CampaignSpineBeatPointerV1>[];
  for (var world = 1; world <= 10; world++) {
    final packId = 'world${world}_spine_campaign_v1';
    final handCount = store.handCountForPackId(packId);
    if (handCount < 2) {
      throw StateError('Pack $packId must have at least 2 hands');
    }
    final indexSet = <int>{0, 1, handCount ~/ 2, handCount - 1};
    final sorted = indexSet.toList()..sort();
    final selected = sorted.take(pointersPerWorld).toList();
    for (final beatIndex in selected) {
      pointers.add(
        CampaignSpineBeatPointerV1(
          packId: packId,
          worldId: world,
          beatIndex: beatIndex,
          totalBeats: handCount,
          beat: store.beatForPackIdAndIndex(packId, beatIndex),
        ),
      );
    }
  }
  return List<CampaignSpineBeatPointerV1>.unmodifiable(pointers);
}

class CampaignRegistryStoreV1TestHelper
    implements CampaignSpineProgressStoreV1 {
  @override
  campaign_pack_registry.MicroTaskStep beatForPackIdAndIndex(
    String packId,
    int index,
  ) {
    final normalized = packId.trim().toLowerCase();
    final pack = campaign_pack_registry.kCampaignPacksV1[normalized];
    if (pack == null || pack.isEmpty) {
      throw StateError('Unknown campaign pack: $packId');
    }
    if (index < 0 || index >= pack.length) {
      throw RangeError.index(index, pack, 'index');
    }
    return pack[index];
  }

  @override
  Future<void> clearActivePackId() async {}

  @override
  Future<String?> getActivePackId() async => null;

  @override
  Future<int> getNextHandIndex() async => 0;

  @override
  Future<String> getNextPackToRun() async => 'world1_spine_campaign_v1';

  @override
  int handCountForPackId(String packId) {
    return campaign_pack_registry.campaignHandCountForPackIdV1(packId);
  }

  @override
  Future<bool> isPackCompleted(String packId) async => false;

  @override
  Future<void> markPackCompleted(String packId) async {}

  @override
  Future<void> setActivePackId(String packId) async {}

  @override
  Future<void> setNextHandIndex(int index) async {}

  @override
  int worldIndexForPackId(String packId) {
    final match = RegExp(r'^world(\d+)_').firstMatch(packId.trim());
    if (match == null) {
      throw StateError('Cannot parse world index from packId: $packId');
    }
    return int.parse(match.group(1)!);
  }
}
