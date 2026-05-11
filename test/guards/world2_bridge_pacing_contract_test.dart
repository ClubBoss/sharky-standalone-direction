import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  test(
    'world2 spine campaign breaks action-choice pressure before a third decision beat',
    () {
      final pack = kCampaignPacksV1['world2_spine_campaign_v1'];
      expect(pack, isNotNull, reason: 'Missing pack: world2_spine_campaign_v1');

      final prompts = pack!
          .map((step) => step.prompt.trim())
          .toList(growable: false);

      final preflopIndex = prompts.indexOf(
        'Preflop decision in Hijack: facing an open.',
      );
      final flopIndex = prompts.indexOf(
        'Flop decision in Cutoff: board is visible.',
      );
      final recapIndex = prompts.indexOf(
        'Seat recap: find Under the Gun again.',
      );
      final turnIndex = prompts.indexOf(
        'Turn decision in Big Blind: read the fourth board card.',
      );

      expect(preflopIndex, greaterThanOrEqualTo(0));
      expect(flopIndex, preflopIndex + 1);
      expect(recapIndex, flopIndex + 1);
      expect(turnIndex, recapIndex + 1);
    },
  );
}
