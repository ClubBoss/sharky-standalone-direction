import 'package:flutter_test/flutter_test.dart';

import 'package:poker_analyzer/campaign/campaign_pack_registry_v1.dart';

void main() {
  test('W7-W12 first route-visible jargon is beginner-contextualized', () {
    final checks = <String, List<String>>{
      'world7_spine_campaign_v1': <String>[
        'visible',
        'range',
        'range buckets',
        'possible',
        'narrow',
        'one exact hand',
        'not proof of one exact hand',
      ],
      'world8_spine_campaign_v1': <String>[
        'stack depth',
        'chips behind',
        'all-in pressure',
        'stack',
        'risk',
        'commitment',
      ],
      'world9_spine_campaign_v1': <String>[
        'tournament pressure',
        'survival',
        'bubble',
        'payout',
        'risk premium',
        'risk',
      ],
      'world10_spine_campaign_v1': <String>[
        'player tendency',
        'one lever',
        'guardrail',
        'player adjustment',
        'measured exploit',
        'sample size',
      ],
      'world11_spine_campaign_v1': <String>[
        'session plan',
        'one focus',
        'trigger',
        'review',
        'real play transfer',
        'one review output',
      ],
      'world12_spine_campaign_v1': <String>[
        'process',
        'reset',
        'discipline',
        'mindset bridge',
        'volume i review',
        'not a future world',
      ],
    };

    for (final entry in checks.entries) {
      final pack = kCampaignPacksV1[entry.key];
      expect(pack, isNotNull, reason: entry.key);
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

      for (final expected in entry.value) {
        expect(copy, contains(expected), reason: '${entry.key}: $expected');
      }
    }
  });
}
