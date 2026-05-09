import 'package:poker_analyzer/engine_v2/cards/deterministic_deal_v1.dart';
import 'package:test/test.dart';

void main() {
  test('same inputs produce identical deal', () {
    final a = DeterministicDealV1.dealForPointer(
      packId: 'world1_spine_campaign_v1',
      pointerKey: '1:0',
      handIndex: 0,
    );
    final b = DeterministicDealV1.dealForPointer(
      packId: 'world1_spine_campaign_v1',
      pointerKey: '1:0',
      handIndex: 0,
    );

    final heroA = a.heroHole2.map((c) => '${c.rank}${c.suit}').toList();
    final heroB = b.heroHole2.map((c) => '${c.rank}${c.suit}').toList();
    final boardA = a.board5.map((c) => '${c.rank}${c.suit}').toList();
    final boardB = b.board5.map((c) => '${c.rank}${c.suit}').toList();

    expect(heroA, equals(heroB));
    expect(boardA, equals(boardB));
  });

  test('different handIndex changes deal', () {
    final a = DeterministicDealV1.dealForPointer(
      packId: 'world1_spine_campaign_v1',
      pointerKey: '1:0',
      handIndex: 0,
    );
    final b = DeterministicDealV1.dealForPointer(
      packId: 'world1_spine_campaign_v1',
      pointerKey: '1:0',
      handIndex: 1,
    );

    final cardsA = <String>[
      ...a.heroHole2.map((c) => '${c.rank}${c.suit}'),
      ...a.board5.map((c) => '${c.rank}${c.suit}'),
    ];
    final cardsB = <String>[
      ...b.heroHole2.map((c) => '${c.rank}${c.suit}'),
      ...b.board5.map((c) => '${c.rank}${c.suit}'),
    ];
    expect(cardsA.join('|') == cardsB.join('|'), isFalse);
  });

  test('deal contains no duplicates and valid cards', () {
    final deal = DeterministicDealV1.dealForPointer(
      packId: 'world10_spine_campaign_v1',
      pointerKey: '10:11',
      handIndex: 11,
    );

    const validRanks = <String>{
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      'T',
      'J',
      'Q',
      'K',
      'A',
    };
    const validSuits = <String>{'♠', '♥', '♦', '♣'};

    expect(deal.heroHole2.length, 2);
    expect(deal.board5.length, 5);

    final all = <String>[
      ...deal.heroHole2.map((c) => '${c.rank}${c.suit}'),
      ...deal.board5.map((c) => '${c.rank}${c.suit}'),
    ];
    expect(all.toSet().length, 7);

    for (final c in [...deal.heroHole2, ...deal.board5]) {
      expect(validRanks.contains(c.rank), isTrue);
      expect(validSuits.contains(c.suit), isTrue);
    }
  });
}
