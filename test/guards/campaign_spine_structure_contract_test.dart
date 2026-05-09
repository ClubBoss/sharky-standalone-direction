import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  const spinePackIds = <String>[
    'world1_spine_campaign_v1',
    'world2_spine_campaign_v1',
    'world3_spine_campaign_v1',
    'world4_spine_campaign_v1',
    'world5_spine_campaign_v1',
    'world6_spine_campaign_v1',
    'world7_spine_campaign_v1',
    'world8_spine_campaign_v1',
    'world9_spine_campaign_v1',
    'world10_spine_campaign_v1',
  ];

  test('campaign spine packs keep structural beat contract', () {
    for (final packId in spinePackIds) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'Missing spine pack: $packId');

      final steps = pack12(pack!);
      expect(steps.length, 12, reason: 'Spine must stay 12 hands: $packId');
      expect(
        distinctConsequenceTextCount(steps),
        greaterThanOrEqualTo(8),
        reason: 'Spine consequence variety too low: $packId',
      );
      expect(
        spinePackHasEarlyPositiveBeatV1(packId),
        isTrue,
        reason: 'Missing early positive beat: $packId',
      );
      expect(
        spinePackHasMidPressureBeatsV1(packId),
        isTrue,
        reason: 'Missing mid pressure beats: $packId',
      );
      expect(
        spinePackHasContrastBeatV1(packId),
        isTrue,
        reason: 'Missing contrast beat: $packId',
      );
      expect(
        spinePackHasStrongFinalBeatV1(packId),
        isTrue,
        reason: 'Missing strong final beat: $packId',
      );
    }
  });
}
