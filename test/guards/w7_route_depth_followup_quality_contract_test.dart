import 'package:flutter_test/flutter_test.dart';
import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  const w7PackIds = <String>[
    'world7_spine_campaign_v1',
    'world7_spine_followup_v1_b0',
    'world7_spine_followup_v1_b1',
    'world7_spine_followup_v1_b2',
  ];

  test('W7 route packs teach visible cards changing ranges', () {
    for (final packId in w7PackIds) {
      final pack = kCampaignPacksV1[packId];
      expect(pack, isNotNull, reason: packId);
      expect(pack, isNotEmpty, reason: packId);

      final copy = pack!
          .map(
            (step) => <String>[
              step.prompt,
              step.hint,
              step.contextText ?? '',
              step.tradeoffText ?? '',
              step.consequenceText ?? '',
              step.insightText ?? '',
            ].join(' '),
          )
          .join(' ')
          .toLowerCase();

      expect(copy, contains('visible'), reason: packId);
      expect(copy, contains('range'), reason: packId);
      expect(copy, contains('possible'), reason: packId);
      expect(copy, isNot(contains('seat label')), reason: packId);
      expect(copy, isNot(contains('range thinking lite')), reason: packId);
      expect(copy, isNot(contains('combo density')), reason: packId);
      expect(copy, isNot(contains('card removal')), reason: packId);
      expect(copy, isNot(contains('solver')), reason: packId);
      expect(copy, isNot(contains('gto')), reason: packId);
      expect(copy, isNot(contains('mastered')), reason: packId);
      expect(copy, isNot(contains('guaranteed')), reason: packId);
      expect(copy, isNot(contains('public')), reason: packId);
      expect(copy, isNot(contains('playable')), reason: packId);
    }
  });

  test('W7 route packs give concrete repair feedback', () {
    for (final packId in w7PackIds) {
      final pack = kCampaignPacksV1[packId]!;
      expect(
        pack.any(
          (step) => (step.insightText ?? '').toLowerCase().contains('exact'),
        ),
        isTrue,
        reason: '$packId needs exact-hand repair copy',
      );
      expect(
        pack.any(
          (step) => (step.insightText ?? '').toLowerCase().contains('still'),
        ),
        isTrue,
        reason: '$packId needs possible-hands-still-exist copy',
      );
    }
  });
}
