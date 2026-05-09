import 'package:poker_analyzer/models/card_model.dart';

class HeroHoleBoardDealV1 {
  const HeroHoleBoardDealV1({required this.heroHole2, required this.board5});

  final List<CardModel> heroHole2;
  final List<CardModel> board5;
}

class DeterministicDealV1 {
  const DeterministicDealV1._();

  static HeroHoleBoardDealV1 dealForPointer({
    required String packId,
    required String pointerKey,
    required int handIndex,
  }) {
    final seedInput = '$packId|$pointerKey|$handIndex';
    var state = _fnv1a32(seedInput);
    if (state == 0) {
      state = 0x9e3779b9;
    }

    final deck = List<int>.generate(52, (i) => i);
    for (var i = deck.length - 1; i > 0; i--) {
      state = _xorshift32(state);
      final j = state % (i + 1);
      final tmp = deck[i];
      deck[i] = deck[j];
      deck[j] = tmp;
    }

    final hero = <CardModel>[_toCard(deck[0]), _toCard(deck[1])];
    final board = <CardModel>[
      _toCard(deck[2]),
      _toCard(deck[3]),
      _toCard(deck[4]),
      _toCard(deck[5]),
      _toCard(deck[6]),
    ];
    return HeroHoleBoardDealV1(
      heroHole2: List<CardModel>.unmodifiable(hero),
      board5: List<CardModel>.unmodifiable(board),
    );
  }

  static int _fnv1a32(String input) {
    var hash = 0x811c9dc5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0xffffffff;
  }

  static int _xorshift32(int state) {
    var x = state & 0xffffffff;
    x ^= (x << 13) & 0xffffffff;
    x ^= (x >> 17) & 0xffffffff;
    x ^= (x << 5) & 0xffffffff;
    return x & 0xffffffff;
  }

  static CardModel _toCard(int index) {
    const ranks = <String>[
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
    ];
    const suits = <String>['♠', '♥', '♦', '♣'];
    final rank = ranks[index % 13];
    final suit = suits[(index ~/ 13) % 4];
    return CardModel(rank: rank, suit: suit);
  }
}
