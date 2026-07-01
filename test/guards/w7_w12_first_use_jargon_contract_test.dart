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
        'w5',
        'outs',
        'draw',
        'future card',
        'improve',
        'flush draw',
        'open-ended',
        'one-gap',
      ],
      'world9_spine_campaign_v1': <String>[
        'after spotting a draw',
        'call price',
        'pot reward',
        'risk',
        'worth paying',
        'same price check',
        'no clear draw',
      ],
      'world10_spine_campaign_v1': <String>[
        'w4',
        'bets and prices exist',
        'w9',
        'call price',
        'worse hands',
        'stronger hands',
      ],
      'world11_spine_campaign_v1': <String>[
        'dry board',
        'connected board',
        'suited',
        'texture',
        'danger',
        'specific',
        'path',
        'improve',
        'fewer obvious straight or flush paths',
      ],
      'world12_spine_campaign_v1': <String>[
        'volume i',
        'visible cards',
        'range',
        'draw',
        'call price',
        'bet purpose',
        'texture',
        'missed cue',
        'earlier clues come together',
        'payoff is the process',
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
