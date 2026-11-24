import 'dart:convert';

import 'package:test/test.dart';

import 'transfer_novelty_check_v1.dart';

TransferSpotV1 _spot({
  String cards = 'As Ks',
  double price = 3,
  String? handBucket = 'premium',
  List<String> actions = const ['call', 'fold'],
}) => (
  position: 'btn',
  price: price,
  thresholdBucket: 'above',
  handBucket: handBucket,
  actionSet: actions,
  answer: ['call'],
  spot: 'preflop',
  cosmetics: cards,
);

void _checkB44Fixtures() {
  for (final (repeat, expected, missing) in [
    (
      _spot(actions: ['fold', 'call']),
      TransferNoveltyV1.paraphrase,
      <String>[],
    ),
    (_spot(cards: 'Ah Kh'), TransferNoveltyV1.cosmetic, <String>[]),
    (_spot(price: 4), TransferNoveltyV1.changedDecision, <String>[]),
    (_spot(handBucket: null), TransferNoveltyV1.unknown, ['repeat.handBucket']),
  ]) {
    final result = classifyTransferNoveltyV1(_spot(), repeat);
    if (result.classification != expected ||
        result.missing.join(',') != missing.join(',')) {
      throw StateError('Expected $expected with $missing, got $result');
    }
  }
}

Map<String, dynamic> _row(String id, List<List<String>> cards) => {
  'id': id,
  'position': ['btn', 'btn'],
  'price': 1,
  'decisionPotBb': 3,
  'thresholdBucket': null,
  'equityPct': 25,
  'handBucket': null,
  'actionSet': ['call', 'fold'],
  'answer': ['call'],
  'spot': '["playedHand", "sixMax", 6, "turn", 3]',
  'cosmetics': jsonEncode([cards]),
};

void main() {
  test('B44 fixtures', _checkB44Fixtures);

  for (final (cards, bucket) in [
    (
      [
        ['T', 's'],
        ['T', 'd'],
      ],
      'pair',
    ),
    (
      [
        ['T', 's'],
        ['J', 's'],
      ],
      'suited broadway',
    ),
    (
      [
        ['T', 's'],
        ['9', 's'],
      ],
      'suited connector',
    ),
    (
      [
        ['T', 's'],
        ['J', 'd'],
      ],
      'offsuit broadway',
    ),
    (
      [
        ['T', 's'],
        ['9', 'd'],
      ],
      'other',
    ),
    (
      [
        ['Q', 's'],
        ['9', 's'],
      ],
      'other',
    ),
    (
      [
        ['A', 's'],
        ['2', 's'],
      ],
      'other',
    ),
    (
      [
        ['T', 's'],
        ['T', 's'],
      ],
      null,
    ),
    (
      [
        ['?', ''],
        ['T', 's'],
      ],
      null,
    ),
  ]) {
    test('hand bucket for $cards is $bucket', () {
      expect(transferHandBucketV2(cards), bucket);
    });
  }

  test('price rounds to the nearest five percentage points', () {
    expect(transferPriceBucketV2(75.1, 24.9), 25);
    expect(transferPriceBucketV2(75, 25), 25);
    expect(transferPriceBucketV2(7751, 2249), 20);
    expect(transferPriceBucketV2(7750, 2250), 25);
    expect(transferPriceBucketV2(10, 0), 0);
    expect(transferPriceBucketV2(0, 0), isNull);
    expect(transferPriceBucketV2(10, -1), isNull);
  });

  test('equity is compared to the unrounded threshold', () {
    expect(transferThresholdBucketV2(24.9, 3, 1), ['equity', -1]);
    expect(transferThresholdBucketV2(25, 3, 1), ['equity', 0]);
    expect(transferThresholdBucketV2(25.1, 3, 1), ['equity', 1]);
    expect(transferThresholdBucketV2(25, 751, 249), ['equity', 1]);
    expect(transferThresholdBucketV2(null, 3, 1), isNull);
  });

  test('fallbacks use comparable buckets with per-side provenance', () {
    final source = _row('source', [
      ['T', 's'],
      ['J', 's'],
    ])..['handBucket'] = 'chart-group';
    final repeat = _row('repeat', [
      ['T', 'h'],
      ['J', 'h'],
    ]);
    final pair = classifyTransferPairV2(source, repeat);
    expect(pair.result.classification, TransferNoveltyV1.cosmetic);
    expect(pair.derived, {
      'source.handBucket': 'suited broadway',
      'repeat.handBucket': 'suited broadway',
      'source.price': 25,
      'repeat.price': 25,
      'source.thresholdBucket': ['equity', 0],
      'repeat.thresholdBucket': ['equity', 0],
    });
  });

  test('different task IDs with no repeat equity remain unknown', () {
    final source = _row('source', [
      ['T', 's'],
      ['J', 's'],
    ]);
    final repeat = _row('repeat', [
      ['T', 'h'],
      ['J', 'h'],
    ])..['equityPct'] = null;
    final pair = classifyTransferPairV2(source, repeat);
    expect(pair.result.classification, TransferNoveltyV1.unknown);
    expect(pair.result.missing, ['repeat.thresholdBucket']);
  });

  test(
    'only an identical snapshot with the same task ID proves exact replay',
    () {
      final source =
          _row('task', [
              ['T', 's'],
              ['J', 's'],
            ])
            ..['actionSet'] = null
            ..['answer'] = null;
      final replay = classifyTransferPairV2(source, {...source});
      expect(replay.exactReplay, isTrue);
      expect(replay.result.classification, TransferNoveltyV1.paraphrase);

      final changed = classifyTransferPairV2(source, {...source, 'price': 2});
      expect(changed.exactReplay, isFalse);
      expect(changed.result.classification, TransferNoveltyV1.unknown);
    },
  );
}
