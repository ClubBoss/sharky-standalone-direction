import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  test('all campaign followup packs satisfy invariants', () {
    final followupIds = campaignFollowupPackIdsV1();

    expect(followupIds.length, 30);

    for (final packId in followupIds) {
      expect(
        campaignHandCountForPackIdV1(packId),
        12,
        reason: 'Followup pack hand count drift: $packId',
      );
      expect(
        distinctConsequenceTextCountForPackIdV1(packId),
        greaterThanOrEqualTo(6),
        reason: 'Followup consequence variety too low: $packId',
      );
      expect(
        hasPositiveAndNegativeConsequenceDeltasForPackIdV1(packId),
        isTrue,
        reason: 'Followup pack missing +/- consequence signals: $packId',
      );
    }
  });

  test('world1 followup b2 keeps stronger consequence variety', () {
    const packId = 'world1_spine_followup_v1_b2';

    expect(campaignHandCountForPackIdV1(packId), 12);
    expect(
      distinctConsequenceTextCountForPackIdV1(packId),
      greaterThanOrEqualTo(8),
    );
    expect(hasPositiveAndNegativeConsequenceDeltasForPackIdV1(packId), isTrue);
  });
}
