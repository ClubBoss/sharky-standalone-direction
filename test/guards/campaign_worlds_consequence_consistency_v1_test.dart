import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  test('world1..world10 spine packs keep consequence consistency floor', () {
    for (var world = 1; world <= 10; world++) {
      final packId = 'world${world}_spine_campaign_v1';
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: 'Missing pack: $packId');
      final steps = pack12(pack!);
      expect(steps.length, 12, reason: 'Hand count drift for $packId');
      expect(
        distinctConsequenceTextCount(steps),
        greaterThanOrEqualTo(12),
        reason: 'Consequence variety dropped for $packId',
      );
    }
  });

  test(
    'world1..world10 spine packs avoid consecutive duplicate consequences',
    () {
      for (var world = 1; world <= 10; world++) {
        final packId = 'world${world}_spine_campaign_v1';
        final pack = kCampaignPacksV1[packId];
        expect(pack, isNotNull, reason: 'Missing pack: $packId');
        final steps = pack12(pack!);
        var previous = '';
        for (var i = 0; i < steps.length; i++) {
          final current = (steps[i].consequenceText ?? '').trim();
          if (current.isEmpty) {
            previous = current;
            continue;
          }
          expect(
            current == previous,
            isFalse,
            reason: 'Consecutive duplicate consequence in $packId at index $i',
          );
          previous = current;
        }
      }
    },
  );
}
