import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  test(
    'world2 spine campaign introduces nearby-family variation before six straight seat-locate beats',
    () {
      final pack = kCampaignPacksV1['world2_spine_campaign_v1'];
      expect(pack, isNotNull, reason: 'Missing pack: world2_spine_campaign_v1');

      final prompts = pack!
          .map((step) => step.prompt.trim())
          .toList(growable: false);

      expect(prompts[0], 'Find Under the Gun');
      expect(prompts[1], 'Find Hijack');
      expect(prompts[2], 'Find Cutoff');
      expect(prompts[3], 'Find the Button');
      expect(prompts[4], 'Preflop decision in Hijack: facing an open.');
      expect(prompts[5], 'Find Small Blind');
      expect(prompts[6], 'Find Big Blind');
    },
  );
}
