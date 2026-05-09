import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart'
    as campaign_registry;
import 'package:poker_analyzer/services/campaign_spine_runner_v1.dart';
import 'package:poker_analyzer/services/progress_service.dart';

class CampaignSpineProgressStoreAdapterV1
    implements CampaignSpineProgressStoreV1 {
  const CampaignSpineProgressStoreAdapterV1();

  @override
  campaign_registry.MicroTaskStep beatForPackIdAndIndex(
    String packId,
    int index,
  ) {
    final normalized = packId.trim().toLowerCase();
    final pack = campaign_registry.kCampaignPacksV1[normalized];
    if (pack == null || pack.isEmpty) {
      throw StateError('Unknown campaign pack: $normalized');
    }
    if (index < 0 || index >= pack.length) {
      throw RangeError.index(index, pack, 'index');
    }
    return pack[index];
  }

  @override
  Future<void> clearActivePackId() {
    return ProgressService.clearSpineActivePackV1();
  }

  @override
  Future<int> getNextHandIndex() {
    return ProgressService.getSpineNextHandIndexV1();
  }

  @override
  Future<String> getNextPackToRun() {
    return ProgressService.getNextSpinePackToRunV1();
  }

  @override
  Future<String?> getActivePackId() {
    return ProgressService.getSpineActivePackIdV1();
  }

  @override
  int handCountForPackId(String packId) {
    return campaign_registry.campaignHandCountForPackIdV1(packId);
  }

  @override
  Future<bool> isPackCompleted(String packId) {
    return ProgressService.isSpinePackCompletedV1(packId);
  }

  @override
  Future<void> markPackCompleted(String packId) {
    return ProgressService.markSpinePackCompletedV1(packId);
  }

  @override
  Future<void> setActivePackId(String packId) {
    return ProgressService.setSpineActivePackIdV1(packId);
  }

  @override
  Future<void> setNextHandIndex(int index) {
    return ProgressService.setSpineNextHandIndexV1(index);
  }

  @override
  int worldIndexForPackId(String packId) {
    return ProgressService.worldIndexForPackIdV1(packId);
  }
}
